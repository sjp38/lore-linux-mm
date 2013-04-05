Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 474656B008C
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 06:00:46 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 2/2] memcg: defer page_cgroup initialization
Date: Fri,  5 Apr 2013 14:01:12 +0400
Message-Id: <1365156072-24100-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1365156072-24100-1-git-send-email-glommer@parallels.com>
References: <1365156072-24100-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@parallels.com>

We have now reached the point in which there is no real need to allocate
page_cgroup upon system boot. We can defer it to the first memcg
initialization, and if it fails, we treat it like any other memcg memory
failures (like for instance, if the mem_cgroup structure itself failed).
In the future, we may want to defer this to the first non-root cgroup
initialization, but we are not there yet.

With that, page_cgroup can be more silent in its initialization.

Signed-off-by: Glauber Costa <glommer@parallels.com>
---
 include/linux/page_cgroup.h |  6 +-----
 init/main.c                 |  1 -
 mm/memcontrol.c             |  2 ++
 mm/page_cgroup.c            | 29 ++++++++---------------------
 4 files changed, 11 insertions(+), 27 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 4860eca..121b17b 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -29,7 +29,7 @@ struct page_cgroup {
 
 void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
 
-extern void __init page_cgroup_init(void);
+extern bool page_cgroup_init(void);
 
 struct page_cgroup *lookup_page_cgroup(struct page *page);
 struct page *lookup_cgroup_page(struct page_cgroup *pc);
@@ -83,10 +83,6 @@ static inline struct page_cgroup *lookup_page_cgroup(struct page *page)
 {
 	return NULL;
 }
-
-static inline void page_cgroup_init(void)
-{
-}
 #endif /* CONFIG_MEMCG */
 
 #include <linux/swap.h>
diff --git a/init/main.c b/init/main.c
index 494774f..1fb3ec0 100644
--- a/init/main.c
+++ b/init/main.c
@@ -591,7 +591,6 @@ asmlinkage void __init start_kernel(void)
 		initrd_start = 0;
 	}
 #endif
-	page_cgroup_init();
 	debug_objects_mem_init();
 	kmemleak_init();
 	setup_per_cpu_pageset();
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f608546..59a5b1f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6357,6 +6357,8 @@ mem_cgroup_css_alloc(struct cgroup *cont)
 		res_counter_init(&memcg->res, NULL);
 		res_counter_init(&memcg->memsw, NULL);
 		res_counter_init(&memcg->kmem, NULL);
+		if (page_cgroup_init())
+			goto free_out;
 	}
 
 	memcg->last_scanned_node = MAX_NUMNODES;
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 84bca4b..0256658 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -61,27 +61,20 @@ static int __init alloc_node_page_cgroup(int nid)
 	return 0;
 }
 
-void __init page_cgroup_init(void)
+bool page_cgroup_init(void)
 {
 
 	int nid, fail;
 
 	if (mem_cgroup_disabled())
-		return;
+		return 0;
 
 	for_each_online_node(nid)  {
 		fail = alloc_node_page_cgroup(nid);
 		if (fail)
-			goto fail;
+			return 1;
 	}
-	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
-	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you"
-	" don't want memory cgroups\n");
-	return;
-fail:
-	printk(KERN_CRIT "allocation of page_cgroup failed.\n");
-	printk(KERN_CRIT "please try 'cgroup_disable=memory' boot option\n");
-	panic("Out of memory");
+	return 0;
 }
 
 #else /* CONFIG_FLAT_NODE_MEM_MAP */
@@ -262,13 +255,13 @@ static int __meminit page_cgroup_callback(struct notifier_block *self,
 
 #endif
 
-void __init page_cgroup_init(void)
+bool page_cgroup_init(void)
 {
 	unsigned long pfn;
 	int nid;
 
 	if (mem_cgroup_disabled())
-		return;
+		return 0;
 
 	for_each_node_state(nid, N_MEMORY) {
 		unsigned long start_pfn, end_pfn;
@@ -295,17 +288,11 @@ void __init page_cgroup_init(void)
 			if (pfn_to_nid(pfn) != nid)
 				continue;
 			if (init_section_page_cgroup(pfn, nid))
-				goto oom;
+				return 1;
 		}
 	}
 	hotplug_memory_notifier(page_cgroup_callback, 0);
-	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
-	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you "
-			 "don't want memory cgroups\n");
-	return;
-oom:
-	printk(KERN_CRIT "try 'cgroup_disable=memory' boot option\n");
-	panic("Out of memory");
+	return 0;
 }
 
 void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
