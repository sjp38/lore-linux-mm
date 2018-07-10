Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3256B0275
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 19:48:52 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id y2-v6so3629868pll.16
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 16:48:52 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id a9-v6si16195039pgl.568.2018.07.10.16.48.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 16:48:51 -0700 (PDT)
Subject: Re: [RFC PATCH v2 18/27] x86/cet/shstk: Introduce WRUSS instruction
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-19-yu-cheng.yu@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <bbb487cc-ac1c-f734-eee3-2463a0ba7efc@linux.intel.com>
Date: Tue, 10 Jul 2018 16:48:50 -0700
MIME-Version: 1.0
In-Reply-To: <20180710222639.8241-19-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

> +/*
> + * WRUSS is a kernel instrcution and but writes to user
> + * shadow stack memory.  When a fault occurs, both
> + * X86_PF_USER and X86_PF_SHSTK are set.
> + */
> +static int is_wruss(struct pt_regs *regs, unsigned long error_code)
> +{
> +	return (((error_code & (X86_PF_USER | X86_PF_SHSTK)) ==
> +		(X86_PF_USER | X86_PF_SHSTK)) && !user_mode(regs));
> +}

I thought X86_PF_USER was set based on the mode in which the fault
occurred.  Does this mean that the architecture of this bit is different
now?

That seems like something we need to call out if so.  It also means we
need to update the SDM because some of the text is wrong.

>  static void
>  show_fault_oops(struct pt_regs *regs, unsigned long error_code,
>  		unsigned long address)
> @@ -848,7 +859,7 @@ __bad_area_nosemaphore(struct pt_regs *regs, unsigned long error_code,
>  	struct task_struct *tsk = current;
>  
>  	/* User mode accesses just cause a SIGSEGV */
> -	if (error_code & X86_PF_USER) {
> +	if ((error_code & X86_PF_USER) && !is_wruss(regs, error_code)) {
>  		/*
>  		 * It's possible to have interrupts off here:
>  		 */

This needs commenting about why is_wruss() is special.
