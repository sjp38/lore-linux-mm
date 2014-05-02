Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 42EBB82963
	for <linux-mm@kvack.org>; Fri,  2 May 2014 09:53:16 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id m20so1593544qcx.26
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:53:16 -0700 (PDT)
Received: from mail-qc0-x234.google.com (mail-qc0-x234.google.com [2607:f8b0:400d:c01::234])
        by mx.google.com with ESMTPS id c43si14167861qge.199.2014.05.02.06.53.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 06:53:15 -0700 (PDT)
Received: by mail-qc0-f180.google.com with SMTP id i17so3959694qcy.25
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:53:15 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 11/11] hmm/dummy_driver: add support for fake remote memory using pages.
Date: Fri,  2 May 2014 09:52:10 -0400
Message-Id: <1399038730-25641-12-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Fake the existent of remote memory using preallocated pages and
demonstrate how to use the hmm api related to remote memory.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 drivers/char/hmm_dummy.c       | 450 ++++++++++++++++++++++++++++++++++++++++-
 include/uapi/linux/hmm_dummy.h |   8 +-
 2 files changed, 453 insertions(+), 5 deletions(-)

diff --git a/drivers/char/hmm_dummy.c b/drivers/char/hmm_dummy.c
index e87dc7c..2443374 100644
--- a/drivers/char/hmm_dummy.c
+++ b/drivers/char/hmm_dummy.c
@@ -48,6 +48,8 @@
 
 #define HMM_DUMMY_DEVICE_NAME		"hmm_dummy_device"
 #define HMM_DUMMY_DEVICE_MAX_MIRRORS	4
+#define HMM_DUMMY_DEVICE_RMEM_SIZE	(32UL << 20UL)
+#define HMM_DUMMY_DEVICE_RMEM_NBITS	(HMM_DUMMY_DEVICE_RMEM_SIZE >> PAGE_SHIFT)
 
 struct hmm_dummy_device;
 
@@ -73,8 +75,16 @@ struct hmm_dummy_device {
 	/* device file mapping tracking (keep track of all vma) */
 	struct hmm_dummy_mirror	*dmirrors[HMM_DUMMY_DEVICE_MAX_MIRRORS];
 	struct address_space	*fmapping[HMM_DUMMY_DEVICE_MAX_MIRRORS];
+	struct page		**rmem_pages;
+	unsigned long		*rmem_bitmap;
 };
 
+struct hmm_dummy_rmem {
+	struct hmm_rmem		rmem;
+	unsigned long		fuid;
+	unsigned long		luid;
+	uint16_t		*rmem_idx;
+};
 
 /* We only create 2 device to show the inter device rmem sharing/migration
  * capabilities.
@@ -482,6 +492,51 @@ static void hmm_dummy_pt_free(struct hmm_dummy_mirror *dmirror,
 }
 
 
+/* hmm_dummy_rmem - dummy remote memory using system memory pages
+ *
+ * Helper function to allocate fake remote memory out of the device rmem_pages.
+ */
+static void hmm_dummy_rmem_free(struct hmm_dummy_rmem *drmem)
+{
+	struct hmm_dummy_device *ddevice;
+	struct hmm_rmem *rmem = &drmem->rmem;
+	unsigned long i, npages;
+
+	npages = (rmem->luid - rmem->fuid);
+	ddevice = container_of(rmem->device, struct hmm_dummy_device, device);
+	mutex_lock(&ddevice->mutex);
+	for (i = 0; i < npages; ++i) {
+		clear_bit(drmem->rmem_idx[i], ddevice->rmem_bitmap);
+	}
+	mutex_unlock(&ddevice->mutex);
+
+	kfree(drmem->rmem_idx);
+	drmem->rmem_idx = NULL;
+}
+
+static struct hmm_dummy_rmem *hmm_dummy_rmem_new(void)
+{
+	struct hmm_dummy_rmem *drmem;
+
+	drmem = kzalloc(sizeof(*drmem), GFP_KERNEL);
+	return drmem;
+}
+
+static int hmm_dummy_mirror_lmem_to_rmem(struct hmm_dummy_mirror *dmirror,
+					 unsigned long faddr,
+					 unsigned long laddr)
+{
+	struct hmm_mirror *mirror = &dmirror->mirror;
+	struct hmm_fault fault;
+	int ret;
+
+	fault.faddr = faddr & PAGE_MASK;
+	fault.laddr = PAGE_ALIGN(laddr);
+	ret = hmm_migrate_lmem_to_rmem(&fault, mirror);
+	return ret;
+}
+
+
 /* hmm_ops - hmm callback for the hmm dummy driver.
  *
  * Below are the various callback that the hmm api require for a device. The
@@ -574,7 +629,7 @@ static struct hmm_fence *hmm_dummy_lmem_update(struct hmm_mirror *mirror,
 
 			page = hmm_dummy_pte_to_page(*pldp);
 			if (page) {
-				set_page_dirty(page);
+				set_page_dirty_lock(page);
 			}
 		}
 		*pldp &= ~HMM_DUMMY_PTE_DIRTY;
@@ -631,6 +686,318 @@ static int hmm_dummy_lmem_fault(struct hmm_mirror *mirror,
 	return 0;
 }
 
+static struct hmm_rmem *hmm_dummy_rmem_alloc(struct hmm_device *device,
+					     struct hmm_fault *fault)
+{
+	struct hmm_dummy_device *ddevice;
+	struct hmm_dummy_rmem *drmem;
+	struct hmm_rmem *rmem;
+	unsigned long i, npages;
+
+	ddevice = container_of(device, struct hmm_dummy_device, device);
+
+	drmem = hmm_dummy_rmem_new();
+	if (drmem == NULL) {
+		return ERR_PTR(-ENOMEM);
+	}
+	rmem = &drmem->rmem;
+
+	npages = (fault->laddr - fault->faddr) >> PAGE_SHIFT;
+	drmem->rmem_idx = kmalloc(npages * sizeof(uint16_t), GFP_KERNEL);
+	if (drmem->rmem_idx == NULL) {
+		kfree(drmem);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	mutex_lock(&ddevice->mutex);
+	for (i = 0; i < npages; ++i) {
+		int r;
+
+		r = find_first_zero_bit(ddevice->rmem_bitmap,
+					HMM_DUMMY_DEVICE_RMEM_NBITS);
+		if (r < 0) {
+			while ((--i)) {
+				clear_bit(drmem->rmem_idx[i],
+					  ddevice->rmem_bitmap);
+			}
+			kfree(drmem->rmem_idx);
+			kfree(drmem);
+			mutex_unlock(&ddevice->mutex);
+			return ERR_PTR(-ENOMEM);
+		}
+		drmem->rmem_idx[i] = r;
+	}
+	mutex_unlock(&ddevice->mutex);
+
+	return rmem;
+}
+
+static struct hmm_fence *hmm_dummy_rmem_update(struct hmm_mirror *mirror,
+					       struct hmm_rmem *rmem,
+					       unsigned long faddr,
+					       unsigned long laddr,
+					       unsigned long fuid,
+					       enum hmm_etype etype,
+					       bool dirty)
+{
+	struct hmm_dummy_mirror *dmirror;
+	struct hmm_dummy_pt_map pt_map = {0};
+	unsigned long addr, i, mask, or, idx;
+
+	dmirror = container_of(mirror, struct hmm_dummy_mirror, mirror);
+	pt_map.dmirror = dmirror;
+	idx = fuid - rmem->fuid;
+
+	/* Sanity check for debugging hmm real device driver do not have to do that. */
+	switch (etype) {
+	case HMM_UNREGISTER:
+	case HMM_UNMAP:
+	case HMM_MUNMAP:
+	case HMM_MPROT_WONLY:
+	case HMM_MIGRATE_TO_RMEM:
+	case HMM_MIGRATE_TO_LMEM:
+		mask = 0;
+		or = 0;
+		break;
+	case HMM_MPROT_RONLY:
+	case HMM_WRITEBACK:
+		mask = ~HMM_DUMMY_PTE_WRITE;
+		or = 0;
+		break;
+	case HMM_MPROT_RANDW:
+		mask = -1L;
+		or = HMM_DUMMY_PTE_WRITE;
+		break;
+	default:
+		printk(KERN_ERR "%4d:%s invalid event type %d\n",
+		       __LINE__, __func__, etype);
+		return ERR_PTR(-EIO);
+	}
+
+	mutex_lock(&dmirror->mutex);
+	for (i = 0, addr = faddr; addr < laddr; ++i, addr += PAGE_SIZE, ++idx) {
+		unsigned long *pldp;
+
+		pldp = hmm_dummy_pt_pld_map(&pt_map, addr);
+		if (!pldp) {
+			continue;
+		}
+		if (dirty && ((*pldp) & HMM_DUMMY_PTE_DIRTY)) {
+			hmm_pfn_set_dirty(&rmem->pfns[idx]);
+		}
+		*pldp &= ~HMM_DUMMY_PTE_DIRTY;
+		*pldp &= mask;
+		*pldp |= or;
+	}
+	hmm_dummy_pt_unmap(&pt_map);
+
+	switch (etype) {
+	case HMM_UNREGISTER:
+	case HMM_MUNMAP:
+		hmm_dummy_pt_free(dmirror, faddr, laddr);
+		break;
+	default:
+		break;
+	}
+	mutex_unlock(&dmirror->mutex);
+	return NULL;
+}
+
+static int hmm_dummy_rmem_fault(struct hmm_mirror *mirror,
+				struct hmm_rmem *rmem,
+				unsigned long faddr,
+				unsigned long laddr,
+				unsigned long fuid,
+				struct hmm_fault *fault)
+{
+	struct hmm_dummy_mirror *dmirror;
+	struct hmm_dummy_device *ddevice;
+	struct hmm_dummy_pt_map pt_map = {0};
+	struct hmm_dummy_rmem *drmem;
+	unsigned long i;
+	bool write = fault ? !!(fault->flags & HMM_FAULT_WRITE) : false;
+
+	dmirror = container_of(mirror, struct hmm_dummy_mirror, mirror);
+	drmem = container_of(rmem, struct hmm_dummy_rmem, rmem);
+	ddevice = dmirror->ddevice;
+	pt_map.dmirror = dmirror;
+
+	mutex_lock(&dmirror->mutex);
+	for (i = fuid; faddr < laddr; ++i, faddr += PAGE_SIZE) {
+		unsigned long *pldp, pld_idx, pfn, idx = i - rmem->fuid;
+
+		pldp = hmm_dummy_pt_pld_map(&pt_map, faddr);
+		if (!pldp) {
+			continue;
+		}
+		pfn = page_to_pfn(ddevice->rmem_pages[drmem->rmem_idx[idx]]);
+		pld_idx = hmm_dummy_pld_index(faddr);
+		pldp[pld_idx]  = (pfn << HMM_DUMMY_PFN_SHIFT);
+		if (test_bit(HMM_PFN_WRITE, &rmem->pfns[idx])) {
+			pldp[pld_idx] |=  HMM_DUMMY_PTE_WRITE;
+			hmm_pfn_clear_lmem_uptodate(&rmem->pfns[idx]);
+		}
+		pldp[pld_idx] |= HMM_DUMMY_PTE_VALID_PAGE;
+		if (write && !test_bit(HMM_PFN_WRITE, &rmem->pfns[idx])) {
+			/* Fallback to use system memory. Other solution would be
+			 * to migrate back to system memory.
+			 */
+			hmm_pfn_clear_rmem_uptodate(&rmem->pfns[idx]);
+			if (!test_bit(HMM_PFN_LMEM_UPTODATE, &rmem->pfns[idx])) {
+				struct page *spage, *dpage;
+
+				dpage = hmm_pfn_to_page(rmem->pfns[idx]);
+				spage = ddevice->rmem_pages[drmem->rmem_idx[idx]];
+				copy_highpage(dpage, spage);
+				hmm_pfn_set_lmem_uptodate(&rmem->pfns[idx]);
+			}
+			pfn = rmem->pfns[idx] >> HMM_PFN_SHIFT;
+			pldp[pld_idx]  = (pfn << HMM_DUMMY_PFN_SHIFT);
+			pldp[pld_idx] |= HMM_DUMMY_PTE_WRITE;
+			pldp[pld_idx] |= HMM_DUMMY_PTE_VALID_PAGE;
+		}
+	}
+	hmm_dummy_pt_unmap(&pt_map);
+	mutex_unlock(&dmirror->mutex);
+	return 0;
+}
+
+struct hmm_fence *hmm_dummy_rmem_to_lmem(struct hmm_rmem *rmem,
+					 unsigned long fuid,
+					 unsigned long luid)
+{
+	struct hmm_dummy_device *ddevice;
+	struct hmm_dummy_rmem *drmem;
+	unsigned long i;
+
+	ddevice = container_of(rmem->device, struct hmm_dummy_device, device);
+	drmem = container_of(rmem, struct hmm_dummy_rmem, rmem);
+
+	for (i = fuid; i < luid; ++i) {
+		unsigned long idx = i - rmem->fuid;
+		struct page *spage, *dpage;
+
+		if (test_bit(HMM_PFN_LMEM_UPTODATE, &rmem->pfns[idx])) {
+			/* This lmem page is already uptodate. */
+			continue;
+		}
+		spage = ddevice->rmem_pages[drmem->rmem_idx[idx]];
+		dpage = hmm_pfn_to_page(rmem->pfns[idx]);
+		if (!dpage) {
+			return ERR_PTR(-EINVAL);
+		}
+		copy_highpage(dpage, spage);
+		hmm_pfn_set_lmem_uptodate(&rmem->pfns[idx]);
+	}
+
+	return NULL;
+}
+
+struct hmm_fence *hmm_dummy_lmem_to_rmem(struct hmm_rmem *rmem,
+					 unsigned long fuid,
+					 unsigned long luid)
+{
+	struct hmm_dummy_device *ddevice;
+	struct hmm_dummy_rmem *drmem;
+	unsigned long i;
+
+	ddevice = container_of(rmem->device, struct hmm_dummy_device, device);
+	drmem = container_of(rmem, struct hmm_dummy_rmem, rmem);
+
+	for (i = fuid; i < luid; ++i) {
+		unsigned long idx = i - rmem->fuid;
+		struct page *spage, *dpage;
+
+		if (test_bit(HMM_PFN_RMEM_UPTODATE, &rmem->pfns[idx])) {
+			/* This rmem page is already uptodate. */
+			continue;
+		}
+		dpage = ddevice->rmem_pages[drmem->rmem_idx[idx]];
+		spage = hmm_pfn_to_page(rmem->pfns[idx]);
+		if (!spage) {
+			return ERR_PTR(-EINVAL);
+		}
+		copy_highpage(dpage, spage);
+		hmm_pfn_set_rmem_uptodate(&rmem->pfns[idx]);
+	}
+
+	return NULL;
+}
+
+static int hmm_dummy_rmem_do_split(struct hmm_rmem *rmem,
+				   unsigned long fuid,
+				   unsigned long luid)
+{
+	struct hmm_dummy_rmem *drmem, *dnew;
+	struct hmm_fault fault;
+	struct hmm_rmem *new;
+	unsigned long i, pgoff, npages;
+	int ret;
+
+	drmem = container_of(rmem, struct hmm_dummy_rmem, rmem);
+	npages = (luid - fuid);
+	pgoff = (fuid == rmem->fuid) ? 0 : fuid - rmem->fuid;
+	fault.faddr = 0;
+	fault.laddr = npages << PAGE_SHIFT;
+	new = hmm_dummy_rmem_alloc(rmem->device, &fault);
+	if (IS_ERR(new)) {
+		return PTR_ERR(new);
+	}
+	dnew = container_of(new, struct hmm_dummy_rmem, rmem);
+
+	new->fuid = fuid;
+	new->luid = luid;
+	ret = hmm_rmem_split_new(rmem, new);
+	if (ret) {
+		return ret;
+	}
+
+	/* Update the rmem it is fine to hold no lock as no one else can access
+	 * both of this rmem object as long as the range are reserved.
+	 */
+	for (i = 0; i < npages; ++i) {
+		dnew->rmem_idx[i] = drmem->rmem_idx[i + pgoff];
+	}
+	if (!pgoff) {
+		for (i = 0; i < (rmem->luid - rmem->fuid); ++i) {
+			drmem->rmem_idx[i] = drmem->rmem_idx[i + npages];
+		}
+	}
+
+	return 0;
+}
+
+static int hmm_dummy_rmem_split(struct hmm_rmem *rmem,
+				unsigned long fuid,
+				unsigned long luid)
+{
+	int ret;
+
+	if (fuid > rmem->fuid) {
+		ret = hmm_dummy_rmem_do_split(rmem, rmem->fuid, fuid);
+		if (ret) {
+			return ret;
+		}
+	}
+	if (luid < rmem->luid) {
+		ret = hmm_dummy_rmem_do_split(rmem, luid, rmem->luid);
+		if (ret) {
+			return ret;
+		}
+	}
+
+	return 0;
+}
+
+static void hmm_dummy_rmem_destroy(struct hmm_rmem *rmem)
+{
+	struct hmm_dummy_rmem *drmem;
+
+	drmem = container_of(rmem, struct hmm_dummy_rmem, rmem);
+	hmm_dummy_rmem_free(drmem);
+	kfree(drmem);
+}
+
 static const struct hmm_device_ops hmm_dummy_ops = {
 	.device_destroy		= &hmm_dummy_device_destroy,
 	.mirror_release		= &hmm_dummy_mirror_release,
@@ -638,6 +1005,14 @@ static const struct hmm_device_ops hmm_dummy_ops = {
 	.fence_wait		= &hmm_dummy_fence_wait,
 	.lmem_update		= &hmm_dummy_lmem_update,
 	.lmem_fault		= &hmm_dummy_lmem_fault,
+	.rmem_alloc		= &hmm_dummy_rmem_alloc,
+	.rmem_update		= &hmm_dummy_rmem_update,
+	.rmem_fault		= &hmm_dummy_rmem_fault,
+	.rmem_to_lmem		= &hmm_dummy_rmem_to_lmem,
+	.lmem_to_rmem		= &hmm_dummy_lmem_to_rmem,
+	.rmem_split		= &hmm_dummy_rmem_split,
+	.rmem_split_adjust	= &hmm_dummy_rmem_split,
+	.rmem_destroy		= &hmm_dummy_rmem_destroy,
 };
 
 
@@ -880,7 +1255,7 @@ static ssize_t hmm_dummy_fops_write(struct file *filp,
 		if (!(pldp[pld_idx] & HMM_DUMMY_PTE_WRITE)) {
 			hmm_dummy_pt_unmap(&pt_map);
 			mutex_unlock(&dmirror->mutex);
-				goto fault;
+			goto fault;
 		}
 		pldp[pld_idx] |= HMM_DUMMY_PTE_DIRTY;
 		page = hmm_dummy_pte_to_page(pldp[pld_idx]);
@@ -964,8 +1339,11 @@ static long hmm_dummy_fops_unlocked_ioctl(struct file *filp,
 					  unsigned int command,
 					  unsigned long arg)
 {
+	struct hmm_dummy_migrate dmigrate;
 	struct hmm_dummy_device *ddevice;
 	struct hmm_dummy_mirror *dmirror;
+	struct hmm_mirror *mirror;
+	void __user *uarg = (void __user *)arg;
 	unsigned minor;
 	int ret;
 
@@ -1011,6 +1389,31 @@ static long hmm_dummy_fops_unlocked_ioctl(struct file *filp,
 				       "mirroring address space of %d\n",
 				       dmirror->pid);
 		return 0;
+	case HMM_DUMMY_MIGRATE_TO_RMEM:
+		mutex_lock(&ddevice->mutex);
+		dmirror = ddevice->dmirrors[minor];
+		if (!dmirror) {
+			mutex_unlock(&ddevice->mutex);
+			return -EINVAL;
+		}
+		mirror = &dmirror->mirror;
+		mutex_unlock(&ddevice->mutex);
+
+		if (copy_from_user(&dmigrate, uarg, sizeof(dmigrate))) {
+			return -EFAULT;
+		}
+
+		ret = hmm_dummy_pt_alloc(dmirror,
+					 dmigrate.faddr,
+					 dmigrate.laddr);
+		if (ret) {
+			return ret;
+		}
+
+		ret = hmm_dummy_mirror_lmem_to_rmem(dmirror,
+						    dmigrate.faddr,
+						    dmigrate.laddr);
+		return ret;
 	default:
 		return -EINVAL;
 	}
@@ -1034,7 +1437,31 @@ static const struct file_operations hmm_dummy_fops = {
  */
 static int hmm_dummy_device_init(struct hmm_dummy_device *ddevice)
 {
-	int ret, i;
+	struct page **pages;
+	unsigned long *bitmap;
+	int ret, i, npages;
+
+	npages = HMM_DUMMY_DEVICE_RMEM_SIZE >> PAGE_SHIFT;
+	bitmap = kzalloc(BITS_TO_LONGS(npages) * sizeof(long), GFP_KERNEL);
+	if (!bitmap) {
+		return -ENOMEM;
+	}
+	pages = kzalloc(npages * sizeof(void*), GFP_KERNEL);
+	if (!pages) {
+		kfree(bitmap);
+		return -ENOMEM;
+	}
+	for (i = 0; i < npages; ++i) {
+		pages[i] = alloc_page(GFP_KERNEL);
+		if (!pages[i]) {
+			while ((--i)) {
+				__free_page(pages[i]);
+			}
+			kfree(bitmap);
+			kfree(pages);
+			return -ENOMEM;
+		}
+	}
 
 	ret = alloc_chrdev_region(&ddevice->dev, 0,
 				  HMM_DUMMY_DEVICE_MAX_MIRRORS,
@@ -1066,15 +1493,23 @@ static int hmm_dummy_device_init(struct hmm_dummy_device *ddevice)
 		goto error;
 	}
 
+	ddevice->rmem_bitmap = bitmap;
+	ddevice->rmem_pages = pages;
+
 	return 0;
 
 error:
+	for (i = 0; i < npages; ++i) {
+		__free_page(pages[i]);
+	}
+	kfree(bitmap);
+	kfree(pages);
 	return ret;
 }
 
 static void hmm_dummy_device_fini(struct hmm_dummy_device *ddevice)
 {
-	unsigned i;
+	unsigned i, npages;
 
 	/* First finish hmm. */
 	for (i = 0; i < HMM_DUMMY_DEVICE_MAX_MIRRORS; i++) {
@@ -1092,6 +1527,13 @@ static void hmm_dummy_device_fini(struct hmm_dummy_device *ddevice)
 	cdev_del(&ddevice->cdev);
 	unregister_chrdev_region(ddevice->dev,
 				 HMM_DUMMY_DEVICE_MAX_MIRRORS);
+
+	npages = HMM_DUMMY_DEVICE_RMEM_SIZE >> PAGE_SHIFT;
+	for (i = 0; i < npages; ++i) {
+		__free_page(ddevice->rmem_pages[i]);
+	}
+	kfree(ddevice->rmem_bitmap);
+	kfree(ddevice->rmem_pages);
 }
 
 static int __init hmm_dummy_init(void)
diff --git a/include/uapi/linux/hmm_dummy.h b/include/uapi/linux/hmm_dummy.h
index 16ae0d3..027c453 100644
--- a/include/uapi/linux/hmm_dummy.h
+++ b/include/uapi/linux/hmm_dummy.h
@@ -29,6 +29,12 @@
 #include <linux/irqnr.h>
 
 /* Expose the address space of the calling process through hmm dummy dev file */
-#define HMM_DUMMY_EXPOSE_MM	_IO( 'R', 0x00 )
+#define HMM_DUMMY_EXPOSE_MM		_IO( 'R', 0x00 )
+#define HMM_DUMMY_MIGRATE_TO_RMEM	_IO( 'R', 0x01 )
+
+struct hmm_dummy_migrate {
+	uint64_t		faddr;
+	uint64_t		laddr;
+};
 
 #endif /* _UAPI_LINUX_RANDOM_H */
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
