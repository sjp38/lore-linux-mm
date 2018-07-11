Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C9DE6B0269
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 05:45:00 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id q77-v6so1635210itc.2
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 02:45:00 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 201-v6si1216497itv.117.2018.07.11.02.44.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 11 Jul 2018 02:44:59 -0700 (PDT)
Date: Wed, 11 Jul 2018 11:44:48 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH v2 18/27] x86/cet/shstk: Introduce WRUSS instruction
Message-ID: <20180711094448.GZ2476@hirez.programming.kicks-ass.net>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-19-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180710222639.8241-19-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Tue, Jul 10, 2018 at 03:26:30PM -0700, Yu-cheng Yu wrote:
> WRUSS is a new kernel-mode instruction but writes directly
> to user shadow stack memory.  This is used to construct
> a return address on the shadow stack for the signal
> handler.
> 
> This instruction can fault if the user shadow stack is
> invalid shadow stack memory.  In that case, the kernel does
> fixup.
> 

> +static inline int write_user_shstk_64(unsigned long addr, unsigned long val)
> +{
> +	int err = 0;
> +
> +	asm volatile("1: wrussq %[val], (%[addr])\n"
> +		     "xor %[err], %[err]\n"

this XOR is superfluous, you already cleared @err above.

> +		     "2:\n"
> +		     ".section .fixup,\"ax\"\n"
> +		     "3: mov $-1, %[err]; jmp 2b\n"
> +		     ".previous\n"
> +		     _ASM_EXTABLE(1b, 3b)
> +		     : [err] "=a" (err)
> +		     : [val] "S" (val), [addr] "D" (addr));
> +
> +	return err;
> +}
> +#endif /* CONFIG_X86_INTEL_CET */
> +
>  #define nop() asm volatile ("nop")

What happened to:

  https://lkml.kernel.org/r/1528729376.4526.0.camel@2b52.sc.intel.com
