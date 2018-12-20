Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 18D928E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 13:49:30 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id a10so1987540plp.14
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 10:49:30 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y15si19133454pgf.321.2018.12.20.10.49.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 20 Dec 2018 10:49:28 -0800 (PST)
Date: Thu, 20 Dec 2018 10:49:18 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 04/12] __wr_after_init: x86_64: __wr_op
Message-ID: <20181220184917.GY10600@bombadil.infradead.org>
References: <20181219213338.26619-1-igor.stoppa@huawei.com>
 <20181219213338.26619-5-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219213338.26619-5-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 19, 2018 at 11:33:30PM +0200, Igor Stoppa wrote:
> +void *__wr_op(unsigned long dst, unsigned long src, __kernel_size_t len,
> +	      enum wr_op_type op)
> +{
> +	temporary_mm_state_t prev;
> +	unsigned long offset;
> +	unsigned long wr_poking_addr;
> +
> +	/* Confirm that the writable mapping exists. */
> +	if (WARN_ONCE(!wr_ready, "No writable mapping available"))
> +		return (void *)dst;
> +
> +	if (WARN_ONCE(op >= WR_OPS_NUMBER, "Invalid WR operation.") ||
> +	    WARN_ONCE(!is_wr_after_init(dst, len), "Invalid WR range."))
> +		return (void *)dst;
> +
> +	offset = dst - (unsigned long)&__start_wr_after_init;
> +	wr_poking_addr = wr_poking_base + offset;
> +	local_irq_disable();
> +	prev = use_temporary_mm(wr_poking_mm);
> +
> +	if (op == WR_MEMCPY)
> +		copy_to_user((void __user *)wr_poking_addr, (void *)src, len);
> +	else if (op == WR_MEMSET)
> +		memset_user((void __user *)wr_poking_addr, (u8)src, len);
> +
> +	unuse_temporary_mm(prev);
> +	local_irq_enable();
> +	return (void *)dst;
> +}

I think you're causing yourself more headaches by implementing this "op"
function.  Here's some generic code:

void *wr_memcpy(void *dst, void *src, unsigned int len)
{
	wr_state_t wr_state;
	void *wr_poking_addr = __wr_addr(dst);

	local_irq_disable();
	wr_enable(&wr_state);
	__wr_memcpy(wr_poking_addr, src, len);
	wr_disable(&wr_state);
	local_irq_enable();

	return dst;
}

Now, x86 can define appropriate macros and functions to use the temporary_mm
functionality, and other architectures can do what makes sense to them.
