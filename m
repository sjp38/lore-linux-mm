Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 61A676B004D
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 17:34:40 -0400 (EDT)
From: =?utf-8?q?Uwe=20Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>
Subject: [PATCH] [RFC, RT] fix kmap_high_get
Date: Thu, 13 Aug 2009 23:34:03 +0200
Message-Id: <1250199243-18677-1-git-send-email-u.kleine-koenig@pengutronix.de>
In-Reply-To: <1249810600-21946-3-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1249810600-21946-3-git-send-email-u.kleine-koenig@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Thomas Gleixner <tglx@linutronix.de>
Cc: rt-users <linux-rt-users@vger.kernel.org>, Nicolas Pitre <nico@marvell.com>, MinChan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>, Li Zefan <lizf@cn.fujitsu.com>, Jens Axboe <jens.axboe@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This fixes the build failure with ARCH_NEEDS_KMAP_HIGH_GET.
This is only compile tested.

Signed-off-by: Uwe Kleine-KA?nig <u.kleine-koenig@pengutronix.de>
Cc: Nicolas Pitre <nico@marvell.com>
Cc: MinChan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Jens Axboe <jens.axboe@oracle.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
Hello

this bases on the patch "[PATCH RT 9/6] [RFH] Build failure on
2.6.31-rc4-rt1 in mm/highmem.c" earlier in this thread.

I don't know if kmap_high_get() has to call kmap_account().  Anyone?

As I don't have any knowledge about highmem (or mm in general) I'll go into
hiding before tglx caughts me with his trout.

Best regards
Uwe

 mm/highmem.c |   79 ++++++++++++++++++++-------------------------------------
 1 files changed, 28 insertions(+), 51 deletions(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index 4aa9eea..b5f5faf 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -75,26 +75,6 @@ pte_t * pkmap_page_table;
 
 static DECLARE_WAIT_QUEUE_HEAD(pkmap_wait);
 
-
-/*
- * Most architectures have no use for kmap_high_get(), so let's abstract
- * the disabling of IRQ out of the locking in that case to save on a
- * potential useless overhead.
- */
-#ifdef ARCH_NEEDS_KMAP_HIGH_GET
-#define lock_kmap()             spin_lock_irq(&kmap_lock)
-#define unlock_kmap()           spin_unlock_irq(&kmap_lock)
-#define lock_kmap_any(flags)    spin_lock_irqsave(&kmap_lock, flags)
-#define unlock_kmap_any(flags)  spin_unlock_irqrestore(&kmap_lock, flags)
-#else
-#define lock_kmap()             spin_lock(&kmap_lock)
-#define unlock_kmap()           spin_unlock(&kmap_lock)
-#define lock_kmap_any(flags)    \
-		do { spin_lock(&kmap_lock); (void)(flags); } while (0)
-#define unlock_kmap_any(flags)  \
-		do { spin_unlock(&kmap_lock); (void)(flags); } while (0)
-#endif
-
 /*
  * Try to free a given kmap slot.
  *
@@ -313,22 +293,32 @@ static void kunmap_account(void)
 	wake_up(&pkmap_wait);
 }
 
-void *kmap_high(struct page *page)
+/**
+ * kmap_high_get - pin a highmem page into memory
+ * @page: &struct page to pin
+ *
+ * Returns the page's current virtual memory address, or NULL if no mapping
+ * exists.  When and only when a non null address is returned then a
+ * matching call to kunmap_high() is necessary.
+ *
+ * This can be called from any context.
+ */
+void *kmap_high_get(struct page *page)
 {
 	unsigned long vaddr;
 
-
-	kmap_account();
 again:
 	vaddr = (unsigned long)page_address(page);
 	if (vaddr) {
 		atomic_t *counter = &pkmap_count[PKMAP_NR(vaddr)];
 		if (atomic_inc_not_zero(counter)) {
 			/*
-			 * atomic_inc_not_zero implies a (memory) barrier on success
-			 * so page address will be reloaded.
+			 * atomic_inc_not_zero implies a (memory) barrier on
+			 * success, so page address will be reloaded.
 			 */
-			unsigned long vaddr2 = (unsigned long)page_address(page);
+			unsigned long vaddr2 =
+				(unsigned long)page_address(page);
+
 			if (likely(vaddr == vaddr2))
 				return (void *)vaddr;
 
@@ -344,6 +334,18 @@ again:
 			goto again;
 		}
 	}
+	return NULL;
+}
+
+void *kmap_high(struct page *page)
+{
+	unsigned long vaddr;
+
+	kmap_account();
+again:
+	vaddr = (unsigned long)kmap_high_get(page);
+	if (vaddr)
+		return (void *)vaddr;
 
 	vaddr = pkmap_insert(page);
 	if (!vaddr)
@@ -354,31 +356,6 @@ again:
 
 EXPORT_SYMBOL(kmap_high);
 
-#ifdef ARCH_NEEDS_KMAP_HIGH_GET
-/**
- * kmap_high_get - pin a highmem page into memory
- * @page: &struct page to pin
- *
- * Returns the page's current virtual memory address, or NULL if no mapping
- * exists.  When and only when a non null address is returned then a
- * matching call to kunmap_high() is necessary.
- *
- * This can be called from any context.
- */
-void *kmap_high_get(struct page *page)
-{
-	unsigned long vaddr, flags;
-
-	lock_kmap_any(flags);
-	vaddr = (unsigned long)page_address(page);
-	if (vaddr) {
-		BUG_ON(atomic_read(&pkmap_count[PKMAP_NR(vaddr)]) < 1);
-		atomic_add(1, pkmap_count[PKMAP_NR(vaddr)]);
-	}
-	unlock_kmap_any(flags);
-	return (void*) vaddr;
-}
-#endif
 
  void kunmap_high(struct page *page)
 {
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
