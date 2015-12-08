Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8F64A6B0254
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 12:25:43 -0500 (EST)
Received: by wmuu63 with SMTP id u63so189906076wmu.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 09:25:43 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id yo9si5487958wjc.233.2015.12.08.09.25.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 09:25:42 -0800 (PST)
Date: Tue, 8 Dec 2015 18:24:35 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 10/34] x86, pkeys: arch-specific protection bitsy
In-Reply-To: <566706A1.3040906@sr71.net>
Message-ID: <alpine.DEB.2.11.1512081817160.3595@nanos>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011438.E50D1498@viggo.jf.intel.com> <alpine.DEB.2.11.1512081523180.3595@nanos> <566706A1.3040906@sr71.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com

Dave,

On Tue, 8 Dec 2015, Dave Hansen wrote:
> On 12/08/2015 07:15 AM, Thomas Gleixner wrote:
> > On Thu, 3 Dec 2015, Dave Hansen wrote:
> >>  
> >> +static inline int vma_pkey(struct vm_area_struct *vma)
> > 
> > Shouldn't this return something unsigned?
> 
> Ingo had asked that we use 'int' in the syscalls at some point.  We also
> use a -1 to mean "no pkey set" (to differentiate it from pkey=0) at
> least at the very top of the syscall level.

Ok.
 
> >> +{
> >> +	u16 pkey = 0;
> >> +#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
> >> +	unsigned long vma_pkey_mask = VM_PKEY_BIT0 | VM_PKEY_BIT1 |
> >> +				      VM_PKEY_BIT2 | VM_PKEY_BIT3;
> >> +	/*
> >> +	 * ffs is one-based, not zero-based, so bias back down by 1.
> >> +	 */
> >> +	int vm_pkey_shift = __builtin_ffsl(vma_pkey_mask) - 1;
> > 
> > Took me some time to figure out that this will resolve to a compile
> > time constant (hopefully). Is there a reason why we don't have a
> > VM_PKEY_SHIFT constant in the header file which makes that code just
> > simple and intuitive?
> 
> All of the VM_* flags are #defined as bitmaps directly and don't define
> shifts:
> 
> #define VM_MAYWRITE     0x00000020
> #define VM_MAYEXEC      0x00000040
> #define VM_MAYSHARE     0x00000080
> ...
> 
> So to get a shift we've either got to do a ffs somewhere, or we have to
> define the VM_PKEY_BIT*'s differently from all of the other VM_* flags.
>  Or, we do something along the lines of:
> 
> #define VM_PKEY_BIT0 0x100000000UL
> #define __VM_PKEY_SHIFT (32)

Well, yes. But these are the new "high" bits so we really can do it:

#define VM_KEY_BIT_SHIFT    32
#define VM_KEY_BIT0	    BIT(VM_KEY_BIT_SHIFT);
...
 
> and we run a small risk that somebody will desynchronize the shift and
> the bit definition.
> 
> We only need this shift in this *one* place, so that's why I opted for
> the local variable and ffs.
> 
> >> +	/*
> >> +	 * gcc generates better code if we do this rather than:
> >> +	 * pkey = (flags & mask) >> shift
> >> +	 */
> >> +	pkey = (vma->vm_flags >> vm_pkey_shift) &
> >> +	       (vma_pkey_mask >> vm_pkey_shift);
> > 
> > My gcc (4.9) does it the other way round for whatever reason.
> 
> I'll go recheck.

It's one instruction difference and that even depends on the offset of
vm_flags in the struct. So we really can go for the readable version :)

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
