Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B22816B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 14:41:40 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b28so7816373wrb.2
        for <linux-mm@kvack.org>; Tue, 30 May 2017 11:41:40 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id e5si14964654wrc.304.2017.05.30.11.41.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 11:41:39 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id e127so108416635wmg.1
        for <linux-mm@kvack.org>; Tue, 30 May 2017 11:41:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170529081525.GA8311@bbox>
References: <20170524194126.18040-1-semenzato@chromium.org>
 <20170525001915.GA14999@bbox> <CAA25o9SH=LSeeRAfHfMK0JyPuDfzLMMOvyXz5RZJ5taa3hybhw@mail.gmail.com>
 <20170526040622.GB17837@bbox> <CAA25o9QG=Juynu-8wAYvdY1t7YNGVtE10fav2u3S-DikuU=aMQ@mail.gmail.com>
 <20170529081525.GA8311@bbox>
From: Luigi Semenzato <semenzato@google.com>
Date: Tue, 30 May 2017 11:41:37 -0700
Message-ID: <CAA25o9Q0ewQyRe=VYOvx2M6FmOxwoRbLqOSmgxfDuJGuExCkQg@mail.gmail.com>
Subject: Re: [PATCH] mm: add counters for different page fault types
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Douglas Anderson <dianders@google.com>, Dmitry Torokhov <dtor@google.com>, Sonny Rao <sonnyrao@google.com>

On Mon, May 29, 2017 at 1:15 AM, Minchan Kim <minchan@kernel.org> wrote:

>> These numbers are from a Chromebook with a few dozen Chrome tabs and a
>> couple of Android apps, and pretty heavy use of zram.
>>
>> pgpgin 4688863
>> pgpgout 442052
>> pswpin 353675
>> pswpout 1072021
>> ...
>> pgfault 5564247
>> pgmajfault 355758
>> pgmajfault_s 6297
>> pgmajfault_a 317645
>> pgmajfault_f 31816
>> pgmajfault_ax 8494
>> pgmajfault_fx 13201
>>
>> where _s, _a, and _f are for shmem, anon, and file pages.
>> (ax and fx are for the subset of executable pages---I was curious about that)
>>
>> So the numbers don't completely match:
>> anon faults = 318,000
>> swap ins = 354,000
>>
>> Any idea of what might explain the difference?
>
> Some of application call madvise(MADV_WILLNEED) for shmem or anon?

Thank you for the suggestion.  Nevertheless, the problem is that
pgmajfault - pswpin is 2,000, which is far from the 32,000 major file
faults, and figuring out where the difference comes from is not
simple.  (Or is it, and I am just too lazy?  Often it's hard to tell
:)

> Yes, it's doable but a thing we need to merge new stat is concrete
> justification rather than "Having, Better. Why not?" approach.
> In my testing, I just wanted to know just file vs anon LRU balancing
> so it was out of my interest but you might have a reason to know it.
> Then, you can send a patch with detailed changelog. :)

Yes I agree, I don't like adding random stats either "just in case
they are useful".

For this stat, we too are interested in the balance between FILE and
ANON faults, because a zram page fault costs us about 10us, but the
latency from disk read to service the FILE fault is about 300us.  So
we want to ensure we're tuning swappiness correctly (and by the way,
we also apply another patch which allows swappiness values up to 200
instead of the obsolete 100 limit).  We run experiments, but we're
also collecting stats from the field (for the users that permit it),
so we have applied this patch to all our kernels.

This is as full an explanation as I can give concisely, would this be enough?

So there is benefit for us in getting this level of detail from
vmstat.  Of course it's not clear that the benefit extends to the
greater community.  If it is deemed to not be sufficiently important
to add those vmstat fields (3 more fields added to about 100, although
we could just add 2 since pgmajfault = sum(pjmajfault_{a,f,s}) then we
can maintain them separately for Chrome OS, and that will be fine.

Thanks!



>
> Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
