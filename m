Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 607086B00D3
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 20:10:54 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id v10so15554639pde.18
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 17:10:54 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id co10si27085133pdb.92.2014.11.13.17.10.51
        for <linux-mm@kvack.org>;
        Thu, 13 Nov 2014 17:10:53 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] zsmalloc: correct fragile [kmap|kunmap]_atomic use
Date: Fri, 14 Nov 2014 10:11:01 +0900
Message-Id: <1415927461-14220-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Jerome Marchand <jmarchan@redhat.com>, Minchan Kim <minchan@kernel.org>

The kunmap_atomic should use virtual address getting by kmap_atomic.
However, some pieces of code in zsmalloc uses modified address,
not the one got by kmap_atomic for kunmap_atomic.

It's okay for working because zsmalloc modifies the address
inner PAGE_SIZE bounday so it works with current kmap_atomic's
implementation. But it's still fragile with potential changing
of kmap_atomic so let's correct it.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b3b57ef85830..85e14f584048 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -629,6 +629,7 @@ static void init_zspage(struct page *first_page, struct size_class *class)
 		struct page *next_page;
 		struct link_free *link;
 		unsigned int i = 1;
+		void *vaddr;
 
 		/*
 		 * page->index stores offset of first object starting
@@ -639,8 +640,8 @@ static void init_zspage(struct page *first_page, struct size_class *class)
 		if (page != first_page)
 			page->index = off;
 
-		link = (struct link_free *)kmap_atomic(page) +
-						off / sizeof(*link);
+		vaddr = kmap_atomic(page);
+		link = (struct link_free *)vaddr + off / sizeof(*link);
 
 		while ((off += class->size) < PAGE_SIZE) {
 			link->next = obj_location_to_handle(page, i++);
@@ -654,7 +655,7 @@ static void init_zspage(struct page *first_page, struct size_class *class)
 		 */
 		next_page = get_next_page(page);
 		link->next = obj_location_to_handle(next_page, 0);
-		kunmap_atomic(link);
+		kunmap_atomic(vaddr);
 		page = next_page;
 		off %= PAGE_SIZE;
 	}
@@ -1055,6 +1056,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 	unsigned long obj;
 	struct link_free *link;
 	struct size_class *class;
+	void *vaddr;
 
 	struct page *first_page, *m_page;
 	unsigned long m_objidx, m_offset;
@@ -1083,11 +1085,11 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 	obj_handle_to_location(obj, &m_page, &m_objidx);
 	m_offset = obj_idx_to_offset(m_page, m_objidx, class->size);
 
-	link = (struct link_free *)kmap_atomic(m_page) +
-					m_offset / sizeof(*link);
+	vaddr = kmap_atomic(m_page);
+	link = (struct link_free *)vaddr + m_offset / sizeof(*link);
 	first_page->freelist = link->next;
 	memset(link, POISON_INUSE, sizeof(*link));
-	kunmap_atomic(link);
+	kunmap_atomic(vaddr);
 
 	first_page->inuse++;
 	/* Now move the zspage to another fullness group, if required */
@@ -1103,6 +1105,7 @@ void zs_free(struct zs_pool *pool, unsigned long obj)
 	struct link_free *link;
 	struct page *first_page, *f_page;
 	unsigned long f_objidx, f_offset;
+	void *vaddr;
 
 	int class_idx;
 	struct size_class *class;
@@ -1121,10 +1124,10 @@ void zs_free(struct zs_pool *pool, unsigned long obj)
 	spin_lock(&class->lock);
 
 	/* Insert this object in containing zspage's freelist */
-	link = (struct link_free *)((unsigned char *)kmap_atomic(f_page)
-							+ f_offset);
+	vaddr = kmap_atomic(f_page);
+	link = (struct link_free *)(vaddr + f_offset);
 	link->next = first_page->freelist;
-	kunmap_atomic(link);
+	kunmap_atomic(vaddr);
 	first_page->freelist = (void *)obj;
 
 	first_page->inuse--;
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
