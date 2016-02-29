Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6D27E6B0254
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:13:09 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l68so67914807wml.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:13:09 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id q6si5292236wmg.121.2016.02.29.09.13.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 09:13:08 -0800 (PST)
Received: by mail-wm0-x22f.google.com with SMTP id l68so67914185wml.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:13:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56D471F5.3010202@gmail.com>
References: <cover.1456504662.git.glider@google.com> <00e9fa7d4adeac2d37a42cf613837e74850d929a.1456504662.git.glider@google.com>
 <56D471F5.3010202@gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 29 Feb 2016 18:12:48 +0100
Message-ID: <CACT4Y+YPFEyuFdnM3_=2p1qANC7A1CKB0o1ySx2zexgE4kgVVw@mail.gmail.com>
Subject: Re: [PATCH v4 5/7] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Alexander Potapenko <glider@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Feb 29, 2016 at 5:29 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
>
>
> On 02/26/2016 07:48 PM, Alexander Potapenko wrote:
>> Stack depot will allow KASAN store allocation/deallocation stack traces
>> for memory chunks. The stack traces are stored in a hash table and
>> referenced by handles which reside in the kasan_alloc_meta and
>> kasan_free_meta structures in the allocated memory chunks.
>>
>> IRQ stack traces are cut below the IRQ entry point to avoid unnecessary
>> duplication.
>>
>> Right now stackdepot support is only enabled in SLAB allocator.
>> Once KASAN features in SLAB are on par with those in SLUB we can switch
>> SLUB to stackdepot as well, thus removing the dependency on SLUB stack
>> bookkeeping, which wastes a lot of memory.
>>
>> This patch is based on the "mm: kasan: stack depots" patch originally
>> prepared by Dmitry Chernenkov.
>>
>> Signed-off-by: Alexander Potapenko <glider@google.com>
>> ---
>> v2: - per request from Joonsoo Kim, moved the stackdepot implementation to
>> lib/, as there's a plan to use it for page owner
>>     - added copyright comments
>>     - added comments about smp_load_acquire()/smp_store_release()
>>
>> v3: - minor description changes
>> ---
>
>
>
>> diff --git a/lib/Makefile b/lib/Makefile
>> index a7c26a4..10a4ae3 100644
>> --- a/lib/Makefile
>> +++ b/lib/Makefile
>> @@ -167,6 +167,13 @@ obj-$(CONFIG_SG_SPLIT) += sg_split.o
>>  obj-$(CONFIG_STMP_DEVICE) += stmp_device.o
>>  obj-$(CONFIG_IRQ_POLL) += irq_poll.o
>>
>> +ifeq ($(CONFIG_KASAN),y)
>> +ifeq ($(CONFIG_SLAB),y)
>
> Just try to imagine that another subsystem wants to use stackdepot. How this gonna look like?
>
> We have Kconfig to describe dependencies. So, this should be under CONFIG_STACKDEPOT.
> So any user of this feature can just do 'select STACKDEPOT' in Kconfig.
>
>> +     obj-y   += stackdepot.o
>> +     KASAN_SANITIZE_slub.o := n
>> +endif
>> +endif
>> +
>>  libfdt_files = fdt.o fdt_ro.o fdt_wip.o fdt_rw.o fdt_sw.o fdt_strerror.o \
>>              fdt_empty_tree.o
>>  $(foreach file, $(libfdt_files), \
>> diff --git a/lib/stackdepot.c b/lib/stackdepot.c
>> new file mode 100644
>> index 0000000..f09b0da
>> --- /dev/null
>> +++ b/lib/stackdepot.c
>
>
>> +/* Allocation of a new stack in raw storage */
>> +static struct stack_record *depot_alloc_stack(unsigned long *entries, int size,
>> +             u32 hash, void **prealloc, gfp_t alloc_flags)
>> +{
>
>
>> +
>> +     stack->hash = hash;
>> +     stack->size = size;
>> +     stack->handle.slabindex = depot_index;
>> +     stack->handle.offset = depot_offset >> STACK_ALLOC_ALIGN;
>> +     __memcpy(stack->entries, entries, size * sizeof(unsigned long));
>
> s/__memcpy/memcpy/

memcpy should be instrumented by asan/tsan, and we would like to avoid
that instrumentation here.
It's plain unnecessary and for tsan it can create recursion issues
(double entry into runtime).


>> +     depot_offset += required_size;
>> +
>> +     return stack;
>> +}
>> +
>
>
>> +/*
>> + * depot_save_stack - save stack in a stack depot.
>> + * @trace - the stacktrace to save.
>> + * @alloc_flags - flags for allocating additional memory if required.
>> + *
>> + * Returns the handle of the stack struct stored in depot.
>> + */
>> +depot_stack_handle depot_save_stack(struct stack_trace *trace,
>> +                                 gfp_t alloc_flags)
>> +{
>> +     u32 hash;
>> +     depot_stack_handle retval = 0;
>> +     struct stack_record *found = NULL, **bucket;
>> +     unsigned long flags;
>> +     struct page *page = NULL;
>> +     void *prealloc = NULL;
>> +
>> +     if (unlikely(trace->nr_entries == 0))
>> +             goto exit;
>> +
>> +     hash = hash_stack(trace->entries, trace->nr_entries);
>> +     /* Bad luck, we won't store this stack. */
>> +     if (hash == 0)
>> +             goto exit;
>> +
>> +     bucket = &stack_table[hash & STACK_HASH_MASK];
>> +
>> +     /* Fast path: look the stack trace up without locking.
>> +      *
>> +      * The smp_load_acquire() here pairs with smp_store_release() to
>> +      * |bucket| below.
>> +      */
>> +     found = find_stack(smp_load_acquire(bucket), trace->entries,
>> +                        trace->nr_entries, hash);
>> +     if (found)
>> +             goto exit;
>> +
>> +     /* Check if the current or the next stack slab need to be initialized.
>> +      * If so, allocate the memory - we won't be able to do that under the
>> +      * lock.
>> +      *
>> +      * The smp_load_acquire() here pairs with smp_store_release() to
>> +      * |next_slab_inited| in depot_alloc_stack() and init_stack_slab().
>> +      */
>> +     if (unlikely(!smp_load_acquire(&next_slab_inited))) {
>> +             if (!preempt_count() && !in_irq()) {
>
> If you trying to detect atomic context here, than this doesn't work. E.g. you can't know
> about held spinlocks in non-preemptible kernel.
> And I'm not sure why need this. You know gfp flags here, so allocation in atomic context shouldn't be problem.


We don't have gfp flags for kfree.
I wonder how CONFIG_DEBUG_ATOMIC_SLEEP handles this. Maybe it has the answer.
Alternatively, we can always assume that we are in atomic context in kfree.



>> +                     alloc_flags &= (__GFP_RECLAIM | __GFP_IO | __GFP_FS |
>> +                             __GFP_NOWARN | __GFP_NORETRY |
>> +                             __GFP_NOMEMALLOC | __GFP_DIRECT_RECLAIM);
>
> I think blacklist approach would be better here.
>
>> +                     page = alloc_pages(alloc_flags, STACK_ALLOC_ORDER);
>
> STACK_ALLOC_ORDER = 4 - that's a lot. Do you really need that much?

Part of the issue the atomic context above. When we can't allocate
memory we still want to save the stack trace. When we have less than
STACK_ALLOC_ORDER memory, we try to preallocate another
STACK_ALLOC_ORDER in advance. So in the worst case, we have
STACK_ALLOC_ORDER memory and that should be enough to handle all
kmalloc/kfree in the atomic context. 1 page does not look enough. I
think Alex did some measuring of the failure race (when we are out of
memory and can't allocate more).


>> diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
>> index a61460d..32bd73a 100644
>> --- a/mm/kasan/Makefile
>> +++ b/mm/kasan/Makefile
>> @@ -7,3 +7,4 @@ CFLAGS_REMOVE_kasan.o = -pg
>>  CFLAGS_kasan.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
>>
>>  obj-y := kasan.o report.o kasan_init.o
>> +
>
> Extra newline.
>
>
>> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
>> index 7b9e4ab9..b4e5942 100644
>> --- a/mm/kasan/kasan.h
>> +++ b/mm/kasan/kasan.h
>> @@ -2,6 +2,7 @@
>>  #define __MM_KASAN_KASAN_H
>>
>>  #include <linux/kasan.h>
>> +#include <linux/stackdepot.h>
>>
>>  #define KASAN_SHADOW_SCALE_SIZE (1UL << KASAN_SHADOW_SCALE_SHIFT)
>>  #define KASAN_SHADOW_MASK       (KASAN_SHADOW_SCALE_SIZE - 1)
>> @@ -64,10 +65,13 @@ enum kasan_state {
>>       KASAN_STATE_FREE
>>  };
>>
>> +#define KASAN_STACK_DEPTH 64
>
> I think, you can reduce this (32 perhaps?). Kernel stacks are not so deep usually.

We don't allocate whole KASAN_STACK_DEPTH for each stack, we allocate
only required memory for a particular stack at hand. So large value
here is not an issue. If most stacks are shallow, then we will
allocate just that small amount of memory.



>> +
>>  struct kasan_track {
>>       u64 cpu : 6;                    /* for NR_CPUS = 64 */
>>       u64 pid : 16;                   /* 65536 processes */
>>       u64 when : 42;                  /* ~140 years */
>> +     depot_stack_handle stack : sizeof(depot_stack_handle);
>>  };
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
