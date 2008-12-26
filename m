Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3E7B46B0044
	for <linux-mm@kvack.org>; Fri, 26 Dec 2008 01:38:56 -0500 (EST)
Message-ID: <49547B93.5090905@cn.fujitsu.com>
Date: Fri, 26 Dec 2008 14:37:07 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: [PATCH] cpuset,mm: fix allocating page cache/slab object on the unallowed
 node when memory spread is set
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The task still allocated the page caches on old node after modifying its
cpuset's mems when 'memory_spread_page' was set, it is caused by the old
mem_allowed_list of the task. Slab has the same problem.

This patch fixes this bug.

Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>
---
 mm/filemap.c |    3 +++
 mm/slab.c    |    3 +++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index f3e5f89..d978983 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -517,6 +517,9 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 #ifdef CONFIG_NUMA
 struct page *__page_cache_alloc(gfp_t gfp)
 {
+	if ((gfp & __GFP_WAIT) && !in_interrupt())
+		cpuset_update_task_memory_state();
+
 	if (cpuset_do_page_mem_spread()) {
 		int n = cpuset_mem_spread_node();
 		return alloc_pages_node(n, gfp, 0);
diff --git a/mm/slab.c b/mm/slab.c
index 0918751..3b6e3d7 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3460,6 +3460,9 @@ __cache_alloc(struct kmem_cache *cachep, gfp_t flags, void *caller)
 	if (should_failslab(cachep, flags))
 		return NULL;
 
+	if ((flags & __GFP_WAIT) && !in_interrupt())
+		cpuset_update_task_memory_state();
+
 	cache_alloc_debugcheck_before(cachep, flags);
 	local_irq_save(save_flags);
 	objp = __do_cache_alloc(cachep, flags);
-- 
1.5.4.rc3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
