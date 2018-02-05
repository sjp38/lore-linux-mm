Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2E6726B005C
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:09 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id t23so7812586ply.21
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b33-v6si6139049plb.750.2018.02.04.17.28.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:08 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 56/64] drivers/android: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:46 +0100
Message-Id: <20180205012754.23615-57-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

The binder_alloc_free_page() shrinker callback can call
zap_page_range(), which needs mmap_sem. Use mm locking
wrappers, no change in semantics.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 drivers/android/binder_alloc.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/android/binder_alloc.c b/drivers/android/binder_alloc.c
index 5a426c877dfb..191724983638 100644
--- a/drivers/android/binder_alloc.c
+++ b/drivers/android/binder_alloc.c
@@ -194,6 +194,7 @@ static int binder_update_page_range(struct binder_alloc *alloc, int allocate,
 	struct vm_area_struct *vma = NULL;
 	struct mm_struct *mm = NULL;
 	bool need_mm = false;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	binder_alloc_debug(BINDER_DEBUG_BUFFER_ALLOC,
 		     "%d: %s pages %pK-%pK\n", alloc->pid,
@@ -219,7 +220,7 @@ static int binder_update_page_range(struct binder_alloc *alloc, int allocate,
 		mm = alloc->vma_vm_mm;
 
 	if (mm) {
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm, &mmrange);
 		vma = alloc->vma;
 	}
 
@@ -288,7 +289,7 @@ static int binder_update_page_range(struct binder_alloc *alloc, int allocate,
 		/* vm_insert_page does not seem to increment the refcount */
 	}
 	if (mm) {
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &mmrange);
 		mmput(mm);
 	}
 	return 0;
@@ -321,7 +322,7 @@ static int binder_update_page_range(struct binder_alloc *alloc, int allocate,
 	}
 err_no_vma:
 	if (mm) {
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &mmrange);
 		mmput(mm);
 	}
 	return vma ? -ENOMEM : -ESRCH;
@@ -914,6 +915,7 @@ enum lru_status binder_alloc_free_page(struct list_head *item,
 	uintptr_t page_addr;
 	size_t index;
 	struct vm_area_struct *vma;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	alloc = page->alloc;
 	if (!mutex_trylock(&alloc->mutex))
@@ -929,7 +931,7 @@ enum lru_status binder_alloc_free_page(struct list_head *item,
 		if (!mmget_not_zero(alloc->vma_vm_mm))
 			goto err_mmget;
 		mm = alloc->vma_vm_mm;
-		if (!down_write_trylock(&mm->mmap_sem))
+		if (!mm_write_trylock(mm, &mmrange))
 			goto err_down_write_mmap_sem_failed;
 	}
 
@@ -945,7 +947,7 @@ enum lru_status binder_alloc_free_page(struct list_head *item,
 
 		trace_binder_unmap_user_end(alloc, index);
 
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &mmrange);
 		mmput(mm);
 	}
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
