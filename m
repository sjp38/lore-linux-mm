Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0CDDC6B0292
	for <linux-mm@kvack.org>; Mon, 29 May 2017 04:15:28 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id m5so61019613pfc.1
        for <linux-mm@kvack.org>; Mon, 29 May 2017 01:15:28 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 5si8192157plx.25.2017.05.29.01.15.26
        for <linux-mm@kvack.org>;
        Mon, 29 May 2017 01:15:27 -0700 (PDT)
Date: Mon, 29 May 2017 17:15:25 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: add counters for different page fault types
Message-ID: <20170529081525.GA8311@bbox>
References: <20170524194126.18040-1-semenzato@chromium.org>
 <20170525001915.GA14999@bbox>
 <CAA25o9SH=LSeeRAfHfMK0JyPuDfzLMMOvyXz5RZJ5taa3hybhw@mail.gmail.com>
 <20170526040622.GB17837@bbox>
 <CAA25o9QG=Juynu-8wAYvdY1t7YNGVtE10fav2u3S-DikuU=aMQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9QG=Juynu-8wAYvdY1t7YNGVtE10fav2u3S-DikuU=aMQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Douglas Anderson <dianders@google.com>, Dmitry Torokhov <dtor@google.com>, Sonny Rao <sonnyrao@google.com>

Hi Luigi,

On Fri, May 26, 2017 at 11:43:48AM -0700, Luigi Semenzato wrote:
> Many thanks Minchan.
> 
> On Thu, May 25, 2017 at 9:06 PM, Minchan Kim <minchan@kernel.org> wrote:
> 
> > If it is swap cache hit, it's not a major fault which causes IO
> > so VM count it as minor fault, not major.
> 
> Cool---but see below.
> 
> > Yub, I expected you guys used zram with readahead off so it shouldn't
> > be a big problem.
> 
> By the way, I was referring to page clustering.  We do this in sysctl.conf:

It's readahead of swap.
I meant it exactly. :)

> 
> # Disable swap read-ahead
> vm.page-cluster = 0
> 
> I figured that the readahead from the disk device
> (/sys/block/zram0/queue/read_ahead_kb) is not meaningful---am I
> correct?

Yub.

> 
> These numbers are from a Chromebook with a few dozen Chrome tabs and a
> couple of Android apps, and pretty heavy use of zram.
> 
> pgpgin 4688863
> pgpgout 442052
> pswpin 353675
> pswpout 1072021
> ...
> pgfault 5564247
> pgmajfault 355758
> pgmajfault_s 6297
> pgmajfault_a 317645
> pgmajfault_f 31816
> pgmajfault_ax 8494
> pgmajfault_fx 13201
> 
> where _s, _a, and _f are for shmem, anon, and file pages.
> (ax and fx are for the subset of executable pages---I was curious about that)
> 
> So the numbers don't completely match:
> anon faults = 318,000
> swap ins = 354,000
> 
> Any idea of what might explain the difference?

Some of application call madvise(MADV_WILLNEED) for shmem or anon?

> 
> > About auto resetting readahead with zram, I agree with you.
> > But there are some reasons I postpone the work. No want to discuss
> > it in this thread/moment. ;)
> 
> Yes, I wasn't even thinking of auto-resetting, just log a warning.
> 
> >> Incidentally, I understand anon and file faults, but what's a shmem fault?
> >
> > For me, it was out of my interest but if you want to count shmem fault,
> > maybe, we need to introdue new stat(e.g., PSWPIN_SHM) in shmem_swapin
> > but there are concrete reasons to justify in changelog. :)
> 
> Actually mine was a simpler question---I have no idea what a major
> shmem fault is.   And for this experiment it's a relatively small
> number, but a similar order of magnitude to the (expensive) file
> faults, so I don't want to completely ignore it.

Yes, it's doable but a thing we need to merge new stat is concrete
justification rather than "Having, Better. Why not?" approach.
In my testing, I just wanted to know just file vs anon LRU balancing
so it was out of my interest but you might have a reason to know it.
Then, you can send a patch with detailed changelog. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
