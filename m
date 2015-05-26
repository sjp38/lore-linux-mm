Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 167636B00BA
	for <linux-mm@kvack.org>; Tue, 26 May 2015 13:53:58 -0400 (EDT)
Received: by obbnx5 with SMTP id nx5so80489106obb.0
        for <linux-mm@kvack.org>; Tue, 26 May 2015 10:53:57 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 194si9197985oif.69.2015.05.26.10.53.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 10:53:57 -0700 (PDT)
Message-ID: <5564B30E.8040809@oracle.com>
Date: Tue, 26 May 2015 10:53:18 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC v3 PATCH 09/10] hugetlbfs: add hugetlbfs_fallocate()
References: <1432223264-4414-1-git-send-email-mike.kravetz@oracle.com> <1432223264-4414-10-git-send-email-mike.kravetz@oracle.com> <20150526065453.GB17652@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150526065453.GB17652@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>

On 05/25/2015 11:54 PM, Naoya Horiguchi wrote:
> On Thu, May 21, 2015 at 08:47:43AM -0700, Mike Kravetz wrote:
>> This is based on the shmem version, but it has diverged quite
>> a bit.  We have no swap to worry about, nor the new file sealing.
>> Add synchronication via the fault mutex table to coordinate
>> page faults,  fallocate allocation and fallocate hole punch.
>>
>> What this allows us to do is move physical memory in and out of
>> a hugetlbfs file without having it mapped.  This also gives us
>> the ability to support MADV_REMOVE since it is currently
>> implemented using fallocate().  MADV_REMOVE lets madvise() remove
>> pages from the middle of a hugetlbfs file, which wasn't possible
>> before.
>>
>> hugetlbfs fallocate only operates on whole huge pages.
>>
>> Based-on code-by: Dave Hansen <dave.hansen@linux.intel.com>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> 
> This patch changes the behavior of user API, so please update manpage of
> fallocate(2).

Will do.

Unfortunately, I believe hugetlbfs does not follow the man page
for ftruncate.  So, I will look to get that updated as well.

>> ---
>>   fs/hugetlbfs/inode.c    | 169 +++++++++++++++++++++++++++++++++++++++++++++++-
>>   include/linux/hugetlb.h |   3 +
>>   mm/hugetlb.c            |   2 +-
>>   3 files changed, 172 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>> index dfa88a5..4b1535f 100644
>> --- a/fs/hugetlbfs/inode.c
>> +++ b/fs/hugetlbfs/inode.c
>> @@ -12,6 +12,7 @@
>>   #include <linux/thread_info.h>
>>   #include <asm/current.h>
>>   #include <linux/sched.h>		/* remove ASAP */
>> +#include <linux/falloc.h>
>>   #include <linux/fs.h>
>>   #include <linux/mount.h>
>>   #include <linux/file.h>
>> @@ -493,6 +494,171 @@ static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
>>   	return 0;
>>   }
>>   
>> +static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
>> +{
>> +	struct hstate *h = hstate_inode(inode);
>> +	unsigned long hpage_size = huge_page_size(h);
>> +	loff_t hole_start, hole_end;
>> +
>> +	/*
>> +	 * For hole punch round up the beginning offset of the hole and
>> +	 * round down the end.
>> +	 */
>> +	hole_start = (offset + hpage_size - 1) & huge_page_mask(h);
>> +	hole_end = (offset + len) & huge_page_mask(h);
> 
> We have round_up/round_up macro, so please use them here.
> Then, it's self-descriptive, so you don't have to write comment.
> 
>> +
>> +	if ((u64)hole_end > (u64)hole_start) {
> 
> Why is this casting to u64 necessary?

It is not necessary.  I will remove it.

>> +		struct address_space *mapping = inode->i_mapping;
>> +
>> +		mutex_lock(&inode->i_mutex);
>> +		i_mmap_lock_write(mapping);
>> +		if (!RB_EMPTY_ROOT(&mapping->i_mmap))
>> +			hugetlb_vmdelete_list(&mapping->i_mmap,
>> +						hole_start >> PAGE_SHIFT,
>> +						hole_end  >> PAGE_SHIFT);
>> +		i_mmap_unlock_write(mapping);
>> +		remove_inode_hugepages(inode, hole_start, hole_end);
>> +		mutex_unlock(&inode->i_mutex);
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>> +static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
>> +				loff_t len)
>> +{
>> +	struct inode *inode = file_inode(file);
>> +	struct address_space *mapping = inode->i_mapping;
>> +	struct hstate *h = hstate_inode(inode);
>> +	struct vm_area_struct pseudo_vma;
>> +	unsigned long hpage_size = huge_page_size(h);
>> +	unsigned long hpage_shift = huge_page_shift(h);
>> +	pgoff_t start, index, end;
>> +	int error;
>> +	u32 hash;
>> +
>> +	if (mode & ~(FALLOC_FL_KEEP_SIZE | FALLOC_FL_PUNCH_HOLE))
>> +		return -EOPNOTSUPP;
>> +
>> +	if (mode & FALLOC_FL_PUNCH_HOLE)
>> +		return hugetlbfs_punch_hole(inode, offset, len);
>> +
>> +	/*
>> +	 * Default preallocate case.
>> +	 * For this range, start is rounded down and end is rounded up.
>> +	 */
>> +	start = offset >> hpage_shift;
>> +	end = (offset + len + hpage_size - 1) >> hpage_shift;
>> +
>> +	mutex_lock(&inode->i_mutex);
>> +
>> +	/* We need to check rlimit even when FALLOC_FL_KEEP_SIZE */
>> +	error = inode_newsize_ok(inode, offset + len);
>> +	if (error)
>> +		goto out;
>> +
>> +	/*
>> +	 * Initialize a pseudo vma that just contains the policy used
>> +	 * when allocating the huge pages.  The actual policy field
>> +	 * (vm_policy) is determined based on the index in the loop below.
>> +	 */
>> +	memset(&pseudo_vma, 0, sizeof(struct vm_area_struct));
>> +	pseudo_vma.vm_start = 0;
>> +	pseudo_vma.vm_flags |= (VM_HUGETLB | VM_MAYSHARE | VM_SHARED);
> 
> Maybe '|' isn't necessary.

No, it is not necessary.  I will remove.

>> +	pseudo_vma.vm_file = file;
>> +
>> +	for (index = start; index < end; index++) {
>> +		/*
>> +		 * This is supposed to be the vaddr where the page is being
>> +		 * faulted in, but we have no vaddr here.
>> +		 */
>> +		struct page *page;
>> +		unsigned long addr;
>> +		int avoid_reserve = 0;
> 
> avoid_reserve is referred only once and never changed, so no need to use
> the variable?

It is not necessary.  I will remove it.

>> +
>> +		cond_resched();
>> +
>> +		/*
>> +		 * fallocate(2) manpage permits EINTR; we may have been
>> +		 * interrupted because we are using up too much memory.
>> +		 */
>> +		if (signal_pending(current)) {
>> +			error = -EINTR;
>> +			break;
>> +		}
>> +
>> +		/* Get policy based on index */
>> +		pseudo_vma.vm_policy =
>> +			mpol_shared_policy_lookup(&HUGETLBFS_I(inode)->policy,
>> +							index);
>> +
>> +		/* addr is the offset within the file (zero based) */
>> +		addr = index * hpage_size;
>> +
>> +		/* mutex taken here, fault path and hole punch */
>> +		hash = hugetlb_fault_mutex_shared_hash(mapping, index);
>> +		hugetlb_fault_mutex_lock(hash);
>> +
>> +		/* see if page already exists to avoid alloc/free */
>> +		page = find_get_page(mapping, index);
>> +		if (page) {
>> +			put_page(page);
>> +			hugetlb_fault_mutex_unlock(hash);
> 
> Don't you need mpol_cond_put() here?

Yes.  Thank you, I will add it.

>> +			continue;
>> +		}
>> +
>> +		page = alloc_huge_page(&pseudo_vma, addr, avoid_reserve);
>> +		mpol_cond_put(pseudo_vma.vm_policy);
>> +		if (IS_ERR(page)) {
>> +			hugetlb_fault_mutex_unlock(hash);
>> +			error = PTR_ERR(page);
>> +			goto out;
>> +		}
>> +		clear_huge_page(page, addr, pages_per_huge_page(h));
>> +		__SetPageUptodate(page);
> 
> Note that recently I added page_huge_active() to mark activeness of hugepages,
> so when you rebased to v4.1-rc1+, please insert set_page_huge_active(page) here.
> 

Yes, I noticed your change.

>> +		error = huge_add_to_page_cache(page, mapping, index);
>> +		if (error) {
>> +			/*
>> +			 * An entry already exists in the cache.  This implies
>> +			 * a region also existed in the reserve map at the time
>> +			 * the page was allocated above.  Therefore, no use
>> +			 * count was added to the subpool for the page.  Before
>> +			 * freeing the page, clear the subpool reference so
>> +			 * that the count is not decremented.
>> +			 */
>> +			set_page_private(page, 0);/* clear spool reference */
> 
> This looks unclear to me. Which "count" do you refer to in the comment
> "no use count was added to the subpool" or "the count is not decremented"?
> I guess spool->used_hpages or spool->rsv_hpages, but alloc_huge_page() above
> should call hugepage_subpool_get_pages(), so it's accounted, right?
> Could you write comments more specifically?

Yes, this is confusing.  As I am reexamining the code, I see that
it is incorrect.  This code may not be necessary.  It was there to
handle a race with page faults.  The code now uses the hugetlb fault
mutex table to synchronize with page faults.  I will do some more
work here and expect this confusing code to go away.

Thank you for your comments,
-- 
Mike Kravetz

> 
> Thanks,
> Naoya Horiguchi
> 
>> +			put_page(page);
>> +
>> +			hugetlb_fault_mutex_unlock(hash);
>> +			/* Keep going if we see an -EEXIST */
>> +			if (error == -EEXIST) {
>> +				error = 0;	/* do not return to user */
>> +				continue;
>> +			} else
>> +				goto out;
>> +		}
>> +
>> +		hugetlb_fault_mutex_unlock(hash);
>> +
>> +		/*
>> +		 * page_put due to reference from alloc_huge_page()
>> +		 * unlock_page because locked by add_to_page_cache()
>> +		 */
>> +		put_page(page);
>> +		unlock_page(page);
>> +	}
>> +
>> +	if (!(mode & FALLOC_FL_KEEP_SIZE) && offset + len > inode->i_size)
>> +		i_size_write(inode, offset + len);
>> +	inode->i_ctime = CURRENT_TIME;
>> +	spin_lock(&inode->i_lock);
>> +	inode->i_private = NULL;
>> +	spin_unlock(&inode->i_lock);
>> +out:
>> +	mutex_unlock(&inode->i_mutex);
>> +	return error;
>> +}
>> +
>>   static int hugetlbfs_setattr(struct dentry *dentry, struct iattr *attr)
>>   {
>>   	struct inode *inode = dentry->d_inode;
>> @@ -804,7 +970,8 @@ const struct file_operations hugetlbfs_file_operations = {
>>   	.mmap			= hugetlbfs_file_mmap,
>>   	.fsync			= noop_fsync,
>>   	.get_unmapped_area	= hugetlb_get_unmapped_area,
>> -	.llseek		= default_llseek,
>> +	.llseek			= default_llseek,
>> +	.fallocate		= hugetlbfs_fallocate,
>>   };
>>   
>>   static const struct inode_operations hugetlbfs_dir_inode_operations = {
>> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
>> index 934f339..fa36b7a 100644
>> --- a/include/linux/hugetlb.h
>> +++ b/include/linux/hugetlb.h
>> @@ -327,6 +327,8 @@ struct huge_bootmem_page {
>>   #endif
>>   };
>>   
>> +struct page *alloc_huge_page(struct vm_area_struct *vma,
>> +				unsigned long addr, int avoid_reserve);
>>   struct page *alloc_huge_page_node(struct hstate *h, int nid);
>>   struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
>>   				unsigned long addr, int avoid_reserve);
>> @@ -481,6 +483,7 @@ static inline bool hugepages_supported(void)
>>   
>>   #else	/* CONFIG_HUGETLB_PAGE */
>>   struct hstate {};
>> +#define alloc_huge_page(v, a, r) NULL
>>   #define alloc_huge_page_node(h, nid) NULL
>>   #define alloc_huge_page_noerr(v, a, r) NULL
>>   #define alloc_bootmem_huge_page(h) NULL
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 94c6154..1e95038 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -1444,7 +1444,7 @@ static long vma_commit_reservation(struct hstate *h,
>>   /* Forward declaration */
>>   static int hugetlb_acct_memory(struct hstate *h, long delta);
>>   
>> -static struct page *alloc_huge_page(struct vm_area_struct *vma,
>> +struct page *alloc_huge_page(struct vm_area_struct *vma,
>>   				    unsigned long addr, int avoid_reserve)
>>   {
>>   	struct hugepage_subpool *spool = subpool_vma(vma);
>> -- 
>> 2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
