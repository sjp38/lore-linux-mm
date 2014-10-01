Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f172.google.com (mail-vc0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id E34556B0070
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 04:57:18 -0400 (EDT)
Received: by mail-vc0-f172.google.com with SMTP id lf12so238736vcb.17
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 01:57:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ik9si126709vdb.79.2014.10.01.01.57.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Oct 2014 01:57:16 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 3/4] mm: gup: use get_user_pages_fast and get_user_pages_unlocked
Date: Wed,  1 Oct 2014 10:56:36 +0200
Message-Id: <1412153797-6667-4-git-send-email-aarcange@redhat.com>
In-Reply-To: <1412153797-6667-1-git-send-email-aarcange@redhat.com>
References: <1412153797-6667-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>

Just an optimization.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 drivers/dma/iovlock.c              | 10 ++--------
 drivers/iommu/amd_iommu_v2.c       |  6 ++----
 drivers/media/pci/ivtv/ivtv-udma.c |  6 ++----
 drivers/misc/sgi-gru/grufault.c    |  3 +--
 drivers/scsi/st.c                  | 10 ++--------
 drivers/video/fbdev/pvr2fb.c       |  5 +----
 mm/mempolicy.c                     |  2 +-
 mm/process_vm_access.c             |  7 ++-----
 mm/util.c                          | 10 ++--------
 net/ceph/pagevec.c                 |  9 ++++-----
 10 files changed, 19 insertions(+), 49 deletions(-)

diff --git a/drivers/dma/iovlock.c b/drivers/dma/iovlock.c
index bb48a57..12ea7c3 100644
--- a/drivers/dma/iovlock.c
+++ b/drivers/dma/iovlock.c
@@ -95,17 +95,11 @@ struct dma_pinned_list *dma_pin_iovec_pages(struct iovec *iov, size_t len)
 		pages += page_list->nr_pages;
 
 		/* pin pages down */
-		down_read(&current->mm->mmap_sem);
-		ret = get_user_pages(
-			current,
-			current->mm,
+		ret = get_user_pages_fast(
 			(unsigned long) iov[i].iov_base,
 			page_list->nr_pages,
 			1,	/* write */
-			0,	/* force */
-			page_list->pages,
-			NULL);
-		up_read(&current->mm->mmap_sem);
+			page_list->pages);
 
 		if (ret != page_list->nr_pages)
 			goto unpin;
diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index 5f578e8..6963b73 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -519,10 +519,8 @@ static void do_fault(struct work_struct *work)
 
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
diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
index f74fc0c..cd20669 100644
--- a/drivers/misc/sgi-gru/grufault.c
+++ b/drivers/misc/sgi-gru/grufault.c
@@ -198,8 +198,7 @@ static int non_atomic_pte_lookup(struct vm_area_struct *vma,
 #else
 	*pageshift = PAGE_SHIFT;
 #endif
-	if (get_user_pages
-	    (current, current->mm, vaddr, 1, write, 0, &page, NULL) <= 0)
+	if (get_user_pages_fast(vaddr, 1, write, &page) <= 0)
 		return -EFAULT;
 	*paddr = page_to_phys(page);
 	put_page(page);
diff --git a/drivers/scsi/st.c b/drivers/scsi/st.c
index aff9689..c89dcfa 100644
--- a/drivers/scsi/st.c
+++ b/drivers/scsi/st.c
@@ -4536,18 +4536,12 @@ static int sgl_map_user_pages(struct st_buffer *STbp,
 		return -ENOMEM;
 
         /* Try to fault in all of the necessary pages */
-	down_read(&current->mm->mmap_sem);
         /* rw==READ means read from drive, write into memory area */
-	res = get_user_pages(
-		current,
-		current->mm,
+	res = get_user_pages_fast(
 		uaddr,
 		nr_pages,
 		rw == READ,
-		0, /* don't force */
-		pages,
-		NULL);
-	up_read(&current->mm->mmap_sem);
+		pages);
 
 	/* Errors and no page mapped should return here */
 	if (res < nr_pages)
diff --git a/drivers/video/fbdev/pvr2fb.c b/drivers/video/fbdev/pvr2fb.c
index 167cfff..ff81f65 100644
--- a/drivers/video/fbdev/pvr2fb.c
+++ b/drivers/video/fbdev/pvr2fb.c
@@ -686,10 +686,7 @@ static ssize_t pvr2fb_write(struct fb_info *info, const char *buf,
 	if (!pages)
 		return -ENOMEM;
 
-	down_read(&current->mm->mmap_sem);
-	ret = get_user_pages(current, current->mm, (unsigned long)buf,
-			     nr_pages, WRITE, 0, pages, NULL);
-	up_read(&current->mm->mmap_sem);
+	ret = get_user_pages_fast((unsigned long)buf, nr_pages, WRITE, pages);
 
 	if (ret < nr_pages) {
 		nr_pages = ret;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 8f5330d..6606c10 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -881,7 +881,7 @@ static int lookup_node(struct mm_struct *mm, unsigned long addr)
 	struct page *p;
 	int err;
 
-	err = get_user_pages(current, mm, addr & PAGE_MASK, 1, 0, 0, &p, NULL);
+	err = get_user_pages_fast(addr & PAGE_MASK, 1, 0, &p);
 	if (err >= 0) {
 		err = page_to_nid(p);
 		put_page(p);
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
 
diff --git a/mm/util.c b/mm/util.c
index 093c973..1b93f2d 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -247,14 +247,8 @@ int __weak get_user_pages_fast(unsigned long start,
 				int nr_pages, int write, struct page **pages)
 {
 	struct mm_struct *mm = current->mm;
-	int ret;
-
-	down_read(&mm->mmap_sem);
-	ret = get_user_pages(current, mm, start, nr_pages,
-					write, 0, pages, NULL);
-	up_read(&mm->mmap_sem);
-
-	return ret;
+	return get_user_pages_unlocked(current, mm, start, nr_pages,
+				       write, 0, pages);
 }
 EXPORT_SYMBOL_GPL(get_user_pages_fast);
 
diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
index 5550130..5504783 100644
--- a/net/ceph/pagevec.c
+++ b/net/ceph/pagevec.c
@@ -23,17 +23,16 @@ struct page **ceph_get_direct_page_vector(const void __user *data,
 	if (!pages)
 		return ERR_PTR(-ENOMEM);
 
-	down_read(&current->mm->mmap_sem);
 	while (got < num_pages) {
-		rc = get_user_pages(current, current->mm,
-		    (unsigned long)data + ((unsigned long)got * PAGE_SIZE),
-		    num_pages - got, write_page, 0, pages + got, NULL);
+		rc = get_user_pages_fast((unsigned long)data +
+					 ((unsigned long)got * PAGE_SIZE),
+					 num_pages - got,
+					 write_page, pages + got);
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
