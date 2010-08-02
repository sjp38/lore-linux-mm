Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 60FC16B02F4
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 11:48:51 -0400 (EDT)
Date: Mon, 2 Aug 2010 10:48:46 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
In-Reply-To: <20100731153031.GE27064@n2100.arm.linux.org.uk>
Message-ID: <alpine.DEB.2.00.1008021044380.18490@router.home>
References: <alpine.DEB.2.00.1007291038100.16510@router.home> <20100729161856.GA16420@barrios-desktop> <alpine.DEB.2.00.1007291132210.17734@router.home> <20100729170313.GB16420@barrios-desktop> <alpine.DEB.2.00.1007291222410.17734@router.home>
 <20100729183320.GH18923@n2100.arm.linux.org.uk> <1280436919.16922.11246.camel@nimitz> <20100729221426.GA28699@n2100.arm.linux.org.uk> <1280450338.16922.11735.camel@nimitz> <alpine.DEB.2.00.1007300745180.9007@router.home>
 <20100731153031.GE27064@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Sat, 31 Jul 2010, Russell King - ARM Linux wrote:

> Looking at vmemmap sparsemem, we need to fix it as the page table
> allocation in there bypasses the arch defined page table setup.

You are required to define your own vmemmap_populate function. In that you
can call some of the provided functions or use your own.

> This causes a problem if you have 256-entry L2 page tables with no
> room for the additional Linux VM PTE support bits (such as young,
> dirty, etc), and need to glue two 256-entry L2 hardware page tables
> plus a Linux version to store its accounting in each page.  See
> arch/arm/include/asm/pgalloc.h.
>
> So this causes a problem with vmemmap:
>
>                 pte_t entry;
>                 void *p = vmemmap_alloc_block_buf(PAGE_SIZE, node);
>                 if (!p)
>                         return NULL;
>                 entry = pfn_pte(__pa(p) >> PAGE_SHIFT, PAGE_KERNEL);
>
> Are you willing for this stuff to be replaced by architectures as
> necessary?

Sure its designed that way. If we missed anything we'd surely add it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
