Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f53.google.com (mail-oa0-f53.google.com [209.85.219.53])
	by kanga.kvack.org (Postfix) with ESMTP id 972CB6B0031
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 23:54:47 -0400 (EDT)
Received: by mail-oa0-f53.google.com with SMTP id j17so468285oag.26
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 20:54:47 -0700 (PDT)
Received: from mail-oa0-x232.google.com (mail-oa0-x232.google.com [2607:f8b0:4003:c02::232])
        by mx.google.com with ESMTPS id kb7si682090oeb.141.2014.03.12.20.54.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 12 Mar 2014 20:54:46 -0700 (PDT)
Received: by mail-oa0-f50.google.com with SMTP id i7so479237oag.23
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 20:54:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140312232924.GK17828@bbox>
References: <CAA6Yd9V=RJpysp1u3_+nA6ttWMNdYdRTn1o8fyOX35faaOtx2w@mail.gmail.com>
 <20140312232924.GK17828@bbox>
From: Ramakrishnan Muthukrishnan <vu3rdd@gmail.com>
Date: Thu, 13 Mar 2014 09:24:25 +0530
Message-ID: <CAA6Yd9VjuYDYAZDrf=dPz-e-hAeJeUnisfFOmNj0LQYzFG=w2A@mail.gmail.com>
Subject: Re: cma: alloc_contig_range test_pages_isolated .. failed
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Laura Abbott <lauraa@codeaurora.org>

Hello,

On Thu, Mar 13, 2014 at 4:59 AM, Minchan Kim <minchan@kernel.org> wrote:
>
> On Tue, Mar 11, 2014 at 07:32:34PM +0530, Ramakrishnan Muthukrishnan wrote:
>> Hello linux-mm hackers,
>>
>> We have a TI OMAP4 based system running 3.4 kernel. OMAP4 has got 2 M3
>> processors which is used for some media tasks.
>>
>> During bootup, the M3 firmware is loaded and it used CMA to allocate 3
>> regions for DMA, as seen by these logs:
>>
>> [    0.000000] cma: dma_declare_contiguous(size a400000, base
>> 99000000, limit 00000000)
>> [    0.000000] cma: CMA: reserved 168 MiB at 99000000
>> [    0.000000] cma: dma_declare_contiguous(size 2000000, base
>> 00000000, limit 00000000)
>> [    0.000000] cma: CMA: reserved 32 MiB at ad800000
>> [    0.000000] cma: dma_contiguous_reserve(limit af800000)
>> [    0.000000] cma: dma_contiguous_reserve: reserving 16 MiB for global area
>> [    0.000000] cma: dma_declare_contiguous(size 1000000, base
>> 00000000, limit af800000)
>> [    0.000000] cma: CMA: reserved 16 MiB at ac000000
>> [    0.243652] cma: cma_init_reserved_areas()
>> [    0.243682] cma: cma_create_area(base 00099000, count a800)
>> [    0.253417] cma: cma_create_area: returned ed0ee400
>> [...]
>>
>> We observed that if we reboot a system without unmounting the file
>> systems (like in abrupt power off..etc), after the fresh reboot, the
>> file system checks are performed, the firmware load is delayed by ~4
>> seconds (compared to the one without fsck) and then we see the
>> following in the kernel bootup logs:
>>
>> [   26.846313] alloc_contig_range test_pages_isolated(a2e00, a3400) failed
>> [   26.853515] alloc_contig_range test_pages_isolated(a2e00, a3500) failed
>> [   26.860809] alloc_contig_range test_pages_isolated(a3100, a3700) failed
>> [   26.868133] alloc_contig_range test_pages_isolated(a3200, a3800) failed
>> [   26.875213] rproc remoteproc0: dma_alloc_coherent failed: 6291456
>> [   26.881744] rproc remoteproc0: Failed to process resources: -12
>> [   26.902221] omap_hwmod: ipu: failed to hardreset
>> [   26.909545] omap_hwmod: ipu: _wait_target_disable failed
>> [   26.916748] rproc remoteproc0: rproc_boot() failed -12
>>
>> The M3 firmware load fails because of this. I have been looking at the
>> git logs to see if this is fixed in the later checkins, since this is
>> a bit old kernel. For various non-technical reasons which I have no
>> control of, we can't move to a newer kernel. But I could backport any
>> fixes done in newer kernel. Also I am totally new to memory management
>> in the kernel, so any help in debugging is highly appreciated.
>
> Could you try this one?
> https://lkml.org/lkml/2012/8/31/313
> I didn't reviewd that patch carefully but I guess you have similar problem.
> So, if it fixes your problem, we should review that patch carefully and
> merge if it doesn't have any problem and we couldn't find better solution.

It didn't fix the problem, unfortunately. In fact my kernel already
had that patch applied (by a TI engineer):

commit df9cf0bdf4a59e0fe6604f92f52028c259da69ad
Author: Guillaume Aubertin <g-aubertin@ti.com>
Date:   Mon Sep 10 20:27:08 2012 +0800

    CMA: removing buffers from LRU when migrating

    based on the fix provided by Laura Abbott :
    https://lkml.org/lkml/2012/8/31/313

Thanks
Ramakrishnan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
