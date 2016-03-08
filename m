Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3251D6B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 06:31:00 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l68so145656211wml.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 03:31:00 -0800 (PST)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id dz12si3157031wjb.180.2016.03.08.03.30.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 03:30:58 -0800 (PST)
Received: by mail-wm0-x235.google.com with SMTP id p65so23329822wmp.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 03:30:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56D471F5.3010202@gmail.com>
References: <cover.1456504662.git.glider@google.com>
	<00e9fa7d4adeac2d37a42cf613837e74850d929a.1456504662.git.glider@google.com>
	<56D471F5.3010202@gmail.com>
Date: Tue, 8 Mar 2016 12:30:58 +0100
Message-ID: <CAG_fn=Wq2kd7hns-FdFJUAz0OLr+s2rwHKs4tvGhRCO9pyCURg@mail.gmail.com>
Subject: Re: [PATCH v4 5/7] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Feb 29, 2016 at 5:29 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> w=
rote:
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
>> v2: - per request from Joonsoo Kim, moved the stackdepot implementation =
to
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
>> @@ -167,6 +167,13 @@ obj-$(CONFIG_SG_SPLIT) +=3D sg_split.o
>>  obj-$(CONFIG_STMP_DEVICE) +=3D stmp_device.o
>>  obj-$(CONFIG_IRQ_POLL) +=3D irq_poll.o
>>
>> +ifeq ($(CONFIG_KASAN),y)
>> +ifeq ($(CONFIG_SLAB),y)
>
> Just try to imagine that another subsystem wants to use stackdepot. How t=
his gonna look like?
>
> We have Kconfig to describe dependencies. So, this should be under CONFIG=
_STACKDEPOT.
> So any user of this feature can just do 'select STACKDEPOT' in Kconfig.
Agreed. Will fix this in the updated patch.

>> +     obj-y   +=3D stackdepot.o
>> +     KASAN_SANITIZE_slub.o :=3D n
>> +endif
>> +endif
>> +
>>  libfdt_files =3D fdt.o fdt_ro.o fdt_wip.o fdt_rw.o fdt_sw.o fdt_strerro=
r.o \
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
>> +static struct stack_record *depot_alloc_stack(unsigned long *entries, i=
nt size,
>> +             u32 hash, void **prealloc, gfp_t alloc_flags)
>> +{
>
>
>> +
>> +     stack->hash =3D hash;
>> +     stack->size =3D size;
>> +     stack->handle.slabindex =3D depot_index;
>> +     stack->handle.offset =3D depot_offset >> STACK_ALLOC_ALIGN;
>> +     __memcpy(stack->entries, entries, size * sizeof(unsigned long));
>
> s/__memcpy/memcpy
Ack.
>> +     depot_offset +=3D required_size;
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
>> +     depot_stack_handle retval =3D 0;
>> +     struct stack_record *found =3D NULL, **bucket;
>> +     unsigned long flags;
>> +     struct page *page =3D NULL;
>> +     void *prealloc =3D NULL;
>> +
>> +     if (unlikely(trace->nr_entries =3D=3D 0))
>> +             goto exit;
>> +
>> +     hash =3D hash_stack(trace->entries, trace->nr_entries);
>> +     /* Bad luck, we won't store this stack. */
>> +     if (hash =3D=3D 0)
>> +             goto exit;
>> +
>> +     bucket =3D &stack_table[hash & STACK_HASH_MASK];
>> +
>> +     /* Fast path: look the stack trace up without locking.
>> +      *
>> +      * The smp_load_acquire() here pairs with smp_store_release() to
>> +      * |bucket| below.
>> +      */
>> +     found =3D find_stack(smp_load_acquire(bucket), trace->entries,
>> +                        trace->nr_entries, hash);
>> +     if (found)
>> +             goto exit;
>> +
>> +     /* Check if the current or the next stack slab need to be initiali=
zed.
>> +      * If so, allocate the memory - we won't be able to do that under =
the
>> +      * lock.
>> +      *
>> +      * The smp_load_acquire() here pairs with smp_store_release() to
>> +      * |next_slab_inited| in depot_alloc_stack() and init_stack_slab()=
.
>> +      */
>> +     if (unlikely(!smp_load_acquire(&next_slab_inited))) {
>> +             if (!preempt_count() && !in_irq()) {
>
> If you trying to detect atomic context here, than this doesn't work. E.g.=
 you can't know
> about held spinlocks in non-preemptible kernel.
> And I'm not sure why need this. You know gfp flags here, so allocation in=
 atomic context shouldn't be problem.
Yeah, we can just remove these checks. As discussed before, this will
eliminate allocations from kfree(), but that's very unlikely to become
a problem.

>
>> +                     alloc_flags &=3D (__GFP_RECLAIM | __GFP_IO | __GFP=
_FS |
>> +                             __GFP_NOWARN | __GFP_NORETRY |
>> +                             __GFP_NOMEMALLOC | __GFP_DIRECT_RECLAIM);
>
> I think blacklist approach would be better here.
Perhaps we don't need to change the mask at all.

>> +                     page =3D alloc_pages(alloc_flags, STACK_ALLOC_ORDE=
R);
>
> STACK_ALLOC_ORDER =3D 4 - that's a lot. Do you really need that much?
Well, this is not "that" much, actually. The allocation happens only
~150 times within three hours under Trinity, which means only 9
megabytes.
At around 250 allocations the stack depot saturates and new stacks are
very rare.
We can probably drop the order to 3 or 2, which will increase the
number of allocations by just the factor of 2 to 4, but will be better
from the point of page fragmentation.
>
>> diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
>> index a61460d..32bd73a 100644
>> --- a/mm/kasan/Makefile
>> +++ b/mm/kasan/Makefile
>> @@ -7,3 +7,4 @@ CFLAGS_REMOVE_kasan.o =3D -pg
>>  CFLAGS_kasan.o :=3D $(call cc-option, -fno-conserve-stack -fno-stack-pr=
otector)
>>
>>  obj-y :=3D kasan.o report.o kasan_init.o
>> +
>
> Extra newline.
Ack.
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
> I think, you can reduce this (32 perhaps?). Kernel stacks are not so deep=
 usually.
>
>> +
>>  struct kasan_track {
>>       u64 cpu : 6;                    /* for NR_CPUS =3D 64 */
>>       u64 pid : 16;                   /* 65536 processes */
>>       u64 when : 42;                  /* ~140 years */
>> +     depot_stack_handle stack : sizeof(depot_stack_handle);
>>  };
>>
>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
