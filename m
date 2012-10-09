Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 2FE3B6B0044
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 16:48:33 -0400 (EDT)
Date: Tue, 9 Oct 2012 13:48:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH] Split mm_slot from ksm and huge_memory
Message-Id: <20121009134831.d9946b9f.akpm@linux-foundation.org>
In-Reply-To: <1349685772-29359-1-git-send-email-lliubbo@gmail.com>
References: <1349685772-29359-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, mhocko@suse.cz, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, aarcange@redhat.com, hannes@cmpxchg.org, rientjes@google.com

On Mon, 8 Oct 2012 16:42:52 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> Both ksm and huge_memory do hash lookup from mm to mm_slot, but the
> mm_slot are mostly the same except ksm need a rmap_list.
> 
> This patch split some duplicated part of mm_slot from ksm/huge_memory
> to a head file mm_slot.h, it make code cleaner and future work easier
> if someone need to lookup from mm to mm_slot also.
> 
> To make things simple, they still have their own slab cache and
> mm_slots_hash table.
> 
> Not well tested, just see whether the way is right firstly.
> 

Yes, this is a good thing to do.

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

It would be nice to have some overview here.  What is an mm_slot, why
code would want to use this library, etc.

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

I suggest this be removed - the caller shouldn't be calling
alloc_mm_slot() if the caller's slab creation failed.

> +	return kmem_cache_zalloc(mm_slot_cache, GFP_KERNEL);

It's generally poor form for a callee to assume that the caller wanted
GFP_KERNEL.  Usually we'll require that the caller pass in the gfp
flags.  As this is an inlined function, that is free so I guess we
should stick with convention here.

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

Ditto, although it would be a pretty silly caller which calls this
function from a non-GFP_KERNEL context.

It would be more appropriate to use kcalloc() here.

> +	if (!(*mm_slots_hash))
> +		return -ENOMEM;
> +	return 0;
> +}
>
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
>
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

These functions require locking (perhaps rw locking), so some
commentary is needed here describing that.

These functions are probably too large to be inlined - perhaps we
should create a .c file?

A common convention for code like this is to prefix all the
globally-visible identifiers with the subsystem's name.  So here we
could use mm_slots_get() and mm_slots_hash_insert() or similar.

The code assumes that the caller manages the kmem cache.  We didn't
have to do it that way - we could create a single kernel-wide one which
is created on first use (which will require mm_slots-internal locking)
and which is probably never destroyed, although it _could_ be destroyed
if we were to employ refcounting.  Thoughts on this?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
