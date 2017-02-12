Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EE4506B0387
	for <linux-mm@kvack.org>; Sun, 12 Feb 2017 17:44:10 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id x4so35282476wme.3
        for <linux-mm@kvack.org>; Sun, 12 Feb 2017 14:44:10 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id m73si3060998wmg.161.2017.02.12.14.44.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 12 Feb 2017 14:44:09 -0800 (PST)
Date: Sun, 12 Feb 2017 23:44:06 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC][PATCH 5/7] x86, mpx: shrink per-mm MPX data
In-Reply-To: <20170201232414.8D9B9BAC@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.20.1702122334220.3734@nanos>
References: <20170201232408.FA486473@viggo.jf.intel.com> <20170201232414.8D9B9BAC@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, kirill.shutemov@linux.intel.com

On Wed, 1 Feb 2017, Dave Hansen wrote:
>  /*
> - * NULL is theoretically a valid place to put the bounds
> - * directory, so point this at an invalid address.
> + * These get stored into mm_context_t->mpx_directory_info.
> + * We could theoretically use bits 0 and 1, but those are
> + * used in the BNDCFGU register that also holds the bounds
> + * directory pointer.  To avoid confusion, use different bits.
>   */
> -#define MPX_INVALID_BOUNDS_DIR	((void __user *)-1)
> +#define MPX_INVALID_BOUNDS_DIR	(1UL<<2)
> +#define MPX_LARGE_BOUNDS_DIR	(1UL<<3)

Please keep them tabular aligned

>  static inline int mpx_bd_size_shift(struct mm_struct *mm)
>  {
> -	return mm->context.mpx_bd_shift;
> +	if (!kernel_managing_mpx_tables(mm))
> +		return 0;
> +	if (mm->context.mpx_directory_info & MPX_LARGE_BOUNDS_DIR)
> +		return MPX_LARGE_BOUNDS_DIR_SHIFT;
> +	return 0;

So now makes the inline sense.

> -int mpx_set_mm_bd_size(unsigned long bd_size)
> +int mpx_set_dir_size(unsigned long bd_size, unsigned long *mpx_directory_info)
>  {
>  	struct mm_struct *mm = current->mm;
> +	int ret = 0;
> +	bool large_dir = false;

>  	struct mm_struct *mm = current->mm;
> +	bool large_dir = false;
> +	int ret = 0;

Please

>  
>  	switch ((unsigned long long)bd_size) {
>  	case 0:
> -		/* Legacy call to prctl(): */
> -		mm->context.mpx_bd_shift = 0;
> -		return 0;
> +		/* Legacy call to prctl() */
> +		break;
>  	case MPX_BD_SIZE_BYTES_32:
>  		/* 32-bit, legacy-sized bounds directory: */
> -		if (is_64bit_mm(mm))
> -			return -EINVAL;
> -		mm->context.mpx_bd_shift = 0;
> -		return 0;
> +		if (is_64bit_mm(mm)) {
> +			ret = -EINVAL;
> +			break;

Why do you want to break in the error case instead of just returning the
error? In case of error it really makes no sense to fiddle with the large
page bit in the directory_info.

> +		}
> +		ret = 0;

It's already 0

> +		break;
>  	case MPX_BD_BASE_SIZE_BYTES_64:
>  		/* 64-bit, legacy-sized bounds directory: */
>  		if (!is_64bit_mm(mm)
>  		// FIXME && ! opted-in to larger address space
>  		)
> -			return -EINVAL;
> -		mm->context.mpx_bd_shift = 0;
> -		return 0;
> +			ret = -EINVAL;

See above

> +		break;
>  	case MPX_BD_BASE_SIZE_BYTES_64 << MPX_LARGE_BOUNDS_DIR_SHIFT:
>  		/*
>  		 * Non-legacy call, with larger directory.
> @@ -370,7 +372,7 @@ int mpx_set_mm_bd_size(unsigned long bd_
>  		 * change sizes.
>  		 */
>  		if (!is_64bit_mm(mm))
> -			return -EINVAL;
> +			ret = -EINVAL;

Ditto

>  		/*
>  		 * Do not let this be enabled unles we are on
>  		 * 5-level hardware *and* have that feature
> @@ -379,16 +381,20 @@ int mpx_set_mm_bd_size(unsigned long bd_
>  		if (!cpu_feature_enabled(X86_FEATURE_LA57)
>  		// FIXME && opted into larger address space
>  		)
> -			return -EINVAL;
> -		mm->context.mpx_bd_shift = MPX_LARGE_BOUNDS_DIR_SHIFT;
> -		return 0;
> +			ret = -EINVAL;
> +		if (ret)
> +			break;

This is outright silly.

> +		large_dir = true;
> +		break;
>  	}
> -	return -EINVAL;
> +	if (large_dir)
> +		(*mpx_directory_info) |= MPX_LARGE_BOUNDS_DIR;
> +	return ret;
>  }
>  
>  int mpx_enable_management(unsigned long bd_size)
>  {
> -	void __user *bd_base = MPX_INVALID_BOUNDS_DIR;
> +	void __user *bd_base;
>  	struct mm_struct *mm = current->mm;
>  	int ret = 0;
>  
> @@ -404,13 +410,16 @@ int mpx_enable_management(unsigned long
>  	 * unmap path; we can just use mm->context.bd_addr instead.
>  	 */
>  	bd_base = mpx_get_bounds_dir();
> +	if (bd_base == MPX_INVALID_BOUNDS_DIR)
> +		return -ENXIO;
> +
>  	down_write(&mm->mmap_sem);
> -	ret = mpx_set_mm_bd_size(bd_size);
> +	/* Mask out the invalid bit: */
> +	mm->context.mpx_directory_info &= ~MPX_INVALID_BOUNDS_DIR;

The handling of that bit is really confusing

> +	ret = mpx_set_dir_size(bd_size, &mm->context.mpx_directory_info);
>  	if (ret)
>  		goto out;

And what makes the thing invalid again in case of ret != 0?

> -	mm->context.bd_addr = bd_base;
> -	if (mm->context.bd_addr == MPX_INVALID_BOUNDS_DIR)
> -		ret = -ENXIO;
> +	mm->context.mpx_directory_info |= bd_base;
>  out:
>  	up_write(&mm->mmap_sem);
>  	return ret;

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
