Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id A56336B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 03:45:44 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id hq4so6902499wib.2
        for <linux-mm@kvack.org>; Thu, 11 Oct 2012 00:45:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121009134831.d9946b9f.akpm@linux-foundation.org>
References: <1349685772-29359-1-git-send-email-lliubbo@gmail.com>
	<20121009134831.d9946b9f.akpm@linux-foundation.org>
Date: Thu, 11 Oct 2012 15:45:42 +0800
Message-ID: <CAA_GA1cK7GACnEb790FfiXNXLo6=yzQkSMp5oW3rccg4GpsVww@mail.gmail.com>
Subject: Re: [RFC PATCH] Split mm_slot from ksm and huge_memory
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, mhocko@suse.cz, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, aarcange@redhat.com, hannes@cmpxchg.org, rientjes@google.com

On Wed, Oct 10, 2012 at 4:48 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 8 Oct 2012 16:42:52 +0800
> Bob Liu <lliubbo@gmail.com> wrote:
>
>> Both ksm and huge_memory do hash lookup from mm to mm_slot, but the
>> mm_slot are mostly the same except ksm need a rmap_list.
>>
>> This patch split some duplicated part of mm_slot from ksm/huge_memory
>> to a head file mm_slot.h, it make code cleaner and future work easier
>> if someone need to lookup from mm to mm_slot also.
>>
>> To make things simple, they still have their own slab cache and
>> mm_slots_hash table.
>>
>> Not well tested, just see whether the way is right firstly.
>>
>
> Yes, this is a good thing to do.


Thank you for your review.

>
>> --- /dev/null
>> +++ b/include/linux/mm_slot.h
>> @@ -0,0 +1,68 @@
>> +#ifndef _LINUX_MM_SLOT_H
>> +#define _LINUX_MM_SLOT_H
>> +
>> +#define MM_SLOTS_HASH_HEADS 1024
>> +
>> +/**
>> + * struct mm_slot - hash lookup from mm to mm_slot
>> + * @hash: hash collision list
>> + * @mm_node: khugepaged scan list headed in khugepaged_scan.mm_head
>> + * @mm: the mm that this information is valid for
>> + * @private: rmaplist for ksm
>> + */
>
> It would be nice to have some overview here.  What is an mm_slot, why
> code would want to use this library, etc.
>

Okay.
>> +struct mm_slot {
>> +     struct hlist_node hash;
>> +     struct list_head mm_list;
>> +     struct mm_struct *mm;
>> +     void *private;
>> +};
>> +
>> +static inline struct mm_slot *alloc_mm_slot(struct kmem_cache *mm_slot_cache)
>> +{
>> +     if (!mm_slot_cache)     /* initialization failed */
>> +             return NULL;
>
> I suggest this be removed - the caller shouldn't be calling
> alloc_mm_slot() if the caller's slab creation failed.
>

Okay.

>> +     return kmem_cache_zalloc(mm_slot_cache, GFP_KERNEL);
>
> It's generally poor form for a callee to assume that the caller wanted
> GFP_KERNEL.  Usually we'll require that the caller pass in the gfp
> flags.  As this is an inlined function, that is free so I guess we
> should stick with convention here.
>
>> +}
>> +
>> +static inline void free_mm_slot(struct mm_slot *mm_slot,
>> +                     struct kmem_cache *mm_slot_cache)
>> +{
>> +     kmem_cache_free(mm_slot_cache, mm_slot);
>> +}
>> +
>> +static int __init mm_slots_hash_init(struct hlist_head **mm_slots_hash)
>> +{
>> +     *mm_slots_hash = kzalloc(MM_SLOTS_HASH_HEADS * sizeof(struct hlist_head),
>> +                     GFP_KERNEL);
>
> Ditto, although it would be a pretty silly caller which calls this
> function from a non-GFP_KERNEL context.
>
> It would be more appropriate to use kcalloc() here.
>
>> +     if (!(*mm_slots_hash))
>> +             return -ENOMEM;
>> +     return 0;
>> +}
>>
>> +static struct mm_slot *get_mm_slot(struct mm_struct *mm,
>> +                             struct hlist_head *mm_slots_hash)
>> +{
>> +     struct mm_slot *mm_slot;
>> +     struct hlist_head *bucket;
>> +     struct hlist_node *node;
>> +
>> +     bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
>> +                             % MM_SLOTS_HASH_HEADS];
>> +     hlist_for_each_entry(mm_slot, node, bucket, hash) {
>> +             if (mm == mm_slot->mm)
>> +                     return mm_slot;
>> +     }
>> +     return NULL;
>> +}
>>
>> +static void insert_to_mm_slots_hash(struct mm_struct *mm,
>> +             struct mm_slot *mm_slot, struct hlist_head *mm_slots_hash)
>> +{
>> +     struct hlist_head *bucket;
>> +
>> +     bucket = &mm_slots_hash[((unsigned long)mm / sizeof(struct mm_struct))
>> +                             % MM_SLOTS_HASH_HEADS];
>> +     mm_slot->mm = mm;
>> +     hlist_add_head(&mm_slot->hash, bucket);
>> +}
>
> These functions require locking (perhaps rw locking), so some
> commentary is needed here describing that.

There is no lock need here.
ksm and thp have their own mm_slots_hash and have no competition even
inside of them.

>
> These functions are probably too large to be inlined - perhaps we
> should create a .c file?


What about move them to memory.c?
It's a bit strange to create a .c file less than 100 lines.

>
> A common convention for code like this is to prefix all the
> globally-visible identifiers with the subsystem's name.  So here we
> could use mm_slots_get() and mm_slots_hash_insert() or similar.
>
> The code assumes that the caller manages the kmem cache.  We didn't
> have to do it that way - we could create a single kernel-wide one which
> is created on first use (which will require mm_slots-internal locking)
> and which is probably never destroyed, although it _could_ be destroyed
> if we were to employ refcounting.  Thoughts on this?
>

Yes, i already considered this before send out this one.

Do you think whether it make things too complicate?
mm_slot kmem_cache only created/destroyed once in ksm/thp, but we need to add
a lock and refcount to check it.

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
