Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 75B0D6B0032
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 12:47:27 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so54828248pab.5
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:47:27 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id u5si11283932pde.139.2015.01.30.09.47.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 30 Jan 2015 09:47:26 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJ000LIL49QU9B0@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 30 Jan 2015 17:51:26 +0000 (GMT)
Message-id: <54CBC3A1.5040505@samsung.com>
Date: Fri, 30 Jan 2015 20:47:13 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v10 17/17] kasan: enable instrumentation of global variables
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
 <1422544321-24232-18-git-send-email-a.ryabinin@samsung.com>
 <20150129151332.3f87c0b2e335afd88af33e08@linux-foundation.org>
In-reply-to: <20150129151332.3f87c0b2e335afd88af33e08@linux-foundation.org>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Rusty Russell <rusty@rustcorp.com.au>, Michal Marek <mmarek@suse.cz>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>

On 01/30/2015 02:13 AM, Andrew Morton wrote:
> On Thu, 29 Jan 2015 18:12:01 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> 
>> This feature let us to detect accesses out of bounds
>> of global variables.
> 
> global variables *within modules*, I think?  More specificity needed here.

Within modules and within kernel image. Handling modules just the most
tricky part of this.

> 
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
>>
>> ...
>>
>> +int kasan_module_alloc(void *addr, size_t size)
>> +{
>> +
>> +	size_t shadow_size = round_up(size >> KASAN_SHADOW_SCALE_SHIFT,
>> +				PAGE_SIZE);
>> +	unsigned long shadow_start = kasan_mem_to_shadow((unsigned long)addr);
>> +	void *ret;
> 
> Like this:
> 
> 	size_t shadow_size;
> 	unsigned long shadow_start;
> 	void *ret;
> 
> 	shadow_size = round_up(size >> KASAN_SHADOW_SCALE_SHIFT, PAGE_SIZE);
> 	shadow_start = kasan_mem_to_shadow((unsigned long)addr);
> 
> it's much easier to read and avoids the 80-column trickery.
> 
> I do suspect that
> 
> 	void *kasan_mem_to_shadow(const void *addr);
> 
> would clean up lots and lots of code.
> 

Agreed.

>> +	if (WARN_ON(!PAGE_ALIGNED(shadow_start)))
>> +		return -EINVAL;
>> +
>> +	ret = __vmalloc_node_range(shadow_size, 1, shadow_start,
>> +			shadow_start + shadow_size,
>> +			GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
>> +			PAGE_KERNEL, VM_NO_GUARD, NUMA_NO_NODE,
>> +			__builtin_return_address(0));
>> +	return ret ? 0 : -ENOMEM;
>> +}
>> +
>>
>> ...
>>
>> +struct kasan_global {
>> +	const void *beg;		/* Address of the beginning of the global variable. */
>> +	size_t size;			/* Size of the global variable. */
>> +	size_t size_with_redzone;	/* Size of the variable + size of the red zone. 32 bytes aligned */
>> +	const void *name;
>> +	const void *module_name;	/* Name of the module where the global variable is declared. */
>> +	unsigned long has_dynamic_init;	/* This needed for C++ */
> 
> This can be removed?
> 

No, compiler dictates layout of this struct. That probably deserves a comment.

>> +#if KASAN_ABI_VERSION >= 4
>> +	struct kasan_source_location *location;
>> +#endif
>> +};
>>
>> ...
>>
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
