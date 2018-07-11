Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 51E886B0007
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 15:37:28 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id v205-v6so36521909oie.20
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 12:37:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w197-v6sor13988692oia.58.2018.07.11.12.37.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 12:37:27 -0700 (PDT)
MIME-Version: 1.0
References: <20180710222639.8241-1-yu-cheng.yu@intel.com> <20180710222639.8241-21-yu-cheng.yu@intel.com>
In-Reply-To: <20180710222639.8241-21-yu-cheng.yu@intel.com>
From: Jann Horn <jannh@google.com>
Date: Wed, 11 Jul 2018 12:37:00 -0700
Message-ID: <CAG48ez3DYQtgk_WfOwbFFeuWJmzwZhH-DkDT1UKYVZaYi6V_Pg@mail.gmail.com>
Subject: Re: [RFC PATCH v2 20/27] x86/cet/shstk: ELF header parsing of CET
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yu-cheng.yu@intel.com
Cc: the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, bsingharora@gmail.com, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On Tue, Jul 10, 2018 at 3:31 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> Look in .note.gnu.property of an ELF file and check if shadow stack needs
> to be enabled for the task.
>
> Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
[...]
> diff --git a/arch/x86/kernel/elf.c b/arch/x86/kernel/elf.c
> new file mode 100644
> index 000000000000..233f6dad9c1f
> --- /dev/null
> +++ b/arch/x86/kernel/elf.c
[...]
> +#define NOTE_SIZE_BAD(n, align, max) \
> +       ((n->n_descsz < 8) || ((n->n_descsz % align) != 0) || \
> +        (((u8 *)(n + 1) + 4 + n->n_descsz) > (max)))

Please do not compute out-of-bounds pointers and then compare them
against an expected maximum pointer. Computing an out-of-bounds
pointer is undefined behavior according to the C99 specification,
section "6.5.6 Additive operators", paragraph 8; and in this case,
n->n_descsz is 32 bits wide, which means that even if the compiler
isn't doing anything funny, if you're operating on addresses in the
last 4GiB of virtual memory and the pointer wraps around, this could
break.
In particular, if anyone ever uses this code in a 32-bit kernel, this
is going to blow up.
Please use size comparisons instead of pointer comparisons.

> +
> +/*
> + * Go through the property array and look for the one
> + * with pr_type of GNU_PROPERTY_X86_FEATURE_1_AND.
> + */
> +static u32 find_x86_feature_1(u8 *buf, u32 size, u32 align)
> +{
> +       u8 *end = buf + size;
> +       u8 *ptr = buf;
> +
> +       while (1) {
> +               u32 pr_type, pr_datasz;
> +
> +               if ((ptr + 4) >= end)
> +                       break;

Theoretical UB.

> +               pr_type = *(u32 *)ptr;
> +               pr_datasz = *(u32 *)(ptr + 4);
> +               ptr += 8;
> +
> +               if ((ptr + pr_datasz) >= end)
> +                       break;

UB, like in NOTE_SIZE_BAD().

> +               if (pr_type == GNU_PROPERTY_X86_FEATURE_1_AND &&
> +                   pr_datasz == 4)
> +                       return *(u32 *)ptr;
> +
> +               ptr += pr_datasz;
> +       }
> +       return 0;
> +}
[...]
> diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> index 0ac456b52bdd..3395f6a631d5 100644
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -1081,6 +1081,22 @@ static int load_elf_binary(struct linux_binprm *bprm)
>                 goto out_free_dentry;
>         }
>
> +#ifdef CONFIG_ARCH_HAS_PROGRAM_PROPERTIES
> +
> +       if (interpreter) {
> +               retval = arch_setup_features(&loc->interp_elf_ex,
> +                                            interp_elf_phdata,
> +                                            interpreter, true);
> +       } else {
> +               retval = arch_setup_features(&loc->elf_ex,
> +                                            elf_phdata,
> +                                            bprm->file, false);
> +       }

So for non-static binaries, the ELF headers of ld.so determine whether
CET will be on or off for the entire system, right? Is the intent here
that ld.so should start with CET enabled, and then either use the
compatibility bitmap or turn CET off at runtime if the executable or
one of the libraries doesn't actually work with CET?
