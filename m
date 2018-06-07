Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 84F2D6B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 14:30:47 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f65-v6so5204003wmd.2
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 11:30:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i2-v6sor17226947wrh.13.2018.06.07.11.30.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Jun 2018 11:30:45 -0700 (PDT)
MIME-Version: 1.0
References: <20180607143807.3611-1-yu-cheng.yu@intel.com> <20180607143807.3611-4-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143807.3611-4-yu-cheng.yu@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 7 Jun 2018 11:30:34 -0700
Message-ID: <CALCETrWo77RS_wOzskw5OG-LdC1S-b_NY=uPWUmPbQEnNwANgQ@mail.gmail.com>
Subject: Re: [PATCH 03/10] x86/cet: Signal handling for shadow stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, Florian Weimer <fweimer@redhat.com>, Dmitry Safonov <dsafonov@virtuozzo.com>, Cyrill Gorcunov <gorcunov@openvz.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> Set and restore shadow stack pointer for signals.

How does this interact with siglongjmp()?

This patch makes me extremely nervous due to the possibility of ABI
issues and CRIU breakage.

> diff --git a/arch/x86/include/uapi/asm/sigcontext.h b/arch/x86/include/uapi/asm/sigcontext.h
> index 844d60eb1882..6c8997a0156a 100644
> --- a/arch/x86/include/uapi/asm/sigcontext.h
> +++ b/arch/x86/include/uapi/asm/sigcontext.h
> @@ -230,6 +230,7 @@ struct sigcontext_32 {
>         __u32                           fpstate; /* Zero when no FPU/extended context */
>         __u32                           oldmask;
>         __u32                           cr2;
> +       __u32                           ssp;
>  };
>
>  /*
> @@ -262,6 +263,7 @@ struct sigcontext_64 {
>         __u64                           trapno;
>         __u64                           oldmask;
>         __u64                           cr2;
> +       __u64                           ssp;
>
>         /*
>          * fpstate is really (struct _fpstate *) or (struct _xstate *)
> @@ -320,6 +322,7 @@ struct sigcontext {
>         struct _fpstate __user          *fpstate;
>         __u32                           oldmask;
>         __u32                           cr2;
> +       __u32                           ssp;

Is it actually okay to modify these structures like this?  They're
part of the user ABI, and I don't know whether any user code relies on
the size being constant.

> +int cet_push_shstk(int ia32, unsigned long ssp, unsigned long val)
> +{
> +       if (val >= TASK_SIZE)
> +               return -EINVAL;

TASK_SIZE_MAX.  But I'm a bit unsure why you need this check at all.

> +int cet_restore_signal(unsigned long ssp)
> +{
> +       if (!current->thread.cet.shstk_enabled)
> +               return 0;
> +       return cet_set_shstk_ptr(ssp);
> +}

This will blow up if the shadow stack enabled state changes in a
signal handler.  Maybe we don't care.
