Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C5C356B0273
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 11:06:12 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id j10-v6so7856454pgv.6
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 08:06:12 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id e2-v6si301634pfn.271.2018.06.12.08.06.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 08:06:11 -0700 (PDT)
Message-ID: <1528815781.8271.15.camel@2b52.sc.intel.com>
Subject: Re: [PATCH 01/10] x86/cet: User-mode shadow stack support
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Tue, 12 Jun 2018 08:03:01 -0700
In-Reply-To: <0e80c181-83b2-457f-a419-01e79f94ca1c@gmail.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
	 <20180607143807.3611-2-yu-cheng.yu@intel.com>
	 <0e80c181-83b2-457f-a419-01e79f94ca1c@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter
 Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>

On Tue, 2018-06-12 at 21:56 +1000, Balbir Singh wrote:
> 
> On 08/06/18 00:37, Yu-cheng Yu wrote:
> > This patch adds basic shadow stack enabling/disabling routines.
> > A task's shadow stack is allocated from memory with VM_SHSTK
> > flag set and read-only protection.  The shadow stack is
> > allocated to a fixed size and that can be changed by the system
> > admin.
> > 
> 
> I presume a read-only permission on the kernel side, but it
> can be written by hardware?

Yes, the shadow stack is written by the processor when a call
instruction is executed.

...

> > 
> > diff --git a/arch/x86/include/asm/cet.h b/arch/x86/include/asm/cet.h
> > new file mode 100644
> > index 000000000000..9d5bc1efc9b7
> > --- /dev/null
> > +++ b/arch/x86/include/asm/cet.h
> > @@ -0,0 +1,32 @@
> > +/* SPDX-License-Identifier: GPL-2.0 */
> > +#ifndef _ASM_X86_CET_H
> > +#define _ASM_X86_CET_H
> > +
> > +#ifndef __ASSEMBLY__
> > +#include <linux/types.h>
> > +
> > +struct task_struct;
> > +/*
> > + * Per-thread CET status
> > + */
> > +struct cet_stat {
> 
> stat sounds like statistics, just expand out to status please

I will make it 'cet_status'.

> > +	unsigned long	shstk_base;
> > +	unsigned long	shstk_size;
> > +	unsigned int	shstk_enabled:1;
> > +};
> > +
> > +#ifdef CONFIG_X86_INTEL_CET
> > +unsigned long cet_get_shstk_ptr(void);
> 
> For the current task? Why does _ptr routine return an unsigned long?

What about cet_get_shstk_addr()?

...

> > diff --git a/arch/x86/include/asm/msr-index.h b/arch/x86/include/asm/msr-index.h
> > index fda2114197b3..428d13828ba9 100644
> > --- a/arch/x86/include/asm/msr-index.h
> > +++ b/arch/x86/include/asm/msr-index.h
> > @@ -770,4 +770,18 @@
> >  #define MSR_VM_IGNNE                    0xc0010115
> >  #define MSR_VM_HSAVE_PA                 0xc0010117
> >  
> > +/* Control-flow Enforcement Technology MSRs */
> > +#define MSR_IA32_U_CET		0x6a0
> > +#define MSR_IA32_S_CET		0x6a2
> > +#define MSR_IA32_PL0_SSP	0x6a4
> > +#define MSR_IA32_PL3_SSP	0x6a7
> > +#define MSR_IA32_INT_SSP_TAB	0x6a8
> 
> some comments on the purpose of the MSR would be nice

Sure.

...

> 
> I think there was a comment about this being TASK_SIZE_MAX
> 
> > +
> > +	rdmsrl(MSR_IA32_U_CET, r);
> > +	wrmsrl(MSR_IA32_U_CET, r | MSR_IA32_CET_SHSTK_EN);
> > +	wrmsrl(MSR_IA32_PL3_SSP, addr);
> 
> Should the enable happen before setting addr? I would expect to do this in the opposite order.

I will check.

> > +	return 0;
> > +}
> > +
> > +unsigned long cet_get_shstk_ptr(void)
> > +{
> > +	unsigned long ptr;
> > +
> > +	if (!current->thread.cet.shstk_enabled)
> > +		return 0;
> > +
> > +	rdmsrl(MSR_IA32_PL3_SSP, ptr);
> > +	return ptr;
> > +}
> > +
> > +static unsigned long shstk_mmap(unsigned long addr, unsigned long len)
> > +{
> > +	struct mm_struct *mm = current->mm;
> > +	unsigned long populate;
> > +
> > +	down_write(&mm->mmap_sem);
> > +	addr = do_mmap(NULL, addr, len, PROT_READ,
> > +		       MAP_ANONYMOUS | MAP_PRIVATE, VM_SHSTK,
> > +		       0, &populate, NULL);
> > +	up_write(&mm->mmap_sem);
> 
> What happens if the mmap fails for any reason? I presume the caller disables shadow stack on this process?

This is from exec(), and that fails.

> > +
> > +	if (populate)
> > +		mm_populate(addr, populate);
> > +
> > +	return addr;
> > +}
> > +
> > +int cet_setup_shstk(void)
> > +{
> > +	unsigned long addr, size;
> > +
> > +	if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
> > +		return -EOPNOTSUPP;
> > +
> > +	size = SHSTK_SIZE;
> > +	addr = shstk_mmap(0, size);
> > +
> > +	if (addr >= TASK_SIZE)
> > +		return -ENOMEM;
> > +
> 
> TASK_SIZE_MAX?

Yes.

> 
> > +	cet_set_shstk_ptr(addr + size - sizeof(void *));
> > +	current->thread.cet.shstk_base = addr;
> > +	current->thread.cet.shstk_size = size;
> > +	current->thread.cet.shstk_enabled = 1;
> > +	return 0;
> > +}
> > +
> > +void cet_disable_shstk(void)
> > +{
> > +	u64 r;
> > +
> > +	if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
> > +		return;
> > +
> > +	rdmsrl(MSR_IA32_U_CET, r);
> > +	r &= ~(MSR_IA32_CET_SHSTK_EN);
> > +	wrmsrl(MSR_IA32_U_CET, r);
> > +	wrmsrl(MSR_IA32_PL3_SSP, 0);
> 
> Again, I'd expect the order to be the reverse
> 
> > +	current->thread.cet.shstk_enabled = 0;
> > +}
> > +
> > +void cet_disable_free_shstk(struct task_struct *tsk)
> > +{
> > +	if (!cpu_feature_enabled(X86_FEATURE_SHSTK) ||
> > +	    !tsk->thread.cet.shstk_enabled)
> > +		return;
> > +
> > +	if (tsk == current)
> > +		cet_disable_shstk();
> > +
> > +	/*
> > +	 * Free only when tsk is current or shares mm
> > +	 * with current but has its own shstk.
> > +	 */
> > +	if (tsk->mm && (tsk->mm == current->mm) &&
> > +	    (tsk->thread.cet.shstk_base)) {
> 
> Does the caller hold a reference to tsk->mm?

If (tsk->mm == current->mm), i.e. it is current or it is a pthread of
current, then yes.

Yu-cheng
