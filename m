Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 089206B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 03:56:35 -0400 (EDT)
Date: Fri, 28 Sep 2012 08:56:28 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: CMA broken in next-20120926
Message-ID: <20120928075628.GJ3429@suse.de>
References: <20120927112911.GA25959@avionic-0098.mockup.avionic-design.de>
 <20120927151159.4427fc8f.akpm@linux-foundation.org>
 <20120928054330.GA27594@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120928054330.GA27594@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Thierry Reding <thierry.reding@avionic-design.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Peter Ujfalusi <peter.ujfalusi@ti.com>

On Fri, Sep 28, 2012 at 02:43:30PM +0900, Minchan Kim wrote:
> On Thu, Sep 27, 2012 at 03:11:59PM -0700, Andrew Morton wrote:
> > On Thu, 27 Sep 2012 13:29:11 +0200
> > Thierry Reding <thierry.reding@avionic-design.de> wrote:
> > 
> > > Hi Marek,
> > > 
> > > any idea why CMA might be broken in next-20120926. I see that there
> > > haven't been any major changes to CMA itself, but there's been quite a
> > > bit of restructuring of various memory allocation bits lately. I wasn't
> > > able to track the problem down, though.
> > > 
> > > What I see is this during boot (with CMA_DEBUG enabled):
> > > 
> > > [    0.266904] cma: dma_alloc_from_contiguous(cma db474f80, count 64, align 6)
> > > [    0.284469] cma: dma_alloc_from_contiguous(): memory range at c09d7000 is busy, retrying
> > > [    0.293648] cma: dma_alloc_from_contiguous(): memory range at c09d7800 is busy, retrying
> > > ...
> > > [    2.648619] DMA: failed to allocate 256 KiB pool for atomic coherent allocation
> > > ...
> > > [    4.196193] WARNING: at /home/thierry.reding/src/kernel/linux-ipmp.git/arch/arm/mm/dma-mapping.c:485 __alloc_from_pool+0xdc/0x110()
> > > [    4.207988] coherent pool not initialised!
> > > 
> > > So the pool isn't getting initialized properly because CMA can't get at
> > > the memory. Do you have any hints as to what might be going on? If it's
> > > any help, I started seeing this with next-20120926 and it is in today's
> > > next as well.
> > > 
> > 
> > Bart and Minchan have made recent changes to CMA.  Let us cc them.
> 
> Hi all,
> 
> I have no time now so I look over the problem during short time
> so I mighte be wrong. Even I should leave the office soon and
> Korea will have long vacation from now on so I will be off by next week.
> So it's hard to reach on me.
> 
> I hope this patch fixes the bug. If this patch fixes the problem
> but has some problem about description or someone has better idea,
> feel free to modify and resend to akpm, Please.
> 
> Thierry, Could you test below patch?
> 
> From 24a547855fa2bd4212a779cc73997837148310b3 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Fri, 28 Sep 2012 14:28:32 +0900
> Subject: [PATCH] revert mm: compaction: iron out isolate_freepages_block()
>  and isolate_freepages_range()
> 
> [1] made bug on CMA.
> The nr_scanned should be never equal to total_isolated for successful CMA.
> This patch reverts part of the patch.
> 

Why should nr_scanned never be equal to total_isolated for CMA?

Reverting the patch reintroduces Andrew's complaint that this function
was "straggly" and getting a bit out of control so I'd much prefer to
understand why this situation is not true and fix that.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
