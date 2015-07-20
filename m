Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id EF0BD6B02BE
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 07:28:02 -0400 (EDT)
Received: by wicgb10 with SMTP id gb10so23876966wic.1
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 04:28:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pa6si34684141wjb.84.2015.07.20.04.28.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Jul 2015 04:28:01 -0700 (PDT)
Message-ID: <55ACDB3B.8010607@suse.cz>
Date: Mon, 20 Jul 2015 13:27:55 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm/page_owner: set correct gfp_mask on page_owner
References: <1436942039-16897-1-git-send-email-iamjoonsoo.kim@lge.com> <1436942039-16897-2-git-send-email-iamjoonsoo.kim@lge.com> <20150716000613.GE988@bgram>
In-Reply-To: <20150716000613.GE988@bgram>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 07/16/2015 02:06 AM, Minchan Kim wrote:
> On Wed, Jul 15, 2015 at 03:33:59PM +0900, Joonsoo Kim wrote:
>> @@ -2003,7 +2005,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
>>   	zone->free_area[order].nr_free--;
>>   	rmv_page_order(page);
>>
>> -	set_page_owner(page, order, 0);
>> +	set_page_owner(page, order, __GFP_MOVABLE);
>
> It seems the reason why  __GFP_MOVABLE is okay is that __isolate_free_page
> works on a free page on MIGRATE_MOVABLE|MIGRATE_CMA's pageblock. But if we
> break the assumption in future, here is broken again?

I didn't study the page owner code yet and I'm catching up after 
vacation, but I share your concern. But I don't think the correctness 
depends on the pageblock we are isolating from. I think the assumption 
is that the isolated freepage will be used as a target for migration, 
and that only movable pages can be successfully migrated (but also CMA 
pages, and that information can be lost?). However there are also 
efforts to allow migrate e.g. driver pages that won't be marked as 
movable. And I'm not sure which migratetype are balloon pages which 
already have special migration code.

So what I would think (without knowing all details) that the page owner 
info should be transferred during page migration with all the other 
flags, and shouldn't concern __isolate_free_page() at all?


> Please put the comment here to cause it.
>
> Otherwise, Good spot!
>
> Reviewed-by: Minchan Kim <minchan@kernel.org>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
