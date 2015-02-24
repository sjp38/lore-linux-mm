Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 353F86B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 07:58:25 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so33223474pdb.2
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 04:58:24 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id yc6si11553752pbc.16.2015.02.24.04.58.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 24 Feb 2015 04:58:24 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NKA00JZ71JXCXA0@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 24 Feb 2015 13:02:21 +0000 (GMT)
Message-id: <54EC7563.8090801@samsung.com>
Date: Tue, 24 Feb 2015 15:58:11 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] kasan, module,
 vmalloc: rework shadow allocation for modules
References: <1424281467-2593-1-git-send-email-a.ryabinin@samsung.com>
 <87pp96stmz.fsf@rustcorp.com.au> <54E5E355.9020404@samsung.com>
 <87fva1sajo.fsf@rustcorp.com.au> <54E6E684.4070806@samsung.com>
 <87vbithw4b.fsf@rustcorp.com.au>
In-reply-to: <87vbithw4b.fsf@rustcorp.com.au>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>

On 02/23/2015 11:26 AM, Rusty Russell wrote:
> Andrey Ryabinin <a.ryabinin@samsung.com> writes:
>> On 02/20/2015 03:15 AM, Rusty Russell wrote:
>>> Andrey Ryabinin <a.ryabinin@samsung.com> writes:
>>>> On 02/19/2015 02:10 AM, Rusty Russell wrote:
>>>>> This is not portable.  Other archs don't use vmalloc, or don't use
>>>>> (or define) MODULES_VADDR.  If you really want to hook here, you'd
>>>>> need a new flag (or maybe use PAGE_KERNEL_EXEC after an audit).
>>>>>
>>>>
>>>> Well, instead of explicit (addr >= MODULES_VADDR && addr < MODULES_END)
>>>> I could hide this into arch-specific function: 'kasan_need_to_allocate_shadow(const void *addr)'
>>>> or make make all those functions weak and allow arch code to redefine them.
>>>
>>> That adds another layer of indirection.  And how would the caller of
>>> plain vmalloc() even know what to return?
>>>
>>
>> I think I don't understand what do you mean here. vmalloc() callers shouldn't know
>> anything about kasan/shadow.
> 
> How else would kasan_need_to_allocate_shadow(const void *addr) work for
> architectures which don't have a reserved vmalloc region for modules?
> 


I think I need to clarify what I'm doing.

Address sanitizer algorithm in short:
-------------------------------------
Every memory access is transformed by the compiler in the following way:

Before:
	*address = ...;

after:

	if (memory_is_poisoned(address)) {
		report_error(address, access_size);
	}
	*address = ...;

where memory_is_poisoned():
	bool memory_is_poisoned(unsigned long addr)
	{
        	s8 shadow_value = *(s8 *)kasan_mem_to_shadow((void *)addr);
	        if (unlikely(shadow_value)) {
        	        s8 last_accessible_byte = addr & KASAN_SHADOW_MASK;
                	return unlikely(last_accessible_byte >= shadow_value);
	        }
	        return false;
	}
--------------------------------------

So shadow memory should be present for every accessible address in kernel
otherwise it will be unhandled page fault on reading shadow value.

Shadow for vmalloc addresses (on x86_64) is readonly mapping of one zero page.
Zero byte in shadow means that it's ok to access to that address.
Currently we don't catch bugs in vmalloc because most of such bugs could be caught
in more simple way with CONFIG_DEBUG_PAGEALLOC.
That's why we don't need RW shadow for vmalloc, it just one zero page that readonly
mapped early on boot for the whole [kasan_mem_to_shadow(VMALLOC_START, kasan_mem_to_shadow(VMALLOC_END)] range
So every access to vmalloc range assumed to be valid.

To catch out of bounds accesses in global variables we need to fill shadow corresponding
to variable's redzone with non-zero (negative) values.
So for kernel image and modules we need a writable shadow.

If some arch don't have separate address range for modules and it uses general vmalloc()
shadow for vmalloc should be writable, so it means that shadow has to be allocated
for every vmalloc() call.

In such arch kasan_need_to_allocate_shadow(const void *addr) should return true for every vmalloc address:
bool kasan_need_to_allocate_shadow(const void *addr)
{
	return addr >= VMALLOC_START && addr < VMALLOC_END;
}


All above means that current code is not very portable.
And 'kasan_module_alloc(p, size) after module alloc' approach is not portable
too. This won't work for arches that use [VMALLOC_START, VMALLOC_END] addresses for modules,
because now we need to handle all vmalloc() calls.

I really think that this patch after proposed addition of arch specific
'kasan_need_to_allocate_shadow(const void *addr)' is the simplest and best way to fix bug
and make it portable for other arches.
Though, I doubt that someone ever bother to port kasan on those arches
that don't have separate addresses for modules.


>>> Hmm, how about a hybrid:
>>>
>>> 1) Add kasan_module_alloc(p, size) after module alloc as your original.
>>> 2) Hook into vfree(), and ignore it if you can't find the map.
>>>
>>
>> That should work, but it looks messy IMO.
>>
>>> Or is the latter too expensive?
>>>
>>
>> Not sure whether this will be too expensive or not,
>> but definitely more expensive than simple (addr >= MODULES_VADDR && addr < MODULES_END) check.
> 
> Sure, if that check were portable.  If you ever wanted kasan on other
> vmalloc addresses it wouldn't work either.
> 
> I actually think this pattern is the *simplest* solution for auxilliary
> data like kasan.
> 
> Cheers,
> Rusty.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
