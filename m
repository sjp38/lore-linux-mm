Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA8176B0005
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 20:24:29 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x2-v6so4191528pgr.8
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 17:24:29 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b20-v6si6261837pgk.360.2018.10.24.17.24.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 17:24:28 -0700 (PDT)
Subject: Re: [PATCH 02/17] prmem: write rare for static allocation
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
 <20181023213504.28905-3-igor.stoppa@huawei.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <23022d8a-dcef-20d5-cb07-a218b08b7b9a@intel.com>
Date: Wed, 24 Oct 2018 17:24:27 -0700
MIME-Version: 1.0
In-Reply-To: <20181023213504.28905-3-igor.stoppa@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> +static __always_inline bool __is_wr_after_init(const void *ptr, size_t size)
> +{
> +	size_t start = (size_t)&__start_wr_after_init;
> +	size_t end = (size_t)&__end_wr_after_init;
> +	size_t low = (size_t)ptr;
> +	size_t high = (size_t)ptr + size;
> +
> +	return likely(start <= low && low < high && high <= end);
> +}

size_t is an odd type choice for doing address arithmetic.

> +/**
> + * wr_memset() - sets n bytes of the destination to the c value
> + * @dst: beginning of the memory to write to
> + * @c: byte to replicate
> + * @size: amount of bytes to copy
> + *
> + * Returns true on success, false otherwise.
> + */
> +static __always_inline
> +bool wr_memset(const void *dst, const int c, size_t n_bytes)
> +{
> +	size_t size;
> +	unsigned long flags;
> +	uintptr_t d = (uintptr_t)dst;
> +
> +	if (WARN(!__is_wr_after_init(dst, n_bytes), WR_ERR_RANGE_MSG))
> +		return false;
> +	while (n_bytes) {
> +		struct page *page;
> +		uintptr_t base;
> +		uintptr_t offset;
> +		uintptr_t offset_complement;

Again, these are really odd choices for types.  vmap() returns a void*
pointer, on which you can do arithmetic.  Why bother keeping another
type to which you have to cast to and from?

BTW, our usual "pointer stored in an integer type" is 'unsigned long',
if a pointer needs to be manipulated.

> +		local_irq_save(flags);

Why are you doing the local_irq_save()?

> +		page = virt_to_page(d);
> +		offset = d & ~PAGE_MASK;
> +		offset_complement = PAGE_SIZE - offset;
> +		size = min(n_bytes, offset_complement);
> +		base = (uintptr_t)vmap(&page, 1, VM_MAP, PAGE_KERNEL);

Can you even call vmap() (which sleeps) with interrupts off?

> +		if (WARN(!base, WR_ERR_PAGE_MSG)) {
> +			local_irq_restore(flags);
> +			return false;
> +		}

You really need some kmap_atomic()-style accessors to wrap this stuff
for you.  This little pattern is repeated over and over.

...
> +const char WR_ERR_RANGE_MSG[] = "Write rare on invalid memory range.";
> +const char WR_ERR_PAGE_MSG[] = "Failed to remap write rare page.";

Doesn't the compiler de-duplicate duplicated strings for you?  Is there
any reason to declare these like this?
