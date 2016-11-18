Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D1C116B0420
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 08:04:37 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g186so251223858pgc.2
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 05:04:37 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id b10si8201242pga.13.2016.11.18.05.04.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 05:04:36 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 09/10] mm: turn vmap_purge_lock into a mutex
Date: Fri, 18 Nov 2016 14:03:55 +0100
Message-Id: <1479474236-4139-10-git-send-email-hch@lst.de>
In-Reply-To: <1479474236-4139-1-git-send-email-hch@lst.de>
References: <1479474236-4139-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aryabinin@virtuozzo.com, joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

The purge_lock spinlock causes high latencies with non RT kernel. This
has been reported multiple times on lkml [1] [2] and affects
applications like audio.

This patch replaces it with a mutex to allow preemption while holding
the lock.

Thanks to Joel Fernandes for the detailed report and analysis as well
as an earlier attempt at fixing this issue.

[1] http://lists.openwall.net/linux-kernel/2016/03/23/29
[2] https://lkml.org/lkml/2016/10/9/59

Signed-off-by: Christoph Hellwig <hch@lst.de>
Tested-by: Jisheng Zhang <jszhang@marvell.com>
---
 mm/vmalloc.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 25283af..dccf242 100644
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
