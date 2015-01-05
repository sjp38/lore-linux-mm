Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id CF6C96B006C
	for <linux-mm@kvack.org>; Sun,  4 Jan 2015 20:36:13 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so27525999pab.7
        for <linux-mm@kvack.org>; Sun, 04 Jan 2015 17:36:13 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ho8si8332198pbc.204.2015.01.04.17.36.10
        for <linux-mm@kvack.org>;
        Sun, 04 Jan 2015 17:36:12 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 2/2] mm: don't use compound_head() in virt_to_head_page()
Date: Mon,  5 Jan 2015 10:36:05 +0900
Message-Id: <1420421765-3209-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1420421765-3209-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1420421765-3209-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, rostedt@goodmis.org, Thomas Gleixner <tglx@linutronix.de>

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

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mm.h |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f80d019..0460e2e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -453,6 +453,13 @@ static inline struct page *compound_head(struct page *page)
 	return page;
 }
 
+static inline struct page *compound_head_fast(struct page *page)
+{
+	if (unlikely(PageTail(page)))
+		return page->first_page;
+	return page;
+}
+
 /*
  * The atomic page->_mapcount, starts from -1: so that transitions
  * both from it and to it can be tracked, using atomic_inc_and_test
@@ -531,7 +538,8 @@ static inline void get_page(struct page *page)
 static inline struct page *virt_to_head_page(const void *x)
 {
 	struct page *page = virt_to_page(x);
-	return compound_head(page);
+
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
