Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EBB9E900138
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 13:29:51 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp05.in.ibm.com (8.14.4/8.13.1) with ESMTP id p7AHTjZ1021988
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 22:59:45 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7AHTj2L3952650
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 22:59:45 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7AHTir9024334
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 03:29:45 +1000
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Date: Wed, 10 Aug 2011 22:59:42 +0530
Message-Id: <20110810172942.23280.99644.sendpatchset@oc5400248562.ibm.com>
In-Reply-To: <20110810172917.23280.9440.sendpatchset@oc5400248562.ibm.com>
References: <20110810172917.23280.9440.sendpatchset@oc5400248562.ibm.com>
Subject: [PATCH 2/2][cleanup] memcg: renaming of mem variable to memcg
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arend van Spriel <arend@broadcom.com>, Greg Kroah-Hartman <gregkh@suse.de>, "David S. Miller" <davem@davemloft.net>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, "John W. Linville" <linville@tuxdriver.com>, Mauro Carvalho Chehab <mchehab@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>

 The memcg code sometimes uses "struct mem_cgroup *mem" and sometimes uses
 "struct mem_cgroup *memcg". This patch renames all mem variables to memcg in header file.

From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
---
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5633f51..fb1ed1c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -88,8 +88,8 @@ extern void mem_cgroup_uncharge_end(void);
 extern void mem_cgroup_uncharge_page(struct page *page);
 extern void mem_cgroup_uncharge_cache_page(struct page *page);
 
-extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
-int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
+extern void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask);
+int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg);
 
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
@@ -98,19 +98,19 @@ extern struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm);
 static inline
 int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *memcg;
 	rcu_read_lock();
-	mem = mem_cgroup_from_task(rcu_dereference((mm)->owner));
+	memcg = mem_cgroup_from_task(rcu_dereference((mm)->owner));
 	rcu_read_unlock();
-	return cgroup == mem;
+	return cgroup == memcg;
 }
 
-extern struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem);
+extern struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg);
 
 extern int
 mem_cgroup_prepare_migration(struct page *page,
 	struct page *newpage, struct mem_cgroup **ptr, gfp_t gfp_mask);
-extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
+extern void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 	struct page *oldpage, struct page *newpage, bool migration_ok);
 
 /*
@@ -167,7 +167,7 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask,
 						unsigned long *total_scanned);
-u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
+u64 mem_cgroup_get_limit(struct mem_cgroup *memcg);
 
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -263,18 +263,20 @@ static inline struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm
 	return NULL;
 }
 
-static inline int mm_match_cgroup(struct mm_struct *mm, struct mem_cgroup *mem)
+static inline int mm_match_cgroup(struct mm_struct *mm,
+		struct mem_cgroup *memcg)
 {
 	return 1;
 }
 
 static inline int task_in_mem_cgroup(struct task_struct *task,
-				     const struct mem_cgroup *mem)
+				     const struct mem_cgroup *memcg)
 {
 	return 1;
 }
 
-static inline struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem)
+static inline struct cgroup_subsys_state
+		*mem_cgroup_css(struct mem_cgroup *memcg)
 {
 	return NULL;
 }
@@ -286,22 +288,22 @@ mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
 	return 0;
 }
 
-static inline void mem_cgroup_end_migration(struct mem_cgroup *mem,
+static inline void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 		struct page *oldpage, struct page *newpage, bool migration_ok)
 {
 }
 
-static inline int mem_cgroup_get_reclaim_priority(struct mem_cgroup *mem)
+static inline int mem_cgroup_get_reclaim_priority(struct mem_cgroup *memcg)
 {
 	return 0;
 }
 
-static inline void mem_cgroup_note_reclaim_priority(struct mem_cgroup *mem,
+static inline void mem_cgroup_note_reclaim_priority(struct mem_cgroup *memcg,
 						int priority)
 {
 }
 
-static inline void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem,
+static inline void mem_cgroup_record_reclaim_priority(struct mem_cgroup *memcg,
 						int priority)
 {
 }
@@ -367,7 +369,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 }
 
 static inline
-u64 mem_cgroup_get_limit(struct mem_cgroup *mem)
+u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
 {
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
