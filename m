Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 142AE6B005A
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 04:51:59 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so4280329oag.14
        for <linux-mm@kvack.org>; Mon, 08 Oct 2012 01:51:58 -0700 (PDT)
Message-ID: <50729420.5050001@gmail.com>
Date: Mon, 08 Oct 2012 16:51:44 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] Split mm_slot from ksm and huge_memory
References: <1349685772-29359-1-git-send-email-lliubbo@gmail.com>
In-Reply-To: <1349685772-29359-1-git-send-email-lliubbo@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mhocko@suse.cz, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, aarcange@redhat.com, hannes@cmpxchg.org, rientjes@google.com

On 10/08/2012 04:42 PM, Bob Liu wrote:
> Both ksm and huge_memory do hash lookup from mm to mm_slot, but the
> mm_slot are mostly the same except ksm need a rmap_list.
>
> This patch split some duplicated part of mm_slot from ksm/huge_memory
> to a head file mm_slot.h, it make code cleaner and future work easier
> if someone need to lookup from mm to mm_slot also.
>
> To make things simple, they still have their own slab cache and
> mm_slots_hash table.

I also found this issue several months ago, looks reasonable to me.

> Not well tested, just see whether the way is right firstly.
>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>   include/linux/mm_slot.h |   68 ++++++++++++++++++++++++++++++++
>   mm/huge_memory.c        |   98 ++++++++---------------------------------------
>   mm/ksm.c                |   86 +++++++++--------------------------------
>   3 files changed, 102 insertions(+), 150 deletions(-)
>   create mode 100644 include/linux/mm_slot.h
>
> diff --git a/include/linux/mm_slot.h b/include/linux/mm_slot.h
> new file mode 100644
> index 0000000..e1e3725
> --- /dev/null
> +++ b/include/linux/mm_slot.h
> @@ -0,0 +1,68 @@
> +#ifndef _LINUX_MM_SLOT_H
> +#define _LINUX_MM_SLOT_H
> +
> +#define MM_SLOTS_HASH_HEADS 1024
> +
> +/**
> + * struct mm_slot - hash lookup from mm to mm_slot
> + * @hash: hash collision list
> + * @mm_node: khugepaged scan list headed in khugepaged_scan.mm_head
> + * @mm: the mm that this information is valid for
> + * @private: rmaplist for ksm
> + */
> +struct mm_slot {
> +	struct hlist_node hash;
> +	struct list_head mm_list;
> +	struct mm_struct *mm;
> +	void *private;
> +};
> +
> +static inline struct mm_slot *alloc_mm_slot(struct kmem_cache *mm_slot_cache)
> +{
> +	if (!mm_slot_cache)	/* initialization failed */
> +		return NULL;
> +	return kmem_cache_zalloc(mm_slot_cache, GFP_KERNEL);
> +}
> +
> +static inline void free_mm_slot(struct mm_slot *mm_slot,
> +			struct kmem_cache *mm_slot_cache)
> +{
> +	kmem_cache_free(mm_slot_cache, mm_slot);
> +}
> +
> +static int __init mm_slots_hash_init(struct hlist_head **mm_slots_hash)
> +{
> +	*mm_slots_hash = kzalloc(MM_SLOTS_HASH_HEADS * sizeof(struct hlist_head),
> +			GFP_KERNEL);
> +	if (!(*mm_slots_hash))
> +		return -ENOMEM;
> +	return 0;
> +}
> +
> +static struct mm_slot *get_mm_slot(struct mm_struct *mm,
> +				struct hlist_head *mm_slots_hash)
> +{
> +	struct mm_slot *mm_slot;
> +	struct hlist_head *bucket;
> +	struct hlist_node *node;
> +
> +	bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
> +				% MM_SLOTS_HASH_HEADS];
> +	hlist_for_each_entry(mm_slot, node, bucket, hash) {
> +		if (mm == mm_slot->mm)
> +			return mm_slot;
> +	}
> +	return NULL;
> +}
> +
> +static void insert_to_mm_slots_hash(struct mm_struct *mm,
> +		struct mm_slot *mm_slot, struct hlist_head *mm_slots_hash)
> +{
> +	struct hlist_head *bucket;
> +
> +	bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
> +				% MM_SLOTS_HASH_HEADS];
> +	mm_slot->mm = mm;
> +	hlist_add_head(&mm_slot->hash, bucket);
> +}
> +#endif
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 141dbb6..8ab58a0 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -17,6 +17,7 @@
>   #include <linux/khugepaged.h>
>   #include <linux/freezer.h>
>   #include <linux/mman.h>
> +#include <linux/mm_slot.h>
>   #include <asm/tlb.h>
>   #include <asm/pgalloc.h>
>   #include "internal.h"
> @@ -57,27 +58,13 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
>   static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR-1;
>   
>   static int khugepaged(void *none);
> -static int mm_slots_hash_init(void);
>   static int khugepaged_slab_init(void);
>   static void khugepaged_slab_free(void);
>   
> -#define MM_SLOTS_HASH_HEADS 1024
>   static struct hlist_head *mm_slots_hash __read_mostly;
>   static struct kmem_cache *mm_slot_cache __read_mostly;
>   
>   /**
> - * struct mm_slot - hash lookup from mm to mm_slot
> - * @hash: hash collision list
> - * @mm_node: khugepaged scan list headed in khugepaged_scan.mm_head
> - * @mm: the mm that this information is valid for
> - */
> -struct mm_slot {
> -	struct hlist_node hash;
> -	struct list_head mm_node;
> -	struct mm_struct *mm;
> -};
> -
> -/**
>    * struct khugepaged_scan - cursor for scanning
>    * @mm_head: the head of the mm list to scan
>    * @mm_slot: the current mm_slot we are scanning
> @@ -554,7 +541,7 @@ static int __init hugepage_init(void)
>   	if (err)
>   		goto out;
>   
> -	err = mm_slots_hash_init();
> +	err = mm_slots_hash_init(&mm_slots_hash);
>   	if (err) {
>   		khugepaged_slab_free();
>   		goto out;
> @@ -1550,61 +1537,6 @@ static void __init khugepaged_slab_free(void)
>   	mm_slot_cache = NULL;
>   }
>   
> -static inline struct mm_slot *alloc_mm_slot(void)
> -{
> -	if (!mm_slot_cache)	/* initialization failed */
> -		return NULL;
> -	return kmem_cache_zalloc(mm_slot_cache, GFP_KERNEL);
> -}
> -
> -static inline void free_mm_slot(struct mm_slot *mm_slot)
> -{
> -	kmem_cache_free(mm_slot_cache, mm_slot);
> -}
> -
> -static int __init mm_slots_hash_init(void)
> -{
> -	mm_slots_hash = kzalloc(MM_SLOTS_HASH_HEADS * sizeof(struct hlist_head),
> -				GFP_KERNEL);
> -	if (!mm_slots_hash)
> -		return -ENOMEM;
> -	return 0;
> -}
> -
> -#if 0
> -static void __init mm_slots_hash_free(void)
> -{
> -	kfree(mm_slots_hash);
> -	mm_slots_hash = NULL;
> -}
> -#endif
> -
> -static struct mm_slot *get_mm_slot(struct mm_struct *mm)
> -{
> -	struct mm_slot *mm_slot;
> -	struct hlist_head *bucket;
> -	struct hlist_node *node;
> -
> -	bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
> -				% MM_SLOTS_HASH_HEADS];
> -	hlist_for_each_entry(mm_slot, node, bucket, hash) {
> -		if (mm == mm_slot->mm)
> -			return mm_slot;
> -	}
> -	return NULL;
> -}
> -
> -static void insert_to_mm_slots_hash(struct mm_struct *mm,
> -				    struct mm_slot *mm_slot)
> -{
> -	struct hlist_head *bucket;
> -
> -	bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
> -				% MM_SLOTS_HASH_HEADS];
> -	mm_slot->mm = mm;
> -	hlist_add_head(&mm_slot->hash, bucket);
> -}
> -
>   static inline int khugepaged_test_exit(struct mm_struct *mm)
>   {
>   	return atomic_read(&mm->mm_users) == 0;
> @@ -1615,25 +1547,25 @@ int __khugepaged_enter(struct mm_struct *mm)
>   	struct mm_slot *mm_slot;
>   	int wakeup;
>   
> -	mm_slot = alloc_mm_slot();
> +	mm_slot = alloc_mm_slot(mm_slot_cache);
>   	if (!mm_slot)
>   		return -ENOMEM;
>   
>   	/* __khugepaged_exit() must not run from under us */
>   	VM_BUG_ON(khugepaged_test_exit(mm));
>   	if (unlikely(test_and_set_bit(MMF_VM_HUGEPAGE, &mm->flags))) {
> -		free_mm_slot(mm_slot);
> +		free_mm_slot(mm_slot, mm_slot_cache);
>   		return 0;
>   	}
>   
>   	spin_lock(&khugepaged_mm_lock);
> -	insert_to_mm_slots_hash(mm, mm_slot);
> +	insert_to_mm_slots_hash(mm, mm_slot, mm_slots_hash);
>   	/*
>   	 * Insert just behind the scanning cursor, to let the area settle
>   	 * down a little.
>   	 */
>   	wakeup = list_empty(&khugepaged_scan.mm_head);
> -	list_add_tail(&mm_slot->mm_node, &khugepaged_scan.mm_head);
> +	list_add_tail(&mm_slot->mm_list, &khugepaged_scan.mm_head);
>   	spin_unlock(&khugepaged_mm_lock);
>   
>   	atomic_inc(&mm->mm_count);
> @@ -1673,17 +1605,17 @@ void __khugepaged_exit(struct mm_struct *mm)
>   	int free = 0;
>   
>   	spin_lock(&khugepaged_mm_lock);
> -	mm_slot = get_mm_slot(mm);
> +	mm_slot = get_mm_slot(mm, mm_slots_hash);
>   	if (mm_slot && khugepaged_scan.mm_slot != mm_slot) {
>   		hlist_del(&mm_slot->hash);
> -		list_del(&mm_slot->mm_node);
> +		list_del(&mm_slot->mm_list);
>   		free = 1;
>   	}
>   	spin_unlock(&khugepaged_mm_lock);
>   
>   	if (free) {
>   		clear_bit(MMF_VM_HUGEPAGE, &mm->flags);
> -		free_mm_slot(mm_slot);
> +		free_mm_slot(mm_slot, mm_slot_cache);
>   		mmdrop(mm);
>   	} else if (mm_slot) {
>   		/*
> @@ -2089,7 +2021,7 @@ static void collect_mm_slot(struct mm_slot *mm_slot)
>   	if (khugepaged_test_exit(mm)) {
>   		/* free mm_slot */
>   		hlist_del(&mm_slot->hash);
> -		list_del(&mm_slot->mm_node);
> +		list_del(&mm_slot->mm_list);
>   
>   		/*
>   		 * Not strictly needed because the mm exited already.
> @@ -2098,7 +2030,7 @@ static void collect_mm_slot(struct mm_slot *mm_slot)
>   		 */
>   
>   		/* khugepaged_mm_lock actually not necessary for the below */
> -		free_mm_slot(mm_slot);
> +		free_mm_slot(mm_slot, mm_slot_cache);
>   		mmdrop(mm);
>   	}
>   }
> @@ -2120,7 +2052,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
>   		mm_slot = khugepaged_scan.mm_slot;
>   	else {
>   		mm_slot = list_entry(khugepaged_scan.mm_head.next,
> -				     struct mm_slot, mm_node);
> +				     struct mm_slot, mm_list);
>   		khugepaged_scan.address = 0;
>   		khugepaged_scan.mm_slot = mm_slot;
>   	}
> @@ -2209,10 +2141,10 @@ breakouterloop_mmap_sem:
>   		 * khugepaged runs here, khugepaged_exit will find
>   		 * mm_slot not pointing to the exiting mm.
>   		 */
> -		if (mm_slot->mm_node.next != &khugepaged_scan.mm_head) {
> +		if (mm_slot->mm_list.next != &khugepaged_scan.mm_head) {
>   			khugepaged_scan.mm_slot = list_entry(
> -				mm_slot->mm_node.next,
> -				struct mm_slot, mm_node);
> +				mm_slot->mm_list.next,
> +				struct mm_slot, mm_list);
>   			khugepaged_scan.address = 0;
>   		} else {
>   			khugepaged_scan.mm_slot = NULL;
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 47c8853..37b73c6 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -31,6 +31,7 @@
>   #include <linux/rbtree.h>
>   #include <linux/memory.h>
>   #include <linux/mmu_notifier.h>
> +#include <linux/mm_slot.h>
>   #include <linux/swap.h>
>   #include <linux/ksm.h>
>   #include <linux/hash.h>
> @@ -79,21 +80,6 @@
>    *    it is secured in the stable tree.  (When we scan a new page, we first
>    *    compare it against the stable tree, and then against the unstable tree.)
>    */
> -
> -/**
> - * struct mm_slot - ksm information per mm that is being scanned
> - * @link: link to the mm_slots hash list
> - * @mm_list: link into the mm_slots list, rooted in ksm_mm_head
> - * @rmap_list: head for this mm_slot's singly-linked list of rmap_items
> - * @mm: the mm that this information is valid for
> - */
> -struct mm_slot {
> -	struct hlist_node link;
> -	struct list_head mm_list;
> -	struct rmap_item *rmap_list;
> -	struct mm_struct *mm;
> -};
> -
>   /**
>    * struct ksm_scan - cursor for scanning
>    * @mm_slot: the current mm_slot we are scanning
> @@ -156,9 +142,7 @@ struct rmap_item {
>   static struct rb_root root_stable_tree = RB_ROOT;
>   static struct rb_root root_unstable_tree = RB_ROOT;
>   
> -#define MM_SLOTS_HASH_SHIFT 10
> -#define MM_SLOTS_HASH_HEADS (1 << MM_SLOTS_HASH_SHIFT)
> -static struct hlist_head mm_slots_hash[MM_SLOTS_HASH_HEADS];
> +static struct hlist_head *mm_slots_hash;
>   
>   static struct mm_slot ksm_mm_head = {
>   	.mm_list = LIST_HEAD_INIT(ksm_mm_head.mm_list),
> @@ -261,42 +245,6 @@ static inline void free_stable_node(struct stable_node *stable_node)
>   	kmem_cache_free(stable_node_cache, stable_node);
>   }
>   
> -static inline struct mm_slot *alloc_mm_slot(void)
> -{
> -	if (!mm_slot_cache)	/* initialization failed */
> -		return NULL;
> -	return kmem_cache_zalloc(mm_slot_cache, GFP_KERNEL);
> -}
> -
> -static inline void free_mm_slot(struct mm_slot *mm_slot)
> -{
> -	kmem_cache_free(mm_slot_cache, mm_slot);
> -}
> -
> -static struct mm_slot *get_mm_slot(struct mm_struct *mm)
> -{
> -	struct mm_slot *mm_slot;
> -	struct hlist_head *bucket;
> -	struct hlist_node *node;
> -
> -	bucket = &mm_slots_hash[hash_ptr(mm, MM_SLOTS_HASH_SHIFT)];
> -	hlist_for_each_entry(mm_slot, node, bucket, link) {
> -		if (mm == mm_slot->mm)
> -			return mm_slot;
> -	}
> -	return NULL;
> -}
> -
> -static void insert_to_mm_slots_hash(struct mm_struct *mm,
> -				    struct mm_slot *mm_slot)
> -{
> -	struct hlist_head *bucket;
> -
> -	bucket = &mm_slots_hash[hash_ptr(mm, MM_SLOTS_HASH_SHIFT)];
> -	mm_slot->mm = mm;
> -	hlist_add_head(&mm_slot->link, bucket);
> -}
> -
>   static inline int in_stable_tree(struct rmap_item *rmap_item)
>   {
>   	return rmap_item->address & STABLE_FLAG;
> @@ -641,17 +589,17 @@ static int unmerge_and_remove_all_rmap_items(void)
>   				goto error;
>   		}
>   
> -		remove_trailing_rmap_items(mm_slot, &mm_slot->rmap_list);
> +		remove_trailing_rmap_items(mm_slot, (struct rmap_item **)&mm_slot->private);
>   
>   		spin_lock(&ksm_mmlist_lock);
>   		ksm_scan.mm_slot = list_entry(mm_slot->mm_list.next,
>   						struct mm_slot, mm_list);
>   		if (ksm_test_exit(mm)) {
> -			hlist_del(&mm_slot->link);
> +			hlist_del(&mm_slot->hash);
>   			list_del(&mm_slot->mm_list);
>   			spin_unlock(&ksm_mmlist_lock);
>   
> -			free_mm_slot(mm_slot);
> +			free_mm_slot(mm_slot, mm_slot_cache);
>   			clear_bit(MMF_VM_MERGEABLE, &mm->flags);
>   			up_read(&mm->mmap_sem);
>   			mmdrop(mm);
> @@ -1314,7 +1262,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
>   			return NULL;
>   next_mm:
>   		ksm_scan.address = 0;
> -		ksm_scan.rmap_list = &slot->rmap_list;
> +		ksm_scan.rmap_list = (struct rmap_item **)&slot->private;
>   	}
>   
>   	mm = slot->mm;
> @@ -1364,7 +1312,7 @@ next_mm:
>   
>   	if (ksm_test_exit(mm)) {
>   		ksm_scan.address = 0;
> -		ksm_scan.rmap_list = &slot->rmap_list;
> +		ksm_scan.rmap_list = (struct rmap_item **)&slot->private;
>   	}
>   	/*
>   	 * Nuke all the rmap_items that are above this current rmap:
> @@ -1385,11 +1333,11 @@ next_mm:
>   		 * or when all VM_MERGEABLE areas have been unmapped (and
>   		 * mmap_sem then protects against race with MADV_MERGEABLE).
>   		 */
> -		hlist_del(&slot->link);
> +		hlist_del(&slot->hash);
>   		list_del(&slot->mm_list);
>   		spin_unlock(&ksm_mmlist_lock);
>   
> -		free_mm_slot(slot);
> +		free_mm_slot(slot, mm_slot_cache);
>   		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
>   		up_read(&mm->mmap_sem);
>   		mmdrop(mm);
> @@ -1504,7 +1452,7 @@ int __ksm_enter(struct mm_struct *mm)
>   	struct mm_slot *mm_slot;
>   	int needs_wakeup;
>   
> -	mm_slot = alloc_mm_slot();
> +	mm_slot = alloc_mm_slot(mm_slot_cache);
>   	if (!mm_slot)
>   		return -ENOMEM;
>   
> @@ -1512,7 +1460,7 @@ int __ksm_enter(struct mm_struct *mm)
>   	needs_wakeup = list_empty(&ksm_mm_head.mm_list);
>   
>   	spin_lock(&ksm_mmlist_lock);
> -	insert_to_mm_slots_hash(mm, mm_slot);
> +	insert_to_mm_slots_hash(mm, mm_slot, mm_slots_hash);
>   	/*
>   	 * Insert just behind the scanning cursor, to let the area settle
>   	 * down a little; when fork is followed by immediate exec, we don't
> @@ -1545,10 +1493,10 @@ void __ksm_exit(struct mm_struct *mm)
>   	 */
>   
>   	spin_lock(&ksm_mmlist_lock);
> -	mm_slot = get_mm_slot(mm);
> +	mm_slot = get_mm_slot(mm, mm_slots_hash);
>   	if (mm_slot && ksm_scan.mm_slot != mm_slot) {
> -		if (!mm_slot->rmap_list) {
> -			hlist_del(&mm_slot->link);
> +		if (!mm_slot->private) {
> +			hlist_del(&mm_slot->hash);
>   			list_del(&mm_slot->mm_list);
>   			easy_to_free = 1;
>   		} else {
> @@ -1559,7 +1507,7 @@ void __ksm_exit(struct mm_struct *mm)
>   	spin_unlock(&ksm_mmlist_lock);
>   
>   	if (easy_to_free) {
> -		free_mm_slot(mm_slot);
> +		free_mm_slot(mm_slot, mm_slot_cache);
>   		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
>   		mmdrop(mm);
>   	} else if (mm_slot) {
> @@ -1998,6 +1946,10 @@ static int __init ksm_init(void)
>   	if (err)
>   		goto out;
>   
> +	err = mm_slots_hash_init(&mm_slots_hash);
> +	if (err)
> +		goto out_free;
> +
>   	ksm_thread = kthread_run(ksm_scan_thread, NULL, "ksmd");
>   	if (IS_ERR(ksm_thread)) {
>   		printk(KERN_ERR "ksm: creating kthread failed\n");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
