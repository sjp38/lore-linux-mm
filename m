Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 57DE86B02C4
	for <linux-mm@kvack.org>; Wed, 17 May 2017 08:15:31 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id x64so8203654pgd.6
        for <linux-mm@kvack.org>; Wed, 17 May 2017 05:15:31 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0111.outbound.protection.outlook.com. [104.47.0.111])
        by mx.google.com with ESMTPS id d8si1950376plj.104.2017.05.17.05.15.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 17 May 2017 05:15:29 -0700 (PDT)
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <ebcc02d9-fa2b-30b1-2260-99cdf7434487@virtuozzo.com>
Date: Wed, 17 May 2017 15:17:13 +0300
MIME-Version: 1.0
In-Reply-To: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 05/16/2017 04:16 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Hello, all.
> 
> This is an attempt to recude memory consumption of KASAN. Please see
> following description to get the more information.
> 
> 1. What is per-page shadow memory
> 
> This patch introduces infrastructure to support per-page shadow memory.
> Per-page shadow memory is the same with original shadow memory except
> the granualarity. It's one byte shows the shadow value for the page.
> The purpose of introducing this new shadow memory is to save memory
> consumption.
> 
> 2. Problem of current approach
> 
> Until now, KASAN needs shadow memory for all the range of the memory
> so the amount of statically allocated memory is so large. It causes
> the problem that KASAN cannot run on the system with hard memory
> constraint. Even if KASAN can run, large memory consumption due to
> KASAN changes behaviour of the workload so we cannot validate
> the moment that we want to check.
> 
> 3. How does this patch fix the problem
> 
> This patch tries to fix the problem by reducing memory consumption for
> the shadow memory. There are two observations.
> 


I think that the best way to deal with your problem is to increase shadow scale size.

You'll need to add tunable to gcc to control shadow size. I expect that gcc has some
places where 8-shadow scale size is hardcoded, but it should be fixable.

The kernel also have some small amount of code written with KASAN_SHADOW_SCALE_SIZE == 8 in mind,
which should be easy to fix.

Note that bigger shadow scale size requires bigger alignment of allocated memory and variables.
However, according to comments in gcc/asan.c gcc already aligns stack and global variables and at
32-bytes boundary.
So we could bump shadow scale up to 32 without increasing current stack consumption.

On a small machine (1Gb) 1/32 of shadow is just 32Mb which is comparable to yours 30Mb, but I expect it to be
much faster. More importantly, this will require only small amount of simple changes in code, which will be
a *lot* more easier to maintain.

I'd start from implementing this on the kernel side only. With KASAN_OUTLINE and disabled
stack instrumentation (--param asan-stack=0) it's doable without any changes in gcc.


...
> base vs patched
> 
> MemTotal: 858 MB vs 987 MB
> runtime: 0 MB vs 30MB
> Net Available: 858 MB vs 957 MB
> 
> For 4096 MB QEMU system
> 
> MemTotal: 3477 MB vs 4000 MB
> runtime: 0 MB vs 50MB
> 
> base vs patched (2048 MB QEMU system)
> 204 s vs 224 s
> Net Available: 3477 MB vs 3950 MB
> 
> Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
