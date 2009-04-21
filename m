Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CBFA46B005A
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 01:32:08 -0400 (EDT)
Date: Tue, 21 Apr 2009 14:29:31 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH 2/2] memcg: free unused swapcache at the end of page
 migration
Message-Id: <20090421142931.2c02811a.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090421142641.aa4efa2f.nishimura@mxp.nes.nec.co.jp>
References: <20090421142641.aa4efa2f.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@in.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Reading the comments, mem_cgroup_end_migration assumes that "newpage" is under lock_page.

And at the end of mem_cgroup_end_migration, mem_cgroup_uncharge_page cannot
uncharge the "target" if it's SwapCache even if the owner process has already
called zap_pte_range -> free_swap_and_cache.
try_to_free_swap does all necessary checks(it checks page_swapcount).

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |    7 +++++--
 mm/migrate.c    |    9 +++++++--
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 619b0c1..f41433c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1611,10 +1611,13 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
 	 * There is a case for !page_mapped(). At the start of
 	 * migration, oldpage was mapped. But now, it's zapped.
 	 * But we know *target* page is not freed/reused under us.
-	 * mem_cgroup_uncharge_page() does all necessary checks.
+	 * mem_cgroup_uncharge_page() cannot free SwapCache, so we call
+	 * try_to_free_swap(), which does all necessary checks.
 	 */
-	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
+	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED && !page_mapped(target)) {
 		mem_cgroup_uncharge_page(target);
+		try_to_free_swap(target);
+	}
 }
 
 /*
diff --git a/mm/migrate.c b/mm/migrate.c
index 068655d..364edf7 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -580,7 +580,7 @@ static int move_to_new_page(struct page *newpage, struct page *page)
 	} else
 		newpage->mapping = NULL;
 
-	unlock_page(newpage);
+	/* keep lock on newpage because mem_cgroup_end_migration assumes it */
 
 	return rc;
 }
@@ -595,6 +595,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 	int rc = 0;
 	int *result = NULL;
 	struct page *newpage = get_new_page(page, private, &result);
+	int newpage_locked = 0;
 	int rcu_locked = 0;
 	int charge = 0;
 	struct mem_cgroup *mem;
@@ -671,8 +672,10 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 	/* Establish migration ptes or remove ptes */
 	try_to_unmap(page, 1);
 
-	if (!page_mapped(page))
+	if (!page_mapped(page)) {
 		rc = move_to_new_page(newpage, page);
+		newpage_locked = 1;
+	}
 
 	if (rc)
 		remove_migration_ptes(page, page);
@@ -683,6 +686,8 @@ uncharge:
 	if (!charge)
 		mem_cgroup_end_migration(mem, page, newpage);
 unlock:
+	if (newpage_locked)
+		unlock_page(newpage);
 	unlock_page(page);
 
 	if (rc != -EAGAIN) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
