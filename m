Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A33566B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 06:50:38 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from euspt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LSW009NBE4AW630@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 11 Oct 2011 11:50:34 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LSW0049CE49U6@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 11 Oct 2011 11:50:34 +0100 (BST)
Date: Tue, 11 Oct 2011 12:50:23 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [Linaro-mm-sig] [PATCHv16 0/9] Contiguous Memory Allocator
In-reply-to: <4E93F088.60006@stericsson.com>
Message-id: <00b301cc8803$93b5b3e0$bb211ba0$%szyprowski@samsung.com>
Content-language: pl
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
 <4E92E003.4060901@stericsson.com>
 <00b001cc87e5$dc818cc0$9584a640$%szyprowski@samsung.com>
 <4E93F088.60006@stericsson.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Maxime Coquelin' <maxime.coquelin-nonst@stericsson.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Daniel Walker' <dwalker@codeaurora.org>, 'Russell King' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Michal Nazarewicz' <mina86@mina86.com>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, benjamin.gaignard@linaro.org, 'Ludovic BARRE' <ludovic.barre@stericsson.com>, vincent.guittot@linaro.org

Hello,

On Tuesday, October 11, 2011 9:30 AM Maxime Coquelin wrote:

> On 10/11/2011 09:17 AM, Marek Szyprowski wrote:
> > On Monday, October 10, 2011 2:08 PM Maxime Coquelin wrote:
> >
> >       During our stress tests, we encountered some problems :
> >
> >       1) Contiguous allocation lockup:
> >           When system RAM is full of Anon pages, if we try to allocate a
> > contiguous buffer greater than the min_free value, we face a
> > dma_alloc_from_contiguous lockup.
> >           The expected result would be dma_alloc_from_contiguous() to fail.
> >           The problem is reproduced systematically on our side.
> > Thanks for the report. Do you use Android's lowmemorykiller? I haven't
> > tested CMA on Android kernel yet. I have no idea how it will interfere
> > with Android patches.
> >
> 
> The software used for this test (v16) is a generic 3.0 Kernel and a
> minimal filesystem using Busybox.

I'm really surprised. Could you elaborate a bit how to trigger this issue?
I've did several tests and I never get a lockup. Allocation failed from time
to time though.

> With v15 patchset, I also tested it with Android.
> IIRC, sometimes the lowmemorykiller succeed to get free space and the
> contiguous allocation succeed, sometimes we faced  the lockup.
> 
> >>       2) Contiguous allocation fail:
> >>           We have developed a small driver and a shell script to
> >> allocate/release contiguous buffers.
> >>           Sometimes, dma_alloc_from_contiguous() fails to allocate the
> >> contiguous buffer (about once every 30 runs).
> >>           We have 270MB Memory passed to the kernel in our configuration,
> >> and the CMA pool is 90MB large.
> >>           In this setup, the overall memory is either free or full of
> >> reclaimable pages.
> > Yeah. We also did such stress tests recently and faced this issue. I've
> > spent some time investigating it but I have no solution yet.
> >
> > The problem is caused by a page, which is put in the CMA area. This page
> > is movable, but it's address space provides no 'migratepage' method. In
> > such case mm subsystem uses fallback_migrate_page() function. Sadly this
> > function only returns -EAGAIN. The migration loops a few times over it
> > and fails causing the fail in the allocation procedure.
> >
> > We are investing now which kernel code created/allocated such problematic

s/investing/investigating

> > pages and how to add real migration support for them.
> >
> 
> Ok, thanks for pointing this out.

We found this issue very recently. I'm still surprised that we did not notice 
it during system testing.

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
