Date: Thu, 11 Sep 2008 20:13:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] [PATCH 2/9]  memcg: atomic page_cgroup flags
Message-Id: <20080911201347.431a6c23.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080911200855.94d33d3b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080911200855.94d33d3b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "xemul@openvz.org" <xemul@openvz.org>, "hugh@veritas.com" <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, menage@google.com
List-ID: <linux-mm.kvack.org>

This patch makes page_cgroup->flags to be atomic_ops and define
functions (and macros) to access it.

This patch itself makes memcg slow but this patch's final purpose is 
to remove lock_page_cgroup() (in some situation) and allowing fast
access (and no-dead-lock access) to page_cgroup.

Changelog:  (v2) -> (v3)
 - renamed macros and flags to be longer name.
 - added comments.
 - added "default bit set" for File, Shmem, Anon.

Changelog:  (preview) -> (v1):
 - patch ordering is changed.
 - Added macro for defining functions for Test/Set/Clear bit.
 - made the names of flags shorter.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |  114 ++++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 82 insertions(+), 32 deletions(-)

Index: mmtom-2.6.27-rc5+/mm/memcontrol.c
===================================================================
--- mmtom-2.6.27-rc5+.orig/mm/memcontrol.c
+++ mmtom-2.6.27-rc5+/mm/memcontrol.c
@@ -161,12 +161,60 @@ struct page_cgroup {
 	struct list_head lru;		/* per cgroup LRU list */
 	struct page *page;
 	struct mem_cgroup *mem_cgroup;
-	int flags;
+	unsigned long flags;
 };
-#define PAGE_CGROUP_FLAG_CACHE	   (0x1)	/* charged as cache */
-#define PAGE_CGROUP_FLAG_ACTIVE    (0x2)	/* page is active in this cgroup */
-#define PAGE_CGROUP_FLAG_FILE	   (0x4)	/* page is file system backed */
-#define PAGE_CGROUP_FLAG_UNEVICTABLE (0x8)	/* page is unevictableable */
+
+enum {
+	/* flags for mem_cgroup */
+	PCG_CACHE, /* charged as cache */
+	/* flags for LRU placement */
+	PCG_ACTIVE, /* page is active in this cgroup */
+	PCG_FILE, /* page is file system backed */
+	PCG_UNEVICTABLE, /* page is unevictableable */
+};
+
+#define TESTPCGFLAG(uname, lname)			\
+static inline int PageCgroup##uname(struct page_cgroup *pc)	\
+	{ return test_bit(PCG_##lname, &pc->flags); }
+
+#define SETPCGFLAG(uname, lname)			\
+static inline void SetPageCgroup##uname(struct page_cgroup *pc)\
+	{ set_bit(PCG_##lname, &pc->flags);  }
+
+#define CLEARPCGFLAG(uname, lname)			\
+static inline void ClearPageCgroup##uname(struct page_cgroup *pc)	\
+	{ clear_bit(PCG_##lname, &pc->flags);  }
+
+#define __SETPCGFLAG(uname, lname)			\
+static inline void __SetPageCgroup##uname(struct page_cgroup *pc)\
+	{ __set_bit(PCG_##lname, &pc->flags);  }
+
+#define __CLEARPCGFLAG(uname, lname)			\
+static inline void __ClearPageCgroup##uname(struct page_cgroup *pc)	\
+	{ __clear_bit(PCG_##lname, &pc->flags);  }
+
+/* Cache flag is set only once (at allocation) */
+TESTPCGFLAG(Cache, CACHE)
+__SETPCGFLAG(Cache, CACHE)
+
+/* LRU management flags (from global-lru definition) */
+TESTPCGFLAG(File, FILE)
+SETPCGFLAG(File, FILE)
+__SETPCGFLAG(File, FILE)
+CLEARPCGFLAG(File, FILE)
+
+TESTPCGFLAG(Active, ACTIVE)
+SETPCGFLAG(Active, ACTIVE)
+__SETPCGFLAG(Active, ACTIVE)
+CLEARPCGFLAG(Active, ACTIVE)
+
+TESTPCGFLAG(Unevictable, UNEVICTABLE)
+SETPCGFLAG(Unevictable, UNEVICTABLE)
+CLEARPCGFLAG(Unevictable, UNEVICTABLE)
+
+#define PcgDefaultAnonFlag	((1 << PCG_ACTIVE))
+#define PcgDefaultFileFlag	((1 << PCG_CACHE) | (1 << PCG_FILE))
+#define PcgDefaultShmemFlag	((1 << PCG_CACHE) | (1 << PCG_ACTIVE))
 
 static int page_cgroup_nid(struct page_cgroup *pc)
 {
@@ -187,14 +235,15 @@ enum charge_type {
 /*
  * Always modified under lru lock. Then, not necessary to preempt_disable()
  */
-static void mem_cgroup_charge_statistics(struct mem_cgroup *mem, int flags,
-					bool charge)
+static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
+					 struct page_cgroup *pc,
+					 bool charge)
 {
 	int val = (charge)? 1 : -1;
 	struct mem_cgroup_stat *stat = &mem->stat;
 
 	VM_BUG_ON(!irqs_disabled());
-	if (flags & PAGE_CGROUP_FLAG_CACHE)
+	if (PageCgroupCache(pc))
 		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_CACHE, val);
 	else
 		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_RSS, val);
@@ -295,18 +344,18 @@ static void __mem_cgroup_remove_list(str
 {
 	int lru = LRU_BASE;
 
-	if (pc->flags & PAGE_CGROUP_FLAG_UNEVICTABLE)
+	if (PageCgroupUnevictable(pc))
 		lru = LRU_UNEVICTABLE;
 	else {
-		if (pc->flags & PAGE_CGROUP_FLAG_ACTIVE)
+		if (PageCgroupActive(pc))
 			lru += LRU_ACTIVE;
-		if (pc->flags & PAGE_CGROUP_FLAG_FILE)
+		if (PageCgroupFile(pc))
 			lru += LRU_FILE;
 	}
 
 	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
 
-	mem_cgroup_charge_statistics(pc->mem_cgroup, pc->flags, false);
+	mem_cgroup_charge_statistics(pc->mem_cgroup, pc, false);
 	list_del(&pc->lru);
 }
 
@@ -315,27 +364,27 @@ static void __mem_cgroup_add_list(struct
 {
 	int lru = LRU_BASE;
 
-	if (pc->flags & PAGE_CGROUP_FLAG_UNEVICTABLE)
+	if (PageCgroupUnevictable(pc))
 		lru = LRU_UNEVICTABLE;
 	else {
-		if (pc->flags & PAGE_CGROUP_FLAG_ACTIVE)
+		if (PageCgroupActive(pc))
 			lru += LRU_ACTIVE;
-		if (pc->flags & PAGE_CGROUP_FLAG_FILE)
+		if (PageCgroupFile(pc))
 			lru += LRU_FILE;
 	}
 
 	MEM_CGROUP_ZSTAT(mz, lru) += 1;
 	list_add(&pc->lru, &mz->lists[lru]);
 
-	mem_cgroup_charge_statistics(pc->mem_cgroup, pc->flags, true);
+	mem_cgroup_charge_statistics(pc->mem_cgroup, pc, true);
 }
 
 static void __mem_cgroup_move_lists(struct page_cgroup *pc, enum lru_list lru)
 {
 	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
-	int active    = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
-	int file      = pc->flags & PAGE_CGROUP_FLAG_FILE;
-	int unevictable = pc->flags & PAGE_CGROUP_FLAG_UNEVICTABLE;
+	int active    = PageCgroupActive(pc);
+	int file      = PageCgroupFile(pc);
+	int unevictable = PageCgroupUnevictable(pc);
 	enum lru_list from = unevictable ? LRU_UNEVICTABLE :
 				(LRU_FILE * !!file + !!active);
 
@@ -343,16 +392,20 @@ static void __mem_cgroup_move_lists(stru
 		return;
 
 	MEM_CGROUP_ZSTAT(mz, from) -= 1;
-
+	/*
+	 * However this is done under mz->lru_lock, another flags, which
+	 * are not related to LRU, will be modified from out-of-lock.
+	 * We have to use atomic set/clear flags.
+	 */
 	if (is_unevictable_lru(lru)) {
-		pc->flags &= ~PAGE_CGROUP_FLAG_ACTIVE;
-		pc->flags |= PAGE_CGROUP_FLAG_UNEVICTABLE;
+		ClearPageCgroupActive(pc);
+		SetPageCgroupUnevictable(pc);
 	} else {
 		if (is_active_lru(lru))
-			pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
+			SetPageCgroupActive(pc);
 		else
-			pc->flags &= ~PAGE_CGROUP_FLAG_ACTIVE;
-		pc->flags &= ~PAGE_CGROUP_FLAG_UNEVICTABLE;
+			ClearPageCgroupActive(pc);
+		ClearPageCgroupUnevictable(pc);
 	}
 
 	MEM_CGROUP_ZSTAT(mz, lru) += 1;
@@ -585,18 +638,20 @@ static int mem_cgroup_charge_common(stru
 
 	pc->mem_cgroup = mem;
 	pc->page = page;
-	/*
-	 * If a page is accounted as a page cache, insert to inactive list.
-	 * If anon, insert to active list.
-	 */
-	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE) {
-		pc->flags = PAGE_CGROUP_FLAG_CACHE;
+
+	switch (ctype) {
+	case MEM_CGROUP_CHARGE_TYPE_CACHE:
 		if (page_is_file_cache(page))
-			pc->flags |= PAGE_CGROUP_FLAG_FILE;
+			pc->flags = PcgDefaultFileFlag;
 		else
-			pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
-	} else
-		pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
+			pc->flags = PcgDefaultShmemFlag;
+		break;
+	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
+		pc->flags = PcgDefaultAnonFlag;
+		break;
+	default:
+		BUG();
+	}
 
 	lock_page_cgroup(page);
 	if (unlikely(page_get_page_cgroup(page))) {
@@ -704,8 +759,7 @@ __mem_cgroup_uncharge_common(struct page
 	VM_BUG_ON(pc->page != page);
 
 	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
-	    && ((pc->flags & PAGE_CGROUP_FLAG_CACHE)
-		|| page_mapped(page)))
+	    && ((PageCgroupCache(pc) || page_mapped(page))))
 		goto unlock;
 
 	mz = page_cgroup_zoneinfo(pc);
@@ -755,7 +809,7 @@ int mem_cgroup_prepare_migration(struct 
 	if (pc) {
 		mem = pc->mem_cgroup;
 		css_get(&mem->css);
-		if (pc->flags & PAGE_CGROUP_FLAG_CACHE)
+		if (PageCgroupCache(pc))
 			ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
 	}
 	unlock_page_cgroup(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
