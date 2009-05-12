Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C726D6B0088
	for <linux-mm@kvack.org>; Tue, 12 May 2009 09:34:51 -0400 (EDT)
Message-ID: <4A097A80.9000502@redhat.com>
Date: Tue, 12 May 2009 09:32:48 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] vmscan: merge duplicate code in	shrink_active_list()
References: <20090501123541.7983a8ae.akpm@linux-foundation.org> <20090503031539.GC5702@localhost> <1241432635.7620.4732.camel@twins> <20090507121101.GB20934@localhost> <20090507151039.GA2413@cmpxchg.org> <20090507134410.0618b308.akpm@linux-foundation.org> <20090508081608.GA25117@localhost> <20090508125859.210a2a25.akpm@linux-foundation.org> <20090512025319.GD7518@localhost> <20090512162633.352313d6.minchan.kim@barrios-desktop> <20090512114807.GC5926@localhost>
In-Reply-To: <20090512114807.GC5926@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:
> On Tue, May 12, 2009 at 03:26:33PM +0800, Minchan Kim wrote:
>> On Tue, 12 May 2009 10:53:19 +0800
>> Wu Fengguang <fengguang.wu@intel.com> wrote:
>>
>>> The "move pages to active list" and "move pages to inactive list"
>>> code blocks are mostly identical and can be served by a function.
>>>
>>> Thanks to Andrew Morton for pointing this out.
>>>
>>> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
>>> ---
>>>  mm/vmscan.c |   84 ++++++++++++++++++++------------------------------
>>>  1 file changed, 35 insertions(+), 49 deletions(-)
>>>
>>> --- linux.orig/mm/vmscan.c
>>> +++ linux/mm/vmscan.c
>>> @@ -1225,6 +1225,36 @@ static inline void note_zone_scanning_pr
>>>   * But we had to alter page->flags anyway.
>>>   */
>>>  
>>> +void move_active_pages_to_lru(enum lru_list lru, struct list_head *list)
>>> +{
>>> +	unsigned long pgmoved = 0;
>>> +
>>> +	while (!list_empty(&list)) {
>>> +		page = lru_to_page(&list);
>>> +		prefetchw_prev_lru_page(page, &list, flags);
>>> +
>>> +		VM_BUG_ON(PageLRU(page));
>>> +		SetPageLRU(page);
>>> +
>>> +		VM_BUG_ON(!PageActive(page));
>>> +		if (lru < LRU_ACTIVE)
>>> +			ClearPageActive(page);
>> Arithmetic on the LRU list is not good code for redability, I think. 
>> How about adding comment? 
>>
>> if (lru < LRU_ACTIVE) /* In case of moving from active list to inactive */
>>
>> Ignore me if you think this is trivial. 
> 
> Good suggestion. Or this simple one: "we are de-activating"?

lru < LRU_ACTIVE will never be true for file pages,
either active or inactive.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
