Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 2389C6B006C
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 17:26:54 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id bh2so1622192pad.33
        for <linux-mm@kvack.org>; Wed, 19 Dec 2012 14:26:53 -0800 (PST)
Date: Wed, 19 Dec 2012 14:26:51 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 04/15] mm/huge_memory: use new hashtable implementation
In-Reply-To: <1355756497-15834-4-git-send-email-sasha.levin@oracle.com>
Message-ID: <alpine.DEB.2.00.1212191416410.32757@chino.kir.corp.google.com>
References: <1355756497-15834-1-git-send-email-sasha.levin@oracle.com> <1355756497-15834-4-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 17 Dec 2012, Sasha Levin wrote:

> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 827d9c8..2a0ef01 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -20,6 +20,7 @@
>  #include <linux/mman.h>
>  #include <linux/pagemap.h>
>  
> +#include <linux/hashtable.h>
>  #include <asm/tlb.h>
>  #include <asm/pgalloc.h>
>  #include "internal.h"

Why group this with the asm includes?

> @@ -61,12 +62,12 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
>  static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR-1;
>  
>  static int khugepaged(void *none);
> -static int mm_slots_hash_init(void);
>  static int khugepaged_slab_init(void);
>  static void khugepaged_slab_free(void);
>  

You're removing khugepaged_slab_free() too.

> -#define MM_SLOTS_HASH_HEADS 1024
> -static struct hlist_head *mm_slots_hash __read_mostly;
> +#define MM_SLOTS_HASH_BITS 10
> +static DEFINE_HASHTABLE(mm_slots_hash, MM_SLOTS_HASH_BITS);
> +

What happened to the __read_mostly?

This used to be dynamically allocated and would save the 8KB that you 
statically allocate if transparent hugepages cannot be used.  The generic 
hashtable implementation does not support dynamic allocation?

>  static struct kmem_cache *mm_slot_cache __read_mostly;
>  
>  /**
> @@ -633,12 +634,6 @@ static int __init hugepage_init(void)
>  	if (err)
>  		goto out;
>  
> -	err = mm_slots_hash_init();
> -	if (err) {
> -		khugepaged_slab_free();

This is the only use of khugepaged_slab_free(), so the function should be 
removed as well.

> -		goto out;
> -	}
> -
>  	register_shrinker(&huge_zero_page_shrinker);
>  
>  	/*
> @@ -1821,47 +1816,23 @@ static inline void free_mm_slot(struct mm_slot *mm_slot)
>  	kmem_cache_free(mm_slot_cache, mm_slot);
>  }
>  
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
>  static struct mm_slot *get_mm_slot(struct mm_struct *mm)
>  {
> -	struct mm_slot *mm_slot;
> -	struct hlist_head *bucket;
> +	struct mm_slot *slot;
>  	struct hlist_node *node;
>  
> -	bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
> -				% MM_SLOTS_HASH_HEADS];
> -	hlist_for_each_entry(mm_slot, node, bucket, hash) {
> -		if (mm == mm_slot->mm)
> -			return mm_slot;
> -	}
> +	hash_for_each_possible(mm_slots_hash, slot, node, hash, (unsigned long) mm)
> +		if (slot->mm == mm)
> +			return slot;

Why these other changes (the naming of the variable, the ordering of the 
conditional)?

> +
>  	return NULL;
>  }
>  
>  static void insert_to_mm_slots_hash(struct mm_struct *mm,
>  				    struct mm_slot *mm_slot)
>  {
> -	struct hlist_head *bucket;
> -
> -	bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
> -				% MM_SLOTS_HASH_HEADS];
>  	mm_slot->mm = mm;
> -	hlist_add_head(&mm_slot->hash, bucket);
> +	hash_add(mm_slots_hash, &mm_slot->hash, (long)mm);
>  }
>  
>  static inline int khugepaged_test_exit(struct mm_struct *mm)
> @@ -1930,7 +1901,7 @@ void __khugepaged_exit(struct mm_struct *mm)
>  	spin_lock(&khugepaged_mm_lock);
>  	mm_slot = get_mm_slot(mm);
>  	if (mm_slot && khugepaged_scan.mm_slot != mm_slot) {
> -		hlist_del(&mm_slot->hash);
> +		hash_del(&mm_slot->hash);
>  		list_del(&mm_slot->mm_node);
>  		free = 1;
>  	}
> @@ -2379,7 +2350,7 @@ static void collect_mm_slot(struct mm_slot *mm_slot)
>  
>  	if (khugepaged_test_exit(mm)) {
>  		/* free mm_slot */
> -		hlist_del(&mm_slot->hash);
> +		hash_del(&mm_slot->hash);
>  		list_del(&mm_slot->mm_node);
>  
>  		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
