Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id AF6246B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 02:49:55 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so8342957pbb.19
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 23:49:55 -0700 (PDT)
Date: Tue, 15 Oct 2013 09:49:51 +0300 (EEST)
From: =?UTF-8?B?0JjQstCw0LnQu9C+INCU0LjQvNC40YLRgNC+0LI=?= <freemangordon@abv.bg>
Message-ID: <991366690.30380.1381819791799.JavaMail.apache@mail83.abv.bg>
Subject: Re: OMAPFB: CMA allocation failures
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tomi Valkeinen <tomi.valkeinen@ti.com>
Cc: pali.rohar@gmail.com, pc+n900@asdf.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

 Hi

 >-------- D?N?D,D3D,D 1/2 D?D>>D 1/2 D 3/4  D?D,N?D 1/4 D 3/4  --------
 >D?N?:  Tomi Valkeinen 
 >D?N?D 1/2 D 3/4 N?D 1/2 D 3/4 : Re: OMAPFB: CMA allocation failures
 >D?D 3/4 : D?D2D?D1D>>D 3/4  D?D,D 1/4 D,N?N?D 3/4 D2
	
 >D?D.D?N?D?N?DuD 1/2 D 3/4  D 1/2 D?: D?D 3/4 D 1/2 DuD'DuD>>D 1/2 D,Do, 2013, D?DoN?D 3/4 D 1/4 D2N?D, 14 09:04:35 EEST
 >
 >
 >Hi,
 >
 >On 12/10/13 17:43, D?D2D?D1D>>D 3/4  D?D,D 1/4 D,N?N?D 3/4 D2 wrote:
 >>  Hi Tomi,
 >> 
 >> patch http://lists.infradead.org/pipermail/linux-arm-kernel/2012-November/131269.html modifies
 >> omapfb driver to use DMA API to allocate framebuffer memory instead of preallocating VRAM.
 >> 
 >> With this patch I see a lot of:
 >> 
 >> Jan  1 06:33:27 Nokia-N900 kernel: [ 2054.879577] cma: dma_alloc_from_contiguous(cma c05f5844, count 192, align 8)
 >> Jan  1 06:33:27 Nokia-N900 kernel: [ 2054.914215] cma: dma_alloc_from_contiguous(): memory range at c07df000 is busy, retrying
 >> Jan  1 06:33:27 Nokia-N900 kernel: [ 2054.933502] cma: dma_alloc_from_contiguous(): memory range at c07e1000 is busy, retrying
 >> Jan  1 06:33:27 Nokia-N900 kernel: [ 2054.940032] cma: dma_alloc_from_contiguous(): memory range at c07e3000 is busy, retrying
 >> Jan  1 06:33:27 Nokia-N900 kernel: [ 2054.966644] cma: dma_alloc_from_contiguous(): memory range at c07e5000 is busy, retrying
 >> Jan  1 06:33:27 Nokia-N900 kernel: [ 2054.976867] cma: dma_alloc_from_contiguous(): memory range at c07e7000 is busy, retrying
 >> Jan  1 06:33:27 Nokia-N900 kernel: [ 2055.038055] cma: dma_alloc_from_contiguous(): memory range at c07e9000 is busy, retrying
 >> Jan  1 06:33:27 Nokia-N900 kernel: [ 2055.038116] cma: dma_alloc_from_contiguous(): returned   (null)
 >> Jan  1 06:33:27 Nokia-N900 kernel: [ 2055.038146] omapfb omapfb: failed to allocate framebuffer
 >> 
 >> errors while trying to play a video on N900 with Maemo 5 (Fremantle) on top of linux-3.12rc1.
 >> It is deffinitely the CMA that fails to allocate the memory most of the times, but I wonder
 >> how reliable CMA is to be used in omapfb. I even reserved 64MB for CMA, but that made no
 >> difference. If CMA is disabled, the memory allocation still fails as obviously it is highly
 >> unlikely there will be such a big chunk of continuous free memory on RAM limited device like
 >> N900. 
 >> 
 >> One obvious solution is to just revert the removal of VRAM memory allocator, but that would
 >> mean I'll have to maintain a separate tree with all the implications that brings.
 >> 
 >> What would you advise on how to deal with the issue?
 >
 >I've not seen such errors, and I'm no expert on CMA. But I guess the
 >contiguous memory area can get fragmented enough no matter how hard one
 >tries to avoid it. The old VRAM system had the same issue, although it
 >was quite difficult to hit it.

I am using my n900 as a daily/only device since the beginning of 2010, never seen such an 
issue with video playback. And as a maintainer of one of the community supported kernels for
n900 (kernel-power) I've never had such an issue reported. On stock kernel and derivatives of
course. It seems VRAM allocator is virtually impossible to fail, while with CMA OMAPFB fails on
the first video after boot-up.

When saying you've not seen such an issue - did you actually test video playback, on what
device and using which distro? Did you use DSP accelerated decoding?

 >64MB does sound quite a lot, though. I wonder what other drivers are
 >using CMA, and how do they manage to allocate so much memory and
 >fragment it so badly... With double buffering, N900 should only need
 >something like 3MB for the frame buffer.

Sure, 64 MB is a lot, but I just wanted to see if that would make any difference. And for 720p 
3MB is not enough, something like 8MB is needed.

 >With a quick glance I didn't find any debugfs or such files to show
 >information about the CMA area. It'd be helpful to find out what's going
 >on there. Or maybe normal allocations are fragmenting the CMA area, but
 >for some reason they cannot be moved? Just guessing.

I was able to track down the failures to:
http://lxr.free-electrons.com/source/mm/migrate.c#L320

So it seems the problem is not that CMA gets fragmented, rather some pages cannot be migrated.
Unfortunately, my knowledge stops here. Someone from the mm guys should be involved in the
issue as well? I am starting to think there is some serious issue with CMA and/or mm I am
hitting on n900. As it is not the lack of free RAM that is the problem - 
"echo 3>/proc/sys/vm/drop_caches" results in more that 45MB of free RAM according to free.

 >There's also dma_declare_contiguous() that could be used to reserve
 >memory for omapfb. I have not used it, and I have no idea if it would
 >help here. But it's something you could try.

dma_declare_contiguous() won't help IMO, it just reserves CMA area that is private to the
driver, so it is used instead of the global CMA area, but I don't see how that would help in my
case.

Anyway, what about reverting VRAM allocator removal and migrating it to DMA API, the same way
DMA coherent pool is allocated and managed? Or simply revering VRAM allocator removal :) ?

Regards,
Ivo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
