Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 29C985F0001
	for <linux-mm@kvack.org>; Sun, 19 Apr 2009 21:36:43 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 5/5] add ksm kernel shared memory driver.
Date: Mon, 20 Apr 2009 04:36:06 +0300
Message-Id: <1240191366-10029-6-git-send-email-ieidus@redhat.com>
In-Reply-To: <1240191366-10029-5-git-send-email-ieidus@redhat.com>
References: <1240191366-10029-1-git-send-email-ieidus@redhat.com>
 <1240191366-10029-2-git-send-email-ieidus@redhat.com>
 <1240191366-10029-3-git-send-email-ieidus@redhat.com>
 <1240191366-10029-4-git-send-email-ieidus@redhat.com>
 <1240191366-10029-5-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

Ksm is driver that allow merging identical pages between one or more
applications in way unvisible to the application that use it.
Pages that are merged are marked as readonly and are COWed when any
application try to change them.

Ksm is used for cases where using fork() is not suitable,
one of this cases is where the pages of the application keep changing
dynamicly and the application cannot know in advance what pages are
going to be identical.

Ksm works by walking over the memory pages of the applications it
scan in order to find identical pages.
It uses a two sorted data strctures called stable and unstable trees
to find in effective way the identical pages.

When ksm finds two identical pages, it marks them as readonly and merges
them into single one page,
after the pages are marked as readonly and merged into one page, linux
will treat this pages as normal copy_on_write pages and will fork them
when write access will happen to them.

Ksm scan just memory areas that were registred to be scanned by it.

Signed-off-by: Izik Eidus <ieidus@redhat.com>
Signed-off-by: Chris Wright <chrisw@redhat.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/ksm.h        |   48 ++
 include/linux/miscdevice.h |    1 +
 mm/Kconfig                 |    6 +
 mm/Makefile                |    1 +
 mm/ksm.c                   | 1675 ++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 1731 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/ksm.h
 create mode 100644 mm/ksm.c

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
new file mode 100644
index 0000000..2c11e9a
--- /dev/null
+++ b/include/linux/ksm.h
@@ -0,0 +1,48 @@
+#ifndef __LINUX_KSM_H
+#define __LINUX_KSM_H
+
+/*
+ * Userspace interface for /dev/ksm - kvm shared memory
+ */
+
+#include <linux/types.h>
+#include <linux/ioctl.h>
+
+#include <asm/types.h>
+
+#define KSM_API_VERSION 1
+
+#define ksm_control_flags_run 1
+
+/* for KSM_REGISTER_MEMORY_REGION */
+struct ksm_memory_region {
+	__u32 npages; /* number of pages to share */
+	__u32 pad;
+	__u64 addr; /* the begining of the virtual address */
+        __u64 reserved_bits;
+};
+
+#define KSMIO 0xAB
+
+/* ioctls for /dev/ksm */
+
+#define KSM_GET_API_VERSION              _IO(KSMIO,   0x00)
+/*
+ * KSM_CREATE_SHARED_MEMORY_AREA - create the shared memory reagion fd
+ */
+#define KSM_CREATE_SHARED_MEMORY_AREA    _IO(KSMIO,   0x01) /* return SMA fd */
+
+/* ioctls for SMA fds */
+
+/*
+ * KSM_REGISTER_MEMORY_REGION - register virtual address memory area to be
+ * scanned by kvm.
+ */
+#define KSM_REGISTER_MEMORY_REGION       _IOW(KSMIO,  0x20,\
+					      struct ksm_memory_region)
+/*
+ * KSM_REMOVE_MEMORY_REGION - remove virtual address memory area from ksm.
+ */
+#define KSM_REMOVE_MEMORY_REGION         _IO(KSMIO,   0x21)
+
+#endif
diff --git a/include/linux/miscdevice.h b/include/linux/miscdevice.h
index beb6ec9..297c0bb 100644
--- a/include/linux/miscdevice.h
+++ b/include/linux/miscdevice.h
@@ -30,6 +30,7 @@
 #define HPET_MINOR		228
 #define FUSE_MINOR		229
 #define KVM_MINOR		232
+#define KSM_MINOR		233
 #define MISC_DYNAMIC_MINOR	255
 
 struct device;
diff --git a/mm/Kconfig b/mm/Kconfig
index 57971d2..fb8ac63 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -225,3 +225,9 @@ config HAVE_MLOCKED_PAGE_BIT
 
 config MMU_NOTIFIER
 	bool
+
+config KSM
+	tristate "Enable KSM for page sharing"
+	help
+	  Enable the KSM kernel module to allow page sharing of equal pages
+	  among different tasks.
diff --git a/mm/Makefile b/mm/Makefile
index ec73c68..b885513 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -24,6 +24,7 @@ obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_TMPFS_POSIX_ACL) += shmem_acl.o
 obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
+obj-$(CONFIG_KSM) += ksm.o
 obj-$(CONFIG_PAGE_POISONING) += debug-pagealloc.o
 obj-$(CONFIG_SLAB) += slab.o
 obj-$(CONFIG_SLUB) += slub.o
diff --git a/mm/ksm.c b/mm/ksm.c
new file mode 100644
index 0000000..7fd4158
--- /dev/null
+++ b/mm/ksm.c
@@ -0,0 +1,1675 @@
+/*
+ * Memory merging driver for Linux
+ *
+ * This module enables dynamic sharing of identical pages found in different
+ * memory areas, even if they are not shared by fork()
+ *
+ * Copyright (C) 2008 Red Hat, Inc.
+ * Authors:
+ *	Izik Eidus
+ *	Andrea Arcangeli
+ *	Chris Wright
+ *
+ * This work is licensed under the terms of the GNU GPL, version 2.
+ */
+
+#include <linux/module.h>
+#include <linux/errno.h>
+#include <linux/mm.h>
+#include <linux/fs.h>
+#include <linux/miscdevice.h>
+#include <linux/vmalloc.h>
+#include <linux/file.h>
+#include <linux/mman.h>
+#include <linux/sched.h>
+#include <linux/rwsem.h>
+#include <linux/pagemap.h>
+#include <linux/sched.h>
+#include <linux/rmap.h>
+#include <linux/spinlock.h>
+#include <linux/jhash.h>
+#include <linux/delay.h>
+#include <linux/kthread.h>
+#include <linux/wait.h>
+#include <linux/scatterlist.h>
+#include <linux/random.h>
+#include <linux/slab.h>
+#include <linux/swap.h>
+#include <linux/rbtree.h>
+#include <linux/anon_inodes.h>
+#include <linux/ksm.h>
+
+#include <asm/tlbflush.h>
+
+MODULE_AUTHOR("Red Hat, Inc.");
+MODULE_LICENSE("GPL");
+
+static int rmap_hash_size;
+module_param(rmap_hash_size, int, 0);
+MODULE_PARM_DESC(rmap_hash_size, "Hash table size for the reverse mapping");
+
+/*
+ * ksm_mem_slot - hold information for an userspace scanning range
+ * (the scanning for this region will be from addr untill addr +
+ *  npages * PAGE_SIZE inside mm)
+ */
+struct ksm_mem_slot {
+	struct list_head link;
+	struct list_head sma_link;
+	struct mm_struct *mm;
+	unsigned long addr;	/* the begining of the virtual address */
+	unsigned npages;	/* number of pages to share */
+};
+
+/*
+ * ksm_sma - shared memory area, each process have its own sma that contain the
+ * information about the slots that it own
+ */
+struct ksm_sma {
+	struct list_head sma_slots;
+};
+
+/**
+ * struct ksm_scan - cursor for scanning
+ * @slot_index: the current slot we are scanning
+ * @page_index: the page inside the sma that is currently being scanned
+ *
+ * ksm uses it to know what are the next pages it need to scan
+ */
+struct ksm_scan {
+	struct ksm_mem_slot *slot_index;
+	unsigned long page_index;
+};
+
+/*
+ * Few notes about ksm scanning progress (make it easier to understand the
+ * data structures below):
+ *
+ * In order to reduce excessive scanning, ksm sort the memory pages by their
+ * contents into a data strcture that hold pointer into the pages.
+ *
+ * Since the contents of the pages may change at any moment, ksm cant just
+ * insert the pages into normal sorted tree and expect it to find anything.
+ *
+ * For this purpuse ksm use two data strctures - stable and unstable trees,
+ * the stable tree hold pointers into all the merged pages (KsmPage) sorted by
+ * their contents, beacuse that each such page have to be write-protected,
+ * searching on this tree is fully assuranced to be working and therefore this
+ * tree is called the stable tree.
+ *
+ * In addition to the stable tree, ksm use another data strcture called the
+ * unstable tree, this specific tree hold pointers into pages that have
+ * been found to be "unchanged for period of time", the unstable tree sort this
+ * pages by their contents, but given the fact that this pages are not
+ * write-protected, ksm cant trust the unstable tree to be fully assuranced to
+ * work.
+ * For the reason that the unstable tree would become corrupted when some of
+ * the page inside itself would change, the tree is called unstable.
+ * Ksm solve this problem by two ways:
+ * 1) the unstable tree get flushed every time ksm finish to scan the whole
+ *    memory, and then the tree is rebuild from the begining.
+ * 2) Ksm will only insert into the unstable tree, pages that their hash value
+ *    was not changed during the whole progress of one circuler scanning of the
+ *    memory.
+ * 3) The unstable tree is RedBlack Tree - meaning its balancing is based on
+ *    the colors of the nodes and not their content, this assure that even when
+ *    the tree get "corrupted" we wont get out of balance and the timing of
+ *    scanning is the same, another issue is that searching and inserting nodes
+ *    into rbtree is the same algorithem, therefore we have no overhead when we
+ *    flush the tree and rebuild it.
+ * 4) Ksm never flush the stable tree, this mean that even if it would take 10
+ *    times to find page inside the unstable tree, as soon as we would find it,
+ *    it will be secured inside the stable tree,
+ *    (When we scan new page, we first compare it against the stable tree, and
+ *     then against the unstable tree)
+ */
+
+struct rmap_item;
+
+/*
+ * tree_item - object of the stable and unstable trees
+ */
+struct tree_item {
+	struct rb_node node;
+	struct rmap_item *rmap_item;
+};
+
+/*
+ * rmap_item - object of the rmap_hash hash table
+ * (it is holding the previous hash value (oldindex),
+ *  pointer into the page_hash_item, and pointer into the tree_item)
+ */
+
+/**
+ * struct rmap_item - reverse mapping item for virtual addresses
+ * @link: link into the rmap_hash hash table.
+ * @mm: the memory strcture the rmap_item is pointing to.
+ * @address: the virtual address the rmap_item is pointing to.
+ * @oldchecksum: old checksum result for the page belong the virtual address
+ * @stable_tree: when 1 rmap_item is used for stable_tree, 0 unstable tree
+ * @kpage_outside_tree: when 1 this rmap_item point into kpage outside tree
+ * @tree_item: pointer into the stable/unstable tree that hold the virtual
+ *             address that the rmap_item is pointing to.
+ * @next: the next rmap item inside the stable/unstable tree that have that is
+ *        found inside the same tree node.
+ */
+
+struct rmap_item {
+	struct hlist_node link;
+	struct mm_struct *mm;
+	unsigned long address;
+	unsigned int oldchecksum; /* old checksum value */
+	unsigned char stable_tree; /* 1 stable_tree 0 unstable tree */
+	unsigned char kpage_outside_tree;
+	struct tree_item *tree_item;
+	struct rmap_item *next;
+	struct rmap_item *prev;
+};
+
+/*
+ * slots is linked list that hold all the memory regions that were registred
+ * to be scanned.
+ */
+static LIST_HEAD(slots);
+/*
+ * slots_lock protects against removing and adding memory regions while a scanner
+ * is in the middle of scanning.
+ */
+static DECLARE_RWSEM(slots_lock);
+
+/* The stable and unstable trees heads. */
+struct rb_root root_stable_tree = RB_ROOT;
+struct rb_root root_unstable_tree = RB_ROOT;
+
+
+/* The number of linked list members inside the hash table */
+static unsigned int nrmaps_hash;
+/* rmap_hash hash table */
+static struct hlist_head *rmap_hash;
+
+static struct kmem_cache *tree_item_cache;
+static struct kmem_cache *rmap_item_cache;
+
+/* the number of nodes inside the stable tree */
+static unsigned long nnodes_stable_tree;
+
+/* the number of kernel allocated pages outside the stable tree */
+static unsigned long nkpage_out_tree;
+
+static int ksm_thread_sleep; /* sleep time of the kernel thread */
+static int ksm_thread_pages_to_scan; /* npages to scan for the kernel thread */
+static int ksm_thread_max_kernel_pages; /* num of unswappable pages allowed */
+static unsigned long ksm_pages_shared;
+static struct ksm_scan ksm_thread_scan;
+static int ksmd_flags;
+static struct task_struct *ksm_thread;
+static DECLARE_WAIT_QUEUE_HEAD(ksm_thread_wait);
+static DECLARE_RWSEM(ksm_thread_lock);
+
+
+static int ksm_slab_init(void)
+{
+	int ret = -ENOMEM;
+
+	tree_item_cache = KMEM_CACHE(tree_item, 0);
+	if (!tree_item_cache)
+		goto out;
+
+	rmap_item_cache = KMEM_CACHE(rmap_item, 0);
+	if (!rmap_item_cache)
+		goto out_free;
+
+	return 0;
+
+out_free:
+	kmem_cache_destroy(tree_item_cache);
+out:
+	return ret;
+}
+
+static void ksm_slab_free(void)
+{
+	kmem_cache_destroy(rmap_item_cache);
+	kmem_cache_destroy(tree_item_cache);
+}
+
+static inline struct tree_item *alloc_tree_item(void)
+{
+	return kmem_cache_zalloc(tree_item_cache, GFP_KERNEL);
+}
+
+static void free_tree_item(struct tree_item *tree_item)
+{
+	kmem_cache_free(tree_item_cache, tree_item);
+}
+
+static inline struct rmap_item *alloc_rmap_item(void)
+{
+	return kmem_cache_zalloc(rmap_item_cache, GFP_KERNEL);
+}
+
+static inline void free_rmap_item(struct rmap_item *rmap_item)
+{
+	kmem_cache_free(rmap_item_cache, rmap_item);
+}
+
+static unsigned long addr_in_vma(struct vm_area_struct *vma, struct page *page)
+{
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	unsigned long addr;
+
+	addr = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
+	if (unlikely(addr < vma->vm_start || addr >= vma->vm_end))
+		return -EFAULT;
+	return addr;
+}
+
+static int is_present_pte(struct mm_struct *mm, unsigned long addr)
+{
+	pte_t *ptep;
+	int r;
+
+	ptep = get_pte(mm, addr);
+	if (!ptep)
+		return 0;
+
+	r = pte_present(*ptep);
+	pte_unmap(ptep);
+
+	return r;
+}
+
+/*
+ * PageKsm - this type of pages are the write protected pages that ksm map
+ * into multiple vmas (this is the "shared page")
+ * this page was allocated using alloc_page(), and every pte that point to it
+ * is always write protected (therefore its data content cant ever be changed)
+ * and this page cant be swapped.
+ */
+static inline int PageKsm(struct page *page)
+{
+	/*
+	 * When ksm create new shared page, it create kernel allocated page
+	 * using alloc_page(), therefore this page is not anonymous, taking into
+	 * account that ksm scan just anonymous pages, we can relay on the fact
+	 * that each time we see !PageAnon(page) we are hitting shared page,
+	 * in addition to this check, to be 100% sure we are dealing with
+	 * KsmPage we have to check for !vm_file.
+	 */
+	return !PageAnon(page);
+}
+
+static int rmap_hash_init(void)
+{
+	if (!rmap_hash_size) {
+		struct sysinfo sinfo;
+
+		si_meminfo(&sinfo);
+		rmap_hash_size = sinfo.totalram / 10;
+	}
+	nrmaps_hash = rmap_hash_size;
+	rmap_hash = vmalloc(nrmaps_hash * sizeof(struct hlist_head));
+	if (!rmap_hash)
+		return -ENOMEM;
+	memset(rmap_hash, 0, nrmaps_hash * sizeof(struct hlist_head));
+	return 0;
+}
+
+static void rmap_hash_free(void)
+{
+	int i;
+	struct hlist_head *bucket;
+	struct hlist_node *node, *n;
+	struct rmap_item *rmap_item;
+
+	for (i = 0; i < nrmaps_hash; ++i) {
+		bucket = &rmap_hash[i];
+		hlist_for_each_entry_safe(rmap_item, node, n, bucket, link) {
+			hlist_del(&rmap_item->link);
+			free_rmap_item(rmap_item);
+		}
+	}
+	vfree(rmap_hash);
+}
+
+static inline u32 calc_checksum(struct page *page)
+{
+	u32 checksum;
+	void *addr = kmap_atomic(page, KM_USER0);
+	checksum = jhash2(addr, PAGE_SIZE / 4, 17);
+	kunmap_atomic(addr, KM_USER0);
+	return checksum;
+}
+
+/*
+ * Return rmap_item for a given virtual address.
+ */
+static struct rmap_item *get_rmap_item(struct mm_struct *mm, unsigned long addr)
+{
+	struct rmap_item *rmap_item;
+	struct hlist_head *bucket;
+	struct hlist_node *node;
+
+	bucket = &rmap_hash[addr % nrmaps_hash];
+	hlist_for_each_entry(rmap_item, node, bucket, link) {
+		if (mm == rmap_item->mm && rmap_item->address == addr) {
+			return rmap_item;
+		}
+	}
+	return NULL;
+}
+
+/*
+ * Removing rmap_item from stable or unstable tree.
+ * This function will free the rmap_item object, and if that rmap_item was
+ * insde the stable or unstable trees, it would remove the link from there
+ * as well.
+ */
+static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
+{
+	struct tree_item *tree_item;
+
+	tree_item = rmap_item->tree_item;
+	rmap_item->tree_item = NULL;
+
+	if (rmap_item->stable_tree) {
+		ksm_pages_shared--;
+		if (rmap_item->prev) {
+			BUG_ON(rmap_item->prev->next != rmap_item);
+			rmap_item->prev->next = rmap_item->next;
+		}
+		if (rmap_item->next) {
+			BUG_ON(rmap_item->next->prev != rmap_item);
+			rmap_item->next->prev = rmap_item->prev;
+		}
+	} else if (rmap_item->kpage_outside_tree) {
+		ksm_pages_shared--;
+		nkpage_out_tree--;
+	}
+
+	if (tree_item) {
+		if (rmap_item->stable_tree) {
+	 		if (!rmap_item->next && !rmap_item->prev) {
+				rb_erase(&tree_item->node, &root_stable_tree);
+				free_tree_item(tree_item);
+				nnodes_stable_tree--;
+			} else if (!rmap_item->prev) {
+				tree_item->rmap_item = rmap_item->next;
+			} else {
+				tree_item->rmap_item = rmap_item->prev;
+			}
+		} else {
+			/*
+			 * We dont rb_erase(&tree_item->node) here, beacuse
+			 * that the unstable tree will get flushed before we are
+			 * here.
+			 */
+			free_tree_item(tree_item);
+		}
+	}
+
+	hlist_del(&rmap_item->link);
+	free_rmap_item(rmap_item);
+}
+
+static void break_cow(struct mm_struct *mm, unsigned long addr)
+{
+	struct page *page[1];
+
+	down_read(&mm->mmap_sem);
+	if (get_user_pages(current, mm, addr, 1, 1, 0, page, NULL) == 1)
+		put_page(page[0]);
+	up_read(&mm->mmap_sem);
+}
+
+static void remove_page_from_tree(struct mm_struct *mm,
+				  unsigned long addr)
+{
+	struct rmap_item *rmap_item;
+
+	rmap_item = get_rmap_item(mm, addr);
+	if (!rmap_item)
+		return;
+
+	if (rmap_item->stable_tree) {
+		/* We are breaking all the KsmPages of area that is removed */
+		break_cow(mm, addr);
+	} else {
+		/*
+		 * If kpage_outside_tree is set, this item is KsmPage outside
+		 * the stable tree, therefor we have to break the COW and
+		 * in addition we have to dec nkpage_out_tree.
+		 */
+		if (rmap_item->kpage_outside_tree)
+			break_cow(mm, addr);
+	}
+
+	remove_rmap_item_from_tree(rmap_item);
+}
+
+static int ksm_sma_ioctl_register_memory_region(struct ksm_sma *ksm_sma,
+						struct ksm_memory_region *mem)
+{
+	struct ksm_mem_slot *slot;
+	int ret = -EPERM;
+
+	slot = kzalloc(sizeof(struct ksm_mem_slot), GFP_KERNEL);
+	if (!slot) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	/*
+	 * We will hold refernce to the task_mm untill the file descriptor
+	 * will be closed, or KSM_REMOVE_MEMORY_REGION will be called.
+	 */
+	slot->mm = get_task_mm(current);
+	if (!slot->mm)
+		goto out_free;
+	slot->addr = mem->addr;
+	slot->npages = mem->npages;
+
+	down_write(&slots_lock);
+
+	list_add_tail(&slot->link, &slots);
+	list_add_tail(&slot->sma_link, &ksm_sma->sma_slots);
+
+	up_write(&slots_lock);
+	return 0;
+
+out_free:
+	kfree(slot);
+out:
+	return ret;
+}
+
+static void remove_mm_from_hash_and_tree(struct mm_struct *mm)
+{
+	struct ksm_mem_slot *slot;
+	int pages_count;
+
+	list_for_each_entry(slot, &slots, link)
+		if (slot->mm == mm)
+			break;
+	BUG_ON(!slot);
+
+	root_unstable_tree = RB_ROOT;
+	for (pages_count = 0; pages_count < slot->npages; ++pages_count)
+		remove_page_from_tree(mm, slot->addr +
+				      pages_count * PAGE_SIZE);
+	/* Called under slots_lock */
+	list_del(&slot->link);
+}
+
+static int ksm_sma_ioctl_remove_memory_region(struct ksm_sma *ksm_sma)
+{
+	struct ksm_mem_slot *slot, *node;
+
+	down_write(&slots_lock);
+	list_for_each_entry_safe(slot, node, &ksm_sma->sma_slots, sma_link) {
+		remove_mm_from_hash_and_tree(slot->mm);
+		mmput(slot->mm);
+		list_del(&slot->sma_link);
+		kfree(slot);
+	}
+	up_write(&slots_lock);
+	return 0;
+}
+
+static int ksm_sma_release(struct inode *inode, struct file *filp)
+{
+	struct ksm_sma *ksm_sma = filp->private_data;
+	int r;
+
+	r = ksm_sma_ioctl_remove_memory_region(ksm_sma);
+	kfree(ksm_sma);
+	return r;
+}
+
+static long ksm_sma_ioctl(struct file *filp,
+			  unsigned int ioctl, unsigned long arg)
+{
+	struct ksm_sma *sma = filp->private_data;
+	void __user *argp = (void __user *)arg;
+	int r = EINVAL;
+
+	switch (ioctl) {
+	case KSM_REGISTER_MEMORY_REGION: {
+		struct ksm_memory_region ksm_memory_region;
+
+		r = -EFAULT;
+		if (copy_from_user(&ksm_memory_region, argp,
+				   sizeof(ksm_memory_region)))
+			goto out;
+		r = ksm_sma_ioctl_register_memory_region(sma,
+							 &ksm_memory_region);
+		break;
+	}
+	case KSM_REMOVE_MEMORY_REGION:
+		r = ksm_sma_ioctl_remove_memory_region(sma);
+		break;
+	}
+
+out:
+	return r;
+}
+
+static int memcmp_pages(struct page *page1, struct page *page2)
+{
+	char *addr1, *addr2;
+	int r;
+
+	addr1 = kmap_atomic(page1, KM_USER0);
+	addr2 = kmap_atomic(page2, KM_USER1);
+	r = memcmp(addr1, addr2, PAGE_SIZE);
+	kunmap_atomic(addr1, KM_USER0);
+	kunmap_atomic(addr2, KM_USER1);
+	return r;
+}
+
+/* pages_identical
+ * return 1 if identical, 0 otherwise.
+ */
+static inline int pages_identical(struct page *page1, struct page *page2)
+{
+	return !memcmp_pages(page1, page2);
+}
+
+/*
+ * try_to_merge_one_page - take two pages and merge them into one
+ * @mm: mm_struct that hold vma pointing into oldpage
+ * @vma: the vma that hold the pte pointing into oldpage
+ * @oldpage: the page that we want to replace with newpage
+ * @newpage: the page that we want to map instead of oldpage
+ * @newprot: the new permission of the pte inside vma
+ * note:
+ * oldpage should be anon page while newpage should be file mapped page
+ *
+ * this function return 0 if the pages were merged, 1 otherwise.
+ */
+static int try_to_merge_one_page(struct mm_struct *mm,
+				 struct vm_area_struct *vma,
+				 struct page *oldpage,
+				 struct page *newpage,
+				 pgprot_t newprot)
+{
+	int ret = 1;
+	int odirect_sync;
+	unsigned long page_addr_in_vma;
+	pte_t orig_pte, *orig_ptep;
+
+	if (!PageAnon(oldpage))
+		goto out;
+
+	get_page(newpage);
+	get_page(oldpage);
+
+	page_addr_in_vma = addr_in_vma(vma, oldpage);
+	if (page_addr_in_vma == -EFAULT)
+		goto out_putpage;
+
+	orig_ptep = get_pte(mm, page_addr_in_vma);
+	if (!orig_ptep)
+		goto out_putpage;
+	orig_pte = *orig_ptep;
+	pte_unmap(orig_ptep);
+	if (!pte_present(orig_pte))
+		goto out_putpage;
+	if (page_to_pfn(oldpage) != pte_pfn(orig_pte))
+		goto out_putpage;
+	/*
+	 * we need the page lock to read a stable PageSwapCache in
+	 * page_wrprotect().
+	 * we use trylock_page() instead of lock_page(), beacuse we dont want to
+	 * wait here, we prefer to continue scanning and merging diffrent pages
+	 * and to come back to this page when it is unlocked.
+	 */
+	if (!trylock_page(oldpage))
+		goto out_putpage;
+	/*
+	 * page_wrprotect check if the page is swapped or in swap cache,
+	 * in the future we might want to run here if_present_pte and then
+	 * swap_free
+	 */
+	if (!page_wrprotect(oldpage, &odirect_sync, 2)) {
+		unlock_page(oldpage);
+		goto out_putpage;
+	}
+	unlock_page(oldpage);
+	if (!odirect_sync)
+		goto out_putpage;
+
+	orig_pte = pte_wrprotect(orig_pte);
+
+	if (pages_identical(oldpage, newpage))
+		ret = replace_page(vma, oldpage, newpage, orig_pte, newprot);
+
+out_putpage:
+	put_page(oldpage);
+	put_page(newpage);
+out:
+	return ret;
+}
+
+/*
+ * try_to_merge_two_pages_alloc - take two identical pages and prepare them
+ * to be merged into one page.
+ *
+ * this function return 0 if we successfully mapped two identical pages into one
+ * page, 1 otherwise.
+ * (note this function will allocate a new kernel page, if one of the pages
+ * is already shared page (KsmPage), then try_to_merge_two_pages_noalloc()
+ * should be called.)
+ */
+
+static int try_to_merge_two_pages_alloc(struct mm_struct *mm1,
+					struct page *page1,
+					struct mm_struct *mm2,
+					struct page *page2,
+					unsigned long addr1,
+					unsigned long addr2)
+{
+	struct vm_area_struct *vma;
+	pgprot_t prot;
+	int ret = 1;
+	struct page *kpage;
+
+	/*
+	 * The number of the nodes inside the stable tree +
+	 * nkpage_out_tree is the same as the number kernel pages that
+	 * we hold.
+	 */
+	if (ksm_thread_max_kernel_pages &&
+	    (nnodes_stable_tree + nkpage_out_tree) >=
+	    ksm_thread_max_kernel_pages)
+		return ret;
+
+	kpage = alloc_page(GFP_HIGHUSER);
+	if (!kpage)
+		return ret;
+	down_read(&mm1->mmap_sem);
+	vma = find_vma(mm1, addr1);
+	if (!vma) {
+		put_page(kpage);
+		up_read(&mm1->mmap_sem);
+		return ret;
+	}
+	prot = vma->vm_page_prot;
+	pgprot_val(prot) &= ~_PAGE_RW;
+
+	copy_user_highpage(kpage, page1, addr1, vma);
+	ret = try_to_merge_one_page(mm1, vma, page1, kpage, prot);
+	up_read(&mm1->mmap_sem);
+
+	if (!ret) {
+		down_read(&mm2->mmap_sem);
+		vma = find_vma(mm2, addr2);
+		if (!vma) {
+			put_page(kpage);
+			up_read(&mm2->mmap_sem);
+			break_cow(mm1, addr1);
+			ret = 1;
+			return ret;
+		}
+
+		prot = vma->vm_page_prot;
+		pgprot_val(prot) &= ~_PAGE_RW;
+
+		ret = try_to_merge_one_page(mm2, vma, page2, kpage,
+					    prot);
+		up_read(&mm2->mmap_sem);
+		/*
+		 * If the secoend try_to_merge_one_page call was failed,
+		 * we are in situation where we have Ksm page that have
+		 * just one pte pointing to it, in this case we break
+		 * it.
+		 */
+		if (ret) {
+			break_cow(mm1, addr1);
+		} else {
+			ksm_pages_shared += 2;
+		}
+	}
+
+	put_page(kpage);
+	return ret;
+}
+
+/*
+ * try_to_merge_two_pages_noalloc - the same astry_to_merge_two_pages_alloc,
+ * but no new kernel page is allocated (page2 should be KsmPage)
+ */
+static int try_to_merge_two_pages_noalloc(struct mm_struct *mm1,
+					  struct page *page1,
+					  struct page *page2,
+					  unsigned long addr1)
+{
+	struct vm_area_struct *vma;
+	pgprot_t prot;
+	int ret = 1;
+
+	/*
+	 * If page2 is shared, we can just make the pte of mm1(page1) point to
+	 * page2.
+	 */
+	BUG_ON(!PageKsm(page2));
+	down_read(&mm1->mmap_sem);
+	vma = find_vma(mm1, addr1);
+	if (!vma) {
+		up_read(&mm1->mmap_sem);
+		return ret;
+	}
+	prot = vma->vm_page_prot;
+	pgprot_val(prot) &= ~_PAGE_RW;
+	ret = try_to_merge_one_page(mm1, vma, page1, page2, prot);
+	up_read(&mm1->mmap_sem);
+	if (!ret)
+		ksm_pages_shared++;
+
+	return ret;
+}
+
+/*
+ * is_zapped_item - check if the page belong to the rmap_item was zapped.
+ *
+ * This function would check if the page that the virtual address inside
+ * rmap_item is poiting to is still KsmPage, and therefore we can trust the
+ * content of this page.
+ * Since that this function call already to get_user_pages it return the
+ * pointer to the page as an optimization.
+ */
+static int is_zapped_item(struct rmap_item *rmap_item,
+			  struct page **page)
+{
+	int ret = 0;
+	struct vm_area_struct *vma;
+
+	cond_resched();
+	if (is_present_pte(rmap_item->mm, rmap_item->address)) {
+		down_read(&rmap_item->mm->mmap_sem);
+		vma = find_vma(rmap_item->mm, rmap_item->address);
+		if (vma && !vma->vm_file) {
+			BUG_ON(vma->vm_flags & VM_SHARED);
+			ret = get_user_pages(current, rmap_item->mm,
+					     rmap_item->address,
+					     1, 0, 0, page, NULL);
+		}
+		up_read(&rmap_item->mm->mmap_sem);
+	}
+
+	if (ret != 1)
+		return 1;
+
+	if (unlikely(!PageKsm(page[0]))) { 
+		put_page(page[0]);
+		return 1;
+	}
+	return 0;
+}
+
+/*
+ * stable_tree_search - search page inside the stable tree
+ * @page: the page that we are searching idneitcal pages to.
+ * @page2: pointer into identical page that we are holding inside the stable
+ *	   tree that we have found.
+ * @rmap_item: the reverse mapping item
+ *
+ * this function check if there is a page inside the stable tree
+ * with identical content to the page that we are scanning right now.
+ *
+ * this function return rmap_item pointer to the identical item if found, NULL
+ * otherwise.
+ */
+static struct rmap_item *stable_tree_search(struct page *page,
+					    struct page **page2,
+					    struct rmap_item *rmap_item)
+{
+	struct rb_node *node = root_stable_tree.rb_node;
+	struct tree_item *tree_item;
+	struct rmap_item *found_rmap_item;
+
+	while (node) {
+		int ret;
+
+		tree_item = rb_entry(node, struct tree_item, node);
+		found_rmap_item = tree_item->rmap_item;
+		while (found_rmap_item) {
+			BUG_ON(!found_rmap_item->stable_tree);
+			BUG_ON(!found_rmap_item->tree_item);
+			if (!rmap_item ||
+			     !(found_rmap_item->mm == rmap_item->mm &&
+			      found_rmap_item->address == rmap_item->address)) {
+				if (!is_zapped_item(found_rmap_item, page2))
+					break;
+				remove_rmap_item_from_tree(found_rmap_item);
+			}
+			found_rmap_item = found_rmap_item->next;
+		}
+		if (!found_rmap_item)
+			goto out_didnt_find;
+
+		/*
+		 * We can trust the value of the memcmp as we know the pages
+		 * are write protected.
+		 */
+		ret = memcmp_pages(page, page2[0]);
+
+		if (ret < 0) {
+			put_page(page2[0]);
+			node = node->rb_left;
+		} else if (ret > 0) {
+			put_page(page2[0]);
+			node = node->rb_right;
+		} else {
+			goto out_found;
+		}
+	}
+out_didnt_find:
+	found_rmap_item = NULL;
+out_found:
+	return found_rmap_item;
+}
+
+/*
+ * stable_tree_insert - insert into the stable tree, new rmap_item that is
+ * pointing into a new KsmPage.
+ *
+ * @page: the page that we are searching identical page to inside the stable
+ *	  tree.
+ * @new_tree_item: the new tree item we are going to link into the stable tree.
+ * @rmap_item: pointer into the reverse mapping item.
+ *
+ * this function return 0 if success, 1 otherwise.
+ * otherwise.
+ */
+static int stable_tree_insert(struct page *page,
+			      struct tree_item *new_tree_item,
+			      struct rmap_item *rmap_item)
+{
+	struct rb_node **new = &(root_stable_tree.rb_node);
+	struct rb_node *parent = NULL;
+	struct tree_item *tree_item;
+	struct page *page2[1];
+
+	while (*new) {
+		int ret;
+		struct rmap_item *insert_rmap_item;
+
+		tree_item = rb_entry(*new, struct tree_item, node);
+		BUG_ON(!tree_item);
+		BUG_ON(!tree_item->rmap_item);
+
+		insert_rmap_item = tree_item->rmap_item;
+		while (insert_rmap_item) {
+			BUG_ON(!insert_rmap_item->stable_tree);
+			BUG_ON(!insert_rmap_item->tree_item);
+			if (!(insert_rmap_item->mm == rmap_item->mm &&
+			     insert_rmap_item->address == rmap_item->address)) {
+				if (!is_zapped_item(insert_rmap_item, page2))
+					break;
+				remove_rmap_item_from_tree(insert_rmap_item);
+			}
+			insert_rmap_item = insert_rmap_item->next;
+		}
+		if (!insert_rmap_item)
+			return 1;
+
+		ret = memcmp_pages(page, page2[0]);
+
+		parent = *new;
+		if (ret < 0) {
+			put_page(page2[0]);
+			new = &((*new)->rb_left);
+		} else if (ret > 0) {
+			put_page(page2[0]);
+			new = &((*new)->rb_right);
+		} else {
+			/*
+			 * It isnt a bug when we are here (the fact that we
+			 * didnt find the page inside the stable tree), beacuse:
+			 * when we searched the page inside the stable tree
+			 * it was still not write protected, and therefore it
+			 * could have changed later.
+			 */
+			return 1;
+		}
+	}
+
+	rb_link_node(&new_tree_item->node, parent, new);
+	rb_insert_color(&new_tree_item->node, &root_stable_tree);
+	nnodes_stable_tree++;
+	rmap_item->stable_tree = 1;
+	rmap_item->tree_item = new_tree_item;
+
+	return 0;
+}
+
+/*
+ * unstable_tree_search_insert - search and insert items into the unstable tree.
+ *
+ * @page: the page that we are going to search for identical page or to insert
+ *	  into the unstable tree
+ * @page2: pointer into identical page that was found inside the unstable tree
+ * @page_rmap_item: the reverse mapping item of page
+ *
+ * this function search if identical page to the page that we
+ * are scanning right now is found inside the unstable tree, and in case no page
+ * with identical content is exist inside the unstable tree, we insert
+ * page_rmap_item as a new object into the unstable tree.
+ *
+ * this function return pointer to rmap_item pointer of item that is found to
+ * be identical to the page that we are scanning right now, NULL otherwise.
+ *
+ * (this function do both searching and inserting, beacuse the fact that
+ *  searching and inserting share the same walking algorithem in rbtrees)
+ */
+static struct tree_item *unstable_tree_search_insert(struct page *page,
+					struct page **page2,
+					struct rmap_item *page_rmap_item)
+{
+	struct rb_node **new = &(root_unstable_tree.rb_node);
+	struct rb_node *parent = NULL;
+	struct tree_item *tree_item;
+	struct tree_item *new_tree_item;
+	struct rmap_item *rmap_item;
+
+	while (*new) {
+		int ret;
+
+		tree_item = rb_entry(*new, struct tree_item, node);
+		BUG_ON(!tree_item);
+		rmap_item = tree_item->rmap_item;
+		BUG_ON(!rmap_item);
+
+		/*
+		 * We dont want to swap in pages
+		 */
+		if (!is_present_pte(rmap_item->mm, rmap_item->address))
+			return NULL;
+
+		down_read(&rmap_item->mm->mmap_sem);
+		ret = get_user_pages(current, rmap_item->mm, rmap_item->address,
+				     1, 0, 0, page2, NULL);
+		up_read(&rmap_item->mm->mmap_sem);
+		if (ret != 1)
+			return NULL;
+
+		ret = memcmp_pages(page, page2[0]);
+
+		parent = *new;
+		if (ret < 0) {
+			put_page(page2[0]);
+			new = &((*new)->rb_left);
+		} else if (ret > 0) {
+			put_page(page2[0]);
+			new = &((*new)->rb_right);
+		} else {
+			return tree_item;
+		}
+	}
+
+	if (!page_rmap_item)
+		return NULL;
+
+	new_tree_item = alloc_tree_item();
+	if (!new_tree_item)
+		return NULL;
+
+	page_rmap_item->tree_item = new_tree_item;
+	page_rmap_item->stable_tree = 0;
+	new_tree_item->rmap_item = page_rmap_item;
+	rb_link_node(&new_tree_item->node, parent, new);
+	rb_insert_color(&new_tree_item->node, &root_unstable_tree);
+
+	return NULL;
+}
+
+/*
+ * update_stable_tree - check if the page inside tree got zapped,
+ * and if it got zapped, kick it from the tree.
+ *
+ * we return 1 in case we removed the rmap_item.
+ */
+int update_tree(struct rmap_item *rmap_item)
+{
+	if (!rmap_item->stable_tree) {
+		if (unlikely(rmap_item->kpage_outside_tree)) {
+			remove_rmap_item_from_tree(rmap_item);
+			return 1;
+		}
+		/*
+		 * If the rmap_item is !stable_tree and in addition
+		 * it have tree_item != NULL, it mean this rmap_item
+		 * was inside the unstable tree, therefore we have to free
+		 * the tree_item from it (beacuse the unstable tree was already
+		 * flushed by the time we are here).
+		 */
+		if (rmap_item->tree_item) {
+			free_tree_item(rmap_item->tree_item);
+			rmap_item->tree_item = NULL;
+			return 0;
+		}
+		return 0;
+	}
+	/*
+	 * If we are here it mean the rmap_item was zapped, beacuse the
+	 * rmap_item was pointing into the stable_tree and there all the pages
+	 * should be KsmPages, so it shouldnt have came to here in the first
+	 * place. (cmp_and_merge_page() shouldnt have been called)
+	 */
+	remove_rmap_item_from_tree(rmap_item);
+	return 1;
+}
+
+static void create_new_rmap_item(struct rmap_item *rmap_item,
+				 struct mm_struct *mm,
+				 unsigned long addr,
+				 unsigned int checksum)
+{
+	struct hlist_head *bucket;
+
+	rmap_item->mm = mm;
+	rmap_item->address = addr;
+	rmap_item->oldchecksum = checksum;
+	rmap_item->stable_tree = 0;
+	rmap_item->kpage_outside_tree = 0;
+	rmap_item->tree_item = NULL;
+
+	bucket = &rmap_hash[addr % nrmaps_hash];
+	hlist_add_head(&rmap_item->link, bucket);
+}
+
+/*
+ * insert_to_stable_tree_list - insert another rmap_item into the linked list
+ * rmap_items of a given node inside the stable tree.
+ */
+static void insert_to_stable_tree_list(struct rmap_item *rmap_item,
+				       struct rmap_item *tree_rmap_item)
+{
+	rmap_item->next = tree_rmap_item->next;
+	rmap_item->prev = tree_rmap_item;
+
+	if (tree_rmap_item->next)
+		tree_rmap_item->next->prev = rmap_item;
+
+	tree_rmap_item->next = rmap_item;
+
+	rmap_item->stable_tree = 1;
+	rmap_item->tree_item = tree_rmap_item->tree_item;
+}
+
+/*
+ * cmp_and_merge_page - take a page computes its hash value and check if there
+ * is similar hash value to different page,
+ * in case we find that there is similar hash to different page we call to
+ * try_to_merge_two_pages().
+ *
+ * @ksm_scan: the ksm scanner strcture.
+ * @page: the page that we are searching identical page to.
+ */
+static int cmp_and_merge_page(struct ksm_scan *ksm_scan, struct page *page)
+{
+	struct page *page2[1];
+	struct ksm_mem_slot *slot;
+	struct tree_item *tree_item;
+	struct rmap_item *rmap_item;
+	struct rmap_item *tree_rmap_item;
+	unsigned int checksum;
+	unsigned long addr;
+	int wait = 0;
+	int ret = 0;
+
+	slot = ksm_scan->slot_index;
+	addr = slot->addr + ksm_scan->page_index * PAGE_SIZE;
+	rmap_item = get_rmap_item(slot->mm, addr);
+	if (rmap_item) {
+		if (update_tree(rmap_item)) {
+			rmap_item = NULL;
+			wait = 1;
+		}
+	}
+
+	/* We first start with searching the page inside the stable tree */
+	tree_rmap_item = stable_tree_search(page, page2, rmap_item);
+	if (tree_rmap_item) {
+		struct rmap_item *tmp_rmap_item = NULL;
+
+		if (!rmap_item) {
+			tmp_rmap_item = alloc_rmap_item();
+			if (!tmp_rmap_item)
+				return ret;
+		}
+
+		BUG_ON(!tree_rmap_item->tree_item);
+		ret = try_to_merge_two_pages_noalloc(slot->mm, page, page2[0],
+						     addr);
+		put_page(page2[0]);
+		if (!ret) {
+			/*
+			 * The page was successuly merged, lets insert its
+			 * rmap_item into the stable tree.
+			 */
+
+			if (!rmap_item) {
+				create_new_rmap_item(tmp_rmap_item, slot->mm,
+						     addr, 0);
+				rmap_item = tmp_rmap_item;
+			}
+
+			insert_to_stable_tree_list(rmap_item, tree_rmap_item);
+		} else {
+			if (tmp_rmap_item)
+				free_rmap_item(tmp_rmap_item);
+		}
+		ret = !ret;
+		goto out;
+	}
+
+	/*
+	 * In case the hash value of the page was changed from the last time we
+	 * have calculated it, this page to be changed frequely, therefore we
+	 * dont want to insert it to the unstable tree, and we dont want to
+	 * waste our time to search if there is something identical to it there.
+	 */
+	if (rmap_item) {
+		checksum = calc_checksum(page);
+		if (rmap_item->oldchecksum != checksum) {
+			rmap_item->oldchecksum = checksum;
+			goto out;
+		}
+	}
+
+	tree_item = unstable_tree_search_insert(page, page2, rmap_item);
+	if (tree_item) {
+		struct rmap_item *tmp_rmap_item = NULL;
+		struct rmap_item *merge_rmap_item;
+
+		merge_rmap_item = tree_item->rmap_item;
+		BUG_ON(!merge_rmap_item);
+
+		if (!rmap_item) {
+			tmp_rmap_item = alloc_rmap_item();
+			if (!tmp_rmap_item)
+				return ret;
+		}
+
+		ret = try_to_merge_two_pages_alloc(slot->mm, page,
+						   merge_rmap_item->mm,
+						   page2[0], addr,
+						   merge_rmap_item->address);
+		/*
+		 * As soon as we successuly merged this page, we want to remove
+		 * the rmap_item object of the page that we have merged with
+		 * from the unstable_tree and instead insert it as a new stable
+		 * tree node.
+		 */
+		if (!ret) {
+			rb_erase(&tree_item->node, &root_unstable_tree);
+			/*
+			 * In case we will fail to insert the page into
+			 * the stable tree, we will have 2 virtual addresses
+			 * that are pointing into KsmPage that wont be inside
+			 * the stable tree, therefore we have to mark both of
+			 * their rmap as tree_item->kpage_outside_tree = 1
+			 * and to inc nkpage_out_tree by 2.
+			 */
+			if (stable_tree_insert(page2[0],
+					       tree_item, merge_rmap_item)) {
+				merge_rmap_item->kpage_outside_tree = 1;
+				if (!rmap_item) {
+					create_new_rmap_item(tmp_rmap_item,
+							     slot->mm,
+							     addr, 0);
+					rmap_item = tmp_rmap_item;
+				}
+				rmap_item->kpage_outside_tree = 1;
+				nkpage_out_tree += 2;
+			} else {
+				if (tmp_rmap_item) {
+					create_new_rmap_item(tmp_rmap_item,
+							     slot->mm, addr, 0);
+					rmap_item = tmp_rmap_item;
+				}
+				insert_to_stable_tree_list(rmap_item,
+							   merge_rmap_item);
+			}
+		} else {
+			if (tmp_rmap_item)
+				free_rmap_item(tmp_rmap_item);
+		}
+		put_page(page2[0]);
+		ret = !ret;
+		goto out;
+	}
+	/*
+	 * When wait is 1, we dont want to calculate the hash value of the page
+	 * right now, instead we prefer to wait.
+	 */
+	if (!wait && !rmap_item) {
+		rmap_item = alloc_rmap_item();
+		if (!rmap_item)
+			return ret;
+		checksum = calc_checksum(page);
+		create_new_rmap_item(rmap_item, slot->mm, addr, checksum);
+	}
+out:
+	return ret;
+}
+
+/* return -EAGAIN - no slots registered, nothing to be done */
+static int scan_get_next_index(struct ksm_scan *ksm_scan)
+{
+	struct ksm_mem_slot *slot;
+
+	if (list_empty(&slots))
+		return -EAGAIN;
+
+	slot = ksm_scan->slot_index;
+
+	/* Are there pages left in this slot to scan? */
+	if ((slot->npages - ksm_scan->page_index - 1) > 0) {
+		ksm_scan->page_index++;
+		return 0;
+	}
+
+	list_for_each_entry_from(slot, &slots, link) {
+		if (slot == ksm_scan->slot_index)
+			continue;
+		ksm_scan->page_index = 0;
+		ksm_scan->slot_index = slot;
+		return 0;
+	}
+
+	/* look like we finished scanning the whole memory, starting again */
+	root_unstable_tree = RB_ROOT;
+	ksm_scan->page_index = 0;
+	ksm_scan->slot_index = list_first_entry(&slots,
+						struct ksm_mem_slot, link);
+	return 0;
+}
+
+/*
+ * update slot_index - make sure ksm_scan will point to vaild data,
+ * it is possible that by the time we are here the data that ksm_scan was
+ * pointed to was released so we have to call this function every time after
+ * taking the slots_lock
+ */
+static void scan_update_old_index(struct ksm_scan *ksm_scan)
+{
+	struct ksm_mem_slot *slot;
+
+	if (list_empty(&slots))
+		return;
+
+	list_for_each_entry(slot, &slots, link) {
+		if (ksm_scan->slot_index == slot)
+			return;
+	}
+
+	ksm_scan->slot_index = list_first_entry(&slots,
+						struct ksm_mem_slot, link);
+	ksm_scan->page_index = 0;
+}
+
+/**
+ * ksm_scan_start - the ksm scanner main worker function.
+ * @ksm_scan -    the scanner.
+ * @scan_npages - number of pages we are want to scan before we return from this
+ * @function.
+ *
+ * (this function can be called from the kernel thread scanner, or from 
+ *  userspace ioctl context scanner)
+ *
+ *  The function return -EAGAIN in case there are not slots to scan.
+ */
+static int ksm_scan_start(struct ksm_scan *ksm_scan, unsigned int scan_npages)
+{
+	struct ksm_mem_slot *slot;
+	struct page *page[1];
+	int val;
+	int ret = 0;
+
+	down_read(&slots_lock);
+
+	scan_update_old_index(ksm_scan);
+
+	while (scan_npages > 0) {
+		ret = scan_get_next_index(ksm_scan);
+		if (ret)
+			goto out;
+
+		slot = ksm_scan->slot_index;
+
+		cond_resched();
+
+		/*
+		 * If the page is swapped out or in swap cache, we don't want to
+		 * scan it (it is just for performance).
+		 */
+		if (is_present_pte(slot->mm, slot->addr +
+				   ksm_scan->page_index * PAGE_SIZE)) {
+			down_read(&slot->mm->mmap_sem);
+			val = get_user_pages(current, slot->mm, slot->addr +
+					     ksm_scan->page_index * PAGE_SIZE ,
+					      1, 0, 0, page, NULL);
+			up_read(&slot->mm->mmap_sem);
+			if (val == 1) {
+				if (!PageKsm(page[0]))
+					cmp_and_merge_page(ksm_scan, page[0]);
+				put_page(page[0]);
+			}
+		}
+		scan_npages--;
+	}
+	scan_get_next_index(ksm_scan);
+out:
+	up_read(&slots_lock);
+	return ret;
+}
+
+static const struct file_operations ksm_sma_fops = {
+	.release        = ksm_sma_release,
+	.unlocked_ioctl = ksm_sma_ioctl,
+	.compat_ioctl   = ksm_sma_ioctl,
+};
+
+static int ksm_dev_ioctl_create_shared_memory_area(void)
+{
+	int fd = -1;
+	struct ksm_sma *ksm_sma;
+
+	ksm_sma = kmalloc(sizeof(struct ksm_sma), GFP_KERNEL);
+	if (!ksm_sma) {
+		fd = -ENOMEM;
+		goto out;
+	}
+
+	INIT_LIST_HEAD(&ksm_sma->sma_slots);
+
+	fd = anon_inode_getfd("ksm-sma", &ksm_sma_fops, ksm_sma, 0);
+	if (fd < 0)
+		goto out_free;
+
+	return fd;
+out_free:
+	kfree(ksm_sma);
+out:
+	return fd;
+}
+
+static long ksm_dev_ioctl(struct file *filp,
+			  unsigned int ioctl, unsigned long arg)
+{
+	long r = -EINVAL;
+
+	switch (ioctl) {
+	case KSM_GET_API_VERSION:
+		r = KSM_API_VERSION;
+		break;
+	case KSM_CREATE_SHARED_MEMORY_AREA:
+		r = ksm_dev_ioctl_create_shared_memory_area();
+		break;
+	default:
+		break;
+	}
+	return r;
+}
+
+static const struct file_operations ksm_chardev_ops = {
+	.unlocked_ioctl = ksm_dev_ioctl,
+	.compat_ioctl   = ksm_dev_ioctl,
+	.owner          = THIS_MODULE,
+};
+
+static struct miscdevice ksm_dev = {
+	KSM_MINOR,
+	"ksm",
+	&ksm_chardev_ops,
+};
+
+int ksm_scan_thread(void *nothing)
+{
+	while (!kthread_should_stop()) {
+		if (ksmd_flags & ksm_control_flags_run) {
+			down_read(&ksm_thread_lock);
+			ksm_scan_start(&ksm_thread_scan,
+				       ksm_thread_pages_to_scan);
+			up_read(&ksm_thread_lock);
+			schedule_timeout_interruptible(
+					usecs_to_jiffies(ksm_thread_sleep));
+		} else {
+			wait_event_interruptible(ksm_thread_wait,
+					ksmd_flags & ksm_control_flags_run ||
+					kthread_should_stop());
+		}
+	}
+	return 0;
+}
+
+#define KSM_ATTR_RO(_name) \
+	static struct kobj_attribute _name##_attr = __ATTR_RO(_name)
+#define KSM_ATTR(_name) \
+	static struct kobj_attribute _name##_attr = \
+		__ATTR(_name, 0644, _name##_show, _name##_store)
+
+static ssize_t sleep_show(struct kobject *kobj, struct kobj_attribute *attr,
+			  char *buf)
+{
+	unsigned int usecs;
+
+	down_read(&ksm_thread_lock);
+	usecs = ksm_thread_sleep;
+	up_read(&ksm_thread_lock);
+
+	return sprintf(buf, "%u\n", usecs);
+}
+
+static ssize_t sleep_store(struct kobject *kobj,
+				   struct kobj_attribute *attr,
+				   const char *buf, size_t count)
+{
+	unsigned long usecs;
+	int err;
+
+	err = strict_strtoul(buf, 10, &usecs);
+	if (err)
+		return 0;
+
+	/* TODO sanitize usecs */
+
+	down_write(&ksm_thread_lock);
+	ksm_thread_sleep = usecs;
+	up_write(&ksm_thread_lock);
+
+	return count;
+}
+KSM_ATTR(sleep);
+
+static ssize_t pages_to_scan_show(struct kobject *kobj,
+				  struct kobj_attribute *attr, char *buf)
+{
+	unsigned long nr_pages;
+
+	down_read(&ksm_thread_lock);
+	nr_pages = ksm_thread_pages_to_scan;
+	up_read(&ksm_thread_lock);
+
+	return sprintf(buf, "%lu\n", nr_pages);
+}
+
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
+	down_write(&ksm_thread_lock);
+	ksm_thread_pages_to_scan = nr_pages;
+	up_write(&ksm_thread_lock);
+
+	return count;
+}
+KSM_ATTR(pages_to_scan);
+
+static ssize_t run_show(struct kobject *kobj, struct kobj_attribute *attr,
+			char *buf)
+{
+	unsigned long run;
+
+	down_read(&ksm_thread_lock);
+	run = ksmd_flags;
+	up_read(&ksm_thread_lock);
+
+	return sprintf(buf, "%lu\n", run);
+}
+
+static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
+			 const char *buf, size_t count)
+{
+	int err;
+	unsigned long k_flags;
+
+	err = strict_strtoul(buf, 10, &k_flags);
+	if (err)
+		return 0;
+
+	down_write(&ksm_thread_lock);
+	ksmd_flags = k_flags;
+	up_write(&ksm_thread_lock);
+
+	if (ksmd_flags)
+		wake_up_interruptible(&ksm_thread_wait);
+
+	return count;
+}
+KSM_ATTR(run);
+
+static ssize_t pages_shared_show(struct kobject *kobj,
+				 struct kobj_attribute *attr, char *buf)
+{
+	/*
+	 * Note: this number does not include the shared pages outside the
+	 * stable tree.
+	 */
+	return sprintf(buf, "%lu\n", ksm_pages_shared - nnodes_stable_tree);
+}
+KSM_ATTR_RO(pages_shared);
+
+static ssize_t kernel_pages_allocated_show(struct kobject *kobj,
+					   struct kobj_attribute *attr,
+					   char *buf)
+{
+	return sprintf(buf, "%lu\n", nnodes_stable_tree);
+}
+KSM_ATTR_RO(kernel_pages_allocated);
+
+static ssize_t max_kernel_pages_store(struct kobject *kobj,
+				      struct kobj_attribute *attr,
+				      const char *buf, size_t count)
+{
+	int err;
+	unsigned long nr_pages;
+
+	err = strict_strtoul(buf, 10, &nr_pages);
+	if (err)
+		return 0;
+
+	down_write(&ksm_thread_lock);
+	ksm_thread_max_kernel_pages = nr_pages;
+	up_write(&ksm_thread_lock);
+
+	return count;
+}
+
+static ssize_t max_kernel_pages_show(struct kobject *kobj,
+				     struct kobj_attribute *attr, char *buf)
+{
+	unsigned long nr_pages;
+
+	down_read(&ksm_thread_lock);
+	nr_pages = ksm_thread_max_kernel_pages;
+	up_read(&ksm_thread_lock);
+
+	return sprintf(buf, "%lu\n", nr_pages);
+}
+KSM_ATTR(max_kernel_pages);
+
+static struct attribute *ksm_attrs[] = {
+	&sleep_attr.attr,
+	&pages_to_scan_attr.attr,
+	&run_attr.attr,
+	&pages_shared_attr.attr,
+	&kernel_pages_allocated_attr.attr,
+	&max_kernel_pages_attr.attr,
+	NULL,
+};
+
+static struct attribute_group ksm_attr_group = {
+	.attrs = ksm_attrs,
+	.name = "ksm",
+};
+
+
+static int __init ksm_init(void)
+{
+	int r;
+
+	r = ksm_slab_init();
+	if (r)
+		goto out;
+
+	r = rmap_hash_init();
+	if (r)
+		goto out_free1;
+
+	ksm_thread = kthread_run(ksm_scan_thread, NULL, "kksmd");
+	if (IS_ERR(ksm_thread)) {
+		printk(KERN_ERR "ksm: creating kthread failed\n");
+		r = PTR_ERR(ksm_thread);
+		goto out_free2;
+	}
+
+	r = misc_register(&ksm_dev);
+	if (r) {
+		printk(KERN_ERR "ksm: misc device register failed\n");
+		goto out_free3;
+	}
+
+	r = sysfs_create_group(mm_kobj, &ksm_attr_group);
+	if (r) {
+		printk(KERN_ERR "ksm: register sysfs failed\n");
+		goto out_free4;
+	}
+
+	printk(KERN_WARNING "ksm loaded\n");
+	return 0;
+
+out_free4:
+	misc_deregister(&ksm_dev);
+out_free3:
+	kthread_stop(ksm_thread);
+out_free2:
+	rmap_hash_free();
+out_free1:
+	ksm_slab_free();
+out:
+	return r;
+}
+
+static void __exit ksm_exit(void)
+{
+	sysfs_remove_group(mm_kobj, &ksm_attr_group);
+	misc_deregister(&ksm_dev);
+	ksmd_flags = ksm_control_flags_run;
+	kthread_stop(ksm_thread);
+	rmap_hash_free();
+	ksm_slab_free();
+}
+
+module_init(ksm_init)
+module_exit(ksm_exit)
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
