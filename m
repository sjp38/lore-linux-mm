Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 8AEAD6B0062
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 13:02:51 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 01/10] mm: memcg: fix compaction/migration failing due to memcg limits
Date: Wed, 11 Jul 2012 19:02:13 +0200
Message-Id: <1342026142-7284-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1342026142-7284-1-git-send-email-hannes@cmpxchg.org>
References: <1342026142-7284-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwp.linux@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Compaction (and page migration in general) can currently be hindered
through pages being owned by memory cgroups that are at their limits
and unreclaimable.

The reason is that the replacement page is being charged against the
limit while the page being replaced is also still charged.  But this
seems unnecessary, given that only one of the two pages will still be
in use after migration finishes.

This patch changes the memcg migration sequence so that the
replacement page is not charged.  Whatever page is still in use after
successful or failed migration gets to keep the charge of the page
that was going to be replaced.

The replacement page will still show up temporarily in the rss/cache
statistics, this can be fixed in a later patch as it's less urgent.

Reported-by: David Rientjes <rientjes@google.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/memcontrol.h |   11 +++----
 mm/memcontrol.c            |   67 +++++++++++++++++++++++--------------------
 mm/migrate.c               |   27 ++++--------------
 3 files changed, 47 insertions(+), 58 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5a3ee64..8d9489f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -98,9 +98,9 @@ int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
 
 extern struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg);
 
-extern int
-mem_cgroup_prepare_migration(struct page *page,
-	struct page *newpage, struct mem_cgroup **memcgp, gfp_t gfp_mask);
+extern void
+mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
+			     struct mem_cgroup **memcgp);
 extern void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 	struct page *oldpage, struct page *newpage, bool migration_ok);
 
@@ -276,11 +276,10 @@ static inline struct cgroup_subsys_state
 	return NULL;
 }
 
-static inline int
+static inline void
 mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
-	struct mem_cgroup **memcgp, gfp_t gfp_mask)
+			     struct mem_cgroup **memcgp)
 {
-	return 0;
 }
 
 static inline void mem_cgroup_end_migration(struct mem_cgroup *memcg,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e8ddc00..12ee2de 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2977,7 +2977,8 @@ static void mem_cgroup_do_uncharge(struct mem_cgroup *memcg,
  * uncharge if !page_mapped(page)
  */
 static struct mem_cgroup *
-__mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
+__mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype,
+			     bool end_migration)
 {
 	struct mem_cgroup *memcg = NULL;
 	unsigned int nr_pages = 1;
@@ -3021,7 +3022,16 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 		/* fallthrough */
 	case MEM_CGROUP_CHARGE_TYPE_DROP:
 		/* See mem_cgroup_prepare_migration() */
-		if (page_mapped(page) || PageCgroupMigration(pc))
+		if (page_mapped(page))
+			goto unlock_out;
+		/*
+		 * Pages under migration may not be uncharged.  But
+		 * end_migration() /must/ be the one uncharging the
+		 * unused post-migration page and so it has to call
+		 * here with the migration bit still set.  See the
+		 * res_counter handling below.
+		 */
+		if (!end_migration && PageCgroupMigration(pc))
 			goto unlock_out;
 		break;
 	case MEM_CGROUP_CHARGE_TYPE_SWAPOUT:
@@ -3055,7 +3065,12 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 		mem_cgroup_swap_statistics(memcg, true);
 		mem_cgroup_get(memcg);
 	}
-	if (!mem_cgroup_is_root(memcg))
+	/*
+	 * Migration does not charge the res_counter for the
+	 * replacement page, so leave it alone when phasing out the
+	 * page that is unused after the migration.
+	 */
+	if (!end_migration && !mem_cgroup_is_root(memcg))
 		mem_cgroup_do_uncharge(memcg, nr_pages, ctype);
 
 	return memcg;
@@ -3071,14 +3086,14 @@ void mem_cgroup_uncharge_page(struct page *page)
 	if (page_mapped(page))
 		return;
 	VM_BUG_ON(page->mapping && !PageAnon(page));
-	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_ANON);
+	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_ANON, false);
 }
 
 void mem_cgroup_uncharge_cache_page(struct page *page)
 {
 	VM_BUG_ON(page_mapped(page));
 	VM_BUG_ON(page->mapping);
-	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
+	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE, false);
 }
 
 /*
@@ -3142,7 +3157,7 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
 	if (!swapout) /* this was a swap cache but the swap is unused ! */
 		ctype = MEM_CGROUP_CHARGE_TYPE_DROP;
 
-	memcg = __mem_cgroup_uncharge_common(page, ctype);
+	memcg = __mem_cgroup_uncharge_common(page, ctype, false);
 
 	/*
 	 * record memcg information,  if swapout && memcg != NULL,
@@ -3232,19 +3247,18 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
  * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
  * page belongs to.
  */
-int mem_cgroup_prepare_migration(struct page *page,
-	struct page *newpage, struct mem_cgroup **memcgp, gfp_t gfp_mask)
+void mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
+				  struct mem_cgroup **memcgp)
 {
 	struct mem_cgroup *memcg = NULL;
 	struct page_cgroup *pc;
 	enum charge_type ctype;
-	int ret = 0;
 
 	*memcgp = NULL;
 
 	VM_BUG_ON(PageTransHuge(page));
 	if (mem_cgroup_disabled())
-		return 0;
+		return;
 
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
@@ -3289,24 +3303,9 @@ int mem_cgroup_prepare_migration(struct page *page,
 	 * we return here.
 	 */
 	if (!memcg)
-		return 0;
+		return;
 
 	*memcgp = memcg;
-	ret = __mem_cgroup_try_charge(NULL, gfp_mask, 1, memcgp, false);
-	css_put(&memcg->css);/* drop extra refcnt */
-	if (ret) {
-		if (PageAnon(page)) {
-			lock_page_cgroup(pc);
-			ClearPageCgroupMigration(pc);
-			unlock_page_cgroup(pc);
-			/*
-			 * The old page may be fully unmapped while we kept it.
-			 */
-			mem_cgroup_uncharge_page(page);
-		}
-		/* we'll need to revisit this error code (we have -EINTR) */
-		return -ENOMEM;
-	}
 	/*
 	 * We charge new page before it's used/mapped. So, even if unlock_page()
 	 * is called before end_migration, we can catch all events on this new
@@ -3319,8 +3318,12 @@ int mem_cgroup_prepare_migration(struct page *page,
 		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
 	else
 		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
+	/*
+	 * The page is committed to the memcg, but it's not actually
+	 * charged to the res_counter since we plan on replacing the
+	 * old one and only one page is going to be left afterwards.
+	 */
 	__mem_cgroup_commit_charge(memcg, newpage, 1, ctype, false);
-	return ret;
 }
 
 /* remove redundant charge if migration failed*/
@@ -3342,6 +3345,12 @@ void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 		used = newpage;
 		unused = oldpage;
 	}
+	anon = PageAnon(used);
+	__mem_cgroup_uncharge_common(unused,
+		anon ? MEM_CGROUP_CHARGE_TYPE_ANON
+		     : MEM_CGROUP_CHARGE_TYPE_CACHE,
+		true);
+	css_put(&memcg->css);
 	/*
 	 * We disallowed uncharge of pages under migration because mapcount
 	 * of the page goes down to zero, temporarly.
@@ -3351,10 +3360,6 @@ void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 	lock_page_cgroup(pc);
 	ClearPageCgroupMigration(pc);
 	unlock_page_cgroup(pc);
-	anon = PageAnon(used);
-	__mem_cgroup_uncharge_common(unused,
-		anon ? MEM_CGROUP_CHARGE_TYPE_ANON
-		     : MEM_CGROUP_CHARGE_TYPE_CACHE);
 
 	/*
 	 * If a page is a file cache, radix-tree replacement is very atomic
diff --git a/mm/migrate.c b/mm/migrate.c
index 8137aea..aa06bf4 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -687,7 +687,6 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 {
 	int rc = -EAGAIN;
 	int remap_swapcache = 1;
-	int charge = 0;
 	struct mem_cgroup *mem;
 	struct anon_vma *anon_vma = NULL;
 
@@ -729,12 +728,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	}
 
 	/* charge against new page */
-	charge = mem_cgroup_prepare_migration(page, newpage, &mem, GFP_KERNEL);
-	if (charge == -ENOMEM) {
-		rc = -ENOMEM;
-		goto unlock;
-	}
-	BUG_ON(charge);
+	mem_cgroup_prepare_migration(page, newpage, &mem);
 
 	if (PageWriteback(page)) {
 		/*
@@ -824,8 +818,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		put_anon_vma(anon_vma);
 
 uncharge:
-	if (!charge)
-		mem_cgroup_end_migration(mem, page, newpage, rc == 0);
+	mem_cgroup_end_migration(mem, page, newpage, rc == 0);
 unlock:
 	unlock_page(page);
 out:
@@ -1519,10 +1512,9 @@ migrate_misplaced_page(struct page *page, struct mm_struct *mm, int node)
 {
 	struct page *oldpage = page, *newpage;
 	struct address_space *mapping = page_mapping(page);
-	struct mem_cgroup *mcg;
+	struct mem_cgroup *memcg;
 	unsigned int gfp;
 	int rc = 0;
-	int charge = -ENOMEM;
 
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(page_mapcount(page));
@@ -1556,12 +1548,7 @@ migrate_misplaced_page(struct page *page, struct mm_struct *mm, int node)
 	if (!trylock_page(newpage))
 		BUG();		/* new page should be unlocked!!! */
 
-	// XXX hnaz, is this right?
-	charge = mem_cgroup_prepare_migration(page, newpage, &mcg, gfp);
-	if (charge == -ENOMEM) {
-		rc = charge;
-		goto out;
-	}
+	mem_cgroup_prepare_migration(page, newpage, &memcg);
 
 	newpage->index = page->index;
 	newpage->mapping = page->mapping;
@@ -1581,11 +1568,9 @@ migrate_misplaced_page(struct page *page, struct mm_struct *mm, int node)
 		page = newpage;
 	}
 
+	mem_cgroup_end_migration(memcg, oldpage, newpage, !rc);
 out:
-	if (!charge)
-		mem_cgroup_end_migration(mcg, oldpage, newpage, !rc);
-
-       if (oldpage != page)
+	if (oldpage != page)
                put_page(oldpage);
 
 	if (rc) {
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
