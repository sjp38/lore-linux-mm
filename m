Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A50B86B517F
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 11:40:03 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id r131-v6so7862966oie.14
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 08:40:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f130-v6sor6091679oic.18.2018.08.30.08.40.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Aug 2018 08:40:02 -0700 (PDT)
MIME-Version: 1.0
References: <20180830143904.3168-1-yu-cheng.yu@intel.com> <20180830143904.3168-20-yu-cheng.yu@intel.com>
In-Reply-To: <20180830143904.3168-20-yu-cheng.yu@intel.com>
From: Jann Horn <jannh@google.com>
Date: Thu, 30 Aug 2018 17:39:35 +0200
Message-ID: <CAG48ez3uZrC-9uJ0uMoVPTtxRXRN8D+3zs5FknZD2woTT6mazg@mail.gmail.com>
Subject: Re: [RFC PATCH v3 19/24] x86/cet/shstk: Introduce WRUSS instruction
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yu-cheng.yu@intel.com
Cc: the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On Thu, Aug 30, 2018 at 4:44 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> WRUSS is a new kernel-mode instruction but writes directly
> to user shadow stack memory.  This is used to construct
> a return address on the shadow stack for the signal
> handler.
>
> This instruction can fault if the user shadow stack is
> invalid shadow stack memory.  In that case, the kernel does
> fixup.
>
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
[...]
> +static inline int write_user_shstk_64(unsigned long addr, unsigned long val)
> +{
> +       int err = 0;
> +
> +       asm volatile("1: wrussq %1, (%0)\n"
> +                    "2:\n"
> +                    _ASM_EXTABLE_HANDLE(1b, 2b, ex_handler_wruss)
> +                    :
> +                    : "r" (addr), "r" (val));
> +
> +       return err;
> +}

What's up with "err"? You set it to zero, and then you return it, but
nothing can ever set it to non-zero, right?

> +__visible bool ex_handler_wruss(const struct exception_table_entry *fixup,
> +                               struct pt_regs *regs, int trapnr)
> +{
> +       regs->ip = ex_fixup_addr(fixup);
> +       regs->ax = -1;
> +       return true;
> +}

And here you just write into regs->ax, but your "asm volatile" doesn't
reserve that register. This looks wrong to me.

I think you probably want to add something like an explicit
`"+&a"(err)` output to the asm statements.

> @@ -1305,6 +1305,15 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
>                 error_code |= X86_PF_USER;
>                 flags |= FAULT_FLAG_USER;
>         } else {
> +               /*
> +                * WRUSS is a kernel instrcution and but writes

Nits: typo ("instrcution"), weird grammar ("and but writes")
