Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6C5F16B002E
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 15:15:09 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 96so6290200wrk.12
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 12:15:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j9sor4806103wri.18.2018.03.23.12.15.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Mar 2018 12:15:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180323180911.E43ACAB8@viggo.jf.intel.com>
References: <20180323180903.33B17168@viggo.jf.intel.com> <20180323180911.E43ACAB8@viggo.jf.intel.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 23 Mar 2018 12:15:06 -0700
Message-ID: <CALvZod6F8x-smAE7sEGfJ3Ds5p6M5Qj6gd-P-VLejuBxfU6niQ@mail.gmail.com>
Subject: Re: [PATCH 4/9] x86, pkeys: override pkey when moving away from PROT_EXEC
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linuxram@us.ibm.com, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@intel.com>, mpe@ellerman.id.au, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, shuah@kernel.org

On Fri, Mar 23, 2018 at 11:09 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> I got a bug report that the following code (roughly) was
> causing a SIGSEGV:
>
>         mprotect(ptr, size, PROT_EXEC);
>         mprotect(ptr, size, PROT_NONE);
>         mprotect(ptr, size, PROT_READ);
>         *ptr = 100;
>
> The problem is hit when the mprotect(PROT_EXEC)
> is implicitly assigned a protection key to the VMA, and made
> that key ACCESS_DENY|WRITE_DENY.  The PROT_NONE mprotect()
> failed to remove the protection key, and the PROT_NONE->
> PROT_READ left the PTE usable, but the pkey still in place
> and left the memory inaccessible.
>
> To fix this, we ensure that we always "override" the pkee
> at mprotect() if the VMA does not have execute-only
> permissions, but the VMA has the execute-only pkey.
>
> We had a check for PROT_READ/WRITE, but it did not work
> for PROT_NONE.  This entirely removes the PROT_* checks,
> which ensures that PROT_NONE now works.
>
> Reported-by: Shakeel Butt <shakeelb@google.com>
>
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Should there be a 'Fixes' tag? Also should this patch go to stable?

> Cc: Ram Pai <linuxram@us.ibm.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Michael Ellermen <mpe@ellerman.id.au>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Shuah Khan <shuah@kernel.org>
> ---
>
>  b/arch/x86/include/asm/pkeys.h |   12 +++++++++++-
>  b/arch/x86/mm/pkeys.c          |   19 ++++++++++---------
>  2 files changed, 21 insertions(+), 10 deletions(-)
>
> diff -puN arch/x86/include/asm/pkeys.h~pkeys-abandon-exec-only-pkey-more-aggressively arch/x86/include/asm/pkeys.h
> --- a/arch/x86/include/asm/pkeys.h~pkeys-abandon-exec-only-pkey-more-aggressively       2018-03-21 15:47:49.810198922 -0700
> +++ b/arch/x86/include/asm/pkeys.h      2018-03-21 15:47:49.816198922 -0700
> @@ -2,6 +2,8 @@
>  #ifndef _ASM_X86_PKEYS_H
>  #define _ASM_X86_PKEYS_H
>
> +#define ARCH_DEFAULT_PKEY      0
> +
>  #define arch_max_pkey() (boot_cpu_has(X86_FEATURE_OSPKE) ? 16 : 1)
>
>  extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
> @@ -15,7 +17,7 @@ extern int __execute_only_pkey(struct mm
>  static inline int execute_only_pkey(struct mm_struct *mm)
>  {
>         if (!boot_cpu_has(X86_FEATURE_OSPKE))
> -               return 0;
> +               return ARCH_DEFAULT_PKEY;
>
>         return __execute_only_pkey(mm);
>  }
> @@ -56,6 +58,14 @@ bool mm_pkey_is_allocated(struct mm_stru
>                 return false;
>         if (pkey >= arch_max_pkey())
>                 return false;
> +       /*
> +        * The exec-only pkey is set in the allocation map, but
> +        * is not available to any of the user interfaces like
> +        * mprotect_pkey().
> +        */
> +       if (pkey == mm->context.execute_only_pkey)
> +               return false;
> +
>         return mm_pkey_allocation_map(mm) & (1U << pkey);
>  }
>
> diff -puN arch/x86/mm/pkeys.c~pkeys-abandon-exec-only-pkey-more-aggressively arch/x86/mm/pkeys.c
> --- a/arch/x86/mm/pkeys.c~pkeys-abandon-exec-only-pkey-more-aggressively        2018-03-21 15:47:49.812198922 -0700
> +++ b/arch/x86/mm/pkeys.c       2018-03-21 15:47:49.816198922 -0700
> @@ -94,15 +94,7 @@ int __arch_override_mprotect_pkey(struct
>          */
>         if (pkey != -1)
>                 return pkey;
> -       /*
> -        * Look for a protection-key-drive execute-only mapping
> -        * which is now being given permissions that are not
> -        * execute-only.  Move it back to the default pkey.
> -        */
> -       if (vma_is_pkey_exec_only(vma) &&
> -           (prot & (PROT_READ|PROT_WRITE))) {
> -               return 0;
> -       }
> +
>         /*
>          * The mapping is execute-only.  Go try to get the
>          * execute-only protection key.  If we fail to do that,
> @@ -113,7 +105,16 @@ int __arch_override_mprotect_pkey(struct
>                 pkey = execute_only_pkey(vma->vm_mm);
>                 if (pkey > 0)
>                         return pkey;
> +       } else if (vma_is_pkey_exec_only(vma)) {
> +               /*
> +                * Protections are *not* PROT_EXEC, but the mapping
> +                * is using the exec-only pkey.  This mapping was
> +                * PROT_EXEC and will no longer be.  Move back to
> +                * the default pkey.
> +                */
> +               return ARCH_DEFAULT_PKEY;
>         }
> +
>         /*
>          * This is a vanilla, non-pkey mprotect (or we failed to
>          * setup execute-only), inherit the pkey from the VMA we
> _
