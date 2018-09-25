Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF8C88E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 12:38:14 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id a26-v6so10315106pgw.7
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 09:38:14 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u129-v6si2547954pfb.247.2018.09.25.09.38.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 25 Sep 2018 09:38:13 -0700 (PDT)
Date: Tue, 25 Sep 2018 18:37:45 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH v4 02/27] x86/fpu/xstate: Change some names to
 separate XSAVES system and user states
Message-ID: <20180925163745.GC30146@hirez.programming.kicks-ass.net>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
 <20180921150351.20898-3-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180921150351.20898-3-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Fri, Sep 21, 2018 at 08:03:26AM -0700, Yu-cheng Yu wrote:

> diff --git a/arch/x86/include/asm/fpu/internal.h b/arch/x86/include/asm/fpu/internal.h
> index a38bf5a1e37a..f1f9bf91a0ab 100644
> --- a/arch/x86/include/asm/fpu/internal.h
> +++ b/arch/x86/include/asm/fpu/internal.h
> @@ -93,7 +93,8 @@ static inline void fpstate_init_xstate(struct xregs_state *xsave)
>  	 * XRSTORS requires these bits set in xcomp_bv, or it will
>  	 * trigger #GP:
>  	 */
> -	xsave->header.xcomp_bv = XCOMP_BV_COMPACTED_FORMAT | xfeatures_mask;
> +	xsave->header.xcomp_bv = XCOMP_BV_COMPACTED_FORMAT |
> +			xfeatures_mask_user;

I would be OK with that line extending to 82 characters..

>  }
>  
>  static inline void fpstate_init_fxstate(struct fxregs_state *fx)

> diff --git a/arch/x86/kernel/fpu/xstate.c b/arch/x86/kernel/fpu/xstate.c
> index 87a57b7642d3..19f8df54c72a 100644
> --- a/arch/x86/kernel/fpu/xstate.c
> +++ b/arch/x86/kernel/fpu/xstate.c

> @@ -421,7 +421,8 @@ static void __init setup_init_fpu_buf(void)
>  	print_xstate_features();
>  
>  	if (boot_cpu_has(X86_FEATURE_XSAVES))
> -		init_fpstate.xsave.header.xcomp_bv = (u64)1 << 63 | xfeatures_mask;
> +		init_fpstate.xsave.header.xcomp_bv =
> +			BIT_ULL(63) | xfeatures_mask_user;

If you do that, the if () needs { } per coding style.

>  
>  	/*
>  	 * Init all the features state with header.xfeatures being 0x0
