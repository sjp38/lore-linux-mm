Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id C486F6B0005
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 16:33:03 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id q141-v6so4048627ywg.5
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 13:33:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s18-v6sor1095807ywg.97.2018.08.08.13.33.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Aug 2018 13:33:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1533727000-9172-1-git-send-email-joro@8bytes.org>
References: <1533727000-9172-1-git-send-email-joro@8bytes.org>
From: Kees Cook <keescook@google.com>
Date: Wed, 8 Aug 2018 13:33:01 -0700
Message-ID: <CAGXu5jK-wd=wbXcqoaogThVF1gHvH+UXgvVtsFuV2efjo8K46g@mail.gmail.com>
Subject: Re: [PATCH] x86/mm/pti: Move user W+X check into pti_finalize()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, Anthony Liguori <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>

On Wed, Aug 8, 2018 at 4:16 AM, Joerg Roedel <joro@8bytes.org> wrote:
> From: Joerg Roedel <jroedel@suse.de>
>
> The user page-table gets the updated kernel mappings in
> pti_finalize(), which runs after the RO+X permissions got
> applied to the kernel page-table in mark_readonly().
>
> But with CONFIG_DEBUG_WX enabled, the user page-table is
> already checked in mark_readonly() for insecure mappings.
> This causes false-positive warnings, because the user
> page-table did not get the updated mappings yet.
>
> Move the W+X check for the user page-table into
> pti_finalize() after it updated all required mappings.
>
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  arch/x86/include/asm/pgtable.h | 7 +++++--
>  arch/x86/mm/dump_pagetables.c  | 3 +--
>  arch/x86/mm/pti.c              | 2 ++
>  3 files changed, 8 insertions(+), 4 deletions(-)
>
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index e39088cb..a1cb333 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -30,11 +30,14 @@ int __init __early_make_pgtable(unsigned long address, pmdval_t pmd);
>  void ptdump_walk_pgd_level(struct seq_file *m, pgd_t *pgd);
>  void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user);
>  void ptdump_walk_pgd_level_checkwx(void);
> +void ptdump_walk_user_pgd_level_checkwx(void);
>
>  #ifdef CONFIG_DEBUG_WX
> -#define debug_checkwx() ptdump_walk_pgd_level_checkwx()
> +#define debug_checkwx()                ptdump_walk_pgd_level_checkwx()
> +#define debug_checkwx_user()   ptdump_walk_user_pgd_level_checkwx()
>  #else
> -#define debug_checkwx() do { } while (0)
> +#define debug_checkwx()                do { } while (0)
> +#define debug_checkwx_user()   do { } while (0)
>  #endif
>
>  /*
> diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
> index ccd92c4..b8ab901 100644
> --- a/arch/x86/mm/dump_pagetables.c
> +++ b/arch/x86/mm/dump_pagetables.c
> @@ -569,7 +569,7 @@ void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user)
>  }
>  EXPORT_SYMBOL_GPL(ptdump_walk_pgd_level_debugfs);
>
> -static void ptdump_walk_user_pgd_level_checkwx(void)
> +void ptdump_walk_user_pgd_level_checkwx(void)
>  {
>  #ifdef CONFIG_PAGE_TABLE_ISOLATION
>         pgd_t *pgd = INIT_PGD;
> @@ -586,7 +586,6 @@ static void ptdump_walk_user_pgd_level_checkwx(void)
>  void ptdump_walk_pgd_level_checkwx(void)
>  {
>         ptdump_walk_pgd_level_core(NULL, NULL, true, false);
> -       ptdump_walk_user_pgd_level_checkwx();
>  }
>
>  static int __init pt_dump_init(void)
> diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
> index 69a9d60..026a89a 100644
> --- a/arch/x86/mm/pti.c
> +++ b/arch/x86/mm/pti.c
> @@ -628,4 +628,6 @@ void pti_finalize(void)
>          */
>         pti_clone_entry_text();
>         pti_clone_kernel_text();
> +
> +       debug_checkwx_user();
>  }

I'm slightly nervous about complicating this and splitting up the
check. I have a mild preference that all the checks get moved later,
so that all architectures have the checks happening at the same time
during boot. Splitting this up could give us some weird differences
between architectures, etc.

-Kees

-- 
Kees Cook
Pixel Security
