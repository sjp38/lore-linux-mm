Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id A17B66B0253
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 09:58:15 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so118053679wib.1
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 06:58:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dk2si14100737wib.80.2015.07.27.06.58.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Jul 2015 06:58:13 -0700 (PDT)
Subject: Re: [PATCH 4/4] mm: remove direct calling of migration
References: <1436776519-17337-1-git-send-email-gioh.kim@lge.com>
 <1436776519-17337-5-git-send-email-gioh.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55B638F1.9090407@suse.cz>
Date: Mon, 27 Jul 2015 15:58:09 +0200
MIME-Version: 1.0
In-Reply-To: <1436776519-17337-5-git-send-email-gioh.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, jlayton@poochiereds.net, bfields@fieldses.org, iamjoonsoo.kim@lge.com, viro@zeniv.linux.org.uk, mst@redhat.com, koct9i@gmail.com, minchan@kernel.org, aquini@redhat.com, linux-fsdevel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: dri-devel@lists.freedesktop.org, akpm@linux-foundation.org, Gioh Kim <gurugio@hanmail.net>

On 07/13/2015 10:35 AM, Gioh Kim wrote:
> From: Gioh Kim <gurugio@hanmail.net>
>
> Migration is completely generalized so that migrating mobile page
> is processed with lru-pages in move_to_new_page.
>
> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
> Acked-by: Rafael Aquini <aquini@redhat.com>

Why not just fold this to Patch 3? You already modify this hunk there, 
and prior to patch 3, the hunk was balloon-pages specific. You made it 
look generic only to remove it, which is unneeded code churn and I don't 
think it adds anything wrt e.g. bisectability.

> ---
>   mm/migrate.c | 15 ---------------
>   1 file changed, 15 deletions(-)
>
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 53f0081d..e6644ac 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -844,21 +844,6 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>   		}
>   	}
>
> -	if (unlikely(mobile_page(page))) {
> -		/*
> -		 * A mobile page does not need any special attention from
> -		 * physical to virtual reverse mapping procedures.
> -		 * Skip any attempt to unmap PTEs or to remap swap cache,
> -		 * in order to avoid burning cycles at rmap level, and perform
> -		 * the page migration right away (proteced by page lock).
> -		 */
> -		lock_page(newpage);
> -		rc = page->mapping->a_ops->migratepage(page->mapping,
> -						       newpage, page, mode);
> -		unlock_page(newpage);
> -		goto out_unlock;
> -	}
> -
>   	/*
>   	 * Corner case handling:
>   	 * 1. When a new swap-cache page is read into, it is added to the LRU
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
