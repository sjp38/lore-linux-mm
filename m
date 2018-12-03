Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D448B6B6716
	for <linux-mm@kvack.org>; Sun,  2 Dec 2018 23:03:04 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id k58so5858555eda.20
        for <linux-mm@kvack.org>; Sun, 02 Dec 2018 20:03:04 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id bs9-v6si753849ejb.272.2018.12.02.20.03.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Dec 2018 20:03:02 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB33wrAr107504
	for <linux-mm@kvack.org>; Sun, 2 Dec 2018 23:03:01 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2p4rwnra72-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 02 Dec 2018 23:03:01 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Mon, 3 Dec 2018 04:02:59 -0000
Date: Sun, 2 Dec 2018 20:02:49 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <6f9c65fb-ea7e-8217-a4cc-f93e766ed9bb@intel.com>
 <87k1ln8o7u.fsf@oldenburg.str.redhat.com>
 <20181108201231.GE5481@ram.oc3035372033.ibm.com>
 <87bm6z71yw.fsf@oldenburg.str.redhat.com>
 <20181109180947.GF5481@ram.oc3035372033.ibm.com>
 <87efbqqze4.fsf@oldenburg.str.redhat.com>
 <20181127102350.GA5795@ram.oc3035372033.ibm.com>
 <87zhtuhgx0.fsf@oldenburg.str.redhat.com>
 <58e263a6-9a93-46d6-c5f9-59973064d55e@intel.com>
 <87va4g5d3o.fsf@oldenburg.str.redhat.com>
MIME-Version: 1.0
In-Reply-To: <87va4g5d3o.fsf@oldenburg.str.redhat.com>
Message-Id: <20181203040249.GA11930@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Thu, Nov 29, 2018 at 12:37:15PM +0100, Florian Weimer wrote:
> * Dave Hansen:
> 
> > On 11/27/18 3:57 AM, Florian Weimer wrote:
> >> I would have expected something that translates PKEY_DISABLE_WRITE |
> >> PKEY_DISABLE_READ into PKEY_DISABLE_ACCESS, and also accepts
> >> PKEY_DISABLE_ACCESS | PKEY_DISABLE_READ, for consistency with POWER.
> >> 
> >> (My understanding is that PKEY_DISABLE_ACCESS does not disable all
> >> access, but produces execute-only memory.)
> >
> > Correct, it disables all data access, but not execution.
> 
> So I would expect something like this (completely untested, I did not
> even compile this):


Ok. I re-read through the entire email thread to understand the problem and
the proposed solution. Let me summarize it below. Lets see if we are on the same
plate.

So the problem is as follows:

Currently the kernel supports  'disable-write'  and 'disable-access'.

On x86, cpu supports 'disable-write' and 'disable-access'. This
matches with what the kernel supports. All good.

However on power, cpu supports 'disable-read' too. Since userspace can
program the cpu directly, userspace has the ability to set
'disable-read' too.  This can lead to inconsistency between the kernel
and the userspace.

We want the kernel to match userspace on all architectures.

Proposed Solution:

Enhance the kernel to understand 'disable-read', and facilitate architectures
that understand 'disable-read' to allow it.

Also explicitly define the semantics of disable-access  as 
'disable-read and disable-write'

Did I get this right?  Assuming I did, the implementation has to do
the following --
  
	On power, sys_pkey_alloc() should succeed if the init_val
	is PKEY_DISABLE_READ, PKEY_DISABLE_WRITE, PKEY_DISABLE_ACCESS
	or any combination of the three.

	On x86, sys_pkey_alloc() should succeed if the init_val is
	PKEY_DISABLE_WRITE or PKEY_DISABLE_ACCESS or PKEY_DISABLE_READ
	or any combination of the three, except  PKEY_DISABLE_READ
      	specified all by itself.

	On all other arches, none of the flags are supported.


Are we on the same plate?
RP


> 
> diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
> index 20ebf153c871..bed23f9e8336 100644
> --- a/arch/powerpc/include/asm/pkeys.h
> +++ b/arch/powerpc/include/asm/pkeys.h
> @@ -199,6 +199,11 @@ static inline bool arch_pkeys_enabled(void)
>  	return !static_branch_likely(&pkey_disabled);
>  }
> 
> +static inline bool arch_pkey_access_rights_valid(unsigned long rights)
> +{
> +	return (rights & ~(unsigned long)PKEY_ACCESS_MASK) == 0;
> +}
> +
>  extern void pkey_mm_init(struct mm_struct *mm);
>  extern bool arch_supports_pkeys(int cap);
>  extern unsigned int arch_usable_pkeys(void);
> diff --git a/arch/x86/include/asm/pkeys.h b/arch/x86/include/asm/pkeys.h
> index 19b137f1b3be..e3e1d5a316e8 100644
> --- a/arch/x86/include/asm/pkeys.h
> +++ b/arch/x86/include/asm/pkeys.h
> @@ -14,6 +14,17 @@ static inline bool arch_pkeys_enabled(void)
>  	return boot_cpu_has(X86_FEATURE_OSPKE);
>  }
> 
> +static inline bool arch_pkey_access_rights_valid(unsigned long rights)
> +{
> +	if (rights & ~(unsigned long)PKEY_ACCESS_MASK)
> +		return false;
> +	if (rights & PKEY_DISABLE_READ) {
> +		/* x86 can only disable read access along with write access. */
> +		return rights & (PKEY_DISABLE_WRITE | PKEY_DISABLE_ACCESS);
> +	}
> +	return true;
> +}
> +
>  /*
>   * Try to dedicate one of the protection keys to be used as an
>   * execute-only protection key.
> diff --git a/arch/x86/kernel/fpu/xstate.c b/arch/x86/kernel/fpu/xstate.c
> index 87a57b7642d3..b9b78145017f 100644
> --- a/arch/x86/kernel/fpu/xstate.c
> +++ b/arch/x86/kernel/fpu/xstate.c
> @@ -928,7 +928,13 @@ int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
>  		return -EINVAL;
> 
>  	/* Set the bits we need in PKRU:  */
> -	if (init_val & PKEY_DISABLE_ACCESS)
> +	if (init_val & (PKEY_DISABLE_ACCESS | PKEY_DISABLE_READ))
> +		/*
> +		 * arch_pkey_access_rights_valid checked that
> +		 * PKEY_DISABLE_READ is actually representable on x86
> +		 * (that is, it comes with PKEY_DISABLE_ACCESS or
> +		 * PKEY_DISABLE_WRITE).
> +		 */
>  		new_pkru_bits |= PKRU_AD_BIT;
>  	if (init_val & PKEY_DISABLE_WRITE)
>  		new_pkru_bits |= PKRU_WD_BIT;
> diff --git a/include/linux/pkeys.h b/include/linux/pkeys.h
> index 2955ba976048..2c330fabbe55 100644
> --- a/include/linux/pkeys.h
> +++ b/include/linux/pkeys.h
> @@ -48,6 +48,11 @@ static inline void copy_init_pkru_to_fpregs(void)
>  {
>  }
> 
> +static inline bool arch_pkey_access_rights_valid(unsigned long rights)
> +{
> +	return false;
> +}
> +
>  #endif /* ! CONFIG_ARCH_HAS_PKEYS */
> 
>  #endif /* _LINUX_PKEYS_H */
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 6d331620b9e5..f4cefc3540df 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -597,7 +597,7 @@ SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
>  	if (flags)
>  		return -EINVAL;
>  	/* check for unsupported init values */
> -	if (init_val & ~PKEY_ACCESS_MASK)
> +	if (!arch_pkey_access_rights_valid(init_val))
>  		return -EINVAL;
> 
>  	down_write(&current->mm->mmap_sem);
> 
> Thanks,
> Florian

-- 
Ram Pai
