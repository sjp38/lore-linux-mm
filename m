Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AD5426B025B
	for <linux-mm@kvack.org>; Fri,  7 May 2010 02:30:13 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o476U9Oc009782
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 7 May 2010 15:30:10 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8445545DE4E
	for <linux-mm@kvack.org>; Fri,  7 May 2010 15:30:09 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 560CE45DE50
	for <linux-mm@kvack.org>; Fri,  7 May 2010 15:30:09 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E6F541DB8015
	for <linux-mm@kvack.org>; Fri,  7 May 2010 15:30:06 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 765B71DB801D
	for <linux-mm@kvack.org>; Fri,  7 May 2010 15:30:03 +0900 (JST)
Date: Fri, 7 May 2010 15:26:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][BUGFIX] memcg: fix file_mapped counting at migraton
Message-Id: <20100507152606.c5fef2f1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


It seems Mel's fix will go ahead, soon. (it works well) So, we can do
test migration by compaction, again. Let's start to fix memcg.
This is a patch under a test in my box (-mm + Mel's fix).

==
At page migration, the new page is unlocked before calling end_migration().
This is mis-understanding with page-migration code of memcg.
(it worked but...)
This has small race and we need to fix this race. By this,
FILE_MAPPED of migrated file cache is not properly updated, now.

This patch is for fixing the race by changing algorithm.

At migrating mapped file, events happens in following sequence.

 1. allocate a new page.
 2. get memcg of an old page.
 3. charge ageinst a new page before migration. But at this point,
    no changes to new page's page_cgroup, no commit-charge.
 4. page migration replaces radix-tree, old-page and new-page.
 5. page migration remaps the new page if the old page was mapped.
 6. Here, the new page is unlocked.
 7. memcg commits the charge for newpage, Mark page cgroup as USED.

Because "commit" happens after page-remap, we can count FILE_MAPPED
at "5", we can lose file_mapped accounting information within this
small race. FILE_MAPPED is updated only when mapcount changes 0->1.
So, if we don't catch this 0->1 event, we can underflow FILE_MAPPED
at 1->0 event.

We may be able to avoid underflow by some small technique but
we should catch mapcount 0->1 event. To catch this, we have to
make page_cgroup of new page as "USED".

BTW, historically, above implemntation comes from migration-failure
of anonymous page. Because we charge both of old page and new page
with mapcount=0, we can't catch
  - the page is really freed before remap.
  - migration fails but it's freed before remap
or .....corner cases.

For fixing all, this changes parepare/end migration.

New migration sequence with memcg is:

 1. allocate a new page.
 2. mark PageCgroupMigration to the old page.
 3. charge against a new page onto the old page's memcg. (here, new page's pc
    is marked as PageCgroupUsed.)
 4. mark PageCgroupMigration to the old page.

If page_cgroup is marked as PageCgroupMigration, it's uncahrged until
it's cleared.

 5. page migration replaces radix-tree, page table, etc...
 6. At remapping, new page's page_cgroup is now makrked as "USED"
    We can catch 0->1 event and FILE_MAPPED will be properly updated.
    And we can catch SWAPOUT event after unlock this and freeing this
    page by unmap() can be caught.

 7. Clear PageCgroupMigration of the old page.

By this:
At migration success of Anon:
 - The new page is properly charged. If not-mapped after remap,
   uncharge() will be called.
 - The file cache is properly charged. FILE_MAPPED event can be caught.

At migration failure of Anon:
 - The old page stays as charged. If not mapped after remap,
   uncharge() will called. The corner case is SWAPOUT. But, while migraion,
   it's locked. So, we have no race with it.

Then, for what MIGRATION flag is ?
  Without it, at migration failure, we may have to charge old page again
  because it may be fully unmapped. "charge" means that we have to dive into
  memory reclaim or something complated. So, it's better to avoid
  charge it again. Before this patch, __commit_charge() was working for
  both of the old/new page and fixed up all. But this technique has some
  racy condtion around FILE_MAPPED and SWAPOUT etc...
  Now, the kernel use MIGRATION flag and don't uncharge old page until
  the end of migration.


I hope this change will make memcg's page migration much simpler.
This page migration has caused several troubles. Worth to add
a flag for simplification.

Changelog: 2010/04/20
 - fixed SWAPOUT case.
 - added texts for explanation.
 - removed MIGRAION flag onto new page.

Changelog: 2010/04/15
 - updated against  mm-of-the-moment snapshot 2010-04-15-14-42
   + Nishimura's fix. memcg-fix-prepare-migration-fix.patch
 - fixed some typos.
 - handle migration failure of anon page.

Changelog: 2010/04/14
 - updated onto the latest mmotm + page-compaction, etc...
 - fixed __try_charge() bypass case.
 - use CHARGE_TYPE_FORCE for uncharging an unused page.

Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h  |    6 +
 include/linux/page_cgroup.h |    5 +
 mm/memcontrol.c             |  145 +++++++++++++++++++++++++++++++-------------
 mm/migrate.c                |    2 
 4 files changed, 115 insertions(+), 43 deletions(-)

Index: linux-2.6.34-rc4-mm1/mm/memcontrol.c
===================================================================
--- linux-2.6.34-rc4-mm1.orig/mm/memcontrol.c
+++ linux-2.6.34-rc4-mm1/mm/memcontrol.c
@@ -2278,7 +2278,8 @@ __mem_cgroup_uncharge_common(struct page
 	switch (ctype) {
 	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
 	case MEM_CGROUP_CHARGE_TYPE_DROP:
-		if (page_mapped(page))
+		/* See mem_cgroup_prepare_migration() */
+		if (page_mapped(page) || PageCgroupMigration(pc))
 			goto unlock_out;
 		break;
 	case MEM_CGROUP_CHARGE_TYPE_SWAPOUT:
@@ -2501,10 +2502,12 @@ static inline int mem_cgroup_move_swap_a
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
@@ -2515,69 +2518,131 @@ int mem_cgroup_prepare_migration(struct 
 	if (PageCgroupUsed(pc)) {
 		mem = pc->mem_cgroup;
 		css_get(&mem->css);
+		/*
+		 * At migrationg an anonymous page, its mapcount goes down
+		 * to 0 and uncharge() will be called. But, even if it's fully
+		 * unmapped, migration may fail and this page has to be
+		 * charged again. We set MIGRATION flag here and delay uncharge
+		 * until end_migration() is called
+		 *
+		 * Corner Case Thinking
+		 * A)
+		 * When the old page was mapped as Anon and it's unmap-and-freed
+		 * while migration was ongoing, it's not uncharged until
+		 * end_migration(). Both of old and new page will be uncharged
+		 * at end_migration() because it's not mapped and not SwapCache.
+		 *
+		 * B)
+		 * When the old page was mapped but migraion fails, the kernel
+		 * remap it. The charge for it is kept by MIGRATION flag even
+		 * if mapcount goes down to 0, we can do remap successfully
+		 * without charging it again.
+		 * If the kernel doesn't remap it because it's unmapped,
+		 * we can check it at end_migration(), no new charge happens
+		 * at end_migration().
+		 *
+		 * C)
+		 * The "old" page is under lock_page() until the end of
+		 * migration, so, the old page itself will not be swapped-out.
+		 * But the new page can be.
+		 * etc...
+		 */
+		if (PageAnon(page))
+			SetPageCgroupMigration(pc);
 	}
 	unlock_page_cgroup(pc);
+	/*
+	 * If the page is not charged at this point,
+	 * we return here.
+	 */
+	if (!mem)
+		return 0;
 
 	*ptr = mem;
-	if (mem) {
-		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, ptr, false);
-		css_put(&mem->css);
+	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, ptr, false);
+	css_put(&mem->css);/* drop extra refcnt */
+	if (ret || *ptr == NULL) {
+		if (PageAnon(page)) {
+			lock_page_cgroup(pc);
+			ClearPageCgroupMigration(pc);
+			unlock_page_cgroup(pc);
+			/*
+		 	 * The old page may be fully unmapped while we kept it.
+		 	 */
+			mem_cgroup_uncharge_page(page);
+		}
+		return -ENOMEM;
 	}
+	/*
+ 	 * We charge new page before it's mapped. So, even if unlock_page()
+ 	 * is called far before end_migration, we can catch all events on
+ 	 * this new page. In the case new page is migrated but not remapped,
+ 	 * new page's mapcount will be finally 0 and we call uncharge in
+ 	 * end_migration().
+  	 */
+	pc = lookup_page_cgroup(newpage);
+	if (PageAnon(page))
+		ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
+	else if (page_is_file_cache(page))
+		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
+	else
+		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
+	__mem_cgroup_commit_charge(mem, pc, ctype);
 	return ret;
 }
 
 /* remove redundant charge if migration failed*/
 void mem_cgroup_end_migration(struct mem_cgroup *mem,
-		struct page *oldpage, struct page *newpage)
+	struct page *oldpage, struct page *newpage)
 {
-	struct page *target, *unused;
+	struct page *used, *unused;
 	struct page_cgroup *pc;
-	enum charge_type ctype;
 
 	if (!mem)
 		return;
+	/* blocks rmdir() */
 	cgroup_exclude_rmdir(&mem->css);
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
 	/*
-	 * __mem_cgroup_commit_charge() check PCG_USED bit of page_cgroup.
-	 * So, double-counting is effectively avoided.
+	 * We disallowed uncharge of pages under migration because mapcount
+	 * of the page goes down to zero, temporarly.
+	 * Clear the flag and check the page should be charged.
 	 */
-	__mem_cgroup_commit_charge(mem, pc, ctype);
-
+	pc = lookup_page_cgroup(unused);
+	/* This flag itself is not racy, so, check it before lock */
+	if (PageCgroupMigration(pc)) {
+		lock_page_cgroup(pc);
+		ClearPageCgroupMigration(pc);
+		unlock_page_cgroup(pc);
+	}
+	__mem_cgroup_uncharge_common(unused, MEM_CGROUP_CHARGE_TYPE_FORCE);
+
+	pc = lookup_page_cgroup(used);
+	if (PageCgroupMigration(pc)) {
+		lock_page_cgroup(pc);
+		ClearPageCgroupMigration(pc);
+		unlock_page_cgroup(pc);
+	}
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
+	 * If a page is a file cache, radix-tree replacement is very atomic
+ 	 * and we can skip this check. When it was an Anon page, its mapcount
+ 	 * goes down to 0. But because we added MIGRATION flage, it's not
+ 	 * uncharged yet. There are several case but page->mapcount check
+ 	 * and USED bit check in mem_cgroup_uncharge_page() will do enough
+ 	 * check. (see prepare_charge() also)
+ 	 */
+	if (PageAnon(used))
+		mem_cgroup_uncharge_page(used);
 	/*
-	 * At migration, we may charge account against cgroup which has no tasks
+	 * At migration, we may charge account against cgroup which has no
+	 * tasks.
 	 * So, rmdir()->pre_destroy() can be called while we do this charge.
 	 * In that case, we need to call pre_destroy() again. check it here.
 	 */
Index: linux-2.6.34-rc4-mm1/mm/migrate.c
===================================================================
--- linux-2.6.34-rc4-mm1.orig/mm/migrate.c
+++ linux-2.6.34-rc4-mm1/mm/migrate.c
@@ -581,7 +581,7 @@ static int unmap_and_move(new_page_t get
 	}
 
 	/* charge against new page */
-	charge = mem_cgroup_prepare_migration(page, &mem);
+	charge = mem_cgroup_prepare_migration(page, newpage, &mem);
 	if (charge == -ENOMEM) {
 		rc = -ENOMEM;
 		goto unlock;
Index: linux-2.6.34-rc4-mm1/include/linux/memcontrol.h
===================================================================
--- linux-2.6.34-rc4-mm1.orig/include/linux/memcontrol.h
+++ linux-2.6.34-rc4-mm1/include/linux/memcontrol.h
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
Index: linux-2.6.34-rc4-mm1/include/linux/page_cgroup.h
===================================================================
--- linux-2.6.34-rc4-mm1.orig/include/linux/page_cgroup.h
+++ linux-2.6.34-rc4-mm1/include/linux/page_cgroup.h
@@ -40,6 +40,7 @@ enum {
 	PCG_USED, /* this object is in use. */
 	PCG_ACCT_LRU, /* page has been accounted for */
 	PCG_FILE_MAPPED, /* page is accounted as "mapped" */
+	PCG_MIGRATION, /* under page migration */
 };
 
 #define TESTPCGFLAG(uname, lname)			\
@@ -79,6 +80,10 @@ SETPCGFLAG(FileMapped, FILE_MAPPED)
 CLEARPCGFLAG(FileMapped, FILE_MAPPED)
 TESTPCGFLAG(FileMapped, FILE_MAPPED)
 
+SETPCGFLAG(Migration, MIGRATION)
+CLEARPCGFLAG(Migration, MIGRATION)
+TESTPCGFLAG(Migration, MIGRATION)
+
 static inline int page_cgroup_nid(struct page_cgroup *pc)
 {
 	return page_to_nid(pc->page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
