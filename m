Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id E31A86B0039
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 19:33:18 -0400 (EDT)
Received: by mail-qa0-f43.google.com with SMTP id w8so7806513qac.30
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 16:33:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v4si17189078qae.51.2014.08.20.16.33.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Aug 2014 16:33:17 -0700 (PDT)
Date: Wed, 20 Aug 2014 20:33:09 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH 2/7] mm/balloon_compaction: keep ballooned pages away
 from normal migration path
Message-ID: <20140820233308.GC3457@optiplex.redhat.com>
References: <20140820150435.4194.28003.stgit@buzz>
 <20140820150440.4194.70267.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140820150440.4194.70267.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, linux-kernel@vger.kernel.org

On Wed, Aug 20, 2014 at 07:04:40PM +0400, Konstantin Khlebnikov wrote:
> Proper testing shows yet another problem in balloon migration: it works only
> once for each page. balloon_page_movable() check page flags and page_count.
> In __unmap_and_move page is locked, reference counter is elevated, so
> balloon_page_movable() _always_ fails here. As result in __unmap_and_move()
> migration goes to the normal migration path.
> 
> Balloon ->migratepage() is so special, it returns MIGRATEPAGE_BALLOON_SUCCESS
> instead of MIGRATEPAGE_SUCCESS. After that in move_to_new_page() successfully
> migrated page got NULL into its mapping pointer and loses connectivity with
> balloon and ability for further migration.
> 
> It's safe to use __is_movable_balloon_page here: page is isolated and pinned.
> 
> Signed-off-by: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
> Cc: stable <stable@vger.kernel.org> # v3.8
> ---
>  mm/migrate.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index f78ec9b..161d044 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -873,7 +873,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>  		}
>  	}
>  
> -	if (unlikely(balloon_page_movable(page))) {
> +	if (unlikely(__is_movable_balloon_page(page))) {
>  		/*
>  		 * A ballooned page does not need any special attention from
>  		 * physical to virtual reverse mapping procedures.
> 
Acked-by: Rafael Aquini <aquini@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
