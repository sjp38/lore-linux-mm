Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2DCF36B02B4
	for <linux-mm@kvack.org>; Wed, 24 May 2017 20:46:51 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e8so211270963pfl.4
        for <linux-mm@kvack.org>; Wed, 24 May 2017 17:46:51 -0700 (PDT)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id o186si26375055pga.24.2017.05.24.17.46.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 17:46:50 -0700 (PDT)
Received: by mail-pf0-x22b.google.com with SMTP id 9so150753642pfj.1
        for <linux-mm@kvack.org>; Wed, 24 May 2017 17:46:50 -0700 (PDT)
Date: Thu, 25 May 2017 09:46:40 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
Message-ID: <20170525004638.GB21336@js1304-desktop>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
 <ebcc02d9-fa2b-30b1-2260-99cdf7434487@virtuozzo.com>
 <20170519015348.GA1763@js1304-desktop>
 <CACT4Y+bZVJpi++kfMkAc-3pXK165ZQyHaEU_6oN94+qQErJd8A@mail.gmail.com>
 <20170524060432.GA8672@js1304-desktop>
 <CACT4Y+b56nGv6WcTqysa=Xxdksxr-c9-tCzBxEY8PzfVYAUbrA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+b56nGv6WcTqysa=Xxdksxr-c9-tCzBxEY8PzfVYAUbrA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

On Wed, May 24, 2017 at 06:31:04PM +0200, Dmitry Vyukov wrote:
> On Wed, May 24, 2017 at 8:04 AM, Joonsoo Kim <js1304@gmail.com> wrote:
> >> >> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >> >> >
> >> >> > Hello, all.
> >> >> >
> >> >> > This is an attempt to recude memory consumption of KASAN. Please see
> >> >> > following description to get the more information.
> >> >> >
> >> >> > 1. What is per-page shadow memory
> >> >> >
> >> >> > This patch introduces infrastructure to support per-page shadow memory.
> >> >> > Per-page shadow memory is the same with original shadow memory except
> >> >> > the granualarity. It's one byte shows the shadow value for the page.
> >> >> > The purpose of introducing this new shadow memory is to save memory
> >> >> > consumption.
> >> >> >
> >> >> > 2. Problem of current approach
> >> >> >
> >> >> > Until now, KASAN needs shadow memory for all the range of the memory
> >> >> > so the amount of statically allocated memory is so large. It causes
> >> >> > the problem that KASAN cannot run on the system with hard memory
> >> >> > constraint. Even if KASAN can run, large memory consumption due to
> >> >> > KASAN changes behaviour of the workload so we cannot validate
> >> >> > the moment that we want to check.
> >> >> >
> >> >> > 3. How does this patch fix the problem
> >> >> >
> >> >> > This patch tries to fix the problem by reducing memory consumption for
> >> >> > the shadow memory. There are two observations.
> >> >> >
> >> >>
> >> >>
> >> >> I think that the best way to deal with your problem is to increase shadow scale size.
> >> >>
> >> >> You'll need to add tunable to gcc to control shadow size. I expect that gcc has some
> >> >> places where 8-shadow scale size is hardcoded, but it should be fixable.
> >> >>
> >> >> The kernel also have some small amount of code written with KASAN_SHADOW_SCALE_SIZE == 8 in mind,
> >> >> which should be easy to fix.
> >> >>
> >> >> Note that bigger shadow scale size requires bigger alignment of allocated memory and variables.
> >> >> However, according to comments in gcc/asan.c gcc already aligns stack and global variables and at
> >> >> 32-bytes boundary.
> >> >> So we could bump shadow scale up to 32 without increasing current stack consumption.
> >> >>
> >> >> On a small machine (1Gb) 1/32 of shadow is just 32Mb which is comparable to yours 30Mb, but I expect it to be
> >> >> much faster. More importantly, this will require only small amount of simple changes in code, which will be
> >> >> a *lot* more easier to maintain.
> >>
> >>
> >> Interesting option. We never considered increasing scale in user space
> >> due to performance implications. But the algorithm always supported up
> >> to 128x scale. Definitely worth considering as an option.
> >
> > Could you explain me how does increasing scale reduce performance? I
> > tried to guess the reason but failed.
> 
> 
> The main reason is inline instrumentation. Inline instrumentation for
> a check of 8-byte access (which are very common in 64-bit code) is
> just a check of the shadow byte for 0. For smaller accesses we have
> more complex instrumentation that first checks shadow for 0 and then
> does precise check based on size/offset of the access + shadow value.
> That's slower and also increases register pressure and code size
> (which can further reduce performance due to icache overflow). If we
> increase scale to 16/32, all accesses will need that slow path.
> Another thing is stack instrumentation: larger scale will require
> larger redzones to ensure proper alignment. That will increase stack
> frames and also more instructions to poison/unpoison stack shadow on
> function entry/exit.

Now, I see. Thanks for explanation.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
