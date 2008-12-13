Return-Path: <linux-kernel-owner+w=401wt.eu-S1755216AbYLMHER@vger.kernel.org>
Date: Sat, 13 Dec 2008 16:03:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH mmotm] memcg fix swap accounting leak (v2)
Message-Id: <20081213160310.e9501cd9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <46730.10.75.179.61.1229080565.squirrel@webmail-b.css.fujitsu.com>
References: <20081212172930.282caa38.kamezawa.hiroyu@jp.fujitsu.com>
	<20081212184341.b62903a7.nishimura@mxp.nes.nec.co.jp>
	<46730.10.75.179.61.1229080565.squirrel@webmail-b.css.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Updated explanation and fixed comment.
==

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Fix swapin charge operation of memcg.

Now, memcg has hooks to swap-out operation and checks SwapCache is really
unused or not. That check depends on contents of struct page.
I.e. If PageAnon(page) && page_mapped(page), the page is recoginized as
still-in-use.

Now, reuse_swap_page() calles delete_from_swap_cache() before establishment
of any rmap. Then, in followinig sequence

	(Page fault with WRITE)
	try_charge() (charge += PAGESIZE)
	commit_charge() (Check page_cgroup is used or not..)
	reuse_swap_page()
		-> delete_from_swapcache()
			-> mem_cgroup_uncharge_swapcache() (charge -= PAGESIZE)
	......
New charge is uncharged soon....
To avoid this,  move commit_charge() after page_mapcount() goes up to 1.
By this,

	try_charge()		(usage += PAGESIZE)
	reuse_swap_page()	(may usage -= PAGESIZE if PCG_USED is set)
	commit_charge()		(If page_cgroup is not marked as PCG_USED,
				 add new charge.)
Accounting will be correct.

Changelog (v1) -> (v2)
  - fixed comment.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/controllers/memcg_test.txt |   50 +++++++++++++++++++++++++++++--
 mm/memory.c                              |   11 +++---
 2 files changed, 54 insertions(+), 7 deletions(-)

Index: mmotm-2.6.28-Dec12/mm/memory.c
===================================================================
--- mmotm-2.6.28-Dec12.orig/mm/memory.c
+++ mmotm-2.6.28-Dec12/mm/memory.c
@@ -2428,22 +2428,23 @@ static int do_swap_page(struct mm_struct
 	 * while the page is counted on swap but not yet in mapcount i.e.
 	 * before page_add_anon_rmap() and swap_free(); try_to_free_swap()
 	 * must be called after the swap_free(), or it will never succeed.
-	 * And mem_cgroup_commit_charge_swapin(), which uses the swp_entry
-	 * in page->private, must be called before reuse_swap_page(),
-	 * which may delete_from_swap_cache().
+	 * Because delete_from_swap_page() may be called by reuse_swap_page(),
+	 * mem_cgroup_commit_charge_swapin() may not be able to find swp_entry
+	 * in page->private. In this case, a record in swap_cgroup  is silently
+	 * discarded at swap_free().
 	 */
 
-	mem_cgroup_commit_charge_swapin(page, ptr);
 	inc_mm_counter(mm, anon_rss);
 	pte = mk_pte(page, vma->vm_page_prot);
 	if (write_access && reuse_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
 		write_access = 0;
 	}
-
 	flush_icache_page(vma, page);
 	set_pte_at(mm, address, page_table, pte);
 	page_add_anon_rmap(page, vma, address);
+	/* It's better to call commit-charge after rmap is established */
+	mem_cgroup_commit_charge_swapin(page, ptr);
 
 	swap_free(entry);
 	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
Index: mmotm-2.6.28-Dec12/Documentation/controllers/memcg_test.txt
===================================================================
--- mmotm-2.6.28-Dec12.orig/Documentation/controllers/memcg_test.txt
+++ mmotm-2.6.28-Dec12/Documentation/controllers/memcg_test.txt
@@ -1,6 +1,6 @@
 Memory Resource Controller(Memcg)  Implementation Memo.
-Last Updated: 2008/12/10
-Base Kernel Version: based on 2.6.28-rc7-mm.
+Last Updated: 2008/12/13
+Base Kernel Version: based on 2.6.28-rc8-mm.
 
 Because VM is getting complex (one of reasons is memcg...), memcg's behavior
 is complex. This is a document for memcg's internal behavior.
@@ -115,6 +115,52 @@ Under below explanation, we assume CONFI
 	(But racy state between (a) and (b) exists. We do check it.)
 	At charging, a charge recorded in swap_cgroup is moved to page_cgroup.
 
+	In case (a), reuse_swap_page() may call delete_from_swap_cache() if
+	the page can drop swp_entry and be reused for "WRITE".
+	Note: If the page may be accounted before (A), if it isn't kicked out
+	      to disk before page fault.
+
+	case A) the page is not accounted as SwapCache and SwapCache is deleted
+		by reuse_swap_page().
+		1. try_charge_swapin() is called and
+			- charge_for_memory +=1.
+			- charge_for_memsw  +=1.
+		2. reuse_swap_page -> delete_from_swap_cache() is called.
+			because the page is not accounted as SwapCache,
+			no changes in accounting.
+		3. commit_charge_swapin() finds PCG_USED bit is not set and
+		   set PCG_USED bit.
+		   Because page->private is empty by 2. no changes in charge.
+		4. swap_free(entry) is called.
+			- charge_for_memsw -= 1.
+
+		Finally, charge_for_memory +=1, charge_for_memsw = +-0.
+
+	case B) the page is accounted as SwapCache and SwapCache is deleted
+		by reuse_swap_page.
+		1. try_charge_swapin() is called.
+			- charge_for_memory += 1.
+			- charge_for_memsw += 1.
+		2. reuse_swap_page -> delete_from_swap_cache() is called.
+			PCG_USED bit is found and cleared.
+			- charge_for_memory -= 1. (swap_cgroup is recorded.)
+		3. commit_charge_swapin() finds PCG_USED bit is not set.
+		4. swap_free(entry) is called and
+			- charge_for_memsw -= 1.
+
+		Finally, charge_for_memory = +-0, charge_for_memsw = +-0.
+
+	case C) the page is not accounted as SwapCache and reuse_swap_page
+		doesn't call delete_from_swap_cache()
+		1. try_charge_swapin() is called.
+			- charge_for_memory += 1.
+			- charge_for_memsw += 1.
+		2. commit_charge_swapin() finds PCG_USED bit is not set
+		   and finds swap_cgroup records this entry.
+			- charge_for_memsw -= 1.
+
+		Finally, charge_for_memory +=1, charge_for_memsw = +-0
+
 	4.2 Swap-out.
 	At swap-out, typical state transition is below.
 
