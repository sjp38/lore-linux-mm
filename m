Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 2/6] mic/scif: do not use mmap_sem
Date: Mon, 21 Jan 2019 09:42:16 -0800
Message-Id: <20190121174220.10583-3-dave@stgolabs.net>
In-Reply-To: <20190121174220.10583-1-dave@stgolabs.net>
References: <20190121174220.10583-1-dave@stgolabs.net>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: dledford@redhat.com, jgg@mellanox.com, jack@suse.de, ira.weiny@intel.com, linux-rdma@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave@stgolabs.net, sudeep.dutt@intel.com, ashutosh.dixit@intel.com, Davidlohr Bueso <dbueso@suse.de>
List-ID: <linux-mm.kvack.org>

The driver uses mmap_sem for both pinned_vm accounting and
get_user_pages(). By using gup_fast() and letting the mm handle
the lock if needed, we can no longer rely on the semaphore and
simplify the whole thing.

Cc: sudeep.dutt@intel.com
Cc: ashutosh.dixit@intel.com
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 drivers/misc/mic/scif/scif_rma.c | 36 +++++++++++-------------------------
 1 file changed, 11 insertions(+), 25 deletions(-)

diff --git a/drivers/misc/mic/scif/scif_rma.c b/drivers/misc/mic/scif/scif_rma.c
index 2448368f181e..263b8ad507ea 100644
--- a/drivers/misc/mic/scif/scif_rma.c
+++ b/drivers/misc/mic/scif/scif_rma.c
@@ -272,21 +272,12 @@ static inline void __scif_release_mm(struct mm_struct *mm)
 
 static inline int
 __scif_dec_pinned_vm_lock(struct mm_struct *mm,
-			  int nr_pages, bool try_lock)
+			  int nr_pages)
 {
 	if (!mm || !nr_pages || !scif_ulimit_check)
 		return 0;
-	if (try_lock) {
-		if (!down_write_trylock(&mm->mmap_sem)) {
-			dev_err(scif_info.mdev.this_device,
-				"%s %d err\n", __func__, __LINE__);
-			return -1;
-		}
-	} else {
-		down_write(&mm->mmap_sem);
-	}
+
 	atomic64_sub(nr_pages, &mm->pinned_vm);
-	up_write(&mm->mmap_sem);
 	return 0;
 }
 
@@ -298,16 +289,16 @@ static inline int __scif_check_inc_pinned_vm(struct mm_struct *mm,
 	if (!mm || !nr_pages || !scif_ulimit_check)
 		return 0;
 
-	locked = nr_pages;
-	locked += atomic64_read(&mm->pinned_vm);
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
+	locked = atomic64_add_return(nr_pages, &mm->pinned_vm);
+
 	if ((locked > lock_limit) && !capable(CAP_IPC_LOCK)) {
+		atomic64_sub(nr_pages, &mm->pinned_vm);
 		dev_err(scif_info.mdev.this_device,
 			"locked(%lu) > lock_limit(%lu)\n",
 			locked, lock_limit);
 		return -ENOMEM;
 	}
-	atomic64_set(&mm->pinned_vm, locked);
 	return 0;
 }
 
@@ -326,7 +317,7 @@ int scif_destroy_window(struct scif_endpt *ep, struct scif_window *window)
 
 	might_sleep();
 	if (!window->temp && window->mm) {
-		__scif_dec_pinned_vm_lock(window->mm, window->nr_pages, 0);
+		__scif_dec_pinned_vm_lock(window->mm, window->nr_pages);
 		__scif_release_mm(window->mm);
 		window->mm = NULL;
 	}
@@ -737,7 +728,7 @@ int scif_unregister_window(struct scif_window *window)
 					    ep->rma_info.dma_chan);
 		} else {
 			if (!__scif_dec_pinned_vm_lock(window->mm,
-						       window->nr_pages, 1)) {
+						       window->nr_pages)) {
 				__scif_release_mm(window->mm);
 				window->mm = NULL;
 			}
@@ -1385,28 +1376,23 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
 		prot |= SCIF_PROT_WRITE;
 retry:
 		mm = current->mm;
-		down_write(&mm->mmap_sem);
 		if (ulimit) {
 			err = __scif_check_inc_pinned_vm(mm, nr_pages);
 			if (err) {
-				up_write(&mm->mmap_sem);
 				pinned_pages->nr_pages = 0;
 				goto error_unmap;
 			}
 		}
 
-		pinned_pages->nr_pages = get_user_pages(
+		pinned_pages->nr_pages = get_user_pages_fast(
 				(u64)addr,
 				nr_pages,
 				(prot & SCIF_PROT_WRITE) ? FOLL_WRITE : 0,
-				pinned_pages->pages,
-				NULL);
-		up_write(&mm->mmap_sem);
+				pinned_pages->pages);
 		if (nr_pages != pinned_pages->nr_pages) {
 			if (try_upgrade) {
 				if (ulimit)
-					__scif_dec_pinned_vm_lock(mm,
-								  nr_pages, 0);
+					__scif_dec_pinned_vm_lock(mm, nr_pages);
 				/* Roll back any pinned pages */
 				for (i = 0; i < pinned_pages->nr_pages; i++) {
 					if (pinned_pages->pages[i])
@@ -1433,7 +1419,7 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
 	return err;
 dec_pinned:
 	if (ulimit)
-		__scif_dec_pinned_vm_lock(mm, nr_pages, 0);
+		__scif_dec_pinned_vm_lock(mm, nr_pages);
 	/* Something went wrong! Rollback */
 error_unmap:
 	pinned_pages->nr_pages = nr_pages;
-- 
2.16.4
