Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 00C396B0387
	for <linux-mm@kvack.org>; Sun, 12 Feb 2017 14:05:59 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id ez4so33721249wjd.2
        for <linux-mm@kvack.org>; Sun, 12 Feb 2017 11:05:59 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id r37si10804660wrb.159.2017.02.12.11.05.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 12 Feb 2017 11:05:58 -0800 (PST)
Date: Sun, 12 Feb 2017 20:05:53 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC][PATCH 2/7] x86, mpx: update MPX to grok larger bounds
 tables
In-Reply-To: <20170201232411.4B6B4220@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.20.1702122001070.3734@nanos>
References: <20170201232408.FA486473@viggo.jf.intel.com> <20170201232411.4B6B4220@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, kirill.shutemov@linux.intel.com

On Wed, 1 Feb 2017, Dave Hansen wrote:
>  /*
> - * The upper 28 bits [47:20] of the virtual address in 64-bit
> - * are used to index into bounds directory (BD).
> + * The uppermost bits [56:20] of the virtual address in 64-bit
> + * are used to index into bounds directory (BD).  On processors
> + * with support for smaller virtual address space size, the "56"
> + * is obviously smaller.

 ... space size, the upper limit is adjusted accordingly.

Or something like that,

> +/*
> + * Note: size of tables on 64-bit is not constant, so we have no
> + * fixed definition for MPX_BD_NR_ENTRIES_64.
> + *
> + * The 5-Level Paging Whitepaper says:  "A bound directory
> + * comprises 2^(28+MAWA) 64-bit entries."  Since MAWA=0 in
> + * legacy mode:
> + */
> +#define MPX_BD_LEGACY_NR_ENTRIES_64	(1UL<<28)

(1UL << 28) please

>  
> +static inline int mpx_bd_size_shift(struct mm_struct *mm)
> +{
> +	return mm->context.mpx_bd_shift;
> +}

Do we really need that helper?

>  static inline unsigned long mpx_bd_size_bytes(struct mm_struct *mm)
>  {
> -	if (is_64bit_mm(mm))
> -		return MPX_BD_SIZE_BYTES_64;
> -	else
> +	if (!is_64bit_mm(mm))
>  		return MPX_BD_SIZE_BYTES_32;
> +
> +	/*
> +	 * The bounds directory grows with the address space size.
> +	 * The "legacy" shift is 0.
> +	 */
> +	return MPX_BD_BASE_SIZE_BYTES_64 << mpx_bd_shift_shift(mm);

shift_shift. I wonder how that compiles...

Looks good otherwise.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
