Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C014E6B0215
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 23:10:18 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3E3AEUx020129
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 14 Apr 2010 12:10:14 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D0CE45DE55
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 12:10:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0602545DE4E
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 12:10:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E09FE1DB803C
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 12:10:13 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A1AE1DB803A
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 12:10:13 +0900 (JST)
Date: Wed, 14 Apr 2010 12:06:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][BUGFIX][PATCH] memcg: fix underflow of mapped_file stat
Message-Id: <20100414120622.0a5c2983.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100414105608.d40c70ab.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100413134207.f12cdc9c.nishimura@mxp.nes.nec.co.jp>
	<20100413151400.cb89beb7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100414095408.d7b352f1.nishimura@mxp.nes.nec.co.jp>
	<20100414100308.693c5650.kamezawa.hiroyu@jp.fujitsu.com>
	<20100414104010.7a359d04.kamezawa.hiroyu@jp.fujitsu.com>
	<20100414105608.d40c70ab.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Apr 2010 10:56:08 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Thinking again....new page is unlocked here. It means the new page may be
> removed from radix-tree before commit_charge().
> 
> Haha, it seems totally wrong. please wait..
> 

This is my answer. How do you think ?
I think this logic is simple. (But yes, we should check corner cases.)

==

At page migration, the new page is unlocked before calling end_migration().
This is mis-understanding with page-migration code of memcg.
And FILE_MAPPED of migrated file cache is not properly updated, now.

At migrating mapped file, events happens in following sequence.

 1. allocate a new page.
 2. get memcg of an old page.
 3. charge ageinst new page, before migration. But at this point
    no changes to page_cgroup, no commit-charge.
 4. page migration replaces radix-tree, old-page and new-page.
 5. page migration remaps the new page if the old page was mapped.
 6. memcg commits the charge for newpage.

Because "commit" happens after page-remap, we lose file_mapped
accounting information at migration.

For fixing all, this changes parepare/end migration.
New migration sequence with memcg is:

 1. allocate a new page.
 2. charge against a new page onto old page's memcg. (here, the new page
    is marked as PageCgroupUsed.)
 3. page migration replaces radix-tree, page table, etc...
 4. At remapping, FILE_MAPPED will be properly updated. (because newpage is marked as
    USED, already)
 5. If anonymous page is freed before remap, check it and fixup accounting.
 

Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    6 +-
 mm/memcontrol.c            |   95 ++++++++++++++++++++++++---------------------
 mm/migrate.c               |    2 
 3 files changed, 56 insertions(+), 47 deletions(-)

Index: mmotm-temp/mm/memcontrol.c
===================================================================
--- mmotm-temp.orig/mm/memcontrol.c
+++ mmotm-temp/mm/memcontrol.c
@@ -2501,10 +2501,12 @@ static inline int mem_cgroup_move_swap_a
  * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
  * page belongs to.
  */
-int mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
+int mem_cgroup_prepare_migration(struct page *page,
+	struct page *newpage, struct mem_cgroup **ptr)
 {
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
+	enum charge_type ctype;
 	int ret = 0;
 
 	if (mem_cgroup_disabled())
@@ -2517,65 +2519,70 @@ int mem_cgroup_prepare_migration(struct 
 		css_get(&mem->css);
 	}
 	unlock_page_cgroup(pc);
-
-	if (mem) {
-		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
-		css_put(&mem->css);
-	}
-	*ptr = mem;
+	/*
+	 * If the page is uncharged before migration (removed from radix-tree)
+	 * we return here.
+	 */
+	if (!mem)
+		return 0;
+	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
+	css_put(&mem->css); /* drop extra refcnt */
+	if (ret)
+		return ret;
+	/*
+ 	 * The old page is under lock_page().
+ 	 * If the old_page is uncharged and freed while migration, page migration
+ 	 * will fail and newpage will properly uncharged by end_migration.
+ 	 * And commit_charge against newpage never fails.
+  	 */
+	pc = lookup_page_cgroup(newpage);
+	if (PageAnon(page))
+		ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
+	else if (!PageSwapBacked(page))
+		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
+	else
+		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
+	__mem_cgroup_commit_charge(mem, pc, ctype);
+	/* FILE_MAPPED of this page will be updated at remap routine */
 	return ret;
 }
 
 /* remove redundant charge if migration failed*/
 void mem_cgroup_end_migration(struct mem_cgroup *mem,
-		struct page *oldpage, struct page *newpage)
+	struct page *oldpage, struct page *newpage)
 {
-	struct page *target, *unused;
-	struct page_cgroup *pc;
-	enum charge_type ctype;
+	struct page *used, *unused;
 
 	if (!mem)
 		return;
 	cgroup_exclude_rmdir(&mem->css);
+
+
 	/* at migration success, oldpage->mapping is NULL. */
 	if (oldpage->mapping) {
-		target = oldpage;
-		unused = NULL;
+		used = oldpage;
+		unused = newpage;
 	} else {
-		target = newpage;
+		used = newpage;
 		unused = oldpage;
 	}
-
-	if (PageAnon(target))
-		ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
-	else if (page_is_file_cache(target))
-		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
-	else
-		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
-
-	/* unused page is not on radix-tree now. */
-	if (unused)
-		__mem_cgroup_uncharge_common(unused, ctype);
-
-	pc = lookup_page_cgroup(target);
-	/*
-	 * __mem_cgroup_commit_charge() check PCG_USED bit of page_cgroup.
-	 * So, double-counting is effectively avoided.
-	 */
-	__mem_cgroup_commit_charge(mem, pc, ctype);
-
+	/* PageCgroupUsed() flag check will do all we want */
+	mem_cgroup_uncharge_page(unused);
 	/*
-	 * Both of oldpage and newpage are still under lock_page().
-	 * Then, we don't have to care about race in radix-tree.
-	 * But we have to be careful that this page is unmapped or not.
-	 *
-	 * There is a case for !page_mapped(). At the start of
-	 * migration, oldpage was mapped. But now, it's zapped.
-	 * But we know *target* page is not freed/reused under us.
-	 * mem_cgroup_uncharge_page() does all necessary checks.
-	 */
-	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
-		mem_cgroup_uncharge_page(target);
+ 	 * If old page was file cache, and removed from radix-tree
+ 	 * before lock_page(), perepare_migration doesn't charge and we never
+ 	 * reach here.
+ 	 *
+ 	 * Considering ANON pages, we can't depend on lock_page.
+ 	 * If a page may be unmapped before it's remapped, new page's
+ 	 * mapcount will not increase. (case that mapcount 0->1 never occur.)
+ 	 * PageCgroupUsed() and SwapCache checks will be done.
+ 	 *
+ 	 * Once mapcount goes to 1, our hook to page_remove_rmap will do
+ 	 * enough jobs.
+ 	 */
+	if (PageAnon(used) && !page_mapped(used))
+		mem_cgroup_uncharge_page(used);
 	/*
 	 * At migration, we may charge account against cgroup which has no tasks
 	 * So, rmdir()->pre_destroy() can be called while we do this charge.
Index: mmotm-temp/mm/migrate.c
===================================================================
--- mmotm-temp.orig/mm/migrate.c
+++ mmotm-temp/mm/migrate.c
@@ -576,7 +576,7 @@ static int unmap_and_move(new_page_t get
 	}
 
 	/* charge against new page */
-	charge = mem_cgroup_prepare_migration(page, &mem);
+	charge = mem_cgroup_prepare_migration(page, newpage, &mem);
 	if (charge == -ENOMEM) {
 		rc = -ENOMEM;
 		goto unlock;
Index: mmotm-temp/include/linux/memcontrol.h
===================================================================
--- mmotm-temp.orig/include/linux/memcontrol.h
+++ mmotm-temp/include/linux/memcontrol.h
@@ -89,7 +89,8 @@ int mm_match_cgroup(const struct mm_stru
 extern struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem);
 
 extern int
-mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr);
+mem_cgroup_prepare_migration(struct page *page,
+	struct page *newpage, struct mem_cgroup **ptr);
 extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
 	struct page *oldpage, struct page *newpage);
 
@@ -228,7 +229,8 @@ static inline struct cgroup_subsys_state
 }
 
 static inline int
-mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
+mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
+	struct mem_cgroup **ptr)
 {
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
