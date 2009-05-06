Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4676D6B003D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 19:59:00 -0400 (EDT)
Date: Wed, 6 May 2009 16:59:49 -0700
From: Chris Wright <chrisw@redhat.com>
Subject: Re: [PATCH 3/6] ksm: change the KSM_REMOVE_MEMORY_REGION ioctl.
Message-ID: <20090506235949.GC16870@x200.localdomain>
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com> <1241475935-21162-2-git-send-email-ieidus@redhat.com> <1241475935-21162-3-git-send-email-ieidus@redhat.com> <1241475935-21162-4-git-send-email-ieidus@redhat.com> <4A00DF9B.1080501@redhat.com> <4A014C7B.9080702@redhat.com> <Pine.LNX.4.64.0905061110470.3519@blonde.anvils> <4A01AC5E.6000906@redhat.com> <Pine.LNX.4.64.0905061706590.4005@blonde.anvils> <4A01C1AD.9060802@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A01C1AD.9060802@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Hugh Dickins <hugh@veritas.com>, Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

* Izik Eidus (ieidus@redhat.com) wrote:
> Ok, i give up, lets move to madvice(), i will write a patch that move  
> the whole thing into madvice after i finish here something, but that  
> ofcurse only if Andrea agree for the move?

Here's where I left off last time (refreshed against a current mmotm).

It needs to get converted to vma rather than still scanning via slots.
It's got locking issues (I think this can be remedied w/ vma
conversion).  I think the scan list would be ->mm and each ->mm we'd
scan the vma's that are marked VM_MERGEABLE or whatever.

---
 include/asm-generic/mman.h |    2 
 include/linux/ksm.h        |   41 ---------
 include/linux/miscdevice.h |    1 
 mm/ksm.c                   |  205 ++-------------------------------------------
 mm/madvise.c               |   29 ++++++
 5 files changed, 46 insertions(+), 232 deletions(-)

--- a/include/asm-generic/mman.h
+++ b/include/asm-generic/mman.h
@@ -34,6 +34,8 @@
 #define MADV_REMOVE	9		/* remove these pages & resources */
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
+#define MADV_SHAREABLE	12		/* can share identical pages */
+#define MADV_UNSHAREABLE 13		/* can not share identical pages */
 
 /* compatibility flags */
 #define MAP_FILE	0
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -1,46 +1,9 @@
 #ifndef __LINUX_KSM_H
 #define __LINUX_KSM_H
 
-/*
- * Userspace interface for /dev/ksm - kvm shared memory
- */
-
-#include <linux/types.h>
-#include <linux/ioctl.h>
-
-#define KSM_API_VERSION 1
-
 #define ksm_control_flags_run 1
 
-/* for KSM_REGISTER_MEMORY_REGION */
-struct ksm_memory_region {
-	__u32 npages; /* number of pages to share */
-	__u32 pad;
-	__u64 addr; /* the begining of the virtual address */
-	__u64 reserved_bits;
-};
-
-#define KSMIO 0xAB
-
-/* ioctls for /dev/ksm */
-
-#define KSM_GET_API_VERSION              _IO(KSMIO,   0x00)
-/*
- * KSM_CREATE_SHARED_MEMORY_AREA - create the shared memory reagion fd
- */
-#define KSM_CREATE_SHARED_MEMORY_AREA    _IO(KSMIO,   0x01) /* return SMA fd */
-
-/* ioctls for SMA fds */
-
-/*
- * KSM_REGISTER_MEMORY_REGION - register virtual address memory area to be
- * scanned by kvm.
- */
-#define KSM_REGISTER_MEMORY_REGION       _IOW(KSMIO,  0x20,\
-					      struct ksm_memory_region)
-/*
- * KSM_REMOVE_MEMORY_REGION - remove virtual address memory area from ksm.
- */
-#define KSM_REMOVE_MEMORY_REGION         _IO(KSMIO,   0x21)
+long ksm_register_memory(struct vm_area_struct *, unsigned long, unsigned long);
+long ksm_unregister_memory(struct vm_area_struct *, unsigned long, unsigned long);
 
 #endif
--- a/include/linux/miscdevice.h
+++ b/include/linux/miscdevice.h
@@ -30,7 +30,6 @@
 #define HPET_MINOR		228
 #define FUSE_MINOR		229
 #define KVM_MINOR		232
-#define KSM_MINOR		234
 #define MISC_DYNAMIC_MINOR	255
 
 struct device;
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -17,7 +17,6 @@
 #include <linux/errno.h>
 #include <linux/mm.h>
 #include <linux/fs.h>
-#include <linux/miscdevice.h>
 #include <linux/vmalloc.h>
 #include <linux/file.h>
 #include <linux/mman.h>
@@ -58,21 +57,11 @@ module_param(regions_per_fd, int, 0);
  */
 struct ksm_mem_slot {
 	struct list_head link;
-	struct list_head sma_link;
 	struct mm_struct *mm;
 	unsigned long addr;	/* the begining of the virtual address */
 	unsigned npages;	/* number of pages to share */
 };
 
-/*
- * ksm_sma - shared memory area, each process have its own sma that contain the
- * information about the slots that it own
- */
-struct ksm_sma {
-	struct list_head sma_slots;
-	int nregions;
-};
-
 /**
  * struct ksm_scan - cursor for scanning
  * @slot_index: the current slot we are scanning
@@ -459,85 +448,35 @@ static inline int is_intersecting_addres
 	return 0;
 }
 
-/*
- * is_overlap_mem - check if there is overlapping with memory that was already
- * registred.
- *
- * note - this function must to be called under slots_lock
- */
-static int is_overlap_mem(struct ksm_memory_region *mem)
-{
-	struct ksm_mem_slot *slot;
-
-	list_for_each_entry(slot, &slots, link) {
-		unsigned long mem_end;
-		unsigned long slot_end;
-
-		cond_resched();
-
-		if (current->mm != slot->mm)
-			continue;
-
-		mem_end = mem->addr + (unsigned long)mem->npages * PAGE_SIZE;
-		slot_end = slot->addr + (unsigned long)slot->npages * PAGE_SIZE;
-
-		if (is_intersecting_address(mem->addr, slot->addr, slot_end) ||
-		    is_intersecting_address(mem_end - 1, slot->addr, slot_end))
-			return 1;
-		if (is_intersecting_address(slot->addr, mem->addr, mem_end) ||
-		    is_intersecting_address(slot_end - 1, mem->addr, mem_end))
-			return 1;
-	}
-
-	return 0;
-}
+long ksm_register_memory(struct vm_area_struct *vma, unsigned long start,
+			 unsigned long end)
 
-static int ksm_sma_ioctl_register_memory_region(struct ksm_sma *ksm_sma,
-						struct ksm_memory_region *mem)
 {
 	struct ksm_mem_slot *slot;
+	int npages = (end - start) >> PAGE_SHIFT;
 	int ret = -EPERM;
 
-	if (!mem->npages)
-		goto out;
-
-	down_write(&slots_lock);
-
-	if ((ksm_sma->nregions + 1) > regions_per_fd) {
-		ret = -EBUSY;
-		goto out_unlock;
-	}
-
-	if (is_overlap_mem(mem))
-		goto out_unlock;
-
 	slot = kzalloc(sizeof(struct ksm_mem_slot), GFP_KERNEL);
 	if (!slot) {
 		ret = -ENOMEM;
-		goto out_unlock;
+		goto out;
 	}
 
-	/*
-	 * We will hold refernce to the task_mm untill the file descriptor
-	 * will be closed, or KSM_REMOVE_MEMORY_REGION will be called.
-	 */
 	slot->mm = get_task_mm(current);
 	if (!slot->mm)
 		goto out_free;
-	slot->addr = mem->addr;
-	slot->npages = mem->npages;
+	slot->addr = start;
+	slot->npages = npages;
+
+	down_write(&slots_lock);
 
 	list_add_tail(&slot->link, &slots);
-	list_add_tail(&slot->sma_link, &ksm_sma->sma_slots);
-	ksm_sma->nregions++;
 
 	up_write(&slots_lock);
 	return 0;
 
 out_free:
 	kfree(slot);
-out_unlock:
-	up_write(&slots_lock);
 out:
 	return ret;
 }
@@ -554,20 +493,18 @@ static void remove_slot_from_hash_and_tr
 	list_del(&slot->link);
 }
 
-static int ksm_sma_ioctl_remove_memory_region(struct ksm_sma *ksm_sma,
-					      unsigned long addr)
+long ksm_unregister_memory(struct vm_area_struct *vma, unsigned long start,
+			   unsigned long end)
 {
 	int ret = -EFAULT;
 	struct ksm_mem_slot *slot, *node;
 
 	down_write(&slots_lock);
-	list_for_each_entry_safe(slot, node, &ksm_sma->sma_slots, sma_link) {
-		if (addr == slot->addr) {
+	list_for_each_entry_safe(slot, node, &slots, link) {
+		if (vma->vm_mm == slot->mm && start == slot->addr) {
 			remove_slot_from_hash_and_tree(slot);
 			mmput(slot->mm);
-			list_del(&slot->sma_link);
 			kfree(slot);
-			ksm_sma->nregions--;
 			ret = 0;
 		}
 	}
@@ -575,52 +512,6 @@ static int ksm_sma_ioctl_remove_memory_r
 	return ret;
 }
 
-static int ksm_sma_release(struct inode *inode, struct file *filp)
-{
-	struct ksm_mem_slot *slot, *node;
-	struct ksm_sma *ksm_sma = filp->private_data;
-
-	down_write(&slots_lock);
-	list_for_each_entry_safe(slot, node, &ksm_sma->sma_slots, sma_link) {
-		remove_slot_from_hash_and_tree(slot);
-		mmput(slot->mm);
-		list_del(&slot->sma_link);
-		kfree(slot);
-	}
-	up_write(&slots_lock);
-
-	kfree(ksm_sma);
-	return 0;
-}
-
-static long ksm_sma_ioctl(struct file *filp,
-			  unsigned int ioctl, unsigned long arg)
-{
-	struct ksm_sma *sma = filp->private_data;
-	void __user *argp = (void __user *)arg;
-	int r = EINVAL;
-
-	switch (ioctl) {
-	case KSM_REGISTER_MEMORY_REGION: {
-		struct ksm_memory_region ksm_memory_region;
-
-		r = -EFAULT;
-		if (copy_from_user(&ksm_memory_region, argp,
-				   sizeof(ksm_memory_region)))
-			goto out;
-		r = ksm_sma_ioctl_register_memory_region(sma,
-							 &ksm_memory_region);
-		break;
-	}
-	case KSM_REMOVE_MEMORY_REGION:
-		r = ksm_sma_ioctl_remove_memory_region(sma, arg);
-		break;
-	}
-
-out:
-	return r;
-}
-
 static int memcmp_pages(struct page *page1, struct page *page2)
 {
 	char *addr1, *addr2;
@@ -1437,67 +1328,6 @@ out:
 	return ret;
 }
 
-static const struct file_operations ksm_sma_fops = {
-	.release        = ksm_sma_release,
-	.unlocked_ioctl = ksm_sma_ioctl,
-	.compat_ioctl   = ksm_sma_ioctl,
-};
-
-static int ksm_dev_ioctl_create_shared_memory_area(void)
-{
-	int fd = -1;
-	struct ksm_sma *ksm_sma;
-
-	ksm_sma = kmalloc(sizeof(struct ksm_sma), GFP_KERNEL);
-	if (!ksm_sma) {
-		fd = -ENOMEM;
-		goto out;
-	}
-
-	INIT_LIST_HEAD(&ksm_sma->sma_slots);
-	ksm_sma->nregions = 0;
-
-	fd = anon_inode_getfd("ksm-sma", &ksm_sma_fops, ksm_sma, 0);
-	if (fd < 0)
-		goto out_free;
-
-	return fd;
-out_free:
-	kfree(ksm_sma);
-out:
-	return fd;
-}
-
-static long ksm_dev_ioctl(struct file *filp,
-			  unsigned int ioctl, unsigned long arg)
-{
-	long r = -EINVAL;
-
-	switch (ioctl) {
-	case KSM_GET_API_VERSION:
-		r = KSM_API_VERSION;
-		break;
-	case KSM_CREATE_SHARED_MEMORY_AREA:
-		r = ksm_dev_ioctl_create_shared_memory_area();
-		break;
-	default:
-		break;
-	}
-	return r;
-}
-
-static const struct file_operations ksm_chardev_ops = {
-	.unlocked_ioctl = ksm_dev_ioctl,
-	.compat_ioctl   = ksm_dev_ioctl,
-	.owner          = THIS_MODULE,
-};
-
-static struct miscdevice ksm_dev = {
-	KSM_MINOR,
-	"ksm",
-	&ksm_chardev_ops,
-};
-
 int ksm_scan_thread(void *nothing)
 {
 	while (!kthread_should_stop()) {
@@ -1708,23 +1538,15 @@ static int __init ksm_init(void)
 		goto out_free2;
 	}
 
-	r = misc_register(&ksm_dev);
-	if (r) {
-		printk(KERN_ERR "ksm: misc device register failed\n");
-		goto out_free3;
-	}
-
 	r = sysfs_create_group(mm_kobj, &ksm_attr_group);
 	if (r) {
 		printk(KERN_ERR "ksm: register sysfs failed\n");
-		goto out_free4;
+		goto out_free3;
 	}
 
 	printk(KERN_WARNING "ksm loaded\n");
 	return 0;
 
-out_free4:
-	misc_deregister(&ksm_dev);
 out_free3:
 	kthread_stop(ksm_thread);
 out_free2:
@@ -1738,7 +1560,6 @@ out:
 static void __exit ksm_exit(void)
 {
 	sysfs_remove_group(mm_kobj, &ksm_attr_group);
-	misc_deregister(&ksm_dev);
 	ksmd_flags = ksm_control_flags_run;
 	kthread_stop(ksm_thread);
 	rmap_hash_free();
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -11,6 +11,7 @@
 #include <linux/mempolicy.h>
 #include <linux/hugetlb.h>
 #include <linux/sched.h>
+#include <linux/ksm.h>
 
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
@@ -23,6 +24,8 @@ static int madvise_need_mmap_write(int b
 	case MADV_REMOVE:
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
+	case MADV_SHAREABLE:
+	case MADV_UNSHAREABLE:
 		return 0;
 	default:
 		/* be safe, default to 1. list exceptions explicitly */
@@ -207,6 +210,26 @@ static long madvise_remove(struct vm_are
 	return error;
 }
 
+/*
+ * Application allows pages to be shared with other pages of identical
+ * content.
+ *
+ */
+static long madvise_shareable(struct vm_area_struct *vma,
+				struct vm_area_struct **prev,
+				unsigned long start, unsigned long end,
+				int behavior)
+{
+	switch (behavior) {
+	case MADV_SHAREABLE:
+		return ksm_register_memory(vma, start, end);
+	case MADV_UNSHAREABLE:
+		return ksm_unregister_memory(vma, start, end);
+	default:
+		return -EINVAL;
+	}
+}
+
 static long
 madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		unsigned long start, unsigned long end, int behavior)
@@ -237,6 +260,10 @@ madvise_vma(struct vm_area_struct *vma, 
 		error = madvise_dontneed(vma, prev, start, end);
 		break;
 
+	case MADV_SHAREABLE:
+	case MADV_UNSHAREABLE:
+		error = madvise_shareable(vma, prev, start, end, behavior);
+		break;
 	default:
 		error = -EINVAL;
 		break;
@@ -268,6 +295,8 @@ madvise_vma(struct vm_area_struct *vma, 
  *		so the kernel can free resources associated with it.
  *  MADV_REMOVE - the application wants to free up the given range of
  *		pages and associated backing store.
+ *  MADV_SHAREABLE - the application agrees that pages in the given
+ *		range can be shared w/ other pages of identical content.
  *
  * return values:
  *  zero    - success

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
