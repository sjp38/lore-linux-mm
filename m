Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 39DF06B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 01:29:50 -0500 (EST)
Received: by pablf10 with SMTP id lf10so2843772pab.6
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 22:29:49 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id nq6si8551957pbc.101.2015.02.24.22.29.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 22:29:49 -0800 (PST)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] kasan, module, vmalloc: rework shadow allocation for modules
In-Reply-To: <54EC7563.8090801@samsung.com>
References: <1424281467-2593-1-git-send-email-a.ryabinin@samsung.com> <87pp96stmz.fsf@rustcorp.com.au> <54E5E355.9020404@samsung.com> <87fva1sajo.fsf@rustcorp.com.au> <54E6E684.4070806@samsung.com> <87vbithw4b.fsf@rustcorp.com.au> <54EC7563.8090801@samsung.com>
Date: Wed, 25 Feb 2015 16:55:53 +1030
Message-ID: <874mqamrri.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>

Andrey Ryabinin <a.ryabinin@samsung.com> writes:
> On 02/23/2015 11:26 AM, Rusty Russell wrote:
>> Andrey Ryabinin <a.ryabinin@samsung.com> writes:
>>> On 02/20/2015 03:15 AM, Rusty Russell wrote:
>>>> Andrey Ryabinin <a.ryabinin@samsung.com> writes:
>>>>> On 02/19/2015 02:10 AM, Rusty Russell wrote:
>>>>>> This is not portable.  Other archs don't use vmalloc, or don't use
>>>>>> (or define) MODULES_VADDR.  If you really want to hook here, you'd
>>>>>> need a new flag (or maybe use PAGE_KERNEL_EXEC after an audit).
>>>>>>
>>>>>
>>>>> Well, instead of explicit (addr >= MODULES_VADDR && addr < MODULES_END)
>>>>> I could hide this into arch-specific function: 'kasan_need_to_allocate_shadow(const void *addr)'
>>>>> or make make all those functions weak and allow arch code to redefine them.
>>>>
>>>> That adds another layer of indirection.  And how would the caller of
>>>> plain vmalloc() even know what to return?
>>>>
>>>
>>> I think I don't understand what do you mean here. vmalloc() callers shouldn't know
>>> anything about kasan/shadow.
>> 
>> How else would kasan_need_to_allocate_shadow(const void *addr) work for
>> architectures which don't have a reserved vmalloc region for modules?
>> 
>
>
> I think I need to clarify what I'm doing.
>
> Address sanitizer algorithm in short:
> -------------------------------------
> Every memory access is transformed by the compiler in the following way:
>
> Before:
> 	*address = ...;
>
> after:
>
> 	if (memory_is_poisoned(address)) {
> 		report_error(address, access_size);
> 	}
> 	*address = ...;
>
> where memory_is_poisoned():
> 	bool memory_is_poisoned(unsigned long addr)
> 	{
>         	s8 shadow_value = *(s8 *)kasan_mem_to_shadow((void *)addr);
> 	        if (unlikely(shadow_value)) {
>         	        s8 last_accessible_byte = addr & KASAN_SHADOW_MASK;
>                 	return unlikely(last_accessible_byte >= shadow_value);
> 	        }
> 	        return false;
> 	}
> --------------------------------------
>
> So shadow memory should be present for every accessible address in kernel
> otherwise it will be unhandled page fault on reading shadow value.
>
> Shadow for vmalloc addresses (on x86_64) is readonly mapping of one zero page.
> Zero byte in shadow means that it's ok to access to that address.
> Currently we don't catch bugs in vmalloc because most of such bugs could be caught
> in more simple way with CONFIG_DEBUG_PAGEALLOC.
> That's why we don't need RW shadow for vmalloc, it just one zero page that readonly
> mapped early on boot for the whole [kasan_mem_to_shadow(VMALLOC_START, kasan_mem_to_shadow(VMALLOC_END)] range
> So every access to vmalloc range assumed to be valid.
>
> To catch out of bounds accesses in global variables we need to fill shadow corresponding
> to variable's redzone with non-zero (negative) values.
> So for kernel image and modules we need a writable shadow.
>
> If some arch don't have separate address range for modules and it uses general vmalloc()
> shadow for vmalloc should be writable, so it means that shadow has to be allocated
> for every vmalloc() call.
>
> In such arch kasan_need_to_allocate_shadow(const void *addr) should return true for every vmalloc address:
> bool kasan_need_to_allocate_shadow(const void *addr)
> {
> 	return addr >= VMALLOC_START && addr < VMALLOC_END;
> }

Thanks for the explanation.

> All above means that current code is not very portable.
> And 'kasan_module_alloc(p, size) after module alloc' approach is not portable
> too. This won't work for arches that use [VMALLOC_START, VMALLOC_END] addresses for modules,
> because now we need to handle all vmalloc() calls.

I'm confused.  That's what you do now, and it hasn't been a problem,
has it?  The problem is on the freeing from interrupt context...

How about:

#define VM_KASAN		0x00000080      /* has shadow kasan map */

Set that in kasan_module_alloc():

        if (ret) {
                struct vm_struct *vma = find_vm_area(addr);

                BUG_ON(!vma);
                /* Set VM_KASAN so vfree() can free up shadow. */
                vma->flags |= VM_KASAN;
        }

And check that in __vunmap():

        if (area->flags & VM_KASAN)
                kasan_module_free(addr);

That is portable, and is actually a fairly small patch on what you
have at the moment.

What am I missing?

Thanks,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
