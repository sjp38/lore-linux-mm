Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6BE386B006C
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 09:48:21 -0500 (EST)
Received: by labms9 with SMTP id ms9so23281553lab.10
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 06:48:20 -0800 (PST)
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com. [209.85.215.45])
        by mx.google.com with ESMTPS id i8si7438607lam.148.2015.02.16.06.48.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Feb 2015 06:48:19 -0800 (PST)
Received: by lams18 with SMTP id s18so29300712lam.11
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 06:48:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54E20238.3090902@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
 <1422985392-28652-20-git-send-email-a.ryabinin@samsung.com>
 <87a90ea7ge.fsf@rustcorp.com.au> <54E20238.3090902@samsung.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 16 Feb 2015 18:47:57 +0400
Message-ID: <CACT4Y+bdf05fHtD87TtFZZYBgKudLna6yOBfs-dpYnccZJLhsw@mail.gmail.com>
Subject: Re: [PATCH v11 19/19] kasan: enable instrumentation of global variables
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>, LKML <linux-kernel@vger.kernel.org>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Michal Marek <mmarek@suse.cz>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>

Can a module be freed in an interrupt?


On Mon, Feb 16, 2015 at 5:44 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> On 02/16/2015 05:58 AM, Rusty Russell wrote:
>> Andrey Ryabinin <a.ryabinin@samsung.com> writes:
>>> This feature let us to detect accesses out of bounds of
>>> global variables. This will work as for globals in kernel
>>> image, so for globals in modules. Currently this won't work
>>> for symbols in user-specified sections (e.g. __init, __read_mostly, ...)
>>>
>>> The idea of this is simple. Compiler increases each global variable
>>> by redzone size and add constructors invoking __asan_register_globals()
>>> function. Information about global variable (address, size,
>>> size with redzone ...) passed to __asan_register_globals() so we could
>>> poison variable's redzone.
>>>
>>> This patch also forces module_alloc() to return 8*PAGE_SIZE aligned
>>> address making shadow memory handling ( kasan_module_alloc()/kasan_module_free() )
>>> more simple. Such alignment guarantees that each shadow page backing
>>> modules address space correspond to only one module_alloc() allocation.
>>
>> Hmm, I understand why you only fixed x86, but it's weird.
>>
>> I think MODULE_ALIGN belongs in linux/moduleloader.h, and every arch
>> should be fixed up to use it (though you could leave that for later).
>>
>> Might as well fix the default implementation at least.
>>
>>> @@ -49,8 +49,15 @@ void kasan_krealloc(const void *object, size_t new_size);
>>>  void kasan_slab_alloc(struct kmem_cache *s, void *object);
>>>  void kasan_slab_free(struct kmem_cache *s, void *object);
>>>
>>> +#define MODULE_ALIGN (PAGE_SIZE << KASAN_SHADOW_SCALE_SHIFT)
>>> +
>>> +int kasan_module_alloc(void *addr, size_t size);
>>> +void kasan_module_free(void *addr);
>>> +
>>>  #else /* CONFIG_KASAN */
>>>
>>> +#define MODULE_ALIGN 1
>>
>> Hmm, that should be PAGE_SIZE (we assume that in several places).
>>
>>> @@ -1807,6 +1808,7 @@ static void unset_module_init_ro_nx(struct module *mod) { }
>>>  void __weak module_memfree(void *module_region)
>>>  {
>>>      vfree(module_region);
>>> +    kasan_module_free(module_region);
>>>  }
>>
>> This looks racy (memory reuse?).  Perhaps try other order?
>>
>
> You are right, it's racy. Concurrent kasan_module_alloc() could fail because
> kasan_module_free() wasn't called/finished yet, so whole module_alloc() will fail
> and module loading will fail.
> However, I just find out that this race is not the worst problem here.
> When vfree(addr) called in interrupt context, memory at addr will be reused for
> storing 'struct llist_node':
>
> void vfree(const void *addr)
> {
> ...
>         if (unlikely(in_interrupt())) {
>                 struct vfree_deferred *p = this_cpu_ptr(&vfree_deferred);
>                 if (llist_add((struct llist_node *)addr, &p->list))
>                         schedule_work(&p->wq);
>
>
> In this case we have to free shadow *after* freeing 'module_region', because 'module_region'
> is still used in llist_add() and in free_work() latter.
> free_work() (in mm/vmalloc.c) processes list in LIFO order, so to free shadow after freeing
> 'module_region' kasan_module_free(module_region); should be called before vfree(module_region);
>
> It will be racy still, but this is not so bad as potential crash that we have now.
> Honestly, I have no idea how to fix this race nicely. Any suggestions?
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
