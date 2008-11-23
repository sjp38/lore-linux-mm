Date: Sun, 23 Nov 2008 22:11:07 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH] memcg: memswap controller core swapcache fixes
In-Reply-To: <Pine.LNX.4.64.0811232156120.4142@blonde.site>
Message-ID: <Pine.LNX.4.64.0811232208380.6437@blonde.site>
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
 <Pine.LNX.4.64.0811232156120.4142@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Two SwapCache bug fixes to mmotm's memcg-memswap-controller-core.patch:

One bug is independent of my current changes: there is no guarantee that
the page passed to mem_cgroup_try_charge_swapin() is still in SwapCache.

The other bug is a consequence of my changes, but the fix is okay without
them: mem_cgroup_commit_charge_swapin() expects swp_entry in page->private,
but now reuse_swap_page() (formerly can_share_swap_page()) might already
have done delete_from_swap_cache(): move commit_charge_swapin() earlier.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/memcontrol.c |    8 ++++++++
 mm/memory.c     |   15 +++++++++++++--
 2 files changed, 21 insertions(+), 2 deletions(-)

--- mmotm.orig/mm/memcontrol.c	2008-11-23 21:03:48.000000000 +0000
+++ mmotm/mm/memcontrol.c	2008-11-23 21:06:12.000000000 +0000
@@ -847,6 +847,14 @@ int mem_cgroup_try_charge_swapin(struct 
 	if (!do_swap_account)
 		goto charge_cur_mm;
 
+	/*
+	 * A racing thread's fault, or swapoff, may have already updated
+	 * the pte, and even removed page from swap cache: return success
+	 * to go on to do_swap_page()'s pte_same() test, which should fail.
+	 */
+	if (!PageSwapCache(page))
+		return 0;
+
 	ent.val = page_private(page);
 
 	mem = lookup_swap_cgroup(ent);
--- mmotm.orig/mm/memory.c	2008-11-23 21:03:48.000000000 +0000
+++ mmotm/mm/memory.c	2008-11-23 21:06:12.000000000 +0000
@@ -2361,8 +2361,20 @@ static int do_swap_page(struct mm_struct
 		goto out_nomap;
 	}
 
-	/* The page isn't present yet, go ahead with the fault. */
+	/*
+	 * The page isn't present yet, go ahead with the fault.
+	 *
+	 * Be careful about the sequence of operations here.
+	 * To get its accounting right, reuse_swap_page() must be called
+	 * while the page is counted on swap but not yet in mapcount i.e.
+	 * before page_add_anon_rmap() and swap_free(); try_to_free_swap()
+	 * must be called after the swap_free(), or it will never succeed.
+	 * And mem_cgroup_commit_charge_swapin(), which uses the swp_entry
+	 * in page->private, must be called before reuse_swap_page(),
+	 * which may delete_from_swap_cache().
+	 */
 
+	mem_cgroup_commit_charge_swapin(page, ptr);
 	inc_mm_counter(mm, anon_rss);
 	pte = mk_pte(page, vma->vm_page_prot);
 	if (write_access && reuse_swap_page(page)) {
@@ -2373,7 +2385,6 @@ static int do_swap_page(struct mm_struct
 	flush_icache_page(vma, page);
 	set_pte_at(mm, address, page_table, pte);
 	page_add_anon_rmap(page, vma, address);
-	mem_cgroup_commit_charge_swapin(page, ptr);
 
 	swap_free(entry);
 	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
