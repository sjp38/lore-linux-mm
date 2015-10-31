Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id A366B82F64
	for <linux-mm@kvack.org>; Sat, 31 Oct 2015 13:59:56 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so108916504pac.3
        for <linux-mm@kvack.org>; Sat, 31 Oct 2015 10:59:56 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id sy8si20428804pac.67.2015.10.31.10.59.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 31 Oct 2015 10:59:55 -0700 (PDT)
Subject: Re: [PATCH] mm/hugetlbfs Fix bugs in fallocate hole punch of areas
 with holes
References: <007901d1139a$030b0440$09210cc0$@alibaba-inc.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <56350014.2040800@oracle.com>
Date: Sat, 31 Oct 2015 10:53:24 -0700
MIME-Version: 1.0
In-Reply-To: <007901d1139a$030b0440$09210cc0$@alibaba-inc.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>

On 10/30/2015 10:07 PM, Hillf Danton wrote:
>>
>> Hugh Dickins pointed out problems with the new hugetlbfs fallocate
>> hole punch code.  These problems are in the routine remove_inode_hugepages
>> and mostly occur in the case where there are holes in the range of
>> pages to be removed.  These holes could be the result of a previous hole
>> punch or simply sparse allocation.
>>
>> remove_inode_hugepages handles both hole punch and truncate operations.
>> Page index handling was fixed/cleaned up so that holes are properly
>> handled.  In addition, code was changed to ensure multiple passes of the
>> address range only happens in the truncate case.  More comments were added
>> to explain the different actions in each case.  A cond_resched() was added
>> after removing up to PAGEVEC_SIZE pages.
>>
>> Some totally unnecessary code in hugetlbfs_fallocate() that remained from
>> early development was also removed.
>>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>> ---
>>  fs/hugetlbfs/inode.c | 44 +++++++++++++++++++++++++++++---------------
>>  1 file changed, 29 insertions(+), 15 deletions(-)
>>
>> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>> index 316adb9..30cf534 100644
>> --- a/fs/hugetlbfs/inode.c
>> +++ b/fs/hugetlbfs/inode.c
>> @@ -368,10 +368,25 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
>>  			lookup_nr = end - next;
>>
>>  		/*
>> -		 * This pagevec_lookup() may return pages past 'end',
>> -		 * so we must check for page->index > end.
>> +		 * When no more pages are found, take different action for
>> +		 * hole punch and truncate.
>> +		 *
>> +		 * For hole punch, this indicates we have removed each page
>> +		 * within the range and are done.  Note that pages may have
>> +		 * been faulted in after being removed in the hole punch case.
>> +		 * This is OK as long as each page in the range was removed
>> +		 * once.
>> +		 *
>> +		 * For truncate, we need to make sure all pages within the
>> +		 * range are removed when exiting this routine.  We could
>> +		 * have raced with a fault that brought in a page after it
>> +		 * was first removed.  Check the range again until no pages
>> +		 * are found.
>>  		 */
>>  		if (!pagevec_lookup(&pvec, mapping, next, lookup_nr)) {
>> +			if (!truncate_op)
>> +				break;
>> +
>>  			if (next == start)
>>  				break;
>>  			next = start;
>> @@ -382,19 +397,23 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
>>  			struct page *page = pvec.pages[i];
>>  			u32 hash;
>>
>> +			/*
>> +			 * The page (index) could be beyond end.  This is
>> +			 * only possible in the punch hole case as end is
>> +			 * LLONG_MAX for truncate.
>> +			 */
>> +			if (page->index >= end) {
>> +				next = end;	/* we are done */
>> +				break;
>> +			}
>> +			next = page->index;
>> +
>>  			hash = hugetlb_fault_mutex_hash(h, current->mm,
>>  							&pseudo_vma,
>>  							mapping, next, 0);
>>  			mutex_lock(&hugetlb_fault_mutex_table[hash]);
>>
>>  			lock_page(page);
>> -			if (page->index >= end) {
>> -				unlock_page(page);
>> -				mutex_unlock(&hugetlb_fault_mutex_table[hash]);
>> -				next = end;	/* we are done */
>> -				break;
>> -			}
>> -
>>  			/*
>>  			 * If page is mapped, it was faulted in after being
>>  			 * unmapped.  Do nothing in this race case.  In the
>> @@ -423,15 +442,13 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
>>  				}
>>  			}
>>
>> -			if (page->index > next)
>> -				next = page->index;
>> -
>>  			++next;
>>  			unlock_page(page);
>>
>>  			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
>>  		}
>>  		huge_pagevec_release(&pvec);
>> +		cond_resched();
>>  	}
>>
>>  	if (truncate_op)
>> @@ -647,9 +664,6 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
> 
> This hunk is already in the next tree, see below please.
> 

Ah, the whole series to add shmem like code to handle hole punch/fault
races is in the next tree.  It has been determined that most of this
series is not necessary.  For the next tree, ideally the following
should happen:
- revert the series
	0830d5afd4ab69d01cf5ceba9b9f2796564c4eb6
	4e0a78fea078af972276c2d3aeaceb2bac80e033
	251c8a023a0c639725e014a612e8c05a631ce839
	03bcef375766af4db12ec783241ac39f8bf5e2b1
- Add this patch (if Ack'ed/reviewed) to fix remove_inode_hugepages
- Add a new patch for the handle hole punch/fault race.  It modifies
  same code as this patch, so I have not sent out until this is Ack'ed.

I will admit that I do not fully understand how maintainers manage their
trees and share patches.  If someone can make suggestions on how to handle
this situation (create patches against what tree? send patches to who?),
I will be happy to make it happen.

-- 
Mike Kravetz

>>  	if (!(mode & FALLOC_FL_KEEP_SIZE) && offset + len > inode->i_size)
>>  		i_size_write(inode, offset + len);
>>  	inode->i_ctime = CURRENT_TIME;
>> -	spin_lock(&inode->i_lock);
>> -	inode->i_private = NULL;
>> -	spin_unlock(&inode->i_lock);
>>  out:
>>  	mutex_unlock(&inode->i_mutex);
>>  	return error;
>> --
>> 2.4.3
>>
> In the next tree,
> 	4e0a78fea078af972276c2d3aeaceb2bac80e033
> 	mm/hugetlb: setup hugetlb_falloc during fallocate hole punch
> 
> @@ -647,9 +676,6 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
>  	if (!(mode & FALLOC_FL_KEEP_SIZE) && offset + len > inode->i_size)
>  		i_size_write(inode, offset + len);
>  	inode->i_ctime = CURRENT_TIME;
> -	spin_lock(&inode->i_lock);
> -	inode->i_private = NULL;
> -	spin_unlock(&inode->i_lock);
>  out:
>  	mutex_unlock(&inode->i_mutex);
>  	return error;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
