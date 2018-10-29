Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B3E56B04A1
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 16:01:27 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id 6-v6so1625209ljv.21
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 13:01:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l16-v6sor6268829ljh.14.2018.10.29.13.01.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Oct 2018 13:01:25 -0700 (PDT)
Subject: Re: [PATCH 02/17] prmem: write rare for static allocation
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
 <20181023213504.28905-3-igor.stoppa@huawei.com>
 <20181026094105.GE3159@worktop.c.hoisthospitality.com>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <e3ef00ef-3d28-2336-7bae-2e4f738a6e44@gmail.com>
Date: Mon, 29 Oct 2018 22:01:22 +0200
MIME-Version: 1.0
In-Reply-To: <20181026094105.GE3159@worktop.c.hoisthospitality.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org, igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 26/10/2018 10:41, Peter Zijlstra wrote:
> On Wed, Oct 24, 2018 at 12:34:49AM +0300, Igor Stoppa wrote:
>> +static __always_inline
> 
> That's far too large for inline.

The reason for it is that it's supposed to minimize the presence of 
gadgets that might be used in JOP attacks.
I am ready to stand corrected, if I'm wrong, but this is the reason why 
I did it.

Regarding the function being too large, yes, I would not normally choose 
it for inlining.

Actually, I would not normally use "__always_inline" and instead I would 
limit myself to plain "inline", at most.

> 
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
>> +
>> +		local_irq_save(flags);
>> +		page = virt_to_page(d);
>> +		offset = d & ~PAGE_MASK;
>> +		offset_complement = PAGE_SIZE - offset;
>> +		size = min(n_bytes, offset_complement);
>> +		base = (uintptr_t)vmap(&page, 1, VM_MAP, PAGE_KERNEL);
>> +		if (WARN(!base, WR_ERR_PAGE_MSG)) {
>> +			local_irq_restore(flags);
>> +			return false;
>> +		}
>> +		memset((void *)(base + offset), c, size);
>> +		vunmap((void *)base);
> 
> BUG

yes, somehow I managed to drop this debug configuration from the debug 
builds I made.

[...]

> Also, I see an amount of duplication here that shows you're not nearly
> lazy enough.

I did notice a certain amount of duplication, but I didn't know how to 
exploit it.

--
igor
