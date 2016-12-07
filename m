Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A02C16B025E
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 08:08:16 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id hb5so83794169wjc.2
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 05:08:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k8si24314213wjv.25.2016.12.07.05.08.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Dec 2016 05:08:15 -0800 (PST)
Subject: Re: [PATCH] mm: page_idle_get_page() does not need zone_lru_lock
References: <alpine.LSU.2.11.1612052152560.13021@eggly.anvils>
 <20161207110845.GA4655@esperanza>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3e48f802-b489-a052-f703-dd456ffeda46@suse.cz>
Date: Wed, 7 Dec 2016 14:07:56 +0100
MIME-Version: 1.0
In-Reply-To: <20161207110845.GA4655@esperanza>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@tarantool.org>, Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org

On 12/07/2016 12:08 PM, Vladimir Davydov wrote:
> Hello,
> 
> On Mon, Dec 05, 2016 at 09:55:10PM -0800, Hugh Dickins wrote:
>> Rechecking PageLRU() after get_page_unless_zero() may have value, but
>> holding zone_lru_lock around that serves no useful purpose: delete it.
> 
> IIRC this lock/unlock was added on purpose, by request from Minchan. It
> serves as a barrier that guarantees that all page fields (specifically
> ->mapping in case of anonymous pages) have been properly initialized by
> the time we pass it to rmap_walk(). Here's a reference to the thread
> where this problem was discussed:
> 
>   http://lkml.kernel.org/r/<20150430082531.GD21771@blaptop>

Um OK, but then there should have been a comment explaining why the lock
is there :/

Vlastimil

>>
>> Signed-off-by: Hugh Dickins <hughd@google.com>
>> ---
>>
>>  mm/page_idle.c |    4 ----
>>  1 file changed, 4 deletions(-)
>>
>> --- 4.9-rc8/mm/page_idle.c	2016-10-02 16:24:33.000000000 -0700
>> +++ linux/mm/page_idle.c	2016-12-05 19:44:32.646625435 -0800
>> @@ -30,7 +30,6 @@
>>  static struct page *page_idle_get_page(unsigned long pfn)
>>  {
>>  	struct page *page;
>> -	struct zone *zone;
>>  
>>  	if (!pfn_valid(pfn))
>>  		return NULL;
>> @@ -40,13 +39,10 @@ static struct page *page_idle_get_page(u
>>  	    !get_page_unless_zero(page))
>>  		return NULL;
>>  
>> -	zone = page_zone(page);
>> -	spin_lock_irq(zone_lru_lock(zone));
>>  	if (unlikely(!PageLRU(page))) {
>>  		put_page(page);
>>  		page = NULL;
>>  	}
>> -	spin_unlock_irq(zone_lru_lock(zone));
>>  	return page;
>>  }
>>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
