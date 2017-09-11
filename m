Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id BD9256B02A6
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 03:24:35 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id t184so11975037qke.0
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 00:24:35 -0700 (PDT)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id n63si6529287qtd.474.2017.09.11.00.24.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Sep 2017 00:24:34 -0700 (PDT)
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <302be94d-7e44-001d-286c-2b0cd6098f7b@huawei.com>
Date: Mon, 11 Sep 2017 15:24:09 +0800
MIME-Version: 1.0
In-Reply-To: <20170907173609.22696-4-tycho@docker.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, x86@kernel.org

Hi Tycho,

On 2017/9/8 1:36, Tycho Andersen wrote:
> From: Juerg Haefliger <juerg.haefliger@canonical.com>
> 
> This patch adds support for XPFO which protects against 'ret2dir' kernel
> attacks. The basic idea is to enforce exclusive ownership of page frames
> by either the kernel or userspace, unless explicitly requested by the
> kernel. Whenever a page destined for userspace is allocated, it is
> unmapped from physmap (the kernel's page table). When such a page is
> reclaimed from userspace, it is mapped back to physmap.
> 
> Additional fields in the page_ext struct are used for XPFO housekeeping,
> specifically:
>   - two flags to distinguish user vs. kernel pages and to tag unmapped
>     pages.
>   - a reference counter to balance kmap/kunmap operations.
>   - a lock to serialize access to the XPFO fields.
> 
> This patch is based on the work of Vasileios P. Kemerlis et al. who
> published their work in this paper:
>   http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf
> 
> [...]
> +void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
> +{
> +	int i, flush_tlb = 0;
> +	struct xpfo *xpfo;
> +
> +	if (!static_branch_unlikely(&xpfo_inited))
> +		return;
> +
> +	for (i = 0; i < (1 << order); i++)  {
> +		xpfo = lookup_xpfo(page + i);
> +		if (!xpfo)
> +			continue;
> +
> +		WARN(test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags),
> +		     "xpfo: unmapped page being allocated\n");
> +
> +		/* Initialize the map lock and map counter */
> +		if (unlikely(!xpfo->inited)) {
> +			spin_lock_init(&xpfo->maplock);
> +			atomic_set(&xpfo->mapcount, 0);
> +			xpfo->inited = true;
> +		}
> +		WARN(atomic_read(&xpfo->mapcount),
> +		     "xpfo: already mapped page being allocated\n");
> +
> +		if ((gfp & GFP_HIGHUSER) == GFP_HIGHUSER) {
> +			/*
> +			 * Tag the page as a user page and flush the TLB if it
> +			 * was previously allocated to the kernel.
> +			 */
> +			if (!test_and_set_bit(XPFO_PAGE_USER, &xpfo->flags))
> +				flush_tlb = 1;

I'm not sure whether I am miss anything, however, when the page was previously allocated
to kernel,  should we unmap the physmap (the kernel's page table) here? For we allocate
the page to user now

Yisheng Xie
Thanks


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
