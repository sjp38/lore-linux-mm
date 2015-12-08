Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 799786B0254
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 10:16:37 -0500 (EST)
Received: by wmww144 with SMTP id w144so184989680wmw.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 07:16:37 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id s3si4859521wjw.65.2015.12.08.07.16.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 07:16:36 -0800 (PST)
Date: Tue, 8 Dec 2015 16:15:29 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 10/34] x86, pkeys: arch-specific protection bitsy
In-Reply-To: <20151204011438.E50D1498@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1512081523180.3595@nanos>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011438.E50D1498@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com

Dave,

On Thu, 3 Dec 2015, Dave Hansen wrote:
>  
> +static inline int vma_pkey(struct vm_area_struct *vma)

Shouldn't this return something unsigned?

> +{
> +	u16 pkey = 0;
> +#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
> +	unsigned long vma_pkey_mask = VM_PKEY_BIT0 | VM_PKEY_BIT1 |
> +				      VM_PKEY_BIT2 | VM_PKEY_BIT3;
> +	/*
> +	 * ffs is one-based, not zero-based, so bias back down by 1.
> +	 */
> +	int vm_pkey_shift = __builtin_ffsl(vma_pkey_mask) - 1;

Took me some time to figure out that this will resolve to a compile
time constant (hopefully). Is there a reason why we don't have a
VM_PKEY_SHIFT constant in the header file which makes that code just
simple and intuitive?

> +	/*
> +	 * gcc generates better code if we do this rather than:
> +	 * pkey = (flags & mask) >> shift
> +	 */
> +	pkey = (vma->vm_flags >> vm_pkey_shift) &
> +	       (vma_pkey_mask >> vm_pkey_shift);

My gcc (4.9) does it the other way round for whatever reason.

I really prefer to have this as simple as:

#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
#define VM_PKEY_MASK (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | VM_PKEY_BIT3)
#define VM_PKEY_SHIFT 
#else
#define VM_PKEY_MASK 0UL
#define VM_PKEY_SHIFT 0
#endif
    	 
static inline unsigned int vma_pkey(struct vm_area_struct *vma)
{
	 return (vma->vm_flags & VM_PKEY_MASK) >> VM_PKEY_SHIFT;
}

or 

#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
#define VM_PKEY_MASK (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | VM_PKEY_BIT3)
#define VM_PKEY_SHIFT 
static inline unsigned int vma_pkey(struct vm_area_struct *vma)
{
	 return (vma->vm_flags & VM_PKEY_MASK) >> VM_PKEY_SHIFT;
}
#else
static inline unsigned int vma_pkey(struct vm_area_struct *vma)
{
	 return 0;
}
#endif

Hmm?

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
