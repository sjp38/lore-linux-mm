Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E867D6B02B4
	for <linux-mm@kvack.org>; Wed, 24 May 2017 02:18:48 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p74so188734648pfd.11
        for <linux-mm@kvack.org>; Tue, 23 May 2017 23:18:48 -0700 (PDT)
Received: from mail-pg0-x234.google.com (mail-pg0-x234.google.com. [2607:f8b0:400e:c05::234])
        by mx.google.com with ESMTPS id p21si14920184pgc.277.2017.05.23.23.18.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 23:18:47 -0700 (PDT)
Received: by mail-pg0-x234.google.com with SMTP id q125so60698623pgq.2
        for <linux-mm@kvack.org>; Tue, 23 May 2017 23:18:47 -0700 (PDT)
Date: Wed, 24 May 2017 15:18:40 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
Message-ID: <20170524061839.GB8672@js1304-desktop>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
 <ebcc02d9-fa2b-30b1-2260-99cdf7434487@virtuozzo.com>
 <20170519015348.GA1763@js1304-desktop>
 <0c14ea7f-1ae9-5923-8c4c-4f1b2f7dad62@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0c14ea7f-1ae9-5923-8c4c-4f1b2f7dad62@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

On Mon, May 22, 2017 at 05:00:29PM +0300, Andrey Ryabinin wrote:
> 
> 
> On 05/19/2017 04:53 AM, Joonsoo Kim wrote:
> > On Wed, May 17, 2017 at 03:17:13PM +0300, Andrey Ryabinin wrote:
> >> On 05/16/2017 04:16 AM, js1304@gmail.com wrote:
> >>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >>>
> >>> Hello, all.
> >>>
> >>> This is an attempt to recude memory consumption of KASAN. Please see
> >>> following description to get the more information.
> >>>
> >>> 1. What is per-page shadow memory
> >>>
> >>> This patch introduces infrastructure to support per-page shadow memory.
> >>> Per-page shadow memory is the same with original shadow memory except
> >>> the granualarity. It's one byte shows the shadow value for the page.
> >>> The purpose of introducing this new shadow memory is to save memory
> >>> consumption.
> >>>
> >>> 2. Problem of current approach
> >>>
> >>> Until now, KASAN needs shadow memory for all the range of the memory
> >>> so the amount of statically allocated memory is so large. It causes
> >>> the problem that KASAN cannot run on the system with hard memory
> >>> constraint. Even if KASAN can run, large memory consumption due to
> >>> KASAN changes behaviour of the workload so we cannot validate
> >>> the moment that we want to check.
> >>>
> >>> 3. How does this patch fix the problem
> >>>
> >>> This patch tries to fix the problem by reducing memory consumption for
> >>> the shadow memory. There are two observations.
> >>>
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
> > 
> > I agree that it is also a good option to reduce memory consumption.
> > Nevertheless, there are two reasons that justifies this patchset.
> > 
> > 1) With this patchset, memory consumption isn't increased in
> > proportional to total memory size. Please consider my 4Gb system
> > example on the below. With increasing shadow scale size to 32, memory
> > would be consumed by 128M. However, this patchset consumed 50MB. This
> > difference can be larger if we run KASAN with bigger machine.
> > 
> 
> Well, yes, but I assume that bigger machine implies that we can use more memory without
> causing a significant change in system's behavior.

In common case, yes. But, I guess that there is a system that
statically uses most of memory and just a few memory is left for others.
For example, consider 64GB system and some program (DB?) runs with
using 60GB. Only 4GB left. If KASAN uses 2GB, just 2GB is left and it
would cause the problem. So, I'd like to insist that this merit 1)
should be considered as valuable.

> 
> > 2) These two optimization can be applied simulatenously. It is just an
> > orthogonal feature. If shadow scale size is increased to 32, memory
> > consumption will be decreased in case of my patchset, too.
> > 
> > Therefore, I think that this patchset is useful in any case.
>  
> These are valid points, but IMO it's not enough to justify this patchset.
> Too much of hacky and fragile code.
> 
> If our goal is to make KASAN to eat less memory, the first step definitely would be a 1/32 shadow.
> Simply because it's the best way to achieve that goal.
> And only if it's not enough we could think about something else, like decreasing/turning off quarantine
> and/or smaller redzones.

Please refer the reply to Dmitry. I think that we need an option that
everything else than something compulsory is the same with non-KASAN
build as much as possible. 1/32 scale would change object layout so it
will not work for this option.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
