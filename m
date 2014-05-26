Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 940EA6B0038
	for <linux-mm@kvack.org>; Mon, 26 May 2014 11:29:54 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id u56so8327323wes.28
        for <linux-mm@kvack.org>; Mon, 26 May 2014 08:29:53 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id bb5si18879695wjb.32.2014.05.26.08.29.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 May 2014 08:29:51 -0700 (PDT)
Message-Id: <20140526152108.018672523@infradead.org>
Date: Mon, 26 May 2014 16:56:09 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [RFC][PATCH 4/5] mm,ib,ipath: Use VM_PINNED
References: <20140526145605.016140154@infradead.org>
Content-Disposition: inline; filename=peterz-mm-pinned-4.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

XXX: got lost, need the start vaddr in the release paths, help?

Use the mm_mpin() call to prepare the vm for a 'persistent'
get_user_pages() call.

Cc: Christoph Lameter <cl@linux.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Mike Marciniszyn <infinipath@intel.com> 
Cc: Roland Dreier <roland@kernel.org> 
Cc: Sean Hefty <sean.hefty@intel.com> 
Cc: Hal Rosenstock <hal.rosenstock@gmail.com> 
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 drivers/infiniband/hw/ipath/ipath_file_ops.c   |    6 ++---
 drivers/infiniband/hw/ipath/ipath_kernel.h     |    4 +--
 drivers/infiniband/hw/ipath/ipath_user_pages.c |   28 +++++++++++--------------
 3 files changed, 18 insertions(+), 20 deletions(-)

--- a/drivers/infiniband/hw/ipath/ipath_file_ops.c
+++ b/drivers/infiniband/hw/ipath/ipath_file_ops.c
@@ -456,7 +456,7 @@ static int ipath_tid_update(struct ipath
 				ipath_stats.sps_pageunlocks++;
 			}
 		}
-		ipath_release_user_pages(pagep, cnt);
+		ipath_release_user_pages(pagep, /* vaddr */, cnt);
 	} else {
 		/*
 		 * Copy the updated array, with ipath_tid's filled in, back
@@ -572,7 +572,7 @@ static int ipath_tid_free(struct ipath_p
 			pci_unmap_page(dd->pcidev,
 				dd->ipath_physshadow[porttid + tid],
 				PAGE_SIZE, PCI_DMA_FROMDEVICE);
-			ipath_release_user_pages(&p, 1);
+			ipath_release_user_pages(&p, /* vaddr */, 1);
 			ipath_stats.sps_pageunlocks++;
 		} else
 			ipath_dbg("Unused tid %u, ignoring\n", tid);
@@ -2025,7 +2025,7 @@ static void unlock_expected_tids(struct
 		dd->ipath_pageshadow[i] = NULL;
 		pci_unmap_page(dd->pcidev, dd->ipath_physshadow[i],
 			PAGE_SIZE, PCI_DMA_FROMDEVICE);
-		ipath_release_user_pages_on_close(&ps, 1);
+		ipath_release_user_pages_on_close(&ps, /* vaddr */, 1);
 		cnt++;
 		ipath_stats.sps_pageunlocks++;
 	}
--- a/drivers/infiniband/hw/ipath/ipath_kernel.h
+++ b/drivers/infiniband/hw/ipath/ipath_kernel.h
@@ -1082,8 +1082,8 @@ static inline void ipath_sdma_desc_unres
 #define IPATH_DFLT_RCVHDRSIZE 9
 
 int ipath_get_user_pages(unsigned long, size_t, struct page **);
-void ipath_release_user_pages(struct page **, size_t);
-void ipath_release_user_pages_on_close(struct page **, size_t);
+void ipath_release_user_pages(struct page **, unsigned long, size_t);
+void ipath_release_user_pages_on_close(struct page **, unsigned long, size_t);
 int ipath_eeprom_read(struct ipath_devdata *, u8, void *, int);
 int ipath_eeprom_write(struct ipath_devdata *, u8, const void *, int);
 int ipath_tempsense_read(struct ipath_devdata *, u8 regnum);
--- a/drivers/infiniband/hw/ipath/ipath_user_pages.c
+++ b/drivers/infiniband/hw/ipath/ipath_user_pages.c
@@ -39,7 +39,7 @@
 #include "ipath_kernel.h"
 
 static void __ipath_release_user_pages(struct page **p, size_t num_pages,
-				   int dirty)
+				       int dirty)
 {
 	size_t i;
 
@@ -56,16 +56,12 @@ static void __ipath_release_user_pages(s
 static int __ipath_get_user_pages(unsigned long start_page, size_t num_pages,
 				  struct page **p, struct vm_area_struct **vma)
 {
-	unsigned long lock_limit;
 	size_t got;
 	int ret;
 
-	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
-
-	if (num_pages > lock_limit) {
-		ret = -ENOMEM;
+	ret = mm_mpin(start_page, num_pages * PAGE_SIZE);
+	if (ret)
 		goto bail;
-	}
 
 	ipath_cdbg(VERBOSE, "pin %lx pages from vaddr %lx\n",
 		   (unsigned long) num_pages, start_page);
@@ -78,14 +74,12 @@ static int __ipath_get_user_pages(unsign
 		if (ret < 0)
 			goto bail_release;
 	}
-
-	current->mm->pinned_vm += num_pages;
-
 	ret = 0;
 	goto bail;
 
 bail_release:
 	__ipath_release_user_pages(p, got, 0);
+	mm_munpin(start_page, num_pages * PAGE_SIZE);
 bail:
 	return ret;
 }
@@ -172,13 +166,13 @@ int ipath_get_user_pages(unsigned long s
 	return ret;
 }
 
-void ipath_release_user_pages(struct page **p, size_t num_pages)
+void ipath_release_user_pages(struct page **p, unsigned long start_page,
+			      size_t num_pages)
 {
 	down_write(&current->mm->mmap_sem);
 
 	__ipath_release_user_pages(p, num_pages, 1);
-
-	current->mm->pinned_vm -= num_pages;
+	mm_munpin(start_page, num_pages * PAGE_SIZE);
 
 	up_write(&current->mm->mmap_sem);
 }
@@ -186,6 +180,7 @@ void ipath_release_user_pages(struct pag
 struct ipath_user_pages_work {
 	struct work_struct work;
 	struct mm_struct *mm;
+	unsigned long start_page;
 	unsigned long num_pages;
 };
 
@@ -195,13 +190,15 @@ static void user_pages_account(struct wo
 		container_of(_work, struct ipath_user_pages_work, work);
 
 	down_write(&work->mm->mmap_sem);
-	work->mm->pinned_vm -= work->num_pages;
+	mm_munpin(work->start_page, work->num_pages * PAGE_SIZE);
 	up_write(&work->mm->mmap_sem);
 	mmput(work->mm);
 	kfree(work);
 }
 
-void ipath_release_user_pages_on_close(struct page **p, size_t num_pages)
+void ipath_release_user_pages_on_close(struct page **p,
+				       unsigned long start_page,
+				       size_t num_pages)
 {
 	struct ipath_user_pages_work *work;
 	struct mm_struct *mm;
@@ -218,6 +215,7 @@ void ipath_release_user_pages_on_close(s
 
 	INIT_WORK(&work->work, user_pages_account);
 	work->mm = mm;
+	work->start_page = start_page;
 	work->num_pages = num_pages;
 
 	queue_work(ib_wq, &work->work);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
