Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 79DE26B0270
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 10:29:44 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id c79so27310575ybf.2
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 07:29:44 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id q84si820938ywc.190.2016.09.27.07.21.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 07:21:44 -0700 (PDT)
Message-ID: <57EA7FFE.60401@huawei.com>
Date: Tue, 27 Sep 2016 22:19:42 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: remove unnecessary condition in remove_inode_hugepages
References: <1474857253-35702-1-git-send-email-zhongjiang@huawei.com> <20160926090121.GC28550@dhcp22.suse.cz> <9d43eafa-a3c2-01c8-53c7-6654ad0114e9@oracle.com>
In-Reply-To: <9d43eafa-a3c2-01c8-53c7-6654ad0114e9@oracle.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org

On 2016/9/27 4:16, Mike Kravetz wrote:
> On 09/26/2016 02:01 AM, Michal Hocko wrote:
>> On Mon 26-09-16 10:34:13, zhongjiang wrote:
>>> From: zhong jiang <zhongjiang@huawei.com>
>>>
>>> when the huge page is added to the page cahce (huge_add_to_page_cache),
>>> the page private flag will be cleared. since this code
>>> (remove_inode_hugepages) will only be called for pages in the
>>> page cahce, PagePrivate(page) will always be false.
>>>
>>> The patch remove the code without any functional change.
>>>
>>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>>> ---
>>>  fs/hugetlbfs/inode.c    | 10 ++++------
>>>  include/linux/hugetlb.h |  2 +-
>>>  mm/hugetlb.c            |  4 ++--
>>>  3 files changed, 7 insertions(+), 9 deletions(-)
>>>
>>> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>>> index 4ea71eb..81f8bbf4 100644
>>> --- a/fs/hugetlbfs/inode.c
>>> +++ b/fs/hugetlbfs/inode.c
>>> @@ -458,18 +458,16 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
>>>  			 * cache (remove_huge_page) BEFORE removing the
>>>  			 * region/reserve map (hugetlb_unreserve_pages).  In
>>>  			 * rare out of memory conditions, removal of the
>>> -			 * region/reserve map could fail.  Before free'ing
>>> -			 * the page, note PagePrivate which is used in case
>>> -			 * of error.
>>> +			 * region/reserve map could fail. Correspondingly,
>>> +			 * the subpool and global reserve usage count can need
>>> +			 * to be adjusted.
>>>  			 */
>>> -			rsv_on_error = !PagePrivate(page);
>> This whole code is tricky as hell. I would be calmer if we just stick a
>> VM_BUG_ON here to make sure that this assumption will not break later
>> on.
> I'm OK with adding the VM_BUG_ON.
>
> This has run through the fallocate stress testing without issue.  In
> addition, I ran it through the (in development) userfaultfd huge page
> tests that use fallocate hole punch on a privately mapped hugetlbfs
> file.
  Thank you for test and review.
> The original check for PagePrivate was likely added due to observations
> about the way the flag is used in dequeue_huge_page_vma/free_huge_page.
> Unfortunately, I did not recognize that they did not apply in this case.
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
