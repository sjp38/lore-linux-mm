Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id DC18D6B0035
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 12:19:03 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id g10so11471601pdj.15
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 09:19:03 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id kb2si933689pbc.123.2014.07.22.09.19.02
        for <linux-mm@kvack.org>;
        Tue, 22 Jul 2014 09:19:02 -0700 (PDT)
Message-ID: <53CE8EEC.2090402@intel.com>
Date: Tue, 22 Jul 2014 09:18:52 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 03/10] x86, mpx: add macro cpu_has_mpx
References: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com> <1405921124-4230-4-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1405921124-4230-4-git-send-email-qiaowei.ren@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/20/2014 10:38 PM, Qiaowei Ren wrote:
> +#ifdef CONFIG_X86_INTEL_MPX
> +#define cpu_has_mpx boot_cpu_has(X86_FEATURE_MPX)
> +#else
> +#define cpu_has_mpx 0
> +#endif /* CONFIG_X86_INTEL_MPX */

Is this enough checking?  Looking at the extension reference, it says:

> 9.3.3
> Enabling of Intel MPX States
> An OS can enable Intel MPX states to support software operation using bounds registers with the following steps:
> ? Verify the processor supports XSAVE/XRSTOR/XSETBV/XGETBV instructions and XCR0 by checking
> CPUID.1.ECX.XSAVE[bit 26]=1.

That, I assume the xsave code is already doing.

> ? Verify the processor supports both Intel MPX states by checking CPUID.(EAX=0x0D, ECX=0):EAX[4:3] is 11b.

I see these bits _attempting_ to get set in pcntxt_mask via XCNTXT_MASK.
 But, I don't see us ever actually checking that they _do_ get set.  For
instance, we do this for:

>         if ((pcntxt_mask & XSTATE_FPSSE) != XSTATE_FPSSE) {
>                 pr_err("FP/SSE not shown under xsave features 0x%llx\n",
>                        pcntxt_mask);
>                 BUG();
>         }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
