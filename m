Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2C58128027B
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 10:08:04 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 20so36642226ioj.0
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 07:08:04 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id u185si3111637itc.12.2016.09.27.07.08.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 07:08:03 -0700 (PDT)
Message-ID: <57EA7BBE.3070900@huawei.com>
Date: Tue, 27 Sep 2016 22:01:34 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: remove unnecessary condition in remove_inode_hugepages
References: <1474857253-35702-1-git-send-email-zhongjiang@huawei.com> <20160926090121.GC28550@dhcp22.suse.cz>
In-Reply-To: <20160926090121.GC28550@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: mike.kravetz@oracle.com, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org

On 2016/9/26 17:01, Michal Hocko wrote:
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
> This whole code is tricky as hell. I would be calmer if we just stick a
> VM_BUG_ON here to make sure that this assumption will not break later
> on.
  Resonable,   I will do it in V2.  Thanks.
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


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
