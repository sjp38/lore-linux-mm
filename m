Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 569D06B0279
	for <linux-mm@kvack.org>; Fri, 26 May 2017 14:43:51 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y43so1598956wrc.11
        for <linux-mm@kvack.org>; Fri, 26 May 2017 11:43:51 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a24sor8749wra.34.2017.05.26.11.43.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 May 2017 11:43:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170526040622.GB17837@bbox>
References: <20170524194126.18040-1-semenzato@chromium.org>
 <20170525001915.GA14999@bbox> <CAA25o9SH=LSeeRAfHfMK0JyPuDfzLMMOvyXz5RZJ5taa3hybhw@mail.gmail.com>
 <20170526040622.GB17837@bbox>
From: Luigi Semenzato <semenzato@google.com>
Date: Fri, 26 May 2017 11:43:48 -0700
Message-ID: <CAA25o9QG=Juynu-8wAYvdY1t7YNGVtE10fav2u3S-DikuU=aMQ@mail.gmail.com>
Subject: Re: [PATCH] mm: add counters for different page fault types
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Douglas Anderson <dianders@google.com>, Dmitry Torokhov <dtor@google.com>, Sonny Rao <sonnyrao@google.com>

Many thanks Minchan.

On Thu, May 25, 2017 at 9:06 PM, Minchan Kim <minchan@kernel.org> wrote:

> If it is swap cache hit, it's not a major fault which causes IO
> so VM count it as minor fault, not major.

Cool---but see below.

> Yub, I expected you guys used zram with readahead off so it shouldn't
> be a big problem.

By the way, I was referring to page clustering.  We do this in sysctl.conf:

# Disable swap read-ahead
vm.page-cluster = 0

I figured that the readahead from the disk device
(/sys/block/zram0/queue/read_ahead_kb) is not meaningful---am I
correct?

These numbers are from a Chromebook with a few dozen Chrome tabs and a
couple of Android apps, and pretty heavy use of zram.

pgpgin 4688863
pgpgout 442052
pswpin 353675
pswpout 1072021
...
pgfault 5564247
pgmajfault 355758
pgmajfault_s 6297
pgmajfault_a 317645
pgmajfault_f 31816
pgmajfault_ax 8494
pgmajfault_fx 13201

where _s, _a, and _f are for shmem, anon, and file pages.
(ax and fx are for the subset of executable pages---I was curious about that)

So the numbers don't completely match:
anon faults = 318,000
swap ins = 354,000

Any idea of what might explain the difference?

> About auto resetting readahead with zram, I agree with you.
> But there are some reasons I postpone the work. No want to discuss
> it in this thread/moment. ;)

Yes, I wasn't even thinking of auto-resetting, just log a warning.

>> Incidentally, I understand anon and file faults, but what's a shmem fault?
>
> For me, it was out of my interest but if you want to count shmem fault,
> maybe, we need to introdue new stat(e.g., PSWPIN_SHM) in shmem_swapin
> but there are concrete reasons to justify in changelog. :)

Actually mine was a simpler question---I have no idea what a major
shmem fault is.   And for this experiment it's a relatively small
number, but a similar order of magnitude to the (expensive) file
faults, so I don't want to completely ignore it.

Thanks again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
