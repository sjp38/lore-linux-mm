Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 77C896B0055
	for <linux-mm@kvack.org>; Fri, 11 Sep 2009 07:23:05 -0400 (EDT)
Date: Fri, 11 Sep 2009 19:22:59 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 2/2] memcg: add accessor to mem_cgroup.css
Message-ID: <20090911112259.GA20988@localhost>
References: <20090911112221.GA20629@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090911112221.GA20629@localhost>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

So that an outside user can free the reference count grabbed by
try_get_mem_cgroup_from_page().

CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Hugh Dickins <hugh@veritas.com>
CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
CC: Balbir Singh <balbir@linux.vnet.ibm.com>
CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/memcontrol.h |    7 +++++++
 mm/memcontrol.c            |    8 ++++++++
 2 files changed, 15 insertions(+)

--- linux-mm.orig/include/linux/memcontrol.h	2009-09-11 18:16:55.000000000 +0800
+++ linux-mm/include/linux/memcontrol.h	2009-09-11 18:16:56.000000000 +0800
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
--- linux-mm.orig/mm/memcontrol.c	2009-09-11 18:16:55.000000000 +0800
+++ linux-mm/mm/memcontrol.c	2009-09-11 18:18:11.000000000 +0800
@@ -282,6 +282,14 @@ mem_cgroup_zoneinfo(struct mem_cgroup *m
 	return &mem->info.nodeinfo[nid]->zoneinfo[zid];
 }
 
+#ifdef CONFIG_HWPOISON_INJECT /* for now, only user is hwpoison injector */
+struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem)
+{
+	return &mem->css;
+}
+EXPORT_SYMBOL(mem_cgroup_css);
+#endif
+
 static struct mem_cgroup_per_zone *
 page_cgroup_zoneinfo(struct page_cgroup *pc)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
