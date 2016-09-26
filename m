Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 941E2280273
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 16:16:35 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id n4so106987186lfb.3
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 13:16:35 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id y3si9350383wjm.10.2016.09.26.13.16.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 13:16:34 -0700 (PDT)
Subject: Re: [PATCH] mm: remove unnecessary condition in
 remove_inode_hugepages
References: <1474857253-35702-1-git-send-email-zhongjiang@huawei.com>
 <20160926090121.GC28550@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <9d43eafa-a3c2-01c8-53c7-6654ad0114e9@oracle.com>
Date: Mon, 26 Sep 2016 13:16:02 -0700
MIME-Version: 1.0
In-Reply-To: <20160926090121.GC28550@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, zhongjiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org

On 09/26/2016 02:01 AM, Michal Hocko wrote:
> On Mon 26-09-16 10:34:13, zhongjiang wrote:
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
>>  fs/hugetlbfs/inode.c    | 10 ++++------
>>  include/linux/hugetlb.h |  2 +-
>>  mm/hugetlb.c            |  4 ++--
>>  3 files changed, 7 insertions(+), 9 deletions(-)
>>
>> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>> index 4ea71eb..81f8bbf4 100644
>> --- a/fs/hugetlbfs/inode.c
>> +++ b/fs/hugetlbfs/inode.c
>> @@ -458,18 +458,16 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
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
> 
> This whole code is tricky as hell. I would be calmer if we just stick a
> VM_BUG_ON here to make sure that this assumption will not break later
> on.

I'm OK with adding the VM_BUG_ON.

This has run through the fallocate stress testing without issue.  In
addition, I ran it through the (in development) userfaultfd huge page
tests that use fallocate hole punch on a privately mapped hugetlbfs
file.

The original check for PagePrivate was likely added due to observations
about the way the flag is used in dequeue_huge_page_vma/free_huge_page.
Unfortunately, I did not recognize that they did not apply in this case.

-- 
Mike Kravetz

> 
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
>> -- 
>> 1.8.3.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
