Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2E12C6B0261
	for <linux-mm@kvack.org>; Tue, 24 May 2016 13:09:19 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id s130so12359232lfs.2
        for <linux-mm@kvack.org>; Tue, 24 May 2016 10:09:19 -0700 (PDT)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id m10si24753790wmg.50.2016.05.24.10.09.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 10:09:17 -0700 (PDT)
Received: by mail-wm0-x22b.google.com with SMTP id z87so32287814wmh.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 10:09:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160524001736.135ae3cdc101ecec3232a493@gmail.com>
References: <20160524001405.3e6abd1d5a63a871cc366cff@gmail.com> <20160524001736.135ae3cdc101ecec3232a493@gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 24 May 2016 10:09:16 -0700
Message-ID: <CAGXu5jJgFujkiqBrb6k-VX8WHz8P3A__McKNOtRgGd-USuEyeQ@mail.gmail.com>
Subject: Re: [PATCH v1 3/3] Add the extra_latent_entropy kernel parameter
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Emese Revfy <re.emese@gmail.com>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, bart.vanassche@sandisk.com, "David S. Miller" <davem@davemloft.net>

On Mon, May 23, 2016 at 3:17 PM, Emese Revfy <re.emese@gmail.com> wrote:
> When extra_latent_entropy is passed on the kernel command line,
> entropy will be extracted from up to the first 4GB of RAM while the
> runtime memory allocator is being initialized.
>
> Based on work created by the PaX Team.
>
> Signed-off-by: Emese Revfy <re.emese@gmail.com>
> ---
>  Documentation/kernel-parameters.txt |  5 +++++
>  arch/Kconfig                        |  5 +++++
>  mm/page_alloc.c                     | 23 +++++++++++++++++++++++
>  3 files changed, 33 insertions(+)
>
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index 5349363..6c2496e 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -2862,6 +2862,11 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>                         the specified number of seconds.  This is to be used if
>                         your oopses keep scrolling off the screen.
>
> +       extra_latent_entropy
> +                       Enable a very simple form of latent entropy extraction
> +                       from the first 4GB of memory as the bootmem allocator
> +                       passes the memory pages to the buddy allocator.
> +
>         pcbit=          [HW,ISDN]
>
>         pcd.            [PARIDE]
> diff --git a/arch/Kconfig b/arch/Kconfig
> index 74489df..327d1e4 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -403,6 +403,11 @@ config GCC_PLUGIN_LATENT_ENTROPY
>           there is little 'natural' source of entropy normally.  The cost
>           is some slowdown of the boot process and fork and irq processing.
>
> +         When extra_latent_entropy is passed on the kernel command line,
> +         entropy will be extracted from up to the first 4GB of RAM while the
> +         runtime memory allocator is being initialized.  This costs even more
> +         slowdown of the boot process.
> +
>           Note that entropy extracted this way is not known to be cryptographically
>           secure!
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ffc4f4a..c79407b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -63,6 +63,7 @@
>  #include <linux/sched/rt.h>
>  #include <linux/page_owner.h>
>  #include <linux/kthread.h>
> +#include <linux/random.h>
>
>  #include <asm/sections.h>
>  #include <asm/tlbflush.h>
> @@ -1235,6 +1236,15 @@ static void __free_pages_ok(struct page *page, unsigned int order)
>  }
>
>  #ifdef CONFIG_GCC_PLUGIN_LATENT_ENTROPY
> +bool __meminitdata extra_latent_entropy;
> +
> +static int __init setup_extra_latent_entropy(char *str)
> +{
> +       extra_latent_entropy = true;
> +       return 0;
> +}
> +early_param("extra_latent_entropy", setup_extra_latent_entropy);
> +
>  volatile u64 latent_entropy __latent_entropy;
>  EXPORT_SYMBOL(latent_entropy);
>  #endif
> @@ -1254,6 +1264,19 @@ static void __init __free_pages_boot_core(struct page *page, unsigned int order)
>         __ClearPageReserved(p);
>         set_page_count(p, 0);
>
> +#ifdef CONFIG_GCC_PLUGIN_LATENT_ENTROPY
> +       if (extra_latent_entropy && !PageHighMem(page) && page_to_pfn(page) < 0x100000) {
> +               u64 hash = 0;
> +               size_t index, end = PAGE_SIZE * nr_pages / sizeof hash;
> +               const u64 *data = lowmem_page_address(page);
> +
> +               for (index = 0; index < end; index++)
> +                       hash ^= hash + data[index];
> +               latent_entropy ^= hash;
> +               add_device_randomness((const void *)&latent_entropy, sizeof(latent_entropy));
> +       }
> +#endif
> +

We try to minimize #ifdefs in the .c code, so in this case, I think I
would define "extra_latent_entropy" during an #else above so this "if"
can be culled by the compiler automatically:

#else
# define extra_latent_entropy false
#endif

Others may have better suggestions to avoid the second #ifdef, but
this seems the cleanest way to me to tie this to the earlier #ifdef.

-Kees

>         page_zone(page)->managed_pages += nr_pages;
>         set_page_refcounted(page);
>         __free_pages(page, order);
> --
> 2.8.1
>



-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
