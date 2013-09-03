Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id AC4B16B0034
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 04:49:15 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Tue, 3 Sep 2013 14:12:26 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id C61D13940058
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 14:18:59 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r838ow3n36831280
	for <linux-mm@kvack.org>; Tue, 3 Sep 2013 14:20:58 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r838n9Qw026153
	for <linux-mm@kvack.org>; Tue, 3 Sep 2013 14:19:10 +0530
Message-ID: <5225A1A1.5010204@linux.vnet.ibm.com>
Date: Tue, 03 Sep 2013 14:15:21 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 09/35] mm: Track the freepage migratetype of pages
 accurately
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com> <20130830131635.4947.81565.stgit@srivatsabhat.in.ibm.com> <522583DE.709@jp.fujitsu.com>
In-Reply-To: <522583DE.709@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/03/2013 12:08 PM, Yasuaki Ishimatsu wrote:
> (2013/08/30 22:16), Srivatsa S. Bhat wrote:
>> Due to the region-wise ordering of the pages in the buddy allocator's
>> free lists, whenever we want to delete a free pageblock from a free list
>> (for ex: when moving blocks of pages from one list to the other), we need
>> to be able to tell the buddy allocator exactly which migratetype it
>> belongs
>> to. For that purpose, we can use the page's freepage migratetype
>> (which is
>> maintained in the page's ->index field).
>>
>> So, while splitting up higher order pages into smaller ones as part of
>> buddy
>> operations, keep the new head pages updated with the correct freepage
>> migratetype information (because we depend on tracking this info
>> accurately,
>> as outlined above).
>>
>> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
>> ---
>>
>>   mm/page_alloc.c |    7 +++++++
>>   1 file changed, 7 insertions(+)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 398b62c..b4b1275 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -947,6 +947,13 @@ static inline void expand(struct zone *zone,
>> struct page *page,
>>           add_to_freelist(&page[size], &area->free_list[migratetype]);
>>           area->nr_free++;
>>           set_page_order(&page[size], high);
>> +
>> +        /*
>> +         * Freepage migratetype is tracked using the index field of the
>> +         * first page of the block. So we need to update the new first
>> +         * page, when changing the page order.
>> +         */
>> +        set_freepage_migratetype(&page[size], migratetype);
>>       }
>>   }
>>
>>
> 
> It this patch a bug fix patch?
> If so, I want you to split the patch from the patch-set.
> 

No, its not a bug-fix. We need to take care of this only when using the
sorted-buddy design to maintain the freelists, which is introduced only in
this patchset. So mainline doesn't need this patch.

In mainline, we can delete a page from a buddy freelist by simply calling
list_del() by passing a pointer to page->lru. It doesn't matter which freelist
the page was belonging to. However, in the sorted-buddy design introduced
in this patchset, we also need to know which particular freelist we are
deleting that page from, because apart from breaking the ->lru link from
the linked-list, we also need to update certain other things such as the
region->page_block pointer etc, which are part of that particular freelist.
Thus, it becomes essential to know which freelist we are deleting the page
from. And for that, we need this patch to maintain that information accurately
even during buddy operations such as splitting buddy pages in expand().

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
