Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6AF026B01F3
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 09:22:18 -0400 (EDT)
Date: Wed, 28 Apr 2010 02:59:37 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/3] mm,migration: During fork(), wait for migration to
 end if migration PTE is encountered
Message-ID: <20100428005937.GI510@random.random>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
 <1272403852-10479-2-git-send-email-mel@csn.ul.ie>
 <20100427222245.GE8860@random.random>
 <20100428085203.4336b761.kamezawa.hiroyu@jp.fujitsu.com>
 <20100428001821.GF510@random.random>
 <20100428001911.GG510@random.random>
 <20100428092802.816e2716.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100428092802.816e2716.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 28, 2010 at 09:28:02AM +0900, KAMEZAWA Hiroyuki wrote:
> why we have to remove migration_pte by rmap_walk() which doesnt' exist ?

I already thought this for split_huge_page and because split_huge_page
that already waits inside copy_huge_pmd if there's any
pmd_trans_splitting bit set, isn't removing the requirement for
list_add_tail in anon_vma_[chain_]link this patch also isn't removing
it.

But it's more complex than my prev explanation now that I think about
it more so no wonder it's not clear why yet (my fault).

So the thing is, if you patch it this way, the second rmap_walk run by
remove_migration_ptes will be safe even if the ordering is inverted,
but then the first rmap_walk that establishes the migration entry, will
still break if the rmap walk scans the child before the parent.

The only objective of the patch is to remove the list_add_tail
requirement but I'll show that it's still required by the first
rmap_walk in try_to_unmap below:

CPU A	    		  	      	CPU B
				      	fork
try_to_unmap
try to set migration entry in child (null pte still, nothing done)
					copy pte and map page in child pte (no
				      	migration entry set on child)
set migration entry in parent

parent ends up with migration entry but child not, breaking migration
in another way. so even with the patch, the only way to be safe is
that rmap_walk always scans the parent _first_.

So this patch is a noop from every angle, and it just moves the
ordering requirement from the remove_migration_ptes to try_to_unmap,
but it doesn't remove it as far as I can tell. So it only slowdown
fork a bit for no good.

split_huge_page is about the same. If the ordering is inverted,
split_huge_page could set a splitting pmd in the parent only, like the
above try_to_unmap would set the migration pte in the parent only.

> Anyway, I agree there are no oops. But there are risks because migration is
> a feature which people don't tend to take care of (as memcg ;)
> I like conservative approach for this kind of features.

Don't worry, migrate will run 24/7 the moment THP is in ;).

What migration really changed (and it's beneficial so split_huge_page
isn't introducing new requirement) is that rmap has to be exact at all
times, if it was only swap using it, nothing would happen because of
the vma_adjust/move_page_tables/vma_adjust not being in an atomic
section against the rmap_walk (the anon_vma lock of the process stack
vma is enough to make it atomic against rmap_walk luckily).

On a side note: split_huge_page isn't using migration because:

1) migrate.c can't deal with pmd or huge pmd (or compound pages at all)
2) we need it to split in place for gup (used by futex, o_direct,
   vmware workstation etc... and they definitely can't be slowed down
   by having to split the hugepage before gup returns, the only one
   that wouldn't be able to prevent gup splitting the hugepage without
   causing issues to split_huge_page is kvm thanks to the mmu
   notifier, but to do so it'd require to introduce
   a gup_fast variant that wouldn't be increasing the page count, but
   because of o_direct and friends we can't avoid to deal with staying
   in place in split_huge_page), while migrate
   by definition is about migrating something from here to there,
   not doing anything in place
3) we need to convert page structures from compound to not compound in
   place (beisdes the fact the physical memory is in place too),
   inside of the two rmap walks which is definitely specialized
   enough not to fit into the migrate framework

But memory compaction is the definitive user of migration code, as
it's only moving not-yet-huge pages from here to there, and THP
will run memory compaction every time we miss a hugepage in the buddy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
