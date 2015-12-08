Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id DF5F36B0255
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 13:17:55 -0500 (EST)
Received: by wmuu63 with SMTP id u63so191683274wmu.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 10:17:55 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id i204si32011195wma.10.2015.12.08.10.17.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 10:17:55 -0800 (PST)
Date: Tue, 8 Dec 2015 19:17:05 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 20/34] x86, pkeys: differentiate instruction fetches
In-Reply-To: <20151204011452.AA84FFA8@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1512081915320.3595@nanos>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011452.AA84FFA8@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com

On Thu, 3 Dec 2015, Dave Hansen wrote:
>  static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
> -		bool write, bool foreign)
> +		bool write, bool execute, bool foreign)
....
> +	/*
> +	 * gups are always data accesses, not instruction
> +	 * fetches, so execute=0 here

Again. Can we please be consistent about booleans?

> +	 */
> +	if (!arch_vma_access_permitted(vma, write, 0, foreign))
>  		return -EFAULT;
>  	return 0;
>  }
> @@ -576,8 +580,11 @@ bool vma_permits_fault(struct vm_area_st
>  	/*
>  	 * The architecture might have a hardware protection
>  	 * mechanism other than read/write that can deny access.
> +	 *
> +	 * gup always represents data access, not instruction
> +	 * fetches, so execute=0 here:
>  	 */
> -	if (!arch_vma_access_permitted(vma, write, foreign))
> +	if (!arch_vma_access_permitted(vma, write, 0, foreign))
>  		return false;

Ditto.

Other than that: Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
