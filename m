Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 470696B0263
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 02:56:37 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id rz1so227594837pab.0
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 23:56:37 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id xt4si28501839pab.126.2016.10.17.23.56.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 23:56:36 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 5/6] mm: turn vmap_purge_lock into a mutex
Date: Tue, 18 Oct 2016 08:56:10 +0200
Message-Id: <1476773771-11470-6-git-send-email-hch@lst.de>
In-Reply-To: <1476773771-11470-1-git-send-email-hch@lst.de>
References: <1476773771-11470-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/vmalloc.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 2af2921..6c7eb8d 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -606,7 +606,7 @@ static atomic_t vmap_lazy_nr = ATOMIC_INIT(0);
  * by this look, but we want to avoid concurrent calls for performance
  * reasons and to make the pcpu_get_vm_areas more deterministic.
  */
-static DEFINE_SPINLOCK(vmap_purge_lock);
+static DEFINE_MUTEX(vmap_purge_lock);
 
 /* for per-CPU blocks */
 static void purge_fragmented_blocks_allcpus(void);
@@ -660,9 +660,9 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
  */
 static void try_purge_vmap_area_lazy(void)
 {
-	if (spin_trylock(&vmap_purge_lock)) {
+	if (mutex_trylock(&vmap_purge_lock)) {
 		__purge_vmap_area_lazy(ULONG_MAX, 0);
-		spin_unlock(&vmap_purge_lock);
+		mutex_unlock(&vmap_purge_lock);
 	}
 }
 
@@ -671,10 +671,10 @@ static void try_purge_vmap_area_lazy(void)
  */
 static void purge_vmap_area_lazy(void)
 {
-	spin_lock(&vmap_purge_lock);
+	mutex_lock(&vmap_purge_lock);
 	purge_fragmented_blocks_allcpus();
 	__purge_vmap_area_lazy(ULONG_MAX, 0);
-	spin_unlock(&vmap_purge_lock);
+	mutex_unlock(&vmap_purge_lock);
 }
 
 /*
@@ -1063,11 +1063,11 @@ void vm_unmap_aliases(void)
 		rcu_read_unlock();
 	}
 
-	spin_lock(&vmap_purge_lock);
+	mutex_lock(&vmap_purge_lock);
 	purge_fragmented_blocks_allcpus();
 	if (!__purge_vmap_area_lazy(start, end) && flush)
 		flush_tlb_kernel_range(start, end);
-	spin_unlock(&vmap_purge_lock);
+	mutex_unlock(&vmap_purge_lock);
 }
 EXPORT_SYMBOL_GPL(vm_unmap_aliases);
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
