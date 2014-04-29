Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 82B116B0039
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 05:43:15 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id fp1so4634169pdb.37
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 02:43:15 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id rb6si12281559pab.395.2014.04.29.02.43.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 02:43:14 -0700 (PDT)
Received: by mail-pa0-f46.google.com with SMTP id kp14so6882863pab.33
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 02:43:14 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH 3/3] mm: introdule compound_head_by_tail()
Date: Tue, 29 Apr 2014 17:42:48 +0800
Message-Id: <809ea3d4f8b83698117e97b55ab4ec33d3b03ea7.1398764420.git.nasa4836@gmail.com>
In-Reply-To: <b1987d6fb09745a5274895efbde79e37ff9557a3.1398764420.git.nasa4836@gmail.com>
References: <b1987d6fb09745a5274895efbde79e37ff9557a3.1398764420.git.nasa4836@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, riel@redhat.com, liuj97@gmail.com, peterz@infradead.org, hannes@cmpxchg.org, mgorman@suse.de, aarcange@redhat.com, sasha.levin@oracle.com, liwanp@linux.vnet.ibm.com, nasa4836@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, in put_compound_page(), we have such code

--- snipt ----
if (likely(!PageTail(page))) {                  <------  (1)
        if (put_page_testzero(page)) {
                 /*
                 A|* By the time all refcounts have been released
                 A|* split_huge_page cannot run anymore from under us.
                 A|*/
                 if (PageHead(page))
                         __put_compound_page(page);
                 else
                         __put_single_page(page);
         }
         return;
}

/* __split_huge_page_refcount can run under us */
page_head = compound_head(page);        <------------ (2)
--- snipt ---

if at (1) ,  we fail the check, this means page is *likely* a tail page.

Then at (2), as compoud_head(page) is inlined, it is :

--- snipt ---
static inline struct page *compound_head(struct page *page)
{
          if (unlikely(PageTail(page))) {           <----------- (3)
              struct page *head = page->first_page;

                smp_rmb();
                if (likely(PageTail(page)))
                        return head;
        }
        return page;
}
--- snipt ---

here, the (3) unlikely in the case is  a negative hint, because it
is *likely* a tail page. So the check (3) in this case is not good,
so I introduce a helper for this case.

So this patch introduces compound_head_by_tail() which deal with
a possible tail page(though it could be spilt by a racy thread),
and make compound_head() a wrapper on it.

This patch has no functional change, and it reduces the object
size slightly:
   text    data     bss     dec     hex  filename
  11003    1328      16   12347    303b  mm/swap.o.orig
  10971    1328      16   12315    301b  mm/swap.o.patched

I've ran "perf top -e branch-miss" to observe branch-miss in this
case. As Michael points out, it's a slow path, so only very few
times this case happens. But I grep'ed the code base, and found there
still are some other call sites could be benifited from this helper. And
given that it only bloating up the source by only 5 lines, but with
a reduced object size. I still believe this helper deserves to exsit.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 include/linux/mm.h | 29 +++++++++++++++++------------
 mm/swap.c          |  2 +-
 2 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index bf9811e..a606a3e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -405,20 +405,25 @@ static inline void compound_unlock_irqrestore(struct page *page,
 #endif
 }
 
+static inline struct page *compound_head_by_tail(struct page *tail)
+{
+	struct page *head = tail->first_page;
+
+	/*
+	 * page->first_page may be a dangling pointer to an old
+	 * compound page, so recheck that it is still a tail
+	 * page before returning.
+	 */
+	smp_rmb();
+	if (likely(PageTail(tail)))
+		return head;
+	return tail;
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
index d8654d8..a061107 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -253,7 +253,7 @@ static void put_compound_page(struct page *page)
 	 *  Case 3 is possible, as we may race with
 	 *  __split_huge_page_refcount tearing down a THP page.
 	 */
-	page_head = compound_head(page);
+	page_head = compound_head_by_tail(page);
 	if (!__compound_tail_refcounted(page_head))
 		put_unrefcounted_compound_page(page_head, page);
 	else
-- 
2.0.0-rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
