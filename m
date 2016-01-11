Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7586C680F7F
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 18:49:29 -0500 (EST)
Received: by mail-io0-f175.google.com with SMTP id 77so335102634ioc.2
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 15:49:29 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ck10si28337990igb.65.2016.01.11.15.49.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 15:49:28 -0800 (PST)
Subject: Re: [PATCH] mm/hugetlbfs: Unmap pages if page fault raced with hole
 punch
References: <1452119824-32715-1-git-send-email-mike.kravetz@oracle.com>
 <20160111143548.f6dc084529530b05b03b8f0c@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <56943D00.7090405@oracle.com>
Date: Mon, 11 Jan 2016 15:38:40 -0800
MIME-Version: 1.0
In-Reply-To: <20160111143548.f6dc084529530b05b03b8f0c@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Davidlohr Bueso <dave@stgolabs.net>, Dave Hansen <dave.hansen@linux.intel.com>

On 01/11/2016 02:35 PM, Andrew Morton wrote:
> On Wed,  6 Jan 2016 14:37:04 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
>> Page faults can race with fallocate hole punch.  If a page fault happens
>> between the unmap and remove operations, the page is not removed and
>> remains within the hole.  This is not the desired behavior.  The race
>> is difficult to detect in user level code as even in the non-race
>> case, a page within the hole could be faulted back in before fallocate
>> returns.  If userfaultfd is expanded to support hugetlbfs in the future,
>> this race will be easier to observe.
>>
>> If this race is detected and a page is mapped, the remove operation
>> (remove_inode_hugepages) will unmap the page before removing.  The unmap
>> within remove_inode_hugepages occurs with the hugetlb_fault_mutex held
>> so that no other faults will be processed until the page is removed.
>>
>> The (unmodified) routine hugetlb_vmdelete_list was moved ahead of
>> remove_inode_hugepages to satisfy the new reference.
>>
>> ...
>>
>> --- a/fs/hugetlbfs/inode.c
>> +++ b/fs/hugetlbfs/inode.c
>>
>> ...
>>
>> @@ -395,37 +431,43 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
>>  							mapping, next, 0);
>>  			mutex_lock(&hugetlb_fault_mutex_table[hash]);
>>  
>> -			lock_page(page);
>> -			if (likely(!page_mapped(page))) {
> 
> hm, what are the locking requirements for page_mapped()?

page_mapped is just reading/evaluating an atomic within the struct page
which we have a referene on from the pagevec_lookup.  But, I think the
question is what prevents page_mapped from changing after we check it?

The patch takes the hugetlb_fault_mutex_table lock before checking
page_mapped.  If the page is unmapped and the hugetlb_fault_mutex_table
is held, it can not be faulted in and change from unmapped to mapped.

The new comment in the patch about taking hugetlb_fault_mutex_table is
right before the check for page_mapped.

> 
>> -				bool rsv_on_error = !PagePrivate(page);
>> -				/*
>> -				 * We must free the huge page and remove
>> -				 * from page cache (remove_huge_page) BEFORE
>> -				 * removing the region/reserve map
>> -				 * (hugetlb_unreserve_pages).  In rare out
>> -				 * of memory conditions, removal of the
>> -				 * region/reserve map could fail.  Before
>> -				 * free'ing the page, note PagePrivate which
>> -				 * is used in case of error.
>> -				 */
>> -				remove_huge_page(page);
> 
> And remove_huge_page().

The page must be locked before calling remove_huge_page, since it will
call delete_from_page_cache.  It currently is locked.  Would you prefer
a comment stating this before the call?

-- 
Mike Kravetz

> 
>> -				freed++;
>> -				if (!truncate_op) {
>> -					if (unlikely(hugetlb_unreserve_pages(
>> -							inode, next,
>> -							next + 1, 1)))
>> -						hugetlb_fix_reserve_counts(
>> -							inode, rsv_on_error);
>> -				}
>>
>> ...
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
