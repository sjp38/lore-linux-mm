Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id AC94A6B05E2
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 22:42:55 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id o24-v6so5651507iob.20
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 19:42:55 -0700 (PDT)
Received: from mtlfep01.bell.net (belmont79srvr.owm.bell.net. [184.150.200.79])
        by mx.google.com with ESMTPS id o11-v6si1891896ito.83.2018.08.16.19.42.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Aug 2018 19:42:54 -0700 (PDT)
Received: from bell.net mtlfep01 184.150.200.30 by mtlfep01.bell.net
          with ESMTP
          id <20180817024253.UCO10498.mtlfep01.bell.net@mtlspm01.bell.net>
          for <linux-mm@kvack.org>; Thu, 16 Aug 2018 22:42:53 -0400
Message-ID: <a5d99f4f367cfa553471e4cad1d0c80e52ac0a9f.camel@sympatico.ca>
Subject: Re: [PATCH] x86/mm/pti: Move user W+X check into pti_finalize()
From: "David H. Gutteridge" <dhgutteridge@sympatico.ca>
Date: Thu, 16 Aug 2018 22:42:48 -0400
In-Reply-To: <1533727000-9172-1-git-send-email-joro@8bytes.org>
References: <1533727000-9172-1-git-send-email-joro@8bytes.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de

On Wed, 2018-08-08 at 13:16 +0200, Joerg Roedel wrote:
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
> diff --git a/arch/x86/include/asm/pgtable.h
> b/arch/x86/include/asm/pgtable.h
> index e39088cb..a1cb333 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -30,11 +30,14 @@ int __init __early_make_pgtable(unsigned long
> address, pmdval_t pmd);
>  void ptdump_walk_pgd_level(struct seq_file *m, pgd_t *pgd);
>  void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd,
> bool user);
>  void ptdump_walk_pgd_level_checkwx(void);
> +void ptdump_walk_user_pgd_level_checkwx(void);
>  
>  #ifdef CONFIG_DEBUG_WX
> -#define debug_checkwx() ptdump_walk_pgd_level_checkwx()
> +#define debug_checkwx()		ptdump_walk_pgd_level_checkwx()
> +#define debug_checkwx_user()	ptdump_walk_user_pgd_level_checkwx()
>  #else
> -#define debug_checkwx() do { } while (0)
> +#define debug_checkwx()		do { } while (0)
> +#define debug_checkwx_user()	do { } while (0)
>  #endif
>  
>  /*
> diff --git a/arch/x86/mm/dump_pagetables.c
> b/arch/x86/mm/dump_pagetables.c
> index ccd92c4..b8ab901 100644
> --- a/arch/x86/mm/dump_pagetables.c
> +++ b/arch/x86/mm/dump_pagetables.c
> @@ -569,7 +569,7 @@ void ptdump_walk_pgd_level_debugfs(struct seq_file
> *m, pgd_t *pgd, bool user)
>  }
>  EXPORT_SYMBOL_GPL(ptdump_walk_pgd_level_debugfs);
>  
> -static void ptdump_walk_user_pgd_level_checkwx(void)
> +void ptdump_walk_user_pgd_level_checkwx(void)
>  {
>  #ifdef CONFIG_PAGE_TABLE_ISOLATION
>  	pgd_t *pgd = INIT_PGD;
> @@ -586,7 +586,6 @@ static void
> ptdump_walk_user_pgd_level_checkwx(void)
>  void ptdump_walk_pgd_level_checkwx(void)
>  {
>  	ptdump_walk_pgd_level_core(NULL, NULL, true, false);
> -	ptdump_walk_user_pgd_level_checkwx();
>  }
>  
>  static int __init pt_dump_init(void)
> diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
> index 69a9d60..026a89a 100644
> --- a/arch/x86/mm/pti.c
> +++ b/arch/x86/mm/pti.c
> @@ -628,4 +628,6 @@ void pti_finalize(void)
>  	 */
>  	pti_clone_entry_text();
>  	pti_clone_kernel_text();
> +
> +	debug_checkwx_user();
>  }

I've tested this in a VM and on an Atom laptop, as usual. No
regressions noted.

(The version I tested was the latter pulled into tip:
[ tglx: Folded !NX supported fix ])

Tested-by: David H. Gutteridge <dhgutteridge@sympatico.ca>

Regards,

Dave
