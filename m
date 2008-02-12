Date: Mon, 11 Feb 2008 22:06:48 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Fastpath prototype?
In-Reply-To: <20080211235607.GA27320@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0802112205150.26977@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com>
 <20080209143518.ced71a48.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0802091549120.13328@schroedinger.engr.sgi.com>
 <20080210024517.GA32721@wotan.suse.de> <Pine.LNX.4.64.0802091938160.14089@schroedinger.engr.sgi.com>
 <20080211071828.GD8717@wotan.suse.de> <Pine.LNX.4.64.0802111117440.24379@schroedinger.engr.sgi.com>
 <20080211234029.GB14980@wotan.suse.de> <Pine.LNX.4.64.0802111540550.28729@schroedinger.engr.sgi.com>
 <20080211235607.GA27320@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

This patch preserves the performance while only needing order 0 allocs. 
Pretty primitive.

---
 include/linux/gfp.h      |    4 ++
 include/linux/slub_def.h |    6 ++-
 mm/page_alloc.c          |   94 +++++++++++++++++++++++++++++++++++++++++++++++
 mm/slub.c                |    5 ++
 4 files changed, 107 insertions(+), 2 deletions(-)

Index: linux-2.6/include/linux/gfp.h
===================================================================
--- linux-2.6.orig/include/linux/gfp.h	2008-02-11 20:24:37.550298970 -0800
+++ linux-2.6/include/linux/gfp.h	2008-02-11 20:24:56.655574504 -0800
@@ -231,4 +231,8 @@ void drain_zone_pages(struct zone *zone,
 void drain_all_pages(void);
 void drain_local_pages(void *dummy);
 
+struct page *fast_alloc(gfp_t gfp_mask);
+void fast_free(struct page *page);
+void flush_fast_pages(void);
+void *fast_alloc_addr(gfp_t gfp_mask);
 #endif /* __LINUX_GFP_H */
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2008-02-11 20:24:37.558299609 -0800
+++ linux-2.6/mm/page_alloc.c	2008-02-11 21:51:46.806898404 -0800
@@ -1485,6 +1485,7 @@ restart:
 	if (page)
 		goto got_pg;
 
+	flush_fast_pages();
 	/*
 	 * GFP_THISNODE (meaning __GFP_THISNODE, __GFP_NORETRY and
 	 * __GFP_NOWARN set) should not cause reclaim since the subsystem
@@ -4550,3 +4551,96 @@ __offline_isolated_pages(unsigned long s
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 #endif
+
+#if defined(CONFIG_FAST_CMPXCHG_LOCAL) && !defined(CONFIG_PREEMPT)
+#define PAGE_ALLOC_FASTPATH
+#endif
+
+DEFINE_PER_CPU(struct page *, fast_pages);
+
+void flush_fast_pages_cpu(void *dummy)
+{
+	struct page *page;
+
+	while (__get_cpu_var(fast_pages)) {
+		page = __get_cpu_var(fast_pages);
+#ifdef PAGE_ALLOC_FASTPATH
+		if (cmpxchg_local(&__get_cpu_var(fast_pages), page,
+				(struct page *)page->lru.next) != page)
+			continue;
+#else
+		__get_cpu_var(fast_pages) = (struct page *)page->lru.next;
+#endif
+		__free_page(page);
+	}
+}
+
+void flush_fast_pages(void)
+{
+	printk("flush_fast_pages\n");
+	on_each_cpu(flush_fast_pages_cpu, NULL, 0, 1);
+}
+
+struct page *fast_alloc(gfp_t mask)
+{
+	struct page *page;
+
+#ifdef PAGE_ALLOC_FASTPATH
+	do {
+		page = __get_cpu_var(fast_pages);
+		if (unlikely(!page))
+			goto slow;
+
+	} while (unlikely(cmpxchg_local(&__get_cpu_var(fast_pages),
+			page, (struct page *)page->lru.next) != page));
+#else
+	unsigned long flags;
+
+	local_irq_save(flags);
+	page = __get_cpu_var(fast_pages);
+	if (unlikely(!page)) {
+		local_irq_restore(flags);
+		goto slow;
+	}
+
+	__get_cpu_var(fast_pages) = (struct page *)page->lru.next;
+	local_irq_restore(flags);
+#endif
+	if (unlikely(mask & __GFP_ZERO))
+		memset(page_address(page), 0, PAGE_SIZE);
+	return page;
+
+slow:
+	return alloc_page(mask);
+}
+
+void fast_free(struct page *page)
+{
+#ifdef PAGE_ALLOC_FASTPAH
+	struct page *old;
+
+	do {
+		p = &__get_cpu_var(fast_pages);
+		old = *p;
+		page->lru.next = (void *)old;
+	} while (unlikely(cmpxchg_local(p, old, page) != old));
+#else
+	unsigned long flags;
+
+	local_irq_save(flags);
+	page->lru.next = (void *)__get_cpu_var(fast_pages);
+	__get_cpu_var(fast_pages) = page;
+	local_irq_restore(flags);
+#endif
+}
+
+void *fast_alloc_addr(gfp_t gfp_mask)
+{
+	struct page * page;
+
+	page = fast_alloc(gfp_mask);
+	if (likely(page))
+		return (void *) page_address(page);
+
+	return NULL;
+}
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-02-11 20:24:37.570300573 -0800
+++ linux-2.6/mm/slub.c	2008-02-11 20:24:56.655574504 -0800
@@ -2750,7 +2750,10 @@ void kfree(const void *x)
 
 	page = virt_to_head_page(x);
 	if (unlikely(!PageSlab(page))) {
-		put_page(page);
+		if (unlikely(PageCompound(page)))
+			put_page(page);
+		else
+			fast_free(page);
 		return;
 	}
 	slab_free(page->slab, page, object, __builtin_return_address(0));
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2008-02-11 20:24:55.111479643 -0800
+++ linux-2.6/include/linux/slub_def.h	2008-02-11 20:27:19.076283534 -0800
@@ -190,7 +190,11 @@ void *__kmalloc(size_t size, gfp_t flags
 
 static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
 {
-	return (void *)__get_free_pages(flags | __GFP_COMP, get_order(size));
+	if (size <= PAGE_SIZE)
+		return fast_alloc_addr(flags);
+	else
+		return (void *)__get_free_pages(flags | __GFP_COMP,
+							get_order(size));
 }
 
 static __always_inline void *kmalloc(size_t size, gfp_t flags)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
