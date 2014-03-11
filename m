Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9FBCB6B009C
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 10:02:55 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id uy5so8528434obc.34
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 07:02:55 -0700 (PDT)
Received: from mail-oa0-x22f.google.com (mail-oa0-x22f.google.com [2607:f8b0:4003:c02::22f])
        by mx.google.com with ESMTPS id sp3si24270958obb.134.2014.03.11.07.02.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 07:02:54 -0700 (PDT)
Received: by mail-oa0-f47.google.com with SMTP id i11so8638840oag.34
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 07:02:54 -0700 (PDT)
MIME-Version: 1.0
From: Ramakrishnan Muthukrishnan <vu3rdd@gmail.com>
Date: Tue, 11 Mar 2014 19:32:34 +0530
Message-ID: <CAA6Yd9V=RJpysp1u3_+nA6ttWMNdYdRTn1o8fyOX35faaOtx2w@mail.gmail.com>
Subject: cma: alloc_contig_range test_pages_isolated .. failed
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello linux-mm hackers,

We have a TI OMAP4 based system running 3.4 kernel. OMAP4 has got 2 M3
processors which is used for some media tasks.

During bootup, the M3 firmware is loaded and it used CMA to allocate 3
regions for DMA, as seen by these logs:

[    0.000000] cma: dma_declare_contiguous(size a400000, base
99000000, limit 00000000)
[    0.000000] cma: CMA: reserved 168 MiB at 99000000
[    0.000000] cma: dma_declare_contiguous(size 2000000, base
00000000, limit 00000000)
[    0.000000] cma: CMA: reserved 32 MiB at ad800000
[    0.000000] cma: dma_contiguous_reserve(limit af800000)
[    0.000000] cma: dma_contiguous_reserve: reserving 16 MiB for global area
[    0.000000] cma: dma_declare_contiguous(size 1000000, base
00000000, limit af800000)
[    0.000000] cma: CMA: reserved 16 MiB at ac000000
[    0.243652] cma: cma_init_reserved_areas()
[    0.243682] cma: cma_create_area(base 00099000, count a800)
[    0.253417] cma: cma_create_area: returned ed0ee400
[...]

We observed that if we reboot a system without unmounting the file
systems (like in abrupt power off..etc), after the fresh reboot, the
file system checks are performed, the firmware load is delayed by ~4
seconds (compared to the one without fsck) and then we see the
following in the kernel bootup logs:

[   26.846313] alloc_contig_range test_pages_isolated(a2e00, a3400) failed
[   26.853515] alloc_contig_range test_pages_isolated(a2e00, a3500) failed
[   26.860809] alloc_contig_range test_pages_isolated(a3100, a3700) failed
[   26.868133] alloc_contig_range test_pages_isolated(a3200, a3800) failed
[   26.875213] rproc remoteproc0: dma_alloc_coherent failed: 6291456
[   26.881744] rproc remoteproc0: Failed to process resources: -12
[   26.902221] omap_hwmod: ipu: failed to hardreset
[   26.909545] omap_hwmod: ipu: _wait_target_disable failed
[   26.916748] rproc remoteproc0: rproc_boot() failed -12

The M3 firmware load fails because of this. I have been looking at the
git logs to see if this is fixed in the later checkins, since this is
a bit old kernel. For various non-technical reasons which I have no
control of, we can't move to a newer kernel. But I could backport any
fixes done in newer kernel. Also I am totally new to memory management
in the kernel, so any help in debugging is highly appreciated.

thanks
-- 
  Ramakrishnan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
