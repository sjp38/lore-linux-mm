Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id ED7116B0256
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 16:27:50 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so209940275wic.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 13:27:50 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id fi7si9872572wic.91.2015.09.22.13.27.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 22 Sep 2015 13:27:49 -0700 (PDT)
Date: Tue, 22 Sep 2015 22:27:11 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 10/26] x86, pkeys: notify userspace about protection key
 faults
In-Reply-To: <5601B82F.6070601@sr71.net>
Message-ID: <alpine.DEB.2.11.1509222226090.5606@nanos>
References: <20150916174903.E112E464@viggo.jf.intel.com> <20150916174906.51062FBC@viggo.jf.intel.com> <alpine.DEB.2.11.1509222157050.5606@nanos> <5601B82F.6070601@sr71.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 22 Sep 2015, Dave Hansen wrote:
> On 09/22/2015 01:03 PM, Thomas Gleixner wrote:
> > On Wed, 16 Sep 2015, Dave Hansen wrote:
> >>  
> >> +static inline u16 vma_pkey(struct vm_area_struct *vma)
> >> +{
> >> +	u16 pkey = 0;
> >> +#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
> >> +	unsigned long f = vma->vm_flags;
> >> +	pkey |= (!!(f & VM_HIGH_ARCH_0)) << 0;
> >> +	pkey |= (!!(f & VM_HIGH_ARCH_1)) << 1;
> >> +	pkey |= (!!(f & VM_HIGH_ARCH_2)) << 2;
> >> +	pkey |= (!!(f & VM_HIGH_ARCH_3)) << 3;
> > 
> > Eew. What's wrong with:
> > 
> >      pkey = (vma->vm_flags & VM_PKEY_MASK) >> VM_PKEY_SHIFT;
> 
> I didn't do that only because we don't have any other need for
> VM_PKEY_MASK or VM_PKEY_SHIFT.  We could do:
> 
> #define VM_PKEY_MASK (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2...)
> 
> static inline u16 vma_pkey(struct vm_area_struct *vma)
> {
> 	int vm_pkey_shift = __ffs(VM_PKEY_MASK)
> 	return (vma->vm_flags & VM_PKEY_MASK) >> vm_pkey_shift;
> }
> 
> That's probably the same number of lines of code in the end.  The
> compiler _probably_ ends up doing the same thing either way.
> 
> >> +static u16 fetch_pkey(unsigned long address, struct task_struct *tsk)
> > 
> > So here we get a u16 and assign it to si_pkey
> > 
> >> +	if (boot_cpu_has(X86_FEATURE_OSPKE) && si_code == SEGV_PKUERR)
> >> +		info.si_pkey = fetch_pkey(address, tsk);
> > 
> > which is int.
> > 
> >> +			int _pkey; /* FIXME: protection key value??
> > 
> > Inconsistent at least.
> 
> So I defined all the kernel-internal types as u16 since I *know* the
> size of the hardware.
> 
> The user-exposed ones should probably be a bit more generic.  I did just
> realize that this is an int and my proposed syscall is a long.  That I
> definitely need to make consistent.
> 
> Does anybody care whether it's an int or a long?

long is frowned upon due to 32/64bit. Even if that key stuff is only
available on 64bit for now ....

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
