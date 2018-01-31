Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 269626B0006
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 11:03:32 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id g202so75698ita.4
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 08:03:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u3sor27819itf.37.2018.01.31.08.03.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jan 2018 08:03:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <ba158a93f3250e6fca752cff2cfb1fcdd9f2b50c.1517414050.git.luto@kernel.org>
References: <ba158a93f3250e6fca752cff2cfb1fcdd9f2b50c.1517414050.git.luto@kernel.org>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Wed, 31 Jan 2018 16:03:30 +0000
Message-ID: <CAKv+Gu_Gxb62zhWQgWxHbfekJGB2rry_U1PWuBd6Jf5cWsJycw@mail.gmail.com>
Subject: Re: [PATCH] x86/debugfs: Add the EFI pagetable to the debugfs
 'page_tables' directory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, linux-efi@vger.kernel.org

Hi Andy,

On 31 January 2018 at 15:56, Andy Lutomirski <luto@kernel.org> wrote:
> EFI is complicated enough that being able to view its pagetables is
> quite helpful.  Rather than requiring users to fish it out of dmesg
> on an appropriately configured kernel, let users view it in debugfs
> as well.
>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

This is more x86 code than EFI code, but from my side, this looks fine
(and even though we already have a similar facility on ARM/arm64,
there doesn't seem to be much point in attempting to reuse any of its
code for this)

Acked-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

> ---
>  arch/x86/mm/debug_pagetables.c | 32 ++++++++++++++++++++++++++++++++
>  arch/x86/platform/efi/efi_64.c |  2 +-
>  2 files changed, 33 insertions(+), 1 deletion(-)
>
> diff --git a/arch/x86/mm/debug_pagetables.c b/arch/x86/mm/debug_pagetables.c
> index 421f2664ffa0..9861797b1fd5 100644
> --- a/arch/x86/mm/debug_pagetables.c
> +++ b/arch/x86/mm/debug_pagetables.c
> @@ -72,6 +72,31 @@ static const struct file_operations ptdump_curusr_fops = {
>  };
>  #endif
>
> +#if defined(CONFIG_EFI) && defined(CONFIG_X86_64)
> +extern pgd_t *efi_pgd;
> +static struct dentry *pe_efi;
> +
> +static int ptdump_show_efi(struct seq_file *m, void *v)
> +{
> +       if (efi_pgd)
> +               ptdump_walk_pgd_level_debugfs(m, efi_pgd, false);
> +       return 0;
> +}
> +
> +static int ptdump_open_efi(struct inode *inode, struct file *filp)
> +{
> +       return single_open(filp, ptdump_show_efi, NULL);
> +}
> +
> +static const struct file_operations ptdump_efi_fops = {
> +       .owner          = THIS_MODULE,
> +       .open           = ptdump_open_efi,
> +       .read           = seq_read,
> +       .llseek         = seq_lseek,
> +       .release        = single_release,
> +};
> +#endif
> +
>  static struct dentry *dir, *pe_knl, *pe_curknl;
>
>  static int __init pt_dump_debug_init(void)
> @@ -94,8 +119,15 @@ static int __init pt_dump_debug_init(void)
>         pe_curusr = debugfs_create_file("current_user", 0400,
>                                         dir, NULL, &ptdump_curusr_fops);
>         if (!pe_curusr)
> +                goto err;
> +#endif
> +
> +#if defined(CONFIG_EFI) && defined(CONFIG_X86_64)
> +       pe_efi = debugfs_create_file("efi", 0400, dir, NULL, &ptdump_efi_fops);
> +       if (!pe_efi)
>                 goto err;
>  #endif
> +
>         return 0;
>  err:
>         debugfs_remove_recursive(dir);
> diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
> index 2dd15e967c3f..a9734df2c1b7 100644
> --- a/arch/x86/platform/efi/efi_64.c
> +++ b/arch/x86/platform/efi/efi_64.c
> @@ -191,7 +191,7 @@ void __init efi_call_phys_epilog(pgd_t *save_pgd)
>         early_code_mapping_set_exec(0);
>  }
>
> -static pgd_t *efi_pgd;
> +pgd_t *efi_pgd;
>
>  /*
>   * We need our own copy of the higher levels of the page tables
> --
> 2.14.3
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
