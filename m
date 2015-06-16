Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 27DC26B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 08:16:57 -0400 (EDT)
Received: by lblr1 with SMTP id r1so9571654lbl.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 05:16:56 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id uc10si1501350wjc.54.2015.06.16.05.16.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Jun 2015 05:16:55 -0700 (PDT)
Message-ID: <558013B5.4050204@suse.cz>
Date: Tue, 16 Jun 2015 14:16:53 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 4/6] mm, compaction: always skip compound pages by order
 in migrate scanner
References: <1433928754-966-1-git-send-email-vbabka@suse.cz> <1433928754-966-5-git-send-email-vbabka@suse.cz> <20150616054436.GD12641@js1304-P5Q-DELUXE>
In-Reply-To: <20150616054436.GD12641@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On 06/16/2015 07:44 AM, Joonsoo Kim wrote:
> On Wed, Jun 10, 2015 at 11:32:32AM +0200, Vlastimil Babka wrote:

[...]

>> @@ -723,39 +725,35 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>>  		 * It's possible to migrate LRU pages and balloon pages
>>  		 * Skip any other type of page
>>  		 */
>> -		if (!PageLRU(page)) {
>> +		is_lru = PageLRU(page);
>> +		if (!is_lru) {
>>  			if (unlikely(balloon_page_movable(page))) {
>>  				if (balloon_page_isolate(page)) {
>>  					/* Successfully isolated */
>>  					goto isolate_success;
>>  				}
>>  			}
>> -			continue;
>>  		}
>>  
>>  		/*
>> -		 * PageLRU is set. lru_lock normally excludes isolation
>> -		 * splitting and collapsing (collapsing has already happened
>> -		 * if PageLRU is set) but the lock is not necessarily taken
>> -		 * here and it is wasteful to take it just to check transhuge.
>> -		 * Check PageCompound without lock and skip the whole pageblock
>> -		 * if it's a transhuge page, as calling compound_order()
>> -		 * without preventing THP from splitting the page underneath us
>> -		 * may return surprising results.
>> -		 * If we happen to check a THP tail page, compound_order()
>> -		 * returns 0. It should be rare enough to not bother with
>> -		 * using compound_head() in that case.
>> +		 * Regardless of being on LRU, compound pages such as THP and
>> +		 * hugetlbfs are not to be compacted. We can potentially save
>> +		 * a lot of iterations if we skip them at once. The check is
>> +		 * racy, but we can consider only valid values and the only
>> +		 * danger is skipping too much.
>>  		 */
>>  		if (PageCompound(page)) {
>> -			int nr;
>> -			if (locked)
>> -				nr = 1 << compound_order(page);
>> -			else
>> -				nr = pageblock_nr_pages;
>> -			low_pfn += nr - 1;
>> +			unsigned int comp_order = compound_order(page);
>> +
>> +			if (comp_order > 0 && comp_order < MAX_ORDER)
>> +				low_pfn += (1UL << comp_order) - 1;
>> +
>>  			continue;
>>  		}
> 
> How about moving this PageCompound() check up to the PageLRU check?
> Is there any relationship between balloon page and PageCompound()?

I didn't want to assume if there's a relationship or not, as per the changelog:

>> After this patch, all pages are tested for PageCompound() and we skip them by
>> compound_order().  The test is done after the test for balloon_page_movable()
>> as we don't want to assume if balloon pages (or other pages with own isolation
>> and migration implementation if a generic API gets implemented) are compound
>> or not.

> It will remove is_lru and code would be more understandable.

Right, it just felt safer and more future-proof this way.

> Otherwise,
> 
> Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
