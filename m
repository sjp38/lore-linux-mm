Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D82F66B781C
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 23:44:25 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id x7so16394963pll.23
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 20:44:25 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l61si22891627plb.6.2018.12.05.20.44.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Dec 2018 20:44:24 -0800 (PST)
Date: Wed, 5 Dec 2018 20:44:13 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/6] __wr_after_init: write rare for static allocation
Message-ID: <20181206044413.GB24603@bombadil.infradead.org>
References: <20181204121805.4621-1-igor.stoppa@huawei.com>
 <20181204121805.4621-3-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204121805.4621-3-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@chromium.org>, igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 04, 2018 at 02:18:01PM +0200, Igor Stoppa wrote:
> +void *__wr_op(unsigned long dst, unsigned long src, __kernel_size_t len,
> +	      enum wr_op_type op)
> +{
> +	temporary_mm_state_t prev;
> +	unsigned long flags;
> +	unsigned long offset;
> +	unsigned long wr_poking_addr;
> +
> +	/* Confirm that the writable mapping exists. */
> +	BUG_ON(!wr_ready);
> +
> +	if (WARN_ONCE(op >= WR_OPS_NUMBER, "Invalid WR operation.") ||
> +	    WARN_ONCE(!is_wr_after_init(dst, len), "Invalid WR range."))
> +		return (void *)dst;
> +
> +	offset = dst - (unsigned long)&__start_wr_after_init;
> +	wr_poking_addr = wr_poking_base + offset;
> +	local_irq_save(flags);

Why not local_irq_disable()?  Do we have a use-case for wanting to access
this from interrupt context?

> +	/* XXX make the verification optional? */

Well, yes.  It seems like debug code to me.

> +	/* Randomize the poking address base*/
> +	wr_poking_base = TASK_UNMAPPED_BASE +
> +		(kaslr_get_random_long("Write Rare Poking") & PAGE_MASK) %
> +		(TASK_SIZE - (TASK_UNMAPPED_BASE + wr_range));

I don't think this is a great idea.  We want to use the same mm for both
static and dynamic wr memory, yes?  So we should have enough space for
all of ram, not splatter the static section all over the address space.

On x86-64 (4 level page tables), we have a 64TB space for all of physmem
and 128TB of user space, so we can place the base anywhere in a 64TB
range.
