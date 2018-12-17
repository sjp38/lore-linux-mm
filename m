Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9B4108E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 13:42:32 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id 129so8179920ybc.2
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 10:42:32 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id b200si7717073ybg.421.2018.12.17.10.42.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 10:42:31 -0800 (PST)
Subject: Re: [PATCH 2/3] hugetlbfs: Use i_mmap_rwsem to fix page
 fault/truncate race
References: <20181203200850.6460-1-mike.kravetz@oracle.com>
 <20181203200850.6460-3-mike.kravetz@oracle.com>
 <27f8893b-57b3-088d-2d48-9e8acc5987bd@linux.ibm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <f6fd9491-4b3d-16ca-f606-025c78756936@oracle.com>
Date: Mon, 17 Dec 2018 10:42:17 -0800
MIME-Version: 1.0
In-Reply-To: <27f8893b-57b3-088d-2d48-9e8acc5987bd@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On 12/17/18 2:25 AM, Aneesh Kumar K.V wrote:
> On 12/4/18 1:38 AM, Mike Kravetz wrote:
>> hugetlbfs page faults can race with truncate and hole punch operations.
>> Current code in the page fault path attempts to handle this by 'backing
>> out' operations if we encounter the race.  One obvious omission in the
>> current code is removing a page newly added to the page cache.  This is
>> pretty straight forward to address, but there is a more subtle and
>> difficult issue of backing out hugetlb reservations.  To handle this
>> correctly, the 'reservation state' before page allocation needs to be
>> noted so that it can be properly backed out.  There are four distinct
>> possibilities for reservation state: shared/reserved, shared/no-resv,
>> private/reserved and private/no-resv.  Backing out a reservation may
>> require memory allocation which could fail so that needs to be taken
>> into account as well.
>>
>> Instead of writing the required complicated code for this rare
>> occurrence, just eliminate the race.  i_mmap_rwsem is now held in read
>> mode for the duration of page fault processing.  Hold i_mmap_rwsem
>> longer in truncation and hold punch code to cover the call to
>> remove_inode_hugepages.
>>
>> Cc: <stable@vger.kernel.org>
>> Fixes: ebed4bfc8da8 ("hugetlb: fix absurd HugePages_Rsvd")
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>> ---
>>   fs/hugetlbfs/inode.c | 4 ++--
>>   1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>> index 32920a10100e..3244147fc42b 100644
>> --- a/fs/hugetlbfs/inode.c
>> +++ b/fs/hugetlbfs/inode.c
>> @@ -505,8 +505,8 @@ static int hugetlb_vmtruncate(struct inode *inode, loff_t
>> offset)
>>       i_mmap_lock_write(mapping);
>>       if (!RB_EMPTY_ROOT(&mapping->i_mmap.rb_root))
>>           hugetlb_vmdelete_list(&mapping->i_mmap, pgoff, 0);
>> -    i_mmap_unlock_write(mapping);
>>       remove_inode_hugepages(inode, offset, LLONG_MAX);
>> +    i_mmap_unlock_write(mapping);
>>       return 0;
>>   }
> 
> 
> We used to do remove_inode_hugepages()
> 
>     mutex_lock(&hugetlb_fault_mutex_table[hash]);
>     i_mmap_lock_write(mapping);
>     hugetlb_vmdelete_list(&mapping->i_mmap,
>     i_mmap_unlock_write(mapping);
> 
> did we change the lock ordering with this patch?

Thanks for taking a look.

Yes, we did take locks in that order in the 'if (unlikely(page_mapped(page)))'
case within remove_inode_hugepages.  That ordering was important as the
fault_mutex prevented faults while unmapping the page in all potential
mappings.

With the change above, we will be holding i_mmap_rwsem in write mode while
calling remove_inode_hugepages.  The page fault code (modified in previous
patch) acquires i_mmap_rwsem in read mode.  Therefore, no page faults can
occur and, that 'if (unlikely(page_mapped(page)))' case within
remove_inode_hugepages will never happen.  The now dead code is removed in
the subsequent patch.

As you suggested in a comment to the subsequent patch, it would be better to
combine the patches and remove the dead code when it becomes dead.  I will
work on that.  Actually some of the code in patch 3 applies to patch 1 and
some applies to patch 2.  So, it will not be simply combining patch 2 and 3.

-- 
Mike Kravetz
