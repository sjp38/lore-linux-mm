Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id DFCFA8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 12:46:55 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id v27-v6so701310ljv.1
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 09:46:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l15-v6sor14047098ljc.33.2018.12.20.09.46.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 09:46:53 -0800 (PST)
Subject: Re: [PATCH 04/12] __wr_after_init: x86_64: __wr_op
References: <20181219213338.26619-1-igor.stoppa@huawei.com>
 <20181219213338.26619-5-igor.stoppa@huawei.com>
 <87r2ecunc2.fsf@morokweng.localdomain>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <31a2fc9c-440b-ba09-b4b6-6ecacce63e01@gmail.com>
Date: Thu, 20 Dec 2018 19:46:44 +0200
MIME-Version: 1.0
In-Reply-To: <87r2ecunc2.fsf@morokweng.localdomain>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thiago Jung Bauermann <bauerman@linux.ibm.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On 20/12/2018 19:20, Thiago Jung Bauermann wrote:
> 
> Hello Igor,
> 
>> +/*
>> + * The following two variables are statically allocated by the linker
>> + * script at the the boundaries of the memory region (rounded up to
>> + * multiples of PAGE_SIZE) reserved for __wr_after_init.
>> + */
>> +extern long __start_wr_after_init;
>> +extern long __end_wr_after_init;
>> +
>> +static inline bool is_wr_after_init(unsigned long ptr, __kernel_size_t size)
>> +{
>> +	unsigned long start = (unsigned long)&__start_wr_after_init;
>> +	unsigned long end = (unsigned long)&__end_wr_after_init;
>> +	unsigned long low = ptr;
>> +	unsigned long high = ptr + size;
>> +
>> +	return likely(start <= low && low <= high && high <= end);
>> +}
>> +
>> +void *__wr_op(unsigned long dst, unsigned long src, __kernel_size_t len,
>> +	      enum wr_op_type op)
>> +{
>> +	temporary_mm_state_t prev;
>> +	unsigned long offset;
>> +	unsigned long wr_poking_addr;
>> +
>> +	/* Confirm that the writable mapping exists. */
>> +	if (WARN_ONCE(!wr_ready, "No writable mapping available"))
>> +		return (void *)dst;
>> +
>> +	if (WARN_ONCE(op >= WR_OPS_NUMBER, "Invalid WR operation.") ||
>> +	    WARN_ONCE(!is_wr_after_init(dst, len), "Invalid WR range."))
>> +		return (void *)dst;
>> +
>> +	offset = dst - (unsigned long)&__start_wr_after_init;
>> +	wr_poking_addr = wr_poking_base + offset;
>> +	local_irq_disable();
>> +	prev = use_temporary_mm(wr_poking_mm);
>> +
>> +	if (op == WR_MEMCPY)
>> +		copy_to_user((void __user *)wr_poking_addr, (void *)src, len);
>> +	else if (op == WR_MEMSET)
>> +		memset_user((void __user *)wr_poking_addr, (u8)src, len);
>> +
>> +	unuse_temporary_mm(prev);
>> +	local_irq_enable();
>> +	return (void *)dst;
>> +}
> 
> There's a lot of casting back and forth between unsigned long and void *
> (also in the previous patch). Is there a reason for that?

The intention is to ensure that algebraic operations between addresses 
are performed as intended, rather than gcc operating some incorrect 
optimization, wrongly assuming that two addresses belong to the same object.

Said this, I can certainly have a further look at the code and see if I 
can reduce the amount of casts. I do not like them either.

But I'm not sure how much can be dropped: if I start from (void *), then 
I have to cast them to unsigned long for the math.

And the xxx_user() operations require a (void __user *).

> My impression
> is that there would be less casts if variables holding addresses were
> declared as void * in the first place. 

It might save 1 or 2 casts. I'll do the count.

> In that case, it wouldn't hurt to
> have an additional argument in __rw_op() to carry the byte value for the
> WR_MEMSET operation.

Wouldn't it clobber one more register? Or can gcc figure out that it's 
not used? __wr_op() is not inline.

>> +
>> +#define TB (1UL << 40)

^^^^^^^^^^^^^^^^^^^^^^^^^^spurious

>> +
>> +struct mm_struct *copy_init_mm(void);
>> +void __init wr_poking_init(void)
>> +{
>> +	unsigned long start = (unsigned long)&__start_wr_after_init;
>> +	unsigned long end = (unsigned long)&__end_wr_after_init;
>> +	unsigned long i;
>> +	unsigned long wr_range;
>> +
>> +	wr_poking_mm = copy_init_mm();
>> +	if (WARN_ONCE(!wr_poking_mm, "No alternate mapping available."))
>> +		return;
>> +
>> +	wr_range = round_up(end - start, PAGE_SIZE);
>> +
>> +	/* Randomize the poking address base*/
>> +	wr_poking_base = TASK_UNMAPPED_BASE +
>> +		(kaslr_get_random_long("Write Rare Poking") & PAGE_MASK) %
>> +		(TASK_SIZE - (TASK_UNMAPPED_BASE + wr_range));
>> +
>> +	/*
>> +	 * Place 64TB of kernel address space within 128TB of user address
>> +	 * space, at a random page aligned offset.
>> +	 */
>> +	wr_poking_base = (((unsigned long)kaslr_get_random_long("WR Poke")) &
>> +			  PAGE_MASK) % (64 * _BITUL(40));
> 
> You're setting wr_poking_base twice in a row? Is this an artifact from
> rebase?

Yes, the first is a leftover. Thanks for spotting it.

--
igor
