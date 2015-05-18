Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 69E476B0032
	for <linux-mm@kvack.org>; Mon, 18 May 2015 14:45:40 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so24542921wgb.3
        for <linux-mm@kvack.org>; Mon, 18 May 2015 11:45:39 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id 2si19171384wjq.85.2015.05.18.11.45.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 11:45:38 -0700 (PDT)
Received: by wizk4 with SMTP id k4so90173486wiz.1
        for <linux-mm@kvack.org>; Mon, 18 May 2015 11:45:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1431974526-21788-1-git-send-email-leon@leon.nu>
References: <1431974526-21788-1-git-send-email-leon@leon.nu>
From: Leon Romanovsky <leon@leon.nu>
Date: Mon, 18 May 2015 21:45:15 +0300
Message-ID: <CALq1K=LMtN-sqyD9WWCMJSCakAgw+bTG=cs=fSa8b9NYfWukLQ@mail.gmail.com>
Subject: Re: [PATCH] mm: nommu: convert kenter/kleave/kdebug macros to use pr_devel()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dhowells <dhowells@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, aarcange <aarcange@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Leon Romanovsky <leon@leon.nu>

Sorry for this multiple resend, my mail client hid from me part of
subject line :(

On Mon, May 18, 2015 at 9:42 PM, Leon Romanovsky <leon@leon.nu> wrote:
> kenter/kleave/kdebug are wrapper macros to print functions flow and debug
> information. This set was written before pr_devel() was introduced, so
> it was controlled by "#if 0" construction.
>
> This patch refactors the current macros to use general pr_devel()
> functions which won't be compiled in if "#define DEBUG" is not declared
> prior to that macros.
>
> Signed-off-by: Leon Romanovsky <leon@leon.nu>
> ---
>  mm/nommu.c |   18 ++++++------------
>  1 file changed, 6 insertions(+), 12 deletions(-)
>
> diff --git a/mm/nommu.c b/mm/nommu.c
> index e544508..7e5986b6 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -42,21 +42,15 @@
>  #include <asm/mmu_context.h>
>  #include "internal.h"
>
> -#if 0
> -#define kenter(FMT, ...) \
> -       printk(KERN_DEBUG "==> %s("FMT")\n", __func__, ##__VA_ARGS__)
> -#define kleave(FMT, ...) \
> -       printk(KERN_DEBUG "<== %s()"FMT"\n", __func__, ##__VA_ARGS__)
> -#define kdebug(FMT, ...) \
> -       printk(KERN_DEBUG "xxx" FMT"yyy\n", ##__VA_ARGS__)
> -#else
> +/*
> + * Relies on "#define DEBUG" construction to print them
> + */
>  #define kenter(FMT, ...) \
> -       no_printk(KERN_DEBUG "==> %s("FMT")\n", __func__, ##__VA_ARGS__)
> +       pr_devel("==> %s("FMT")\n", __func__, ##__VA_ARGS__)
>  #define kleave(FMT, ...) \
> -       no_printk(KERN_DEBUG "<== %s()"FMT"\n", __func__, ##__VA_ARGS__)
> +       pr_devel("<== %s()"FMT"\n", __func__, ##__VA_ARGS__)
>  #define kdebug(FMT, ...) \
> -       no_printk(KERN_DEBUG FMT"\n", ##__VA_ARGS__)
> -#endif
> +       pr_devel("xxx" FMT"yyy\n", ##__VA_ARGS__)
>
>  void *high_memory;
>  EXPORT_SYMBOL(high_memory);
> --
> 1.7.9.5
>



-- 
Leon Romanovsky | Independent Linux Consultant
        www.leon.nu | leon@leon.nu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
