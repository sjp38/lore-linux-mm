Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 02FED6B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 14:32:50 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n8-v6so3367713wmh.0
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 11:32:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 11-v6sor683366wmj.86.2018.06.07.11.32.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Jun 2018 11:32:48 -0700 (PDT)
MIME-Version: 1.0
References: <20180607143855.3681-1-yu-cheng.yu@intel.com> <20180607143855.3681-8-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143855.3681-8-yu-cheng.yu@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 7 Jun 2018 11:32:36 -0700
Message-ID: <CALCETrXx4FHLad8XhrP-RrBtXnmALf7Myy4wVO+u-SKxa_D01Q@mail.gmail.com>
Subject: Re: [PATCH 7/7] x86/cet: Add PTRACE interface for CET
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 7, 2018 at 7:42 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> Add PTRACE interface for CET MSRs.
>
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  arch/x86/include/asm/fpu/regset.h |  7 ++++---
>  arch/x86/kernel/fpu/regset.c      | 41 +++++++++++++++++++++++++++++++++++++++
>  arch/x86/kernel/ptrace.c          | 16 +++++++++++++++
>  include/uapi/linux/elf.h          |  1 +
>  4 files changed, 62 insertions(+), 3 deletions(-)
>
> diff --git a/arch/x86/include/asm/fpu/regset.h b/arch/x86/include/asm/fpu/regset.h
> index d5bdffb9d27f..edad0d889084 100644
> --- a/arch/x86/include/asm/fpu/regset.h
> +++ b/arch/x86/include/asm/fpu/regset.h
> @@ -7,11 +7,12 @@
>
>  #include <linux/regset.h>
>
> -extern user_regset_active_fn regset_fpregs_active, regset_xregset_fpregs_active;
> +extern user_regset_active_fn regset_fpregs_active, regset_xregset_fpregs_active,
> +                               cetregs_active;
>  extern user_regset_get_fn fpregs_get, xfpregs_get, fpregs_soft_get,
> -                               xstateregs_get;
> +                               xstateregs_get, cetregs_get;
>  extern user_regset_set_fn fpregs_set, xfpregs_set, fpregs_soft_set,
> -                                xstateregs_set;
> +                                xstateregs_set, cetregs_set;
>
>  /*
>   * xstateregs_active == regset_fpregs_active. Please refer to the comment
> diff --git a/arch/x86/kernel/fpu/regset.c b/arch/x86/kernel/fpu/regset.c
> index bc02f5144b95..7008eb084d36 100644
> --- a/arch/x86/kernel/fpu/regset.c
> +++ b/arch/x86/kernel/fpu/regset.c
> @@ -160,6 +160,47 @@ int xstateregs_set(struct task_struct *target, const struct user_regset *regset,
>         return ret;
>  }
>
> +int cetregs_active(struct task_struct *target, const struct user_regset *regset)
> +{
> +#ifdef CONFIG_X86_INTEL_CET
> +       if (target->thread.cet.shstk_enabled || target->thread.cet.ibt_enabled)
> +               return regset->n;
> +#endif
> +       return 0;
> +}
> +
> +int cetregs_get(struct task_struct *target, const struct user_regset *regset,
> +               unsigned int pos, unsigned int count,
> +               void *kbuf, void __user *ubuf)
> +{
> +       struct fpu *fpu = &target->thread.fpu;
> +       struct cet_user_state *cetregs;
> +
> +       if (!boot_cpu_has(X86_FEATURE_SHSTK))
> +               return -ENODEV;

This whole series has a boot_cpu_has, static_cpu_has, and
cpu_feature_enabled all over.  Please settle on just one, preferably
static_cpu_has.

> +
> +       cetregs = get_xsave_addr(&fpu->state.xsave, XFEATURE_MASK_SHSTK_USER);
> +
> +       fpu__prepare_read(fpu);
> +       return user_regset_copyout(&pos, &count, &kbuf, &ubuf, cetregs, 0, -1);
> +}
> +
> +int cetregs_set(struct task_struct *target, const struct user_regset *regset,
> +                 unsigned int pos, unsigned int count,
> +                 const void *kbuf, const void __user *ubuf)
> +{
> +       struct fpu *fpu = &target->thread.fpu;
> +       struct cet_user_state *cetregs;
> +
> +       if (!boot_cpu_has(X86_FEATURE_SHSTK))
> +               return -ENODEV;
> +
> +       cetregs = get_xsave_addr(&fpu->state.xsave, XFEATURE_MASK_SHSTK_USER);
> +
> +       fpu__prepare_write(fpu);
> +       return user_regset_copyin(&pos, &count, &kbuf, &ubuf, cetregs, 0, -1);

Is this called for core dumping on current?  If so, please make sure
it's correct.  (I think it is for get but maybe not for set.)
