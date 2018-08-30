Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id D81306B50F2
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 12:10:45 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b8-v6so7975288oib.4
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 09:10:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d87-v6sor3778029oic.134.2018.08.30.09.10.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Aug 2018 09:10:44 -0700 (PDT)
MIME-Version: 1.0
References: <20180830143904.3168-1-yu-cheng.yu@intel.com> <20180830143904.3168-19-yu-cheng.yu@intel.com>
In-Reply-To: <20180830143904.3168-19-yu-cheng.yu@intel.com>
From: Jann Horn <jannh@google.com>
Date: Thu, 30 Aug 2018 18:10:17 +0200
Message-ID: <CAG48ez0d8+E_O-9u6ZHZ6dQO55Ui2ydV_kia-EEhyYeB_w4r2g@mail.gmail.com>
Subject: Re: [RFC PATCH v3 18/24] x86/cet/shstk: User-mode shadow stack support
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yu-cheng.yu@intel.com
Cc: the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On Thu, Aug 30, 2018 at 4:44 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> This patch adds basic shadow stack enabling/disabling routines.
> A task's shadow stack is allocated from memory with VM_SHSTK
> flag set and read-only protection.  The shadow stack is
> allocated to a fixed size of RLIMIT_STACK.
>
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
[...]
> +static int set_shstk_ptr(unsigned long addr)
> +{
> +       u64 r;
> +
> +       if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
> +               return -1;
> +
> +       if ((addr >= TASK_SIZE_MAX) || (!IS_ALIGNED(addr, 4)))
> +               return -1;
> +
> +       rdmsrl(MSR_IA32_U_CET, r);
> +       wrmsrl(MSR_IA32_PL3_SSP, addr);
> +       wrmsrl(MSR_IA32_U_CET, r | MSR_IA32_CET_SHSTK_EN);
> +       return 0;
> +}

Here's a really stupid question: Where is the logic for switching
those MSRs on task switch? MSR_IA32_PL3_SSP contains a userspace
pointer, so it has to be switched on task switch, right? I'm sure I'm
missing something obvious, but grepping for places that set
MSR_IA32_PL3_SSP to nonzero values through the entire patchset, I only
see set_shstk_ptr(), which is called from:

 - cet_setup_shstk() (called from arch_setup_features(), which is
called from load_elf_binary())
 - cet_restore_signal() (called on signal handler return)
 - cet_setup_signal() (called from signal handling code)
