From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 3/4] add ksm kernel shared memory driver
Date: Tue, 11 Nov 2008 15:21:40 +0200
Message-Id: <1226409701-14831-4-git-send-email-ieidus@redhat.com>
In-Reply-To: <1226409701-14831-3-git-send-email-ieidus@redhat.com>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>
 <1226409701-14831-2-git-send-email-ieidus@redhat.com>
 <1226409701-14831-3-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
From: Izik Eidus <izike@qumranet.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, Izik Eidus <izike@qumranet.com>
List-ID: <linux-mm.kvack.org>

ksm is driver that allow merging identical pages between one or more
applications in way unvisible to the application that use it.
pages that are merged are marked as readonly and are COWed when any application
try to change them.

ksm is working by walking over the memory pages of the applications it scan
in order to find identical pages.
it uses an hash table to find in effective way the identical pages.

when ksm find two identical pages, it marked them as readonly and merge them
into single one page,
after the pages are marked as readonly and merged into one page, linux
will treat this pages as normal copy_on_write pages and will fork them
when write access will happen to them.

ksm scan just memory areas that were registred to be scanned by it.

Signed-off-by: Izik Eidus <izike@qumranet.com>
---
 drivers/Kconfig            |    5 +
 include/linux/ksm.h        |   53 ++
 include/linux/miscdevice.h |    1 +
 mm/Kconfig                 |    3 +
 mm/Makefile                |    1 +
 mm/ksm.c                   | 1202 ++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 1265 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/ksm.h
 create mode 100644 mm/ksm.c

diff --git a/drivers/Kconfig b/drivers/Kconfig
index d38f43f..c1c701f 100644
--- a/drivers/Kconfig
+++ b/drivers/Kconfig
@@ -105,4 +105,9 @@ source "drivers/uio/Kconfig"
 source "drivers/xen/Kconfig"
 
 source "drivers/staging/Kconfig"
+
+config KSM
+	bool "KSM driver support"
+	help
+		ksm is driver for merging identical pages between applciations
 endmenu
diff --git a/include/linux/ksm.h b/include/linux/ksm.h
new file mode 100644
index 0000000..f873502
--- /dev/null
+++ b/include/linux/ksm.h
@@ -0,0 +1,53 @@
+#ifndef __LINUX_KSM_H
+#define __LINUX_KSM_H
+
+/*
+ * Userspace interface for /dev/ksm - kvm shared memory
+ */
+
+#include <asm/types.h>
+#include <linux/ioctl.h>
+
+#define KSM_API_VERSION 1
+
+/* for KSM_REGISTER_MEMORY_REGION */
+struct ksm_memory_region {
+	__u32 npages; /* number of pages to share */
+	__u32 pad;
+	__u64 addr; /* the begining of the virtual address */
+};
+
+struct ksm_user_scan {
+	__u32 pages_to_scan;
+	__u32 max_pages_to_merge;
+};
+
+struct ksm_kthread_info {
+	__u32 sleep; /* number of microsecoends to sleep */
+	__u32 pages_to_scan; /* number of pages to scan */
+	__u32 max_pages_to_merge;
+	__u32 running;
+};
+
+#define KSMIO 0xAB
+
+/* ioctls for /dev/ksm */
+#define KSM_GET_API_VERSION              _IO(KSMIO,   0x00)
+#define KSM_CREATE_SHARED_MEMORY_AREA    _IO(KSMIO,   0x01) /* return SMA fd */
+#define KSM_CREATE_SCAN                  _IO(KSMIO,   0x02) /* return SCAN fd */
+#define KSM_START_STOP_KTHREAD		 _IOW(KSMIO,  0x03,\
+					      struct ksm_kthread_info)
+#define KSM_GET_INFO_KTHREAD		 _IOW(KSMIO,  0x04,\
+					      struct ksm_kthread_info) 
+
+
+/* ioctls for SMA fds */
+#define KSM_REGISTER_MEMORY_REGION       _IOW(KSMIO,  0x20,\
+					      struct ksm_memory_region)
+#define KSM_REMOVE_MEMORY_REGION         _IO(KSMIO,   0x21)
+
+/* ioctls for SCAN fds */
+#define KSM_SCAN                         _IOW(KSMIO,  0x40,\
+					      struct ksm_user_scan)
+
+#endif
diff --git a/include/linux/miscdevice.h b/include/linux/miscdevice.h
index 26433ec..adc2435 100644
--- a/include/linux/miscdevice.h
+++ b/include/linux/miscdevice.h
@@ -30,6 +30,7 @@
 #define TUN_MINOR	     200
 #define	HPET_MINOR	     228
 #define KVM_MINOR            232
+#define KSM_MINOR            233
 
 struct device;
 
diff --git a/mm/Kconfig b/mm/Kconfig
index 5b5790f..e7f0061 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -222,3 +222,6 @@ config UNEVICTABLE_LRU
 
 config MMU_NOTIFIER
 	bool
+
+config KSM
+	bool
diff --git a/mm/Makefile b/mm/Makefile
index c06b45a..9722afe 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -26,6 +26,7 @@ obj-$(CONFIG_TMPFS_POSIX_ACL) += shmem_acl.o
 obj-$(CONFIG_TINY_SHMEM) += tiny-shmem.o
 obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
+obj-$(CONFIG_KSM) += ksm.o
 obj-$(CONFIG_SLAB) += slab.o
 obj-$(CONFIG_SLUB) += slub.o
 obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
diff --git a/mm/ksm.c b/mm/ksm.c
new file mode 100644
index 0000000..977eb37
--- /dev/null
+++ b/mm/ksm.c
@@ -0,0 +1,1202 @@
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
+#include <linux/vmalloc.h>
+#include <linux/sched.h>
+#include <linux/rmap.h>
+#include <linux/spinlock.h>
+#include <linux/jhash.h>
+#include <linux/delay.h>
+#include <linux/kthread.h>
+#include <linux/wait.h>
+#include <linux/anon_inodes.h>
+#include <linux/ksm.h>
+#include <linux/crypto.h>
+#include <linux/scatterlist.h>
+#include <linux/random.h>
+#include <crypto/sha.h>
+
+#include <asm/tlbflush.h>
+
+MODULE_AUTHOR("Red Hat, Inc.");
+MODULE_LICENSE("GPL");
+
+static int page_hash_size;
+module_param(page_hash_size, int, 0);
+MODULE_PARM_DESC(page_hash_size, "Hash table size for the pages checksum");
+
+static int rmap_hash_size;
+module_param(rmap_hash_size, int, 0);
+MODULE_PARM_DESC(rmap_hash_size, "Hash table size for the reverse mapping");
+
+static int sha1_hash_size;
+module_param(sha1_hash_size, int, 0);
+MODULE_PARM_DESC(sha1_hash_size, "Hash table size for the sha1 caching");
+
+struct ksm_mem_slot {
+	struct list_head link;
+	struct list_head sma_link;
+	struct mm_struct *mm;
+	unsigned long addr;	/* the begining of the virtual address */
+	int npages;		/* number of pages to share */
+};
+
+/*
+ * sma - shared memory area, each process have its own sma that contain the
+ * information about the slots that it own
+ */
+struct ksm_sma {
+	struct list_head sma_slots;
+};
+
+struct ksm_scan {
+	struct ksm_mem_slot *slot_index; /* the slot we are scanning now */
+	int page_index;	/* the page inside sma that is now being scanned */
+};
+
+struct page_hash_item {
+	struct hlist_node link;
+	struct mm_struct *mm;
+	unsigned long addr;
+};
+
+struct rmap_item {
+	struct hlist_node link;
+	struct page_hash_item *page_hash_item;
+	unsigned long oldindex;
+};
+
+struct sha1_item {
+	unsigned char sha1val[SHA1_DIGEST_SIZE];
+	unsigned long pfn;
+};
+
+static struct list_head slots;
+static struct rw_semaphore slots_lock;
+
+static DEFINE_MUTEX(sha1_lock);
+
+static int npages_hash;
+static struct hlist_head *page_hash_items;
+static int nrmaps_hash;
+static struct hlist_head *rmap_hash;
+static int nsha1s_hash;
+static struct sha1_item *sha1_hash;
+
+static struct kmem_cache *page_hash_item_cache;
+static struct kmem_cache *rmap_item_cache;
+
+static int kthread_sleep;
+static int kthread_pages_to_scan;
+static int kthread_max_npages;
+static struct ksm_scan kthread_ksm_scan;
+static int kthread_run;
+static struct task_struct *kthread;
+static wait_queue_head_t kthread_wait;
+static struct rw_semaphore kthread_lock;
+static struct crypto_hash *tfm;
+static unsigned char hmac_key[SHA1_DIGEST_SIZE];
+static DEFINE_MUTEX(tfm_mutex);
+
+static spinlock_t hash_lock;
+
+static int ksm_tfm_init(void)
+{
+	struct crypto_hash *hash;
+	int rc = 0;
+
+	mutex_lock(&tfm_mutex);
+	if (tfm)
+		goto out;
+
+	/* Must be called from user context before starting any scanning */
+	hash = crypto_alloc_hash("hmac(sha1)", 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(hash)) {
+		rc = PTR_ERR(hash);
+		goto out;
+	}
+
+	get_random_bytes(hmac_key, sizeof(hmac_key));
+
+	rc = crypto_hash_setkey(hash, hmac_key, SHA1_DIGEST_SIZE);
+	if (rc) {
+		crypto_free_hash(hash);
+		goto out;
+	}
+	tfm = hash;
+out:
+	mutex_unlock(&tfm_mutex);
+	return rc;
+}
+
+static int ksm_slab_init(void)
+{
+	int ret = 1;
+
+	page_hash_item_cache = kmem_cache_create("ksm_page_hash_item",
+					    sizeof(struct page_hash_item), 0, 0,
+					    NULL);
+	if (!page_hash_item_cache)
+		goto out;
+
+	rmap_item_cache = kmem_cache_create("ksm_rmap_item",
+					    sizeof(struct rmap_item), 0, 0,
+					    NULL);
+	if (!rmap_item_cache)
+		goto out_free;
+	return 0;
+
+out_free:
+	kmem_cache_destroy(page_hash_item_cache);
+out:
+	return ret;
+}
+
+static void ksm_slab_free(void)
+{
+	kmem_cache_destroy(rmap_item_cache);
+	kmem_cache_destroy(page_hash_item_cache);
+}
+
+static struct page_hash_item *alloc_page_hash_item(void)
+{
+	void *obj;
+
+	obj = kmem_cache_zalloc(page_hash_item_cache, GFP_KERNEL);
+	return (struct page_hash_item *)obj;
+}
+
+static void free_page_hash_item(struct page_hash_item *page_hash_item)
+{
+	kmem_cache_free(page_hash_item_cache, page_hash_item);
+}
+
+static struct rmap_item *alloc_rmap_item(void)
+{
+	void *obj;
+
+	obj = kmem_cache_zalloc(rmap_item_cache, GFP_KERNEL);
+	return (struct rmap_item *)obj;
+}
+
+static void free_rmap_item(struct rmap_item *rmap_item)
+{
+	kmem_cache_free(rmap_item_cache, rmap_item);
+}
+
+static inline int PageKsm(struct page *page)
+{
+	return !PageAnon(page);
+}
+
+static int page_hash_init(void)
+{
+	if (!page_hash_size) {
+		struct sysinfo sinfo;
+
+		si_meminfo(&sinfo);
+		page_hash_size = sinfo.totalram;
+		page_hash_size /= 40;
+	}
+	npages_hash = page_hash_size;
+	page_hash_items = vmalloc(npages_hash * sizeof(struct page_hash_item));
+	if (!page_hash_items)
+		return 1;
+
+	memset(page_hash_items, 0, npages_hash * sizeof(struct page_hash_item));
+	return 0;
+}
+
+static void page_hash_free(void)
+{
+	int i;
+	struct hlist_head *bucket;
+	struct hlist_node *node, *n;
+	struct page_hash_item *page_hash_item;
+
+	for (i = 0; i < npages_hash; ++i) {
+		bucket = &page_hash_items[i];
+		hlist_for_each_entry_safe(page_hash_item, node, n, bucket, link) {
+			hlist_del(&page_hash_item->link);
+			free_page_hash_item(page_hash_item);
+		}
+	}
+	vfree(page_hash_items);
+}
+
+static int rmap_hash_init(void)
+{
+	if (!rmap_hash_size) {
+		struct sysinfo sinfo;
+
+		si_meminfo(&sinfo);
+		rmap_hash_size = sinfo.totalram;
+		rmap_hash_size /= 40;
+	}
+	nrmaps_hash = rmap_hash_size;
+	rmap_hash = vmalloc(nrmaps_hash *
+				 sizeof(struct hlist_head));
+	if (!rmap_hash)
+		return 1;
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
+static int sha1_hash_init(void)
+{
+	if (!sha1_hash_size) {
+		struct sysinfo sinfo;
+
+		si_meminfo(&sinfo);
+		sha1_hash_size = sinfo.totalram;
+		sha1_hash_size /= 128;
+	}
+	nsha1s_hash = sha1_hash_size;
+	sha1_hash = vmalloc(nsha1s_hash *
+				 sizeof(struct sha1_item));
+	if (!sha1_hash)
+		return 1;
+	memset(sha1_hash, 0, nsha1s_hash * sizeof(struct sha1_item));
+	return 0;
+}
+
+static void sha1_hash_free(void)
+{
+	vfree(sha1_hash);
+}
+
+static inline u32 calc_hash_index(struct page *page)
+{
+	u32 hash;
+	void *addr = kmap_atomic(page, KM_USER0);
+	hash = jhash(addr, PAGE_SIZE, 17);
+	kunmap_atomic(addr, KM_USER0);
+	return hash % npages_hash;
+}
+
+static void remove_page_from_hash(struct mm_struct *mm, unsigned long addr)
+{
+	struct rmap_item *rmap_item;
+	struct hlist_head *bucket;
+	struct hlist_node *node, *n;
+
+	bucket = &rmap_hash[addr % nrmaps_hash];
+	hlist_for_each_entry_safe(rmap_item, node, n, bucket, link) {
+		if (mm == rmap_item->page_hash_item->mm &&
+		    rmap_item->page_hash_item->addr == addr) {
+			hlist_del(&rmap_item->page_hash_item->link);
+			free_page_hash_item(rmap_item->page_hash_item);
+			hlist_del(&rmap_item->link);
+			free_rmap_item(rmap_item);
+			return;
+		}
+	}
+}
+
+static int ksm_sma_ioctl_register_memory_region(struct ksm_sma *ksm_sma,
+						struct ksm_memory_region *mem)
+{
+	struct ksm_mem_slot *slot;
+	int ret = -1;
+
+	if (!current->mm)
+		goto out;
+
+	slot = kzalloc(sizeof(struct ksm_mem_slot), GFP_KERNEL);
+	if (!slot)
+		goto out;
+
+	slot->mm = get_task_mm(current);
+	slot->addr = mem->addr;
+	slot->npages = mem->npages;
+
+	down_write(&slots_lock);
+
+	list_add_tail(&slot->link, &slots);
+	list_add_tail(&slot->sma_link, &ksm_sma->sma_slots);
+
+	up_write(&slots_lock);
+	ret = 0;
+out:
+	return ret;
+}
+
+static void remove_mm_from_hash(struct mm_struct *mm)
+{
+	struct ksm_mem_slot *slot;
+	int pages_count = 0;
+
+	list_for_each_entry(slot, &slots, link)
+		if (slot->mm == mm)
+			break;
+	if (!slot)
+		BUG();
+
+	spin_lock(&hash_lock);
+	while (pages_count < slot->npages) {
+		remove_page_from_hash(mm, slot->addr + pages_count * PAGE_SIZE);
+		pages_count++;
+	}
+	spin_unlock(&hash_lock);
+	list_del(&slot->link);
+}
+
+static int ksm_sma_ioctl_remove_memory_region(struct ksm_sma *ksm_sma)
+{
+	struct ksm_mem_slot *slot, *node;
+
+	down_write(&slots_lock);
+	list_for_each_entry_safe(slot, node, &ksm_sma->sma_slots, sma_link) {
+		remove_mm_from_hash(slot->mm);
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
+				   sizeof ksm_memory_region))
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
+static int insert_page_to_hash(struct ksm_scan *ksm_scan,
+			       unsigned long hash_index,
+			       struct page_hash_item *page_hash_item,
+			       struct rmap_item *rmap_item)
+{
+	struct ksm_mem_slot *slot;
+	struct hlist_head *bucket;
+
+	slot = ksm_scan->slot_index;
+	page_hash_item->addr = slot->addr + ksm_scan->page_index * PAGE_SIZE;
+	page_hash_item->mm = slot->mm;
+	bucket = &page_hash_items[hash_index];
+	hlist_add_head(&page_hash_item->link, bucket);
+
+	rmap_item->page_hash_item = page_hash_item;
+	rmap_item->oldindex = hash_index;
+	bucket = &rmap_hash[page_hash_item->addr % nrmaps_hash];
+	hlist_add_head(&rmap_item->link, bucket);
+	return 0;
+}
+
+static void update_hash(struct ksm_scan *ksm_scan,
+		       unsigned long hash_index)
+{
+	struct rmap_item *rmap_item;
+	struct ksm_mem_slot *slot;
+	struct hlist_head *bucket;
+	struct hlist_node *node, *n;
+	unsigned long addr;
+
+	slot = ksm_scan->slot_index;;
+	addr = slot->addr + ksm_scan->page_index * PAGE_SIZE;
+	bucket = &rmap_hash[addr % nrmaps_hash];
+	hlist_for_each_entry_safe(rmap_item, node, n, bucket, link) {
+		if (slot->mm == rmap_item->page_hash_item->mm &&
+		    rmap_item->page_hash_item->addr == addr) {
+			if (hash_index != rmap_item->oldindex) {
+				hlist_del(&rmap_item->page_hash_item->link);
+				free_page_hash_item(rmap_item->page_hash_item);
+				hlist_del(&rmap_item->link);
+				free_rmap_item(rmap_item);
+			}
+			return;
+		}
+	}
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
+
+	ptep = get_pte(mm, addr);
+	if (!ptep)
+		return 0;
+
+	if (pte_present(*ptep))
+		return 1;
+	return 0;
+}
+
+#define PAGECMP_OFFSET 128
+#define PAGEHASH_SIZE (PAGECMP_OFFSET ? PAGECMP_OFFSET : PAGE_SIZE)
+/* hash the page */
+static void page_hash(struct page *page, unsigned char *digest)
+{
+	struct scatterlist sg;
+	struct hash_desc desc;
+
+	sg_init_table(&sg, 1);
+	sg_set_page(&sg, page, PAGEHASH_SIZE, 0);
+	desc.tfm = tfm;
+	desc.flags = 0;
+	crypto_hash_digest(&desc, &sg, PAGEHASH_SIZE, digest);
+}
+
+/* pages_identical
+ * calculate sha1 hash of each page, compare results,
+ * and return 1 if identical, 0 otherwise.
+ */
+static int pages_identical(struct page *oldpage, struct page *newpage, int new)
+{
+	int r;
+	unsigned char old_digest[SHA1_DIGEST_SIZE];
+	struct sha1_item *sha1_item;
+
+	page_hash(oldpage, old_digest);
+	/*
+	 * If new = 1, it is never safe to use the sha1 value that is
+	 * inside the cache, the reason is that the page can be released
+	 * and then recreated and have diffrent sha1 value.
+	 * (swapping as for now is not an issue, beacuse KsmPages cannot be
+	 * swapped)
+	 */
+	if (new) {
+		mutex_lock(&sha1_lock);
+		sha1_item = &sha1_hash[page_to_pfn(newpage) % nsha1s_hash];
+		page_hash(newpage, sha1_item->sha1val);
+		sha1_item->pfn = page_to_pfn(newpage);
+		r = !memcmp(old_digest, sha1_item->sha1val, SHA1_DIGEST_SIZE);
+		mutex_unlock(&sha1_lock);
+	} else {
+		mutex_lock(&sha1_lock);
+		sha1_item = &sha1_hash[page_to_pfn(newpage) % nsha1s_hash];
+		if (sha1_item->pfn != page_to_pfn(newpage)) {
+			page_hash(newpage, sha1_item->sha1val);
+			sha1_item->pfn = page_to_pfn(newpage);
+		}
+		r = !memcmp(old_digest, sha1_item->sha1val, SHA1_DIGEST_SIZE);
+		mutex_unlock(&sha1_lock);
+	}
+	if (PAGECMP_OFFSET && r) {
+		char *old_addr, *new_addr;
+		old_addr = kmap_atomic(oldpage, KM_USER0);
+		new_addr = kmap_atomic(newpage, KM_USER1);
+		r = !memcmp(old_addr+PAGECMP_OFFSET, new_addr+PAGECMP_OFFSET, PAGE_SIZE-PAGECMP_OFFSET);
+		kunmap_atomic(old_addr, KM_USER0);
+		kunmap_atomic(new_addr, KM_USER1);
+	}
+	return r;
+}
+
+/*
+ * try_to_merge_one_page - take two pages and merge them into one
+ * note:
+ * oldpage should be anon page while newpage should be file mapped page
+ */
+static int try_to_merge_one_page(struct mm_struct *mm,
+				 struct vm_area_struct *vma,
+				 struct page *oldpage,
+				 struct page *newpage,
+				 pgprot_t newprot,
+				 int new)
+{
+	int ret = 0;
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
+	if (!pte_present(orig_pte))
+		goto out_unlock;
+	if (page_to_pfn(oldpage) != pte_pfn(orig_pte))
+		goto out_unlock;
+	/*
+	 * page_wrprotect check if the page is swapped or in swap cache,
+	 * in the future we might want to run here if_present_pte and then
+	 * swap_free
+	 */
+	if (!page_wrprotect(oldpage, &odirect_sync))
+		goto out_unlock;
+	if (!odirect_sync)
+		goto out_unlock;
+
+	orig_pte = pte_wrprotect(orig_pte);
+
+	ret = 1;
+	if (pages_identical(oldpage, newpage, new))
+		ret = replace_page(vma, oldpage, newpage, orig_pte, newprot);
+
+	if (!ret)
+		ret = 1;
+	else
+		ret = 0;
+
+out_unlock:
+	up_read(&mm->mmap_sem);
+	put_page(oldpage);
+	put_page(newpage);
+	return ret;
+}
+
+static int try_to_merge_two_pages(struct mm_struct *mm1, struct page *page1,
+				  struct mm_struct *mm2, struct page *page2,
+				  unsigned long addr1, unsigned long addr2)
+{
+	struct vm_area_struct *vma;
+	pgprot_t prot;
+	int ret = 0;
+
+	/*
+	 * If page2 isn't shared (it isn't PageKsm) we have to allocate a new 
+	 * file mapped page and make the two ptes of mm1(page1) and mm2(page2)
+	 * point to it.  If page2 is shared, we can just make the pte of
+	 * mm1(page1) point to page2
+	 */
+	if (PageKsm(page2)) {
+		vma = find_vma(mm1, addr1);
+		if (!vma)
+			return ret;
+		prot = vma->vm_page_prot;
+		pgprot_val(prot) &= ~VM_WRITE;
+		ret = try_to_merge_one_page(mm1, vma, page1, page2, prot, 0);
+	} else {
+		struct page *kpage;
+
+		kpage = alloc_page(GFP_KERNEL |  __GFP_HIGHMEM);
+		if (!kpage)
+			return ret;
+
+		vma = find_vma(mm1, addr1);
+		if (!vma) {
+			page_cache_release(kpage);
+			return ret;
+		}
+		prot = vma->vm_page_prot;
+		pgprot_val(prot) &= ~VM_WRITE;
+
+		copy_highpage(kpage, page1);
+		ret = try_to_merge_one_page(mm1, vma, page1, kpage, prot, 1);
+
+		if (ret) {
+			vma = find_vma(mm2, addr2);
+			if (!vma) {
+				page_cache_release(kpage);
+				return ret;
+			}
+
+			prot = vma->vm_page_prot;
+			pgprot_val(prot) &= ~VM_WRITE;
+
+			ret = try_to_merge_one_page(mm2, vma, page2, kpage,
+						    prot, 0);
+		}
+		page_cache_release(kpage);
+	}
+	return ret;
+}
+
+static int cmp_and_merge_page(struct ksm_scan *ksm_scan, struct page *page)
+{
+	struct hlist_head *bucket;
+	struct hlist_node *node, *n;
+	struct page_hash_item *page_hash_item;
+	struct ksm_mem_slot *slot;
+	unsigned long hash_index;
+	unsigned long addr;
+	int ret = 0;
+	int used = 0;
+
+	hash_index = calc_hash_index(page);
+	bucket = &page_hash_items[hash_index];
+
+	slot = ksm_scan->slot_index;
+	addr = slot->addr + ksm_scan->page_index * PAGE_SIZE;
+
+	spin_lock(&hash_lock);
+	/*
+	 * update_hash must be called every time because there is a chance
+	 * that the data in the page has changed since the page was inserted
+	 * into the hash table to avoid inserting the page more than once.
+	 */ 
+	update_hash(ksm_scan, hash_index);
+	spin_unlock(&hash_lock);
+
+	hlist_for_each_entry_safe(page_hash_item, node, n, bucket, link) {
+		int npages;
+		struct page *hash_page[1];
+
+		if (slot->mm == page_hash_item->mm && addr == page_hash_item->addr) {
+			used = 1;
+			continue;
+		}
+
+		down_read(&page_hash_item->mm->mmap_sem);
+		/*
+		 * If the page is swapped out or in swap cache we don't want to
+		 * scan it (it is just for performance).
+		 */
+		if (!is_present_pte(page_hash_item->mm, page_hash_item->addr)) {
+			up_read(&page_hash_item->mm->mmap_sem);
+			continue;
+		}
+		npages = get_user_pages(current, page_hash_item->mm,
+					page_hash_item->addr,
+					1, 0, 0, hash_page, NULL);
+		up_read(&page_hash_item->mm->mmap_sem);
+		if (npages != 1)
+			break;
+
+		/* Recalculate the page's hash index in case it has changed. */
+		if (calc_hash_index(hash_page[0]) == hash_index) {
+
+			ret = try_to_merge_two_pages(slot->mm, page,
+						     page_hash_item->mm,
+						     hash_page[0], addr,
+						     page_hash_item->addr);
+			if (ret) {
+				page_cache_release(hash_page[0]);
+				return ret;
+			}
+		}
+		page_cache_release(hash_page[0]);
+	}
+	/* If node is NULL and used=0, the page is not in the hash table. */
+	if (!node && !used) {
+		struct page_hash_item *page_hash_item;
+		struct rmap_item *rmap_item;
+
+		page_hash_item = alloc_page_hash_item();
+		if (!page_hash_item)
+			return ret;
+
+		rmap_item = alloc_rmap_item();
+		if (!rmap_item) {
+			free_page_hash_item(page_hash_item);
+			return ret;
+		}
+
+		spin_lock(&hash_lock);
+		update_hash(ksm_scan, hash_index);
+		insert_page_to_hash(ksm_scan, hash_index, page_hash_item, rmap_item);
+		spin_unlock(&hash_lock);
+	}
+
+	return ret;
+}
+
+/* return 1 - no slots registered, nothing to be done */
+static int scan_get_next_index(struct ksm_scan *ksm_scan, int nscan)
+{
+	struct ksm_mem_slot *slot;
+
+	if (list_empty(&slots))
+		return 1;
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
+	ksm_scan->page_index = 0;
+	ksm_scan->slot_index = list_first_entry(&slots,
+						struct ksm_mem_slot, link);
+	return 0;
+}
+
+/*
+ * update slot_index so it point to vaild data, it is possible that by
+ * the time we are here the data that ksm_scan was pointed to was released
+ * so we have to call this function every time after taking the slots_lock
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
+static int ksm_scan_start(struct ksm_scan *ksm_scan, int scan_npages,
+			  int max_npages)
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
+	while (scan_npages > 0 && max_npages > 0) {
+		if (scan_get_next_index(ksm_scan, 1)) {
+			/* we have no slots, another ret value should be used */
+			goto out;
+		}
+
+		slot = ksm_scan->slot_index;
+		down_read(&slot->mm->mmap_sem);
+		/*
+		 * If the page is swapped out or in swap cache, we don't want to
+		 * scan it (it is just for performance).
+		 */
+		if (is_present_pte(slot->mm, slot->addr +
+				   ksm_scan->page_index * PAGE_SIZE)) {
+			val = get_user_pages(current, slot->mm, slot->addr +
+					     ksm_scan->page_index * PAGE_SIZE ,
+					      1, 0, 0, page, NULL);
+			up_read(&slot->mm->mmap_sem);
+			if (val == 1) {
+				if (!PageKsm(page[0]))
+					max_npages -=
+					cmp_and_merge_page(ksm_scan, page[0]);
+				page_cache_release(page[0]);
+			}
+		} else
+			up_read(&slot->mm->mmap_sem);
+		scan_npages--;
+	}
+
+	scan_get_next_index(ksm_scan, 1);
+out:
+	up_read(&slots_lock);
+	return ret;
+}
+
+static int ksm_scan_ioctl_start(struct ksm_scan *ksm_scan,
+				struct ksm_user_scan *scan)
+{
+	return ksm_scan_start(ksm_scan, scan->pages_to_scan,
+			      scan->max_pages_to_merge);
+}
+
+static int ksm_scan_release(struct inode *inode, struct file *filp)
+{
+	struct ksm_scan *ksm_scan = filp->private_data;
+
+	kfree(ksm_scan);
+	return 0;
+}
+
+static long ksm_scan_ioctl(struct file *filp,
+			   unsigned int ioctl, unsigned long arg)
+{
+	struct ksm_scan *ksm_scan = filp->private_data;
+	void __user *argp = (void __user *)arg;
+	int r = EINVAL;
+
+	switch (ioctl) {
+	case KSM_SCAN: {
+		struct ksm_user_scan scan;
+
+		r = -EFAULT;
+		if (copy_from_user(&scan, argp,
+				   sizeof(struct ksm_user_scan)))
+			break;
+
+		r = ksm_scan_ioctl_start(ksm_scan, &scan);
+	}
+	}
+	return r;
+}
+
+static struct file_operations ksm_sma_fops = {
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
+	if (!ksm_sma)
+		goto out;
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
+static struct file_operations ksm_scan_fops = {
+	.release        = ksm_scan_release,
+	.unlocked_ioctl = ksm_scan_ioctl,
+	.compat_ioctl   = ksm_scan_ioctl,
+};
+
+static struct ksm_scan *ksm_scan_create(void)
+{
+	struct ksm_scan *ksm_scan;
+
+	ksm_scan = kzalloc(sizeof(struct ksm_scan), GFP_KERNEL);
+	return ksm_scan;
+}
+
+static int ksm_dev_ioctl_create_scan(void)
+{
+	int fd;
+	struct ksm_scan *ksm_scan;
+
+	if (!tfm) {
+		fd = ksm_tfm_init();
+		if (fd)
+			goto out;
+	}
+
+	fd = -ENOMEM;
+	ksm_scan = ksm_scan_create();
+	if (!ksm_scan)
+		goto out;
+
+	fd = anon_inode_getfd("ksm-scan", &ksm_scan_fops, ksm_scan, 0);
+	if (fd < 0)
+		goto out_free;
+	return fd;
+
+out_free:
+	kfree(ksm_scan);
+out:
+	return fd;
+}
+
+static int ksm_dev_ioctl_start_stop_kthread(struct ksm_kthread_info *info)
+{
+	int rc = 0;
+
+	/* Make sure crypto tfm is initialized before starting scanning */
+	if (info->running && !tfm) {
+		rc = ksm_tfm_init();
+		if (rc)
+			goto out;
+	}
+
+	down_write(&kthread_lock);
+
+	kthread_sleep = info->sleep;
+	kthread_pages_to_scan = info->pages_to_scan;
+	kthread_max_npages = info->max_pages_to_merge;
+	kthread_run = info->running;
+
+	up_write(&kthread_lock);
+
+	if (kthread_run)
+		wake_up_interruptible(&kthread_wait);
+
+out:
+	return rc;
+}
+
+static int ksm_dev_ioctl_get_info_kthread(struct ksm_kthread_info *info)
+{
+	down_read(&kthread_lock);
+
+	info->sleep = kthread_sleep;
+	info->pages_to_scan = kthread_pages_to_scan;
+	info->max_pages_to_merge = kthread_max_npages;
+	info->running = kthread_run;
+
+	up_read(&kthread_lock);
+	return 0;
+}
+
+static long ksm_dev_ioctl(struct file *filp,
+			  unsigned int ioctl, unsigned long arg)
+{
+	void __user *argp = (void __user *)arg;
+	long r = -EINVAL;
+
+	switch (ioctl) {
+	case KSM_GET_API_VERSION:
+		r = KSM_API_VERSION;
+		break;
+	case KSM_CREATE_SHARED_MEMORY_AREA:
+		r = ksm_dev_ioctl_create_shared_memory_area();
+		break;
+	case KSM_CREATE_SCAN:
+		r = ksm_dev_ioctl_create_scan();
+		break;
+	case KSM_START_STOP_KTHREAD: {
+		struct ksm_kthread_info info;
+
+		r = -EFAULT;
+		if (copy_from_user(&info, argp,
+				   sizeof(struct ksm_kthread_info)))
+			break;
+
+		r = ksm_dev_ioctl_start_stop_kthread(&info);
+		break;
+		}
+	case KSM_GET_INFO_KTHREAD: {
+		struct ksm_kthread_info info;
+
+		r = ksm_dev_ioctl_get_info_kthread(&info);
+		if (r)
+			break;
+		r = -EFAULT;
+		if (copy_to_user(argp, &info,
+				 sizeof(struct ksm_kthread_info)))
+			break;
+		r = 0;
+	}
+	default:
+		return r;
+	}
+	return r;
+}
+
+static int ksm_dev_open(struct inode *inode, struct file *filp)
+{
+	try_module_get(THIS_MODULE);
+	return 0;
+}
+
+static int ksm_dev_release(struct inode *inode, struct file *filp)
+{
+	module_put(THIS_MODULE);
+	return 0;
+}
+
+static struct file_operations ksm_chardev_ops = {
+	.open           = ksm_dev_open,
+	.release        = ksm_dev_release,
+	.unlocked_ioctl = ksm_dev_ioctl,
+	.compat_ioctl   = ksm_dev_ioctl,
+};
+
+static struct miscdevice ksm_dev = {
+	KSM_MINOR,
+	"ksm",
+	&ksm_chardev_ops,
+};
+
+int kthread_ksm_scan_thread(void *nothing)
+{
+	while (!kthread_should_stop()) {
+		if(kthread_run) {
+			down_read(&kthread_lock);
+			ksm_scan_start(&kthread_ksm_scan,
+				       kthread_pages_to_scan,
+				       kthread_max_npages);
+			up_read(&kthread_lock);
+			schedule_timeout_interruptible(usecs_to_jiffies(kthread_sleep));
+		} else
+			wait_event_interruptible(kthread_wait, kthread_run);
+	}
+	return 0;
+}
+
+static int __init ksm_init(void)
+{
+	int r = 1;
+
+	r = ksm_slab_init();
+	if (r)
+		goto out;
+
+	r = page_hash_init();
+	if (r)
+		goto out_free1;
+
+	r = rmap_hash_init();
+	if (r)
+		goto out_free2;
+
+	r = sha1_hash_init();
+	if (r)
+		goto out_free3;
+
+	INIT_LIST_HEAD(&slots);
+	init_rwsem(&slots_lock);
+	spin_lock_init(&hash_lock);
+	init_rwsem(&kthread_lock);
+	init_waitqueue_head(&kthread_wait);
+
+	kthread = kthread_run(kthread_ksm_scan_thread, NULL, "kksmd");
+	if (IS_ERR(kthread)) {
+		printk(KERN_ERR "ksm: creating kthread failed\n");
+		goto out_free4;
+	}
+
+	r = misc_register(&ksm_dev);
+	if (r) {
+		printk(KERN_ERR "ksm: misc device register failed\n");
+		goto out_free5;
+	}
+
+	printk(KERN_WARNING "ksm loaded\n");
+	return 0;
+
+out_free5:
+	kthread_stop(kthread);
+out_free4:
+	sha1_hash_free();
+out_free3:
+	rmap_hash_free();
+out_free2:
+	page_hash_free();
+out_free1:
+	ksm_slab_free();
+out:
+	return r;
+}
+
+static void __exit ksm_exit(void)
+{
+	misc_deregister(&ksm_dev);
+	kthread_run = 1;
+	kthread_stop(kthread);
+	if (tfm)
+		crypto_free_hash(tfm);
+	sha1_hash_free();
+	rmap_hash_free();
+	page_hash_free();
+	ksm_slab_free();
+}
+
+module_init(ksm_init)
+module_exit(ksm_exit)
-- 
1.6.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
