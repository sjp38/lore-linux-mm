Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3E0DF6B000A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 10:07:05 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id u86-v6so12331730qku.5
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 07:07:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q16-v6sor1313721qtf.29.2018.10.05.07.07.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Oct 2018 07:07:04 -0700 (PDT)
MIME-Version: 1.0
References: <1531906876-13451-1-git-send-email-joro@8bytes.org> <1531906876-13451-33-git-send-email-joro@8bytes.org>
In-Reply-To: <1531906876-13451-33-git-send-email-joro@8bytes.org>
From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 5 Oct 2018 16:06:47 +0200
Message-ID: <CAK8P3a13D6v=R7GKMxf7tZo6MjaMqoRudcW=u_AGQZOTbrocWA@mail.gmail.com>
Subject: Re: [PATCH 32/39] x86/pgtable/pae: Use separate kernel PMDs for user page-table
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, gregkh <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, dhgutteridge@sympatico.ca, Joerg Roedel <jroedel@suse.de>

On Wed, Jul 18, 2018 at 11:43 AM Joerg Roedel <joro@8bytes.org> wrote:
>  arch/x86/mm/pgtable.c | 100 ++++++++++++++++++++++++++++++++++++++++----------
>  1 file changed, 81 insertions(+), 19 deletions(-)
>
> diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
> index db6fb77..8e4e63d 100644
> --- a/arch/x86/mm/pgtable.c
> +++ b/arch/x86/mm/pgtable.c
> @@ -182,6 +182,14 @@ static void pgd_dtor(pgd_t *pgd)
>   */
>  #define PREALLOCATED_PMDS      UNSHARED_PTRS_PER_PGD
>
> +/*
> + * We allocate separate PMDs for the kernel part of the user page-table
> + * when PTI is enabled. We need them to map the per-process LDT into the
> + * user-space page-table.
> + */
> +#define PREALLOCATED_USER_PMDS  (static_cpu_has(X86_FEATURE_PTI) ? \
> +                                       KERNEL_PGD_PTRS : 0)

>   * Xen paravirt assumes pgd table should be in one page. 64 bit kernel also
>   * assumes that pgd should be in one page.
> @@ -376,6 +431,7 @@ static inline void _pgd_free(pgd_t *pgd)
>  pgd_t *pgd_alloc(struct mm_struct *mm)
>  {
>         pgd_t *pgd;
> +       pmd_t *u_pmds[PREALLOCATED_USER_PMDS];
>         pmd_t *pmds[PREALLOCATED_PMDS];
>

This commit from back in July now causes a build warning after the patch
from Kees that enables -Wvla:

In file included from /git/arm-soc/include/linux/kernel.h:15,
                 from /git/arm-soc/include/asm-generic/bug.h:18,
                 from /git/arm-soc/arch/x86/include/asm/bug.h:83,
                 from /git/arm-soc/include/linux/bug.h:5,
                 from /git/arm-soc/include/linux/mmdebug.h:5,
                 from /git/arm-soc/include/linux/mm.h:9,
                 from /git/arm-soc/arch/x86/mm/pgtable.c:2:
/git/arm-soc/arch/x86/mm/pgtable.c: In function 'pgd_alloc':
/git/arm-soc/include/linux/build_bug.h:29:45: error: ISO C90 forbids
variable length array 'u_pmds' [-Werror=vla]
 #define BUILD_BUG_ON_ZERO(e) (sizeof(struct { int:(-!!(e)); }))
                                             ^
/git/arm-soc/arch/x86/include/asm/cpufeature.h:85:5: note: in
expansion of macro 'BUILD_BUG_ON_ZERO'
     BUILD_BUG_ON_ZERO(NCAPINTS != 19))
     ^~~~~~~~~~~~~~~~~
/git/arm-soc/arch/x86/include/asm/cpufeature.h:111:32: note: in
expansion of macro 'REQUIRED_MASK_BIT_SET'
  (__builtin_constant_p(bit) && REQUIRED_MASK_BIT_SET(bit) ? 1 : \
                                ^~~~~~~~~~~~~~~~~~~~~
/git/arm-soc/arch/x86/include/asm/cpufeature.h:129:27: note: in
expansion of macro 'cpu_has'
 #define boot_cpu_has(bit) cpu_has(&boot_cpu_data, bit)
                           ^~~~~~~
/git/arm-soc/arch/x86/include/asm/cpufeature.h:209:3: note: in
expansion of macro 'boot_cpu_has'
   boot_cpu_has(bit) :    \
   ^~~~~~~~~~~~
/git/arm-soc/arch/x86/mm/pgtable.c:190:34: note: in expansion of macro
'static_cpu_has'
 #define PREALLOCATED_USER_PMDS  (static_cpu_has(X86_FEATURE_PTI) ? \
                                  ^~~~~~~~~~~~~~
/git/arm-soc/arch/x86/mm/pgtable.c:431:16: note: in expansion of macro
'PREALLOCATED_USER_PMDS'
  pmd_t *u_pmds[PREALLOCATED_USER_PMDS];
                ^~~~~~~~~~~~~~~~~~~~~~

       Arnd
