Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0938E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 14:56:48 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id i11-v6so6072114yba.8
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 11:56:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d7-v6sor3015010ybl.19.2018.09.21.11.56.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 11:56:47 -0700 (PDT)
Received: from mail-yb1-f179.google.com (mail-yb1-f179.google.com. [209.85.219.179])
        by smtp.gmail.com with ESMTPSA id r126-v6sm4950742ywb.92.2018.09.21.11.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 11:56:43 -0700 (PDT)
Received: by mail-yb1-f179.google.com with SMTP id o63-v6so5863109yba.2
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 11:56:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1536874298-23492-4-git-send-email-rick.p.edgecombe@intel.com>
References: <1536874298-23492-1-git-send-email-rick.p.edgecombe@intel.com> <1536874298-23492-4-git-send-email-rick.p.edgecombe@intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 21 Sep 2018 11:56:41 -0700
Message-ID: <CAGXu5jJj+08J9UeyQs5ku8CziYWA72iJ+hxMR2Z2tLiVwvU8MA@mail.gmail.com>
Subject: Re: [PATCH v6 3/4] vmalloc: Add debugfs modfraginfo
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Daniel Borkmann <daniel@iogearbox.net>, Jann Horn <jannh@google.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, Kristen Carlson Accardi <kristen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>

On Thu, Sep 13, 2018 at 2:31 PM, Rick Edgecombe
<rick.p.edgecombe@intel.com> wrote:
> Add debugfs file "modfraginfo" for providing info on module space fragmentation.
> This can be used for determining if loadable module randomization is causing any
> problems for extreme module loading situations, like huge numbers of modules or
> extremely large modules.
>
> Sample output when KASLR is enabled and X86_64 is configured:
>         Largest free space:     897912 kB
>           Total free space:     1025424 kB
> Allocations in backup area:     0
>
> Sample output when just X86_64:
>         Largest free space:     897912 kB
>           Total free space:     1025424 kB
>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>

I like having these statistics available!

> ---
>  mm/vmalloc.c | 102 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 101 insertions(+), 1 deletion(-)
>
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 1954458..a44b902 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -18,6 +18,7 @@
>  #include <linux/interrupt.h>
>  #include <linux/proc_fs.h>
>  #include <linux/seq_file.h>
> +#include <linux/debugfs.h>
>  #include <linux/debugobjects.h>
>  #include <linux/kallsyms.h>
>  #include <linux/list.h>
> @@ -33,6 +34,7 @@
>  #include <linux/bitops.h>
>
>  #include <linux/uaccess.h>
> +#include <asm/setup.h>
>  #include <asm/tlbflush.h>
>  #include <asm/shmparam.h>
>
> @@ -2919,7 +2921,105 @@ static int __init proc_vmalloc_init(void)
>                 proc_create_seq("vmallocinfo", 0400, NULL, &vmalloc_op);
>         return 0;
>  }
> -module_init(proc_vmalloc_init);
> +#else
> +static int __init proc_vmalloc_init(void)
> +{
> +       return 0;
> +}
> +#endif
> +
> +#if defined(CONFIG_RANDOMIZE_BASE) && defined(CONFIG_X86_64)
> +static inline unsigned long is_in_backup(unsigned long addr)
> +{
> +       return addr >= MODULES_VADDR + MODULES_RAND_LEN;
> +}
> +#else
> +static inline unsigned long is_in_backup(unsigned long addr)
> +{
> +       return 0;
> +}
>
> +inline bool kaslr_enabled(void);
>  #endif
>
> +
> +#if defined(CONFIG_DEBUG_FS) && defined(CONFIG_X86_64)
> +static int modulefraginfo_debug_show(struct seq_file *m, void *v)
> +{
> +       unsigned long last_end = MODULES_VADDR;
> +       unsigned long total_free = 0;
> +       unsigned long largest_free = 0;
> +       unsigned long backup_cnt = 0;
> +       unsigned long gap;
> +       struct vmap_area *prev, *cur = NULL;
> +
> +       spin_lock(&vmap_area_lock);
> +
> +       if (!pvm_find_next_prev(MODULES_VADDR, &cur, &prev) || !cur)
> +               goto done;
> +
> +       for (; cur->va_end <= MODULES_END; cur = list_next_entry(cur, list)) {
> +               /* Don't count areas that are marked to be lazily freed */
> +               if (!(cur->flags & VM_LAZY_FREE)) {
> +                       backup_cnt += is_in_backup(cur->va_start);
> +                       gap = cur->va_start - last_end;
> +                       if (gap > largest_free)
> +                               largest_free = gap;
> +                       total_free += gap;
> +                       last_end = cur->va_end;
> +               }
> +
> +               if (list_is_last(&cur->list, &vmap_area_list))
> +                       break;
> +       }
> +
> +done:
> +       gap = (MODULES_END - last_end);
> +       if (gap > largest_free)
> +               largest_free = gap;
> +       total_free += gap;
> +
> +       spin_unlock(&vmap_area_lock);
> +
> +       seq_printf(m, "\tLargest free space:\t%lu kB\n", largest_free / 1024);
> +       seq_printf(m, "\t  Total free space:\t%lu kB\n", total_free / 1024);
> +
> +       if (IS_ENABLED(CONFIG_RANDOMIZE_BASE) && kaslr_enabled())
> +               seq_printf(m, "Allocations in backup area:\t%lu\n", backup_cnt);

I don't think the IS_ENABLED is needed here?

I wonder if there is a better way to arrange this code that uses fewer
ifdefs, etc. Maybe a single CONFIG that capture whether or not
fine-grained module randomization is built in, like:

config RANDOMIZE_FINE_MODULE
    def_bool y if RANDOMIZE_BASE && X86_64

#ifdef CONFIG_RANDOMIZE_FINE_MODULE
...
#endif

But that doesn't capture the DEBUG_FS and PROC_FS bits ... so ...
maybe not worth it. I guess, either way:

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

-- 
Kees Cook
Pixel Security
