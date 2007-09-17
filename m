Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8HJaZ4B014671
	for <linux-mm@kvack.org>; Tue, 18 Sep 2007 05:36:35 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8HJaZQH3670086
	for <linux-mm@kvack.org>; Tue, 18 Sep 2007 05:36:35 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8HJaIe8026896
	for <linux-mm@kvack.org>; Tue, 18 Sep 2007 05:36:18 +1000
Message-ID: <46EED726.6030807@linux.vnet.ibm.com>
Date: Tue, 18 Sep 2007 01:06:06 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 5/14] Reclaim Scalability:  Use an indexed array for
 LRU variables
References: <20070914205359.6536.98017.sendpatchset@localhost> <20070914205431.6536.43754.sendpatchset@localhost> <46EECE5C.3070801@linux.vnet.ibm.com> <1190056353.5460.112.camel@localhost>
In-Reply-To: <1190056353.5460.112.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn wrote:
> On Tue, 2007-09-18 at 00:28 +0530, Balbir Singh wrote:
>> Lee Schermerhorn wrote:
>>> [PATCH/RFC] 05/15  Reclaim Scalability:   Use an indexed array for LRU variables
>>>
>>> From clameter@sgi.com Wed Aug 29 11:39:51 2007
>>>
>>> Currently we are defining explicit variables for the inactive
>>> and active list. An indexed array can be more generic and avoid
>>> repeating similar code in several places in the reclaim code.
>>>
>>> We are saving a few bytes in terms of code size:
>>>
>>> Before:
>>>
>>>    text    data     bss     dec     hex filename
>>> 4097753  573120 4092484 8763357  85b7dd vmlinux
>>>
>>> After:
>>>
>>>    text    data     bss     dec     hex filename
>>> 4097729  573120 4092484 8763333  85b7c5 vmlinux
>>>
>>> Having an easy way to add new lru lists may ease future work on
>>> the reclaim code.
>>>
>>> [CL's signoff added by lts based on mail from CL]
>>> Signed-off-by:  Christoph Lameter <clameter@sgi.com>
>>>
>>>  include/linux/mm_inline.h |   33 ++++++++---
>>>  include/linux/mmzone.h    |   17 +++--
>>>  mm/page_alloc.c           |    9 +--
>>>  mm/swap.c                 |    2 
>>>  mm/vmscan.c               |  132 ++++++++++++++++++++++------------------------
>>>  mm/vmstat.c               |    3 -
>>>  6 files changed, 107 insertions(+), 89 deletions(-)
>>>
>>> Index: Linux/include/linux/mmzone.h
>>> ===================================================================
>>> --- Linux.orig/include/linux/mmzone.h	2007-09-10 12:21:31.000000000 -0400
>>> +++ Linux/include/linux/mmzone.h	2007-09-10 12:22:33.000000000 -0400
>>> @@ -81,8 +81,8 @@ struct zone_padding {
>>>  enum zone_stat_item {
>>>  	/* First 128 byte cacheline (assuming 64 bit words) */
>>>  	NR_FREE_PAGES,
>>> -	NR_INACTIVE,
>>> -	NR_ACTIVE,
>>> +	NR_INACTIVE,	/* must match order of LRU_[IN]ACTIVE */
>>> +	NR_ACTIVE,	/*  "     "     "   "       "         */
>>>  	NR_ANON_PAGES,	/* Mapped anonymous pages */
>>>  	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
>>>  			   only modified from process context */
>>> @@ -106,6 +106,13 @@ enum zone_stat_item {
>>>  #endif
>>>  	NR_VM_ZONE_STAT_ITEMS };
>>>
>>> +enum lru_list {
>>> +	LRU_INACTIVE,	/* must match order of NR_[IN]ACTIVE */
>>> +	LRU_ACTIVE,	/*  "     "     "   "       "        */
>>> +	NR_LRU_LISTS };
>>> +
>>> +#define for_each_lru(l) for (l = 0; l < NR_LRU_LISTS; l++)
>>> +
>>>  struct per_cpu_pages {
>>>  	int count;		/* number of pages in the list */
>>>  	int high;		/* high watermark, emptying needed */
>>> @@ -259,10 +266,8 @@ struct zone {
>>>
>>>  	/* Fields commonly accessed by the page reclaim scanner */
>>>  	spinlock_t		lru_lock;	
>>> -	struct list_head	active_list;
>>> -	struct list_head	inactive_list;
>>> -	unsigned long		nr_scan_active;
>>> -	unsigned long		nr_scan_inactive;
>>> +	struct list_head	list[NR_LRU_LISTS];
>>> +	unsigned long		nr_scan[NR_LRU_LISTS];
>> I wonder if it makes sense to have an array of the form
>>
>> struct reclaim_lists {
>> 	struct list_head list[NR_LRU_LISTS];
>> 	unsigned long nr_scan[NR_LRU_LISTS];
>> 	reclaim_function_t list_reclaim_function[NR_LRU_LISTS];
>> }
>>
>> where reclaim_function is an array of reclaim functions for each list
>> (in our case shrink_active_list/shrink_inactive_list).
> 
> Are you thinking that memory controller would use the reclaim functions
> switch--e.g., because of it's private lru lists?  And what sort of
> reclaim functions do you have in mind?   Would it add additional
> indirection in the fault path where we add pages to the LRU and move
> them between LRU lists in the case of page activiation?  That could be a
> concern.  In any case, maybe should be named something like 'lru_lists'
> and 'lru_list_functions'?
> 

Well we already have our own isolate function and we re-use
shrink_(in)active_list() functions. The idea behind associating
a function was that shrink_list() would look cleaner. In addition,
the reclaim function for locked page lists would be NULL. I prefer
lru_list_functions.

>>
>>>  static inline void
>>>  del_page_from_lru(struct zone *zone, struct page *page)
>>>  {
>>> +	enum lru_list l = LRU_INACTIVE;
>>> +
>>>  	list_del(&page->lru);
>>>  	if (PageActive(page)) {
>>>  		__ClearPageActive(page);
>>>  		__dec_zone_state(zone, NR_ACTIVE);
>>> -	} else {
>>> -		__dec_zone_state(zone, NR_INACTIVE);
>>> +		l = LRU_ACTIVE;
>>>  	}
>>> +	__dec_zone_state(zone, NR_INACTIVE + l);
>> This is unconditional, does not seem right.
> 
> It's not the unconditional one that wrong.  As Mel pointed out earlier,
> I forgot to remove the explicit decrement of NR_ACTIVE.  Turns out that
> I unknowingly fixed this in the subsequent noreclaim infrastructure
> patch, but I need to fix it in this patch so that it stands alone.  Next
> respin.
> 

Yes, my bad. It's the NR_ACTIVE that is.

> Lee
> 


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
