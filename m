Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id BDA0D6B003A
	for <linux-mm@kvack.org>; Mon, 26 May 2014 11:29:55 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id n15so183064wiw.2
        for <linux-mm@kvack.org>; Mon, 26 May 2014 08:29:55 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id qi1si18883479wjc.18.2014.05.26.08.29.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 May 2014 08:29:52 -0700 (PDT)
Message-Id: <20140526152108.075622852@infradead.org>
Date: Mon, 26 May 2014 16:56:10 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [RFC][PATCH 5/5] mm,ib,qib: Use VM_PINNED
References: <20140526145605.016140154@infradead.org>
Content-Disposition: inline; filename=peterz-mm-pinned-5.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Mike Marciniszyn <infinipath@intel.com>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Peter Zijlstra <peterz@infradead.org>

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
 drivers/infiniband/hw/qib/qib.h            |    2 +-
 drivers/infiniband/hw/qib/qib_file_ops.c   |    6 +++---
 drivers/infiniband/hw/qib/qib_user_pages.c |   16 ++++++----------
 3 files changed, 10 insertions(+), 14 deletions(-)

--- a/drivers/infiniband/hw/qib/qib.h
+++ b/drivers/infiniband/hw/qib/qib.h
@@ -1376,7 +1376,7 @@ void qib_sdma_process_event(struct qib_p
 #define QIB_RCVHDR_ENTSIZE 32
 
 int qib_get_user_pages(unsigned long, size_t, struct page **);
-void qib_release_user_pages(struct page **, size_t);
+void qib_release_user_pages(struct page **, unsigned long, size_t);
 int qib_eeprom_read(struct qib_devdata *, u8, void *, int);
 int qib_eeprom_write(struct qib_devdata *, u8, const void *, int);
 u32 __iomem *qib_getsendbuf_range(struct qib_devdata *, u32 *, u32, u32);
--- a/drivers/infiniband/hw/qib/qib_file_ops.c
+++ b/drivers/infiniband/hw/qib/qib_file_ops.c
@@ -423,7 +423,7 @@ static int qib_tid_update(struct qib_ctx
 				dd->pageshadow[ctxttid + tid] = NULL;
 			}
 		}
-		qib_release_user_pages(pagep, cnt);
+		qib_release_user_pages(pagep, /* vaddr */, cnt);
 	} else {
 		/*
 		 * Copy the updated array, with qib_tid's filled in, back
@@ -535,7 +535,7 @@ static int qib_tid_free(struct qib_ctxtd
 				      RCVHQ_RCV_TYPE_EXPECTED, dd->tidinvalid);
 			pci_unmap_page(dd->pcidev, phys, PAGE_SIZE,
 				       PCI_DMA_FROMDEVICE);
-			qib_release_user_pages(&p, 1);
+			qib_release_user_pages(&p, /* vaddr */, 1);
 		}
 	}
 done:
@@ -1796,7 +1796,7 @@ static void unlock_expected_tids(struct
 		dd->pageshadow[i] = NULL;
 		pci_unmap_page(dd->pcidev, phys, PAGE_SIZE,
 			       PCI_DMA_FROMDEVICE);
-		qib_release_user_pages(&p, 1);
+		qib_release_user_pages(&p, /* vaddr */, 1);
 		cnt++;
 	}
 }
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -54,16 +54,12 @@ static void __qib_release_user_pages(str
 static int __qib_get_user_pages(unsigned long start_page, size_t num_pages,
 				struct page **p, struct vm_area_struct **vma)
 {
-	unsigned long lock_limit;
 	size_t got;
 	int ret;
 
-	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
-
-	if (num_pages > lock_limit && !capable(CAP_IPC_LOCK)) {
-		ret = -ENOMEM;
+	ret = mm_mpin(start_page, num_pages * PAGE_SIZE);
+	if (ret)
 		goto bail;
-	}
 
 	for (got = 0; got < num_pages; got += ret) {
 		ret = get_user_pages(current, current->mm,
@@ -74,13 +70,12 @@ static int __qib_get_user_pages(unsigned
 			goto bail_release;
 	}
 
-	current->mm->pinned_vm += num_pages;
-
 	ret = 0;
 	goto bail;
 
 bail_release:
 	__qib_release_user_pages(p, got, 0);
+	mm_munpin(start_page, num_pages * PAGE_SIZE);
 bail:
 	return ret;
 }
@@ -143,15 +138,16 @@ int qib_get_user_pages(unsigned long sta
 	return ret;
 }
 
-void qib_release_user_pages(struct page **p, size_t num_pages)
+void qib_release_user_pages(struct page **p, unsigned long start_page, size_t num_pages)
 {
 	if (current->mm) /* during close after signal, mm can be NULL */
 		down_write(&current->mm->mmap_sem);
 
 	__qib_release_user_pages(p, num_pages, 1);
 
+
 	if (current->mm) {
-		current->mm->pinned_vm -= num_pages;
+		mm_munpin(start_page, num_pages * PAGE_SIZE);
 		up_write(&current->mm->mmap_sem);
 	}
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
