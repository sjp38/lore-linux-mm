Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 26F4C6B0003
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 05:16:17 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id 137so3977432wml.0
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 02:16:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 6si344975wrn.544.2018.02.13.02.16.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Feb 2018 02:16:15 -0800 (PST)
Date: Tue, 13 Feb 2018 11:16:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_poison: move PAGE_POISON to page_poison.c
Message-ID: <20180213101615.GO3443@dhcp22.suse.cz>
References: <1518163694-27155-1-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1518163694-27155-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mst@redhat.com, akpm@linux-foundation.org

On Fri 09-02-18 16:08:14, Wei Wang wrote:
> The PAGE_POISON macro is used in page_poison.c only, so avoid exporting
> it. Also remove the "mm/debug-pagealloc.c" related comment, which is
> obsolete.

Why is this an improvement? I thought the whole point of poison.h is to
keep all the poison value at a single place to make them obviously
unique.

> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> ---
>  include/linux/poison.h | 7 -------
>  mm/page_poison.c       | 6 ++++++
>  2 files changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/poison.h b/include/linux/poison.h
> index 15927eb..348bf67 100644
> --- a/include/linux/poison.h
> +++ b/include/linux/poison.h
> @@ -30,13 +30,6 @@
>   */
>  #define TIMER_ENTRY_STATIC	((void *) 0x300 + POISON_POINTER_DELTA)
>  
> -/********** mm/debug-pagealloc.c **********/
> -#ifdef CONFIG_PAGE_POISONING_ZERO
> -#define PAGE_POISON 0x00
> -#else
> -#define PAGE_POISON 0xaa
> -#endif
> -
>  /********** mm/page_alloc.c ************/
>  
>  #define TAIL_MAPPING	((void *) 0x400 + POISON_POINTER_DELTA)
> diff --git a/mm/page_poison.c b/mm/page_poison.c
> index e83fd44..8aaf076 100644
> --- a/mm/page_poison.c
> +++ b/mm/page_poison.c
> @@ -7,6 +7,12 @@
>  #include <linux/poison.h>
>  #include <linux/ratelimit.h>
>  
> +#ifdef CONFIG_PAGE_POISONING_ZERO
> +#define PAGE_POISON 0x00
> +#else
> +#define PAGE_POISON 0xaa
> +#endif
> +
>  static bool want_page_poisoning __read_mostly;
>  
>  static int early_page_poison_param(char *buf)
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
