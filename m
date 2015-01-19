Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4F4D16B0038
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 01:08:25 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so36695393pab.7
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 22:08:25 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id z1si14646459pas.104.2015.01.18.22.08.21
        for <linux-mm@kvack.org>;
        Sun, 18 Jan 2015 22:08:24 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 2/2] mm: don't use compound_head() in virt_to_head_page()
Date: Mon, 19 Jan 2015 15:08:50 +0900
Message-Id: <1421647730-11568-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1421647730-11568-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1421647730-11568-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, rostedt@goodmis.org, Thomas Gleixner <tglx@linutronix.de>, Guenter Roeck <linux@roeck-us.net>

compound_head() is implemented with assumption that there would be
race condition when checking tail flag. This assumption is only true
when we try to access arbitrary positioned struct page.

The situation that virt_to_head_page() is called is different case.
We call virt_to_head_page() only in the range of allocated pages,
so there is no race condition on tail flag. In this case, we don't
need to handle race condition and we can reduce overhead slightly.
This patch implements compound_head_fast() which is similar with
compound_head() except tail flag race handling. And then,
virt_to_head_page() uses this optimized function to improve performance.

I saw 1.8% win in a fast-path loop over kmem_cache_alloc/free,
(14.063 ns -> 13.810 ns) if target object is on tail page.

Change from v2: Add some code comments

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mm.h |   27 ++++++++++++++++++++++++++-
 1 file changed, 26 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f80d019..1148fc6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -446,6 +446,12 @@ static inline struct page *compound_head_by_tail(struct page *tail)
 	return tail;
 }
 
+/*
+ * Since either compound page could be dismantled asynchronously in THP
+ * or we access asynchronously arbitrary positioned struct page, there
+ * would be tail flag race. To handle this race, we should call
+ * smp_rmb() before checking tail flag. compound_head_by_tail() did it.
+ */
 static inline struct page *compound_head(struct page *page)
 {
 	if (unlikely(PageTail(page)))
@@ -454,6 +460,18 @@ static inline struct page *compound_head(struct page *page)
 }
 
 /*
+ * If we access compound page synchronously such as access to
+ * allocated page, there is no need to handle tail flag race, so we can
+ * check tail flag directly without any synchronization primitive.
+ */
+static inline struct page *compound_head_fast(struct page *page)
+{
+	if (unlikely(PageTail(page)))
+		return page->first_page;
+	return page;
+}
+
+/*
  * The atomic page->_mapcount, starts from -1: so that transitions
  * both from it and to it can be tracked, using atomic_inc_and_test
  * and atomic_add_negative(-1).
@@ -531,7 +549,14 @@ static inline void get_page(struct page *page)
 static inline struct page *virt_to_head_page(const void *x)
 {
 	struct page *page = virt_to_page(x);
-	return compound_head(page);
+
+	/*
+	 * We don't need to worry about synchronization of tail flag
+	 * when we call virt_to_head_page() since it is only called for
+	 * already allocated page and this page won't be freed until
+	 * this virt_to_head_page() is finished. So use _fast variant.
+	 */
+	return compound_head_fast(page);
 }
 
 /*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
