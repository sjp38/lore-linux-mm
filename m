Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0FF506B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 08:26:23 -0400 (EDT)
Message-ID: <49D20AE1.4060802@redhat.com>
Date: Tue, 31 Mar 2009 15:21:53 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
References: <1238457560-7613-1-git-send-email-ieidus@redhat.com>	<1238457560-7613-2-git-send-email-ieidus@redhat.com>	<1238457560-7613-3-git-send-email-ieidus@redhat.com>	<1238457560-7613-4-git-send-email-ieidus@redhat.com>	<1238457560-7613-5-git-send-email-ieidus@redhat.com> <20090331111510.dbb712d2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090331111510.dbb712d2.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 31 Mar 2009 02:59:20 +0300
> Izik Eidus <ieidus@redhat.com> wrote:
>
>   
>> Ksm is driver that allow merging identical pages between one or more
>> applications in way unvisible to the application that use it.
>> Pages that are merged are marked as readonly and are COWed when any
>> application try to change them.
>>
>> Ksm is used for cases where using fork() is not suitable,
>> one of this cases is where the pages of the application keep changing
>> dynamicly and the application cannot know in advance what pages are
>> going to be identical.
>>
>> Ksm works by walking over the memory pages of the applications it
>> scan in order to find identical pages.
>> It uses a two sorted data strctures called stable and unstable trees
>> to find in effective way the identical pages.
>>
>> When ksm finds two identical pages, it marks them as readonly and merges
>> them into single one page,
>> after the pages are marked as readonly and merged into one page, linux
>> will treat this pages as normal copy_on_write pages and will fork them
>> when write access will happen to them.
>>
>> Ksm scan just memory areas that were registred to be scanned by it.
>>
>> Ksm api:
>>
>> KSM_GET_API_VERSION:
>> Give the userspace the api version of the module.
>>
>> KSM_CREATE_SHARED_MEMORY_AREA:
>> Create shared memory reagion fd, that latter allow the user to register
>> the memory region to scan by using:
>> KSM_REGISTER_MEMORY_REGION and KSM_REMOVE_MEMORY_REGION
>>
>> KSM_START_STOP_KTHREAD:
>> Return information about the kernel thread, the inforamtion is returned
>> using the ksm_kthread_info structure:
>> ksm_kthread_info:
>> __u32 sleep:
>>         number of microsecoends to sleep between each iteration of
>> scanning.
>>
>> __u32 pages_to_scan:
>>         number of pages to scan for each iteration of scanning.
>>
>> __u32 max_pages_to_merge:
>>         maximum number of pages to merge in each iteration of scanning
>>         (so even if there are still more pages to scan, we stop this
>> iteration)
>>
>> __u32 flags:
>>        flags to control ksmd (right now just ksm_control_flags_run
>> 			      available)
>>
>> KSM_REGISTER_MEMORY_REGION:
>> Register userspace virtual address range to be scanned by ksm.
>> This ioctl is using the ksm_memory_region structure:
>> ksm_memory_region:
>> __u32 npages;
>>          number of pages to share inside this memory region.
>> __u32 pad;
>> __u64 addr:
>>         the begining of the virtual address of this region.
>>
>> KSM_REMOVE_MEMORY_REGION:
>> Remove memory region from ksm.
>>
>> Signed-off-by: Izik Eidus <ieidus@redhat.com>
>> ---
>>  include/linux/ksm.h        |   69 +++
>>  include/linux/miscdevice.h |    1 +
>>  mm/Kconfig                 |    6 +
>>  mm/Makefile                |    1 +
>>  mm/ksm.c                   | 1431 ++++++++++++++++++++++++++++++++++++++++++++
>>  5 files changed, 1508 insertions(+), 0 deletions(-)
>>  create mode 100644 include/linux/ksm.h
>>  create mode 100644 mm/ksm.c
>>
>> diff --git a/include/linux/ksm.h b/include/linux/ksm.h
>> new file mode 100644
>> index 0000000..5776dce
>> --- /dev/null
>> +++ b/include/linux/ksm.h
>> @@ -0,0 +1,69 @@
>> +#ifndef __LINUX_KSM_H
>> +#define __LINUX_KSM_H
>> +
>> +/*
>> + * Userspace interface for /dev/ksm - kvm shared memory
>> + */
>> +
>> +#include <linux/types.h>
>> +#include <linux/ioctl.h>
>> +
>> +#include <asm/types.h>
>> +
>> +#define KSM_API_VERSION 1
>> +
>> +#define ksm_control_flags_run 1
>> +
>> +/* for KSM_REGISTER_MEMORY_REGION */
>> +struct ksm_memory_region {
>> +	__u32 npages; /* number of pages to share */
>> +	__u32 pad;
>> +	__u64 addr; /* the begining of the virtual address */
>> +        __u64 reserved_bits;
>> +};
>> +
>> +struct ksm_kthread_info {
>> +	__u32 sleep; /* number of microsecoends to sleep */
>> +	__u32 pages_to_scan; /* number of pages to scan */
>> +	__u32 flags; /* control flags */
>> +        __u32 pad;
>> +        __u64 reserved_bits;
>> +};
>> +
>> +#define KSMIO 0xAB
>> +
>> +/* ioctls for /dev/ksm */
>> +
>> +#define KSM_GET_API_VERSION              _IO(KSMIO,   0x00)
>> +/*
>> + * KSM_CREATE_SHARED_MEMORY_AREA - create the shared memory reagion fd
>> + */
>> +#define KSM_CREATE_SHARED_MEMORY_AREA    _IO(KSMIO,   0x01) /* return SMA fd */
>> +/*
>> + * KSM_START_STOP_KTHREAD - control the kernel thread scanning speed
>> + * (can stop the kernel thread from working by setting running = 0)
>> + */
>> +#define KSM_START_STOP_KTHREAD		 _IOW(KSMIO,  0x02,\
>> +					      struct ksm_kthread_info)
>> +/*
>> + * KSM_GET_INFO_KTHREAD - return information about the kernel thread
>> + * scanning speed.
>> + */
>> +#define KSM_GET_INFO_KTHREAD		 _IOW(KSMIO,  0x03,\
>> +					      struct ksm_kthread_info)
>> +
>> +
>> +/* ioctls for SMA fds */
>> +
>> +/*
>> + * KSM_REGISTER_MEMORY_REGION - register virtual address memory area to be
>> + * scanned by kvm.
>> + */
>> +#define KSM_REGISTER_MEMORY_REGION       _IOW(KSMIO,  0x20,\
>> +					      struct ksm_memory_region)
>> +/*
>> + * KSM_REMOVE_MEMORY_REGION - remove virtual address memory area from ksm.
>> + */
>> +#define KSM_REMOVE_MEMORY_REGION         _IO(KSMIO,   0x21)
>> +
>> +#endif
>> diff --git a/include/linux/miscdevice.h b/include/linux/miscdevice.h
>> index a820f81..6d4f8df 100644
>> --- a/include/linux/miscdevice.h
>> +++ b/include/linux/miscdevice.h
>> @@ -29,6 +29,7 @@
>>  #define HPET_MINOR		228
>>  #define FUSE_MINOR		229
>>  #define KVM_MINOR		232
>> +#define KSM_MINOR		233
>>  #define MISC_DYNAMIC_MINOR	255
>>  
>>  struct device;
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index a5b7781..2818223 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -216,3 +216,9 @@ config UNEVICTABLE_LRU
>>  
>>  config MMU_NOTIFIER
>>  	bool
>> +
>> +config KSM
>> +	tristate "Enable KSM for page sharing"
>> +	help
>> +	  Enable the KSM kernel module to allow page sharing of equal pages
>> +	  among different tasks.
>> diff --git a/mm/Makefile b/mm/Makefile
>> index 72255be..e3bf7bf 100644
>> --- a/mm/Makefile
>> +++ b/mm/Makefile
>> @@ -24,6 +24,7 @@ obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
>>  obj-$(CONFIG_TMPFS_POSIX_ACL) += shmem_acl.o
>>  obj-$(CONFIG_SLOB) += slob.o
>>  obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
>> +obj-$(CONFIG_KSM) += ksm.o
>>  obj-$(CONFIG_SLAB) += slab.o
>>  obj-$(CONFIG_SLUB) += slub.o
>>  obj-$(CONFIG_FAILSLAB) += failslab.o
>> diff --git a/mm/ksm.c b/mm/ksm.c
>> new file mode 100644
>> index 0000000..eba4c09
>> --- /dev/null
>> +++ b/mm/ksm.c
>> @@ -0,0 +1,1431 @@
>> +/*
>> + * Memory merging driver for Linux
>> + *
>> + * This module enables dynamic sharing of identical pages found in different
>> + * memory areas, even if they are not shared by fork()
>> + *
>> + * Copyright (C) 2008 Red Hat, Inc.
>> + * Authors:
>> + *	Izik Eidus
>> + *	Andrea Arcangeli
>> + *	Chris Wright
>> + *
>> + * This work is licensed under the terms of the GNU GPL, version 2.
>> + */
>> +
>> +#include <linux/module.h>
>> +#include <linux/errno.h>
>> +#include <linux/mm.h>
>> +#include <linux/fs.h>
>> +#include <linux/miscdevice.h>
>> +#include <linux/vmalloc.h>
>> +#include <linux/file.h>
>> +#include <linux/mman.h>
>> +#include <linux/sched.h>
>> +#include <linux/rwsem.h>
>> +#include <linux/pagemap.h>
>> +#include <linux/sched.h>
>> +#include <linux/rmap.h>
>> +#include <linux/spinlock.h>
>> +#include <linux/jhash.h>
>> +#include <linux/delay.h>
>> +#include <linux/kthread.h>
>> +#include <linux/wait.h>
>> +#include <linux/scatterlist.h>
>> +#include <linux/random.h>
>> +#include <linux/slab.h>
>> +#include <linux/swap.h>
>> +#include <linux/rbtree.h>
>> +#include <linux/anon_inodes.h>
>> +#include <linux/ksm.h>
>> +
>> +#include <asm/tlbflush.h>
>> +
>> +MODULE_AUTHOR("Red Hat, Inc.");
>> +MODULE_LICENSE("GPL");
>> +
>> +static int rmap_hash_size;
>> +module_param(rmap_hash_size, int, 0);
>> +MODULE_PARM_DESC(rmap_hash_size, "Hash table size for the reverse mapping");
>> +
>> +/*
>> + * ksm_mem_slot - hold information for an userspace scanning range
>> + * (the scanning for this region will be from addr untill addr +
>> + *  npages * PAGE_SIZE inside mm)
>> + */
>> +struct ksm_mem_slot {
>> +	struct list_head link;
>> +	struct list_head sma_link;
>> +	struct mm_struct *mm;
>> +	unsigned long addr;	/* the begining of the virtual address */
>> +	unsigned npages;	/* number of pages to share */
>> +};
>> +
>> +/*
>> + * ksm_sma - shared memory area, each process have its own sma that contain the
>> + * information about the slots that it own
>> + */
>> +struct ksm_sma {
>> +	struct list_head sma_slots;
>> +};
>> +
>> +/**
>> + * struct ksm_scan - cursor for scanning
>> + * @slot_index: the current slot we are scanning
>> + * @page_index: the page inside the sma that is currently being scanned
>> + *
>> + * ksm uses it to know what are the next pages it need to scan
>> + */
>> +struct ksm_scan {
>> +	struct ksm_mem_slot *slot_index;
>> +	unsigned long page_index;
>> +};
>> +
>> +/*
>> + * Few notes about ksm scanning progress (make it easier to understand the
>> + * data structures below):
>> + *
>> + * In order to reduce excessive scanning, ksm sort the memory pages by their
>> + * contents into a data strcture that hold pointer into the pages.
>> + *
>> + * Since the contents of the pages may change at any moment, ksm cant just
>> + * insert the pages into normal sorted tree and expect it to find anything.
>> + *
>> + * For this purpuse ksm use two data strctures - stable and unstable trees,
>> + * the stable tree hold pointers into all the merged pages (KsmPage) sorted by
>> + * their contents, beacuse that each such page have to be write-protected,
>> + * searching on this tree is fully assuranced to be working and therefore this
>> + * tree is called the stable tree.
>> + *
>> + * In addition to the stable tree, ksm use another data strcture called the
>> + * unstable tree, this specific tree hold pointers into pages that have
>> + * been found to be "unchanged for period of time", the unstable tree sort this
>> + * pages by their contents, but given the fact that this pages are not
>> + * write-protected, ksm cant trust the unstable tree to be fully assuranced to
>> + * work.
>> + * For the reason that the unstable tree would become corrupted when some of
>> + * the page inside itself would change, the tree is called unstable.
>> + * Ksm solve this problem by two ways:
>> + * 1) the unstable tree get flushed every time ksm finish to scan the whole
>> + *    memory, and then the tree is rebuild from the begining.
>> + * 2) Ksm will only insert into the unstable tree, pages that their hash value
>> + *    was not changed during the whole progress of one circuler scanning of the
>> + *    memory.
>> + * 3) The unstable tree is RedBlack Tree - meaning its balancing is based on
>> + *    the colors of the nodes and not their content, this assure that even when
>> + *    the tree get "corrupted" we wont get out of balance and the timing of
>> + *    scanning is the same, another issue is that searching and inserting nodes
>> + *    into rbtree is the same algorithem, therefore we have no overhead when we
>> + *    flush the tree and rebuild it.
>> + * 4) Ksm never flush the stable tree, this mean that even if it would take 10
>> + *    times to find page inside the unstable tree, as soon as we would find it,
>> + *    it will be secured inside the stable tree,
>> + *    (When we scan new page, we first compare it against the stable tree, and
>> + *     then against the unstable tree)
>> + */
>> +
>> +struct rmap_item;
>> +
>> +/*
>> + * tree_item - object of the stable and unstable trees
>> + */
>> +struct tree_item {
>> +	struct rb_node node;
>> +	struct rmap_item *rmap_item;
>> +};
>> +
>> +/*
>> + * rmap_item - object of the rmap_hash hash table
>> + * (it is holding the previous hash value (oldindex),
>> + *  pointer into the page_hash_item, and pointer into the tree_item)
>> + */
>> +
>> +/**
>> + * struct rmap_item - reverse mapping item for virtual addresses
>> + * @link: link into the rmap_hash hash table.
>> + * @mm: the memory strcture the rmap_item is pointing to.
>> + * @address: the virtual address the rmap_item is pointing to.
>> + * @oldchecksum: old checksum result for the page belong the virtual address
>> + * @stable_tree: when 1 rmap_item is used for stable_tree, 0 unstable tree
>> + * @tree_item: pointer into the stable/unstable tree that hold the virtual
>> + *             address that the rmap_item is pointing to.
>> + * @next: the next rmap item inside the stable/unstable tree that have that is
>> + *        found inside the same tree node.
>> + */
>> +
>> +struct rmap_item {
>> +	struct hlist_node link;
>> +	struct mm_struct *mm;
>> +	unsigned long address;
>> +	unsigned int oldchecksum; /* old checksum value */
>> +	unsigned char stable_tree; /* 1 stable_tree 0 unstable tree */
>> +	struct tree_item *tree_item;
>> +	struct rmap_item *next;
>> +	struct rmap_item *prev;
>> +};
>> +
>> +/*
>> + * slots is linked list that hold all the memory regions that were registred
>> + * to be scanned.
>> + */
>> +static LIST_HEAD(slots);
>> +/*
>> + * slots_lock protect against removing and adding memory regions while a scanner
>> + * is in the middle of scanning.
>> + */
>> +static DECLARE_RWSEM(slots_lock);
>> +
>> +/* The stable and unstable trees heads. */
>> +struct rb_root root_stable_tree = RB_ROOT;
>> +struct rb_root root_unstable_tree = RB_ROOT;
>> +
>> +
>> +/* The number of linked list members inside the hash table */
>> +static int nrmaps_hash;
>> +/* rmap_hash hash table */
>> +static struct hlist_head *rmap_hash;
>> +
>> +static struct kmem_cache *tree_item_cache;
>> +static struct kmem_cache *rmap_item_cache;
>> +
>> +static int kthread_sleep; /* sleep time of the kernel thread */
>> +static int kthread_pages_to_scan; /* npages to scan for the kernel thread */
>> +static struct ksm_scan kthread_ksm_scan;
>> +static int ksmd_flags;
>> +static struct task_struct *kthread;
>> +static DECLARE_WAIT_QUEUE_HEAD(kthread_wait);
>> +static DECLARE_RWSEM(kthread_lock);
>> +
>> +static int ksm_slab_init(void)
>> +{
>> +	int ret = -ENOMEM;
>> +
>> +	tree_item_cache = KMEM_CACHE(tree_item, 0);
>> +	if (!tree_item_cache)
>> +		goto out;
>> +
>> +	rmap_item_cache = KMEM_CACHE(rmap_item, 0);
>> +	if (!rmap_item_cache)
>> +		goto out_free;
>> +
>> +	return 0;
>> +
>> +out_free:
>> +	kmem_cache_destroy(tree_item_cache);
>> +out:
>> +	return ret;
>> +}
>> +
>> +static void ksm_slab_free(void)
>> +{
>> +	kmem_cache_destroy(rmap_item_cache);
>> +	kmem_cache_destroy(tree_item_cache);
>> +}
>> +
>> +static inline struct tree_item *alloc_tree_item(void)
>> +{
>> +	return kmem_cache_zalloc(tree_item_cache, GFP_KERNEL);
>> +}
>> +
>> +static void free_tree_item(struct tree_item *tree_item)
>> +{
>> +	kmem_cache_free(tree_item_cache, tree_item);
>> +}
>> +
>> +static inline struct rmap_item *alloc_rmap_item(void)
>> +{
>> +	return kmem_cache_zalloc(rmap_item_cache, GFP_KERNEL);
>> +}
>> +
>> +static inline void free_rmap_item(struct rmap_item *rmap_item)
>> +{
>> +	kmem_cache_free(rmap_item_cache, rmap_item);
>> +}
>> +
>> +/*
>> + * PageKsm - this type of pages are the write protected pages that ksm map
>> + * into multiple vmas (this is the "shared page")
>> + * this page was allocated using alloc_page(), and every pte that point to it
>> + * is always write protected (therefore its data content cant ever be changed)
>> + * and this page cant be swapped.
>> + */
>> +static inline int PageKsm(struct page *page)
>> +{
>> +	/*
>> +	 * When ksm create new shared page, it create kernel allocated page
>> +	 * using alloc_page(), therefore this page is not anonymous, taking into
>> +         * account that ksm scan just anonymous pages, we can relay on the fact
>> +	 * that each time we see !PageAnon(page) we are hitting shared page.
>> +	 */
>> +	return !PageAnon(page);
>> +}
>> +
>> +static int rmap_hash_init(void)
>> +{
>> +	if (!rmap_hash_size) {
>> +		struct sysinfo sinfo;
>> +
>> +		si_meminfo(&sinfo);
>> +		rmap_hash_size = sinfo.totalram / 10;
>> +	}
>> +	nrmaps_hash = rmap_hash_size;
>> +	rmap_hash = vmalloc(nrmaps_hash * sizeof(struct hlist_head));
>> +	if (!rmap_hash)
>> +		return -ENOMEM;
>> +	memset(rmap_hash, 0, nrmaps_hash * sizeof(struct hlist_head));
>> +	return 0;
>> +}
>> +
>> +static void rmap_hash_free(void)
>> +{
>> +	int i;
>> +	struct hlist_head *bucket;
>> +	struct hlist_node *node, *n;
>> +	struct rmap_item *rmap_item;
>> +
>> +	for (i = 0; i < nrmaps_hash; ++i) {
>> +		bucket = &rmap_hash[i];
>> +		hlist_for_each_entry_safe(rmap_item, node, n, bucket, link) {
>> +			hlist_del(&rmap_item->link);
>> +			free_rmap_item(rmap_item);
>> +		}
>> +	}
>> +	vfree(rmap_hash);
>> +}
>> +
>> +static inline u32 calc_checksum(struct page *page)
>> +{
>> +	u32 checksum;
>> +	void *addr = kmap_atomic(page, KM_USER0);
>> +	checksum = jhash(addr, PAGE_SIZE, 17);
>> +	kunmap_atomic(addr, KM_USER0);
>> +	return checksum;
>> +}
>> +
>> +/*
>> + * Return rmap_item for a given virtual address.
>> + */
>> +static struct rmap_item *get_rmap_item(struct mm_struct *mm, unsigned long addr)
>> +{
>> +	struct rmap_item *rmap_item;
>> +	struct hlist_head *bucket;
>> +	struct hlist_node *node;
>> +
>> +	bucket = &rmap_hash[addr % nrmaps_hash];
>> +	hlist_for_each_entry(rmap_item, node, bucket, link) {
>> +		if (mm == rmap_item->mm && rmap_item->address == addr) {
>> +			return rmap_item;
>> +		}
>> +	}
>> +	return NULL;
>> +}
>> +
>> +/*
>> + * Removing rmap_item from stable or unstable tree.
>> + * This function will free the rmap_item object, and if that rmap_item was
>> + * insde the stable or unstable trees, it would remove the link from there
>> + * as well.
>> + */
>> +static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
>> +{
>> +	struct tree_item *tree_item;
>> +
>> +	tree_item = rmap_item->tree_item;
>> +	rmap_item->tree_item = NULL;
>> +
>> +	if (rmap_item->stable_tree) {
>> +		if (rmap_item->prev) {
>> +			BUG_ON(rmap_item->prev->next != rmap_item);
>> +			rmap_item->prev->next = rmap_item->next;
>> +		}
>> +		if (rmap_item->next) {
>> +			BUG_ON(rmap_item->next->prev != rmap_item);
>> +			rmap_item->next->prev = rmap_item->prev;
>> +		}
>> +	}
>> +
>> +	if (tree_item) {
>> +		if (rmap_item->stable_tree) {
>> +	 		if (!rmap_item->next && !rmap_item->prev) {
>> +				rb_erase(&tree_item->node, &root_stable_tree);
>> +				free_tree_item(tree_item);
>> +			} else if (!rmap_item->prev) {
>> +				tree_item->rmap_item = rmap_item->next;
>> +			} else {
>> +				tree_item->rmap_item = rmap_item->prev;
>> +			}
>> +		} else if (!rmap_item->stable_tree) {
>> +			free_tree_item(tree_item);
>> +		}
>> +	}
>> +
>> +	hlist_del(&rmap_item->link);
>> +	free_rmap_item(rmap_item);
>> +}
>> +
>> +static void remove_page_from_tree(struct mm_struct *mm,
>> +				  unsigned long addr)
>> +{
>> +	struct rmap_item *rmap_item;
>> +
>> +	rmap_item = get_rmap_item(mm, addr);
>> +	if (!rmap_item)
>> +		return;
>> +	remove_rmap_item_from_tree(rmap_item);
>> +	return;
>> +}
>> +
>> +static int ksm_sma_ioctl_register_memory_region(struct ksm_sma *ksm_sma,
>> +						struct ksm_memory_region *mem)
>> +{
>> +	struct ksm_mem_slot *slot;
>> +	int ret = -EPERM;
>> +
>> +	slot = kzalloc(sizeof(struct ksm_mem_slot), GFP_KERNEL);
>> +	if (!slot) {
>> +		ret = -ENOMEM;
>> +		goto out;
>> +	}
>> +
>> +	slot->mm = get_task_mm(current);
>> +	if (!slot->mm)
>> +		goto out_free;
>> +	slot->addr = mem->addr;
>> +	slot->npages = mem->npages;
>> +
>> +	down_write(&slots_lock);
>> +
>> +	list_add_tail(&slot->link, &slots);
>> +	list_add_tail(&slot->sma_link, &ksm_sma->sma_slots);
>> +
>> +	up_write(&slots_lock);
>> +	return 0;
>> +
>> +out_free:
>> +	kfree(slot);
>> +out:
>> +	return ret;
>> +}
>> +
>> +static void remove_mm_from_hash_and_tree(struct mm_struct *mm)
>> +{
>> +	struct ksm_mem_slot *slot;
>> +	int pages_count;
>> +
>> +	list_for_each_entry(slot, &slots, link)
>> +		if (slot->mm == mm)
>> +			break;
>> +	BUG_ON(!slot);
>> +
>> +	root_unstable_tree = RB_ROOT;
>> +	for (pages_count = 0; pages_count < slot->npages; ++pages_count)
>> +		remove_page_from_tree(mm, slot->addr +
>> +				      pages_count * PAGE_SIZE);
>> +	list_del(&slot->link);
>> +}
>> +
>> +static int ksm_sma_ioctl_remove_memory_region(struct ksm_sma *ksm_sma)
>> +{
>> +	struct ksm_mem_slot *slot, *node;
>> +
>> +	down_write(&slots_lock);
>> +	list_for_each_entry_safe(slot, node, &ksm_sma->sma_slots, sma_link) {
>> +		remove_mm_from_hash_and_tree(slot->mm);
>> +		mmput(slot->mm);
>> +		list_del(&slot->sma_link);
>> +		kfree(slot);
>> +	}
>> +	up_write(&slots_lock);
>> +	return 0;
>> +}
>> +
>> +static int ksm_sma_release(struct inode *inode, struct file *filp)
>> +{
>> +	struct ksm_sma *ksm_sma = filp->private_data;
>> +	int r;
>> +
>> +	r = ksm_sma_ioctl_remove_memory_region(ksm_sma);
>> +	kfree(ksm_sma);
>> +	return r;
>> +}
>> +
>> +static long ksm_sma_ioctl(struct file *filp,
>> +			  unsigned int ioctl, unsigned long arg)
>> +{
>> +	struct ksm_sma *sma = filp->private_data;
>> +	void __user *argp = (void __user *)arg;
>> +	int r = EINVAL;
>> +
>> +	switch (ioctl) {
>> +	case KSM_REGISTER_MEMORY_REGION: {
>> +		struct ksm_memory_region ksm_memory_region;
>> +
>> +		r = -EFAULT;
>> +		if (copy_from_user(&ksm_memory_region, argp,
>> +				   sizeof(ksm_memory_region)))
>> +			goto out;
>> +		r = ksm_sma_ioctl_register_memory_region(sma,
>> +							 &ksm_memory_region);
>> +		break;
>> +	}
>> +	case KSM_REMOVE_MEMORY_REGION:
>> +		r = ksm_sma_ioctl_remove_memory_region(sma);
>> +		break;
>> +	}
>> +
>> +out:
>> +	return r;
>> +}
>> +
>> +static unsigned long addr_in_vma(struct vm_area_struct *vma, struct page *page)
>> +{
>> +	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
>> +	unsigned long addr;
>> +
>> +	addr = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
>> +	if (unlikely(addr < vma->vm_start || addr >= vma->vm_end))
>> +		return -EFAULT;
>> +	return addr;
>> +}
>> +
>> +static pte_t *get_pte(struct mm_struct *mm, unsigned long addr)
>> +{
>> +	pgd_t *pgd;
>> +	pud_t *pud;
>> +	pmd_t *pmd;
>> +	pte_t *ptep = NULL;
>> +
>> +	pgd = pgd_offset(mm, addr);
>> +	if (!pgd_present(*pgd))
>> +		goto out;
>> +
>> +	pud = pud_offset(pgd, addr);
>> +	if (!pud_present(*pud))
>> +		goto out;
>> +
>> +	pmd = pmd_offset(pud, addr);
>> +	if (!pmd_present(*pmd))
>> +		goto out;
>> +
>> +	ptep = pte_offset_map(pmd, addr);
>> +out:
>> +	return ptep;
>> +}
>> +
>> +static int is_present_pte(struct mm_struct *mm, unsigned long addr)
>> +{
>> +	pte_t *ptep;
>> +	int r;
>> +
>> +	ptep = get_pte(mm, addr);
>> +	if (!ptep)
>> +		return 0;
>> +
>> +	r = pte_present(*ptep);
>> +	pte_unmap(ptep);
>> +
>> +	return r;
>> +}
>> +
>> +static int memcmp_pages(struct page *page1, struct page *page2)
>> +{
>> +	char *addr1, *addr2;
>> +	int r;
>> +
>> +	addr1 = kmap_atomic(page1, KM_USER0);
>> +	addr2 = kmap_atomic(page2, KM_USER1);
>> +	r = memcmp(addr1, addr2, PAGE_SIZE);
>> +	kunmap_atomic(addr1, KM_USER0);
>> +	kunmap_atomic(addr2, KM_USER1);
>> +	return r;
>> +}
>> +
>> +/* pages_identical
>> + * return 1 if identical, 0 otherwise.
>> + */
>> +static inline int pages_identical(struct page *page1, struct page *page2)
>> +{
>> +	return !memcmp_pages(page1, page2);
>> +}
>> +
>> +/*
>> + * try_to_merge_one_page - take two pages and merge them into one
>> + * @mm: mm_struct that hold vma pointing into oldpage
>> + * @vma: the vma that hold the pte pointing into oldpage
>> + * @oldpage: the page that we want to replace with newpage
>> + * @newpage: the page that we want to map instead of oldpage
>> + * @newprot: the new permission of the pte inside vma
>> + * note:
>> + * oldpage should be anon page while newpage should be file mapped page
>> + *
>> + * this function return 0 if the pages were merged, 1 otherwise.
>> + */
>> +static int try_to_merge_one_page(struct mm_struct *mm,
>> +				 struct vm_area_struct *vma,
>> +				 struct page *oldpage,
>> +				 struct page *newpage,
>> +				 pgprot_t newprot)
>> +{
>> +	int ret = 1;
>> +	int odirect_sync;
>> +	unsigned long page_addr_in_vma;
>> +	pte_t orig_pte, *orig_ptep;
>> +
>> +	get_page(newpage);
>> +	get_page(oldpage);
>> +
>> +	down_read(&mm->mmap_sem);
>> +
>> +	page_addr_in_vma = addr_in_vma(vma, oldpage);
>> +	if (page_addr_in_vma == -EFAULT)
>> +		goto out_unlock;
>> +
>> +	orig_ptep = get_pte(mm, page_addr_in_vma);
>> +	if (!orig_ptep)
>> +		goto out_unlock;
>> +	orig_pte = *orig_ptep;
>> +	pte_unmap(orig_ptep);
>> +	if (!pte_present(orig_pte))
>> +		goto out_unlock;
>> +	if (page_to_pfn(oldpage) != pte_pfn(orig_pte))
>> +		goto out_unlock;
>> +	/*
>> +	 * we need the page lock to read a stable PageSwapCache in
>> +	 * page_wrprotect()
>> +	 */
>> +	if (!trylock_page(oldpage))
>> +		goto out_unlock;
>> +	/*
>> +	 * page_wrprotect check if the page is swapped or in swap cache,
>> +	 * in the future we might want to run here if_present_pte and then
>> +	 * swap_free
>> +	 */
>> +	if (!page_wrprotect(oldpage, &odirect_sync, 2)) {
>> +		unlock_page(oldpage);
>> +		goto out_unlock;
>> +	}
>> +	unlock_page(oldpage);
>> +	if (!odirect_sync)
>> +		goto out_unlock;
>> +
>> +	orig_pte = pte_wrprotect(orig_pte);
>> +
>> +	if (pages_identical(oldpage, newpage))
>> +		ret = replace_page(vma, oldpage, newpage, orig_pte, newprot);
>> +
>> +out_unlock:
>> +	up_read(&mm->mmap_sem);
>> +	put_page(oldpage);
>> +	put_page(newpage);
>> +	return ret;
>> +}
>> +
>> +/*
>> + * try_to_merge_two_pages - take two identical pages and prepare them to be
>> + * merged into one page.
>> + *
>> + * this function return 0 if we successfully mapped two identical pages into one
>> + * page, 1 otherwise.
>> + * (note in case we created KsmPage and mapped one page into it but the second
>> + *  page was not mapped we consider it as a failure and return 1)
>> + */
>> +static int try_to_merge_two_pages(struct mm_struct *mm1, struct page *page1,
>> +				  struct mm_struct *mm2, struct page *page2,
>> +				  unsigned long addr1, unsigned long addr2)
>> +{
>> +	struct vm_area_struct *vma;
>> +	pgprot_t prot;
>> +	int ret = 1;
>> +
>> +	/*
>> +	 * If page2 isn't shared (it isn't PageKsm) we have to allocate a new
>> +	 * file mapped page and make the two ptes of mm1(page1) and mm2(page2)
>> +	 * point to it.  If page2 is shared, we can just make the pte of
>> +	 * mm1(page1) point to page2
>> +	 */
>> +	if (PageKsm(page2)) {
>> +		down_read(&mm1->mmap_sem);
>> +		vma = find_vma(mm1, addr1);
>> +		up_read(&mm1->mmap_sem);
>> +		if (!vma)
>> +			return ret;
>> +		prot = vma->vm_page_prot;
>> +		pgprot_val(prot) &= ~_PAGE_RW;
>> +		ret = try_to_merge_one_page(mm1, vma, page1, page2, prot);
>> +	} else {
>> +		struct page *kpage;
>> +
>> +		kpage = alloc_page(GFP_HIGHUSER);
>> +		if (!kpage)
>> +			return ret;
>> +		down_read(&mm1->mmap_sem);
>> +		vma = find_vma(mm1, addr1);
>> +		up_read(&mm1->mmap_sem);
>> +		if (!vma) {
>> +			put_page(kpage);
>> +			return ret;
>> +		}
>> +		prot = vma->vm_page_prot;
>> +		pgprot_val(prot) &= ~_PAGE_RW;
>> +
>> +		copy_user_highpage(kpage, page1, addr1, vma);
>> +		ret = try_to_merge_one_page(mm1, vma, page1, kpage, prot);
>> +
>> +		if (!ret) {
>> +			down_read(&mm2->mmap_sem);
>> +			vma = find_vma(mm2, addr2);
>> +			up_read(&mm2->mmap_sem);
>> +			if (!vma) {
>> +				put_page(kpage);
>> +				ret = 1;
>> +				return ret;
>> +			}
>> +
>> +			prot = vma->vm_page_prot;
>> +			pgprot_val(prot) &= ~_PAGE_RW;
>> +
>> +			ret = try_to_merge_one_page(mm2, vma, page2, kpage,
>> +						    prot);
>> +			/*
>> +			 * If the secoend try_to_merge_one_page call was failed,
>> +			 * we are in situation where we have Ksm page that have
>> +			 * just one pte pointing to it, in this case we break
>> +			 * it.
>> +			 */
>> +			if (ret) {
>> +				struct page *tmppage[1];
>> +
>> +				down_read(&mm1->mmap_sem);
>> +				if (get_user_pages(current, mm1, addr1, 1, 1,
>> +						    0, tmppage, NULL)) {
>> +					put_page(tmppage[0]);
>> +				}
>> +				up_read(&mm1->mmap_sem);
>> +			}
>> +		}
>> +		put_page(kpage);
>> +	}
>> +	return ret;
>> +}
>>     
>
> I'm sorry if I'm wrong. Is the above "kpage" is free from global LRU and never be
> reclaimed(swapped-out) by global LRU ?
>   
kpage is actually what going to be KsmPage -> the shared page...

Right now this pages are not swappable..., after ksm will be merged we 
will make this pages swappable as well...

> If so, please
>  - show the amount of kpage
>  
>  - allow users to set limit for usage of kpages. or preserve kpages at boot or
>    by user's command.
>   

kpage actually save memory..., and limiting the number of them, would 
make you limit the number of shared pages...

> Thanks,
> -Kame
>
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
