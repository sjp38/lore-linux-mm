Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 352306B025E
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 10:05:51 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id w132so96773325ita.1
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 07:05:51 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0139.outbound.protection.outlook.com. [104.47.1.139])
        by mx.google.com with ESMTPS id an4si31194247pad.84.2016.11.08.07.05.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 08 Nov 2016 07:05:50 -0800 (PST)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 1/3] mm/vmalloc: add vfree_atomic()
Date: Tue, 8 Nov 2016 18:05:43 +0300
Message-ID: <1478617545-8443-1-git-send-email-aryabinin@virtuozzo.com>
In-Reply-To: <20161107150947.GA11279@lst.de>
References: <20161107150947.GA11279@lst.de>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, Joel Fernandes <joelaf@google.com>, Jisheng Zhang <jszhang@marvell.com>, Chris Wilson <chris@chris-wilson.co.uk>, John Dias <joaodias@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, x86@kernel.org

We are going to use sleeping lock for freeing vmap. However some
vfree() users want to free memory from atomic (but not from interrupt)
context. For this we add vfree_atomic() - deferred variation of vfree()
which can be used in any atomic context (except NMIs).

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Joel Fernandes <joelaf@google.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jisheng Zhang <jszhang@marvell.com>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: John Dias <joaodias@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
---
 include/linux/vmalloc.h |  1 +
 mm/vmalloc.c            | 36 ++++++++++++++++++++++++++++++------
 2 files changed, 31 insertions(+), 6 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 3d9d786..d68edff 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -82,6 +82,7 @@ extern void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			const void *caller);
 
 extern void vfree(const void *addr);
+extern void vfree_atomic(const void *addr);
 
 extern void *vmap(struct page **pages, unsigned int count,
 			unsigned long flags, pgprot_t prot);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 719ced3..b0edc67 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1471,7 +1471,33 @@ static void __vunmap(const void *addr, int deallocate_pages)
 	kfree(area);
 	return;
 }
- 
+
+static inline void __vfree_deferred(const void *addr)
+{
+	struct vfree_deferred *p = this_cpu_ptr(&vfree_deferred);
+
+	if (llist_add((struct llist_node *)addr, &p->list))
+		schedule_work(&p->wq);
+}
+
+/**
+ *	vfree_atomic  -  release memory allocated by vmalloc()
+ *	@addr:		memory base address
+ *
+ *	This one is just like vfree() but can be called in any atomic context
+ *	except NMIs.
+ */
+void vfree_atomic(const void *addr)
+{
+	BUG_ON(in_nmi());
+
+	kmemleak_free(addr);
+
+	if (!addr)
+		return;
+	__vfree_deferred(addr);
+}
+
 /**
  *	vfree  -  release memory allocated by vmalloc()
  *	@addr:		memory base address
@@ -1494,11 +1520,9 @@ void vfree(const void *addr)
 
 	if (!addr)
 		return;
-	if (unlikely(in_interrupt())) {
-		struct vfree_deferred *p = this_cpu_ptr(&vfree_deferred);
-		if (llist_add((struct llist_node *)addr, &p->list))
-			schedule_work(&p->wq);
-	} else
+	if (unlikely(in_interrupt()))
+		__vfree_deferred(addr);
+	else
 		__vunmap(addr, 1);
 }
 EXPORT_SYMBOL(vfree);
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
