Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 700E16B026B
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 21:39:59 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id p102so94844583uap.2
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 18:39:59 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id d203si3543623vke.223.2016.09.28.18.39.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Sep 2016 18:39:58 -0700 (PDT)
Message-ID: <57EC6F06.6020703@huawei.com>
Date: Thu, 29 Sep 2016 09:31:50 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: remove unnecessary condition in remove_inode_hugepages
References: <1474985786-5052-1-git-send-email-zhongjiang@huawei.com> <63e015fd-3920-9753-fb58-c11d95d61d8b@oracle.com> <dc693ecb-5353-a274-9ce3-9a1c5aa59aa2@oracle.com>
In-Reply-To: <dc693ecb-5353-a274-9ce3-9a1c5aa59aa2@oracle.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com

On 2016/9/29 7:55, Mike Kravetz wrote:
> On 09/27/2016 12:23 PM, Mike Kravetz wrote:
>> On 09/27/2016 07:16 AM, zhongjiang wrote:
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
>>>  fs/hugetlbfs/inode.c    | 11 +++++------
>>>  include/linux/hugetlb.h |  2 +-
>>>  mm/hugetlb.c            |  4 ++--
>>>  3 files changed, 8 insertions(+), 9 deletions(-)
>>>
>>> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>>> index 4ea71eb..40d0afe 100644
>>> --- a/fs/hugetlbfs/inode.c
>>> +++ b/fs/hugetlbfs/inode.c
>>> @@ -458,18 +458,17 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
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
> You also need to remove the definition of rsv_on_error.
>
> Sorry, I missed that on the review.
  Thanks,  I will remove it now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
