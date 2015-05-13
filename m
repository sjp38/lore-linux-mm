Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id E4A066B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 22:04:27 -0400 (EDT)
Received: by wggj6 with SMTP id j6so28604876wgg.3
        for <linux-mm@kvack.org>; Tue, 12 May 2015 19:04:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id cx3si5970789wib.115.2015.05.12.19.04.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 19:04:26 -0700 (PDT)
Message-ID: <5552B11C.7040304@redhat.com>
Date: Tue, 12 May 2015 22:04:12 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] rmap: fix theoretical race between do_wp_page and
 shrink_active_list
References: <20150513014352.GC8267@blaptop>
In-Reply-To: <20150513014352.GC8267@blaptop>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>

On 05/12/2015 09:43 PM, Minchan Kim wrote:
> Hi, Rik
> 
> I'd like to bring up the issue in this thread although I already gave
> my Acked-by.
> 
> Below issue causes by no PG_locked page in page_referenced while
> page_move_anon_rmap depends on PG_locked to prevent race with rmap code.
> 
> So, although this patch fixes below one example, we still have a problem
> in rmap.
> 
> If page_referenced holds PG_locked for all of pages unconditionally,
> we don't need this patch and might remove READ_ONCE introduced by
> 80e148 and more than.
> 
> What do you think about?

Maybe the reclaim code and page_referenced are fine.

However, I have seen one real world bug report of a page->mapping
pointing to an anon_vma without the PAGE_MAPPING_ANON bit being
set.

This is a pretty hard to hit race, so I have only ever heard of
it happening once, and I do not remember the details of exactly
what code blew up trying to follow the page->mapping pointer in
the wrong way.

I wish I remember what needs this patch, but I have a rather
strong suspicion there is something that needs it...

Acked-by: Rik van Riel <riel@redhat.com>

> On Tue, May 12, 2015 at 01:18:39PM +0300, Vladimir Davydov wrote:
>> As noted by Paul the compiler is free to store a temporary result in a
>> variable on stack, heap or global unless it is explicitly marked as
>> volatile, see:
>>
>>   http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2015/n4455.html#sample-optimizations
>>
>> This can result in a race between do_wp_page() and shrink_active_list()
>> as follows.
>>
>> In do_wp_page() we can call page_move_anon_rmap(), which sets
>> page->mapping as follows:
>>
>>   anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
>>   page->mapping = (struct address_space *) anon_vma;
>>
>> The page in question may be on an LRU list, because nowhere in
>> do_wp_page() we remove it from the list, neither do we take any LRU
>> related locks. Although the page is locked, shrink_active_list() can
>> still call page_referenced() on it concurrently, because the latter does
>> not require an anonymous page to be locked:
>>
>>   CPU0                          CPU1
>>   ----                          ----
>>   do_wp_page                    shrink_active_list
>>    lock_page                     page_referenced
>>                                   PageAnon->yes, so skip trylock_page
>>    page_move_anon_rmap
>>     page->mapping = anon_vma
>>                                   rmap_walk
>>                                    PageAnon->no
>>                                    rmap_walk_file
>>                                     BUG
>>     page->mapping += PAGE_MAPPING_ANON
>>
>> This patch fixes this race by explicitly forbidding the compiler to
>> split page->mapping store in page_move_anon_rmap() with the aid of
>> WRITE_ONCE.
>>
>> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
>> Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
>> Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Hugh Dickins <hughd@google.com>
>> ---
>> Changes in v2:
>>  - do not add READ_ONCE to PageAnon and WRITE_ONCE to
>>    __page_set_anon_rmap and __hugepage_set_anon_rmap (Kirill)
>>
>>  mm/rmap.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index 24dd3f9fee27..8b18fd4227d1 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -950,7 +950,7 @@ void page_move_anon_rmap(struct page *page,
>>  	VM_BUG_ON_PAGE(page->index != linear_page_index(vma, address), page);
>>  
>>  	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
>> -	page->mapping = (struct address_space *) anon_vma;
>> +	WRITE_ONCE(page->mapping, (struct address_space *) anon_vma);
>>  }
>>  
>>  /**
>> -- 
>> 1.7.10.4
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
