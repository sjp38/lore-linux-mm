Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id C16AD900021
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 12:36:13 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id i17so2721923qcy.28
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 09:36:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a2si8228397qgf.77.2014.10.29.09.36.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Oct 2014 09:36:12 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 4/5] mm: gup: use get_user_pages_unlocked
Date: Wed, 29 Oct 2014 17:35:19 +0100
Message-Id: <1414600520-7664-5-git-send-email-aarcange@redhat.com>
In-Reply-To: <1414600520-7664-1-git-send-email-aarcange@redhat.com>
References: <1414600520-7664-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Peter Feiner <pfeiner@google.com>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

This allows those get_user_pages calls to pass FAULT_FLAG_ALLOW_RETRY
to the page fault in order to release the mmap_sem during the I/O.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 drivers/iommu/amd_iommu_v2.c       | 6 ++----
 drivers/media/pci/ivtv/ivtv-udma.c | 6 ++----
 drivers/scsi/st.c                  | 7 ++-----
 drivers/video/fbdev/pvr2fb.c       | 6 ++----
 mm/process_vm_access.c             | 7 ++-----
 net/ceph/pagevec.c                 | 6 ++----
 6 files changed, 12 insertions(+), 26 deletions(-)

diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index 90d734b..4cd8a87 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -521,10 +521,8 @@ static void do_fault(struct work_struct *work)
 
 	write = !!(fault->flags & PPR_FAULT_WRITE);
 
-	down_read(&fault->state->mm->mmap_sem);
-	npages = get_user_pages(NULL, fault->state->mm,
-				fault->address, 1, write, 0, &page, NULL);
-	up_read(&fault->state->mm->mmap_sem);
+	npages = get_user_pages_unlocked(NULL, fault->state->mm,
+					 fault->address, 1, write, 0, &page);
 
 	if (npages == 1) {
 		put_page(page);
diff --git a/drivers/media/pci/ivtv/ivtv-udma.c b/drivers/media/pci/ivtv/ivtv-udma.c
index 7338cb2..96d866b 100644
--- a/drivers/media/pci/ivtv/ivtv-udma.c
+++ b/drivers/media/pci/ivtv/ivtv-udma.c
@@ -124,10 +124,8 @@ int ivtv_udma_setup(struct ivtv *itv, unsigned long ivtv_dest_addr,
 	}
 
 	/* Get user pages for DMA Xfer */
-	down_read(&current->mm->mmap_sem);
-	err = get_user_pages(current, current->mm,
-			user_dma.uaddr, user_dma.page_count, 0, 1, dma->map, NULL);
-	up_read(&current->mm->mmap_sem);
+	err = get_user_pages_unlocked(current, current->mm,
+			user_dma.uaddr, user_dma.page_count, 0, 1, dma->map);
 
 	if (user_dma.page_count != err) {
 		IVTV_DEBUG_WARN("failed to map user pages, returned %d instead of %d\n",
diff --git a/drivers/scsi/st.c b/drivers/scsi/st.c
index 4daa372..a98e00b 100644
--- a/drivers/scsi/st.c
+++ b/drivers/scsi/st.c
@@ -4538,18 +4538,15 @@ static int sgl_map_user_pages(struct st_buffer *STbp,
 		return -ENOMEM;
 
         /* Try to fault in all of the necessary pages */
-	down_read(&current->mm->mmap_sem);
         /* rw==READ means read from drive, write into memory area */
-	res = get_user_pages(
+	res = get_user_pages_unlocked(
 		current,
 		current->mm,
 		uaddr,
 		nr_pages,
 		rw == READ,
 		0, /* don't force */
-		pages,
-		NULL);
-	up_read(&current->mm->mmap_sem);
+		pages);
 
 	/* Errors and no page mapped should return here */
 	if (res < nr_pages)
diff --git a/drivers/video/fbdev/pvr2fb.c b/drivers/video/fbdev/pvr2fb.c
index 7c74f58..0e24eb9 100644
--- a/drivers/video/fbdev/pvr2fb.c
+++ b/drivers/video/fbdev/pvr2fb.c
@@ -686,10 +686,8 @@ static ssize_t pvr2fb_write(struct fb_info *info, const char *buf,
 	if (!pages)
 		return -ENOMEM;
 
-	down_read(&current->mm->mmap_sem);
-	ret = get_user_pages(current, current->mm, (unsigned long)buf,
-			     nr_pages, WRITE, 0, pages, NULL);
-	up_read(&current->mm->mmap_sem);
+	ret = get_user_pages_unlocked(current, current->mm, (unsigned long)buf,
+				      nr_pages, WRITE, 0, pages);
 
 	if (ret < nr_pages) {
 		nr_pages = ret;
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index 5077afc..b159769 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -99,11 +99,8 @@ static int process_vm_rw_single_vec(unsigned long addr,
 		size_t bytes;
 
 		/* Get the pages we're interested in */
-		down_read(&mm->mmap_sem);
-		pages = get_user_pages(task, mm, pa, pages,
-				      vm_write, 0, process_pages, NULL);
-		up_read(&mm->mmap_sem);
-
+		pages = get_user_pages_unlocked(task, mm, pa, pages,
+						vm_write, 0, process_pages);
 		if (pages <= 0)
 			return -EFAULT;
 
diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
index 5550130..096d914 100644
--- a/net/ceph/pagevec.c
+++ b/net/ceph/pagevec.c
@@ -23,17 +23,15 @@ struct page **ceph_get_direct_page_vector(const void __user *data,
 	if (!pages)
 		return ERR_PTR(-ENOMEM);
 
-	down_read(&current->mm->mmap_sem);
 	while (got < num_pages) {
-		rc = get_user_pages(current, current->mm,
+		rc = get_user_pages_unlocked(current, current->mm,
 		    (unsigned long)data + ((unsigned long)got * PAGE_SIZE),
-		    num_pages - got, write_page, 0, pages + got, NULL);
+		    num_pages - got, write_page, 0, pages + got);
 		if (rc < 0)
 			break;
 		BUG_ON(rc == 0);
 		got += rc;
 	}
-	up_read(&current->mm->mmap_sem);
 	if (rc < 0)
 		goto fail;
 	return pages;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
