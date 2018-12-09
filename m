Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 669B68E0001
	for <linux-mm@kvack.org>; Sun,  9 Dec 2018 17:23:06 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id v27-v6so2354961ljv.1
        for <linux-mm@kvack.org>; Sun, 09 Dec 2018 14:23:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m191sor2260507lfa.53.2018.12.09.14.23.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Dec 2018 14:23:04 -0800 (PST)
Subject: Re: [PATCH 2/6] __wr_after_init: write rare for static allocation
References: <20181204121805.4621-1-igor.stoppa@huawei.com>
 <20181204121805.4621-3-igor.stoppa@huawei.com>
 <20181206044413.GB24603@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <8959c79b-dd9d-8b1f-87b6-e2c971aa2342@gmail.com>
Date: Mon, 10 Dec 2018 00:22:56 +0200
MIME-Version: 1.0
In-Reply-To: <20181206044413.GB24603@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@chromium.org>, igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 06/12/2018 06:44, Matthew Wilcox wrote:
> On Tue, Dec 04, 2018 at 02:18:01PM +0200, Igor Stoppa wrote:
>> +void *__wr_op(unsigned long dst, unsigned long src, __kernel_size_t len,
>> +	      enum wr_op_type op)
>> +{
>> +	temporary_mm_state_t prev;
>> +	unsigned long flags;
>> +	unsigned long offset;
>> +	unsigned long wr_poking_addr;
>> +
>> +	/* Confirm that the writable mapping exists. */
>> +	BUG_ON(!wr_ready);
>> +
>> +	if (WARN_ONCE(op >= WR_OPS_NUMBER, "Invalid WR operation.") ||
>> +	    WARN_ONCE(!is_wr_after_init(dst, len), "Invalid WR range."))
>> +		return (void *)dst;
>> +
>> +	offset = dst - (unsigned long)&__start_wr_after_init;
>> +	wr_poking_addr = wr_poking_base + offset;
>> +	local_irq_save(flags);
> 
> Why not local_irq_disable()?  Do we have a use-case for wanting to access
> this from interrupt context?

No, not that I can think of. It was "just in case", but I can remove it.

>> +	/* XXX make the verification optional? */
> 
> Well, yes.  It seems like debug code to me.

Ok, I was not sure about this, because text_poke() does it as part of 
its normal operations.

>> +	/* Randomize the poking address base*/
>> +	wr_poking_base = TASK_UNMAPPED_BASE +
>> +		(kaslr_get_random_long("Write Rare Poking") & PAGE_MASK) %
>> +		(TASK_SIZE - (TASK_UNMAPPED_BASE + wr_range));
> 
> I don't think this is a great idea.  We want to use the same mm for both
> static and dynamic wr memory, yes?  So we should have enough space for
> all of ram, not splatter the static section all over the address space.
> 
> On x86-64 (4 level page tables), we have a 64TB space for all of physmem
> and 128TB of user space, so we can place the base anywhere in a 64TB
> range.

I was actually wondering about the dynamic part.
It's still not clear to me if it's possible to write the code in a 
sufficiently generic way that it could work on all 64 bit architectures.
I'll start with x86-64 as you suggest.

--
igor
