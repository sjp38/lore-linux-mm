Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id DCB49828E1
	for <linux-mm@kvack.org>; Mon, 16 May 2016 03:05:34 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gw7so242703004pac.0
        for <linux-mm@kvack.org>; Mon, 16 May 2016 00:05:34 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id zu17si43999776pab.174.2016.05.16.00.05.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 00:05:33 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id zy2so16187048pac.2
        for <linux-mm@kvack.org>; Mon, 16 May 2016 00:05:33 -0700 (PDT)
Date: Mon, 16 May 2016 16:04:55 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 02/12] mm: migrate: support non-lru movable page
 migration
Message-ID: <20160516070455.GA28813@swordfish>
References: <1462760433-32357-1-git-send-email-minchan@kernel.org>
 <1462760433-32357-3-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462760433-32357-3-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

On (05/09/16 11:20), Minchan Kim wrote:
> +++ b/include/linux/migrate.h
> @@ -32,11 +32,16 @@ extern char *migrate_reason_names[MR_TYPES];
>  
>  #ifdef CONFIG_MIGRATION
>  
> +extern int PageMovable(struct page *page);
> +extern void __SetPageMovable(struct page *page, struct address_space *mapping);
> +extern void __ClearPageMovable(struct page *page);
>  extern void putback_movable_pages(struct list_head *l);
>  extern int migrate_page(struct address_space *,
>  			struct page *, struct page *, enum migrate_mode);
>  extern int migrate_pages(struct list_head *l, new_page_t new, free_page_t free,
>  		unsigned long private, enum migrate_mode mode, int reason);
> +extern bool isolate_movable_page(struct page *page, isolate_mode_t mode);
> +extern void putback_movable_page(struct page *page);
>  
>  extern int migrate_prep(void);
>  extern int migrate_prep_local(void);

__ClearPageMovable() is under CONFIG_MIGRATION in include/linux/migrate.h,
but zsmalloc checks for CONFIG_COMPACTION.

can we have stub declarations of movable functions for !CONFIG_MIGRATION builds?
otherwise the users (zsmalloc, for example) have to do things like

static void reset_page(struct page *page)
{
#ifdef CONFIG_COMPACTION
        __ClearPageMovable(page);
#endif
        clear_bit(PG_private, &page->flags);
        clear_bit(PG_private_2, &page->flags);
        set_page_private(page, 0);
        ClearPageHugeObject(page);
        page->freelist = NULL;
}

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
