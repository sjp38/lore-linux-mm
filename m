Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 124386B025E
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 08:34:26 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id s63so83508661wms.7
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 05:34:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kr2si81255277wjc.288.2017.01.04.05.34.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 05:34:24 -0800 (PST)
Subject: Re: [PATCH 2/7] mm, vmscan: add active list aging tracepoint
References: <20170104101942.4860-1-mhocko@kernel.org>
 <20170104101942.4860-3-mhocko@kernel.org>
 <646c3551-e794-611c-5247-490bd89133db@suse.cz>
 <20170104131653.GH25453@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <90fd4f45-a616-be78-fe4d-6abb0d0b083d@suse.cz>
Date: Wed, 4 Jan 2017 14:34:22 +0100
MIME-Version: 1.0
In-Reply-To: <20170104131653.GH25453@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 01/04/2017 02:16 PM, Michal Hocko wrote:
> On Wed 04-01-17 13:52:24, Vlastimil Babka wrote:
>> On 01/04/2017 11:19 AM, Michal Hocko wrote:
>>> From: Michal Hocko <mhocko@suse.com>
>>>
>>> Our reclaim process has several tracepoints to tell us more about how
>>> things are progressing. We are, however, missing a tracepoint to track
>>> active list aging. Introduce mm_vmscan_lru_shrink_active which reports
>>> the number of
>>> 	- nr_scanned, nr_taken pages to tell us the LRU isolation
>>> 	  effectiveness.
>>
>> Well, this point is no longer true, is it...
> 
> ups, leftover
> 	- nr_take - the number of isolated pages

nr_taken

> 
>>> 	- nr_referenced pages which tells us that we are hitting referenced
>>> 	  pages which are deactivated. If this is a large part of the
>>> 	  reported nr_deactivated pages then we might be hitting into
>>> 	  the active list too early because they might be still part of
>>> 	  the working set. This might help to debug performance issues.
>>> 	- nr_activated pages which tells us how many pages are kept on the
>>
>> "nr_activated" is slightly misleading? They remain active, they are not
>> being activated (that's why the pgactivate vmstat is also not increased
>> on them, right?). I guess rename to "nr_active" ? Or something like
>> "nr_remain_active" although that's longer.
> 
> will go with nr_active

OK.

> 
>>
>> [...]
>>
>>> @@ -1857,6 +1859,7 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
>>>  	unsigned long pgmoved = 0;
>>>  	struct page *page;
>>>  	int nr_pages;
>>> +	int nr_moved = 0;
>>>  
>>>  	while (!list_empty(list)) {
>>>  		page = lru_to_page(list);
>>> @@ -1882,11 +1885,15 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
>>>  				spin_lock_irq(&pgdat->lru_lock);
>>>  			} else
>>>  				list_add(&page->lru, pages_to_free);
>>> +		} else {
>>> +			nr_moved += nr_pages;
>>>  		}
>>>  	}
>>>  
>>>  	if (!is_active_lru(lru))
>>>  		__count_vm_events(PGDEACTIVATE, pgmoved);
>>
>> So we now have pgmoved and nr_moved. One is used for vmstat, other for
>> tracepoint, and the only difference is that vmstat includes pages where
>> we raced with page being unmapped from all pte's (IIUC?) and thus
>> removed from lru, which should be rather rare? I guess those are being
>> counted into vmstat only due to how the code evolved from using pagevec.
>> If we don't consider them in the tracepoint, then I'd suggest we don't
>> count them into vmstat either, and simplify this.
> 
> OK, but I would prefer to have this in a separate patch, OK?

Sure, thanks!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
