Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id CEC226B0037
	for <linux-mm@kvack.org>; Sun, 27 Apr 2014 09:36:37 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id up15so4807301pbc.6
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 06:36:37 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id bi5si8509714pbb.62.2014.04.27.06.36.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 27 Apr 2014 06:36:36 -0700 (PDT)
Received: by mail-pa0-f43.google.com with SMTP id rd3so2976203pab.30
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 06:36:36 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH RFC 2/2] mm: introdule compound_head_by_tail()
Date: Sun, 27 Apr 2014 21:36:24 +0800
Message-Id: <2c87e00d633153ba7b710bab12710cc3a58704dd.1398605516.git.nasa4836@gmail.com>
In-Reply-To: <c232030f96bdc60aef967b0d350208e74dc7f57d.1398605516.git.nasa4836@gmail.com>
References: <c232030f96bdc60aef967b0d350208e74dc7f57d.1398605516.git.nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, riel@redhat.com, liuj97@gmail.com, peterz@infradead.org, hannes@cmpxchg.org, mgorman@suse.de, aarcange@redhat.com, sasha.levin@oracle.com, liwanp@linux.vnet.ibm.com, nasa4836@gmail.com, khalid.aziz@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

In put_comound_page(), we call compound_head() after !PageTail
check fails, so in compound_head() PageTail is quite likely to
be true, but instead it is checked with:

   if (unlikely(PageTail(page)))

in this case, this unlikely macro is a negative hint for compiler.

So this patch introduce compound_head_by_tail() which deal with
a possible tail page(though it could be spilt by a racy thread),
and make compound_head() a wrapper on it.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 include/linux/mm.h | 34 ++++++++++++++++++++++------------
 mm/swap.c          |  2 +-
 2 files changed, 23 insertions(+), 13 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index bf9811e..1bc7baf 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -405,20 +405,30 @@ static inline void compound_unlock_irqrestore(struct page *page,
 #endif
 }
 
+/**
+ * Note: this function must be called on a possible tail page,
+ * this tail page may not be tail anymore upon we calling this funciton,
+ * because we may race with __split_huge_page_refcount tearing down it.
+ */
+static inline struct page *compound_head_by_tail(struct page *page)
+{
+	struct page *head = page->first_page;
+
+	/*
+	 * page->first_page may be a dangling pointer to an old
+	 * compound page, so recheck that it is still a tail
+	 * page before returning.
+	 */
+	smp_rmb();
+	if (likely(PageTail(page)))
+		return head;
+	return page;
+}
+
 static inline struct page *compound_head(struct page *page)
 {
-	if (unlikely(PageTail(page))) {
-		struct page *head = page->first_page;
-
-		/*
-		 * page->first_page may be a dangling pointer to an old
-		 * compound page, so recheck that it is still a tail
-		 * page before returning.
-		 */
-		smp_rmb();
-		if (likely(PageTail(page)))
-			return head;
-	}
+	if (unlikely(PageTail(page)))
+		return compound_head_by_tail(page);
 	return page;
 }
 
diff --git a/mm/swap.c b/mm/swap.c
index 0d8d891..0b05355 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -256,7 +256,7 @@ static void put_compound_page(struct page *page)
 	 *  Case 3 is possible, as we may race with
 	 *  __split_huge_page_refcount tearing down a THP page.
 	 */
-	head_page = compound_head(page);
+	head_page = compound_head_by_tail(page);
 	if (!__compound_tail_refcounted(head_page))
 		put_unrefcounted_compound_page(head_page, page);
 	else
-- 
2.0.0-rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
