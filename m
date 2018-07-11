Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id A7DCF6B026D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 17:10:50 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id l26-v6so30599228oii.14
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 14:10:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i65-v6sor11077055oih.50.2018.07.11.14.10.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 14:10:49 -0700 (PDT)
MIME-Version: 1.0
References: <20180710222639.8241-1-yu-cheng.yu@intel.com> <20180710222639.8241-18-yu-cheng.yu@intel.com>
In-Reply-To: <20180710222639.8241-18-yu-cheng.yu@intel.com>
From: Jann Horn <jannh@google.com>
Date: Wed, 11 Jul 2018 14:10:22 -0700
Message-ID: <CAG48ez1ytOfQyNZMNPFp7XqKcpd7_aRai9G5s7rx0V=8ZG+r2A@mail.gmail.com>
Subject: Re: [RFC PATCH v2 17/27] x86/cet/shstk: User-mode shadow stack support
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yu-cheng.yu@intel.com
Cc: the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, bsingharora@gmail.com, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On Tue, Jul 10, 2018 at 3:31 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> This patch adds basic shadow stack enabling/disabling routines.
> A task's shadow stack is allocated from memory with VM_SHSTK
> flag set and read-only protection.  The shadow stack is
> allocated to a fixed size.
>
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
[...]
> diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
> new file mode 100644
> index 000000000000..96bf69db7da7
> --- /dev/null
> +++ b/arch/x86/kernel/cet.c
[...]
> +static unsigned long shstk_mmap(unsigned long addr, unsigned long len)
> +{
> +       struct mm_struct *mm = current->mm;
> +       unsigned long populate;
> +
> +       down_write(&mm->mmap_sem);
> +       addr = do_mmap(NULL, addr, len, PROT_READ,
> +                      MAP_ANONYMOUS | MAP_PRIVATE, VM_SHSTK,
> +                      0, &populate, NULL);
> +       up_write(&mm->mmap_sem);
> +
> +       if (populate)
> +               mm_populate(addr, populate);
> +
> +       return addr;
> +}

How does this interact with UFFDIO_REGISTER?

Is there an explicit design decision on whether FOLL_FORCE should be
able to write to shadow stacks? I'm guessing the answer is "yes,
FOLL_FORCE should be able to write to shadow stacks"? It might make
sense to add documentation for this.

Should the kernel enforce that two shadow stacks must have a guard
page between them so that they can not be directly adjacent, so that
if you have too much recursion, you can't end up corrupting an
adjacent shadow stack?

> +int cet_setup_shstk(void)
> +{
> +       unsigned long addr, size;
> +
> +       if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
> +               return -EOPNOTSUPP;
> +
> +       size = in_ia32_syscall() ? SHSTK_SIZE_32:SHSTK_SIZE_64;
> +       addr = shstk_mmap(0, size);
> +
> +       /*
> +        * Return actual error from do_mmap().
> +        */
> +       if (addr >= TASK_SIZE_MAX)
> +               return addr;
> +
> +       set_shstk_ptr(addr + size - sizeof(u64));
> +       current->thread.cet.shstk_base = addr;
> +       current->thread.cet.shstk_size = size;
> +       current->thread.cet.shstk_enabled = 1;
> +       return 0;
> +}
[...]
> +void cet_disable_free_shstk(struct task_struct *tsk)
> +{
> +       if (!cpu_feature_enabled(X86_FEATURE_SHSTK) ||
> +           !tsk->thread.cet.shstk_enabled)
> +               return;
> +
> +       if (tsk == current)
> +               cet_disable_shstk();
> +
> +       /*
> +        * Free only when tsk is current or shares mm
> +        * with current but has its own shstk.
> +        */
> +       if (tsk->mm && (tsk->mm == current->mm) &&
> +           (tsk->thread.cet.shstk_base)) {
> +               vm_munmap(tsk->thread.cet.shstk_base,
> +                         tsk->thread.cet.shstk_size);
> +               tsk->thread.cet.shstk_base = 0;
> +               tsk->thread.cet.shstk_size = 0;
> +       }
> +
> +       tsk->thread.cet.shstk_enabled = 0;
> +}
