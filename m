Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 22F466B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 14:26:46 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id pv20so894034lab.22
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 11:26:45 -0700 (PDT)
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
        by mx.google.com with ESMTPS id l2si22431986lag.111.2014.09.10.11.26.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 11:26:44 -0700 (PDT)
Received: by mail-lb0-f175.google.com with SMTP id v6so5408220lbi.34
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 11:26:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1410367910-6026-3-git-send-email-toshi.kani@hp.com>
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com> <1410367910-6026-3-git-send-email-toshi.kani@hp.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 10 Sep 2014 11:26:23 -0700
Message-ID: <CALCETrXRjU3HvHogpm5eKB3Cogr5QHUvE67JOFGbOmygKYEGyA@mail.gmail.com>
Subject: Re: [PATCH v2 2/6] x86, mm, pat: Change reserve_memtype() to handle WT
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Wed, Sep 10, 2014 at 9:51 AM, Toshi Kani <toshi.kani@hp.com> wrote:
> This patch changes reserve_memtype() to handle the WT cache mode.
> When PAT is not enabled, it continues to set UC- to *new_type for
> any non-WB request.
>
> When a target range is RAM, reserve_ram_pages_type() fails for WT
> for now.  This function may not reserve a RAM range for WT since
> reserve_ram_pages_type() uses the page flags limited to three memory
> types, WB, WC and UC.

Should it fail if WT is unavailable due to errata?  More generally,
how are all of the do_something_wc / do_something_wt /
do_something_nocache helpers supposed to handle unsupported types?

--Andy

>
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> ---
>  arch/x86/include/asm/cacheflush.h |    4 ++++
>  arch/x86/mm/pat.c                 |   16 +++++++++++++---
>  2 files changed, 17 insertions(+), 3 deletions(-)
>
> diff --git a/arch/x86/include/asm/cacheflush.h b/arch/x86/include/asm/cacheflush.h
> index 157644b..c912680 100644
> --- a/arch/x86/include/asm/cacheflush.h
> +++ b/arch/x86/include/asm/cacheflush.h
> @@ -53,6 +53,10 @@ static inline void set_page_memtype(struct page *pg,
>         case _PAGE_CACHE_MODE_WB:
>                 memtype_flags = _PGMT_WB;
>                 break;
> +       case _PAGE_CACHE_MODE_WT:
> +       case _PAGE_CACHE_MODE_WP:
> +               pr_err("set_page_memtype: unsupported cachemode %d\n", memtype);
> +               BUG();
>         default:
>                 memtype_flags = _PGMT_DEFAULT;
>                 break;
> diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
> index 598d7c7..7644967 100644
> --- a/arch/x86/mm/pat.c
> +++ b/arch/x86/mm/pat.c
> @@ -268,6 +268,8 @@ static int pat_pagerange_is_ram(resource_size_t start, resource_size_t end)
>
>  /*
>   * For RAM pages, we use page flags to mark the pages with appropriate type.
> + * The page flags are currently limited to three types, WB, WC and UC. Hence,
> + * any request to WT or WP will fail with -EINVAL.
>   * Here we do two pass:
>   * - Find the memtype of all the pages in the range, look for any conflicts
>   * - In case of no conflicts, set the new memtype for pages in the range
> @@ -279,6 +281,13 @@ static int reserve_ram_pages_type(u64 start, u64 end,
>         struct page *page;
>         u64 pfn;
>
> +       if ((req_type == _PAGE_CACHE_MODE_WT) ||
> +           (req_type == _PAGE_CACHE_MODE_WP)) {
> +               if (new_type)
> +                       *new_type = _PAGE_CACHE_MODE_UC_MINUS;
> +               return -EINVAL;
> +       }
> +
>         if (req_type == _PAGE_CACHE_MODE_UC) {
>                 /* We do not support strong UC */
>                 WARN_ON_ONCE(1);
> @@ -328,6 +337,7 @@ static int free_ram_pages_type(u64 start, u64 end)
>   * - _PAGE_CACHE_MODE_WC
>   * - _PAGE_CACHE_MODE_UC_MINUS
>   * - _PAGE_CACHE_MODE_UC
> + * - _PAGE_CACHE_MODE_WT
>   *
>   * If new_type is NULL, function will return an error if it cannot reserve the
>   * region with req_type. If new_type is non-NULL, function will return
> @@ -347,10 +357,10 @@ int reserve_memtype(u64 start, u64 end, enum page_cache_mode req_type,
>         if (!pat_enabled) {
>                 /* This is identical to page table setting without PAT */
>                 if (new_type) {
> -                       if (req_type == _PAGE_CACHE_MODE_WC)
> -                               *new_type = _PAGE_CACHE_MODE_UC_MINUS;
> +                       if (req_type == _PAGE_CACHE_MODE_WB)
> +                               *new_type = _PAGE_CACHE_MODE_WB;
>                         else
> -                               *new_type = req_type;
> +                               *new_type = _PAGE_CACHE_MODE_UC_MINUS;
>                 }
>                 return 0;
>         }



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
