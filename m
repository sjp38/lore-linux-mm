Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6237728025E
	for <linux-mm@kvack.org>; Sat, 24 Sep 2016 20:06:34 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e20so122501920itc.3
        for <linux-mm@kvack.org>; Sat, 24 Sep 2016 17:06:34 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id a62si2256087ita.67.2016.09.24.17.06.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Sep 2016 17:06:33 -0700 (PDT)
Subject: Re: [RFC] remove unnecessary condition in remove_inode_hugepages
References: <57E48B30.2000303@huawei.com>
 <d1e61e42-b644-478d-6294-3f8099318a3b@oracle.com>
 <57E5EB74.5070003@huawei.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <70933398-2b73-9835-ab7c-c5b9e2483f31@oracle.com>
Date: Sat, 24 Sep 2016 17:06:13 -0700
MIME-Version: 1.0
In-Reply-To: <57E5EB74.5070003@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 09/23/2016 07:56 PM, zhong jiang wrote:
> On 2016/9/24 1:19, Mike Kravetz wrote:
>> On 09/22/2016 06:53 PM, zhong jiang wrote:
>>> At present, we need to call hugetlb_fix_reserve_count when hugetlb_unrserve_pages fails,
>>> and PagePrivate will decide hugetlb reserves counts.
>>>
>>> we obtain the page from page cache. and use page both lock_page and mutex_lock.
>>> alloc_huge_page add page to page chace always hold lock page, then bail out clearpageprivate
>>> before unlock page. 
>>>
>>> but I' m not sure  it is right  or I miss the points.
>> Let me try to explain the code you suggest is unnecessary.
>>
>> The PagePrivate flag is used in huge page allocation/deallocation to
>> indicate that the page was globally reserved.  For example, in
>> dequeue_huge_page_vma() there is this code:
>>
>>                         if (page) {
>>                                 if (avoid_reserve)
>>                                         break;
>>                                 if (!vma_has_reserves(vma, chg))
>>                                         break;
>>
>>                                 SetPagePrivate(page);
>>                                 h->resv_huge_pages--;
>>                                 break;
>>                         }
>>
>> and in free_huge_page():
>>
>>         restore_reserve = PagePrivate(page);
>>         ClearPagePrivate(page);
>> 	.
>> 	<snip>
>> 	.
>>         if (restore_reserve)
>>                 h->resv_huge_pages++;
>>
>> This helps maintains the global huge page reserve count.
>>
>> In addition to the global reserve count, there are per VMA reservation
>> structures.  Unfortunately, these structures have different meanings
>> depending on the context in which they are used.
>>
>> If there is a VMA reservation entry for a page, and the page has not
>> been instantiated in the VMA this indicates there is a huge page reserved
>> and the global resv_huge_pages count reflects that reservation.  Even
>> if a page was not reserved, a VMA reservation entry is added when a page
>> is instantiated in the VMA.
>>
>> With that background, let's look at the existing code/proposed changes.
>  Clearly. 
>>> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>>> index 4ea71eb..010723b 100644
>>> --- a/fs/hugetlbfs/inode.c
>>> +++ b/fs/hugetlbfs/inode.c
>>> @@ -462,14 +462,12 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
>>>                          * the page, note PagePrivate which is used in case
>>>                          * of error.
>>>                          */
>>> -                       rsv_on_error = !PagePrivate(page);
>> This rsv_on_error flag indicates that when the huge page was allocated,
>    yes
>> it was NOT counted against the global reserve count.  So, when
>> remove_huge_page eventually calls free_huge_page(), the global count
>> resv_huge_pages is not incremented.  So far, no problem.
>  but the page comes from the page cache.  if it is.  it should implement
>  ClearPageprivate(page) when lock page.   This condition always true.
> 
>   The key point is why it need still check the PagePrivate(page) when page from
>   page cache and hold lock.

You are correct.  My apologies for not seeing your point in the original
post.

When the huge page is added to the page cache (huge_add_to_page_cache),
the Page Private flag will be cleared.  Since this code
(remove_inode_hugepages) will only be called for pages in the page cache,
PagePrivate(page) will always be false.

The comments in this area should be changed along with the code.

-- 
Mike Kravetz

> 
>   Thanks you
>  zhongjiang
>>>                         remove_huge_page(page);
>>>                         freed++;
>>>                         if (!truncate_op) {
>>>                                 if (unlikely(hugetlb_unreserve_pages(inode,
>>>                                                         next, next + 1, 1)))
>> We now have this VERY unlikely situation that hugetlb_unreserve_pages fails.
>> This means that the VMA reservation entry for the page was not removed.
>> So, we are in a bit of a mess.  The page has already been removed, but the
>> VMA reservation entry can not.  This LOOKS like there is a reservation for
>> the page in the VMA reservation structure.  But, the global count
>> resv_huge_pages does not reflect this reservation.
>>
>> If we do nothing, when the VMA is eventually removed the VMA reservation
>> structure will be completely removed and the global count resv_huge_pages
>> will be decremented for each entry in the structure.  Since, there is a
>> VMA reservation entry without a corresponding global count, the global
>> count will be one less than it should (will eventually go to -1).
>>
>> To 'fix' this, hugetlb_fix_reserve_counts is called.  In this case, it will
>> increment the global count so that it is consistent with the entries in
>> the VMA reservation structure.
>>
>> This is all quite confusing and really unlikely to happen.  I tried to
>> explain in code comments:
>>
>> Before removing the page:
>>                         /*
>>                          * We must free the huge page and remove from page
>>                          * cache (remove_huge_page) BEFORE removing the
>>                          * region/reserve map (hugetlb_unreserve_pages).  In
>>                          * rare out of memory conditions, removal of the
>>                          * region/reserve map could fail.  Before free'ing
>>                          * the page, note PagePrivate which is used in case
>>                          * of error.
>>                          */
>>
>> And, the routine hugetlb_fix_reserve_counts:
>> /*
>>  * A rare out of memory error was encountered which prevented removal of
>>  * the reserve map region for a page.  The huge page itself was free'ed
>>  * and removed from the page cache.  This routine will adjust the subpool
>>  * usage count, and the global reserve count if needed.  By incrementing
>>  * these counts, the reserve map entry which could not be deleted will
>>  * appear as a "reserved" entry instead of simply dangling with incorrect
>>  * counts.
>>  */
>>
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
