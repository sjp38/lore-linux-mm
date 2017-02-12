Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 299386B0387
	for <linux-mm@kvack.org>; Sun, 12 Feb 2017 14:15:24 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y7so29473494wrc.7
        for <linux-mm@kvack.org>; Sun, 12 Feb 2017 11:15:24 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id p4si2536985wmp.14.2017.02.12.11.15.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 12 Feb 2017 11:15:23 -0800 (PST)
Date: Sun, 12 Feb 2017 20:15:20 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC][PATCH 3/7] x86, mpx: extend MPX prctl() to pass in size
 of bounds directory
In-Reply-To: <20170201232412.BB0806BA@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.20.1702122006230.3734@nanos>
References: <20170201232408.FA486473@viggo.jf.intel.com> <20170201232412.BB0806BA@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, kirill.shutemov@linux.intel.com

On Wed, 1 Feb 2017, Dave Hansen wrote:
> FIXME: we also need to ensure that we check the current state of the
> larger address space opt-in.  If we've opted in to larger address spaces
> we can not allow a small bounds directory to be used.  Also, if we've
> not opted in, we can not allow the larger bounds directory to be used.
> This can be fixed once the in-kernel API for opting in/out is settled.

Ok.

>  /* Register/unregister a process' MPX related resource */
> -#define MPX_ENABLE_MANAGEMENT()	mpx_enable_management()
> +#define MPX_ENABLE_MANAGEMENT(bd_size)	mpx_enable_management(bd_size)
>  #define MPX_DISABLE_MANAGEMENT()	mpx_disable_management()

Please add another tab before mpx_disable so both are aligned.

> -int mpx_enable_management(void)
> +int mpx_set_mm_bd_size(unsigned long bd_size)

static ?

> +{
> +	struct mm_struct *mm = current->mm;
> +
> +	switch ((unsigned long long)bd_size) {
> +	case 0:
> +		/* Legacy call to prctl(): */
> +		mm->context.mpx_bd_shift = 0;
> +		return 0;
> +	case MPX_BD_SIZE_BYTES_32:
> +		/* 32-bit, legacy-sized bounds directory: */
> +		if (is_64bit_mm(mm))
> +			return -EINVAL;
> +		mm->context.mpx_bd_shift = 0;
> +		return 0;
> +	case MPX_BD_BASE_SIZE_BYTES_64:
> +		/* 64-bit, legacy-sized bounds directory: */
> +		if (!is_64bit_mm(mm)
> +		// FIXME && ! opted-in to larger address space

Hmm. Confused. This is where we enable MPX and decode the requested address
space. How can an already opt in happen?

If that's a enable call for an already enabled thing, then we should catch
that at the call site, I think.

> +	case MPX_BD_BASE_SIZE_BYTES_64 << MPX_LARGE_BOUNDS_DIR_SHIFT:
> +		/*
> +		 * Non-legacy call, with larger directory.
> +		 * Note that there is no 32-bit equivalent for
> +		 * this case since its address space does not
> +		 * change sizes.
> +		 */
> +		if (!is_64bit_mm(mm))
> +			return -EINVAL;
> +		/*
> +		 * Do not let this be enabled unles we are on
> +		 * 5-level hardware *and* have that feature
> +		 * enabled. FIXME: need runtime check

Runtime check? Isn't the feature bit enough?

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
