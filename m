Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id B68E86B003A
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 11:28:13 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id p9so1608991lbv.4
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 08:28:13 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id be6si14702945lbc.18.2014.03.26.08.28.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Mar 2014 08:28:12 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 4/4] mm: kill __GFP_KMEMCG
Date: Wed, 26 Mar 2014 19:28:07 +0400
Message-ID: <82f5ebb7088e0011791033060c3448d6bdc10c46.1395846845.git.vdavydov@parallels.com>
In-Reply-To: <cover.1395846845.git.vdavydov@parallels.com>
References: <cover.1395846845.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

All kmem is now charged to memcg explicitly, and __GFP_KMEMCG is not
used anywhere, so just get rid of it.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
---
 include/linux/gfp.h             |    5 -----
 include/linux/memcontrol.h      |    2 +-
 include/linux/thread_info.h     |    2 --
 include/trace/events/gfpflags.h |    1 -
 kernel/fork.c                   |    2 +-
 mm/page_alloc.c                 |   35 -----------------------------------
 6 files changed, 2 insertions(+), 45 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 39b81dc7d01a..e37b662cd869 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -31,7 +31,6 @@ struct vm_area_struct;
 #define ___GFP_HARDWALL		0x20000u
 #define ___GFP_THISNODE		0x40000u
 #define ___GFP_RECLAIMABLE	0x80000u
-#define ___GFP_KMEMCG		0x100000u
 #define ___GFP_NOTRACK		0x200000u
 #define ___GFP_NO_KSWAPD	0x400000u
 #define ___GFP_OTHER_NODE	0x800000u
@@ -91,7 +90,6 @@ struct vm_area_struct;
 
 #define __GFP_NO_KSWAPD	((__force gfp_t)___GFP_NO_KSWAPD)
 #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE) /* On behalf of other node */
-#define __GFP_KMEMCG	((__force gfp_t)___GFP_KMEMCG) /* Allocation comes from a memcg-accounted resource */
 #define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)	/* Allocator intends to dirty page */
 
 /*
@@ -372,9 +370,6 @@ extern void free_pages(unsigned long addr, unsigned int order);
 extern void free_hot_cold_page(struct page *page, int cold);
 extern void free_hot_cold_page_list(struct list_head *list, int cold);
 
-extern void __free_memcg_kmem_pages(struct page *page, unsigned int order);
-extern void free_memcg_kmem_pages(unsigned long addr, unsigned int order);
-
 #define __free_page(page) __free_pages((page), 0)
 #define free_page(addr) free_pages((addr), 0)
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b8aaecc25cbf..c709f1d30bd5 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -543,7 +543,7 @@ memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
 	 * res_counter_charge_nofail, but we hope those allocations are rare,
 	 * and won't be worth the trouble.
 	 */
-	if (!(gfp & __GFP_KMEMCG) || (gfp & __GFP_NOFAIL))
+	if (gfp & __GFP_NOFAIL)
 		return true;
 	if (in_interrupt() || (!current->mm) || (current->flags & PF_KTHREAD))
 		return true;
diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
index fddbe2023a5d..1807bb194816 100644
--- a/include/linux/thread_info.h
+++ b/include/linux/thread_info.h
@@ -61,8 +61,6 @@ extern long do_no_restart_syscall(struct restart_block *parm);
 # define THREADINFO_GFP		(GFP_KERNEL | __GFP_NOTRACK)
 #endif
 
-#define THREADINFO_GFP_ACCOUNTED (THREADINFO_GFP | __GFP_KMEMCG)
-
 /*
  * flag set/clear/test wrappers
  * - pass TIF_xxxx constants to these functions
diff --git a/include/trace/events/gfpflags.h b/include/trace/events/gfpflags.h
index 1eddbf1557f2..d6fd8e5b14b7 100644
--- a/include/trace/events/gfpflags.h
+++ b/include/trace/events/gfpflags.h
@@ -34,7 +34,6 @@
 	{(unsigned long)__GFP_HARDWALL,		"GFP_HARDWALL"},	\
 	{(unsigned long)__GFP_THISNODE,		"GFP_THISNODE"},	\
 	{(unsigned long)__GFP_RECLAIMABLE,	"GFP_RECLAIMABLE"},	\
-	{(unsigned long)__GFP_KMEMCG,		"GFP_KMEMCG"},		\
 	{(unsigned long)__GFP_MOVABLE,		"GFP_MOVABLE"},		\
 	{(unsigned long)__GFP_NOTRACK,		"GFP_NOTRACK"},		\
 	{(unsigned long)__GFP_NO_KSWAPD,	"GFP_NO_KSWAPD"},	\
diff --git a/kernel/fork.c b/kernel/fork.c
index 8209780cf732..043658430e04 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -153,7 +153,7 @@ static struct thread_info *alloc_thread_info_node(struct task_struct *tsk,
 	struct page *page;
 	struct mem_cgroup *memcg = NULL;
 
-	if (!memcg_kmem_newpage_charge(THREADINFO_GFP_ACCOUNTED, &memcg,
+	if (!memcg_kmem_newpage_charge(THREADINFO_GFP, &memcg,
 				       THREAD_SIZE_ORDER))
 		return NULL;
 	page = alloc_pages_node(node, THREADINFO_GFP, THREAD_SIZE_ORDER);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0327f9d5a8c0..80cce64d30d3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2723,7 +2723,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	int migratetype = allocflags_to_migratetype(gfp_mask);
 	unsigned int cpuset_mems_cookie;
 	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
-	struct mem_cgroup *memcg = NULL;
 
 	gfp_mask &= gfp_allowed_mask;
 
@@ -2742,13 +2741,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (unlikely(!zonelist->_zonerefs->zone))
 		return NULL;
 
-	/*
-	 * Will only have any effect when __GFP_KMEMCG is set.  This is
-	 * verified in the (always inline) callee
-	 */
-	if (!memcg_kmem_newpage_charge(gfp_mask, &memcg, order))
-		return NULL;
-
 retry_cpuset:
 	cpuset_mems_cookie = read_mems_allowed_begin();
 
@@ -2810,8 +2802,6 @@ out:
 	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
 
-	memcg_kmem_commit_charge(page, memcg, order);
-
 	if (page)
 		set_page_owner(page, order, gfp_mask);
 
@@ -2867,31 +2857,6 @@ void free_pages(unsigned long addr, unsigned int order)
 
 EXPORT_SYMBOL(free_pages);
 
-/*
- * __free_memcg_kmem_pages and free_memcg_kmem_pages will free
- * pages allocated with __GFP_KMEMCG.
- *
- * Those pages are accounted to a particular memcg, embedded in the
- * corresponding page_cgroup. To avoid adding a hit in the allocator to search
- * for that information only to find out that it is NULL for users who have no
- * interest in that whatsoever, we provide these functions.
- *
- * The caller knows better which flags it relies on.
- */
-void __free_memcg_kmem_pages(struct page *page, unsigned int order)
-{
-	memcg_kmem_uncharge_pages(page, order);
-	__free_pages(page, order);
-}
-
-void free_memcg_kmem_pages(unsigned long addr, unsigned int order)
-{
-	if (addr != 0) {
-		VM_BUG_ON(!virt_addr_valid((void *)addr));
-		__free_memcg_kmem_pages(virt_to_page((void *)addr), order);
-	}
-}
-
 static void *make_alloc_exact(unsigned long addr, unsigned order, size_t size)
 {
 	if (addr) {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
