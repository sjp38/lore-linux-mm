Message-Id: <20071004040005.631121150@sgi.com>
References: <20071004035935.042951211@sgi.com>
Date: Wed, 03 Oct 2007 20:59:52 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [17/18] Virtual compound page freeing in interrupt context
Content-Disposition: inline; filename=vcompound_interrupt_free
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

If we are in an interrupt context then simply defer the free via a workqueue.

Removing a virtual mappping *must* be done with interrupts enabled
since tlb_xx functions are called that rely on interrupts for
processor to processor communications.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/page_alloc.c |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2007-10-03 20:00:37.000000000 -0700
+++ linux-2.6/mm/page_alloc.c	2007-10-03 20:01:09.000000000 -0700
@@ -294,10 +294,20 @@ static void __free_vcompound(void *addr)
 	kfree(pages);
 }
 
+static void vcompound_free_work(struct work_struct *w)
+{
+	__free_vcompound((void *)w);
+}
 
 static void free_vcompound(void *addr)
 {
-	__free_vcompound(addr);
+	struct work_struct *w = addr;
+
+	if (irqs_disabled() || in_interrupt()) {
+		INIT_WORK(w, vcompound_free_work);
+		schedule_work(w);
+	} else
+		__free_vcompound(w);
 }
 
 static void free_compound_page(struct page *page)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
