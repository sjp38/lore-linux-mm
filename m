Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1FC516B0153
	for <linux-mm@kvack.org>; Wed, 13 May 2009 20:31:20 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 3/4] ksm: change ksm api to use madvise instead of ioctls.
Date: Thu, 14 May 2009 03:30:47 +0300
Message-Id: <1242261048-4487-4-git-send-email-ieidus@redhat.com>
In-Reply-To: <1242261048-4487-3-git-send-email-ieidus@redhat.com>
References: <1242261048-4487-1-git-send-email-ieidus@redhat.com>
 <1242261048-4487-2-git-send-email-ieidus@redhat.com>
 <1242261048-4487-3-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: hugh@veritas.com
Cc: linux-kernel@vger.kernel.org, aarcange@redhat.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, chrisw@redhat.com, linux-mm@kvack.org, riel@redhat.com, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

Now ksm use madvise to know what memory regions it should scan.

ksm will walk over all the mm_structs inside the mmlist and will search for
mm_structs that have the MMF_VM_MERGEABLE, and for that mm_structs it will
search for every vma that is VM_MERGEABLE and will try to share its pages.

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 include/linux/ksm.h |   40 --
 mm/Kconfig          |    2 +-
 mm/ksm.c            | 1000 +++++++++++++++++++++++---------------------------
 3 files changed, 461 insertions(+), 581 deletions(-)

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index c0849c7..ca17782 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -1,46 +1,6 @@
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
-
 #endif
diff --git a/mm/Kconfig b/mm/Kconfig
index fb8ac63..73c4463 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -227,7 +227,7 @@ config MMU_NOTIFIER
 	bool
 
 config KSM
-	tristate "Enable KSM for page sharing"
+	bool "Enable KSM for page sharing"
 	help
 	  Enable the KSM kernel module to allow page sharing of equal pages
 	  among different tasks.
diff --git a/mm/ksm.c b/mm/ksm.c
index 8a0489b..901cce3 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1,7 +1,7 @@
 /*
- * Memory merging driver for Linux
+ * Memory merging support.
  *
- * This module enables dynamic sharing of identical pages found in different
+ * This code enables dynamic sharing of identical pages found in different
  * memory areas, even if they are not shared by fork()
  *
  * Copyright (C) 2008 Red Hat, Inc.
@@ -17,7 +17,6 @@
 #include <linux/errno.h>
 #include <linux/mm.h>
 #include <linux/fs.h>
-#include <linux/miscdevice.h>
 #include <linux/vmalloc.h>
 #include <linux/file.h>
 #include <linux/mman.h>
@@ -37,6 +36,7 @@
 #include <linux/swap.h>
 #include <linux/rbtree.h>
 #include <linux/anon_inodes.h>
+#include <linux/mmu_notifier.h>
 #include <linux/ksm.h>
 
 #include <asm/tlbflush.h>
@@ -44,45 +44,32 @@
 MODULE_AUTHOR("Red Hat, Inc.");
 MODULE_LICENSE("GPL");
 
-static int rmap_hash_size;
-module_param(rmap_hash_size, int, 0);
-MODULE_PARM_DESC(rmap_hash_size, "Hash table size for the reverse mapping");
-
-static int regions_per_fd;
-module_param(regions_per_fd, int, 0);
-
-/*
- * ksm_mem_slot - hold information for an userspace scanning range
- * (the scanning for this region will be from addr untill addr +
- *  npages * PAGE_SIZE inside mm)
+/**
+ * struct mm_slot - ksm information per mm that is being scanned
+ * @link: link to the mm_slots list
+ * @rmap_list: head for the rmap_list list
+ * @mm: the mm that this information is valid for
+ * @touched: 0 - mm_slot should be removed
  */
-struct ksm_mem_slot {
-	struct list_head link;
-	struct list_head sma_link;
+struct mm_slot {
+	struct hlist_node link;
+	struct list_head rmap_list;
 	struct mm_struct *mm;
-	unsigned long addr;	/* the begining of the virtual address */
-	unsigned npages;	/* number of pages to share */
-};
-
-/*
- * ksm_sma - shared memory area, each process have its own sma that contain the
- * information about the slots that it own
- */
-struct ksm_sma {
-	struct list_head sma_slots;
-	int nregions;
+	char touched;
 };
 
 /**
  * struct ksm_scan - cursor for scanning
- * @slot_index: the current slot we are scanning
- * @page_index: the page inside the sma that is currently being scanned
+ * @cur_mm_slot: the current mm_slot we are scanning
+ * @add_index: the address inside that is currently being scanned
+ * @cur_rmap: the current rmap that we are scanning inside the rmap_list
  *
  * ksm uses it to know what are the next pages it need to scan
  */
 struct ksm_scan {
-	struct ksm_mem_slot *slot_index;
-	unsigned long page_index;
+	struct mm_slot *cur_mm_slot;
+	unsigned long addr_index;
+	struct rmap_item *cur_rmap;
 };
 
 /*
@@ -139,14 +126,14 @@ struct tree_item {
 };
 
 /*
- * rmap_item - object of the rmap_hash hash table
+ * rmap_item - object of rmap_list per mm
  * (it is holding the previous hash value (oldindex),
  *  pointer into the page_hash_item, and pointer into the tree_item)
  */
 
 /**
  * struct rmap_item - reverse mapping item for virtual addresses
- * @link: link into the rmap_hash hash table.
+ * @link: link into rmap_list (rmap_list is per mm)
  * @mm: the memory strcture the rmap_item is pointing to.
  * @address: the virtual address the rmap_item is pointing to.
  * @oldchecksum: old checksum result for the page belong the virtual address
@@ -159,7 +146,7 @@ struct tree_item {
  */
 
 struct rmap_item {
-	struct hlist_node link;
+	struct list_head link;
 	struct mm_struct *mm;
 	unsigned long address;
 	unsigned int oldchecksum; /* old checksum value */
@@ -170,29 +157,19 @@ struct rmap_item {
 	struct rmap_item *prev;
 };
 
-/*
- * slots is linked list that hold all the memory regions that were registred
- * to be scanned.
- */
-static LIST_HEAD(slots);
-/*
- * slots_lock protects against removing and adding memory regions while a scanner
- * is in the middle of scanning.
- */
-static DECLARE_RWSEM(slots_lock);
-
 /* The stable and unstable trees heads. */
 struct rb_root root_stable_tree = RB_ROOT;
 struct rb_root root_unstable_tree = RB_ROOT;
 
 
-/* The number of linked list members inside the hash table */
-static unsigned int nrmaps_hash;
-/* rmap_hash hash table */
-static struct hlist_head *rmap_hash;
+/* The number of linked list members inside the mm slots hash table */
+static unsigned int nmm_slots_hash;
+/* mm_slots_hash hash table */
+static struct hlist_head *mm_slots_hash;
 
 static struct kmem_cache *tree_item_cache;
 static struct kmem_cache *rmap_item_cache;
+static struct kmem_cache *mm_slot_item_cache;
 
 /* the number of nodes inside the stable tree */
 static unsigned long nnodes_stable_tree;
@@ -223,8 +200,14 @@ static int ksm_slab_init(void)
 	if (!rmap_item_cache)
 		goto out_free;
 
+	mm_slot_item_cache = KMEM_CACHE(mm_slot, 0);
+	if (!mm_slot_item_cache)
+		goto out_free1;
+
 	return 0;
 
+out_free1:
+	kmem_cache_destroy(rmap_item_cache);
 out_free:
 	kmem_cache_destroy(tree_item_cache);
 out:
@@ -233,6 +216,7 @@ out:
 
 static void ksm_slab_free(void)
 {
+	kmem_cache_destroy(mm_slot_item_cache);
 	kmem_cache_destroy(rmap_item_cache);
 	kmem_cache_destroy(tree_item_cache);
 }
@@ -257,6 +241,16 @@ static inline void free_rmap_item(struct rmap_item *rmap_item)
 	kmem_cache_free(rmap_item_cache, rmap_item);
 }
 
+static inline struct mm_slot *alloc_mm_slot_item(void)
+{
+	return kmem_cache_zalloc(mm_slot_item_cache, GFP_KERNEL);
+}
+
+static inline void free_mm_slot_item(struct mm_slot *mm_slot_item)
+{
+	kmem_cache_free(mm_slot_item_cache, mm_slot_item);
+}
+
 static unsigned long addr_in_vma(struct vm_area_struct *vma, struct page *page)
 {
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
@@ -303,71 +297,20 @@ static inline int PageKsm(struct page *page)
 	return !PageAnon(page);
 }
 
-static int rmap_hash_init(void)
-{
-	if (!rmap_hash_size) {
-		struct sysinfo sinfo;
-
-		si_meminfo(&sinfo);
-		rmap_hash_size = sinfo.totalram / 10;
-	}
-	nrmaps_hash = rmap_hash_size;
-	rmap_hash = vmalloc(nrmaps_hash * sizeof(struct hlist_head));
-	if (!rmap_hash)
-		return -ENOMEM;
-	memset(rmap_hash, 0, nrmaps_hash * sizeof(struct hlist_head));
-	return 0;
-}
-
-static void rmap_hash_free(void)
-{
-	int i;
-	struct hlist_head *bucket;
-	struct hlist_node *node, *n;
-	struct rmap_item *rmap_item;
-
-	for (i = 0; i < nrmaps_hash; ++i) {
-		bucket = &rmap_hash[i];
-		hlist_for_each_entry_safe(rmap_item, node, n, bucket, link) {
-			hlist_del(&rmap_item->link);
-			free_rmap_item(rmap_item);
-		}
-	}
-	vfree(rmap_hash);
-}
-
-static inline u32 calc_checksum(struct page *page)
-{
-	u32 checksum;
-	void *addr = kmap_atomic(page, KM_USER0);
-	checksum = jhash2(addr, PAGE_SIZE / 4, 17);
-	kunmap_atomic(addr, KM_USER0);
-	return checksum;
-}
-
-/*
- * Return rmap_item for a given virtual address.
- */
-static struct rmap_item *get_rmap_item(struct mm_struct *mm, unsigned long addr)
+static void break_cow(struct mm_struct *mm, unsigned long addr)
 {
-	struct rmap_item *rmap_item;
-	struct hlist_head *bucket;
-	struct hlist_node *node;
+	struct page *page[1];
 
-	bucket = &rmap_hash[addr % nrmaps_hash];
-	hlist_for_each_entry(rmap_item, node, bucket, link) {
-		if (mm == rmap_item->mm && rmap_item->address == addr) {
-			return rmap_item;
-		}
-	}
-	return NULL;
+	down_read(&mm->mmap_sem);
+	if (get_user_pages(current, mm, addr, 1, 1, 0, page, NULL) == 1)
+		put_page(page[0]);
+	up_read(&mm->mmap_sem);
 }
 
 /*
  * Removing rmap_item from stable or unstable tree.
- * This function will free the rmap_item object, and if that rmap_item was
- * insde the stable or unstable trees, it would remove the link from there
- * as well.
+ * This function will clean the information from the stable/unstable tree
+ * and will free the tree_item if needed.
  */
 static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
 {
@@ -404,222 +347,92 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
 			}
 		} else {
 			/*
-			 * We dont rb_erase(&tree_item->node) here, beacuse
-			 * that the unstable tree will get flushed before we are
-			 * here.
+			 * We dont rb_erase(&tree_item->node) here, beacuse at
+			 * the time we are here root_unstable_tree = RB_ROOT
+			 * should had been called.
 			 */
 			free_tree_item(tree_item);
 		}
 	}
 
-	hlist_del(&rmap_item->link);
-	free_rmap_item(rmap_item);
-}
-
-static void break_cow(struct mm_struct *mm, unsigned long addr)
-{
-	struct page *page[1];
-
-	down_read(&mm->mmap_sem);
-	if (get_user_pages(current, mm, addr, 1, 1, 0, page, NULL) == 1)
-		put_page(page[0]);
-	up_read(&mm->mmap_sem);
+	rmap_item->stable_tree = 0;
+	rmap_item->oldchecksum = 0;
+	rmap_item->kpage_outside_tree = 0;
+	rmap_item->next = NULL;
+	rmap_item->prev = NULL;
 }
 
-static void remove_page_from_tree(struct mm_struct *mm,
-				  unsigned long addr)
+static void remove_all_slot_rmap_items(struct mm_slot *mm_slot, int do_break)
 {
-	struct rmap_item *rmap_item;
-
-	rmap_item = get_rmap_item(mm, addr);
-	if (!rmap_item)
-		return;
-
-	if (rmap_item->stable_tree) {
-		/* We are breaking all the KsmPages of area that is removed */
-		break_cow(mm, addr);
-	} else {
-		/*
-		 * If kpage_outside_tree is set, this item is KsmPage outside
-		 * the stable tree, therefor we have to break the COW and
-		 * in addition we have to dec nkpage_out_tree.
-		 */
-		if (rmap_item->kpage_outside_tree)
-			break_cow(mm, addr);
+	struct rmap_item *rmap_item, *node;
+
+	list_for_each_entry_safe(rmap_item, node, &mm_slot->rmap_list, link) {
+		if (do_break) {
+			if (rmap_item->stable_tree) {
+				/*
+				 * we are breaking all the ksmpages of the area
+				 * that is being removed
+			 	*/
+				break_cow(mm_slot->mm, rmap_item->address);
+			} else {
+				/*
+				 * if kpage_outside_tree is set, this item is
+				 * ksmpage outside the stable tree, therefor we
+				 * have to break the cow and in addition we have
+				 * to dec nkpage_out_tree.
+		 		 */
+				if (rmap_item->kpage_outside_tree)
+					break_cow(mm_slot->mm,
+						  rmap_item->address);
+			}
+		}
+		remove_rmap_item_from_tree(rmap_item);
+		list_del(&rmap_item->link);
+		free_rmap_item(rmap_item);
 	}
-
-	remove_rmap_item_from_tree(rmap_item);
 }
 
-static inline int is_intersecting_address(unsigned long addr,
-					  unsigned long begin,
-					  unsigned long end)
+static void remove_mm_slot(struct mm_slot *mm_slot, int do_break)
 {
-	if (addr >= begin && addr < end)
-		return 1;
-	return 0;
+	hlist_del(&mm_slot->link);
+	remove_all_slot_rmap_items(mm_slot, do_break);
+	mmput(mm_slot->mm);
+	free_mm_slot_item(mm_slot);
 }
 
-/*
- * is_overlap_mem - check if there is overlapping with memory that was already
- * registred.
- *
- * note - this function must to be called under slots_lock
- */
-static int is_overlap_mem(struct ksm_memory_region *mem)
+static int mm_slots_hash_init(void)
 {
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
-
-static int ksm_sma_ioctl_register_memory_region(struct ksm_sma *ksm_sma,
-						struct ksm_memory_region *mem)
-{
-	struct ksm_mem_slot *slot;
-	int ret = -EPERM;
-
-	if (!mem->npages)
-		goto out;
+	nmm_slots_hash = 4096;
 
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
-	slot = kzalloc(sizeof(struct ksm_mem_slot), GFP_KERNEL);
-	if (!slot) {
-		ret = -ENOMEM;
-		goto out_unlock;
-	}
-
-	/*
-	 * We will hold refernce to the task_mm untill the file descriptor
-	 * will be closed, or KSM_REMOVE_MEMORY_REGION will be called.
-	 */
-	slot->mm = get_task_mm(current);
-	if (!slot->mm)
-		goto out_free;
-	slot->addr = mem->addr;
-	slot->npages = mem->npages;
-
-	list_add_tail(&slot->link, &slots);
-	list_add_tail(&slot->sma_link, &ksm_sma->sma_slots);
-	ksm_sma->nregions++;
-
-	up_write(&slots_lock);
+	mm_slots_hash = vmalloc(nmm_slots_hash * sizeof(struct hlist_head));
+	if (!mm_slots_hash)
+		return -ENOMEM;
+	memset(mm_slots_hash, 0, nmm_slots_hash * sizeof(struct hlist_head));
 	return 0;
-
-out_free:
-	kfree(slot);
-out_unlock:
-	up_write(&slots_lock);
-out:
-	return ret;
-}
-
-static void remove_slot_from_hash_and_tree(struct ksm_mem_slot *slot)
-{
-	int pages_count;
-
-	root_unstable_tree = RB_ROOT;
-	for (pages_count = 0; pages_count < slot->npages; ++pages_count)
-		remove_page_from_tree(slot->mm, slot->addr +
-				      pages_count * PAGE_SIZE);
-	/* Called under slots_lock */
-	list_del(&slot->link);
 }
 
-static int ksm_sma_ioctl_remove_memory_region(struct ksm_sma *ksm_sma,
-					      unsigned long addr)
+static void mm_slots_hash_free(void)
 {
-	int ret = -EFAULT;
-	struct ksm_mem_slot *slot, *node;
-
-	down_write(&slots_lock);
-	list_for_each_entry_safe(slot, node, &ksm_sma->sma_slots, sma_link) {
-		if (addr == slot->addr) {
-			remove_slot_from_hash_and_tree(slot);
-			mmput(slot->mm);
-			list_del(&slot->sma_link);
-			kfree(slot);
-			ksm_sma->nregions--;
-			ret = 0;
-		}
-	}
-	up_write(&slots_lock);
-	return ret;
-}
+	int i;
+	struct hlist_head *bucket;
+	struct hlist_node *node, *n;
+	struct mm_slot *mm_slot;
 
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
+	for (i = 0; i < nmm_slots_hash; ++i) {
+		bucket = &mm_slots_hash[i];
+		hlist_for_each_entry_safe(mm_slot, node, n, bucket, link)
+			remove_mm_slot(mm_slot, 1);
 	}
-	up_write(&slots_lock);
-
-	kfree(ksm_sma);
-	return 0;
+	vfree(mm_slots_hash);
 }
 
-static long ksm_sma_ioctl(struct file *filp,
-			  unsigned int ioctl, unsigned long arg)
+static inline u32 calc_checksum(struct page *page)
 {
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
+	u32 checksum;
+	void *addr = kmap_atomic(page, KM_USER0);
+	checksum = jhash2(addr, PAGE_SIZE / 4, 17);
+	kunmap_atomic(addr, KM_USER0);
+	return checksum;
 }
 
 static int memcmp_pages(struct page *page1, struct page *page2)
@@ -666,6 +479,9 @@ static int try_to_merge_one_page(struct mm_struct *mm,
 	unsigned long page_addr_in_vma;
 	pte_t orig_pte, *orig_ptep;
 
+	if(!(vma->vm_flags & VM_MERGEABLE))
+		goto out;
+
 	if (!PageAnon(oldpage))
 		goto out;
 
@@ -731,16 +547,16 @@ out:
  */
 
 static int try_to_merge_two_pages_alloc(struct mm_struct *mm1,
-					struct page *page1,
-					struct mm_struct *mm2,
-					struct page *page2,
-					unsigned long addr1,
-					unsigned long addr2)
+				        struct page *page1,
+				        struct mm_struct *mm2,
+				        struct page *page2,
+				        unsigned long addr1,
+				        unsigned long addr2)
 {
 	struct vm_area_struct *vma;
 	pgprot_t prot;
-	int ret = 1;
 	struct page *kpage;
+	int ret = 1;
 
 	/*
 	 * The number of the nodes inside the stable tree +
@@ -757,7 +573,7 @@ static int try_to_merge_two_pages_alloc(struct mm_struct *mm1,
 		return ret;
 	down_read(&mm1->mmap_sem);
 	vma = find_vma(mm1, addr1);
-	if (!vma) {
+	if (!vma || vma->vm_start > addr1) {
 		put_page(kpage);
 		up_read(&mm1->mmap_sem);
 		return ret;
@@ -772,7 +588,7 @@ static int try_to_merge_two_pages_alloc(struct mm_struct *mm1,
 	if (!ret) {
 		down_read(&mm2->mmap_sem);
 		vma = find_vma(mm2, addr2);
-		if (!vma) {
+		if (!vma || vma->vm_start > addr2) {
 			put_page(kpage);
 			up_read(&mm2->mmap_sem);
 			break_cow(mm1, addr1);
@@ -822,7 +638,7 @@ static int try_to_merge_two_pages_noalloc(struct mm_struct *mm1,
 	BUG_ON(!PageKsm(page2));
 	down_read(&mm1->mmap_sem);
 	vma = find_vma(mm1, addr1);
-	if (!vma) {
+	if (!vma || vma->vm_start > addr1) {
 		up_read(&mm1->mmap_sem);
 		return ret;
 	}
@@ -1100,7 +916,7 @@ static struct tree_item *unstable_tree_search_insert(struct page *page,
  *
  * we return 1 in case we removed the rmap_item.
  */
-int update_tree(struct rmap_item *rmap_item)
+static int update_tree(struct rmap_item *rmap_item)
 {
 	if (!rmap_item->stable_tree) {
 		if (unlikely(rmap_item->kpage_outside_tree)) {
@@ -1131,24 +947,6 @@ int update_tree(struct rmap_item *rmap_item)
 	return 1;
 }
 
-static void create_new_rmap_item(struct rmap_item *rmap_item,
-				 struct mm_struct *mm,
-				 unsigned long addr,
-				 unsigned int checksum)
-{
-	struct hlist_head *bucket;
-
-	rmap_item->mm = mm;
-	rmap_item->address = addr;
-	rmap_item->oldchecksum = checksum;
-	rmap_item->stable_tree = 0;
-	rmap_item->kpage_outside_tree = 0;
-	rmap_item->tree_item = NULL;
-
-	bucket = &rmap_hash[addr % nrmaps_hash];
-	hlist_add_head(&rmap_item->link, bucket);
-}
-
 /*
  * insert_to_stable_tree_list - insert another rmap_item into the linked list
  * rmap_items of a given node inside the stable tree.
@@ -1174,99 +972,75 @@ static void insert_to_stable_tree_list(struct rmap_item *rmap_item,
  * in case we find that there is similar hash to different page we call to
  * try_to_merge_two_pages().
  *
- * @ksm_scan: the ksm scanner strcture.
  * @page: the page that we are searching identical page to.
+ * @rmap_item: the reverse mapping into the virtual address of this page
  */
-static int cmp_and_merge_page(struct ksm_scan *ksm_scan, struct page *page)
+
+static int cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 {
 	struct page *page2[1];
-	struct ksm_mem_slot *slot;
 	struct tree_item *tree_item;
-	struct rmap_item *rmap_item;
 	struct rmap_item *tree_rmap_item;
 	unsigned int checksum;
-	unsigned long addr;
-	int wait = 0;
+	int wait;
 	int ret = 0;
 
-	slot = ksm_scan->slot_index;
-	addr = slot->addr + ksm_scan->page_index * PAGE_SIZE;
-	rmap_item = get_rmap_item(slot->mm, addr);
-	if (rmap_item) {
-		if (update_tree(rmap_item)) {
-			rmap_item = NULL;
-			wait = 1;
-		}
-	}
+	wait = update_tree(rmap_item);
 
 	/* We first start with searching the page inside the stable tree */
 	tree_rmap_item = stable_tree_search(page, page2, rmap_item);
 	if (tree_rmap_item) {
-		struct rmap_item *tmp_rmap_item = NULL;
+		BUG_ON(!tree_rmap_item->tree_item);
 
-		if (!rmap_item) {
-			tmp_rmap_item = alloc_rmap_item();
-			if (!tmp_rmap_item)
-				return ret;
-		}
+		ret = try_to_merge_two_pages_noalloc(rmap_item->mm, page,
+						     page2[0],
+						     rmap_item->address);
 
-		BUG_ON(!tree_rmap_item->tree_item);
-		ret = try_to_merge_two_pages_noalloc(slot->mm, page, page2[0],
-						     addr);
 		put_page(page2[0]);
+
 		if (!ret) {
 			/*
 			 * The page was successuly merged, lets insert its
 			 * rmap_item into the stable tree.
 			 */
-
-			if (!rmap_item) {
-				create_new_rmap_item(tmp_rmap_item, slot->mm,
-						     addr, 0);
-				rmap_item = tmp_rmap_item;
-			}
-
 			insert_to_stable_tree_list(rmap_item, tree_rmap_item);
-		} else {
-			if (tmp_rmap_item)
-				free_rmap_item(tmp_rmap_item);
 		}
+
 		ret = !ret;
 		goto out;
 	}
 
+	if (wait)
+		goto out;
+
 	/*
 	 * In case the hash value of the page was changed from the last time we
 	 * have calculated it, this page to be changed frequely, therefore we
 	 * dont want to insert it to the unstable tree, and we dont want to
 	 * waste our time to search if there is something identical to it there.
 	 */
-	if (rmap_item) {
-		checksum = calc_checksum(page);
-		if (rmap_item->oldchecksum != checksum) {
-			rmap_item->oldchecksum = checksum;
-			goto out;
-		}
+	checksum = calc_checksum(page);
+	if (rmap_item->oldchecksum != checksum) {
+		rmap_item->oldchecksum = checksum;
+		goto out;
 	}
 
 	tree_item = unstable_tree_search_insert(page, page2, rmap_item);
 	if (tree_item) {
-		struct rmap_item *tmp_rmap_item = NULL;
 		struct rmap_item *merge_rmap_item;
+		struct mm_struct *tree_mm;
+		unsigned long tree_addr;
 
 		merge_rmap_item = tree_item->rmap_item;
 		BUG_ON(!merge_rmap_item);
 
-		if (!rmap_item) {
-			tmp_rmap_item = alloc_rmap_item();
-			if (!tmp_rmap_item)
-				return ret;
-		}
+		tree_mm = merge_rmap_item->mm;
+		tree_addr = merge_rmap_item->address;
+
+		ret = try_to_merge_two_pages_alloc(rmap_item->mm, page, tree_mm,
+						   page2[0], rmap_item->address,
+						   tree_addr);
 
-		ret = try_to_merge_two_pages_alloc(slot->mm, page,
-						   merge_rmap_item->mm,
-						   page2[0], addr,
-						   merge_rmap_item->address);
 		/*
 		 * As soon as we successuly merged this page, we want to remove
 		 * the rmap_item object of the page that we have merged with
@@ -1283,102 +1057,319 @@ static int cmp_and_merge_page(struct ksm_scan *ksm_scan, struct page *page)
 			 * their rmap as tree_item->kpage_outside_tree = 1
 			 * and to inc nkpage_out_tree by 2.
 			 */
-			if (stable_tree_insert(page2[0],
-					       tree_item, merge_rmap_item)) {
+			if (stable_tree_insert(page2[0], tree_item,
+					       merge_rmap_item)) {
 				merge_rmap_item->kpage_outside_tree = 1;
-				if (!rmap_item) {
-					create_new_rmap_item(tmp_rmap_item,
-							     slot->mm,
-							     addr, 0);
-					rmap_item = tmp_rmap_item;
-				}
 				rmap_item->kpage_outside_tree = 1;
 				nkpage_out_tree += 2;
 			} else {
-				if (tmp_rmap_item) {
-					create_new_rmap_item(tmp_rmap_item,
-							     slot->mm, addr, 0);
-					rmap_item = tmp_rmap_item;
-				}
 				insert_to_stable_tree_list(rmap_item,
 							   merge_rmap_item);
 			}
-		} else {
-			if (tmp_rmap_item)
-				free_rmap_item(tmp_rmap_item);
 		}
+
 		put_page(page2[0]);
+
 		ret = !ret;
-		goto out;
-	}
-	/*
-	 * When wait is 1, we dont want to calculate the hash value of the page
-	 * right now, instead we prefer to wait.
-	 */
-	if (!wait && !rmap_item) {
-		rmap_item = alloc_rmap_item();
-		if (!rmap_item)
-			return ret;
-		checksum = calc_checksum(page);
-		create_new_rmap_item(rmap_item, slot->mm, addr, checksum);
 	}
+
 out:
 	return ret;
 }
 
-/* return -EAGAIN - no slots registered, nothing to be done */
-static int scan_get_next_index(struct ksm_scan *ksm_scan)
+static struct mm_slot *get_mm_slot(struct mm_struct *mm)
 {
-	struct ksm_mem_slot *slot;
+	struct mm_slot *mm_slot;
+	struct hlist_head *bucket;
+	struct hlist_node *node;
 
-	if (list_empty(&slots))
-		return -EAGAIN;
+	bucket = &mm_slots_hash[((unsigned long)mm / sizeof (struct mm_struct))
+				% nmm_slots_hash];
+	hlist_for_each_entry(mm_slot, node, bucket, link) {
+		if (mm == mm_slot->mm)
+			return mm_slot;
+	}
+	return NULL;
+}
 
-	slot = ksm_scan->slot_index;
+static void insert_to_mm_slots_hash(struct mm_struct *mm,
+				    struct mm_slot *mm_slot)
+{
+	struct hlist_head *bucket;
 
-	/* Are there pages left in this slot to scan? */
-	if ((slot->npages - ksm_scan->page_index - 1) > 0) {
-		ksm_scan->page_index++;
-		return 0;
-	}
+	bucket = &mm_slots_hash[((unsigned long)mm / sizeof (struct mm_struct))
+				% nmm_slots_hash];
+	mm_slot->mm = mm;
+	atomic_inc(&mm_slot->mm->mm_users);
+	INIT_LIST_HEAD(&mm_slot->rmap_list);
+	hlist_add_head(&mm_slot->link, bucket);
+}
 
-	list_for_each_entry_from(slot, &slots, link) {
-		if (slot == ksm_scan->slot_index)
-			continue;
-		ksm_scan->page_index = 0;
-		ksm_scan->slot_index = slot;
-		return 0;
-	}
+static void create_new_rmap_item(struct list_head *cur,
+				 struct rmap_item *rmap_item,
+				 struct mm_struct *mm,
+				 unsigned long addr,
+				 unsigned int checksum)
+{
+	rmap_item->address = addr;
+	rmap_item->mm = mm;
+	rmap_item->oldchecksum = checksum;
+	rmap_item->stable_tree = 0;
+	rmap_item->kpage_outside_tree = 0;
+	rmap_item->tree_item = NULL;
 
-	/* look like we finished scanning the whole memory, starting again */
-	root_unstable_tree = RB_ROOT;
-	ksm_scan->page_index = 0;
-	ksm_scan->slot_index = list_first_entry(&slots,
-						struct ksm_mem_slot, link);
-	return 0;
+	list_add(&rmap_item->link, cur);
 }
 
 /*
- * update slot_index - make sure ksm_scan will point to vaild data,
- * it is possible that by the time we are here the data that ksm_scan was
- * pointed to was released so we have to call this function every time after
- * taking the slots_lock
+ * update_rmap_list - nuke every rmap_item above the current rmap_item.
  */
-static void scan_update_old_index(struct ksm_scan *ksm_scan)
+static void update_rmap_list(struct list_head *head, struct list_head *cur)
+{
+	struct rmap_item *rmap_item;
+
+	cur = cur->next;
+	while (cur != head) {
+		rmap_item = list_entry(cur, struct rmap_item, link);
+		cur = cur->next;
+		remove_rmap_item_from_tree(rmap_item);
+		list_del(&rmap_item->link);
+		free_rmap_item(rmap_item);
+	}
+}
+
+static struct rmap_item *get_next_rmap_index(unsigned long addr,
+					     struct mm_struct *mm,
+					     struct list_head *head,
+					     struct list_head *cur,
+					     struct rmap_item *pre_alloc_rmap,
+					     int *used_pre_alloc)
+{
+	struct rmap_item *rmap_item;
+
+	cur = cur->next;
+	while (cur != head) {
+		rmap_item = list_entry(cur, struct rmap_item, link);
+		if (rmap_item->address == addr) {
+			return rmap_item;
+		} else if (rmap_item->address < addr) {
+			cur = cur->next;
+			remove_rmap_item_from_tree(rmap_item);
+			list_del(&rmap_item->link);
+			free_rmap_item(rmap_item);
+		} else {
+			*used_pre_alloc = 1;
+			create_new_rmap_item(cur->prev, pre_alloc_rmap, mm,
+					     addr, 0);
+			return pre_alloc_rmap;
+		}
+	}
+
+	*used_pre_alloc = 1;
+	create_new_rmap_item(cur->prev, pre_alloc_rmap, mm, addr, 0);
+
+	return pre_alloc_rmap;
+}
+
+static void remove_all_mm_slots(void)
+{
+	int i;
+	struct hlist_head *bucket;
+	struct hlist_node *node, *n;
+	struct mm_slot *mm_slot;
+
+	for (i = 0; i < nmm_slots_hash; ++i) {
+		bucket = &mm_slots_hash[i];
+		hlist_for_each_entry_safe(mm_slot, node, n, bucket, link)
+			remove_mm_slot(mm_slot, 1);
+	}
+}
+
+static void remove_all_untouched_mm_slots(void)
+{
+	int i;
+	struct hlist_head *bucket;
+	struct hlist_node *node, *n;
+	struct mm_slot *mm_slot;
+
+	for (i = 0; i < nmm_slots_hash; ++i) {
+		bucket = &mm_slots_hash[i];
+		hlist_for_each_entry_safe(mm_slot, node, n, bucket, link) {
+			if (!mm_slot->touched)
+				remove_mm_slot(mm_slot, 1);
+			else
+				mm_slot->touched = 0;
+		}
+	}
+}
+
+static struct mm_slot *get_next_mmlist(struct list_head *cur,
+				       struct mm_slot *pre_alloc_mm_slot,
+				       int *used_pre_alloc)
 {
-	struct ksm_mem_slot *slot;
+	struct mm_struct *mm;
+	struct mm_slot *mm_slot;
+
+	cur = cur->next;
+	while (cur != &init_mm.mmlist) {
+		mm = list_entry(cur, struct mm_struct, mmlist);
+		if (test_bit(MMF_VM_MERGEABLE, &mm->flags)) {
+			mm_slot = get_mm_slot(mm);
+			if (unlikely(atomic_read(&mm->mm_users) == 1)) {
+				if (mm_slot)
+					mm_slot->touched = 0;
+			} else {
+				if (!mm_slot) {
+					insert_to_mm_slots_hash(mm,
+							     pre_alloc_mm_slot);
+					*used_pre_alloc = 1;
+					mm_slot = pre_alloc_mm_slot;
+				}
+				mm_slot->touched = 1;
+				return mm_slot;
+			}
+		}
 
-	if (list_empty(&slots))
-		return;
+		cur = cur->next;
+	}
+	return NULL;
+}
 
-	list_for_each_entry(slot, &slots, link) {
-		if (ksm_scan->slot_index == slot)
-			return;
+ /* return -EAGAIN - no slots registered, nothing to be done */
+ static int scan_get_next_index(struct ksm_scan *ksm_scan)
+ {
+	struct mm_slot *slot;
+	struct vm_area_struct *vma;
+	struct rmap_item *pre_alloc_rmap_item;
+	struct mm_slot *pre_alloc_mm_slot;
+	int used_slot = 0;
+	int used_rmap = 0;
+	int ret = -EAGAIN;
+
+	pre_alloc_rmap_item = alloc_rmap_item();
+	if (!pre_alloc_rmap_item)
+		return -ENOMEM;
+	pre_alloc_mm_slot = alloc_mm_slot_item();
+	if (!pre_alloc_mm_slot) {
+		free_rmap_item(pre_alloc_rmap_item);
+		return -ENOMEM;
 	}
 
-	ksm_scan->slot_index = list_first_entry(&slots,
-						struct ksm_mem_slot, link);
-	ksm_scan->page_index = 0;
+	if (!ksm_scan->cur_mm_slot)
+		remove_all_untouched_mm_slots();
+
+	spin_lock(&mmlist_lock);
+
+ 	if (list_empty(&init_mm.mmlist))
+		goto out_unlock;
+
+	if (!ksm_scan->cur_mm_slot) {
+		ksm_scan->cur_mm_slot = get_next_mmlist(&init_mm.mmlist,
+							pre_alloc_mm_slot,
+							&used_slot);
+		if (!ksm_scan->cur_mm_slot)
+			goto out_unlock;
+
+		ksm_scan->addr_index = (unsigned long) -PAGE_SIZE;
+		ksm_scan->cur_rmap = list_entry(
+					      &ksm_scan->cur_mm_slot->rmap_list,
+					      struct rmap_item, link);
+
+		root_unstable_tree = RB_ROOT;
+	}
+
+	spin_unlock(&mmlist_lock);
+
+ 	slot = ksm_scan->cur_mm_slot;
+ 
+	down_read(&slot->mm->mmap_sem);
+
+	ksm_scan->addr_index += PAGE_SIZE;
+
+again:
+	vma = find_vma(slot->mm, ksm_scan->addr_index);
+	if (vma && vma->vm_flags & VM_MERGEABLE) {
+		if (ksm_scan->addr_index < vma->vm_start)
+			ksm_scan->addr_index = vma->vm_start;
+		up_read(&slot->mm->mmap_sem);
+
+		ksm_scan->cur_rmap =
+				  get_next_rmap_index(ksm_scan->addr_index,
+						      slot->mm,
+						      &slot->rmap_list,
+						      &ksm_scan->cur_rmap->link,
+						      pre_alloc_rmap_item,
+						      &used_rmap);
+
+		ret = 0;
+		goto out_free;
+	} else {
+		while (vma && !(vma->vm_flags & VM_MERGEABLE))
+			vma = vma->vm_next;
+
+		if (vma) {
+			ksm_scan->addr_index = vma->vm_start;
+			up_read(&slot->mm->mmap_sem);
+
+			ksm_scan->cur_rmap =
+				  get_next_rmap_index(ksm_scan->addr_index,
+						      slot->mm,
+						      &slot->rmap_list,
+						      &ksm_scan->cur_rmap->link,
+						      pre_alloc_rmap_item,
+						      &used_rmap);
+
+			ret = 0;
+			goto out_free;
+		}
+ 	}
+ 
+	up_read(&slot->mm->mmap_sem);
+
+	/*
+	 * Lets nuke all the rmap_items that above this current rmap
+	 * the reason that we do it is beacuse there were no vmas with the
+	 * VM_MERGEABLE flag set that had such addresses.
+	 */
+	update_rmap_list(&slot->rmap_list, &ksm_scan->cur_rmap->link);
+
+	/*
+	 * We have already used our pre allocated mm_slot, so we return and wait
+	 * this function will get called again.
+	 */
+	if (used_slot)
+		goto out_free;
+
+	spin_lock(&mmlist_lock);
+
+	ksm_scan->cur_mm_slot =
+			     get_next_mmlist(&ksm_scan->cur_mm_slot->mm->mmlist,
+					     pre_alloc_mm_slot,
+					     &used_slot);
+
+	/* look like we finished scanning the whole memory, starting again */
+	if (!ksm_scan->cur_mm_slot)
+		goto out_unlock;
+
+	spin_unlock(&mmlist_lock);
+
+	ksm_scan->addr_index = 0;
+	ksm_scan->cur_rmap = list_entry(&ksm_scan->cur_mm_slot->rmap_list,
+					struct rmap_item, link);
+	slot = ksm_scan->cur_mm_slot;
+
+	down_read(&slot->mm->mmap_sem);
+
+	goto again;
+
+out_unlock:
+	spin_unlock(&mmlist_lock);
+out_free:
+	if (!used_slot)
+		free_mm_slot_item(pre_alloc_mm_slot);
+	if (!used_rmap)
+		free_rmap_item(pre_alloc_rmap_item);
+	return ret;
 }
 
 /**
@@ -1394,21 +1385,23 @@ static void scan_update_old_index(struct ksm_scan *ksm_scan)
  */
 static int ksm_scan_start(struct ksm_scan *ksm_scan, unsigned int scan_npages)
 {
-	struct ksm_mem_slot *slot;
+	struct mm_slot *slot;
 	struct page *page[1];
+	struct mm_struct *mm;
+	struct rmap_item *rmap_item;
+	unsigned long addr;
 	int val;
 	int ret = 0;
 
-	down_read(&slots_lock);
-
-	scan_update_old_index(ksm_scan);
-
 	while (scan_npages > 0) {
 		ret = scan_get_next_index(ksm_scan);
 		if (ret)
 			goto out;
 
-		slot = ksm_scan->slot_index;
+		slot = ksm_scan->cur_mm_slot;
+		mm = slot->mm;
+		addr = ksm_scan->addr_index;
+		rmap_item = ksm_scan->cur_rmap;
 
 		cond_resched();
 
@@ -1416,97 +1409,34 @@ static int ksm_scan_start(struct ksm_scan *ksm_scan, unsigned int scan_npages)
 		 * If the page is swapped out or in swap cache, we don't want to
 		 * scan it (it is just for performance).
 		 */
-		down_read(&slot->mm->mmap_sem);
-		if (is_present_pte(slot->mm, slot->addr +
-				   ksm_scan->page_index * PAGE_SIZE)) {
-			val = get_user_pages(current, slot->mm, slot->addr +
-					     ksm_scan->page_index * PAGE_SIZE ,
-					      1, 0, 0, page, NULL);
-			up_read(&slot->mm->mmap_sem);
+		down_read(&mm->mmap_sem);
+		if (is_present_pte(mm, addr)) {
+			val = get_user_pages(current, mm, addr, 1, 0, 0, page,
+					     NULL);
+			up_read(&mm->mmap_sem);
 			if (val == 1) {
 				if (!PageKsm(page[0]))
-					cmp_and_merge_page(ksm_scan, page[0]);
+					cmp_and_merge_page(page[0], rmap_item);
 				put_page(page[0]);
 			}
 		} else {
-			up_read(&slot->mm->mmap_sem);
+			up_read(&mm->mmap_sem);
 		}
+
 		scan_npages--;
 	}
-	scan_get_next_index(ksm_scan);
 out:
-	up_read(&slots_lock);
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
 		if (ksmd_flags & ksm_control_flags_run) {
 			down_read(&ksm_thread_lock);
-			ksm_scan_start(&ksm_thread_scan,
-				       ksm_thread_pages_to_scan);
+			if (ksmd_flags & ksm_control_flags_run)
+				ksm_scan_start(&ksm_thread_scan,
+					       ksm_thread_pages_to_scan);
 			up_read(&ksm_thread_lock);
 			schedule_timeout_interruptible(
 					usecs_to_jiffies(ksm_thread_sleep));
@@ -1613,6 +1543,8 @@ static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
 
 	down_write(&ksm_thread_lock);
 	ksmd_flags = k_flags;
+	if (!ksmd_flags)
+		remove_all_mm_slots();
 	up_write(&ksm_thread_lock);
 
 	if (ksmd_flags)
@@ -1696,13 +1628,10 @@ static int __init ksm_init(void)
 	if (r)
 		goto out;
 
-	r = rmap_hash_init();
+	r = mm_slots_hash_init();
 	if (r)
 		goto out_free1;
 
-	if (!regions_per_fd)
-		regions_per_fd = 1024;
-
 	ksm_thread = kthread_run(ksm_scan_thread, NULL, "kksmd");
 	if (IS_ERR(ksm_thread)) {
 		printk(KERN_ERR "ksm: creating kthread failed\n");
@@ -1710,27 +1639,19 @@ static int __init ksm_init(void)
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
-	rmap_hash_free();
+	mm_slots_hash_free();
 out_free1:
 	ksm_slab_free();
 out:
@@ -1740,10 +1661,9 @@ out:
 static void __exit ksm_exit(void)
 {
 	sysfs_remove_group(mm_kobj, &ksm_attr_group);
-	misc_deregister(&ksm_dev);
 	ksmd_flags = ksm_control_flags_run;
 	kthread_stop(ksm_thread);
-	rmap_hash_free();
+	mm_slots_hash_free();
 	ksm_slab_free();
 }
 
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
