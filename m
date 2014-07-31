Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id E6A186B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 18:57:06 -0400 (EDT)
Received: by mail-ie0-f176.google.com with SMTP id tr6so4779508ieb.35
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 15:57:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r1si17749929icn.52.2014.07.31.15.57.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jul 2014 15:57:06 -0700 (PDT)
Date: Thu, 31 Jul 2014 15:57:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv2] CMA/HOTPLUG: clear buffer-head lru before page
 migration
Message-Id: <20140731155703.a8bc3b77af913c8b3a63090a@linux-foundation.org>
In-Reply-To: <53D9A86B.20208@lge.com>
References: <53D9A86B.20208@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: =?UTF-8?Q?'=EA=B9=80=EC=A4=80=EC=88=98'?= <iamjoonsoo.kim@lge.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>, Laura Abbott <lauraa@codeaurora.org>, Michal Nazarewicz <mina86@mina86.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ????????? <gunho.lee@lge.com>, 'Chanho Min' <chanho.min@lge.com>

On Thu, 31 Jul 2014 11:22:35 +0900 Gioh Kim <gioh.kim@lge.com> wrote:

> The previous PATCH inserts invalidate_bh_lrus() only into CMA code.
> HOTPLUG needs also dropping bh of lru.
> So v2 inserts invalidate_bh_lrus() into both of CMA and HOTPLUG.
> 
> 
> ---------------------------- 8< ----------------------------
> The bh must be free to migrate a page at which bh is mapped.
> The reference count of bh is increased when it is installed
> into lru so that the bh of lru must be freed before migrating the page.
> 
> This frees every bh of lru. We could free only bh of migrating page.
> But searching lru sometimes costs more than invalidating entire lru.
> 
> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> ---
>  mm/memory_hotplug.c |    1 +
>  mm/page_alloc.c     |    2 ++
>  2 files changed, 3 insertions(+)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index a3797d3..1c5454f 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1672,6 +1672,7 @@ repeat:
>                 lru_add_drain_all();
>                 cond_resched();
>                 drain_all_pages();
> +               invalidate_bh_lrus();

Both of these calls should have a comment explaining why
invalidate_bh_lrus() is being called.

>         }
> 
>         pfn = scan_movable_pages(start_pfn, end_pfn);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b99643d4..c00dedf 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6369,6 +6369,8 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>         if (ret)
>                 return ret;
> 
> +       invalidate_bh_lrus();
> +
>         ret = __alloc_contig_migrate_range(&cc, start, end);
>         if (ret)
>                 goto done;

I do feel that this change is likely to be beneficial, but I don't want
to apply such a patch until I know what its effects are upon all
alloc_contig_range() callers.  Especially hugetlb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
