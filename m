Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1FA266B00DF
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 12:14:53 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so1460357pab.27
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 09:14:52 -0700 (PDT)
Received: from psmtp.com ([74.125.245.139])
        by mx.google.com with SMTP id ud7si15868341pac.178.2013.10.23.09.14.51
        for <linux-mm@kvack.org>;
        Wed, 23 Oct 2013 09:14:52 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 23 Oct 2013 21:44:47 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 3B557E005D
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 21:45:44 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9NGH44329294682
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 21:47:04 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9NGEAKd015443
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 21:44:11 +0530
Message-ID: <5267F4CA.3070106@linux.vnet.ibm.com>
Date: Wed, 23 Oct 2013 21:39:46 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v4 06/40] mm: Demarcate and maintain pageblocks in
 region-order in the zones' freelists
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com> <20130925231454.26184.19783.stgit@srivatsabhat.in.ibm.com> <20131023101703.GC2043@cmpxchg.org>
In-Reply-To: <20131023101703.GC2043@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mark.gross@intel.com

On 10/23/2013 03:47 PM, Johannes Weiner wrote:
> On Thu, Sep 26, 2013 at 04:44:56AM +0530, Srivatsa S. Bhat wrote:
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -517,6 +517,111 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
>>  	return 0;
>>  }
>>  
>> +static void add_to_freelist(struct page *page, struct free_list *free_list)
>> +{
>> +	struct list_head *prev_region_list, *lru;
>> +	struct mem_region_list *region;
>> +	int region_id, i;
>> +
>> +	lru = &page->lru;
>> +	region_id = page_zone_region_id(page);
>> +
>> +	region = &free_list->mr_list[region_id];
>> +	region->nr_free++;
>> +
>> +	if (region->page_block) {
>> +		list_add_tail(lru, region->page_block);
>> +		return;
>> +	}
>> +
>> +#ifdef CONFIG_DEBUG_PAGEALLOC
>> +	WARN(region->nr_free != 1, "%s: nr_free is not unity\n", __func__);
>> +#endif
>> +
>> +	if (!list_empty(&free_list->list)) {
>> +		for (i = region_id - 1; i >= 0; i--) {
>> +			if (free_list->mr_list[i].page_block) {
>> +				prev_region_list =
>> +					free_list->mr_list[i].page_block;
>> +				goto out;
>> +			}
>> +		}
>> +	}
>> +
>> +	/* This is the first region, so add to the head of the list */
>> +	prev_region_list = &free_list->list;
>> +
>> +out:
>> +	list_add(lru, prev_region_list);
>> +
>> +	/* Save pointer to page block of this region */
>> +	region->page_block = lru;
> 
> "Pageblock" has a different meaning in the allocator already.
> 
> The things you string up here are just called pages, regardless of
> which order they are in and how many pages they can be split into.
> 

Ah, yes. I'll fix that.

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
