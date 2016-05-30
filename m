Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3AA1D6B025E
	for <linux-mm@kvack.org>; Mon, 30 May 2016 05:36:12 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id q17so83151396lbn.3
        for <linux-mm@kvack.org>; Mon, 30 May 2016 02:36:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l1si31789895wjy.221.2016.05.30.02.36.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 May 2016 02:36:10 -0700 (PDT)
Subject: Re: PATCH v6v2 02/12] mm: migrate: support non-lru movable page
 migration
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-3-git-send-email-minchan@kernel.org>
 <20160530013926.GB8683@bbox>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2bc277c4-4257-c6cb-2e37-ee5de985410b@suse.cz>
Date: Mon, 30 May 2016 11:36:07 +0200
MIME-Version: 1.0
In-Reply-To: <20160530013926.GB8683@bbox>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

On 05/30/2016 03:39 AM, Minchan Kim wrote:
> After isolation, VM calls migratepage of driver with isolated page.
> The function of migratepage is to move content of the old page to new page
> and set up fields of struct page newpage. Keep in mind that you should
> clear PG_movable of oldpage via __ClearPageMovable under page_lock if you
> migrated the oldpage successfully and returns 0.

This "clear PG_movable" is one of the reasons I was confused about what 
__ClearPageMovable() really does. There's no actual "PG_movable" page 
flag and the function doesn't clear even the actual mapping flag :) Also 
same thing in the Documentation/ part.

Something like "... you should indicate to the VM that the oldpage is no 
longer movable via __ClearPageMovable() ..."?

> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -81,6 +81,39 @@ static inline bool migrate_async_suitable(int migratetype)
>
>  #ifdef CONFIG_COMPACTION
>
> +int PageMovable(struct page *page)
> +{
> +	struct address_space *mapping;
> +
> +	VM_BUG_ON_PAGE(!PageLocked(page), page);
> +	if (!__PageMovable(page))
> +		return 0;
> +
> +	mapping = page_mapping(page);
> +	if (mapping && mapping->a_ops && mapping->a_ops->isolate_page)
> +		return 1;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(PageMovable);
> +
> +void __SetPageMovable(struct page *page, struct address_space *mapping)
> +{
> +	VM_BUG_ON_PAGE(!PageLocked(page), page);
> +	VM_BUG_ON_PAGE((unsigned long)mapping & PAGE_MAPPING_MOVABLE, page);
> +	page->mapping = (void *)((unsigned long)mapping | PAGE_MAPPING_MOVABLE);
> +}
> +EXPORT_SYMBOL(__SetPageMovable);
> +
> +void __ClearPageMovable(struct page *page)
> +{
> +	VM_BUG_ON_PAGE(!PageLocked(page), page);
> +	VM_BUG_ON_PAGE(!PageMovable(page), page);
> +	page->mapping = (void *)((unsigned long)page->mapping &
> +				PAGE_MAPPING_MOVABLE);
> +}
> +EXPORT_SYMBOL(__ClearPageMovable);

The second confusing thing is that the function is named 
__ClearPageMovable(), but what it really clears is the mapping pointer,
which is not at all the opposite of what __SetPageMovable() does.

I know it's explained in the documentation, but it also deserves a 
comment here so it doesn't confuse everyone who looks at it.
Even better would be a less confusing name for the function, but I can't 
offer one right now.

> diff --git a/mm/util.c b/mm/util.c
> index 917e0e3d0f8e..b756ee36f7f0 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -399,10 +399,12 @@ struct address_space *page_mapping(struct page *page)
>  	}
>
>  	mapping = page->mapping;

I'd probably use READ_ONCE() here to be safe. Not all callers are under 
page lock?

> -	if ((unsigned long)mapping & PAGE_MAPPING_FLAGS)
> +	if ((unsigned long)mapping & PAGE_MAPPING_ANON)
>  		return NULL;
> -	return mapping;
> +
> +	return (void *)((unsigned long)mapping & ~PAGE_MAPPING_FLAGS);
>  }
> +EXPORT_SYMBOL(page_mapping);
>
>  /* Slow path of page_mapcount() for compound pages */
>  int __page_mapcount(struct page *page)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
