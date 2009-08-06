Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 806936B004D
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 06:59:38 -0400 (EDT)
Date: Thu, 6 Aug 2009 18:59:32 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090806105932.GA1569@localhost>
References: <20090805024058.GA8886@localhost> <20090805155805.GC23385@random.random> <20090806100824.GO23385@random.random> <4A7AAE07.1010202@redhat.com> <20090806102057.GQ23385@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090806102057.GQ23385@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, Rik van Riel <riel@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 06, 2009 at 06:20:57PM +0800, Andrea Arcangeli wrote:
> On Thu, Aug 06, 2009 at 01:18:47PM +0300, Avi Kivity wrote:
> > Reasonable; if you depend on a hint from userspace, that hint can be 
> > used against you.
> 
> Correct, that is my whole point. Also we never know if applications
> are mmapping huge files with MAP_EXEC just because they might need to
> trampoline once in a while, or do some little JIT thing once in a
> while. Sometime people open files with O_RDWR even if they only need
> O_RDONLY. It's not a bug, but radically altering VM behavior because
> of a bitflag doesn't sound good to me.
> 
> I certainly see this tends to help as it will reactivate all
> .text. But this signals current VM behavior is not ok for small
> systems IMHO if such an hack is required. I prefer a dynamic algorithm
> that when active list grow too much stop reactivating pages and
> reduces the time for young bit activation only to the time the page
> sits on the inactive list. And if active list is small (like 128M
> system) we  fully trust young bit and if it set, we don't allow it to
> go in inactive list as it's quick enough to scan the whole active
> list, and young bit is meaningful there.
> 
> The issue I can see is with huge system and million pages in active
> list, by the time we can it all, too much time has passed and we don't
> get any meaningful information out of young bit. Things are radically
> different on all regular workstations, and frankly regular
> workstations are very important too, as I suspect there are more users
> running on <64G systems than on >64G systems.
> 
> > How about, for every N pages that you scan, evict at least 1 page, 
> > regardless of young bit status?  That limits overscanning to a N:1 
> > ratio.  With N=250 we'll spend at most 25 usec in order to locate one 
> > page to evict.
> 
> Yes exactly, something like that I think will be dynamic, and then we
> can drop VM_EXEC check and solve the issues on large systems while
> still not almost totally ignoring young bit on small systems.

This is a quick hack to materialize the idea. It remembers roughly
the last 32*SWAP_CLUSTER_MAX=1024 active (mapped) pages scanned,
and if _all of them_ are referenced, then the referenced bit is
probably meaningless and should not be taken seriously.

As a refinement, the static variable 'recent_all_referenced' could be
moved to struct zone or made a per-cpu variable.

Thanks,
Fengguang

---
 mm/vmscan.c |   28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

--- linux.orig/mm/vmscan.c	2009-08-06 18:31:20.000000000 +0800
+++ linux/mm/vmscan.c	2009-08-06 18:51:58.000000000 +0800
@@ -1239,6 +1239,9 @@ static void move_active_pages_to_lru(str
 static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 			struct scan_control *sc, int priority, int file)
 {
+	static unsigned int recent_all_referenced;
+	int all_referenced = 1;
+	int referenced_bit_ok;
 	unsigned long pgmoved;
 	unsigned long pgscanned;
 	unsigned long vm_flags;
@@ -1267,6 +1270,8 @@ static void shrink_active_list(unsigned 
 		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -pgmoved);
 	else
 		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -pgmoved);
+
+	referenced_bit_ok = !recent_all_referenced;
 	spin_unlock_irq(&zone->lru_lock);
 
 	pgmoved = 0;  /* count referenced (mapping) mapped pages */
@@ -1281,19 +1286,15 @@ static void shrink_active_list(unsigned 
 		}
 
 		/* page_referenced clears PageReferenced */
-		if (page_mapping_inuse(page) &&
-		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
-			pgmoved++;
-			/*
-			 * Identify referenced, file-backed active pages and
-			 * give them one more trip around the active list. So
-			 * that executable code get better chances to stay in
-			 * memory under moderate memory pressure.
-			 *
-			 * Also protect anon pages: swapping could be costly,
-			 * and KVM guest's referenced bit is helpful.
-			 */
-			if ((vm_flags & VM_EXEC) || PageAnon(page)) {
+		if (page_mapping_inuse(page)) {
+			referenced = page_referenced(page, 0, sc->mem_cgroup,
+						     &vm_flags);
+			if (referenced)
+				pgmoved++;
+			else
+				all_referenced = 0;
+
+			if (referenced && referenced_bit_ok) {
 				list_add(&page->lru, &l_active);
 				continue;
 			}
@@ -1319,6 +1320,7 @@ static void shrink_active_list(unsigned 
 	move_active_pages_to_lru(zone, &l_inactive,
 						LRU_BASE   + file * LRU_FILE);
 
+	recent_all_referenced = (recent_all_referenced << 1) | all_referenced;
 	spin_unlock_irq(&zone->lru_lock);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
