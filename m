Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 712A028024C
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 19:55:30 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id s64so48105073lfs.1
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 16:55:30 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id s192si5141760lfe.215.2016.09.28.16.55.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 16:55:28 -0700 (PDT)
Subject: Re: [PATCH v2] mm: remove unnecessary condition in
 remove_inode_hugepages
References: <1474985786-5052-1-git-send-email-zhongjiang@huawei.com>
 <63e015fd-3920-9753-fb58-c11d95d61d8b@oracle.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <dc693ecb-5353-a274-9ce3-9a1c5aa59aa2@oracle.com>
Date: Wed, 28 Sep 2016 16:55:11 -0700
MIME-Version: 1.0
In-Reply-To: <63e015fd-3920-9753-fb58-c11d95d61d8b@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>, mhocko@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com

On 09/27/2016 12:23 PM, Mike Kravetz wrote:
> On 09/27/2016 07:16 AM, zhongjiang wrote:
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> when the huge page is added to the page cahce (huge_add_to_page_cache),
>> the page private flag will be cleared. since this code
>> (remove_inode_hugepages) will only be called for pages in the
>> page cahce, PagePrivate(page) will always be false.
>>
>> The patch remove the code without any functional change.
>>
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>> ---
>>  fs/hugetlbfs/inode.c    | 11 +++++------
>>  include/linux/hugetlb.h |  2 +-
>>  mm/hugetlb.c            |  4 ++--
>>  3 files changed, 8 insertions(+), 9 deletions(-)
>>
>> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>> index 4ea71eb..40d0afe 100644
>> --- a/fs/hugetlbfs/inode.c
>> +++ b/fs/hugetlbfs/inode.c
>> @@ -458,18 +458,17 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
>>  			 * cache (remove_huge_page) BEFORE removing the
>>  			 * region/reserve map (hugetlb_unreserve_pages).  In
>>  			 * rare out of memory conditions, removal of the
>> -			 * region/reserve map could fail.  Before free'ing
>> -			 * the page, note PagePrivate which is used in case
>> -			 * of error.
>> +			 * region/reserve map could fail. Correspondingly,
>> +			 * the subpool and global reserve usage count can need
>> +			 * to be adjusted.
>>  			 */
>> -			rsv_on_error = !PagePrivate(page);

You also need to remove the definition of rsv_on_error.

Sorry, I missed that on the review.
-- 
Mike Kravetz

>> +			VM_BUG_ON(PagePrivate(page));
>>  			remove_huge_page(page);
>>  			freed++;
>>  			if (!truncate_op) {
>>  				if (unlikely(hugetlb_unreserve_pages(inode,
>>  							next, next + 1, 1)))
>> -					hugetlb_fix_reserve_counts(inode,
>> -								rsv_on_error);
>> +					hugetlb_fix_reserve_counts(inode);
>>  			}
>>  
>>  			unlock_page(page);
>> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
>> index c26d463..d2e0fc5 100644
>> --- a/include/linux/hugetlb.h
>> +++ b/include/linux/hugetlb.h
>> @@ -90,7 +90,7 @@ int dequeue_hwpoisoned_huge_page(struct page *page);
>>  bool isolate_huge_page(struct page *page, struct list_head *list);
>>  void putback_active_hugepage(struct page *page);
>>  void free_huge_page(struct page *page);
>> -void hugetlb_fix_reserve_counts(struct inode *inode, bool restore_reserve);
>> +void hugetlb_fix_reserve_counts(struct inode *inode);
>>  extern struct mutex *hugetlb_fault_mutex_table;
>>  u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
>>  				struct vm_area_struct *vma,
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 87e11d8..28a079a 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -567,13 +567,13 @@ retry:
>>   * appear as a "reserved" entry instead of simply dangling with incorrect
>>   * counts.
>>   */
>> -void hugetlb_fix_reserve_counts(struct inode *inode, bool restore_reserve)
>> +void hugetlb_fix_reserve_counts(struct inode *inode)
>>  {
>>  	struct hugepage_subpool *spool = subpool_inode(inode);
>>  	long rsv_adjust;
>>  
>>  	rsv_adjust = hugepage_subpool_get_pages(spool, 1);
>> -	if (restore_reserve && rsv_adjust) {
>> +	if (rsv_adjust) {
>>  		struct hstate *h = hstate_inode(inode);
>>  
>>  		hugetlb_acct_memory(h, 1);
>>
> 
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
> Tested-by: Mike Kravetz <mike.kravetz@oracle.com>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
