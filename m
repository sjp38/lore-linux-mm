Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0C1A76B000A
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 00:15:42 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 1-v6so3967891qtp.10
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 21:15:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m60-v6si97329qva.9.2018.10.02.21.15.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 21:15:41 -0700 (PDT)
Date: Wed, 3 Oct 2018 06:15:57 +0200
From: Eugene Syromiatnikov <esyr@redhat.com>
Subject: Re: [RFC PATCH v4 19/27] x86/cet/shstk: Introduce WRUSS instruction
Message-ID: <20181003041557.GA22724@asgard.redhat.com>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
 <20180921150351.20898-20-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180921150351.20898-20-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Fri, Sep 21, 2018 at 08:03:43AM -0700, Yu-cheng Yu wrote:
> WRUSS is a new kernel-mode instruction but writes directly
> to user shadow stack memory.  This is used to construct
> a return address on the shadow stack for the signal
> handler.
> 
> This instruction can fault if the user shadow stack is
> invalid shadow stack memory.  In that case, the kernel does
> fixup.

"a fixup"

> 
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  arch/x86/include/asm/special_insns.h | 32 ++++++++++++++++++++++++++++
>  arch/x86/mm/fault.c                  |  9 ++++++++
>  2 files changed, 41 insertions(+)
> 
> diff --git a/arch/x86/include/asm/special_insns.h b/arch/x86/include/asm/special_insns.h
> index 317fc59b512c..c04e68ef47da 100644
> --- a/arch/x86/include/asm/special_insns.h
> +++ b/arch/x86/include/asm/special_insns.h
> @@ -237,6 +237,38 @@ static inline void clwb(volatile void *__p)
>  		: [pax] "a" (p));
>  }
>  
> +#ifdef CONFIG_X86_INTEL_CET
> +#if defined(CONFIG_IA32_EMULATION) || defined(CONFIG_X86_X32)
> +static inline int write_user_shstk_32(unsigned long addr, unsigned int val)
> +{
> +	asm_volatile_goto("1: wrussd %1, (%0)\n"
> +			  _ASM_EXTABLE(1b, %l[fail])
> +			  :: "r" (addr), "r" (val)
> +			  :: fail);
> +	return 0;
> +fail:
> +	return -1;

Should it...

> +}
> +#else
> +static inline int write_user_shstk_32(unsigned long addr, unsigned int val)
> +{
> +	WARN_ONCE(1, "write_user_shstk_32 used but not supported.\n");

"is/was used"

> +	return -EFAULT;
> +}
> +#endif
> +
> +static inline int write_user_shstk_64(unsigned long addr, unsigned long val)
> +{
> +	asm_volatile_goto("1: wrussq %1, (%0)\n"
> +			  _ASM_EXTABLE(1b, %l[fail])
> +			  :: "r" (addr), "r" (val)
> +			  :: fail);
> +	return 0;
> +fail:
> +	return -1;

...and it be -EPERM, if -EFAULT was returned earlier for write_user_shstk_32?

> +}
> +#endif /* CONFIG_X86_INTEL_CET */
> +
>  #define nop() asm volatile ("nop")
>  
>  
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index 7c3877a982f4..4d4ac57a4ba2 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -1305,6 +1305,15 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
>  		error_code |= X86_PF_USER;
>  		flags |= FAULT_FLAG_USER;
>  	} else {
> +		/*
> +		 * WRUSS is a kernel instrcution and but writes

"WRUSS is a kernel instruction but writes"

> +		 * to user shadow stack.  When a fault occurs,
> +		 * both X86_PF_USER and X86_PF_SHSTK are set.
> +		 * Clear X86_PF_USER here.
> +		 */
> +		if ((error_code & (X86_PF_USER | X86_PF_SHSTK)) ==
> +		    (X86_PF_USER | X86_PF_SHSTK))
> +			error_code &= ~X86_PF_USER;
>  		if (regs->flags & X86_EFLAGS_IF)
>  			local_irq_enable();
>  	}
> -- 
> 2.17.1
> 
