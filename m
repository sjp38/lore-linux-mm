Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DF72D600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:17:24 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [22/31] memcg: add accessor to mem_cgroup.css
Message-Id: <20091208211638.81C35B151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:38 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, kosaki.motohiro@jp.fujitsu.com, hugh.dickins@tiscali.co.uk, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.comfengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


From: Wu Fengguang <fengguang.wu@intel.com>

So that an outside user can free the reference count grabbed by
try_get_mem_cgroup_from_page().

CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Hugh Dickins <hugh.dickins@tiscali.co.uk>
CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
CC: Balbir Singh <balbir@linux.vnet.ibm.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 include/linux/memcontrol.h |    7 +++++++
 mm/memcontrol.c            |    5 +++++
 2 files changed, 12 insertions(+)

Index: linux/include/linux/memcontrol.h
===================================================================
--- linux.orig/include/linux/memcontrol.h
+++ linux/include/linux/memcontrol.h
@@ -81,6 +81,8 @@ int mm_match_cgroup(const struct mm_stru
 	return cgroup == mem;
 }
 
+extern struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem);
+
 extern int
 mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr);
 extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
@@ -206,6 +208,11 @@ static inline int task_in_mem_cgroup(str
 	return 1;
 }
 
+static inline struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem)
+{
+	return NULL;
+}
+
 static inline int
 mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
 {
Index: linux/mm/memcontrol.c
===================================================================
--- linux.orig/mm/memcontrol.c
+++ linux/mm/memcontrol.c
@@ -282,6 +282,11 @@ mem_cgroup_zoneinfo(struct mem_cgroup *m
 	return &mem->info.nodeinfo[nid]->zoneinfo[zid];
 }
 
+struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem)
+{
+	return &mem->css;
+}
+
 static struct mem_cgroup_per_zone *
 page_cgroup_zoneinfo(struct page_cgroup *pc)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
