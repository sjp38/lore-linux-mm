Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 18DCF6B0261
	for <linux-mm@kvack.org>; Tue, 31 May 2016 03:51:53 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id ne4so94858432lbc.1
        for <linux-mm@kvack.org>; Tue, 31 May 2016 00:51:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g126si17327074wmd.89.2016.05.31.00.51.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 00:51:50 -0700 (PDT)
Subject: Re: PATCH v6v2 02/12] mm: migrate: support non-lru movable page
 migration
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-3-git-send-email-minchan@kernel.org>
 <20160530013926.GB8683@bbox> <2bc277c4-4257-c6cb-2e37-ee5de985410b@suse.cz>
 <20160530162523.GA18314@bbox>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <bbc87219-d86d-d7a5-2a78-9f09a1549d65@suse.cz>
Date: Tue, 31 May 2016 09:51:47 +0200
MIME-Version: 1.0
In-Reply-To: <20160530162523.GA18314@bbox>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

On 05/30/2016 06:25 PM, Minchan Kim wrote:
>>> --- a/mm/compaction.c
>>> +++ b/mm/compaction.c
>>> @@ -81,6 +81,39 @@ static inline bool migrate_async_suitable(int migratetype)
>>>
>>> #ifdef CONFIG_COMPACTION
>>>
>>> +int PageMovable(struct page *page)
>>> +{
>>> +	struct address_space *mapping;
>>> +
>>> +	VM_BUG_ON_PAGE(!PageLocked(page), page);
>>> +	if (!__PageMovable(page))
>>> +		return 0;
>>> +
>>> +	mapping = page_mapping(page);
>>> +	if (mapping && mapping->a_ops && mapping->a_ops->isolate_page)
>>> +		return 1;
>>> +
>>> +	return 0;
>>> +}
>>> +EXPORT_SYMBOL(PageMovable);
>>> +
>>> +void __SetPageMovable(struct page *page, struct address_space *mapping)
>>> +{
>>> +	VM_BUG_ON_PAGE(!PageLocked(page), page);
>>> +	VM_BUG_ON_PAGE((unsigned long)mapping & PAGE_MAPPING_MOVABLE, page);
>>> +	page->mapping = (void *)((unsigned long)mapping | PAGE_MAPPING_MOVABLE);
>>> +}
>>> +EXPORT_SYMBOL(__SetPageMovable);
>>> +
>>> +void __ClearPageMovable(struct page *page)
>>> +{
>>> +	VM_BUG_ON_PAGE(!PageLocked(page), page);
>>> +	VM_BUG_ON_PAGE(!PageMovable(page), page);
>>> +	page->mapping = (void *)((unsigned long)page->mapping &
>>> +				PAGE_MAPPING_MOVABLE);
>>> +}
>>> +EXPORT_SYMBOL(__ClearPageMovable);
>>
>> The second confusing thing is that the function is named
>> __ClearPageMovable(), but what it really clears is the mapping
>> pointer,
>> which is not at all the opposite of what __SetPageMovable() does.
>>
>> I know it's explained in the documentation, but it also deserves a
>> comment here so it doesn't confuse everyone who looks at it.
>> Even better would be a less confusing name for the function, but I
>> can't offer one right now.
>
> To me, __ClearPageMovable naming is suitable for user POV.
> It effectively makes the page unmovable. The confusion is just caused
> by the implementation and I don't prefer exported API depends on the
> implementation. So I want to add just comment.
>
> I didn't add comment above the function because I don't want to export
> internal implementation to the user. I think they don't need to know it.
>
> index a7df2ae71f2a..d1d2063b4fd9 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -108,6 +108,11 @@ void __ClearPageMovable(struct page *page)
>  {
>         VM_BUG_ON_PAGE(!PageLocked(page), page);
>         VM_BUG_ON_PAGE(!PageMovable(page), page);
> +       /*
> +        * Clear registered address_space val with keeping PAGE_MAPPING_MOVABLE
> +        * flag so that VM can catch up released page by driver after isolation.
> +        * With it, VM migration doesn't try to put it back.
> +        */
>         page->mapping = (void *)((unsigned long)page->mapping &
>                                 PAGE_MAPPING_MOVABLE);

OK, that's fine!

>>
>>> diff --git a/mm/util.c b/mm/util.c
>>> index 917e0e3d0f8e..b756ee36f7f0 100644
>>> --- a/mm/util.c
>>> +++ b/mm/util.c
>>> @@ -399,10 +399,12 @@ struct address_space *page_mapping(struct page *page)
>>> 	}
>>>
>>> 	mapping = page->mapping;
>>
>> I'd probably use READ_ONCE() here to be safe. Not all callers are
>> under page lock?
>
> I don't understand. Yeah, all caller are not under page lock but at least,
> new user of movable pages should call it under page_lock.
> Yeah, I will write the rule down in document.
> In this case, what kinds of problem do you see?

After more thinking, probably none. It wouldn't prevent any extra races. 
Sorry for the noise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
