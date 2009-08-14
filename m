Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 274EC6B004D
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 10:03:46 -0400 (EDT)
Subject: [PATCH -rt] Fix kmap_high_get()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1250199243-18677-1-git-send-email-u.kleine-koenig@pengutronix.de>
References: 
	 <1249810600-21946-3-git-send-email-u.kleine-koenig@pengutronix.de>
	 <1250199243-18677-1-git-send-email-u.kleine-koenig@pengutronix.de>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 14 Aug 2009 16:02:53 +0200
Message-Id: <1250258573.5241.1581.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Cc: Thomas Gleixner <tglx@linutronix.de>, rt-users <linux-rt-users@vger.kernel.org>, Nicolas Pitre <nico@marvell.com>, MinChan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Li Zefan <lizf@cn.fujitsu.com>, Jens Axboe <jens.axboe@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-08-13 at 23:34 +0200, Uwe Kleine-KA?nig wrote:
> This fixes the build failure with ARCH_NEEDS_KMAP_HIGH_GET.
> This is only compile tested.
> 
> Signed-off-by: Uwe Kleine-KA?nig <u.kleine-koenig@pengutronix.de>
> Cc: Nicolas Pitre <nico@marvell.com>
> Cc: MinChan Kim <minchan.kim@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Ingo Molnar <mingo@elte.hu>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Li Zefan <lizf@cn.fujitsu.com>
> Cc: Jens Axboe <jens.axboe@oracle.com>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
> Hello
> 
> this bases on the patch "[PATCH RT 9/6] [RFH] Build failure on
> 2.6.31-rc4-rt1 in mm/highmem.c" earlier in this thread.
> 
> I don't know if kmap_high_get() has to call kmap_account().  Anyone?

I think it should, since it uses kunmap_high() to undo whatever
kmap_high_get() did. Now, if there'd been a kmap_high_put()... :-)

As to the patch, its not quite right.

>From what I understand kmap_high_get() is used to pin a page's kmap iff
it has one, whereas the result of your patch seems to be that it'll
actually create one if its not found.

Something like the below ought to do I guess.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/arm/include/asm/highmem.h |    1 +
 arch/arm/mm/dma-mapping.c      |    2 +-
 mm/highmem.c                   |   50 ++++++++++++++++++---------------------
 3 files changed, 25 insertions(+), 28 deletions(-)

diff --git a/arch/arm/include/asm/highmem.h b/arch/arm/include/asm/highmem.h
index 7f36d00..4d9573b 100644
--- a/arch/arm/include/asm/highmem.h
+++ b/arch/arm/include/asm/highmem.h
@@ -19,6 +19,7 @@ extern pte_t *pkmap_page_table;
 
 extern void *kmap_high(struct page *page);
 extern void *kmap_high_get(struct page *page);
+extern void *kmap_high_put(struct page *page);
 extern void kunmap_high(struct page *page);
 
 extern void *kmap(struct page *page);
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 1576176..4a166d9 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -551,7 +551,7 @@ static void dma_cache_maint_contiguous(struct page *page, unsigned long offset,
 		if (vaddr) {
 			vaddr += offset;
 			inner_op(vaddr, vaddr + size);
-			kunmap_high(page);
+			kmap_high_put(page);
 		}
 	}
 
diff --git a/mm/highmem.c b/mm/highmem.c
index 66e915a..b2eaefe 100644
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
@@ -361,22 +341,38 @@ EXPORT_SYMBOL(kmap_high);
  *
  * Returns the page's current virtual memory address, or NULL if no mapping
  * exists.  When and only when a non null address is returned then a
- * matching call to kunmap_high() is necessary.
+ * matching call to kmap_high_put() is necessary.
  *
  * This can be called from any context.
  */
 void *kmap_high_get(struct page *page)
 {
-	unsigned long vaddr, flags;
+	unsigned long vaddr;
 
-	lock_kmap_any(flags);
+again:
 	vaddr = (unsigned long)page_address(page);
 	if (vaddr) {
-		BUG_ON(pkmap_count[PKMAP_NR(vaddr)] < 1);
-		pkmap_count[PKMAP_NR(vaddr)]++;
+		atomic_t *counter = &pkmap_count[PKMAP_NR(vaddr)];
+		if (atomic_inc_not_zero(counter)) {
+			unsigned long vaddr2 = (unsigned long)page_address(page);
+
+			if (likely(vaddr == vaddr2))
+				return (void *)vaddr;
+
+			pkmap_put(counter);
+			goto again;
+		}
 	}
-	unlock_kmap_any(flags);
-	return (void*) vaddr;
+
+	return NULL;
+}
+
+void kmap_high_put(struct page *page)
+{
+	unsigned long vaddr = (unsigned long)page_address(page);
+
+	BUG_ON(!vaddr);
+	pkmap_put(&pkmap_count[PKMAP_NR(vaddr)]);
 }
 #endif
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
