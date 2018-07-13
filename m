Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 55E596B000A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 08:12:15 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a20-v6so20636166pfi.1
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 05:12:15 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id q1-v6si24106651plb.331.2018.07.13.05.12.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 05:12:14 -0700 (PDT)
Subject: Re: [RFC PATCH v2 18/27] x86/cet/shstk: Introduce WRUSS instruction
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-19-yu-cheng.yu@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <166536e2-b296-7be5-d1b7-982cf56f1f9b@linux.intel.com>
Date: Fri, 13 Jul 2018 05:12:02 -0700
MIME-Version: 1.0
In-Reply-To: <20180710222639.8241-19-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 07/10/2018 03:26 PM, Yu-cheng Yu wrote:
> +static int is_wruss(struct pt_regs *regs, unsigned long error_code)
> +{
> +	return (((error_code & (X86_PF_USER | X86_PF_SHSTK)) ==
> +		(X86_PF_USER | X86_PF_SHSTK)) && !user_mode(regs));
> +}
> +
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

Please don't do it this way.

We have two styles of page fault:
1. User page faults: find a VMA, try to handle (allocate memory et al.),
   kill process if we can't handle.
2. Kernel page faults: search for a *discrete* set of conditions that
   can be handled, including faults in instructions marked in exception
   tables.

X86_PF_USER *means*: do user page fault handling.  In the places where
the hardware doesn't set it, but we still want user page fault handling,
we manually set it, like this where we "downgrade" an implicit
supervisor access to a user access:

        if (user_mode(regs)) {
                local_irq_enable();
                error_code |= X86_PF_USER;
                flags |= FAULT_FLAG_USER;

So, just please *clear* X86_PF_USER if !user_mode(regs) and X86_PF_SS.
We do not want user page fault handling, thus we should not keep the bit
set.
