Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5EB7A6B0115
	for <linux-mm@kvack.org>; Wed, 13 May 2009 11:32:13 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e38.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4DFU17V020514
	for <linux-mm@kvack.org>; Wed, 13 May 2009 09:30:01 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4DFWfnm182072
	for <linux-mm@kvack.org>; Wed, 13 May 2009 09:32:41 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4DFWQBS010667
	for <linux-mm@kvack.org>; Wed, 13 May 2009 09:32:28 -0600
Date: Wed, 13 May 2009 21:02:18 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: [RFC] Low overhead patches for the memory resource controller
Message-ID: <20090513153218.GQ13394@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Important: Not for inclusion, for discussion only

I've been experimenting with a version of the patches below. They add
a PCGF_ROOT flag for tracking pages belonging to the root cgroup and
disable LRU manipulation for them

Caveats:

1. I've not checked accounting, accounting might be broken
2. I've not made the root cgroup as non limitable, we need to disable
hard limits once we agree to go with this


Tests

Quick tests show an improvement with AIM9

                mmotm+patch     mmtom-08-may-2009
AIM9            1338.57         1338.17
Dbase           18034.16        16021.58
New Dbase       18482.24        16518.54
Shared          9935.98         8882.11
Compute         16619.81        15226.13

Comments on the approach much appreciated

Feature: Remove the overhead associated with the root cgroup

From: Balbir Singh <balbir@linux.vnet.ibm.com>

This patch changes the memory cgroup and removes the overhead associated
with accounting all pages in the root cgroup. As a side-effect, we can
no longer set a memory hard limit in the root cgroup.

A new flag is used to track page_cgroup associated with the root cgroup
pages.
---

 include/linux/page_cgroup.h |    5 +++++
 mm/memcontrol.c             |   23 +++++++++++++++++------
 mm/page_cgroup.c            |    1 -
 3 files changed, 22 insertions(+), 7 deletions(-)


diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 7339c7b..9c88e85 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -26,6 +26,7 @@ enum {
 	PCG_LOCK,  /* page cgroup is locked */
 	PCG_CACHE, /* charged as cache */
 	PCG_USED, /* this object is in use. */
+	PCG_ROOT, /* page belongs to root cgroup */
 };
 
 #define TESTPCGFLAG(uname, lname)			\
@@ -46,6 +47,10 @@ TESTPCGFLAG(Cache, CACHE)
 TESTPCGFLAG(Used, USED)
 CLEARPCGFLAG(Used, USED)
 
+SETPCGFLAG(Root, ROOT)
+CLEARPCGFLAG(Root, ROOT)
+TESTPCGFLAG(Root, ROOT)
+
 static inline int page_cgroup_nid(struct page_cgroup *pc)
 {
 	return page_to_nid(pc->page);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9712ef7..2750bed 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -43,6 +43,7 @@
 
 struct cgroup_subsys mem_cgroup_subsys __read_mostly;
 #define MEM_CGROUP_RECLAIM_RETRIES	5
+struct mem_cgroup *root_mem_cgroup __read_mostly;
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 /* Turned on only when memory cgroup is enabled && really_do_swap_account = 0 */
@@ -196,6 +197,7 @@ enum charge_type {
 #define PCGF_CACHE	(1UL << PCG_CACHE)
 #define PCGF_USED	(1UL << PCG_USED)
 #define PCGF_LOCK	(1UL << PCG_LOCK)
+#define PCGF_ROOT	(1UL << PCG_ROOT)
 static const unsigned long
 pcg_default_flags[NR_CHARGE_TYPE] = {
 	PCGF_CACHE | PCGF_USED | PCGF_LOCK, /* File Cache */
@@ -422,6 +424,8 @@ void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
 	/* can happen while we handle swapcache. */
 	if (list_empty(&pc->lru) || !pc->mem_cgroup)
 		return;
+	if (PageCgroupRoot(pc))
+		return;
 	/*
 	 * We don't check PCG_USED bit. It's cleared when the "page" is finally
 	 * removed from global LRU.
@@ -452,8 +456,8 @@ void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
 	 * For making pc->mem_cgroup visible, insert smp_rmb() here.
 	 */
 	smp_rmb();
-	/* unused page is not rotated. */
-	if (!PageCgroupUsed(pc))
+	/* unused or root page is not rotated. */
+	if (!PageCgroupUsed(pc) || PageCgroupRoot(pc))
 		return;
 	mz = page_cgroup_zoneinfo(pc);
 	list_move(&pc->lru, &mz->lists[lru]);
@@ -472,7 +476,7 @@ void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
 	 * For making pc->mem_cgroup visible, insert smp_rmb() here.
 	 */
 	smp_rmb();
-	if (!PageCgroupUsed(pc))
+	if (!PageCgroupUsed(pc) || PageCgroupRoot(pc))
 		return;
 
 	mz = page_cgroup_zoneinfo(pc);
@@ -1114,9 +1118,12 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
 		css_put(&mem->css);
 		return;
 	}
-	pc->mem_cgroup = mem;
-	smp_wmb();
-	pc->flags = pcg_default_flags[ctype];
+	if (mem != root_mem_cgroup) {
+		pc->mem_cgroup = mem;
+		smp_wmb();
+		pc->flags = pcg_default_flags[ctype];
+	} else
+		SetPageCgroupRoot(pc);
 
 	mem_cgroup_charge_statistics(mem, pc, true);
 
@@ -1521,6 +1528,8 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	mem_cgroup_charge_statistics(mem, pc, false);
 
 	ClearPageCgroupUsed(pc);
+	if (mem == root_mem_cgroup)
+		ClearPageCgroupRoot(pc);
 	/*
 	 * pc->mem_cgroup is not cleared here. It will be accessed when it's
 	 * freed from LRU. This is safe because uncharged page is expected not
@@ -2504,6 +2513,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	if (cont->parent == NULL) {
 		enable_swap_cgroup();
 		parent = NULL;
+		root_mem_cgroup = mem;
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
 		mem->use_hierarchy = parent->use_hierarchy;
@@ -2532,6 +2542,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	return &mem->css;
 free_out:
 	__mem_cgroup_free(mem);
+	root_mem_cgroup = NULL;
 	return ERR_PTR(error);
 }
 
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 09b73c5..6145ff6 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -276,7 +276,6 @@ void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
 
 #endif
 
-
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 
 static DEFINE_MUTEX(swap_cgroup_mutex);

-- 
        Thanks!
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
