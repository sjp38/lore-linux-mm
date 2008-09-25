From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 5/12] memcg make page_cgroup->flags atomic
Date: Thu, 25 Sep 2008 15:17:34 +0900
Message-ID: <20080925151734.5b24d494.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755450AbYIYGLv@vger.kernel.org>
In-Reply-To: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-Id: linux-mm.kvack.org

This patch makes page_cgroup->flags to be atomic_ops and define
functions (and macros) to access it.

This patch itself makes memcg slow but this patch's final purpose is 
to remove lock_page_cgroup() and allowing fast access to page_cgroup.
(And total performance will increase after all patches applied.)

Before trying to modify memory resource controller, this atomic operation
on flags is necessary. Most of flags in this patch is for LRU and modfied
under mz->lru_lock but we'll add another flags which is not for LRU soon.
So we use atomic version here.

 
Changelog: (v4) -> (v5)
 - removed unsued operations.
 - adjusted to new ctype MEM_CGROUP_CHARGE_TYPE_SHMEM

Changelog: (v3) -> (v4)
 - no changes.

Changelog:  (v2) -> (v3)
 - renamed macros and flags to be longer name.
 - added comments.
 - added "default bit set" for File, Shmem, Anon.

Changelog:  (preview) -> (v1):
 - patch ordering is changed.
 - Added macro for defining functions for Test/Set/Clear bit.
 - made the names of flags shorter.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/memcontrol.c |  122 +++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 82 insertions(+), 40 deletions(-)

Index: mmotm-2.6.27-rc7+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.27-rc7+.orig/mm/memcontrol.c
+++ mmotm-2.6.27-rc7+/mm/memcontrol.c
@@ -161,12 +161,46 @@ struct page_cgroup {
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
+
+/* Cache flag is set only once (at allocation) */
+TESTPCGFLAG(Cache, CACHE)
+
+/* LRU management flags (from global-lru definition) */
+TESTPCGFLAG(File, FILE)
+SETPCGFLAG(File, FILE)
+CLEARPCGFLAG(File, FILE)
+
+TESTPCGFLAG(Active, ACTIVE)
+SETPCGFLAG(Active, ACTIVE)
+CLEARPCGFLAG(Active, ACTIVE)
+
+TESTPCGFLAG(Unevictable, UNEVICTABLE)
+SETPCGFLAG(Unevictable, UNEVICTABLE)
+CLEARPCGFLAG(Unevictable, UNEVICTABLE)
 
 static int page_cgroup_nid(struct page_cgroup *pc)
 {
@@ -181,21 +215,31 @@ static enum zone_type page_cgroup_zid(st
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
 	MEM_CGROUP_CHARGE_TYPE_MAPPED,
-	MEM_CGROUP_CHARGE_TYPE_FORCE,	/* used by force_empty */
 	MEM_CGROUP_CHARGE_TYPE_SHMEM,	/* used by page migration of shmem */
+	MEM_CGROUP_CHARGE_TYPE_FORCE,	/* used by force_empty */
+	NR_CHARGE_TYPE,
+};
+
+static const unsigned long
+pcg_default_flags[NR_CHARGE_TYPE] = {
+	((1 << PCG_CACHE) | (1 << PCG_FILE)),
+	((1 << PCG_ACTIVE)),
+	((1 << PCG_ACTIVE) | (1 << PCG_CACHE)),
+	0,
 };
 
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
@@ -296,18 +340,18 @@ static void __mem_cgroup_remove_list(str
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
 
@@ -316,27 +360,27 @@ static void __mem_cgroup_add_list(struct
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
 
@@ -344,16 +388,20 @@ static void __mem_cgroup_move_lists(stru
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
@@ -590,16 +638,7 @@ static int mem_cgroup_charge_common(stru
 	 * If a page is accounted as a page cache, insert to inactive list.
 	 * If anon, insert to active list.
 	 */
-	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE) {
-		pc->flags = PAGE_CGROUP_FLAG_CACHE;
-		if (page_is_file_cache(page))
-			pc->flags |= PAGE_CGROUP_FLAG_FILE;
-		else
-			pc->flags |= PAGE_CGROUP_FLAG_ACTIVE;
-	} else if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
-		pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
-	else /* MEM_CGROUP_CHARGE_TYPE_SHMEM */
-		pc->flags = PAGE_CGROUP_FLAG_CACHE | PAGE_CGROUP_FLAG_ACTIVE;
+	pc->flags = pcg_default_flags[ctype];
 
 	lock_page_cgroup(page);
 	if (unlikely(page_get_page_cgroup(page))) {
@@ -678,8 +717,12 @@ int mem_cgroup_cache_charge(struct page 
 	if (unlikely(!mm))
 		mm = &init_mm;
 
-	return mem_cgroup_charge_common(page, mm, gfp_mask,
+	if (page_is_file_cache(page))
+		return mem_cgroup_charge_common(page, mm, gfp_mask,
 				MEM_CGROUP_CHARGE_TYPE_CACHE, NULL);
+	else
+		return mem_cgroup_charge_common(page, mm, gfp_mask,
+				MEM_CGROUP_CHARGE_TYPE_SHMEM, NULL);
 }
 
 /*
@@ -707,8 +750,7 @@ __mem_cgroup_uncharge_common(struct page
 	VM_BUG_ON(pc->page != page);
 
 	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
-	    && ((pc->flags & PAGE_CGROUP_FLAG_CACHE)
-		|| page_mapped(page)))
+	    && ((PageCgroupCache(pc) || page_mapped(page))))
 		goto unlock;
 
 	mz = page_cgroup_zoneinfo(pc);
@@ -759,7 +801,7 @@ int mem_cgroup_prepare_migration(struct 
 	if (pc) {
 		mem = pc->mem_cgroup;
 		css_get(&mem->css);
-		if (pc->flags & PAGE_CGROUP_FLAG_CACHE) {
+		if (PageCgroupCache(pc)) {
 			if (page_is_file_cache(page))
 				ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
 			else
