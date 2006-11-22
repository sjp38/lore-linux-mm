Date: Tue, 21 Nov 2006 18:25:12 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/11] Add __GFP_MOVABLE flag and update callers
In-Reply-To: <Pine.LNX.4.64.0611212340480.11982@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0611211821030.588@schroedinger.engr.sgi.com>
References: <20061121225022.11710.72178.sendpatchset@skynet.skynet.ie>
 <20061121225042.11710.15200.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0611211529030.32283@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611212340480.11982@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Nov 2006, Mel Gorman wrote:

> On Tue, 21 Nov 2006, Christoph Lameter wrote:
> 
> > Are GFP_HIGHUSER allocations always movable? It would reduce the size of
> > the patch if this would be added to GFP_HIGHUSER.
> No, they aren't. Page tables allocated with HIGHPTE are currently not movable
> for example. A number of drivers (infiniband for example) also use
> __GFP_HIGHMEM that are not movable.

HIGHPTE with __GFP_USER set? This is a page table page right? 
pte_alloc_one does currently not set GFP_USER:

struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
{
        struct page *pte;

#ifdef CONFIG_HIGHPTE
        pte = 
alloc_pages(GFP_KERNEL|__GFP_HIGHMEM|__GFP_REPEAT|__GFP_ZERO, 0);
#else
        pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
#endif
        return pte;
}

How does infiniband insure that page migration does not move those pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
