Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 344506B0031
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 01:28:18 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 6 Sep 2013 10:48:08 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 74EA91258052
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 10:58:02 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r865S00m48365748
	for <linux-mm@kvack.org>; Fri, 6 Sep 2013 10:58:02 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r865S00r002030
	for <linux-mm@kvack.org>; Fri, 6 Sep 2013 10:58:01 +0530
Message-ID: <522966FA.7030507@linux.vnet.ibm.com>
Date: Fri, 06 Sep 2013 10:54:10 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 09/35] mm: Track the freepage migratetype of pages
 accurately
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com> <20130830131635.4947.81565.stgit@srivatsabhat.in.ibm.com> <522583DE.709@jp.fujitsu.com> <5225A1A1.5010204@linux.vnet.ibm.com> <5226EE0F.5010906@jp.fujitsu.com>
In-Reply-To: <5226EE0F.5010906@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/04/2013 01:53 PM, Yasuaki Ishimatsu wrote:
> (2013/09/03 17:45), Srivatsa S. Bhat wrote:
>> On 09/03/2013 12:08 PM, Yasuaki Ishimatsu wrote:
>>> (2013/08/30 22:16), Srivatsa S. Bhat wrote:
>>>> Due to the region-wise ordering of the pages in the buddy allocator's
>>>> free lists, whenever we want to delete a free pageblock from a free
>>>> list
>>>> (for ex: when moving blocks of pages from one list to the other), we
>>>> need
>>>> to be able to tell the buddy allocator exactly which migratetype it
>>>> belongs
>>>> to. For that purpose, we can use the page's freepage migratetype
>>>> (which is
>>>> maintained in the page's ->index field).
>>>>
>>>> So, while splitting up higher order pages into smaller ones as part of
>>>> buddy
>>>> operations, keep the new head pages updated with the correct freepage
>>>> migratetype information (because we depend on tracking this info
>>>> accurately,
>>>> as outlined above).
>>>>
>>>> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
>>>> ---
>>>>
>>>>    mm/page_alloc.c |    7 +++++++
>>>>    1 file changed, 7 insertions(+)
>>>>
>>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>>> index 398b62c..b4b1275 100644
>>>> --- a/mm/page_alloc.c
>>>> +++ b/mm/page_alloc.c
>>>> @@ -947,6 +947,13 @@ static inline void expand(struct zone *zone,
>>>> struct page *page,
>>>>            add_to_freelist(&page[size], &area->free_list[migratetype]);
>>>>            area->nr_free++;
>>>>            set_page_order(&page[size], high);
>>>> +
>>>> +        /*
>>>> +         * Freepage migratetype is tracked using the index field of
>>>> the
>>>> +         * first page of the block. So we need to update the new first
>>>> +         * page, when changing the page order.
>>>> +         */
>>>> +        set_freepage_migratetype(&page[size], migratetype);
>>>>        }
>>>>    }
>>>>
>>>>
>>>
>>> It this patch a bug fix patch?
>>> If so, I want you to split the patch from the patch-set.
>>>
>>
>> No, its not a bug-fix. We need to take care of this only when using the
>> sorted-buddy design to maintain the freelists, which is introduced
>> only in
>> this patchset. So mainline doesn't need this patch.
>>
>> In mainline, we can delete a page from a buddy freelist by simply calling
>> list_del() by passing a pointer to page->lru. It doesn't matter which
>> freelist
>> the page was belonging to. However, in the sorted-buddy design introduced
>> in this patchset, we also need to know which particular freelist we are
>> deleting that page from, because apart from breaking the ->lru link from
>> the linked-list, we also need to update certain other things such as the
>> region->page_block pointer etc, which are part of that particular
>> freelist.
>> Thus, it becomes essential to know which freelist we are deleting the
>> page
>> from. And for that, we need this patch to maintain that information
>> accurately
>> even during buddy operations such as splitting buddy pages in expand().
> 
> I may be wrong because I do not know this part clearly.
> 
> Original code is here:
> 
> ---
> static inline void expand(struct zone *zone, struct page *page,
>     int low, int high, struct free_area *area,
>     int migratetype)
> {
> ...
>         list_add(&page[size].lru, &area->free_list[migratetype]);
>         area->nr_free++;
>         set_page_order(&page[size], high);
> ---
> 
> It seems that migratietype of page[size] page is changed. So even if not
> applying your patch, I think migratetype of the page should be changed.
> 

Hmm, thinking about this a bit more, I agree with you. Although its not a
bug-fix for mainline, it is certainly good to have, since it makes things
more consistent by tracking the freepage migratetype properly for pages
split during buddy expansion. I'll separate this patch from the series and
post it as a stand-alone patch. Thank you!

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
