Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 25C0B6B0096
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 08:09:15 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v6 07/29] mm: Allocate kernel pages to the right memcg
Date: Thu,  1 Nov 2012 16:07:23 +0400
Message-Id: <1351771665-11076-8-git-send-email-glommer@parallels.com>
In-Reply-To: <1351771665-11076-1-git-send-email-glommer@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

When a process tries to allocate a page with the __GFP_KMEMCG flag, the
page allocator will call the corresponding memcg functions to validate
the allocation. Tasks in the root memcg can always proceed.

To avoid adding markers to the page - and a kmem flag that would
necessarily follow, as much as doing page_cgroup lookups for no reason,
whoever is marking its allocations with __GFP_KMEMCG flag is responsible
for telling the page allocator that this is such an allocation at
free_pages() time. This is done by the invocation of
__free_accounted_pages() and free_accounted_pages().

[ v2: inverted test order to avoid a memcg_get leak,
  free_accounted_pages simplification ]
[ v4: test for TIF_MEMDIE at newpage_charge ]

Signed-off-by: Glauber Costa <glommer@parallels.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: David Rientjes <rientjes@google.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Suleiman Souhlal <suleiman@google.com>
CC: Tejun Heo <tj@kernel.org>
---
 include/linux/gfp.h |  3 +++
 mm/page_alloc.c     | 35 +++++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 5effbd4..bf98214 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -362,6 +362,9 @@ extern void free_pages(unsigned long addr, unsigned int order);
 extern void free_hot_cold_page(struct page *page, int cold);
 extern void free_hot_cold_page_list(struct list_head *list, int cold);
 
+extern void __free_memcg_kmem_pages(struct page *page, unsigned int order);
+extern void free_memcg_kmem_pages(unsigned long addr, unsigned int order);
+
 #define __free_page(page) __free_pages((page), 0)
 #define free_page(addr) free_pages((addr), 0)
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e29912e..3cc0940 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2599,6 +2599,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	int migratetype = allocflags_to_migratetype(gfp_mask);
 	unsigned int cpuset_mems_cookie;
 	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET;
+	struct mem_cgroup *memcg = NULL;
 
 	gfp_mask &= gfp_allowed_mask;
 
@@ -2617,6 +2618,13 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (unlikely(!zonelist->_zonerefs->zone))
 		return NULL;
 
+	/*
+	 * Will only have any effect when __GFP_KMEMCG is set.  This is
+	 * verified in the (always inline) callee
+	 */
+	if (!memcg_kmem_newpage_charge(gfp_mask, &memcg, order))
+		return NULL;
+
 retry_cpuset:
 	cpuset_mems_cookie = get_mems_allowed();
 
@@ -2652,6 +2660,8 @@ out:
 	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
 		goto retry_cpuset;
 
+	memcg_kmem_commit_charge(page, memcg, order);
+
 	return page;
 }
 EXPORT_SYMBOL(__alloc_pages_nodemask);
@@ -2704,6 +2714,31 @@ void free_pages(unsigned long addr, unsigned int order)
 
 EXPORT_SYMBOL(free_pages);
 
+/*
+ * __free_memcg_kmem_pages and free_memcg_kmem_pages will free
+ * pages allocated with __GFP_KMEMCG.
+ *
+ * Those pages are accounted to a particular memcg, embedded in the
+ * corresponding page_cgroup. To avoid adding a hit in the allocator to search
+ * for that information only to find out that it is NULL for users who have no
+ * interest in that whatsoever, we provide these functions.
+ *
+ * The caller knows better which flags it relies on.
+ */
+void __free_memcg_kmem_pages(struct page *page, unsigned int order)
+{
+	memcg_kmem_uncharge_pages(page, order);
+	__free_pages(page, order);
+}
+
+void free_memcg_kmem_pages(unsigned long addr, unsigned int order)
+{
+	if (addr != 0) {
+		VM_BUG_ON(!virt_addr_valid((void *)addr));
+		__free_memcg_kmem_pages(virt_to_page((void *)addr), order);
+	}
+}
+
 static void *make_alloc_exact(unsigned long addr, unsigned order, size_t size)
 {
 	if (addr) {
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
