Date: Tue, 1 Apr 2008 17:30:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [-mm][PATCH 1/6] memcg: radix-tree lookup for page_cgroup.
Message-Id: <20080401173032.58606e19.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080401172837.2c92000d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080401172837.2c92000d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, menage@google.com
List-ID: <linux-mm.kvack.org>

This patch implements radixt-tree based page cgroup.

This patch does
 * add radix-tree based page_cgroup look up subsystem.
 * remove bit_spin_lock used by page_cgroup.

Logic changes:

Before patch
 * struct page had pointer to page_cgroup. Then, relationship between objects
   was pfn <-> struct page <-> struct page_cgroup
 * (spin) lock for page_cgroup was in struct page.
 * page_cgroup->refcnt is incremented before charge is done.
 * page migration does complicated page_cgroup migration under locks.

After patch
 * struct page has no pointer to page_cgroup. Relationship between objects
   is struct page <-> pfn <-> struct page_cgroup -> struct page,
 * page_cgroup has its own spin lock.
 * page_cgroup->refcnt is incremented after charge is done.
 * page migration accounts a new page before migration. By this, we can
   avoid complicated locks. 

tested on ia64/NUMA, x86_64/SMP.

Changelog v2 -> v3:
 * changes get_alloc_page_cgroup() to return -EBUSY while boot.
 * fixed typos
 * add PageLRU check into force_empty(). (this can be good guard against
   migration.)

Changelog v1 -> v2:
 * create a folded patch. maybe good for bysect.
 * removed special handling codes for new pages under migration
   Added PG_LRU check to force_empty.
 * reflected comments.
 * Added comments in the head of page_cgroup.c
 * order of page_cgroup is automatically calculated.
 * fixed handling of root_node[] entries in page_cgroup_init().
 * rewrite init_page_cgroup_head() to do minimum work.
 * fixed N_NORMAL_MEMORY handling.
 
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 include/linux/memcontrol.h  |   20 --
 include/linux/mm_types.h    |    3 
 include/linux/page_cgroup.h |   55 +++++++
 mm/Makefile                 |    2 
 mm/memcontrol.c             |  331 ++++++++++++++++----------------------------
 mm/migrate.c                |   22 +-
 mm/page_alloc.c             |    8 -
 mm/page_cgroup.c            |  259 ++++++++++++++++++++++++++++++++++
 8 files changed, 462 insertions(+), 238 deletions(-)

Index: mm-2.6.25-rc5-mm1-k/include/linux/page_cgroup.h
===================================================================
--- /dev/null
+++ mm-2.6.25-rc5-mm1-k/include/linux/page_cgroup.h
@@ -0,0 +1,55 @@
+#ifndef __LINUX_PAGE_CGROUP_H
+#define __LINUX_PAGE_CGROUP_H
+
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+/*
+ * page_cgroup is yet another mem_map structure for accounting usage.
+ * but, unlike mem_map, allocated on demand for accounted pages.
+ * see also memcontrol.h
+ * In nature, this consumes much amount of memory.
+ */
+
+struct mem_cgroup;
+
+struct page_cgroup {
+	spinlock_t		lock;        /* lock for all members */
+	int  			refcnt;      /* reference count */
+	struct mem_cgroup 	*mem_cgroup; /* current cgroup subsys */
+	struct list_head 	lru;         /* for per cgroup LRU */
+	int    			flags;	     /* See below */
+	struct page 		*page;       /* the page this accounts for*/
+};
+
+/* flags */
+#define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache. */
+#define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* is on active list */
+
+/*
+ * look up page_cgroup. returns NULL if not exists.
+ */
+extern struct page_cgroup *get_page_cgroup(struct page *page);
+
+
+/*
+ * look up page_cgroup, allocate new one if it doesn't exist.
+ * Return value is
+ *   1. page_cgroup, at success.
+ *   2. -EXXXXX, at failure. (-EBUSY at boot)
+ */
+extern struct page_cgroup *
+get_alloc_page_cgroup(struct page *page, gfp_t gfpmask);
+
+#else
+
+static inline struct page_cgroup *get_page_cgroup(struct page *page)
+{
+	return NULL;
+}
+
+static inline struct page_cgroup *
+get_alloc_page_cgroup(struct page *page, gfp_t gfpmask)
+{
+	return NULL;
+}
+#endif
+#endif
Index: mm-2.6.25-rc5-mm1-k/mm/memcontrol.c
===================================================================
--- mm-2.6.25-rc5-mm1-k.orig/mm/memcontrol.c
+++ mm-2.6.25-rc5-mm1-k/mm/memcontrol.c
@@ -30,6 +30,7 @@
 #include <linux/spinlock.h>
 #include <linux/fs.h>
 #include <linux/seq_file.h>
+#include <linux/page_cgroup.h>
 
 #include <asm/uaccess.h>
 
@@ -92,7 +93,7 @@ struct mem_cgroup_per_zone {
 	/*
 	 * spin_lock to protect the per cgroup LRU
 	 */
-	spinlock_t		lru_lock;
+	spinlock_t		lru_lock;	/* irq should be off. */
 	struct list_head	active_list;
 	struct list_head	inactive_list;
 	unsigned long count[NR_MEM_CGROUP_ZSTAT];
@@ -139,33 +140,6 @@ struct mem_cgroup {
 };
 static struct mem_cgroup init_mem_cgroup;
 
-/*
- * We use the lower bit of the page->page_cgroup pointer as a bit spin
- * lock.  We need to ensure that page->page_cgroup is at least two
- * byte aligned (based on comments from Nick Piggin).  But since
- * bit_spin_lock doesn't actually set that lock bit in a non-debug
- * uniprocessor kernel, we should avoid setting it here too.
- */
-#define PAGE_CGROUP_LOCK_BIT 	0x0
-#if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
-#define PAGE_CGROUP_LOCK 	(1 << PAGE_CGROUP_LOCK_BIT)
-#else
-#define PAGE_CGROUP_LOCK	0x0
-#endif
-
-/*
- * A page_cgroup page is associated with every page descriptor. The
- * page_cgroup helps us identify information about the cgroup
- */
-struct page_cgroup {
-	struct list_head lru;		/* per cgroup LRU list */
-	struct page *page;
-	struct mem_cgroup *mem_cgroup;
-	int ref_cnt;			/* cached, mapped, migrating */
-	int flags;
-};
-#define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
-#define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* page is active in this cgroup */
 
 static int page_cgroup_nid(struct page_cgroup *pc)
 {
@@ -256,37 +230,6 @@ void mm_free_cgroup(struct mm_struct *mm
 	css_put(&mm->mem_cgroup->css);
 }
 
-static inline int page_cgroup_locked(struct page *page)
-{
-	return bit_spin_is_locked(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-}
-
-static void page_assign_page_cgroup(struct page *page, struct page_cgroup *pc)
-{
-	VM_BUG_ON(!page_cgroup_locked(page));
-	page->page_cgroup = ((unsigned long)pc | PAGE_CGROUP_LOCK);
-}
-
-struct page_cgroup *page_get_page_cgroup(struct page *page)
-{
-	return (struct page_cgroup *) (page->page_cgroup & ~PAGE_CGROUP_LOCK);
-}
-
-static void lock_page_cgroup(struct page *page)
-{
-	bit_spin_lock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-}
-
-static int try_lock_page_cgroup(struct page *page)
-{
-	return bit_spin_trylock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-}
-
-static void unlock_page_cgroup(struct page *page)
-{
-	bit_spin_unlock(PAGE_CGROUP_LOCK_BIT, &page->page_cgroup);
-}
-
 static void __mem_cgroup_remove_list(struct page_cgroup *pc)
 {
 	int from = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
@@ -356,6 +299,10 @@ void mem_cgroup_move_lists(struct page *
 	struct mem_cgroup_per_zone *mz;
 	unsigned long flags;
 
+	/* This GFP will be ignored..*/
+	pc = get_page_cgroup(page);
+	if (!pc)
+		return;
 	/*
 	 * We cannot lock_page_cgroup while holding zone's lru_lock,
 	 * because other holders of lock_page_cgroup can be interrupted
@@ -363,17 +310,15 @@ void mem_cgroup_move_lists(struct page *
 	 * safely get to page_cgroup without it, so just try_lock it:
 	 * mem_cgroup_isolate_pages allows for page left on wrong list.
 	 */
-	if (!try_lock_page_cgroup(page))
+	if (!spin_trylock_irqsave(&pc->lock, flags))
 		return;
-
-	pc = page_get_page_cgroup(page);
-	if (pc) {
+	if (pc->refcnt) {
 		mz = page_cgroup_zoneinfo(pc);
-		spin_lock_irqsave(&mz->lru_lock, flags);
+		spin_lock(&mz->lru_lock);
 		__mem_cgroup_move_lists(pc, active);
-		spin_unlock_irqrestore(&mz->lru_lock, flags);
+		spin_unlock(&mz->lru_lock);
 	}
-	unlock_page_cgroup(page);
+	spin_unlock_irqrestore(&pc->lock, flags);
 }
 
 /*
@@ -525,7 +470,8 @@ unsigned long mem_cgroup_isolate_pages(u
  * < 0 if the cgroup is over its limit
  */
 static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
-				gfp_t gfp_mask, enum charge_type ctype)
+				gfp_t gfp_mask, enum charge_type ctype,
+				struct mem_cgroup *memcg)
 {
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
@@ -536,33 +482,26 @@ static int mem_cgroup_charge_common(stru
 	if (mem_cgroup_subsys.disabled)
 		return 0;
 
+	pc = get_alloc_page_cgroup(page, gfp_mask);
+	/* Before kmalloc initialization, get_page_cgroup can return EBUSY */
+	if (unlikely(IS_ERR(pc))) {
+		if (PTR_ERR(pc) == -EBUSY)
+			return NULL;
+		return PTR_ERR(pc);
+	}
+
+	spin_lock_irqsave(&pc->lock, flags);
 	/*
-	 * Should page_cgroup's go to their own slab?
-	 * One could optimize the performance of the charging routine
-	 * by saving a bit in the page_flags and using it as a lock
-	 * to see if the cgroup page already has a page_cgroup associated
-	 * with it
-	 */
-retry:
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
-	/*
-	 * The page_cgroup exists and
-	 * the page has already been accounted.
+	 * Has the page already been accounted ?
 	 */
-	if (pc) {
-		VM_BUG_ON(pc->page != page);
-		VM_BUG_ON(pc->ref_cnt <= 0);
-
-		pc->ref_cnt++;
-		unlock_page_cgroup(page);
-		goto done;
+	if (pc->refcnt > 0) {
+		pc->refcnt++;
+		spin_unlock_irqrestore(&pc->lock, flags);
+		goto success;
 	}
-	unlock_page_cgroup(page);
+	spin_unlock_irqrestore(&pc->lock, flags);
 
-	pc = kzalloc(sizeof(struct page_cgroup), gfp_mask);
-	if (pc == NULL)
-		goto err;
+	/* Note: *new* pc's refcnt is still 0 here. */
 
 	/*
 	 * We always charge the cgroup the mm_struct belongs to.
@@ -570,20 +509,24 @@ retry:
 	 * thread group leader migrates. It's possible that mm is not
 	 * set, if so charge the init_mm (happens for pagecache usage).
 	 */
-	if (!mm)
-		mm = &init_mm;
-
-	rcu_read_lock();
-	mem = rcu_dereference(mm->mem_cgroup);
-	/*
-	 * For every charge from the cgroup, increment reference count
-	 */
-	css_get(&mem->css);
-	rcu_read_unlock();
+	if (memcg) {
+		mem = memcg;
+		css_get(&mem->css);
+	} else {
+		if (!mm)
+			mm = &init_mm;
+		rcu_read_lock();
+		mem = rcu_dereference(mm->mem_cgroup);
+		/*
+		 * For every charge from the cgroup, increment reference count
+		 */
+		css_get(&mem->css);
+		rcu_read_unlock();
+	}
 
 	while (res_counter_charge(&mem->res, PAGE_SIZE)) {
 		if (!(gfp_mask & __GFP_WAIT))
-			goto out;
+			goto nomem;
 
 		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
 			continue;
@@ -600,52 +543,51 @@ retry:
 
 		if (!nr_retries--) {
 			mem_cgroup_out_of_memory(mem, gfp_mask);
-			goto out;
+			goto nomem;
 		}
 		congestion_wait(WRITE, HZ/10);
 	}
-
-	pc->ref_cnt = 1;
-	pc->mem_cgroup = mem;
-	pc->page = page;
-	pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
-	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
-		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
-
-	lock_page_cgroup(page);
-	if (page_get_page_cgroup(page)) {
-		unlock_page_cgroup(page);
-		/*
-		 * Another charge has been added to this page already.
-		 * We take lock_page_cgroup(page) again and read
-		 * page->cgroup, increment refcnt.... just retry is OK.
-		 */
+	/*
+	 * We have to acquire 2 spinlocks.
+	 */
+	spin_lock_irqsave(&pc->lock, flags);
+	/* Is anyone charged ? */
+	if (unlikely(pc->refcnt)) {
+		/* Someone charged this page while we released the lock */
+		pc->refcnt++;
+		spin_unlock_irqrestore(&pc->lock, flags);
 		res_counter_uncharge(&mem->res, PAGE_SIZE);
 		css_put(&mem->css);
-		kfree(pc);
-		goto retry;
+		goto success;
 	}
-	page_assign_page_cgroup(page, pc);
+	/* Anyone doesn't touch this. */
+	VM_BUG_ON(pc->mem_cgroup);
+
+	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
+		pc->flags = PAGE_CGROUP_FLAG_ACTIVE | PAGE_CGROUP_FLAG_CACHE;
+	else
+		pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
+	pc->refcnt = 1;
+	pc->mem_cgroup = mem;
 
 	mz = page_cgroup_zoneinfo(pc);
-	spin_lock_irqsave(&mz->lru_lock, flags);
+
+	spin_lock(&mz->lru_lock);
 	__mem_cgroup_add_list(pc);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
+	spin_unlock(&mz->lru_lock);
+	spin_unlock_irqrestore(&pc->lock, flags);
 
-	unlock_page_cgroup(page);
-done:
+success:
 	return 0;
-out:
+nomem:
 	css_put(&mem->css);
-	kfree(pc);
-err:
 	return -ENOMEM;
 }
 
 int mem_cgroup_charge(struct page *page, struct mm_struct *mm, gfp_t gfp_mask)
 {
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_MAPPED);
+				MEM_CGROUP_CHARGE_TYPE_MAPPED, NULL);
 }
 
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
@@ -654,7 +596,7 @@ int mem_cgroup_cache_charge(struct page 
 	if (!mm)
 		mm = &init_mm;
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
-				MEM_CGROUP_CHARGE_TYPE_CACHE);
+				MEM_CGROUP_CHARGE_TYPE_CACHE, NULL);
 }
 
 /*
@@ -664,105 +606,83 @@ int mem_cgroup_cache_charge(struct page 
 void mem_cgroup_uncharge_page(struct page *page)
 {
 	struct page_cgroup *pc;
-	struct mem_cgroup *mem;
-	struct mem_cgroup_per_zone *mz;
-	unsigned long flags;
 
 	if (mem_cgroup_subsys.disabled)
 		return;
-
 	/*
 	 * Check if our page_cgroup is valid
 	 */
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
-	if (!pc)
-		goto unlock;
-
-	VM_BUG_ON(pc->page != page);
-	VM_BUG_ON(pc->ref_cnt <= 0);
+	pc = get_page_cgroup(page);
+	if (likely(pc)) {
+		unsigned long flags;
+		struct mem_cgroup *mem;
+		struct mem_cgroup_per_zone *mz;
 
-	if (--(pc->ref_cnt) == 0) {
+		spin_lock_irqsave(&pc->lock, flags);
+		if (!pc->refcnt || --pc->refcnt > 0) {
+			spin_unlock_irqrestore(&pc->lock, flags);
+			return;
+		}
+		mem = pc->mem_cgroup;
 		mz = page_cgroup_zoneinfo(pc);
-		spin_lock_irqsave(&mz->lru_lock, flags);
+		spin_lock(&mz->lru_lock);
 		__mem_cgroup_remove_list(pc);
-		spin_unlock_irqrestore(&mz->lru_lock, flags);
-
-		page_assign_page_cgroup(page, NULL);
-		unlock_page_cgroup(page);
+		spin_unlock(&mz->lru_lock);
+		pc->flags = 0;
+		pc->mem_cgroup = 0;
+		spin_unlock_irqrestore(&pc->lock, flags);
 
-		mem = pc->mem_cgroup;
 		res_counter_uncharge(&mem->res, PAGE_SIZE);
 		css_put(&mem->css);
-
-		kfree(pc);
-		return;
 	}
-
-unlock:
-	unlock_page_cgroup(page);
 }
 
 /*
- * Returns non-zero if a page (under migration) has valid page_cgroup member.
- * Refcnt of page_cgroup is incremented.
+ * Pre-charge against newpage while moving a page.
+ * This function is called before taking page locks.
  */
-int mem_cgroup_prepare_migration(struct page *page)
+int mem_cgroup_prepare_migration(struct page *page, struct page *newpage)
 {
 	struct page_cgroup *pc;
+	struct mem_cgroup *mem = NULL;
+	int ret = 0;
+	enum charge_type type = MEM_CGROUP_CHARGE_TYPE_MAPPED;
+	unsigned long flags;
 
 	if (mem_cgroup_subsys.disabled)
-		return 0;
+		return ret;
 
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
-	if (pc)
-		pc->ref_cnt++;
-	unlock_page_cgroup(page);
-	return pc != NULL;
-}
+	pc = get_page_cgroup(page);
 
-void mem_cgroup_end_migration(struct page *page)
-{
-	mem_cgroup_uncharge_page(page);
+	if (pc) {
+		spin_lock_irqsave(&pc->lock, flags);
+		if (pc->refcnt) {
+			mem = pc->mem_cgroup;
+			css_get(&mem->css);
+			if (pc->flags & PAGE_CGROUP_FLAG_CACHE)
+				type = MEM_CGROUP_CHARGE_TYPE_CACHE;
+			else
+				type = MEM_CGROUP_CHARGE_TYPE_MAPPED;
+		}
+		spin_unlock_irqrestore(&pc->lock, flags);
+		if (mem) {
+			ret = mem_cgroup_charge_common(newpage, NULL,
+				GFP_KERNEL, type, mem);
+			css_put(&mem->css);
+		}
+	}
+	return ret;
 }
-
 /*
- * We know both *page* and *newpage* are now not-on-LRU and PG_locked.
- * And no race with uncharge() routines because page_cgroup for *page*
- * has extra one reference by mem_cgroup_prepare_migration.
+ * At the end of migration, we'll push newpage to LRU and
+ * drop one refcnt which added at prepare_migration.
  */
-void mem_cgroup_page_migration(struct page *page, struct page *newpage)
+void mem_cgroup_end_migration(struct page *newpage)
 {
-	struct page_cgroup *pc;
-	struct mem_cgroup_per_zone *mz;
-	unsigned long flags;
-
-	lock_page_cgroup(page);
-	pc = page_get_page_cgroup(page);
-	if (!pc) {
-		unlock_page_cgroup(page);
+	if (mem_cgroup_subsys.disabled)
 		return;
-	}
 
-	mz = page_cgroup_zoneinfo(pc);
-	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_remove_list(pc);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
-
-	page_assign_page_cgroup(page, NULL);
-	unlock_page_cgroup(page);
-
-	pc->page = newpage;
-	lock_page_cgroup(newpage);
-	page_assign_page_cgroup(newpage, pc);
-
-	mz = page_cgroup_zoneinfo(pc);
-	spin_lock_irqsave(&mz->lru_lock, flags);
-	__mem_cgroup_add_list(pc);
-	spin_unlock_irqrestore(&mz->lru_lock, flags);
-
-	unlock_page_cgroup(newpage);
+	mem_cgroup_uncharge_page(newpage);
 }
 
 /*
@@ -790,10 +710,13 @@ static void mem_cgroup_force_empty_list(
 	while (!list_empty(list)) {
 		pc = list_entry(list->prev, struct page_cgroup, lru);
 		page = pc->page;
-		get_page(page);
-		spin_unlock_irqrestore(&mz->lru_lock, flags);
-		mem_cgroup_uncharge_page(page);
-		put_page(page);
+		if (PageLRU(page)) {
+			get_page(page);
+			spin_unlock_irqrestore(&mz->lru_lock, flags);
+			mem_cgroup_uncharge_page(page);
+			put_page(page);
+		} else
+			count = 0;
 		if (--count <= 0) {
 			count = FORCE_UNCHARGE_BATCH;
 			cond_resched();
Index: mm-2.6.25-rc5-mm1-k/include/linux/memcontrol.h
===================================================================
--- mm-2.6.25-rc5-mm1-k.orig/include/linux/memcontrol.h
+++ mm-2.6.25-rc5-mm1-k/include/linux/memcontrol.h
@@ -19,6 +19,7 @@
 
 #ifndef _LINUX_MEMCONTROL_H
 #define _LINUX_MEMCONTROL_H
+#include <linux/page_cgroup.h>
 
 struct mem_cgroup;
 struct page_cgroup;
@@ -30,9 +31,6 @@ struct mm_struct;
 extern void mm_init_cgroup(struct mm_struct *mm, struct task_struct *p);
 extern void mm_free_cgroup(struct mm_struct *mm);
 
-#define page_reset_bad_cgroup(page)	((page)->page_cgroup = 0)
-
-extern struct page_cgroup *page_get_page_cgroup(struct page *page);
 extern int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
@@ -51,9 +49,8 @@ int task_in_mem_cgroup(struct task_struc
 #define mm_match_cgroup(mm, cgroup)	\
 	((cgroup) == rcu_dereference((mm)->mem_cgroup))
 
-extern int mem_cgroup_prepare_migration(struct page *page);
-extern void mem_cgroup_end_migration(struct page *page);
-extern void mem_cgroup_page_migration(struct page *page, struct page *newpage);
+extern int mem_cgroup_prepare_migration(struct page *, struct page *);
+extern void mem_cgroup_end_migration(struct page *);
 
 /*
  * For memory reclaim.
@@ -82,14 +79,6 @@ static inline void mm_free_cgroup(struct
 {
 }
 
-static inline void page_reset_bad_cgroup(struct page *page)
-{
-}
-
-static inline struct page_cgroup *page_get_page_cgroup(struct page *page)
-{
-	return NULL;
-}
 
 static inline int mem_cgroup_charge(struct page *page,
 					struct mm_struct *mm, gfp_t gfp_mask)
@@ -122,7 +111,8 @@ static inline int task_in_mem_cgroup(str
 	return 1;
 }
 
-static inline int mem_cgroup_prepare_migration(struct page *page)
+static inline int
+mem_cgroup_prepare_migration(struct page *page , struct page *newpage)
 {
 	return 0;
 }
Index: mm-2.6.25-rc5-mm1-k/mm/page_alloc.c
===================================================================
--- mm-2.6.25-rc5-mm1-k.orig/mm/page_alloc.c
+++ mm-2.6.25-rc5-mm1-k/mm/page_alloc.c
@@ -222,17 +222,11 @@ static inline int bad_range(struct zone 
 
 static void bad_page(struct page *page)
 {
-	void *pc = page_get_page_cgroup(page);
-
 	printk(KERN_EMERG "Bad page state in process '%s'\n" KERN_EMERG
 		"page:%p flags:0x%0*lx mapping:%p mapcount:%d count:%d\n",
 		current->comm, page, (int)(2*sizeof(unsigned long)),
 		(unsigned long)page->flags, page->mapping,
 		page_mapcount(page), page_count(page));
-	if (pc) {
-		printk(KERN_EMERG "cgroup:%p\n", pc);
-		page_reset_bad_cgroup(page);
-	}
 	printk(KERN_EMERG "Trying to fix it up, but a reboot is needed\n"
 		KERN_EMERG "Backtrace:\n");
 	dump_stack();
@@ -478,7 +472,6 @@ static inline int free_pages_check(struc
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
-		(page_get_page_cgroup(page) != NULL) |
 		(page_count(page) != 0)  |
 		(page->flags & (
 			1 << PG_lru	|
@@ -628,7 +621,6 @@ static int prep_new_page(struct page *pa
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
-		(page_get_page_cgroup(page) != NULL) |
 		(page_count(page) != 0)  |
 		(page->flags & (
 			1 << PG_lru	|
Index: mm-2.6.25-rc5-mm1-k/include/linux/mm_types.h
===================================================================
--- mm-2.6.25-rc5-mm1-k.orig/include/linux/mm_types.h
+++ mm-2.6.25-rc5-mm1-k/include/linux/mm_types.h
@@ -88,9 +88,6 @@ struct page {
 	void *virtual;			/* Kernel virtual address (NULL if
 					   not kmapped, ie. highmem) */
 #endif /* WANT_PAGE_VIRTUAL */
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
-	unsigned long page_cgroup;
-#endif
 #ifdef CONFIG_PAGE_OWNER
 	int order;
 	unsigned int gfp_mask;
Index: mm-2.6.25-rc5-mm1-k/mm/migrate.c
===================================================================
--- mm-2.6.25-rc5-mm1-k.orig/mm/migrate.c
+++ mm-2.6.25-rc5-mm1-k/mm/migrate.c
@@ -358,6 +358,12 @@ static int migrate_page_move_mapping(str
 
 	write_unlock_irq(&mapping->tree_lock);
 
+	/* by mem_cgroup_prepare_migration, newpage is already
+	   assigned to valid cgroup. and current->mm and GFP_ATOMIC
+	   will not be used...*/
+	mem_cgroup_uncharge_page(page);
+	mem_cgroup_cache_charge(newpage, current->mm, GFP_ATOMIC);
+
 	return 0;
 }
 
@@ -603,7 +609,6 @@ static int move_to_new_page(struct page 
 		rc = fallback_migrate_page(mapping, newpage, page);
 
 	if (!rc) {
-		mem_cgroup_page_migration(page, newpage);
 		remove_migration_ptes(page, newpage);
 	} else
 		newpage->mapping = NULL;
@@ -633,6 +638,12 @@ static int unmap_and_move(new_page_t get
 		/* page was freed from under us. So we are done. */
 		goto move_newpage;
 
+	charge = mem_cgroup_prepare_migration(page, newpage);
+	if (charge == -ENOMEM) {
+		rc = -ENOMEM;
+		goto move_newpage;
+	}
+
 	rc = -EAGAIN;
 	if (TestSetPageLocked(page)) {
 		if (!force)
@@ -684,19 +695,14 @@ static int unmap_and_move(new_page_t get
 		goto rcu_unlock;
 	}
 
-	charge = mem_cgroup_prepare_migration(page);
 	/* Establish migration ptes or remove ptes */
 	try_to_unmap(page, 1);
 
 	if (!page_mapped(page))
 		rc = move_to_new_page(newpage, page);
 
-	if (rc) {
+	if (rc)
 		remove_migration_ptes(page, page);
-		if (charge)
-			mem_cgroup_end_migration(page);
-	} else if (charge)
- 		mem_cgroup_end_migration(newpage);
 rcu_unlock:
 	if (rcu_locked)
 		rcu_read_unlock();
@@ -717,6 +723,8 @@ unlock:
 	}
 
 move_newpage:
+	if (!charge)
+		mem_cgroup_end_migration(newpage);
 	/*
 	 * Move the new page to the LRU. If migration was not successful
 	 * then this will free the page.
Index: mm-2.6.25-rc5-mm1-k/mm/page_cgroup.c
===================================================================
--- /dev/null
+++ mm-2.6.25-rc5-mm1-k/mm/page_cgroup.c
@@ -0,0 +1,259 @@
+/*
+ * per-page accounting subsystem infrastructure. - linux/mm/page_cgroup.c
+ *
+ * (C) 2008 FUJITSU, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * page_cgroup is yet another mem_map under memory resoruce controller.
+ * It containes information which cannot be stored in usual mem_map.
+ * This allows us to keep 'struct page' small when a user doesn't activate
+ * memory resource controller.
+ *
+ * We can translate : struct page <-> pfn -> page_cgroup -> struct page.
+ *
+ */
+
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/radix-tree.h>
+#include <linux/memcontrol.h>
+#include <linux/err.h>
+
+static int page_cgroup_order __read_mostly;
+static int page_cgroup_head_size __read_mostly;
+
+#define PCGRP_SHIFT	(page_cgroup_order)
+#define PCGRP_SIZE	(1 << PCGRP_SHIFT)
+#define PCGRP_MASK	(PCGRP_SIZE - 1)
+
+struct page_cgroup_head {
+	struct page_cgroup pc[0];
+};
+
+struct page_cgroup_root {
+	spinlock_t	       tree_lock;
+	struct radix_tree_root root_node;
+};
+
+/*
+ * Calculate page_cgroup order to be not larger than order-2 page allocation.
+ */
+static void calc_page_cgroup_order(void)
+{
+	int order = pageblock_order;
+	unsigned long size = sizeof(struct page_cgroup) << order;
+
+	while (size > PAGE_SIZE * 2) {
+		order -= 1;
+		size = sizeof(struct page_cgroup) << order;
+	}
+
+	page_cgroup_order = order;
+	page_cgroup_head_size = sizeof(struct page_cgroup_head) +
+				(sizeof(struct page_cgroup) << order);
+}
+
+static struct page_cgroup_root __initdata *tmp_root_dir[MAX_NUMNODES];
+static struct page_cgroup_root *root_node[MAX_NUMNODES] __read_mostly;
+
+static void
+init_page_cgroup_head(struct page_cgroup_head *head, unsigned long pfn)
+{
+	struct page *page;
+	struct page_cgroup *pc;
+	int i;
+
+	for (i = 0, page = pfn_to_page(pfn), pc = &head->pc[0];
+	     i < PCGRP_SIZE; i++, page++, pc++) {
+		pc->refcnt = 0;
+		pc->page = page;
+		spin_lock_init(&pc->lock);
+	}
+}
+
+
+struct kmem_cache *page_cgroup_cachep;
+
+static struct page_cgroup_head *
+alloc_page_cgroup_head(unsigned long pfn, int nid, gfp_t mask)
+{
+	struct page_cgroup_head *head;
+
+	if (!node_state(nid, N_NORMAL_MEMORY))
+		nid = -1;
+	head = kmem_cache_alloc_node(page_cgroup_cachep, mask, nid);
+	if (head)
+		init_page_cgroup_head(head, pfn);
+
+	return head;
+}
+
+void free_page_cgroup(struct page_cgroup_head *head)
+{
+	kmem_cache_free(page_cgroup_cachep, head);
+}
+
+static struct page_cgroup_root *pcgroup_get_root(struct page *page)
+{
+	int nid;
+
+	VM_BUG_ON(!page);
+
+	nid = page_to_nid(page);
+
+	return root_node[nid];
+}
+
+/**
+ * get_page_cgroup - look up a page_cgroup for a page
+ * @page: the page whose page_cgroup is looked up.
+ *
+ * This just does lookup.
+ */
+struct page_cgroup *get_page_cgroup(struct page *page)
+{
+	struct page_cgroup_head *head;
+	struct page_cgroup_root *root;
+	struct page_cgroup *ret = NULL;
+	unsigned long pfn, idx;
+
+	/*
+	 * NULL can be returned before initialization
+	 */
+	root = pcgroup_get_root(page);
+	if (unlikely(!root))
+		return ret;
+
+	pfn = page_to_pfn(page);
+	idx = pfn >> PCGRP_SHIFT;
+	/*
+	 * We don't need lock here because no one deletes this head.
+	 * (Freeing routtine will be added later.)
+	 */
+	rcu_read_lock();
+	head = radix_tree_lookup(&root->root_node, idx);
+	rcu_read_unlock();
+
+	if (likely(head))
+		ret = &head->pc[pfn & PCGRP_MASK];
+
+	return ret;
+}
+
+/**
+ * get_alloc_page_cgroup - look up or allocate a page_cgroup for a page
+ * @page: the page whose page_cgroup is looked up.
+ * @gfpmask: the gfpmask which will be used for page allocatiopn.
+ *
+ * look up and allocate if not found.
+ */
+
+struct page_cgroup *
+get_alloc_page_cgroup(struct page *page, gfp_t gfpmask)
+{
+	struct page_cgroup_root *root;
+	struct page_cgroup_head *head;
+	struct page_cgroup *pc;
+	unsigned long pfn, idx;
+	int nid;
+	unsigned long base_pfn, flags;
+	int error = 0;
+
+	might_sleep_if(gfpmask & __GFP_WAIT);
+
+retry:
+	pc = get_page_cgroup(page);
+	if (pc)
+		return pc;
+	/*
+	 * NULL can be returned before initialization.
+	 */
+	root = pcgroup_get_root(page);
+	if (unlikely(!root))
+		return ERR_PTR(-EBUSY);
+
+	pfn = page_to_pfn(page);
+	idx = pfn >> PCGRP_SHIFT;
+	nid = page_to_nid(page);
+	base_pfn = idx << PCGRP_SHIFT;
+
+	gfpmask = gfpmask & ~(__GFP_HIGHMEM | __GFP_MOVABLE);
+
+	head = alloc_page_cgroup_head(base_pfn, nid, gfpmask);
+	if (!head)
+		return ERR_PTR(-ENOMEM);
+
+	pc = &head->pc[pfn & PCGRP_MASK];
+
+	error = radix_tree_preload(gfpmask);
+	if (error)
+		goto out;
+	spin_lock_irqsave(&root->tree_lock, flags);
+	error = radix_tree_insert(&root->root_node, idx, head);
+	spin_unlock_irqrestore(&root->tree_lock, flags);
+	radix_tree_preload_end();
+out:
+	if (error) {
+		free_page_cgroup(head);
+		if (error == -EEXIST)
+			goto retry;
+		pc = ERR_PTR(error);
+	}
+	return pc;
+}
+
+static int __init page_cgroup_init(void)
+{
+	int tmp, nid;
+	struct page_cgroup_root *root;
+
+	calc_page_cgroup_order();
+
+	page_cgroup_cachep = kmem_cache_create("page_cgroup",
+				page_cgroup_head_size, 0,
+				SLAB_PANIC | SLAB_DESTROY_BY_RCU, NULL);
+
+	if (!page_cgroup_cachep) {
+		printk(KERN_ERR "page accouning setup failure\n");
+		return -ENOMEM;
+	}
+
+	for_each_node(nid) {
+		tmp = nid;
+		if (!node_state(nid, N_NORMAL_MEMORY))
+			tmp = -1;
+		root = kmalloc_node(sizeof(struct page_cgroup_root),
+					GFP_KERNEL, tmp);
+		if (!root)
+			goto unroll;
+		INIT_RADIX_TREE(&root->root_node, GFP_ATOMIC);
+		spin_lock_init(&root->tree_lock);
+		tmp_root_dir[nid] = root;
+	}
+	/*
+	 * By filling node_root[], this tree turns to be visible.
+	 * Because we have to finish initialization of the tree before
+	 * we make it visible, memory barrier is necessary.
+	 */
+	smp_wmb();
+	for_each_node(nid)
+		root_node[nid] = tmp_root_dir[nid];
+
+	printk(KERN_INFO "Page Accounting is activated\n");
+	return 0;
+unroll:
+	for_each_node(nid)
+		kfree(tmp_root_dir[nid]);
+
+	return -ENOMEM;
+}
+late_initcall(page_cgroup_init);
Index: mm-2.6.25-rc5-mm1-k/mm/Makefile
===================================================================
--- mm-2.6.25-rc5-mm1-k.orig/mm/Makefile
+++ mm-2.6.25-rc5-mm1-k/mm/Makefile
@@ -32,5 +32,5 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
-obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
+obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
