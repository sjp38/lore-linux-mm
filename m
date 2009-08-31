From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH 3/4] memcg: add accessor to mem_cgroup.css
Date: Mon, 31 Aug 2009 18:26:43 +0800
Message-ID: <20090831104216.923421735@intel.com>
References: <20090831102640.092092954@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2B2BC6B007E
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 06:43:33 -0400 (EDT)
Content-Disposition: inline; filename=memcg-mem_cgroup_css.patch
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, lizf@cn.fujitsu.com, nishimura@mxp.nes.nec.co.jp, menage@google.com, linux-mm <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

So that one can check its cgroup id and free the reference count
grabbed by try_get_mem_cgroup_from_page().

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/memcontrol.h |    7 +++++++
 mm/memcontrol.c            |    6 ++++++
 2 files changed, 13 insertions(+)

--- linux-mm.orig/include/linux/memcontrol.h	2009-08-31 15:25:48.000000000 +0800
+++ linux-mm/include/linux/memcontrol.h	2009-08-31 15:27:00.000000000 +0800
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
--- linux-mm.orig/mm/memcontrol.c	2009-08-31 15:25:48.000000000 +0800
+++ linux-mm/mm/memcontrol.c	2009-08-31 15:25:52.000000000 +0800
@@ -282,6 +282,12 @@ mem_cgroup_zoneinfo(struct mem_cgroup *m
 	return &mem->info.nodeinfo[nid]->zoneinfo[zid];
 }
 
+struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem)
+{
+	return &mem->css;
+}
+EXPORT_SYMBOL(mem_cgroup_css);
+
 static struct mem_cgroup_per_zone *
 page_cgroup_zoneinfo(struct page_cgroup *pc)
 {

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
