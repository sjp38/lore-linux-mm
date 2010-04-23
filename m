Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 121EC6B0203
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 15:23:33 -0400 (EDT)
Date: Fri, 23 Apr 2010 20:23:12 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of
	PageSwapCache  pages
Message-ID: <20100423192311.GC14351@csn.ul.ie>
References: <alpine.DEB.2.00.1004211038020.4959@router.home> <20100422092819.GR30306@csn.ul.ie> <20100422184621.0aaaeb5f.kamezawa.hiroyu@jp.fujitsu.com> <x2l28c262361004220313q76752366l929a8959cd6d6862@mail.gmail.com> <20100422193106.9ffad4ec.kamezawa.hiroyu@jp.fujitsu.com> <20100422195153.d91c1c9e.kamezawa.hiroyu@jp.fujitsu.com> <1271946226.2100.211.camel@barrios-desktop> <1271947206.2100.216.camel@barrios-desktop> <20100422154443.GD30306@csn.ul.ie> <20100423183135.GT32034@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100423183135.GT32034@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 23, 2010 at 08:31:35PM +0200, Andrea Arcangeli wrote:
> Hi Mel,
> 
> On Thu, Apr 22, 2010 at 04:44:43PM +0100, Mel Gorman wrote:
> > heh, I thought of a similar approach at the same time as you but missed
> > this mail until later. However, with this approach I suspect there is a
> > possibility that two walkers of the same anon_vma list could livelock if
> > two locks on the list are held at the same time. Am still thinking of
> > how it could be resolved without introducing new locking.
> 
> Trying to understand this issue and I've some questions. This
> vma_adjust and lock inversion troubles with the anon-vma lock in
> rmap_walk are a new issue introduced by the recent anon-vma changes,
> right?
> 

In a manner of speaking. There was no locking going on but prior to the
anon_vma changes, there would have been only one anon_vma lock and the
fix would be easier - just take the lock on anon_vma->lock while the
VMAs are being updated.

> About swapcache, try_to_unmap just nuke the mappings, establish the
> swap entry in the pte (not migration entry), and then there's no need
> to call remove_migration_ptes.

That would be an alternative for swapcache but it's not necessarily
where the problem is.

> So it just need to skip it for
> swapcache. page_mapped must return zero after try_to_unmap returns
> before we're allowed to migrate (plus the page count must be just 1
> and not 2 or more for gup users!).
> 
> I don't get what's the problem about swapcache and the races connected
> to it, the moment I hear migration PTE in context of swapcache
> migration I'm confused because there's no migration PTE for swapcache.
> 

That was a mistake on my part. The race appears to be between vma_adjust
changing the details of the VMA while rmap_walk is going on. It mistakenly
believes the vma no longer spans the address, gets -EFAULT from vma_address
and doesn't clean up the migration PTE. This is later encountered but the
page lock is no longer held and it bugs. An alternative would be to clean
up the migration PTE of unlocked pages on the assumption it was due to this
race but it's a bit sloppier.

> The new page will have no mappings either, it just needs to be part of
> the swapcache with the same page->index = swapentry, indexed in the
> radix tree with that page->index, and paga->mapping pointing to
> swapcache. Then new page faults will bring it in the pageatables. The
> lookup_swap_cache has to be serialized against some lock, it should be
> the radix tree lock? So the migration has to happen with that lock
> hold no?

Think migrate_page_move_mapping() is what you're looking for? It takes
the mapping tree lock.

>We can't just migrate swapcache without stopping swapcache
> radix tree lookups no? I didn't digest the full migrate.c yet and I
> don't see where it happens. Freeing the swapcache while simpler and
> safer, would be quite bad as it'd create I/O for potentially hot-ram.
> 
> About the refcounting of anon-vma in migrate.c I think it'd be much
> simpler if zap_page_range and folks would just wait (like they do if
> they find a pmd_trans_huge && pmd_trans_splitting pmd), there would be
> no need of refcounting the anon-vma that way.
> 

I'm not getting what you're suggesting here. The refcount is to make
sure the anon_vma doesn't go away after the page mapcount reaches zero.
What are we waiting for?

> I assume whatever is added to rmap_walk I also have to add to
> split_huge_page later when switching to mainline anon-vma code (for
> now I stick to 2.6.32 anon-vma code to avoid debugging anon-vma-chain,
> memory compaction, swapcache migration and transparent hugepage at the
> same time, which becomes a little beyond feasibility).
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
