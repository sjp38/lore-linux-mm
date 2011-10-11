Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B26A16B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 03:17:54 -0400 (EDT)
Received: from euspt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LSW00MFU49RG9@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 11 Oct 2011 08:17:51 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LSW0018L49QKH@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 11 Oct 2011 08:17:51 +0100 (BST)
Date: Tue, 11 Oct 2011 09:17:40 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [Linaro-mm-sig] [PATCHv16 0/9] Contiguous Memory Allocator
In-reply-to: <4E92E003.4060901@stericsson.com>
Message-id: <00b001cc87e5$dc818cc0$9584a640$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
 <4E92E003.4060901@stericsson.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Maxime Coquelin' <maxime.coquelin-nonst@stericsson.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Daniel Walker' <dwalker@codeaurora.org>, 'Russell King' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Michal Nazarewicz' <mina86@mina86.com>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, benjamin.gaignard@linaro.org, 'frq09524' <ludovic.barre@stericsson.com>, vincent.guittot@linaro.org


Hello,

On Monday, October 10, 2011 2:08 PM Maxime Coquelin wrote:

> On 10/06/2011 03:54 PM, Marek Szyprowski wrote:
> > Welcome everyone again,
> >
> > Once again I decided to post an updated version of the Contiguous Memory
> > Allocator patches.
> >
> > This version provides mainly a bugfix for a very rare issue that might
> > have changed migration type of the CMA page blocks resulting in dropping
> > CMA features from the affected page block and causing memory allocation
> > to fail. Also the issue reported by Dave Hansen has been fixed.
> >
> > This version also introduces basic support for x86 architecture, what
> > allows wide testing on KVM/QEMU emulators and all common x86 boxes. I
> > hope this will result in wider testing, comments and easier merging to
> > mainline.
> >
> > I've also dropped an examplary patch for s5p-fimc platform device
> > private memory declaration and added the one from real life. CMA device
> > private memory regions are defined for s5p-mfc device to let it allocate
> > buffers from two memory banks.
> >
> > ARM integration code has not been changed since last version, it
> > provides implementation of all the ideas that has been discussed during
> 
> Hello Marek,
> 
>      We are currently testing CMA (v16) on Snowball platform.
>      This feature is very promising, thanks for pushing it!
> 
>      During our stress tests, we encountered some problems :
> 
>      1) Contiguous allocation lockup:
>          When system RAM is full of Anon pages, if we try to allocate a
> contiguous buffer greater than the min_free value, we face a
> dma_alloc_from_contiguous lockup.
>          The expected result would be dma_alloc_from_contiguous() to fail.
>          The problem is reproduced systematically on our side.

Thanks for the report. Do you use Android's lowmemorykiller? I haven't 
tested CMA on Android kernel yet. I have no idea how it will interfere 
with Android patches.

> 
>      2) Contiguous allocation fail:
>          We have developed a small driver and a shell script to
> allocate/release contiguous buffers.
>          Sometimes, dma_alloc_from_contiguous() fails to allocate the
> contiguous buffer (about once every 30 runs).
>          We have 270MB Memory passed to the kernel in our configuration,
> and the CMA pool is 90MB large.
>          In this setup, the overall memory is either free or full of
> reclaimable pages.

Yeah. We also did such stress tests recently and faced this issue. I've
spent some time investigating it but I have no solution yet. 

The problem is caused by a page, which is put in the CMA area. This page 
is movable, but it's address space provides no 'migratepage' method. In
such case mm subsystem uses fallback_migrate_page() function. Sadly this
function only returns -EAGAIN. The migration loops a few times over it
and fails causing the fail in the allocation procedure.

We are investing now which kernel code created/allocated such problematic
pages and how to add real migration support for them.

>      For now, we didn't had time to investigate further theses problems.
>      Have you already faced this kind of issues?
>      Could someone testing CMA on other boards confirm/infirm theses
> problems?

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
