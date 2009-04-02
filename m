Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9B2696B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 01:31:29 -0400 (EDT)
Date: Wed, 1 Apr 2009 22:31:14 -0700
From: Chris Wright <chrisw@redhat.com>
Subject: [PATCH 5/4] update ksm userspace interfaces
Message-ID: <20090402053114.GF1117@x200.localdomain>
References: <20090331142533.GR9137@random.random> <49D22A9D.4050403@codemonkey.ws> <20090331150218.GS9137@random.random> <49D23224.9000903@codemonkey.ws> <20090331151845.GT9137@random.random> <49D23CD1.9090208@codemonkey.ws> <20090331162525.GU9137@random.random> <49D24A02.6070000@codemonkey.ws> <20090402012215.GE1117@x200.localdomain> <49D424AF.3090806@codemonkey.ws>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49D424AF.3090806@codemonkey.ws>
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: Chris Wright <chrisw@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

* Anthony Liguori (anthony@codemonkey.ws) wrote:
> Using an interface like madvise() would force the issue to be dealt with  
> properly from the start :-)

Yeah, I'm not at all opposed to it.

This updates to madvise for register and sysfs for control.

madvise issues:
- MADV_SHAREABLE
  - register only ATM, can add MADV_UNSHAREABLE to allow an app to proactively
    unregister, but need a cleanup when ->mm goes away via exit/exec
  - will register a region per vma, should probably push the whole thing
    into vma rather than keep [mm,addr,len] tuple in ksm
sysfs issues:
- none really, i added a reporting mechanism for number of pages shared,
  doesn't decrement on COW
- could use some extra sanity checks

It compiles!  Diff output is hard to read, I can send a 4/4 w/ this
patch rolled in for easier review.

Signed-off-by: Chris Wright <chrisw@redhat.com>
---
 include/asm-generic/mman.h |    1 +
 include/linux/ksm.h        |   63 +--------
 mm/ksm.c                   |  352 ++++++++++++++++----------------------------
 mm/madvise.c               |   18 +++
 4 files changed, 149 insertions(+), 285 deletions(-)

diff --git a/include/asm-generic/mman.h b/include/asm-generic/mman.h
index 5e3dde2..a1c1d5c 100644
--- a/include/asm-generic/mman.h
+++ b/include/asm-generic/mman.h
@@ -34,6 +34,7 @@
 #define MADV_REMOVE	9		/* remove these pages & resources */
 #define MADV_DONTFORK	10		/* don't inherit across fork */
 #define MADV_DOFORK	11		/* do inherit across fork */
+#define MADV_SHAREABLE	12		/* can share identical pages */
 
 /* compatibility flags */
 #define MAP_FILE	0
diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index 5776dce..e032f6f 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -1,69 +1,8 @@
 #ifndef __LINUX_KSM_H
 #define __LINUX_KSM_H
 
-/*
- * Userspace interface for /dev/ksm - kvm shared memory
- */
-
-#include <linux/types.h>
-#include <linux/ioctl.h>
-
-#include <asm/types.h>
-
-#define KSM_API_VERSION 1
-
 #define ksm_control_flags_run 1
 
-/* for KSM_REGISTER_MEMORY_REGION */
-struct ksm_memory_region {
-	__u32 npages; /* number of pages to share */
-	__u32 pad;
-	__u64 addr; /* the begining of the virtual address */
-        __u64 reserved_bits;
-};
-
-struct ksm_kthread_info {
-	__u32 sleep; /* number of microsecoends to sleep */
-	__u32 pages_to_scan; /* number of pages to scan */
-	__u32 flags; /* control flags */
-        __u32 pad;
-        __u64 reserved_bits;
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
-/*
- * KSM_START_STOP_KTHREAD - control the kernel thread scanning speed
- * (can stop the kernel thread from working by setting running = 0)
- */
-#define KSM_START_STOP_KTHREAD		 _IOW(KSMIO,  0x02,\
-					      struct ksm_kthread_info)
-/*
- * KSM_GET_INFO_KTHREAD - return information about the kernel thread
- * scanning speed.
- */
-#define KSM_GET_INFO_KTHREAD		 _IOW(KSMIO,  0x03,\
-					      struct ksm_kthread_info)
-
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
 
 #endif
diff --git a/mm/ksm.c b/mm/ksm.c
index eba4c09..fcbf76e 100644
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
@@ -38,6 +37,7 @@
 #include <linux/rbtree.h>
 #include <linux/anon_inodes.h>
 #include <linux/ksm.h>
+#include <linux/kobject.h>
 
 #include <asm/tlbflush.h>
 
@@ -55,20 +55,11 @@ MODULE_PARM_DESC(rmap_hash_size, "Hash table size for the reverse mapping");
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
-};
-
 /**
  * struct ksm_scan - cursor for scanning
  * @slot_index: the current slot we are scanning
@@ -190,6 +181,7 @@ static struct kmem_cache *rmap_item_cache;
 
 static int kthread_sleep; /* sleep time of the kernel thread */
 static int kthread_pages_to_scan; /* npages to scan for the kernel thread */
+static unsigned long ksm_pages_shared;
 static struct ksm_scan kthread_ksm_scan;
 static int ksmd_flags;
 static struct task_struct *kthread;
@@ -363,22 +355,12 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
 	free_rmap_item(rmap_item);
 }
 
-static void remove_page_from_tree(struct mm_struct *mm,
-				  unsigned long addr)
-{
-	struct rmap_item *rmap_item;
-
-	rmap_item = get_rmap_item(mm, addr);
-	if (!rmap_item)
-		return;
-	remove_rmap_item_from_tree(rmap_item);
-	return;
-}
-
-static int ksm_sma_ioctl_register_memory_region(struct ksm_sma *ksm_sma,
-						struct ksm_memory_region *mem)
+long ksm_register_memory(struct vm_area_struct *vma, unsigned long start,
+			unsigned long end)
 {
 	struct ksm_mem_slot *slot;
+	int npages = (end - start) >> PAGE_SHIFT;
+
 	int ret = -EPERM;
 
 	slot = kzalloc(sizeof(struct ksm_mem_slot), GFP_KERNEL);
@@ -390,13 +372,12 @@ static int ksm_sma_ioctl_register_memory_region(struct ksm_sma *ksm_sma,
 	slot->mm = get_task_mm(current);
 	if (!slot->mm)
 		goto out_free;
-	slot->addr = mem->addr;
-	slot->npages = mem->npages;
+	slot->addr = start;
+	slot->npages = npages;
 
 	down_write(&slots_lock);
 
 	list_add_tail(&slot->link, &slots);
-	list_add_tail(&slot->sma_link, &ksm_sma->sma_slots);
 
 	up_write(&slots_lock);
 	return 0;
@@ -407,76 +388,6 @@ out:
 	return ret;
 }
 
-static void remove_mm_from_hash_and_tree(struct mm_struct *mm)
-{
-	struct ksm_mem_slot *slot;
-	int pages_count;
-
-	list_for_each_entry(slot, &slots, link)
-		if (slot->mm == mm)
-			break;
-	BUG_ON(!slot);
-
-	root_unstable_tree = RB_ROOT;
-	for (pages_count = 0; pages_count < slot->npages; ++pages_count)
-		remove_page_from_tree(mm, slot->addr +
-				      pages_count * PAGE_SIZE);
-	list_del(&slot->link);
-}
-
-static int ksm_sma_ioctl_remove_memory_region(struct ksm_sma *ksm_sma)
-{
-	struct ksm_mem_slot *slot, *node;
-
-	down_write(&slots_lock);
-	list_for_each_entry_safe(slot, node, &ksm_sma->sma_slots, sma_link) {
-		remove_mm_from_hash_and_tree(slot->mm);
-		mmput(slot->mm);
-		list_del(&slot->sma_link);
-		kfree(slot);
-	}
-	up_write(&slots_lock);
-	return 0;
-}
-
-static int ksm_sma_release(struct inode *inode, struct file *filp)
-{
-	struct ksm_sma *ksm_sma = filp->private_data;
-	int r;
-
-	r = ksm_sma_ioctl_remove_memory_region(ksm_sma);
-	kfree(ksm_sma);
-	return r;
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
-		r = ksm_sma_ioctl_remove_memory_region(sma);
-		break;
-	}
-
-out:
-	return r;
-}
-
 static unsigned long addr_in_vma(struct vm_area_struct *vma, struct page *page)
 {
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
@@ -652,6 +563,8 @@ static int try_to_merge_two_pages(struct mm_struct *mm1, struct page *page1,
 		prot = vma->vm_page_prot;
 		pgprot_val(prot) &= ~_PAGE_RW;
 		ret = try_to_merge_one_page(mm1, vma, page1, page2, prot);
+		if (!ret)
+			ksm_pages_shared++;
 	} else {
 		struct page *kpage;
 
@@ -701,6 +614,8 @@ static int try_to_merge_two_pages(struct mm_struct *mm1, struct page *page1,
 					put_page(tmppage[0]);
 				}
 				up_read(&mm1->mmap_sem);
+			} else {
+				ksm_pages_shared++;
 			}
 		}
 		put_page(kpage);
@@ -1181,9 +1096,6 @@ static void scan_update_old_index(struct ksm_scan *ksm_scan)
  * @scan_npages - number of pages we are want to scan before we return from this
  * @function.
  *
- * (this function can be called from the kernel thread scanner, or from 
- *  userspace ioctl context scanner)
- *
  *  The function return -EAGAIN in case there are not slots to scan.
  */
 static int ksm_scan_start(struct ksm_scan *ksm_scan, unsigned int scan_npages)
@@ -1231,154 +1143,148 @@ out:
 	return ret;
 }
 
-static struct file_operations ksm_sma_fops = {
-	.release        = ksm_sma_release,
-	.unlocked_ioctl = ksm_sma_ioctl,
-	.compat_ioctl   = ksm_sma_ioctl,
-};
-
-static int ksm_dev_ioctl_create_shared_memory_area(void)
+int kthread_ksm_scan_thread(void *nothing)
 {
-	int fd = -1;
-	struct ksm_sma *ksm_sma;
+	while (!kthread_should_stop()) {
+		if (ksmd_flags & ksm_control_flags_run) {
+			down_read(&kthread_lock);
+			ksm_scan_start(&kthread_ksm_scan,
+				       kthread_pages_to_scan);
+			up_read(&kthread_lock);
+			schedule_timeout_interruptible(
+					usecs_to_jiffies(kthread_sleep));
+		} else {
+			wait_event_interruptible(kthread_wait,
+					ksmd_flags & ksm_control_flags_run ||
+					kthread_should_stop());
+		}
+	}
+	return 0;
+}
 
-	ksm_sma = kmalloc(sizeof(struct ksm_sma), GFP_KERNEL);
-	if (!ksm_sma)
-		goto out;
+#define KSM_ATTR_RO(_name) \
+	static struct kobj_attribute _name##_attr = __ATTR_RO(_name)
 
-	INIT_LIST_HEAD(&ksm_sma->sma_slots);
+#define KSM_ATTR(_name) \
+	static struct kobj_attribute _name##_attr = \
+		__ATTR(_name, 0644, _name##_show, _name##_store)
 
-	fd = anon_inode_getfd("ksm-sma", &ksm_sma_fops, ksm_sma, 0);
-	if (fd < 0)
-		goto out_free;
+static ssize_t sleep_show(struct kobject *kobj, struct kobj_attribute *attr,
+			  char *buf)
+{
+	unsigned int usecs;
 
-	return fd;
-out_free:
-	kfree(ksm_sma);
-out:
-	return fd;
+	down_read(&kthread_lock);
+	usecs = kthread_sleep;
+	up_read(&kthread_lock);
+
+	return sprintf(buf, "%u\n", usecs);
 }
 
-/*
- * ksm_dev_ioctl_start_stop_kthread - control the kernel thread scanning running
- * speed.
- * This function allow us to control on the time the kernel thread will sleep
- * how many pages it will scan between sleep and sleep, and how many pages it
- * will maximum merge between sleep and sleep.
- */
-static int ksm_dev_ioctl_start_stop_kthread(struct ksm_kthread_info *info)
+static ssize_t sleep_store(struct kobject *kobj,
+				   struct kobj_attribute *attr,
+				   const char *buf, size_t count)
 {
-	int ret = 0;
-
-	down_write(&kthread_lock);
+	unsigned long usecs;
+	int err;
 
-	if (info->flags & ksm_control_flags_run) {
-		if (!info->pages_to_scan) {
-			ret = EPERM;
-			up_write(&kthread_lock);
-			goto out;
-		}
-	}
+	err = strict_strtoul(buf, 10, &usecs);
+	if (err)
+		return 0;
 
-	kthread_sleep = info->sleep;
-	kthread_pages_to_scan = info->pages_to_scan;
-	ksmd_flags = info->flags;
+	/* TODO sanitize usecs */
 
+	down_write(&kthread_lock);
+	kthread_sleep = usecs;
 	up_write(&kthread_lock);
 
-	if (ksmd_flags & ksm_control_flags_run)
-		wake_up_interruptible(&kthread_wait);
-
-out:
-	return ret;
+	return count;
 }
+KSM_ATTR(sleep);
 
-/*
- * ksm_dev_ioctl_get_info_kthread - write into info the scanning information
- * of the ksm kernel thread
- */
-static void ksm_dev_ioctl_get_info_kthread(struct ksm_kthread_info *info)
+static ssize_t pages_to_scan_show(struct kobject *kobj,
+				  struct kobj_attribute *attr, char *buf)
 {
+	unsigned long nr_pages;
+
 	down_read(&kthread_lock);
+	nr_pages = kthread_pages_to_scan;
+	up_read(&kthread_lock);
 
-	info->sleep = kthread_sleep;
-	info->pages_to_scan = kthread_pages_to_scan;
-	info->flags = ksmd_flags;
+	return sprintf(buf, "%lu\n", nr_pages);
+}
 
-	up_read(&kthread_lock);
+static ssize_t pages_to_scan_store(struct kobject *kobj,
+				   struct kobj_attribute *attr,
+				   const char *buf, size_t count)
+{
+	int err;
+	unsigned long nr_pages;
+
+	err = strict_strtoul(buf, 10, &nr_pages);
+	if (err)
+		return 0;
+
+	down_write(&kthread_lock);
+	kthread_pages_to_scan = nr_pages;
+	up_write(&kthread_lock);
+
+	return count;
 }
+KSM_ATTR(pages_to_scan);
 
-static long ksm_dev_ioctl(struct file *filp,
-			  unsigned int ioctl, unsigned long arg)
+static ssize_t run_show(struct kobject *kobj, struct kobj_attribute *attr,
+			char *buf)
 {
-	void __user *argp = (void __user *)arg;
-	long r = -EINVAL;
-
-	switch (ioctl) {
-	case KSM_GET_API_VERSION:
-		r = KSM_API_VERSION;
-		break;
-	case KSM_CREATE_SHARED_MEMORY_AREA:
-		r = ksm_dev_ioctl_create_shared_memory_area();
-		break;
-	case KSM_START_STOP_KTHREAD: {
-		struct ksm_kthread_info info;
-
-		r = -EFAULT;
-		if (copy_from_user(&info, argp,
-				   sizeof(struct ksm_kthread_info)))
-			break;
-
-		r = ksm_dev_ioctl_start_stop_kthread(&info);
-		break;
-		}
-	case KSM_GET_INFO_KTHREAD: {
-		struct ksm_kthread_info info;
-
-		ksm_dev_ioctl_get_info_kthread(&info);
-		r = -EFAULT;
-		if (copy_to_user(argp, &info,
-				 sizeof(struct ksm_kthread_info)))
-			break;
-		r = 0;
-		break;
-	}
-	default:
-		break;
-	}
-	return r;
+	unsigned long run;
+
+	down_read(&kthread_lock);
+	run = ksmd_flags;
+	up_read(&kthread_lock);
+
+	return sprintf(buf, "%lu\n", run);
 }
 
-static struct file_operations ksm_chardev_ops = {
-	.unlocked_ioctl = ksm_dev_ioctl,
-	.compat_ioctl   = ksm_dev_ioctl,
-	.owner          = THIS_MODULE,
-};
+static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
+			 const char *buf, size_t count)
+{
+	int err;
+	unsigned long run;
 
-static struct miscdevice ksm_dev = {
-	KSM_MINOR,
-	"ksm",
-	&ksm_chardev_ops,
-};
+	err = strict_strtoul(buf, 10, &run);
+	if (err)
+		return 0;
 
-int kthread_ksm_scan_thread(void *nothing)
+	down_write(&kthread_lock);
+	ksmd_flags = run;
+	up_write(&kthread_lock);
+
+	if (ksmd_flags)
+		wake_up_interruptible(&kthread_wait);
+
+	return count;
+}
+KSM_ATTR(run);
+
+static ssize_t pages_shared_show(struct kobject *kobj,
+				 struct kobj_attribute *attr, char *buf)
 {
-	while (!kthread_should_stop()) {
-		if (ksmd_flags & ksm_control_flags_run) {
-			down_read(&kthread_lock);
-			ksm_scan_start(&kthread_ksm_scan,
-				       kthread_pages_to_scan);
-			up_read(&kthread_lock);
-			schedule_timeout_interruptible(
-					usecs_to_jiffies(kthread_sleep));
-		} else {
-			wait_event_interruptible(kthread_wait,
-					ksmd_flags & ksm_control_flags_run ||
-					kthread_should_stop());
-		}
-	}
-	return 0;
+	return sprintf(buf, "%lu\n", ksm_pages_shared);
 }
+KSM_ATTR_RO(pages_shared);
+
+static struct attribute *ksm_attrs[] = {
+	&sleep_attr.attr,
+	&pages_to_scan_attr.attr,
+	&run_attr.attr,
+	&pages_shared_attr.attr,
+	NULL,
+};
+
+static struct attribute_group ksm_attr_group = {
+	.attrs = ksm_attrs,
+	.name = "ksm",
+};
 
 static int __init ksm_init(void)
 {
@@ -1399,9 +1305,9 @@ static int __init ksm_init(void)
 		goto out_free2;
 	}
 
-	r = misc_register(&ksm_dev);
+	r = sysfs_create_group(mm_kobj, &ksm_attr_group);
 	if (r) {
-		printk(KERN_ERR "ksm: misc device register failed\n");
+		printk(KERN_ERR "ksm: sysfs file creation failed\n");
 		goto out_free3;
 	}
 
@@ -1420,7 +1326,7 @@ out:
 
 static void __exit ksm_exit(void)
 {
-	misc_deregister(&ksm_dev);
+	sysfs_remove_group(mm_kobj, &ksm_attr_group);
 	ksmd_flags = ksm_control_flags_run;
 	kthread_stop(kthread);
 	rmap_hash_free();
diff --git a/mm/madvise.c b/mm/madvise.c
index b9ce574..16bc7fa 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -11,6 +11,7 @@
 #include <linux/mempolicy.h>
 #include <linux/hugetlb.h>
 #include <linux/sched.h>
+#include <linux/ksm.h>
 
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
@@ -208,6 +209,18 @@ static long madvise_remove(struct vm_area_struct *vma,
 	return error;
 }
 
+/*
+ * Application allows pages to be shared with other pages of identical
+ * content.
+ *
+ */
+static long madvise_shareable(struct vm_area_struct *vma,
+				struct vm_area_struct **prev,
+				unsigned long start, unsigned long end)
+{
+	return ksm_register_memory(vma, start, end);
+}
+
 static long
 madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		unsigned long start, unsigned long end, int behavior)
@@ -238,6 +251,9 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 		error = madvise_dontneed(vma, prev, start, end);
 		break;
 
+	case MADV_SHAREABLE:
+		error = madvise_shareable(vma, prev, start, end);
+		break;
 	default:
 		error = -EINVAL;
 		break;
@@ -269,6 +285,8 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
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
