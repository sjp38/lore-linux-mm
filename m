Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8BF3D82F64
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 23:37:07 -0400 (EDT)
Received: by pabla5 with SMTP id la5so49426003pab.0
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 20:37:07 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id lo9si66862229pab.201.2015.10.27.20.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 20:37:06 -0700 (PDT)
Received: by pabla5 with SMTP id la5so49425804pab.0
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 20:37:06 -0700 (PDT)
Date: Tue, 27 Oct 2015 20:37:04 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2 3/4] mm/hugetlb: page faults check for fallocate hole
 punch in progress and wait
In-Reply-To: <1445385142-29936-4-git-send-email-mike.kravetz@oracle.com>
Message-ID: <alpine.LSU.2.11.1510272034420.2872@eggly.anvils>
References: <1445385142-29936-1-git-send-email-mike.kravetz@oracle.com> <1445385142-29936-4-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 20 Oct 2015, Mike Kravetz wrote:

> At page fault time, check i_private which indicates a fallocate hole punch
> is in progress.  If the fault falls within the hole, wait for the hole
> punch operation to complete before proceeding with the fault.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  mm/hugetlb.c | 39 +++++++++++++++++++++++++++++++++++++++
>  1 file changed, 39 insertions(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 3c7db92..2a5e9b4 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3580,6 +3580,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	struct page *pagecache_page = NULL;
>  	struct hstate *h = hstate_vma(vma);
>  	struct address_space *mapping;
> +	struct inode *inode = file_inode(vma->vm_file);
>  	int need_wait_lock = 0;
>  
>  	address &= huge_page_mask(h);
> @@ -3603,6 +3604,44 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	idx = vma_hugecache_offset(h, vma, address);
>  
>  	/*
> +	 * page faults could race with fallocate hole punch.  If a page
> +	 * is faulted between unmap and deallocation, it will still remain
> +	 * in the punched hole.  During hole punch operations, a hugetlb_falloc
> +	 * structure will be pointed to by i_private.  If this fault is for
> +	 * a page in a hole being punched, wait for the operation to finish
> +	 * before proceeding.
> +	 *
> +	 * Even with this strategy, it is still possible for a page fault to
> +	 * race with hole punch.  In this case, remove_inode_hugepages() will
> +	 * unmap the page and then remove.  Checking i_private as below should
> +	 * catch most of these races as we want to minimize unmapping a page
> +	 * multiple times.
> +	 */
> +	if (unlikely(inode->i_private)) {
> +		struct hugetlb_falloc *hugetlb_falloc;
> +
> +		spin_lock(&inode->i_lock);
> +		hugetlb_falloc = inode->i_private;
> +		if (hugetlb_falloc && hugetlb_falloc->waitq &&

Not important, but that "&& hugetlb_falloc->waitq " is redundant.

> +		    idx >= hugetlb_falloc->start &&
> +		    idx <= hugetlb_falloc->end) {

Not important, but "idx < hugetlb_falloc->end" would be better.

> +			wait_queue_head_t *hugetlb_falloc_waitq;
> +			DEFINE_WAIT(hugetlb_fault_wait);
> +
> +			hugetlb_falloc_waitq = hugetlb_falloc->waitq;
> +			prepare_to_wait(hugetlb_falloc_waitq,
> +					&hugetlb_fault_wait,
> +					TASK_UNINTERRUPTIBLE);
> +			spin_unlock(&inode->i_lock);
> +			schedule();
> +
> +			spin_lock(&inode->i_lock);
> +			finish_wait(hugetlb_falloc_waitq, &hugetlb_fault_wait);
> +		}
> +		spin_unlock(&inode->i_lock);
> +	}
> +
> +	/*
>  	 * Serialize hugepage allocation and instantiation, so that we don't
>  	 * get spurious allocation failures if two CPUs race to instantiate
>  	 * the same page in the page cache.
> -- 
> 2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
