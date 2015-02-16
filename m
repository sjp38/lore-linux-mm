Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9EB436B0032
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 09:44:16 -0500 (EST)
Received: by pdjy10 with SMTP id y10so36017107pdj.6
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 06:44:16 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id ns16si3871606pdb.39.2015.02.16.06.44.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 16 Feb 2015 06:44:15 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJV00KKED4COV60@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 16 Feb 2015 14:48:13 +0000 (GMT)
Message-id: <54E20238.3090902@samsung.com>
Date: Mon, 16 Feb 2015 17:44:08 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v11 19/19] kasan: enable instrumentation of global variables
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
 <1422985392-28652-20-git-send-email-a.ryabinin@samsung.com>
 <87a90ea7ge.fsf@rustcorp.com.au>
In-reply-to: <87a90ea7ge.fsf@rustcorp.com.au>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Michal Marek <mmarek@suse.cz>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>

On 02/16/2015 05:58 AM, Rusty Russell wrote:
> Andrey Ryabinin <a.ryabinin@samsung.com> writes:
>> This feature let us to detect accesses out of bounds of
>> global variables. This will work as for globals in kernel
>> image, so for globals in modules. Currently this won't work
>> for symbols in user-specified sections (e.g. __init, __read_mostly, ...)
>>
>> The idea of this is simple. Compiler increases each global variable
>> by redzone size and add constructors invoking __asan_register_globals()
>> function. Information about global variable (address, size,
>> size with redzone ...) passed to __asan_register_globals() so we could
>> poison variable's redzone.
>>
>> This patch also forces module_alloc() to return 8*PAGE_SIZE aligned
>> address making shadow memory handling ( kasan_module_alloc()/kasan_module_free() )
>> more simple. Such alignment guarantees that each shadow page backing
>> modules address space correspond to only one module_alloc() allocation.
> 
> Hmm, I understand why you only fixed x86, but it's weird.
> 
> I think MODULE_ALIGN belongs in linux/moduleloader.h, and every arch
> should be fixed up to use it (though you could leave that for later).
> 
> Might as well fix the default implementation at least.
> 
>> @@ -49,8 +49,15 @@ void kasan_krealloc(const void *object, size_t new_size);
>>  void kasan_slab_alloc(struct kmem_cache *s, void *object);
>>  void kasan_slab_free(struct kmem_cache *s, void *object);
>>  
>> +#define MODULE_ALIGN (PAGE_SIZE << KASAN_SHADOW_SCALE_SHIFT)
>> +
>> +int kasan_module_alloc(void *addr, size_t size);
>> +void kasan_module_free(void *addr);
>> +
>>  #else /* CONFIG_KASAN */
>>  
>> +#define MODULE_ALIGN 1
> 
> Hmm, that should be PAGE_SIZE (we assume that in several places).
> 
>> @@ -1807,6 +1808,7 @@ static void unset_module_init_ro_nx(struct module *mod) { }
>>  void __weak module_memfree(void *module_region)
>>  {
>>  	vfree(module_region);
>> +	kasan_module_free(module_region);
>>  }
> 
> This looks racy (memory reuse?).  Perhaps try other order?
> 

You are right, it's racy. Concurrent kasan_module_alloc() could fail because
kasan_module_free() wasn't called/finished yet, so whole module_alloc() will fail
and module loading will fail.
However, I just find out that this race is not the worst problem here.
When vfree(addr) called in interrupt context, memory at addr will be reused for
storing 'struct llist_node':

void vfree(const void *addr)
{
...
	if (unlikely(in_interrupt())) {
		struct vfree_deferred *p = this_cpu_ptr(&vfree_deferred);
		if (llist_add((struct llist_node *)addr, &p->list))
			schedule_work(&p->wq);


In this case we have to free shadow *after* freeing 'module_region', because 'module_region'
is still used in llist_add() and in free_work() latter.
free_work() (in mm/vmalloc.c) processes list in LIFO order, so to free shadow after freeing
'module_region' kasan_module_free(module_region); should be called before vfree(module_region);

It will be racy still, but this is not so bad as potential crash that we have now.
Honestly, I have no idea how to fix this race nicely. Any suggestions?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
