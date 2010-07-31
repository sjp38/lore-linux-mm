Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5723C6B02B2
	for <linux-mm@kvack.org>; Sat, 31 Jul 2010 11:31:15 -0400 (EDT)
Date: Sat, 31 Jul 2010 16:30:31 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
Message-ID: <20100731153031.GE27064@n2100.arm.linux.org.uk>
References: <alpine.DEB.2.00.1007291038100.16510@router.home> <20100729161856.GA16420@barrios-desktop> <alpine.DEB.2.00.1007291132210.17734@router.home> <20100729170313.GB16420@barrios-desktop> <alpine.DEB.2.00.1007291222410.17734@router.home> <20100729183320.GH18923@n2100.arm.linux.org.uk> <1280436919.16922.11246.camel@nimitz> <20100729221426.GA28699@n2100.arm.linux.org.uk> <1280450338.16922.11735.camel@nimitz> <alpine.DEB.2.00.1007300745180.9007@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1007300745180.9007@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 30, 2010 at 07:48:00AM -0500, Christoph Lameter wrote:
> On Thu, 29 Jul 2010, Dave Hansen wrote:
> 
> > SPARSEMEM_EXTREME would be a bit different.  It's a 2-level lookup.
> > You'd have 16 "section roots", each representing 256MB of address space.
> > Each time we put memory under one of those roots, we'd fill in a
> > 512-section second-level table, which is designed to always fit into one
> > page.  If you start at 256MB, you won't waste all those entries.
> 
> That is certain a solution to the !MMU case and it would work very much
> like a page table. If you have an MMU then the vmemmap sparsemem
> configuration can take advantage of of that to avoid the 2 level lookup.

Looking at vmemmap sparsemem, we need to fix it as the page table
allocation in there bypasses the arch defined page table setup.

This causes a problem if you have 256-entry L2 page tables with no
room for the additional Linux VM PTE support bits (such as young,
dirty, etc), and need to glue two 256-entry L2 hardware page tables
plus a Linux version to store its accounting in each page.  See
arch/arm/include/asm/pgalloc.h.

So this causes a problem with vmemmap:

                pte_t entry;
                void *p = vmemmap_alloc_block_buf(PAGE_SIZE, node);
                if (!p)
                        return NULL;
                entry = pfn_pte(__pa(p) >> PAGE_SHIFT, PAGE_KERNEL);

Are you willing for this stuff to be replaced by architectures as
necessary?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
