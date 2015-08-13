Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id B19F782F61
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 15:38:31 -0400 (EDT)
Received: by qkbm65 with SMTP id m65so18982527qkb.2
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 12:38:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l5si5454111qhl.59.2015.08.13.12.38.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 12:38:30 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 15/15] HMM/dummy: add fake device memory to dummy HMM device driver.
Date: Thu, 13 Aug 2015 15:37:31 -0400
Message-Id: <1439494651-1255-16-git-send-email-jglisse@redhat.com>
In-Reply-To: <1439494651-1255-1-git-send-email-jglisse@redhat.com>
References: <1439494651-1255-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

This patch add fake device memory by simply using regular system memory
page and pretending they are not accessible by the CPU directly. This
serve to showcase how migration to device memory can be impemented inside
a real device driver.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 drivers/char/hmm_dummy.c       | 395 +++++++++++++++++++++++++++++++++++++++--
 include/uapi/linux/hmm_dummy.h |  17 +-
 2 files changed, 391 insertions(+), 21 deletions(-)

diff --git a/drivers/char/hmm_dummy.c b/drivers/char/hmm_dummy.c
index 52843cb..a4af5b1 100644
--- a/drivers/char/hmm_dummy.c
+++ b/drivers/char/hmm_dummy.c
@@ -43,6 +43,9 @@
 #define HMM_DUMMY_MAX_DEVICES 4
 #define HMM_DUMMY_MAX_MIRRORS 4
 
+#define HMM_DUMMY_RMEM_SIZE (32UL << 20UL)
+#define HMM_DUMMY_RMEM_NBITS (HMM_DUMMY_RMEM_SIZE >> PAGE_SHIFT)
+
 struct dummy_device;
 
 struct dummy_mirror {
@@ -70,6 +73,8 @@ struct dummy_device {
 	/* device file mapping tracking (keep track of all vma) */
 	struct dummy_mirror	*dmirrors[HMM_DUMMY_MAX_MIRRORS];
 	struct address_space	*fmapping[HMM_DUMMY_MAX_MIRRORS];
+	struct page		**rmem_pages;
+	unsigned long		*rmem_bitmap;
 };
 
 struct dummy_event {
@@ -77,11 +82,30 @@ struct dummy_event {
 	struct list_head	list;
 	uint64_t		nsys_pages;
 	uint64_t		nfaulted_sys_pages;
+	uint64_t		ndev_pages;
+	uint64_t		nfaulted_dev_pages;
+	unsigned		*dpfn;
+	unsigned		npages;
 	bool			backoff;
 };
 
 static struct dummy_device ddevices[HMM_DUMMY_MAX_DEVICES];
 
+/* dummy_device_pfn_to_page() - Return struct page of fake device memory.
+ *
+ * @ddevice: The dummy device.
+ * @pfn: The fake device page frame number.
+ * Return: The pointer to the struct page of the fake device memory.
+ *
+ * For the dummy device remote memory we simply allocate regular page and
+ * pretend they are not accessible directly by the CPU.
+ */
+struct page *dummy_device_pfn_to_page(struct dummy_device *ddevice,
+				      unsigned pfn)
+{
+	return ddevice->rmem_pages[pfn];
+}
+
 
 static void dummy_mirror_release(struct hmm_mirror *mirror)
 {
@@ -233,9 +257,11 @@ static int dummy_mirror_pt_invalidate(struct hmm_mirror *mirror,
 	unsigned long addr = event->start;
 	struct hmm_pt_iter miter, diter;
 	struct dummy_mirror *dmirror;
+	struct dummy_device *ddevice;
 	int ret = 0;
 
 	dmirror = container_of(mirror, struct dummy_mirror, mirror);
+	ddevice = dmirror->ddevice;
 
 	hmm_pt_iter_init(&diter, &dmirror->pt);
 	hmm_pt_iter_init(&miter, &mirror->pt);
@@ -259,6 +285,24 @@ static int dummy_mirror_pt_invalidate(struct hmm_mirror *mirror,
 		 */
 		hmm_pt_iter_directory_lock(&diter);
 
+		/* Handle the fake device memory page table entry case. */
+		if (hmm_pte_test_valid_dev(dpte)) {
+			unsigned dpfn = hmm_pte_dev_addr(*dpte) >> PAGE_SHIFT;
+
+			*dpte &= event->pte_mask;
+			if (!hmm_pte_test_valid_dev(dpte)) {
+				/*
+				 * Just directly free the fake device memory.
+				 */
+				clear_bit(dpfn, ddevice->rmem_bitmap);
+				hmm_pt_iter_directory_unref(&diter);
+			}
+			hmm_pt_iter_directory_unlock(&diter);
+
+			addr += PAGE_SIZE;
+			continue;
+		}
+
 		/*
 		 * Just skip this entry if it is not valid inside the dummy
 		 * mirror page table.
@@ -341,10 +385,178 @@ static int dummy_mirror_update(struct hmm_mirror *mirror,
 	}
 }
 
+static int dummy_copy_from_device(struct hmm_mirror *mirror,
+				  const struct hmm_event *event,
+				  dma_addr_t *dst,
+				  unsigned long start,
+				  unsigned long end)
+{
+	struct hmm_pt_iter miter, diter;
+	struct dummy_device *ddevice;
+	struct dummy_mirror *dmirror;
+	struct dummy_event *devent;
+	unsigned long addr = start;
+	int ret = 0, i = 0;
+
+	dmirror = container_of(mirror, struct dummy_mirror, mirror);
+	devent = container_of(event, struct dummy_event, hevent);
+	ddevice = dmirror->ddevice;
+
+	hmm_pt_iter_init(&diter, &dmirror->pt);
+	hmm_pt_iter_init(&miter, &mirror->pt);
+
+	do {
+		struct page *spage, *dpage;
+		unsigned long dpfn, next = end;
+		dma_addr_t *mpte, *dpte;
+
+		mpte = hmm_pt_iter_lookup(&miter, addr, &next);
+		if (!mpte || !hmm_pte_test_valid_dev(mpte) ||
+		    !hmm_pte_test_select(&dst[i])) {
+			i++;
+			continue;
+		}
+
+		dpte = hmm_pt_iter_lookup(&diter, addr, &next);
+		/*
+		 * Sanity check, that that device driver page table is a valid
+		 * entry pointing to device memory.
+		 */
+		if (!dpte || !hmm_pte_test_valid_dev(dpte) ||
+		    !hmm_pte_test_select(&dst[i])) {
+			ret = -EINVAL;
+			break;
+		}
+
+		dpfn = hmm_pte_dev_addr(*mpte) >> PAGE_SHIFT;
+		spage = dummy_device_pfn_to_page(ddevice, dpfn);
+		dpage = pfn_to_page(hmm_pte_pfn(dst[i]));
+		copy_highpage(dpage, spage);
+
+		/* Directly free the fake device memory. */
+		clear_bit(dpfn, ddevice->rmem_bitmap);
+
+		if (hmm_pte_test_and_clear_dirty(dpte))
+			hmm_pte_set_dirty(&dst[i]);
+
+		/*
+		 * This is bit inefficient to lock directoy per entry instead
+		 * of locking directory and going over all its entry. But this
+		 * is a dummy driver and we do not care about efficiency here.
+		 */
+		hmm_pt_iter_directory_lock(&diter);
+		*dpte = dst[i];
+		hmm_pte_clear_dirty(dpte);
+		hmm_pt_iter_directory_unlock(&diter);
+
+		i++;
+	} while (addr += PAGE_SIZE, addr < end);
+
+	hmm_pt_iter_fini(&miter);
+	hmm_pt_iter_fini(&diter);
+
+	return ret;
+}
+
+static int dummy_copy_to_device(struct hmm_mirror *mirror,
+				const struct hmm_event *event,
+				struct vm_area_struct *vma,
+				dma_addr_t *dst,
+				unsigned long start,
+				unsigned long end)
+{
+	struct hmm_pt_iter miter, diter;
+	struct dummy_device *ddevice;
+	struct dummy_mirror *dmirror;
+	struct dummy_event *devent;
+	unsigned long addr = start;
+	int ret = 0, i = 0;
+
+	dmirror = container_of(mirror, struct dummy_mirror, mirror);
+	devent = container_of(event, struct dummy_event, hevent);
+	ddevice = dmirror->ddevice;
+
+	hmm_pt_iter_init(&diter, &dmirror->pt);
+	hmm_pt_iter_init(&miter, &mirror->pt);
+
+	do {
+		struct page *spage, *dpage;
+		dma_addr_t *mpte, *dpte;
+		unsigned long next = end;
+
+		mpte = hmm_pt_iter_lookup(&miter, addr, &next);
+		/*
+		 * Sanity check, this is only important for debugging HMM, a
+		 * device driver can ignore those test and assume everything
+		 * below is false (ie mpte is not NULL and it is a valid pfn
+		 * entry with the select bit set).
+		 */
+		if (!mpte || !hmm_pte_test_valid_pfn(mpte) ||
+		    !hmm_pte_test_select(mpte)) {
+			pr_debug("(%s:%4d) (HMM FATAL) empty pt at 0x%lX\n",
+				 __FILE__, __LINE__, addr);
+			ret = -EINVAL;
+			break;
+		}
+
+		dpte = hmm_pt_iter_populate(&diter, addr, &next);
+		if (!dpte) {
+			ret = -ENOMEM;
+			break;
+		}
+		/*
+		 * Sanity check, this is only important for debugging HMM, a
+		 * device driver can ignore those test and assume everything
+		 * below is false (ie dpte is not a valid device entry).
+		 */
+		if (hmm_pte_test_valid_dev(dpte)) {
+			pr_debug("(%s:%4d) (DUMMY FATAL) existing device entry %pad at 0x%lX\n",
+				 __FILE__, __LINE__, dpte, addr);
+			ret = -EINVAL;
+			break;
+		}
+
+		spage = pfn_to_page(hmm_pte_pfn(*mpte));
+		dpage = dummy_device_pfn_to_page(ddevice, devent->dpfn[i]);
+		dst[i] = hmm_pte_from_dev_addr(devent->dpfn[i] << PAGE_SHIFT);
+		copy_highpage(dpage, spage);
+		devent->dpfn[i] = -1;
+		devent->nfaulted_dev_pages++;
+
+		/*
+		 * This is bit inefficient to lock directoy per entry instead
+		 * of locking directory and going over all its entry. But this
+		 * is a dummy driver and we do not care about efficiency here.
+		 */
+		hmm_pt_iter_directory_lock(&diter);
+		if (hmm_pte_test_and_clear_dirty(dpte))
+			hmm_pte_set_dirty(&dst[i]);
+		if (vma->vm_flags & VM_WRITE)
+			hmm_pte_set_write(&dst[i]);
+		/*
+		 * Increment ref count of dummy page table directory if the
+		 * previous entry was not valid. Note that previous entry
+		 * can not be a valid device memory entry.
+		 */
+		if (!hmm_pte_test_valid_pfn(dpte))
+			hmm_pt_iter_directory_ref(&diter);
+		*dpte = dst[i];
+		hmm_pt_iter_directory_unlock(&diter);
+
+	} while (i++, addr += PAGE_SIZE, addr < end);
+
+	hmm_pt_iter_fini(&miter);
+	hmm_pt_iter_fini(&diter);
+
+	return ret;
+}
+
 static const struct hmm_device_ops hmm_dummy_ops = {
 	.release		= &dummy_mirror_release,
 	.free			= &dummy_mirror_free,
 	.update			= &dummy_mirror_update,
+	.copy_from_device	= &dummy_copy_from_device,
+	.copy_to_device		= &dummy_copy_to_device,
 };
 
 
@@ -443,6 +655,7 @@ static int dummy_read(struct dummy_mirror *dmirror,
 		      char __user *buf,
 		      size_t size)
 {
+	struct dummy_device *ddevice = dmirror->ddevice;
 	struct hmm_event *event = &devent->hevent;
 	long r = 0;
 
@@ -483,14 +696,21 @@ static int dummy_read(struct dummy_mirror *dmirror,
 			 * coherent value for each page table entry.
 			 */
 			dpte = ACCESS_ONCE(*dptep);
-			if (!hmm_pte_test_valid_pfn(&dpte)) {
+
+			if (hmm_pte_test_valid_dev(&dpte)) {
+				dma_addr_t dpfn;
+
+				dpfn = hmm_pte_dev_addr(dpte) >> PAGE_SHIFT;
+				page = dummy_device_pfn_to_page(ddevice, dpfn);
+				devent->ndev_pages++;
+			} else if (hmm_pte_test_valid_pfn(&dpte)) {
+				page = pfn_to_page(hmm_pte_pfn(dpte));
+				devent->nsys_pages++;
+			} else {
 				dummy_mirror_access_stop(dmirror, devent);
 				break;
 			}
 
-			devent->nsys_pages++;
-
-			page = pfn_to_page(hmm_pte_pfn(dpte));
 			ptr = kmap(page);
 			r = copy_to_user(buf, ptr + offset, count);
 
@@ -515,6 +735,7 @@ static int dummy_write(struct dummy_mirror *dmirror,
 		       char __user *buf,
 		       size_t size)
 {
+	struct dummy_device *ddevice = dmirror->ddevice;
 	struct hmm_event *event = &devent->hevent;
 	long r = 0;
 
@@ -555,15 +776,25 @@ static int dummy_write(struct dummy_mirror *dmirror,
 			 * coherent value for each page table entry.
 			 */
 			dpte = ACCESS_ONCE(*dptep);
-			if (!hmm_pte_test_valid_pfn(&dpte) ||
-			    !hmm_pte_test_write(&dpte)) {
+			if (!hmm_pte_test_write(&dpte)) {
+				dummy_mirror_access_stop(dmirror, devent);
+				break;
+			}
+			
+			if (hmm_pte_test_valid_dev(&dpte)) {
+				dma_addr_t dpfn;
+
+				dpfn = hmm_pte_dev_addr(dpte) >> PAGE_SHIFT;
+				page = dummy_device_pfn_to_page(ddevice, dpfn);
+				devent->ndev_pages++;
+			} else if (hmm_pte_test_valid_pfn(&dpte)) {
+				page = pfn_to_page(hmm_pte_pfn(dpte));
+				devent->nsys_pages++;
+			} else {
 				dummy_mirror_access_stop(dmirror, devent);
 				break;
 			}
 
-			devent->nsys_pages++;
-
-			page = pfn_to_page(hmm_pte_pfn(dpte));
 			ptr = kmap(page);
 			r = copy_from_user(ptr + offset, buf, count);
 
@@ -583,6 +814,58 @@ static int dummy_write(struct dummy_mirror *dmirror,
 	return r;
 }
 
+static int dummy_lmem_to_rmem(struct dummy_mirror *dmirror,
+			      struct dummy_event *devent)
+{
+	struct dummy_device *ddevice = dmirror->ddevice;
+	struct hmm_mirror *mirror = &dmirror->mirror;
+	int i, ret;
+
+	devent->hevent.start = PAGE_MASK & devent->hevent.start;
+	devent->hevent.end = PAGE_ALIGN(devent->hevent.end);
+	devent->hevent.etype = HMM_COPY_TO_DEVICE;
+
+	/* Simple bitmap allocator for fake device memory. */
+	devent->dpfn = kcalloc(devent->npages, sizeof(unsigned), GFP_KERNEL);
+	if (devent->dpfn == NULL) {
+		return -ENOMEM;
+	}
+
+	/*
+	 * Pre-allocate device memory. Device driver is free to pre-allocate
+	 * memory or to allocate it inside the copy callback.
+	 */
+	mutex_lock(&ddevice->mutex);
+	for (i = 0; i < devent->npages; ++i) {
+		int idx;
+
+		idx = find_first_zero_bit(ddevice->rmem_bitmap,
+					  HMM_DUMMY_RMEM_NBITS);
+		if (idx < 0) {
+			while ((--i) > 0) {
+				idx = devent->dpfn[i];
+				clear_bit(idx, ddevice->rmem_bitmap);
+			}
+			mutex_unlock(&ddevice->mutex);
+			kfree(devent->dpfn);
+			return -ENOMEM;
+		}
+		devent->dpfn[i] = idx;
+		set_bit(idx, ddevice->rmem_bitmap);
+	}
+	mutex_unlock(&ddevice->mutex);
+
+	ret = hmm_mirror_fault(mirror, &devent->hevent);
+	for (i = 0; i < devent->npages; ++i) {
+		if (devent->dpfn[i] == -1U)
+			continue;
+		clear_bit(devent->dpfn[i], ddevice->rmem_bitmap);
+	}
+	kfree(devent->dpfn);
+
+	return ret;
+}
+
 
 /*
  * Below are the vm operation for the dummy device file. Sadly we can not allow
@@ -695,11 +978,26 @@ static int dummy_fops_release(struct inode *inode, struct file *filp)
 	return 0;
 }
 
+struct dummy_ioctlp {
+	uint64_t		address;
+	uint64_t		size;
+};
+
+static void dummy_event_init(struct dummy_event *devent,
+			     const struct dummy_ioctlp *ioctlp)
+{
+	memset(devent, 0, sizeof(*devent));
+	devent->hevent.start = ioctlp->address;
+	devent->hevent.end = ioctlp->address + ioctlp->size;
+	devent->npages = PAGE_ALIGN(ioctlp->size) >> PAGE_SHIFT;
+}
+
 static long dummy_fops_unlocked_ioctl(struct file *filp,
 				      unsigned int command,
 				      unsigned long arg)
 {
 	void __user *uarg = (void __user *)arg;
+	struct hmm_dummy_migrate dmigrate;
 	struct dummy_device *ddevice;
 	struct dummy_mirror *dmirror;
 	struct hmm_dummy_write dwrite;
@@ -765,15 +1063,15 @@ static long dummy_fops_unlocked_ioctl(struct file *filp,
 			return -EFAULT;
 		}
 
-		memset(&devent, 0, sizeof(devent));
-		devent.hevent.start = dread.address;
-		devent.hevent.end = dread.address + dread.size;
+		dummy_event_init(&devent, (struct dummy_ioctlp*)&dread);
 		ret = dummy_read(dmirror, &devent,
 				 (void __user *)dread.ptr,
 				 dread.size);
 
 		dread.nsys_pages = devent.nsys_pages;
 		dread.nfaulted_sys_pages = devent.nfaulted_sys_pages;
+		dread.ndev_pages = devent.ndev_pages;
+		dread.nfaulted_dev_pages = devent.nfaulted_dev_pages;
 		if (copy_to_user(uarg, &dread, sizeof(dread))) {
 			dummy_mirror_worker_thread_stop(dmirror);
 			return -EFAULT;
@@ -787,15 +1085,15 @@ static long dummy_fops_unlocked_ioctl(struct file *filp,
 			return -EFAULT;
 		}
 
-		memset(&devent, 0, sizeof(devent));
-		devent.hevent.start = dwrite.address;
-		devent.hevent.end = dwrite.address + dwrite.size;
+		dummy_event_init(&devent, (struct dummy_ioctlp*)&dwrite);
 		ret = dummy_write(dmirror, &devent,
 				  (void __user *)dwrite.ptr,
 				  dwrite.size);
 
 		dwrite.nsys_pages = devent.nsys_pages;
 		dwrite.nfaulted_sys_pages = devent.nfaulted_sys_pages;
+		dwrite.ndev_pages = devent.ndev_pages;
+		dwrite.nfaulted_dev_pages = devent.nfaulted_dev_pages;
 		if (copy_to_user(uarg, &dwrite, sizeof(dwrite))) {
 			dummy_mirror_worker_thread_stop(dmirror);
 			return -EFAULT;
@@ -803,6 +1101,23 @@ static long dummy_fops_unlocked_ioctl(struct file *filp,
 
 		dummy_mirror_worker_thread_stop(dmirror);
 		return ret;
+	case HMM_DUMMY_MIGRATE_TO:
+		if (copy_from_user(&dmigrate, uarg, sizeof(dmigrate))) {
+			dummy_mirror_worker_thread_stop(dmirror);
+			return -EFAULT;
+		}
+
+		dummy_event_init(&devent, (struct dummy_ioctlp*)&dmigrate);
+		ret = dummy_lmem_to_rmem(dmirror, &devent);
+
+		dmigrate.nfaulted_dev_pages = devent.nfaulted_dev_pages;
+		if (copy_to_user(uarg, &dmigrate, sizeof(dmigrate))) {
+			dummy_mirror_worker_thread_stop(dmirror);
+			return -EFAULT;
+		}
+
+		dummy_mirror_worker_thread_stop(dmirror);
+		return ret;
 	default:
 		return -EINVAL;
 	}
@@ -826,20 +1141,44 @@ static const struct file_operations hmm_dummy_fops = {
  */
 static int dummy_device_init(struct dummy_device *ddevice)
 {
-	int ret, i;
+	struct page **pages;
+	unsigned long *bitmap;
+	int ret, i, npages;
+
+	npages = HMM_DUMMY_RMEM_SIZE >> PAGE_SHIFT;
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
 				  HMM_DUMMY_MAX_DEVICES,
 				  ddevice->name);
 	if (ret < 0)
-		return ret;
+		goto error;
 	ddevice->major = MAJOR(ddevice->dev);
 
 	cdev_init(&ddevice->cdevice, &hmm_dummy_fops);
 	ret = cdev_add(&ddevice->cdevice, ddevice->dev, HMM_DUMMY_MAX_MIRRORS);
 	if (ret) {
 		unregister_chrdev_region(ddevice->dev, HMM_DUMMY_MAX_MIRRORS);
-		return ret;
+		goto error;
 	}
 
 	/* Register the hmm device. */
@@ -853,14 +1192,25 @@ static int dummy_device_init(struct dummy_device *ddevice)
 	if (ret) {
 		cdev_del(&ddevice->cdevice);
 		unregister_chrdev_region(ddevice->dev, HMM_DUMMY_MAX_MIRRORS);
+		goto error;
 	}
+	ddevice->rmem_bitmap = bitmap;
+	ddevice->rmem_pages = pages;
+	return 0;
+
+error:
+	for (i = 0; i < npages; ++i) {
+		__free_page(pages[i]);
+	}
+	kfree(bitmap);
+	kfree(pages);
 	return ret;
 }
 
 static void dummy_device_fini(struct dummy_device *ddevice)
 {
 	struct dummy_mirror *dmirror;
-	unsigned i;
+	unsigned i, npages;
 
 	/* First unregister all mirror. */
 	do {
@@ -880,6 +1230,13 @@ static void dummy_device_fini(struct dummy_device *ddevice)
 
 	cdev_del(&ddevice->cdevice);
 	unregister_chrdev_region(ddevice->dev, HMM_DUMMY_MAX_MIRRORS);
+
+	npages = HMM_DUMMY_RMEM_SIZE >> PAGE_SHIFT;
+	for (i = 0; i < npages; ++i) {
+		__free_page(ddevice->rmem_pages[i]);
+	}
+	kfree(ddevice->rmem_bitmap);
+	kfree(ddevice->rmem_pages);
 }
 
 static int __init hmm_dummy_init(void)
diff --git a/include/uapi/linux/hmm_dummy.h b/include/uapi/linux/hmm_dummy.h
index 3af71d4..a98b03d 100644
--- a/include/uapi/linux/hmm_dummy.h
+++ b/include/uapi/linux/hmm_dummy.h
@@ -31,7 +31,9 @@ struct hmm_dummy_read {
 	uint64_t		ptr;
 	uint64_t		nsys_pages;
 	uint64_t		nfaulted_sys_pages;
-	uint64_t		reserved[11];
+	uint64_t		ndev_pages;
+	uint64_t		nfaulted_dev_pages;
+	uint64_t		reserved[9];
 };
 
 struct hmm_dummy_write {
@@ -40,12 +42,23 @@ struct hmm_dummy_write {
 	uint64_t		ptr;
 	uint64_t		nsys_pages;
 	uint64_t		nfaulted_sys_pages;
-	uint64_t		reserved[11];
+	uint64_t		ndev_pages;
+	uint64_t		nfaulted_dev_pages;
+	uint64_t		reserved[9];
+};
+
+struct hmm_dummy_migrate {
+	uint64_t		address;
+	uint64_t		size;
+	uint64_t		nfaulted_sys_pages;
+	uint64_t		nfaulted_dev_pages;
+	uint64_t		reserved[12];
 };
 
 /* Expose the address space of the calling process through hmm dummy dev file */
 #define HMM_DUMMY_EXPOSE_MM	_IO('H', 0x00)
 #define HMM_DUMMY_READ		_IOWR('H', 0x01, struct hmm_dummy_read)
 #define HMM_DUMMY_WRITE		_IOWR('H', 0x02, struct hmm_dummy_write)
+#define HMM_DUMMY_MIGRATE_TO	_IOWR('H', 0x03, struct hmm_dummy_migrate)
 
 #endif /* _UAPI_LINUX_HMM_DUMMY_H */
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
