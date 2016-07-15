Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C0BFD6B025F
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 21:21:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so187801014pfa.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 18:21:02 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id 123si4050952pfg.205.2016.07.14.18.21.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 18:21:02 -0700 (PDT)
Message-ID: <57883A1F.8070600@huawei.com>
Date: Fri, 15 Jul 2016 09:19:27 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mem-hotplug: use GFP_HIGHUSER_MOVABLE and alloc from
 next node in alloc_migrate_target()
References: <5786F81B.1070502@huawei.com> <alpine.DEB.2.10.1607141513320.72383@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1607141513320.72383@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/7/15 6:17, David Rientjes wrote:

> On Thu, 14 Jul 2016, Xishi Qiu wrote:
> 
>> alloc_migrate_target() is called from migrate_pages(), and the page
>> is always from user space, so we can add __GFP_HIGHMEM directly.
>>
>> Second, when we offline a node, the new page should alloced from other
>> nodes instead of the current node, because re-migrate is a waste of
>> time.
>>
> 
> alloc_migrate_target() is not only used from memory hotplug, it is also 
> used for CMA: we won't be isolating PageHuge() pages in 
> isolate_migratepages_range(), so this would cause a regression where we'd 
> be migrating memory to a remote NUMA node rather than preferring to 
> allocate locally.
> 

> You may find it useful to use the 'private' field of the migrate_pages() 
> callback to specify the node the page should preferably be migrated to.
> 

OK, I know, I'll rewrite v2.

>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>> ---
>>  mm/page_isolation.c | 16 ++++++----------
>>  1 file changed, 6 insertions(+), 10 deletions(-)
>>
>> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
>> index 612122b..83848dc 100644
>> --- a/mm/page_isolation.c
>> +++ b/mm/page_isolation.c
>> @@ -282,20 +282,16 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
>>  struct page *alloc_migrate_target(struct page *page, unsigned long private,
>>  				  int **resultp)
>>  {
>> -	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
>> -
>>  	/*
>> -	 * TODO: allocate a destination hugepage from a nearest neighbor node,
>> +	 * TODO: allocate a destination page from a nearest neighbor node,
>>  	 * accordance with memory policy of the user process if possible. For
>>  	 * now as a simple work-around, we use the next node for destination.
>>  	 */
>> +	int nid = next_node_in(page_to_nid(page), node_online_map);
>> +
>>  	if (PageHuge(page))
>>  		return alloc_huge_page_node(page_hstate(compound_head(page)),
>> -					    next_node_in(page_to_nid(page),
>> -							 node_online_map));
>> -
>> -	if (PageHighMem(page))
>> -		gfp_mask |= __GFP_HIGHMEM;
>> -
>> -	return alloc_page(gfp_mask);
>> +						 nid);
>> +	else
>> +		return __alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
> 
> I don't think this __alloc_pages_node() does what you think it does, it 
> only prefers nid here and will readily fallback to other nodes if 
> necessary.  That is different than alloc_huge_page_node() which does no 
> fallback.  So there's two issues with this change: (1) inconsistency 
> between PageHuge() and !PageHuge() behavior, and (2) the use of 
> __alloc_pages_node() does not match the commit description which states 
> "re-migrate is a waste of time."
>

Yes, you are right, how about change the changelog, one is membind, the
other is prefer?

 

Thanks,
Xishi Qiu

> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
