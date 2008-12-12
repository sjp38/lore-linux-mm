Return-Path: <linux-kernel-owner+w=401wt.eu-S1758038AbYLLIaf@vger.kernel.org>
Date: Fri, 12 Dec 2008 17:29:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH mmotm] memcg fix swap accounting leak
Message-Id: <20081212172930.282caa38.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Fix swap-page-fault charge leak of memcg.

Now, memcg has hooks to swap-out operation and checks SwapCache is really
unused or not. That check depends on contents of struct page.
I.e. If PageAnon(page) && page_mapped(page), the page is recoginized as
still-in-use.

Now, reuse_swap_page() calles delete_from_swap_cache() before establishment
of any rmap. Then, in followinig sequence

	(Page fault with WRITE)
	Assume the page is SwapCache "on memory (still charged)"
	try_charge() (charge += PAGESIZE)
	commit_charge()
	   => (Check page_cgroup and found PCG_USED bit, charge-=PAGE_SIZE
	       because it seems already charged.)
	reuse_swap_page()
		-> delete_from_swapcache()
			-> mem_cgroup_uncharge_swapcache() (charge -= PAGESIZE)
	......

too much uncharge.....

To avoid this,  move commit_charge() after page_mapcount() goes up to 1.
By this,
        Assume the page is SwapCache "on memory"
	try_charge()		(charge += PAGESIZE)
	reuse_swap_page()	(may charge -= PAGESIZE if PCG_USED is set)
	commit_charge()		(Ony if page_cgroup is marked as PCG_USED,
				 charge -= PAGESIZE)
Accounting will be correct.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memory.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: mmotm-2.6.28-Dec11/mm/memory.c
===================================================================
--- mmotm-2.6.28-Dec11.orig/mm/memory.c
+++ mmotm-2.6.28-Dec11/mm/memory.c
@@ -2433,17 +2433,17 @@ static int do_swap_page(struct mm_struct
 	 * which may delete_from_swap_cache().
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
