Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 56C466B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 01:47:42 -0400 (EDT)
Date: Wed, 1 Apr 2009 22:48:16 -0700
From: Chris Wright <chrisw@redhat.com>
Subject: [PATCH 4/4 alternative userspace] add ksm kernel shared memory
	driver
Message-ID: <20090402054816.GG1117@x200.localdomain>
References: <20090331142533.GR9137@random.random> <49D22A9D.4050403@codemonkey.ws> <20090331150218.GS9137@random.random> <49D23224.9000903@codemonkey.ws> <20090331151845.GT9137@random.random> <49D23CD1.9090208@codemonkey.ws> <20090331162525.GU9137@random.random> <49D24A02.6070000@codemonkey.ws> <20090402012215.GE1117@x200.localdomain> <49D424AF.3090806@codemonkey.ws>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49D424AF.3090806@codemonkey.ws>
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: Chris Wright <chrisw@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

Here's ksm w/ a user interface built around madvise for registering and
sysfs for controlling (should just drop config tristate and make it bool,
CONFIG_KSM= y or n).

#include Izik's changelog

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

Ksm api (for users to register region):

Register a memory region as shareable:

madvise(void *addr, size_t len, MADV_SHAREABLE)

Unregister a shareable memory region (not currently implemented):

madvise(void *addr, size_t len, MADV_UNSHAREABLE)

Ksm api (for users to control ksm scanning daemon):
/sys/kernel/mm/ksm
|-- pages_shared	<-- RO, attribute showing number of pages shared
|-- pages_to_scan	<-- RW, number of pages to scan per scan loop
|-- run			<-- RW, whether scanning daemon should scan
`-- sleep		<-- RW, number of usecs to sleep between scan loops

Signed-off-by: Izik Eidus <ieidus@redhat.com>
Signed-off-by: Chris Wright <chrisw@redhat.com>
---
 include/asm-generic/mman.h |    1 +
 include/linux/ksm.h        |    8 +
 mm/Kconfig                 |    6 +
 mm/Makefile                |    1 +
 mm/ksm.c                   | 1337 ++++++++++++++++++++++++++++++++++++++++++++
 mm/madvise.c               |   18 +
 6 files changed, 1371 insertions(+), 0 deletions(-)

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
new file mode 100644
index 0000000..e032f6f
--- /dev/null
+++ b/include/linux/ksm.h
@@ -0,0 +1,8 @@
+#ifndef __LINUX_KSM_H
+#define __LINUX_KSM_H
+
+#define ksm_control_flags_run 1
+
+long ksm_register_memory(struct vm_area_struct *, unsigned long, unsigned long);
+
+#endif
diff --git a/mm/Kconfig b/mm/Kconfig
index b53427a..3f3fd04 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -223,3 +223,9 @@ config HAVE_MLOCKED_PAGE_BIT
 
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
index 0000000..fcbf76e
--- /dev/null
+++ b/mm/ksm.c
@@ -0,0 +1,1337 @@
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
+#include <linux/kobject.h>
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
+	struct mm_struct *mm;
+	unsigned long addr;	/* the begining of the virtual address */
+	unsigned npages;	/* number of pages to share */
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
+ * slots_lock protect against removing and adding memory regions while a scanner
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
+static int nrmaps_hash;
+/* rmap_hash hash table */
+static struct hlist_head *rmap_hash;
+
+static struct kmem_cache *tree_item_cache;
+static struct kmem_cache *rmap_item_cache;
+
+static int kthread_sleep; /* sleep time of the kernel thread */
+static int kthread_pages_to_scan; /* npages to scan for the kernel thread */
+static unsigned long ksm_pages_shared;
+static struct ksm_scan kthread_ksm_scan;
+static int ksmd_flags;
+static struct task_struct *kthread;
+static DECLARE_WAIT_QUEUE_HEAD(kthread_wait);
+static DECLARE_RWSEM(kthread_lock);
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
+         * account that ksm scan just anonymous pages, we can relay on the fact
+	 * that each time we see !PageAnon(page) we are hitting shared page.
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
+	checksum = jhash(addr, PAGE_SIZE, 17);
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
+		if (rmap_item->prev) {
+			BUG_ON(rmap_item->prev->next != rmap_item);
+			rmap_item->prev->next = rmap_item->next;
+		}
+		if (rmap_item->next) {
+			BUG_ON(rmap_item->next->prev != rmap_item);
+			rmap_item->next->prev = rmap_item->prev;
+		}
+	}
+
+	if (tree_item) {
+		if (rmap_item->stable_tree) {
+	 		if (!rmap_item->next && !rmap_item->prev) {
+				rb_erase(&tree_item->node, &root_stable_tree);
+				free_tree_item(tree_item);
+			} else if (!rmap_item->prev) {
+				tree_item->rmap_item = rmap_item->next;
+			} else {
+				tree_item->rmap_item = rmap_item->prev;
+			}
+		} else if (!rmap_item->stable_tree) {
+			free_tree_item(tree_item);
+		}
+	}
+
+	hlist_del(&rmap_item->link);
+	free_rmap_item(rmap_item);
+}
+
+long ksm_register_memory(struct vm_area_struct *vma, unsigned long start,
+			unsigned long end)
+{
+	struct ksm_mem_slot *slot;
+	int npages = (end - start) >> PAGE_SHIFT;
+
+	int ret = -EPERM;
+
+	slot = kzalloc(sizeof(struct ksm_mem_slot), GFP_KERNEL);
+	if (!slot) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	slot->mm = get_task_mm(current);
+	if (!slot->mm)
+		goto out_free;
+	slot->addr = start;
+	slot->npages = npages;
+
+	down_write(&slots_lock);
+
+	list_add_tail(&slot->link, &slots);
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
+static pte_t *get_pte(struct mm_struct *mm, unsigned long addr)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *ptep = NULL;
+
+	pgd = pgd_offset(mm, addr);
+	if (!pgd_present(*pgd))
+		goto out;
+
+	pud = pud_offset(pgd, addr);
+	if (!pud_present(*pud))
+		goto out;
+
+	pmd = pmd_offset(pud, addr);
+	if (!pmd_present(*pmd))
+		goto out;
+
+	ptep = pte_offset_map(pmd, addr);
+out:
+	return ptep;
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
+	get_page(newpage);
+	get_page(oldpage);
+
+	down_read(&mm->mmap_sem);
+
+	page_addr_in_vma = addr_in_vma(vma, oldpage);
+	if (page_addr_in_vma == -EFAULT)
+		goto out_unlock;
+
+	orig_ptep = get_pte(mm, page_addr_in_vma);
+	if (!orig_ptep)
+		goto out_unlock;
+	orig_pte = *orig_ptep;
+	pte_unmap(orig_ptep);
+	if (!pte_present(orig_pte))
+		goto out_unlock;
+	if (page_to_pfn(oldpage) != pte_pfn(orig_pte))
+		goto out_unlock;
+	/*
+	 * we need the page lock to read a stable PageSwapCache in
+	 * page_wrprotect()
+	 */
+	if (!trylock_page(oldpage))
+		goto out_unlock;
+	/*
+	 * page_wrprotect check if the page is swapped or in swap cache,
+	 * in the future we might want to run here if_present_pte and then
+	 * swap_free
+	 */
+	if (!page_wrprotect(oldpage, &odirect_sync, 2)) {
+		unlock_page(oldpage);
+		goto out_unlock;
+	}
+	unlock_page(oldpage);
+	if (!odirect_sync)
+		goto out_unlock;
+
+	orig_pte = pte_wrprotect(orig_pte);
+
+	if (pages_identical(oldpage, newpage))
+		ret = replace_page(vma, oldpage, newpage, orig_pte, newprot);
+
+out_unlock:
+	up_read(&mm->mmap_sem);
+	put_page(oldpage);
+	put_page(newpage);
+	return ret;
+}
+
+/*
+ * try_to_merge_two_pages - take two identical pages and prepare them to be
+ * merged into one page.
+ *
+ * this function return 0 if we successfully mapped two identical pages into one
+ * page, 1 otherwise.
+ * (note in case we created KsmPage and mapped one page into it but the second
+ *  page was not mapped we consider it as a failure and return 1)
+ */
+static int try_to_merge_two_pages(struct mm_struct *mm1, struct page *page1,
+				  struct mm_struct *mm2, struct page *page2,
+				  unsigned long addr1, unsigned long addr2)
+{
+	struct vm_area_struct *vma;
+	pgprot_t prot;
+	int ret = 1;
+
+	/*
+	 * If page2 isn't shared (it isn't PageKsm) we have to allocate a new
+	 * file mapped page and make the two ptes of mm1(page1) and mm2(page2)
+	 * point to it.  If page2 is shared, we can just make the pte of
+	 * mm1(page1) point to page2
+	 */
+	if (PageKsm(page2)) {
+		down_read(&mm1->mmap_sem);
+		vma = find_vma(mm1, addr1);
+		up_read(&mm1->mmap_sem);
+		if (!vma)
+			return ret;
+		prot = vma->vm_page_prot;
+		pgprot_val(prot) &= ~_PAGE_RW;
+		ret = try_to_merge_one_page(mm1, vma, page1, page2, prot);
+		if (!ret)
+			ksm_pages_shared++;
+	} else {
+		struct page *kpage;
+
+		kpage = alloc_page(GFP_HIGHUSER);
+		if (!kpage)
+			return ret;
+		down_read(&mm1->mmap_sem);
+		vma = find_vma(mm1, addr1);
+		up_read(&mm1->mmap_sem);
+		if (!vma) {
+			put_page(kpage);
+			return ret;
+		}
+		prot = vma->vm_page_prot;
+		pgprot_val(prot) &= ~_PAGE_RW;
+
+		copy_user_highpage(kpage, page1, addr1, vma);
+		ret = try_to_merge_one_page(mm1, vma, page1, kpage, prot);
+
+		if (!ret) {
+			down_read(&mm2->mmap_sem);
+			vma = find_vma(mm2, addr2);
+			up_read(&mm2->mmap_sem);
+			if (!vma) {
+				put_page(kpage);
+				ret = 1;
+				return ret;
+			}
+
+			prot = vma->vm_page_prot;
+			pgprot_val(prot) &= ~_PAGE_RW;
+
+			ret = try_to_merge_one_page(mm2, vma, page2, kpage,
+						    prot);
+			/*
+			 * If the secoend try_to_merge_one_page call was failed,
+			 * we are in situation where we have Ksm page that have
+			 * just one pte pointing to it, in this case we break
+			 * it.
+			 */
+			if (ret) {
+				struct page *tmppage[1];
+
+				down_read(&mm1->mmap_sem);
+				if (get_user_pages(current, mm1, addr1, 1, 1,
+						    0, tmppage, NULL)) {
+					put_page(tmppage[0]);
+				}
+				up_read(&mm1->mmap_sem);
+			} else {
+				ksm_pages_shared++;
+			}
+		}
+		put_page(kpage);
+	}
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
+
+	cond_resched();
+	if (is_present_pte(rmap_item->mm, rmap_item->address)) {
+		down_read(&rmap_item->mm->mmap_sem);
+		ret = get_user_pages(current, rmap_item->mm, rmap_item->address,
+				     1, 0, 0, page, NULL);
+		up_read(&rmap_item->mm->mmap_sem);
+	}
+
+	if (!ret)
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
+ * this function return 0 if success, 0 otherwise.
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
+			if (!rmap_item ||
+			    !(insert_rmap_item->mm == rmap_item->mm &&
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
+			 * It isnt a bug when we are here,
+			 * beacuse after we release the stable_tree_lock
+			 * someone else could have merge identical page to the
+			 * tree.
+			 */
+			return 1;
+		}
+	}
+
+	rb_link_node(&new_tree_item->node, parent, new);
+	rb_insert_color(&new_tree_item->node, &root_stable_tree);
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
+		if (!ret)
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
+ * update_stable_tree - check if the page inside the tree got zapped,
+ * and if it got zapped, kick it from the tree.
+ *
+ * we are setting wait to 1 in case we find that the rmap_item was object
+ * inside the stable_tree.
+ * (this is used to notify that we dont want to create new rmap_item to it
+ *  at this moment, but in the next time)
+ * wait is left unchanged incase the rmap_item was object inside the unstable
+ * tree.
+ */
+int update_tree(struct rmap_item *rmap_item, int *wait)
+{
+	struct page *page[1];
+
+	if (!rmap_item->stable_tree) {
+		if (rmap_item->tree_item) {
+			remove_rmap_item_from_tree(rmap_item);
+			return 1;
+		}
+		return 0;
+	}
+	if (is_zapped_item(rmap_item, page)) {
+		remove_rmap_item_from_tree(rmap_item);
+		*wait = 1;
+		return 1;
+	}
+	put_page(page[0]);
+	return 0;
+}
+
+static struct rmap_item *create_new_rmap_item(struct mm_struct *mm,
+			 		      unsigned long addr,
+					      unsigned int checksum)
+{
+	struct rmap_item *rmap_item;
+	struct hlist_head *bucket;
+
+	rmap_item = alloc_rmap_item();
+	if (!rmap_item)
+		return NULL;
+
+	rmap_item->mm = mm;
+	rmap_item->address = addr;
+	rmap_item->oldchecksum = checksum;
+	rmap_item->stable_tree = 0;
+	rmap_item->tree_item = NULL;
+
+	bucket = &rmap_hash[addr % nrmaps_hash];
+	hlist_add_head(&rmap_item->link, bucket);
+
+	return rmap_item;
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
+	int ret;
+
+	slot = ksm_scan->slot_index;
+	addr = slot->addr + ksm_scan->page_index * PAGE_SIZE;
+	rmap_item = get_rmap_item(slot->mm, addr);
+	if (rmap_item) {
+		if (update_tree(rmap_item, &wait))
+			rmap_item = NULL;
+	}
+
+	/* We first start with searching the page inside the stable tree */
+	tree_rmap_item = stable_tree_search(page, page2, rmap_item);
+	if (tree_rmap_item) {
+		BUG_ON(!tree_rmap_item->tree_item);
+		ret = try_to_merge_two_pages(slot->mm, page, tree_rmap_item->mm,
+					     page2[0], addr,
+					     tree_rmap_item->address);
+		put_page(page2[0]);
+		if (!ret) {
+			/*
+			 * The page was successuly merged, lets insert its
+			 * rmap_item into the stable tree.
+			 */
+
+			if (!rmap_item)
+				rmap_item = create_new_rmap_item(slot->mm,
+								 addr, 0);
+			if (!rmap_item)
+				return !ret;
+
+			rmap_item->next = tree_rmap_item->next;
+			rmap_item->prev = tree_rmap_item;
+
+			if (tree_rmap_item->next)
+				tree_rmap_item->next->prev = rmap_item;
+
+			tree_rmap_item->next = rmap_item;
+
+			rmap_item->stable_tree = 1;
+			rmap_item->tree_item = tree_rmap_item->tree_item;
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
+		rmap_item = tree_item->rmap_item;
+		BUG_ON(!rmap_item);
+		ret = try_to_merge_two_pages(slot->mm, page, rmap_item->mm,
+					     page2[0], addr,
+					     rmap_item->address);
+		/*
+		 * As soon as we successuly merged this page, we want to remove
+		 * the rmap_item object of the page that we have merged with and
+		 * instead insert it as a new stable tree node.
+		 */
+		if (!ret) {
+			rb_erase(&tree_item->node, &root_unstable_tree);
+			stable_tree_insert(page2[0], tree_item, rmap_item);
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
+		checksum = calc_checksum(page);
+		create_new_rmap_item(slot->mm, addr, checksum);
+	}
+out:
+	return ret;
+}
+
+/* return -EAGAIN - no slots registered, nothing to be done */
+static int scan_get_next_index(struct ksm_scan *ksm_scan, int nscan)
+{
+	struct ksm_mem_slot *slot;
+
+	if (list_empty(&slots))
+		return -EAGAIN;
+
+	slot = ksm_scan->slot_index;
+
+	/* Are there pages left in this slot to scan? */
+	if ((slot->npages - ksm_scan->page_index - nscan) > 0) {
+		ksm_scan->page_index += nscan;
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
+		ret = scan_get_next_index(ksm_scan, 1);
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
+	scan_get_next_index(ksm_scan, 1);
+out:
+	up_read(&slots_lock);
+	return ret;
+}
+
+int kthread_ksm_scan_thread(void *nothing)
+{
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
+
+#define KSM_ATTR_RO(_name) \
+	static struct kobj_attribute _name##_attr = __ATTR_RO(_name)
+
+#define KSM_ATTR(_name) \
+	static struct kobj_attribute _name##_attr = \
+		__ATTR(_name, 0644, _name##_show, _name##_store)
+
+static ssize_t sleep_show(struct kobject *kobj, struct kobj_attribute *attr,
+			  char *buf)
+{
+	unsigned int usecs;
+
+	down_read(&kthread_lock);
+	usecs = kthread_sleep;
+	up_read(&kthread_lock);
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
+	down_write(&kthread_lock);
+	kthread_sleep = usecs;
+	up_write(&kthread_lock);
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
+	down_read(&kthread_lock);
+	nr_pages = kthread_pages_to_scan;
+	up_read(&kthread_lock);
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
+	down_write(&kthread_lock);
+	kthread_pages_to_scan = nr_pages;
+	up_write(&kthread_lock);
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
+	down_read(&kthread_lock);
+	run = ksmd_flags;
+	up_read(&kthread_lock);
+
+	return sprintf(buf, "%lu\n", run);
+}
+
+static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
+			 const char *buf, size_t count)
+{
+	int err;
+	unsigned long run;
+
+	err = strict_strtoul(buf, 10, &run);
+	if (err)
+		return 0;
+
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
+{
+	return sprintf(buf, "%lu\n", ksm_pages_shared);
+}
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
+	kthread = kthread_run(kthread_ksm_scan_thread, NULL, "kksmd");
+	if (IS_ERR(kthread)) {
+		printk(KERN_ERR "ksm: creating kthread failed\n");
+		r = PTR_ERR(kthread);
+		goto out_free2;
+	}
+
+	r = sysfs_create_group(mm_kobj, &ksm_attr_group);
+	if (r) {
+		printk(KERN_ERR "ksm: sysfs file creation failed\n");
+		goto out_free3;
+	}
+
+	printk(KERN_WARNING "ksm loaded\n");
+	return 0;
+
+out_free3:
+	kthread_stop(kthread);
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
+	ksmd_flags = ksm_control_flags_run;
+	kthread_stop(kthread);
+	rmap_hash_free();
+	ksm_slab_free();
+}
+
+module_init(ksm_init)
+module_exit(ksm_exit)
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
