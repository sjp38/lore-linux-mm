Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E66546B02EB
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 05:41:12 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id s24-v6so292656plp.12
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 02:41:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r2-v6si1064355pgk.137.2018.10.26.02.41.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 26 Oct 2018 02:41:11 -0700 (PDT)
Date: Fri, 26 Oct 2018 11:41:05 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 02/17] prmem: write rare for static allocation
Message-ID: <20181026094105.GE3159@worktop.c.hoisthospitality.com>
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
 <20181023213504.28905-3-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181023213504.28905-3-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org, igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Oct 24, 2018 at 12:34:49AM +0300, Igor Stoppa wrote:
> +static __always_inline

That's far too large for inline.

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
> +
> +		local_irq_save(flags);
> +		page = virt_to_page(d);
> +		offset = d & ~PAGE_MASK;
> +		offset_complement = PAGE_SIZE - offset;
> +		size = min(n_bytes, offset_complement);
> +		base = (uintptr_t)vmap(&page, 1, VM_MAP, PAGE_KERNEL);
> +		if (WARN(!base, WR_ERR_PAGE_MSG)) {
> +			local_irq_restore(flags);
> +			return false;
> +		}
> +		memset((void *)(base + offset), c, size);
> +		vunmap((void *)base);

BUG

> +		d += size;
> +		n_bytes -= size;
> +		local_irq_restore(flags);
> +	}
> +	return true;
> +}
> +
> +static __always_inline

Similarly large

> +bool wr_memcpy(const void *dst, const void *src, size_t n_bytes)
> +{
> +	size_t size;
> +	unsigned long flags;
> +	uintptr_t d = (uintptr_t)dst;
> +	uintptr_t s = (uintptr_t)src;
> +
> +	if (WARN(!__is_wr_after_init(dst, n_bytes), WR_ERR_RANGE_MSG))
> +		return false;
> +	while (n_bytes) {
> +		struct page *page;
> +		uintptr_t base;
> +		uintptr_t offset;
> +		uintptr_t offset_complement;
> +
> +		local_irq_save(flags);
> +		page = virt_to_page(d);
> +		offset = d & ~PAGE_MASK;
> +		offset_complement = PAGE_SIZE - offset;
> +		size = (size_t)min(n_bytes, offset_complement);
> +		base = (uintptr_t)vmap(&page, 1, VM_MAP, PAGE_KERNEL);
> +		if (WARN(!base, WR_ERR_PAGE_MSG)) {
> +			local_irq_restore(flags);
> +			return false;
> +		}
> +		__write_once_size((void *)(base + offset), (void *)s, size);
> +		vunmap((void *)base);

Similarly BUG.

> +		d += size;
> +		s += size;
> +		n_bytes -= size;
> +		local_irq_restore(flags);
> +	}
> +	return true;
> +}

> +static __always_inline

Guess what..

> +uintptr_t __wr_rcu_ptr(const void *dst_p_p, const void *src_p)
> +{
> +	unsigned long flags;
> +	struct page *page;
> +	void *base;
> +	uintptr_t offset;
> +	const size_t size = sizeof(void *);
> +
> +	if (WARN(!__is_wr_after_init(dst_p_p, size), WR_ERR_RANGE_MSG))
> +		return (uintptr_t)NULL;
> +	local_irq_save(flags);
> +	page = virt_to_page(dst_p_p);
> +	offset = (uintptr_t)dst_p_p & ~PAGE_MASK;
> +	base = vmap(&page, 1, VM_MAP, PAGE_KERNEL);
> +	if (WARN(!base, WR_ERR_PAGE_MSG)) {
> +		local_irq_restore(flags);
> +		return (uintptr_t)NULL;
> +	}
> +	rcu_assign_pointer((*(void **)(offset + (uintptr_t)base)), src_p);
> +	vunmap(base);

Also still bug.

> +	local_irq_restore(flags);
> +	return (uintptr_t)src_p;
> +}

Also, I see an amount of duplication here that shows you're not nearly
lazy enough.
