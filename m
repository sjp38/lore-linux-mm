Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4C9D26B039E
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 14:03:13 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id k21-v6so3466299ljg.20
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 11:03:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c10-v6sor3037168ljb.11.2018.10.29.11.03.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Oct 2018 11:03:11 -0700 (PDT)
Subject: Re: [PATCH 02/17] prmem: write rare for static allocation
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
 <20181023213504.28905-3-igor.stoppa@huawei.com>
 <23022d8a-dcef-20d5-cb07-a218b08b7b9a@intel.com>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <311d06ab-df6d-134a-82fc-1e2098f8a924@gmail.com>
Date: Mon, 29 Oct 2018 20:03:07 +0200
MIME-Version: 1.0
In-Reply-To: <23022d8a-dcef-20d5-cb07-a218b08b7b9a@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 25/10/2018 01:24, Dave Hansen wrote:
>> +static __always_inline bool __is_wr_after_init(const void *ptr, size_t size)
>> +{
>> +	size_t start = (size_t)&__start_wr_after_init;
>> +	size_t end = (size_t)&__end_wr_after_init;
>> +	size_t low = (size_t)ptr;
>> +	size_t high = (size_t)ptr + size;
>> +
>> +	return likely(start <= low && low < high && high <= end);
>> +}
> 
> size_t is an odd type choice for doing address arithmetic.

it seemed more portable than unsigned long

>> +/**
>> + * wr_memset() - sets n bytes of the destination to the c value
>> + * @dst: beginning of the memory to write to
>> + * @c: byte to replicate
>> + * @size: amount of bytes to copy
>> + *
>> + * Returns true on success, false otherwise.
>> + */
>> +static __always_inline
>> +bool wr_memset(const void *dst, const int c, size_t n_bytes)
>> +{
>> +	size_t size;
>> +	unsigned long flags;
>> +	uintptr_t d = (uintptr_t)dst;
>> +
>> +	if (WARN(!__is_wr_after_init(dst, n_bytes), WR_ERR_RANGE_MSG))
>> +		return false;
>> +	while (n_bytes) {
>> +		struct page *page;
>> +		uintptr_t base;
>> +		uintptr_t offset;
>> +		uintptr_t offset_complement;
> 
> Again, these are really odd choices for types.  vmap() returns a void*
> pointer, on which you can do arithmetic.  

I wasn't sure of how much I could rely on the compiler not doing some 
unwanted optimizations.

> Why bother keeping another
> type to which you have to cast to and from?

For the above reason. If I'm worrying unnecessarily, I can switch back 
to void *
It certainly is easier to use.

> BTW, our usual "pointer stored in an integer type" is 'unsigned long',
> if a pointer needs to be manipulated.

yes, I noticed that, but it seemed strange ...
size_t corresponds to unsigned long, afaik

but it seems that I have not fully understood where to use it

anyway, I can stick to the convention with unsigned long

> 
>> +		local_irq_save(flags);
> 
> Why are you doing the local_irq_save()?

The idea was to avoid the case where an attack would somehow freeze the 
core doing the write-rare operation, while the temporary mapping is 
accessible.

I have seen comments about using mappings that are private to the 
current core (and I will reply to those comments as well), but this 
approach seems architecture-dependent, while I was looking for a 
solution that, albeit not 100% reliable, would work on any system with 
an MMU. This would not prevent each arch to come up with own custom 
implementation that provides better coverage, performance, etc.

>> +		page = virt_to_page(d);
>> +		offset = d & ~PAGE_MASK;
>> +		offset_complement = PAGE_SIZE - offset;
>> +		size = min(n_bytes, offset_complement);
>> +		base = (uintptr_t)vmap(&page, 1, VM_MAP, PAGE_KERNEL);
> 
> Can you even call vmap() (which sleeps) with interrupts off?

I accidentally disabled sleeping while atomic debugging and I totally 
missed this problem :-(

However, to answer your question, nothing exploded while I was testing 
(without that type of debugging).

I suspect I was just "lucky". Or maybe I was simply not triggering the 
sleeping sub-case.

As I understood the code, sleeping _might_ happen, but it's not going to 
happen systematically.

I wonder if I could split vmap() into two parts: first the sleeping one, 
with interrupts enabled, then the non sleeping one, with interrupts 
disabled.

I need to read the code more carefully, but it seems that sleeping might 
happen when memory for the mapping meta data is not immediately available.

BTW, wouldn't the might_sleep() call belong more to the part which 
really sleeps, instead than to the whole vmap() ?

>> +		if (WARN(!base, WR_ERR_PAGE_MSG)) {
>> +			local_irq_restore(flags);
>> +			return false;
>> +		}
> 
> You really need some kmap_atomic()-style accessors to wrap this stuff
> for you.  This little pattern is repeated over and over.

I really need to learn more about the way the kernel works and is 
structured. It's a work in progress. Thanks for the advice.

> ...
>> +const char WR_ERR_RANGE_MSG[] = "Write rare on invalid memory range.";
>> +const char WR_ERR_PAGE_MSG[] = "Failed to remap write rare page.";
> 
> Doesn't the compiler de-duplicate duplicated strings for you?  Is there
> any reason to declare these like this?

I noticed I have made some accidental modifications in a couple of 
cases, when replicating the command.

So I thought that if I really want to use the same string, why not doing 
it explicitly? It seemed also easier, in case I want to tweak the 
message. I need to do it only in one place.

--
igor
