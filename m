Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 26D6D82F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 12:50:48 -0400 (EDT)
Received: by obbwb3 with SMTP id wb3so49065538obb.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 09:50:48 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id cv7si4882855oec.80.2015.10.30.09.50.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 09:50:47 -0700 (PDT)
Subject: Re: [PATCH] mm/hugetlb: Unmap pages if page fault raced with hole
 punch
References: <1446158038-25815-1-git-send-email-mike.kravetz@oracle.com>
 <alpine.LSU.2.11.1510291937340.5781@eggly.anvils>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <56339EBA.4070508@oracle.com>
Date: Fri, 30 Oct 2015 09:45:46 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1510291937340.5781@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>

On 10/29/2015 08:32 PM, Hugh Dickins wrote:
> On Thu, 29 Oct 2015, Mike Kravetz wrote:
> 
>> This patch is a combination of:
>> [PATCH v2 4/4] mm/hugetlb: Unmap pages to remove if page fault raced
>> 	with hole punch  and,
>> [PATCH] mm/hugetlb: i_mmap_lock_write before unmapping in
>> 	remove_inode_hugepages
>> This patch can replace the entire series:
>> [PATCH v2 0/4] hugetlbfs fallocate hole punch race with page faults
>> 	and
>> [PATCH] mm/hugetlb: i_mmap_lock_write before unmapping in
>> 	remove_inode_hugepages
>> It is being provided in an effort to possibly make tree management easier.
>>
>> Page faults can race with fallocate hole punch.  If a page fault happens
>> between the unmap and remove operations, the page is not removed and
>> remains within the hole.  This is not the desired behavior.
>>
>> If this race is detected and a page is mapped, the remove operation
>> (remove_inode_hugepages) will unmap the page before removing.  The unmap
>> within remove_inode_hugepages occurs with the hugetlb_fault_mutex held
>> so that no other faults can occur until the page is removed.
>>
>> The (unmodified) routine hugetlb_vmdelete_list was moved ahead of
>> remove_inode_hugepages to satisfy the new reference.
>>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> 
> Sorry, I came here to give this a quick Ack, but find I cannot:
> you're adding to the remove_inode_hugepages() loop (heading towards
> 4.3 final), but its use of "next" looks wrong to me already.

You are correct, the (current) code is wrong.

The hugetlbfs fallocate code started with shmem as an example.  Some
of the complexities of that code are not needed in hugetlbfs.  However,
some remnants were left.

I'll create a patch to fix the existing code, then when that is acceptable
refactor this patch.

> 
> Doesn't "next" need to be assigned from page->index much earlier?
> If there's a hole in the file (which there very well might be, since
> you've just implemented holepunch!), doesn't it do the wrong thing?

Yes, I think it will.

> 
> And the loop itself is a bit weird, though that probably doesn't
> matter very much: I said before, seeing the "while (next < end)",
> that it's a straightforward scan from start to end, and sometimes
> it would work that way; but buried inside is "next = start; continue;"

Correct, that next = start should not be there.

Thanks
-- 
Mike Kravetz

> from a contrasting "pincer" loop (which goes back to squeeze every
> page out of the range, lest faults raced truncation or holepunch).
> I know the originals in truncate.c or shmem.c are quite tricky,
> but this being different again would take time to validate.
> 
> No cond_resched() either.
> 
> Hugh
> 
>> ---
>>  fs/hugetlbfs/inode.c | 125 ++++++++++++++++++++++++++-------------------------
>>  1 file changed, 65 insertions(+), 60 deletions(-)
>>
>> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>> index 316adb9..8b8e5e8 100644
>> --- a/fs/hugetlbfs/inode.c
>> +++ b/fs/hugetlbfs/inode.c
>> @@ -324,11 +324,44 @@ static void remove_huge_page(struct page *page)
>>  	delete_from_page_cache(page);
>>  }
>>  
>> +static inline void
>> +hugetlb_vmdelete_list(struct rb_root *root, pgoff_t start, pgoff_t end)
>> +{
>> +	struct vm_area_struct *vma;
>> +
>> +	/*
>> +	 * end == 0 indicates that the entire range after
>> +	 * start should be unmapped.
>> +	 */
>> +	vma_interval_tree_foreach(vma, root, start, end ? end : ULONG_MAX) {
>> +		unsigned long v_offset;
>> +
>> +		/*
>> +		 * Can the expression below overflow on 32-bit arches?
>> +		 * No, because the interval tree returns us only those vmas
>> +		 * which overlap the truncated area starting at pgoff,
>> +		 * and no vma on a 32-bit arch can span beyond the 4GB.
>> +		 */
>> +		if (vma->vm_pgoff < start)
>> +			v_offset = (start - vma->vm_pgoff) << PAGE_SHIFT;
>> +		else
>> +			v_offset = 0;
>> +
>> +		if (end) {
>> +			end = ((end - start) << PAGE_SHIFT) +
>> +			       vma->vm_start + v_offset;
>> +			if (end > vma->vm_end)
>> +				end = vma->vm_end;
>> +		} else
>> +			end = vma->vm_end;
>> +
>> +		unmap_hugepage_range(vma, vma->vm_start + v_offset, end, NULL);
>> +	}
>> +}
>>  
>>  /*
>>   * remove_inode_hugepages handles two distinct cases: truncation and hole
>>   * punch.  There are subtle differences in operation for each case.
>> -
>>   * truncation is indicated by end of range being LLONG_MAX
>>   *	In this case, we first scan the range and release found pages.
>>   *	After releasing pages, hugetlb_unreserve_pages cleans up region/reserv
>> @@ -381,12 +414,27 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
>>  		for (i = 0; i < pagevec_count(&pvec); ++i) {
>>  			struct page *page = pvec.pages[i];
>>  			u32 hash;
>> +			bool rsv_on_error;
>>  
>>  			hash = hugetlb_fault_mutex_hash(h, current->mm,
>>  							&pseudo_vma,
>>  							mapping, next, 0);
>>  			mutex_lock(&hugetlb_fault_mutex_table[hash]);
>>  
>> +			/*
>> +			 * If page is mapped, it was faulted in after being
>> +			 * unmapped in caller.  Unmap (again) now after taking
>> +			 * the fault mutex.  The mutex will prevent faults
>> +			 * until we finish removing the page.
>> +			 */
>> +			if (page_mapped(page)) {
>> +				i_mmap_lock_write(mapping);
>> +				hugetlb_vmdelete_list(&mapping->i_mmap,
>> +					next * pages_per_huge_page(h),
>> +					(next + 1) * pages_per_huge_page(h));
>> +				i_mmap_unlock_write(mapping);
>> +			}
>> +
>>  			lock_page(page);
>>  			if (page->index >= end) {
>>  				unlock_page(page);
>> @@ -396,31 +444,23 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
>>  			}
>>  
>>  			/*
>> -			 * If page is mapped, it was faulted in after being
>> -			 * unmapped.  Do nothing in this race case.  In the
>> -			 * normal case page is not mapped.
>> +			 * We must free the huge page and remove from page
>> +			 * cache (remove_huge_page) BEFORE removing the
>> +			 * region/reserve map (hugetlb_unreserve_pages).
>> +			 * In rare out of memory conditions, removal of the
>> +			 * region/reserve map could fail.  Before free'ing
>> +			 * the page, note PagePrivate which is used in case
>> +			 * of error.
>>  			 */
>> -			if (!page_mapped(page)) {
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
>> -				freed++;
>> -				if (!truncate_op) {
>> -					if (unlikely(hugetlb_unreserve_pages(
>> -							inode, next,
>> -							next + 1, 1)))
>> -						hugetlb_fix_reserve_counts(
>> -							inode, rsv_on_error);
>> -				}
>> +			rsv_on_error = !PagePrivate(page);
>> +			remove_huge_page(page);
>> +			freed++;
>> +			if (!truncate_op) {
>> +				if (unlikely(hugetlb_unreserve_pages(inode,
>> +								next, next + 1,
>> +								1)))
>> +					hugetlb_fix_reserve_counts(inode,
>> +								rsv_on_error);
>>  			}
>>  
>>  			if (page->index > next)
>> @@ -450,41 +490,6 @@ static void hugetlbfs_evict_inode(struct inode *inode)
>>  	clear_inode(inode);
>>  }
>>  
>> -static inline void
>> -hugetlb_vmdelete_list(struct rb_root *root, pgoff_t start, pgoff_t end)
>> -{
>> -	struct vm_area_struct *vma;
>> -
>> -	/*
>> -	 * end == 0 indicates that the entire range after
>> -	 * start should be unmapped.
>> -	 */
>> -	vma_interval_tree_foreach(vma, root, start, end ? end : ULONG_MAX) {
>> -		unsigned long v_offset;
>> -
>> -		/*
>> -		 * Can the expression below overflow on 32-bit arches?
>> -		 * No, because the interval tree returns us only those vmas
>> -		 * which overlap the truncated area starting at pgoff,
>> -		 * and no vma on a 32-bit arch can span beyond the 4GB.
>> -		 */
>> -		if (vma->vm_pgoff < start)
>> -			v_offset = (start - vma->vm_pgoff) << PAGE_SHIFT;
>> -		else
>> -			v_offset = 0;
>> -
>> -		if (end) {
>> -			end = ((end - start) << PAGE_SHIFT) +
>> -			       vma->vm_start + v_offset;
>> -			if (end > vma->vm_end)
>> -				end = vma->vm_end;
>> -		} else
>> -			end = vma->vm_end;
>> -
>> -		unmap_hugepage_range(vma, vma->vm_start + v_offset, end, NULL);
>> -	}
>> -}
>> -
>>  static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
>>  {
>>  	pgoff_t pgoff;
>> -- 
>> 2.4.3
>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
