Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 025086B0037
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 20:16:51 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id hl1so3848050igb.1
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 17:16:51 -0700 (PDT)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id q6si3861243igr.23.2014.03.13.17.16.50
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 17:16:51 -0700 (PDT)
Date: Fri, 14 Mar 2014 09:16:58 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: cma: alloc_contig_range test_pages_isolated .. failed
Message-ID: <20140314001658.GG16062@bbox>
References: <CAA6Yd9V=RJpysp1u3_+nA6ttWMNdYdRTn1o8fyOX35faaOtx2w@mail.gmail.com>
 <20140312232924.GK17828@bbox>
 <CAA6Yd9VjuYDYAZDrf=dPz-e-hAeJeUnisfFOmNj0LQYzFG=w2A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA6Yd9VjuYDYAZDrf=dPz-e-hAeJeUnisfFOmNj0LQYzFG=w2A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ramakrishnan Muthukrishnan <vu3rdd@gmail.com>
Cc: linux-mm@kvack.org, Laura Abbott <lauraa@codeaurora.org>

On Thu, Mar 13, 2014 at 09:24:25AM +0530, Ramakrishnan Muthukrishnan wrote:
> Hello,
> 
> On Thu, Mar 13, 2014 at 4:59 AM, Minchan Kim <minchan@kernel.org> wrote:
> >
> > On Tue, Mar 11, 2014 at 07:32:34PM +0530, Ramakrishnan Muthukrishnan wrote:
> >> Hello linux-mm hackers,
> >>
> >> We have a TI OMAP4 based system running 3.4 kernel. OMAP4 has got 2 M3
> >> processors which is used for some media tasks.
> >>
> >> During bootup, the M3 firmware is loaded and it used CMA to allocate 3
> >> regions for DMA, as seen by these logs:
> >>
> >> [    0.000000] cma: dma_declare_contiguous(size a400000, base
> >> 99000000, limit 00000000)
> >> [    0.000000] cma: CMA: reserved 168 MiB at 99000000
> >> [    0.000000] cma: dma_declare_contiguous(size 2000000, base
> >> 00000000, limit 00000000)
> >> [    0.000000] cma: CMA: reserved 32 MiB at ad800000
> >> [    0.000000] cma: dma_contiguous_reserve(limit af800000)
> >> [    0.000000] cma: dma_contiguous_reserve: reserving 16 MiB for global area
> >> [    0.000000] cma: dma_declare_contiguous(size 1000000, base
> >> 00000000, limit af800000)
> >> [    0.000000] cma: CMA: reserved 16 MiB at ac000000
> >> [    0.243652] cma: cma_init_reserved_areas()
> >> [    0.243682] cma: cma_create_area(base 00099000, count a800)
> >> [    0.253417] cma: cma_create_area: returned ed0ee400
> >> [...]
> >>
> >> We observed that if we reboot a system without unmounting the file
> >> systems (like in abrupt power off..etc), after the fresh reboot, the
> >> file system checks are performed, the firmware load is delayed by ~4
> >> seconds (compared to the one without fsck) and then we see the
> >> following in the kernel bootup logs:
> >>
> >> [   26.846313] alloc_contig_range test_pages_isolated(a2e00, a3400) failed
> >> [   26.853515] alloc_contig_range test_pages_isolated(a2e00, a3500) failed
> >> [   26.860809] alloc_contig_range test_pages_isolated(a3100, a3700) failed
> >> [   26.868133] alloc_contig_range test_pages_isolated(a3200, a3800) failed
> >> [   26.875213] rproc remoteproc0: dma_alloc_coherent failed: 6291456
> >> [   26.881744] rproc remoteproc0: Failed to process resources: -12
> >> [   26.902221] omap_hwmod: ipu: failed to hardreset
> >> [   26.909545] omap_hwmod: ipu: _wait_target_disable failed
> >> [   26.916748] rproc remoteproc0: rproc_boot() failed -12
> >>
> >> The M3 firmware load fails because of this. I have been looking at the
> >> git logs to see if this is fixed in the later checkins, since this is
> >> a bit old kernel. For various non-technical reasons which I have no
> >> control of, we can't move to a newer kernel. But I could backport any
> >> fixes done in newer kernel. Also I am totally new to memory management
> >> in the kernel, so any help in debugging is highly appreciated.
> >
> > Could you try this one?
> > https://lkml.org/lkml/2012/8/31/313
> > I didn't reviewd that patch carefully but I guess you have similar problem.
> > So, if it fixes your problem, we should review that patch carefully and
> > merge if it doesn't have any problem and we couldn't find better solution.
> 
> It didn't fix the problem, unfortunately. In fact my kernel already
> had that patch applied (by a TI engineer):
> 
> commit df9cf0bdf4a59e0fe6604f92f52028c259da69ad
> Author: Guillaume Aubertin <g-aubertin@ti.com>
> Date:   Mon Sep 10 20:27:08 2012 +0800
> 
>     CMA: removing buffers from LRU when migrating
> 
>     based on the fix provided by Laura Abbott :
>     https://lkml.org/lkml/2012/8/31/313

3.4 was initial version for CMA and AFAIR, there were lots of problem and
have fixed until now. I don't know how many patches TI backported to 3.4
so it's really hard to see your problem.

Anyway, patches I can suggest to you are following as

[1] bb13ffeb9, mm: compaction: cache if a pageblock was scanned and no pages were isolated
[2] 627260595, mm: compaction: fix bit ranges in {get,clear,set}_pageblock_skip()

Totally, I forgot what they are but at least, Thierry had similar problem
and it was fixed by that.
https://lkml.org/lkml/2012/9/27/281

Hopefully, It helps you, too.

And please keep in mind. In 3.4, CMA has many problems so although we might
fix poped up problem, you could encounter others in runtime, too unless TI
enginner follows recent fixes.


> 
> Thanks
> Ramakrishnan
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
