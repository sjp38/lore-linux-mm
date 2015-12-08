Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4924D6B0255
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 13:15:44 -0500 (EST)
Received: by wmuu63 with SMTP id u63so191614112wmu.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 10:15:43 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id kj9si5825723wjb.72.2015.12.08.10.15.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 10:15:43 -0800 (PST)
Date: Tue, 8 Dec 2015 19:14:54 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 19/34] x86, pkeys: optimize fault handling in
 access_error()
In-Reply-To: <20151204011450.A07593D5@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1512081913570.3595@nanos>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011450.A07593D5@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com

On Thu, 3 Dec 2015, Dave Hansen wrote:
> diff -puN arch/x86/mm/fault.c~pkeys-15-access_error arch/x86/mm/fault.c
> --- a/arch/x86/mm/fault.c~pkeys-15-access_error	2015-12-03 16:21:26.872727820 -0800
> +++ b/arch/x86/mm/fault.c	2015-12-03 16:21:26.876728002 -0800
> @@ -900,10 +900,16 @@ bad_area(struct pt_regs *regs, unsigned
>  static inline bool bad_area_access_from_pkeys(unsigned long error_code,
>  		struct vm_area_struct *vma)
>  {
> +	/* This code is always called on the current mm */
> +	int foreign = 0;

arch_vma_access_permitted takes a bool ....

>  	if (!boot_cpu_has(X86_FEATURE_OSPKE))
>  		return false;
>  	if (error_code & PF_PK)
>  		return true;
> +	/* this checks permission keys on the VMA: */
> +	if (!arch_vma_access_permitted(vma, (error_code & PF_WRITE), foreign))
> +		return true;
>  	return false;
>  }
>  
> @@ -1091,6 +1097,8 @@ int show_unhandled_signals = 1;
>  static inline int
>  access_error(unsigned long error_code, struct vm_area_struct *vma)
>  {
> +	/* This is only called for the current mm, so: */
> +	int foreign = 0;

Ditto.

Other than that: Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
