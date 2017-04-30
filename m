Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C343A6B02F2
	for <linux-mm@kvack.org>; Sun, 30 Apr 2017 07:32:09 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v1so33417052pgv.8
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 04:32:09 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id g1si12012731pln.18.2017.04.30.04.32.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Apr 2017 04:32:09 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id b23so8282017pfc.0
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 04:32:09 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 2/3] mm/slub: wrap cpu_slab->partial in CONFIG_SLUB_CPU_PARTIAL
Date: Sun, 30 Apr 2017 19:31:51 +0800
Message-Id: <20170430113152.6590-3-richard.weiyang@gmail.com>
In-Reply-To: <20170430113152.6590-1-richard.weiyang@gmail.com>
References: <20170430113152.6590-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

cpu_slab's field partial is used when CONFIG_SLUB_CPU_PARTIAL is set, which
means we can save a pointer's space on each cpu for every slub item.

This patch wrap cpu_slab->partial in CONFIG_SLUB_CPU_PARTIAL and wrap its
sysfs too.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 include/linux/slub_def.h |  2 ++
 mm/slub.c                | 16 +++++++++++++++-
 2 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index ec13aab32647..0debd8df1a7d 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -41,7 +41,9 @@ struct kmem_cache_cpu {
 	void **freelist;	/* Pointer to next available object */
 	unsigned long tid;	/* Globally unique transaction id */
 	struct page *page;	/* The slab from which we are allocating */
+#ifdef CONFIG_SLUB_CPU_PARTIAL
 	struct page *partial;	/* Partially allocated frozen slabs */
+#endif
 #ifdef CONFIG_SLUB_STATS
 	unsigned stat[NR_SLUB_STAT_ITEMS];
 #endif
diff --git a/mm/slub.c b/mm/slub.c
index 7f4bc7027ed5..fde499b6dad8 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2302,7 +2302,11 @@ static bool has_cpu_slab(int cpu, void *info)
 	struct kmem_cache *s = info;
 	struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
 
-	return c->page || c->partial;
+	return c->page
+#ifdef CONFIG_SLUB_CPU_PARTIAL
+		|| c->partial
+#endif
+		;
 }
 
 static void flush_all(struct kmem_cache *s)
@@ -2511,7 +2515,9 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 	page = c->page;
 	if (!page)
 		goto new_slab;
+#ifdef CONFIG_SLUB_CPU_PARTIAL
 redo:
+#endif
 
 	if (unlikely(!node_match(page, node))) {
 		int searchnode = node;
@@ -2568,6 +2574,7 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 
 new_slab:
 
+#ifdef CONFIG_SLUB_CPU_PARTIAL
 	if (c->partial) {
 		page = c->page = c->partial;
 		c->partial = page->next;
@@ -2575,6 +2582,7 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 		c->freelist = NULL;
 		goto redo;
 	}
+#endif
 
 	freelist = new_slab_objects(s, gfpflags, node, &c);
 
@@ -4760,6 +4768,7 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 			total += x;
 			nodes[node] += x;
 
+#ifdef CONFIG_SLUB_CPU_PARTIAL
 			page = READ_ONCE(c->partial);
 			if (page) {
 				node = page_to_nid(page);
@@ -4772,6 +4781,7 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 				total += x;
 				nodes[node] += x;
 			}
+#endif
 		}
 	}
 
@@ -4980,6 +4990,7 @@ static ssize_t objects_partial_show(struct kmem_cache *s, char *buf)
 }
 SLAB_ATTR_RO(objects_partial);
 
+#ifdef CONFIG_SLUB_CPU_PARTIAL
 static ssize_t slabs_cpu_partial_show(struct kmem_cache *s, char *buf)
 {
 	int objects = 0;
@@ -5010,6 +5021,7 @@ static ssize_t slabs_cpu_partial_show(struct kmem_cache *s, char *buf)
 	return len + sprintf(buf + len, "\n");
 }
 SLAB_ATTR_RO(slabs_cpu_partial);
+#endif
 
 static ssize_t reclaim_account_show(struct kmem_cache *s, char *buf)
 {
@@ -5364,7 +5376,9 @@ static struct attribute *slab_attrs[] = {
 	&destroy_by_rcu_attr.attr,
 	&shrink_attr.attr,
 	&reserved_attr.attr,
+#ifdef CONFIG_SLUB_CPU_PARTIAL
 	&slabs_cpu_partial_attr.attr,
+#endif
 #ifdef CONFIG_SLUB_DEBUG
 	&total_objects_attr.attr,
 	&slabs_attr.attr,
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
