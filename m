Date: Wed, 20 Aug 2008 18:55:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH -mm 1/7] memcg: page_cgroup_atomic_flags.patch
Message-Id: <20080820185530.50056b5a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080820185306.e897c512.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080819173014.17358c17.kamezawa.hiroyu@jp.fujitsu.com>
	<20080820185306.e897c512.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, ryov@valinux.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This patch makes page_cgroup->flags to be atomic_ops and define
functions (and macros) to access it.

This patch itself makes memcg slow but this patch's final purpose is 
to remove lock_page_cgroup() and allowing fast/easy access to page_cgroup.

Before trying to modify memory resource controller, this atomic operation
on flags is necessary.

Changelog  (preview) -> (v1):
 - patch ordering is changed.
 - Added macro for defining functions for Test/Set/Clear bit.
 - made the names of flags shorter.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |  108 +++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 77 insertions(+), 31 deletions(-)

Index: mmtom-2.6.27-rc3+/mm/memcontrol.c
===================================================================
--- mmtom-2.6.27-rc3+.orig/mm/memcontrol.c
+++ mmtom-2.6.27-rc3+/mm/memcontrol.c
@@ -158,12 +158,57 @@ struct page_cgroup {
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
+	Pcg_CACHE, /* charged as cache */
+	/* flags for LRU placement */
+	Pcg_ACTIVE, /* page is active in this cgroup */
+	Pcg_FILE, /* page is file system backed */
+	Pcg_UNEVICTABLE, /* page is unevictableable */
+};
+
+#define TESTPCGFLAG(uname, lname)			\
+static inline int Pcg##uname(struct page_cgroup *pc)	\
+	{ return test_bit(Pcg_##lname, &pc->flags); }
+
+#define SETPCGFLAG(uname, lname)			\
+static inline void SetPcg##uname(struct page_cgroup *pc)\
+	{ set_bit(Pcg_##lname, &pc->flags);  }
+
+#define CLEARPCGFLAG(uname, lname)			\
+static inline void ClearPcg##uname(struct page_cgroup *pc)	\
+	{ clear_bit(Pcg_##lname, &pc->flags);  }
+
+#define __SETPCGFLAG(uname, lname)			\
+static inline void __SetPcg##uname(struct page_cgroup *pc)\
+	{ __set_bit(Pcg_##lname, &pc->flags);  }
+
+#define __CLEARPCGFLAG(uname, lname)			\
+static inline void __ClearPcg##uname(struct page_cgroup *pc)	\
+	{ __clear_bit(Pcg_##lname, &pc->flags);  }
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
 
 static int page_cgroup_nid(struct page_cgroup *pc)
 {
@@ -184,14 +229,15 @@ enum charge_type {
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
+	if (PcgCache(pc))
 		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_CACHE, val);
 	else
 		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_RSS, val);
@@ -284,18 +330,18 @@ static void __mem_cgroup_remove_list(str
 {
 	int lru = LRU_BASE;
 
-	if (pc->flags & PAGE_CGROUP_FLAG_UNEVICTABLE)
+	if (PcgUnevictable(pc))
 		lru = LRU_UNEVICTABLE;
 	else {
-		if (pc->flags & PAGE_CGROUP_FLAG_ACTIVE)
+		if (PcgActive(pc))
 			lru += LRU_ACTIVE;
-		if (pc->flags & PAGE_CGROUP_FLAG_FILE)
+		if (PcgFile(pc))
 			lru += LRU_FILE;
 	}
 
 	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
 
-	mem_cgroup_charge_statistics(pc->mem_cgroup, pc->flags, false);
+	mem_cgroup_charge_statistics(pc->mem_cgroup, pc, false);
 	list_del(&pc->lru);
 }
 
@@ -304,27 +350,27 @@ static void __mem_cgroup_add_list(struct
 {
 	int lru = LRU_BASE;
 
-	if (pc->flags & PAGE_CGROUP_FLAG_UNEVICTABLE)
+	if (PcgUnevictable(pc))
 		lru = LRU_UNEVICTABLE;
 	else {
-		if (pc->flags & PAGE_CGROUP_FLAG_ACTIVE)
+		if (PcgActive(pc))
 			lru += LRU_ACTIVE;
-		if (pc->flags & PAGE_CGROUP_FLAG_FILE)
+		if (PcgFile(pc))
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
+	int active    = PcgActive(pc);
+	int file      = PcgFile(pc);
+	int unevictable = PcgUnevictable(pc);
 	enum lru_list from = unevictable ? LRU_UNEVICTABLE :
 				(LRU_FILE * !!file + !!active);
 
@@ -334,14 +380,14 @@ static void __mem_cgroup_move_lists(stru
 	MEM_CGROUP_ZSTAT(mz, from) -= 1;
 
 	if (is_unevictable_lru(lru)) {
-		pc->flags &= ~PAGE_CGROUP_FLAG_ACTIVE;
-		pc->flags |= PAGE_CGROUP_FLAG_UNEVICTABLE;
+		ClearPcgActive(pc);
+		SetPcgUnevictable(pc);
 	} else {
 		if (is_active_lru(lru))
-			pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
+			SetPcgActive(pc);
 		else
-			pc->flags &= ~PAGE_CGROUP_FLAG_ACTIVE;
-		pc->flags &= ~PAGE_CGROUP_FLAG_UNEVICTABLE;
+			ClearPcgActive(pc);
+		ClearPcgUnevictable(pc);
 	}
 
 	MEM_CGROUP_ZSTAT(mz, lru) += 1;
@@ -569,18 +615,19 @@ static int mem_cgroup_charge_common(stru
 
 	pc->mem_cgroup = mem;
 	pc->page = page;
+	pc->flags = 0;
 	/*
 	 * If a page is accounted as a page cache, insert to inactive list.
 	 * If anon, insert to active list.
 	 */
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE) {
-		pc->flags = PAGE_CGROUP_FLAG_CACHE;
+		__SetPcgCache(pc);
 		if (page_is_file_cache(page))
-			pc->flags |= PAGE_CGROUP_FLAG_FILE;
+			__SetPcgFile(pc);
 		else
-			pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
+			__SetPcgActive(pc);
 	} else
-		pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
+		__SetPcgActive(pc);
 
 	lock_page_cgroup(page);
 	if (unlikely(page_get_page_cgroup(page))) {
@@ -688,8 +735,7 @@ __mem_cgroup_uncharge_common(struct page
 	VM_BUG_ON(pc->page != page);
 
 	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
-	    && ((pc->flags & PAGE_CGROUP_FLAG_CACHE)
-		|| page_mapped(page)))
+	    && ((PcgCache(pc) || page_mapped(page))))
 		goto unlock;
 
 	mz = page_cgroup_zoneinfo(pc);
@@ -739,7 +785,7 @@ int mem_cgroup_prepare_migration(struct 
 	if (pc) {
 		mem = pc->mem_cgroup;
 		css_get(&mem->css);
-		if (pc->flags & PAGE_CGROUP_FLAG_CACHE)
+		if (PcgCache(pc))
 			ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
 	}
 	unlock_page_cgroup(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
