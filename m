Subject: [PATCH] swap-prefetch, fix lru_cache_add_tail()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Content-Type: text/plain
Date: Wed, 17 May 2006 18:54:27 +0200
Message-Id: <1147884867.22400.9.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>, Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

lru_cache_add_tail() uses the inactive per-cpu pagevec. This causes
normal inactive and intactive tail inserts to end up on the wrong end
of the list.

When the pagevec is completed by lru_cache_add_tail() but still contains
normal inactive pages, all pages will be added to the inactive tail and
vice versa.

Also *add_drain*() will always complete to the inactive head.

Add a third per-cpu pagevec to alleviate this problem.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

---

 mm/swap.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

Index: 2.6-mm/mm/swap.c
===================================================================
--- 2.6-mm.orig/mm/swap.c	2006-05-17 15:39:59.000000000 +0200
+++ 2.6-mm/mm/swap.c	2006-05-17 18:29:42.000000000 +0200
@@ -138,6 +138,7 @@ EXPORT_SYMBOL(mark_page_accessed);
  */
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvecs) = { 0, };
 static DEFINE_PER_CPU(struct pagevec, lru_add_active_pvecs) = { 0, };
+static DEFINE_PER_CPU(struct pagevec, lru_add_tail_pvecs) = { 0, };
 
 void fastcall lru_cache_add(struct page *page)
 {
@@ -159,6 +160,8 @@ void fastcall lru_cache_add_active(struc
 	put_cpu_var(lru_add_active_pvecs);
 }
 
+static inline void __pagevec_lru_add_tail(struct pagevec *pvec);
+
 static void __lru_add_drain(int cpu)
 {
 	struct pagevec *pvec = &per_cpu(lru_add_pvecs, cpu);
@@ -169,6 +172,9 @@ static void __lru_add_drain(int cpu)
 	pvec = &per_cpu(lru_add_active_pvecs, cpu);
 	if (pagevec_count(pvec))
 		__pagevec_lru_add_active(pvec);
+	pvec = &per_cpu(lru_add_tail_pvecs, cpu);
+	if (pagevec_count(pvec))
+		__pagevec_lru_add_tail(pvec);
 }
 
 void lru_add_drain(void)
@@ -416,7 +422,7 @@ static inline void __pagevec_lru_add_tai
  */
 void fastcall lru_cache_add_tail(struct page *page)
 {
-	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs);
+	struct pagevec *pvec = &get_cpu_var(lru_add_tail_pvecs);
 
 	page_cache_get(page);
 	if (!pagevec_add(pvec, page))


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
