Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 548386B0035
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 20:41:27 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id z10so1793097pdj.18
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 17:41:27 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id nc6si3858207pbc.23.2014.03.13.17.41.23
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 17:41:25 -0700 (PDT)
Date: Fri, 14 Mar 2014 09:41:19 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: cma: alloc_contig_range test_pages_isolated .. failed
Message-ID: <20140314004118.GA4150@lge.com>
References: <CAA6Yd9V=RJpysp1u3_+nA6ttWMNdYdRTn1o8fyOX35faaOtx2w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA6Yd9V=RJpysp1u3_+nA6ttWMNdYdRTn1o8fyOX35faaOtx2w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ramakrishnan Muthukrishnan <vu3rdd@gmail.com>
Cc: linux-mm@kvack.org

On Tue, Mar 11, 2014 at 07:32:34PM +0530, Ramakrishnan Muthukrishnan wrote:
> Hello linux-mm hackers,
> 
> We have a TI OMAP4 based system running 3.4 kernel. OMAP4 has got 2 M3
> processors which is used for some media tasks.
> 
> During bootup, the M3 firmware is loaded and it used CMA to allocate 3
> regions for DMA, as seen by these logs:
> 
> [    0.000000] cma: dma_declare_contiguous(size a400000, base
> 99000000, limit 00000000)
> [    0.000000] cma: CMA: reserved 168 MiB at 99000000
> [    0.000000] cma: dma_declare_contiguous(size 2000000, base
> 00000000, limit 00000000)
> [    0.000000] cma: CMA: reserved 32 MiB at ad800000
> [    0.000000] cma: dma_contiguous_reserve(limit af800000)
> [    0.000000] cma: dma_contiguous_reserve: reserving 16 MiB for global area
> [    0.000000] cma: dma_declare_contiguous(size 1000000, base
> 00000000, limit af800000)
> [    0.000000] cma: CMA: reserved 16 MiB at ac000000
> [    0.243652] cma: cma_init_reserved_areas()
> [    0.243682] cma: cma_create_area(base 00099000, count a800)
> [    0.253417] cma: cma_create_area: returned ed0ee400
> [...]
> 
> We observed that if we reboot a system without unmounting the file
> systems (like in abrupt power off..etc), after the fresh reboot, the
> file system checks are performed, the firmware load is delayed by ~4
> seconds (compared to the one without fsck) and then we see the
> following in the kernel bootup logs:
> 
> [   26.846313] alloc_contig_range test_pages_isolated(a2e00, a3400) failed
> [   26.853515] alloc_contig_range test_pages_isolated(a2e00, a3500) failed
> [   26.860809] alloc_contig_range test_pages_isolated(a3100, a3700) failed
> [   26.868133] alloc_contig_range test_pages_isolated(a3200, a3800) failed
> [   26.875213] rproc remoteproc0: dma_alloc_coherent failed: 6291456
> [   26.881744] rproc remoteproc0: Failed to process resources: -12
> [   26.902221] omap_hwmod: ipu: failed to hardreset
> [   26.909545] omap_hwmod: ipu: _wait_target_disable failed
> [   26.916748] rproc remoteproc0: rproc_boot() failed -12
> 
> The M3 firmware load fails because of this. I have been looking at the
> git logs to see if this is fixed in the later checkins, since this is
> a bit old kernel. For various non-technical reasons which I have no
> control of, we can't move to a newer kernel. But I could backport any
> fixes done in newer kernel. Also I am totally new to memory management
> in the kernel, so any help in debugging is highly appreciated.

Hello,

Is this log all?

In the above log, test_pages_isolated() failed for a short time. Is it root
cause of delayed firmware loading? Why "cma: dma_alloc_from_contiguous():
memory range at %p is busy, retrying" isn't appeared?

There is possible race in start_isolate_page_range() and so on, so some pages
in CMA region don't be moved to MIGRATE_ISOLATE list and test_pages_isolated()
could fail. But, it doesn't last for a long time as far as I know.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
