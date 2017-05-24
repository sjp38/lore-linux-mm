Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4496B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 02:04:46 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e8so189271678pfl.4
        for <linux-mm@kvack.org>; Tue, 23 May 2017 23:04:46 -0700 (PDT)
Received: from mail-pg0-x231.google.com (mail-pg0-x231.google.com. [2607:f8b0:400e:c05::231])
        by mx.google.com with ESMTPS id u20si2930820pfl.234.2017.05.23.23.04.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 23:04:45 -0700 (PDT)
Received: by mail-pg0-x231.google.com with SMTP id x64so60514626pgd.3
        for <linux-mm@kvack.org>; Tue, 23 May 2017 23:04:45 -0700 (PDT)
Date: Wed, 24 May 2017 15:04:35 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
Message-ID: <20170524060432.GA8672@js1304-desktop>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
 <ebcc02d9-fa2b-30b1-2260-99cdf7434487@virtuozzo.com>
 <20170519015348.GA1763@js1304-desktop>
 <CACT4Y+bZVJpi++kfMkAc-3pXK165ZQyHaEU_6oN94+qQErJd8A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+bZVJpi++kfMkAc-3pXK165ZQyHaEU_6oN94+qQErJd8A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

On Mon, May 22, 2017 at 08:02:36AM +0200, Dmitry Vyukov wrote:
> On Fri, May 19, 2017 at 3:53 AM, Joonsoo Kim <js1304@gmail.com> wrote:
> > On Wed, May 17, 2017 at 03:17:13PM +0300, Andrey Ryabinin wrote:
> >> On 05/16/2017 04:16 AM, js1304@gmail.com wrote:
> >> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >> >
> >> > Hello, all.
> >> >
> >> > This is an attempt to recude memory consumption of KASAN. Please see
> >> > following description to get the more information.
> >> >
> >> > 1. What is per-page shadow memory
> >> >
> >> > This patch introduces infrastructure to support per-page shadow memory.
> >> > Per-page shadow memory is the same with original shadow memory except
> >> > the granualarity. It's one byte shows the shadow value for the page.
> >> > The purpose of introducing this new shadow memory is to save memory
> >> > consumption.
> >> >
> >> > 2. Problem of current approach
> >> >
> >> > Until now, KASAN needs shadow memory for all the range of the memory
> >> > so the amount of statically allocated memory is so large. It causes
> >> > the problem that KASAN cannot run on the system with hard memory
> >> > constraint. Even if KASAN can run, large memory consumption due to
> >> > KASAN changes behaviour of the workload so we cannot validate
> >> > the moment that we want to check.
> >> >
> >> > 3. How does this patch fix the problem
> >> >
> >> > This patch tries to fix the problem by reducing memory consumption for
> >> > the shadow memory. There are two observations.
> >> >
> >>
> >>
> >> I think that the best way to deal with your problem is to increase shadow scale size.
> >>
> >> You'll need to add tunable to gcc to control shadow size. I expect that gcc has some
> >> places where 8-shadow scale size is hardcoded, but it should be fixable.
> >>
> >> The kernel also have some small amount of code written with KASAN_SHADOW_SCALE_SIZE == 8 in mind,
> >> which should be easy to fix.
> >>
> >> Note that bigger shadow scale size requires bigger alignment of allocated memory and variables.
> >> However, according to comments in gcc/asan.c gcc already aligns stack and global variables and at
> >> 32-bytes boundary.
> >> So we could bump shadow scale up to 32 without increasing current stack consumption.
> >>
> >> On a small machine (1Gb) 1/32 of shadow is just 32Mb which is comparable to yours 30Mb, but I expect it to be
> >> much faster. More importantly, this will require only small amount of simple changes in code, which will be
> >> a *lot* more easier to maintain.
> 
> 
> Interesting option. We never considered increasing scale in user space
> due to performance implications. But the algorithm always supported up
> to 128x scale. Definitely worth considering as an option.

Could you explain me how does increasing scale reduce performance? I
tried to guess the reason but failed.

> 
> 
> > I agree that it is also a good option to reduce memory consumption.
> > Nevertheless, there are two reasons that justifies this patchset.
> >
> > 1) With this patchset, memory consumption isn't increased in
> > proportional to total memory size. Please consider my 4Gb system
> > example on the below. With increasing shadow scale size to 32, memory
> > would be consumed by 128M. However, this patchset consumed 50MB. This
> > difference can be larger if we run KASAN with bigger machine.
> >
> > 2) These two optimization can be applied simulatenously. It is just an
> > orthogonal feature. If shadow scale size is increased to 32, memory
> > consumption will be decreased in case of my patchset, too.
> >
> > Therefore, I think that this patchset is useful in any case.
> 
> It is definitely useful all else being equal. But it does considerably
> increase code size and complexity, which is an important aspect.
> 
> Also note that there is also fixed size quarantine (1/32 of RAM) and
> redzones. Reducing shadow overhead beyond some threshold has
> diminishing returns, because overall overhead will be just dominated
> by quarantine/redzones.

My usecase doesn't use quarantine yet since it uses old version kernel
and quarantine isn't back-ported. But, this 1/32 of RAM for quarantine
also could affect the system and I think that we need a switch to
disable it. In our case, making the feature work is more important
than detecting more bugs.

Redzone is also a good target to make selectable since
error pattern could be changed with different object layout. I
sometimes saw that error disappears if KASAN is enabled. I'm not sure
what causes it, but, in some case, it would be helpful that everything
else than something compulsory is the same with non-KASAN build.

> What's your target devices and constraints? We run KASAN on phones
> today without any issues.

My target devices are a smart TV or embedded system on a car. Usually,
these devices have specific use scenario and memory is managed more
tightly than a phone. I have heard that some system with 1GB memory
cannot run if 128MB is used for KASAN. I'm not sure that 1/32 scale
changes the picture, but, yes, I guess that most of problem will disappear.

> 
> > Note that increasing shadow scale has it's own trade-off. It requires
> > that the size of slab object is aligned to shadow scale. It will
> > increase memory consumption due to slab.
> 
> I've tried to retest your latest change on top of
> http://git.cmpxchg.org/cgit.cgi/linux-mmots.git
> d9cd9c95cc3b2fed0f04d233ebf2f7056741858c, but now this version
> https://codereview.appspot.com/325780043 always crashes during boot
> for me. Report points to zero shadow.

Oops... Maybe, it's due to lack of stale TLB handling on double-free
check in kasan_slab_free(). I fixed it on my version 2 patchset.
And, I also fixed performance problem due to memory allocated by early
allocator(memblock or (no)bootmem).

https://github.com/JoonsooKim/linux/tree/kasan-opt-memory-consumption-v2.0-next-20170511

This branch is based on next-20170511.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
