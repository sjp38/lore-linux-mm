Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 401F96B0222
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 06:50:56 -0400 (EDT)
Date: Sat, 24 Apr 2010 11:50:33 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of
	PageSwapCache  pages
Message-ID: <20100424105033.GE14351@csn.ul.ie>
References: <20100422184621.0aaaeb5f.kamezawa.hiroyu@jp.fujitsu.com> <x2l28c262361004220313q76752366l929a8959cd6d6862@mail.gmail.com> <20100422193106.9ffad4ec.kamezawa.hiroyu@jp.fujitsu.com> <20100422195153.d91c1c9e.kamezawa.hiroyu@jp.fujitsu.com> <1271946226.2100.211.camel@barrios-desktop> <1271947206.2100.216.camel@barrios-desktop> <20100422154443.GD30306@csn.ul.ie> <20100423183135.GT32034@random.random> <20100423192311.GC14351@csn.ul.ie> <20100423193948.GU32034@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100423193948.GU32034@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 23, 2010 at 09:39:48PM +0200, Andrea Arcangeli wrote:
> On Fri, Apr 23, 2010 at 08:23:12PM +0100, Mel Gorman wrote:
> > On Fri, Apr 23, 2010 at 08:31:35PM +0200, Andrea Arcangeli wrote:
> > > Hi Mel,
> > > 
> > > On Thu, Apr 22, 2010 at 04:44:43PM +0100, Mel Gorman wrote:
> > > > heh, I thought of a similar approach at the same time as you but missed
> > > > this mail until later. However, with this approach I suspect there is a
> > > > possibility that two walkers of the same anon_vma list could livelock if
> > > > two locks on the list are held at the same time. Am still thinking of
> > > > how it could be resolved without introducing new locking.
> > > 
> > > Trying to understand this issue and I've some questions. This
> > > vma_adjust and lock inversion troubles with the anon-vma lock in
> > > rmap_walk are a new issue introduced by the recent anon-vma changes,
> > > right?
> > > 
> > 
> > In a manner of speaking. There was no locking going on but prior to the
> > anon_vma changes, there would have been only one anon_vma lock and the
> > fix would be easier - just take the lock on anon_vma->lock while the
> > VMAs are being updated.
> 
> So it was very much a bug before too and we could miss to find some
> pte mapping the page if vm_start was adjusted?
> 

I thought it was but I was looking at an rc kernel instead of 2.6.33.
This looked as if it was safe but it's not any more with the new
anon_vma scheme.

> Also note, expand_downwards also moves vm_start with only the
> anon_vma->lock as it has to serialize against other expand_downwards
> and the rmap_walk. But expand_downwards takes the lock and it was safe
> before.
> 
> Also for swapping even if things screwup it's no big deal, because it
> will just skip, but migration has to find all ptes in
> remove_migration_ptes and try_to_unmap also has to unmap everything.
> 

It either has to find them all or it has to be capable of a
lazy-cleanup. I had lazy cleanup patch but it was dropped because we
felt it should have been possible to properly lock this. I'm beginning
to think it can't because there appears to be a few cases where the VM
doesn't care if it doesn't find all the mappings.

> In the split_huge_page case even the ordering at which newly allocated
> vmas for the child are queued is critical, they've to be put at the
> end of the list to be safe (otherwise do_wp_huge_page may not wait and
> we may fail to mark the huge_pmd in the child as pmd_splitting).
> 

There might also be a locking snarl there as well then. I confess that
the details of transparent hugepage support have fallen back out of my
head within the last two weeks.

> > > About swapcache, try_to_unmap just nuke the mappings, establish the
> > > swap entry in the pte (not migration entry), and then there's no need
> > > to call remove_migration_ptes.
> > 
> > That would be an alternative for swapcache but it's not necessarily
> > where the problem is.s
> 
> Hmm try_to_unmap already nukes all swap entries without creating any
> migration pte for swapcache as far as I can tell.
> 

When a mapped swapcache is unmapped, a migration PTE is put in place. If
that was not the case, we wouldn't be hitting the bug in the first
place.

> > > So it just need to skip it for
> > > swapcache. page_mapped must return zero after try_to_unmap returns
> > > before we're allowed to migrate (plus the page count must be just 1
> > > and not 2 or more for gup users!).
> > > 
> > > I don't get what's the problem about swapcache and the races connected
> > > to it, the moment I hear migration PTE in context of swapcache
> > > migration I'm confused because there's no migration PTE for swapcache.
> > > 
> > 
> > That was a mistake on my part. The race appears to be between vma_adjust
> > changing the details of the VMA while rmap_walk is going on. It mistakenly
> > believes the vma no longer spans the address, gets -EFAULT from vma_address
> > and doesn't clean up the migration PTE. This is later encountered but the
> > page lock is no longer held and it bugs. An alternative would be to clean
> > up the migration PTE of unlocked pages on the assumption it was due to this
> > race but it's a bit sloppier.
> 
> Agreed, it's sure better to close the race... the other may have even
> more implications.

True, which is why I'm not keen on lazy cleanup.

> It's good to retain the invariant that when a
> migration PTE exists the page also still exists and it's locked
> (locked really mostly matters for pagecache I guess, but it's ok).
> 
> > > The new page will have no mappings either, it just needs to be part of
> > > the swapcache with the same page->index = swapentry, indexed in the
> > > radix tree with that page->index, and paga->mapping pointing to
> > > swapcache. Then new page faults will bring it in the pageatables. The
> > > lookup_swap_cache has to be serialized against some lock, it should be
> > > the radix tree lock? So the migration has to happen with that lock
> > > hold no?
> > 
> > Think migrate_page_move_mapping() is what you're looking for? It takes
> > the mapping tree lock.
> 
> Yep exactly!
> 
> > >We can't just migrate swapcache without stopping swapcache
> > > radix tree lookups no? I didn't digest the full migrate.c yet and I
> > > don't see where it happens. Freeing the swapcache while simpler and
> > > safer, would be quite bad as it'd create I/O for potentially hot-ram.
> > > 
> > > About the refcounting of anon-vma in migrate.c I think it'd be much
> > > simpler if zap_page_range and folks would just wait (like they do if
> > > they find a pmd_trans_huge && pmd_trans_splitting pmd), there would be
> > > no need of refcounting the anon-vma that way.
> > > 
> > 
> > I'm not getting what you're suggesting here. The refcount is to make
> > sure the anon_vma doesn't go away after the page mapcount reaches zero.
> > What are we waiting for?
> 
> Causing zap_page-range to Wait the end of migration when it encounters
> migration ptes instead of skipping them all together by only releasing
> the rss and doing nothing about them. If the pte can't go away, so the
> mm so the vma and so the anon-vma. I'm not suggesting to change that,
> but I guess that's the way I would have done if I would have
> implemented it, it'd avoid refcounting.

Maybe.

> Just like I did in
> split_huge_page I count the number of pmd marked splitting, and I
> compare it to the number of pmds that are converted from huge to
> not-huge and I compared that again with the page_mapcount. If the
> three numbers aren't equal I bug. It simply can't go wrong unnoticed
> that way. I only can do that because I stop the zapping.
> 

That would be another way of doing it all right. Count how many
migration ptes we created, pass that to rmap_walk. If they don't match,
assume a race and do it again before the page is unlocked.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
