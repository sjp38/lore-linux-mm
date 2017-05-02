Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D4A946B02EE
	for <linux-mm@kvack.org>; Tue,  2 May 2017 10:45:45 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id o3so60047989pgn.13
        for <linux-mm@kvack.org>; Tue, 02 May 2017 07:45:45 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id h10si18030074pgc.45.2017.05.02.07.45.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 07:45:45 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id b23so17689678pfc.0
        for <linux-mm@kvack.org>; Tue, 02 May 2017 07:45:45 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH V2 2/3] mm/slub: wrap cpu_slab->partial in CONFIG_SLUB_CPU_PARTIAL
Date: Tue,  2 May 2017 22:45:32 +0800
Message-Id: <20170502144533.10729-3-richard.weiyang@gmail.com>
In-Reply-To: <20170502144533.10729-1-richard.weiyang@gmail.com>
References: <20170502144533.10729-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

cpu_slab's field partial is used when CONFIG_SLUB_CPU_PARTIAL is set, which
means we can save a pointer's space on each cpu for every slub item.

This patch wrap cpu_slab->partial in CONFIG_SLUB_CPU_PARTIAL and wrap its
sysfs too.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

---
v2: define slub_percpu_partial() to make code more elegant
---
 include/linux/slub_def.h | 19 +++++++++++++++++++
 mm/slub.c                | 16 +++++++++-------
 2 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index ec13aab32647..f882a34bb9aa 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -41,12 +41,31 @@ struct kmem_cache_cpu {
 	void **freelist;	/* Pointer to next available object */
 	unsigned long tid;	/* Globally unique transaction id */
 	struct page *page;	/* The slab from which we are allocating */
+#ifdef CONFIG_SLUB_CPU_PARTIAL
 	struct page *partial;	/* Partially allocated frozen slabs */
+#endif
 #ifdef CONFIG_SLUB_STATS
 	unsigned stat[NR_SLUB_STAT_ITEMS];
 #endif
 };
 
+#ifdef CONFIG_SLUB_CPU_PARTIAL
+#define slub_percpu_partial(c)		((c)->partial)
+
+#define slub_set_percpu_partial(c, p)		\
+({						\
+	slub_percpu_partial(c) = (p)->next;	\
+})
+
+#define slub_percpu_partial_read_once(c)     READ_ONCE(slub_percpu_partial(c))
+#else
+#define slub_percpu_partial(c)			NULL
+
+#define slub_set_percpu_partial(c, p)
+
+#define slub_percpu_partial_read_once(c)	NULL
+#endif // CONFIG_SLUB_CPU_PARTIAL
+
 /*
  * Word size structure that can be atomically updated or read and that
  * contains both the order and the number of objects that a slab of the
diff --git a/mm/slub.c b/mm/slub.c
index 7f4bc7027ed5..ae6166533261 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2302,7 +2302,7 @@ static bool has_cpu_slab(int cpu, void *info)
 	struct kmem_cache *s = info;
 	struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
 
-	return c->page || c->partial;
+	return c->page || slub_percpu_partial(c);
 }
 
 static void flush_all(struct kmem_cache *s)
@@ -2568,9 +2568,9 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 
 new_slab:
 
-	if (c->partial) {
-		page = c->page = c->partial;
-		c->partial = page->next;
+	if (slub_percpu_partial(c)) {
+		page = c->page = slub_percpu_partial(c);
+		slub_set_percpu_partial(c, page);
 		stat(s, CPU_PARTIAL_ALLOC);
 		c->freelist = NULL;
 		goto redo;
@@ -4760,7 +4760,7 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 			total += x;
 			nodes[node] += x;
 
-			page = READ_ONCE(c->partial);
+			page = slub_percpu_partial_read_once(c);
 			if (page) {
 				node = page_to_nid(page);
 				if (flags & SO_TOTAL)
@@ -4988,7 +4988,8 @@ static ssize_t slabs_cpu_partial_show(struct kmem_cache *s, char *buf)
 	int len;
 
 	for_each_online_cpu(cpu) {
-		struct page *page = per_cpu_ptr(s->cpu_slab, cpu)->partial;
+		struct page *page =
+			slub_percpu_partial(per_cpu_ptr(s->cpu_slab, cpu));
 
 		if (page) {
 			pages += page->pages;
@@ -5000,7 +5001,8 @@ static ssize_t slabs_cpu_partial_show(struct kmem_cache *s, char *buf)
 
 #ifdef CONFIG_SMP
 	for_each_online_cpu(cpu) {
-		struct page *page = per_cpu_ptr(s->cpu_slab, cpu) ->partial;
+		struct page *page =
+			slub_percpu_partial(per_cpu_ptr(s->cpu_slab, cpu));
 
 		if (page && len < PAGE_SIZE - 20)
 			len += sprintf(buf + len, " C%d=%d(%d)", cpu,
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
