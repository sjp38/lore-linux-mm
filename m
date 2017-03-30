Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC4C6B03A0
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 06:26:20 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 81so41134393pgh.3
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 03:26:20 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0136.outbound.protection.outlook.com. [104.47.2.136])
        by mx.google.com with ESMTPS id x3si1757918pfk.290.2017.03.30.03.26.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Mar 2017 03:26:19 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 4/4] mm/vmalloc: remove vfree_atomic()
Date: Thu, 30 Mar 2017 13:27:19 +0300
Message-ID: <20170330102719.13119-4-aryabinin@virtuozzo.com>
In-Reply-To: <20170330102719.13119-1-aryabinin@virtuozzo.com>
References: <20170330102719.13119-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: penguin-kernel@I-love.SAKURA.ne.jp, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, mhocko@kernel.org, linux-mm@kvack.org, hpa@zytor.com, chris@chris-wilson.co.uk, hch@lst.de, mingo@elte.hu, jszhang@marvell.com, joelaf@google.com, joaodias@google.com, willy@infradead.org, tglx@linutronix.de

vfree() can be used in any atomic context and there is no
vfree_atomic() callers left, so let's remove it.

This reverts commit bf22e37a6413 ("mm: add vfree_atomic()")

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 include/linux/vmalloc.h |  1 -
 mm/vmalloc.c            | 40 +++++-----------------------------------
 2 files changed, 5 insertions(+), 36 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 46991ad..b4f044f 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -83,7 +83,6 @@ extern void *__vmalloc_node_range(unsigned long size, unsigned long align,
 extern void *__vmalloc_node_flags(unsigned long size, int node, gfp_t flags);
 
 extern void vfree(const void *addr);
-extern void vfree_atomic(const void *addr);
 
 extern void *vmap(struct page **pages, unsigned int count,
 			unsigned long flags, pgprot_t prot);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ea1b4ab..b77337a 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1534,38 +1534,6 @@ static void __vunmap(const void *addr, int deallocate_pages)
 	return;
 }
 
-static inline void __vfree_deferred(const void *addr)
-{
-	/*
-	 * Use raw_cpu_ptr() because this can be called from preemptible
-	 * context. Preemption is absolutely fine here, because the llist_add()
-	 * implementation is lockless, so it works even if we are adding to
-	 * nother cpu's list.  schedule_work() should be fine with this too.
-	 */
-	struct vfree_deferred *p = raw_cpu_ptr(&vfree_deferred);
-
-	if (llist_add((struct llist_node *)addr, &p->list))
-		schedule_work(&p->wq);
-}
-
-/**
- *	vfree_atomic  -  release memory allocated by vmalloc()
- *	@addr:		memory base address
- *
- *	This one is just like vfree() but can be called in any atomic context
- *	except NMIs.
- */
-void vfree_atomic(const void *addr)
-{
-	BUG_ON(in_nmi());
-
-	kmemleak_free(addr);
-
-	if (!addr)
-		return;
-	__vfree_deferred(addr);
-}
-
 /**
  *	vfree  -  release memory allocated by vmalloc()
  *	@addr:		memory base address
@@ -1588,9 +1556,11 @@ void vfree(const void *addr)
 
 	if (!addr)
 		return;
-	if (unlikely(in_interrupt()))
-		__vfree_deferred(addr);
-	else
+	if (unlikely(in_interrupt())) {
+		struct vfree_deferred *p = this_cpu_ptr(&vfree_deferred);
+		if (llist_add((struct llist_node *)addr, &p->list))
+			schedule_work(&p->wq);
+	} else
 		__vunmap(addr, 1);
 }
 EXPORT_SYMBOL(vfree);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
