Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C28FA6B004D
	for <linux-mm@kvack.org>; Sat, 27 Jun 2009 08:56:22 -0400 (EDT)
Date: Sat, 27 Jun 2009 14:54:12 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Found the commit that causes the OOMs
Message-ID: <20090627125412.GA1667@cmpxchg.org>
References: <3901.1245848839@redhat.com> <20090624023251.GA16483@localhost> <20090620043303.GA19855@localhost> <32411.1245336412@redhat.com> <20090517022327.280096109@intel.com> <2015.1245341938@redhat.com> <20090618095729.d2f27896.akpm@linux-foundation.org> <7561.1245768237@redhat.com> <26537.1246086769@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <26537.1246086769@redhat.com>
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "riel@redhat.com" <riel@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Sat, Jun 27, 2009 at 08:12:49AM +0100, David Howells wrote:
> 
> I've managed to bisect things to find the commit that causes the OOMs.  It's:
> 
> 	commit 69c854817566db82c362797b4a6521d0b00fe1d8
> 	Author: MinChan Kim <minchan.kim@gmail.com>
> 	Date:   Tue Jun 16 15:32:44 2009 -0700
> 
> 	    vmscan: prevent shrinking of active anon lru list in case of no swap space V3
> 
> 	    shrink_zone() can deactivate active anon pages even if we don't have a
> 	    swap device.  Many embedded products don't have a swap device.  So the
> 	    deactivation of anon pages is unnecessary.
> 
> 	    This patch prevents unnecessary deactivation of anon lru pages.  But, it
> 	    don't prevent aging of anon pages to swap out.
> 
> 	    Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> 	    Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 	    Cc: Johannes Weiner <hannes@cmpxchg.org>
> 	    Acked-by: Rik van Riel <riel@redhat.com>
> 	    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 	    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> 
> This exhibits the problem.  The previous commit:
> 
> 	commit 35282a2de4e5e4e173ab61aa9d7015886021a821
> 	Author: Brice Goglin <Brice.Goglin@ens-lyon.org>
> 	Date:   Tue Jun 16 15:32:43 2009 -0700
> 
> 	    migration: only migrate_prep() once per move_pages()
> 
> survives 16 iterations of the LTP syscall testsuite without exhibiting the
> problem.

Here is the patch in question:

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7592d8e..879d034 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1570,7 +1570,7 @@ static void shrink_zone(int priority, struct zone *zone,
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (inactive_anon_is_low(zone, sc))
+	if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
 		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
 
 	throttle_vm_writeout(sc->gfp_mask);

When this was discussed, I think we missed that nr_swap_pages can
actually get zero on swap systems as well and this should have been
total_swap_pages - otherwise we also stop balancing the two anon lists
when swap is _full_ which was not the intention of this change at all.

[ There is another one hiding in shrink_zone() that does the same - it
was moved from get_scan_ratio() and is pretty old but we still kept
the inactive/active ratio halfway sane without MinChan's patch. ]

This is from your OOM-run dmesg, David:

  Adding 32k swap on swapfile22.  Priority:-21 extents:1 across:32k
  Adding 32k swap on swapfile23.  Priority:-22 extents:1 across:32k
  Adding 32k swap on swapfile24.  Priority:-23 extents:3 across:44k
  Adding 32k swap on swapfile25.  Priority:-24 extents:1 across:32k

So we actually have swap?  Or are those removed again before the OOM?

If not, I think we let the anon lists rot while swap is full and when
some swap space gets freed up and we should be able to evict anon
pages again, we don't find any candidates.  The following patch should
improve on that.

If it's not true for your particular situation, I think we still need
it for the scenario described above.

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: vmscan: keep balancing anon lists on swap-full conditions

Page reclaim doesn't scan and balance the anon LRU lists when
nr_swap_pages is zero to save the scan overhead for swapless systems.

Unfortunately, this variable can reach zero when all present swap
space is occupied as well and we don't want to stop balancing in that
case or we encounter an unreclaimable mess of anon lists when swap
space gets freed up and we are theoretically in the position to page
out again.

Use the total_swap_pages variable to have a better indicator when to
scan the anon LRU lists.

We still might have unbalanced anon lists when swap space is added
during run time but it is a a less dynamic change in state and we
still save the scanning overhead for CONFIG_SWAP systems that never
actually set up swap space.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5415526..5ea7fc3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1524,7 +1524,7 @@ static void shrink_zone(int priority, struct zone *zone,
 	int noswap = 0;
 
 	/* If we have no swap space, do not bother scanning anon pages. */
-	if (!sc->may_swap || (nr_swap_pages <= 0)) {
+	if (!sc->may_swap || (total_swap_pages <= 0)) {
 		noswap = 1;
 		percent[0] = 0;
 		percent[1] = 100;
@@ -1578,7 +1578,7 @@ static void shrink_zone(int priority, struct zone *zone,
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
+	if (inactive_anon_is_low(zone, sc) && total_swap_pages > 0)
 		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
 
 	throttle_vm_writeout(sc->gfp_mask);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
