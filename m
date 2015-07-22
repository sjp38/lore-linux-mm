Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9809E9003C8
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 18:03:47 -0400 (EDT)
Received: by iecri3 with SMTP id ri3so83356352iec.2
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 15:03:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v89si2630448ioi.148.2015.07.22.15.03.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 15:03:47 -0700 (PDT)
Date: Wed, 22 Jul 2015 15:03:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 09/10] hugetlbfs: add hugetlbfs_fallocate()
Message-Id: <20150722150345.f8d5b0042cfa7112bd95d9ef@linux-foundation.org>
In-Reply-To: <1437502184-14269-10-git-send-email-mike.kravetz@oracle.com>
References: <1437502184-14269-1-git-send-email-mike.kravetz@oracle.com>
	<1437502184-14269-10-git-send-email-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Michal Hocko <mhocko@suse.cz>

On Tue, 21 Jul 2015 11:09:43 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> This is based on the shmem version, but it has diverged quite
> a bit.  We have no swap to worry about, nor the new file sealing.
> Add synchronication via the fault mutex table to coordinate
> page faults,  fallocate allocation and fallocate hole punch.
> 
> What this allows us to do is move physical memory in and out of
> a hugetlbfs file without having it mapped.  This also gives us
> the ability to support MADV_REMOVE since it is currently
> implemented using fallocate().  MADV_REMOVE lets madvise() remove
> pages from the middle of a hugetlbfs file, which wasn't possible
> before.
> 
> hugetlbfs fallocate only operates on whole huge pages.
> 
> ...
>
> +static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
> +				loff_t len)
> +{
> +	struct inode *inode = file_inode(file);
> +	struct address_space *mapping = inode->i_mapping;
> +	struct hstate *h = hstate_inode(inode);
> +	struct vm_area_struct pseudo_vma;
> +	struct mm_struct *mm = current->mm;
> +	loff_t hpage_size = huge_page_size(h);
> +	unsigned long hpage_shift = huge_page_shift(h);
> +	pgoff_t start, index, end;
> +	int error;
> +	u32 hash;
> +
> +	if (mode & ~(FALLOC_FL_KEEP_SIZE | FALLOC_FL_PUNCH_HOLE))
> +		return -EOPNOTSUPP;

EOPNOTSUPP is a networking thing.  It's inappropriate here.

The problem is that if this error is ever returned to userspace, the
user will be sitting looking at "Operation not supported on transport
endpoint" and wondering what went wrong in the networking stack.

> +	if (mode & FALLOC_FL_PUNCH_HOLE)
> +		return hugetlbfs_punch_hole(inode, offset, len);
> +
> +	/*
> +	 * Default preallocate case.
> +	 * For this range, start is rounded down and end is rounded up
> +	 * as well as being converted to page offsets.
> +	 */
> +	start = offset >> hpage_shift;
> +	end = (offset + len + hpage_size - 1) >> hpage_shift;
> +
> +	mutex_lock(&inode->i_mutex);
> +
> +	/* We need to check rlimit even when FALLOC_FL_KEEP_SIZE */
> +	error = inode_newsize_ok(inode, offset + len);
> +	if (error)
> +		goto out;
> +
> +	/*
> +	 * Initialize a pseudo vma that just contains the policy used
> +	 * when allocating the huge pages.  The actual policy field
> +	 * (vm_policy) is determined based on the index in the loop below.
> +	 */
> +	memset(&pseudo_vma, 0, sizeof(struct vm_area_struct));
> +	pseudo_vma.vm_flags = (VM_HUGETLB | VM_MAYSHARE | VM_SHARED);
> +	pseudo_vma.vm_file = file;

triviata: we could have just done

	struct vm_area_struct pseudo_vma = {
		.vm_flags = ...
		.vm_file = file;
	};

> +	for (index = start; index < end; index++) {
> +		/*
> +		 * This is supposed to be the vaddr where the page is being
> +		 * faulted in, but we have no vaddr here.
> +		 */
> +		struct page *page;
> +		unsigned long addr;
> +		int avoid_reserve = 0;
> +
> +		cond_resched();
> +
> +		/*
> +		 * fallocate(2) manpage permits EINTR; we may have been
> +		 * interrupted because we are using up too much memory.
> +		 */
> +		if (signal_pending(current)) {
> +			error = -EINTR;
> +			break;
> +		}
> +
> +		/* Get policy based on index */
> +		pseudo_vma.vm_policy =
> +			mpol_shared_policy_lookup(&HUGETLBFS_I(inode)->policy,
> +							index);
> +
> +		/* addr is the offset within the file (zero based) */

So use loff_t?

> +		addr = index * hpage_size;
> +
> +		/* mutex taken here, fault path and hole punch */
> +		hash = hugetlb_fault_mutex_hash(h, mm, &pseudo_vma, mapping,
> +						index, addr);
> +		mutex_lock(&hugetlb_fault_mutex_table[hash]);
> +
> +		/* See if already present in mapping to avoid alloc/free */
> +		page = find_get_page(mapping, index);
> +		if (page) {
> +			put_page(page);
> +			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
> +			mpol_cond_put(pseudo_vma.vm_policy);
> +			continue;
> +		}
> +
> +		/* Allocate page and add to page cache */
> +		page = alloc_huge_page(&pseudo_vma, addr, avoid_reserve);
> +		mpol_cond_put(pseudo_vma.vm_policy);
> +		if (IS_ERR(page)) {
> +			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
> +			error = PTR_ERR(page);
> +			goto out;
> +		}
> +		clear_huge_page(page, addr, pages_per_huge_page(h));
> +		__SetPageUptodate(page);
> +		error = huge_add_to_page_cache(page, mapping, index);
> +		if (unlikely(error)) {
> +			put_page(page);
> +			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
> +			goto out;
> +		}
> +
> +		mutex_unlock(&hugetlb_fault_mutex_table[hash]);
> +
> +		/*
> +		 * page_put due to reference from alloc_huge_page()
> +		 * unlock_page because locked by add_to_page_cache()
> +		 */
> +		put_page(page);
> +		unlock_page(page);
> +	}
> +
> +	if (!(mode & FALLOC_FL_KEEP_SIZE) && offset + len > inode->i_size)
> +		i_size_write(inode, offset + len);
> +	inode->i_ctime = CURRENT_TIME;
> +	spin_lock(&inode->i_lock);
> +	inode->i_private = NULL;
> +	spin_unlock(&inode->i_lock);
> +out:
> +	mutex_unlock(&inode->i_mutex);
> +	return error;
> 
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
