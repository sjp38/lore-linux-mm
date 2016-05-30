Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 235816B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 05:01:37 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id ne4so82794803lbc.1
        for <linux-mm@kvack.org>; Mon, 30 May 2016 02:01:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s68si12211197wme.28.2016.05.30.02.01.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 May 2016 02:01:35 -0700 (PDT)
Subject: Re: [PATCH v6 02/12] mm: migrate: support non-lru movable page
 migration
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-3-git-send-email-minchan@kernel.org>
 <ebe3244c-4821-aad2-ed32-8e730a882438@suse.cz> <20160530013327.GA8683@bbox>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <14ce4626-b3b6-c1f8-f5c4-7e762e77f54f@suse.cz>
Date: Mon, 30 May 2016 11:01:31 +0200
MIME-Version: 1.0
In-Reply-To: <20160530013327.GA8683@bbox>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

On 05/30/2016 03:33 AM, Minchan Kim wrote:
>>
>>
>>> +	page->mapping = (void *)((unsigned long)page->mapping &
>>> +				PAGE_MAPPING_MOVABLE);
>>
>> This should be negated to clear... use ~PAGE_MAPPING_MOVABLE ?
>
> No.
>
> The intention is to clear only mapping value but PAGE_MAPPING_MOVABLE
> flag. So, any new migration trial will be failed because PageMovable
> checks page's mapping value but ongoing migraion handling can catch
> whether it's movable page or not with the type bit.

Oh, OK, I got that wrong. I'll point out in the reply to the v6v2 what 
misled me :)

>>
>> So this effectively prevents movable compound pages from being
>> migrated. Are you sure no users of this functionality are going to
>> have compound pages? I assumed that they could, and so made the code
>> like this, with the is_lru variable (which is redundant after your
>> change).
>
> This implementation at the moment disables effectively non-lru compound
> page migration but I'm not a god so I can't make sure no one doesn't want
> it in future. If someone want it, we can support it then because this work
> doesn't prevent it by design.

Oh well. As long as the balloon pages or zsmalloc don't already use 
compound pages...

>
> I thouht PageCompound check right before isolate_movable_page in
> isolate_migratepages_block will filter it out mostly but yeah
> it is racy without zone->lru_lock so it could reach to isolate_movable_page.
> However, PageMovable check in there investigates mapping, mapping->a_ops,
> and a_ops->isolate_page to verify whether it's movable page or not.
>
> I thought it's sufficient to filter THP page.

I guess, yeah.

>>
>> [...]
>>
>>> @@ -755,33 +844,69 @@ static int move_to_new_page(struct page *newpage, struct page *page,
>>> 				enum migrate_mode mode)
>>> {
>>> 	struct address_space *mapping;
>>> -	int rc;
>>> +	int rc = -EAGAIN;
>>> +	bool is_lru = !__PageMovable(page);
>>>
>>> 	VM_BUG_ON_PAGE(!PageLocked(page), page);
>>> 	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
>>>
>>> 	mapping = page_mapping(page);
>>> -	if (!mapping)
>>> -		rc = migrate_page(mapping, newpage, page, mode);
>>> -	else if (mapping->a_ops->migratepage)
>>> -		/*
>>> -		 * Most pages have a mapping and most filesystems provide a
>>> -		 * migratepage callback. Anonymous pages are part of swap
>>> -		 * space which also has its own migratepage callback. This
>>> -		 * is the most common path for page migration.
>>> -		 */
>>> -		rc = mapping->a_ops->migratepage(mapping, newpage, page, mode);
>>> -	else
>>> -		rc = fallback_migrate_page(mapping, newpage, page, mode);
>>> +	/*
>>> +	 * In case of non-lru page, it could be released after
>>> +	 * isolation step. In that case, we shouldn't try
>>> +	 * fallback migration which is designed for LRU pages.
>>> +	 */
>>
>> Hmm but is_lru was determined from !__PageMovable() above, also well
>> after the isolation step. So if the driver already released it, we
>> wouldn't detect it? And this function is all under same page lock,
>> so if __PageMovable was true above, so will be PageMovable below?
>
> You are missing what I mentioned above.
> We should keep the type bit to catch what you are saying(i.e., driver
> already released).
>
> __PageMovable just checks PAGE_MAPPING_MOVABLE flag and PageMovable
> checks page->mapping valid while __ClearPageMovable reset only
> valid vaule of mapping, not PAGE_MAPPING_MOVABLE flag.
>
> I wrote it down in Documentation/vm/page_migration.
>
> "For testing of non-lru movable page, VM supports __PageMovable function.
> However, it doesn't guarantee to identify non-lru movable page because
> page->mapping field is unified with other variables in struct page.
> As well, if driver releases the page after isolation by VM, page->mapping
> doesn't have stable value although it has PAGE_MAPPING_MOVABLE
> (Look at __ClearPageMovable). But __PageMovable is cheap to catch whether
> page is LRU or non-lru movable once the page has been isolated. Because
> LRU pages never can have PAGE_MAPPING_MOVABLE in page->mapping. It is also
> good for just peeking to test non-lru movable pages before more expensive
> checking with lock_page in pfn scanning to select victim.
>
> For guaranteeing non-lru movable page, VM provides PageMovable function.
> Unlike __PageMovable, PageMovable functions validates page->mapping and
> mapping->a_ops->isolate_page under lock_page. The lock_page prevents sudden
> destroying of page->mapping.
>
> Driver using __SetPageMovable should clear the flag via __ClearMovablePage
> under page_lock before the releasing the page."

Right, I get it now.


>>> +		if (!((unsigned long)page->mapping & PAGE_MAPPING_FLAGS))
>>> 			page->mapping = NULL;
>>
>> The two lines above make little sense to me without a comment.
>
> I folded this.
>
> @@ -901,7 +901,12 @@ static int move_to_new_page(struct page *newpage, struct page *page,
>                         __ClearPageIsolated(page);
>                 }
>
> -               if (!((unsigned long)page->mapping & PAGE_MAPPING_FLAGS))
> +               /*
> +                * Anonymous and movable page->mapping will be cleard by
> +                * free_pages_prepare so don't reset it here for keeping
> +                * the type to work PageAnon, for example.
> +                */
> +               if (!PageMappingFlags(page))
>                         page->mapping = NULL;
>         }

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
