Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 124118E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 05:20:40 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id e68so12919853plb.3
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 02:20:40 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m14si12502519pgd.326.2019.01.21.02.20.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 02:20:38 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0LADrPo008335
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 05:20:38 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q59wep3s3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 05:20:37 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 21 Jan 2019 10:20:35 -0000
Date: Mon, 21 Jan 2019 12:20:24 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH RFC 01/24] mm: gup: rename "nonblocking" to "locked"
 where proper
References: <20190121075722.7945-1-peterx@redhat.com>
 <20190121075722.7945-2-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190121075722.7945-2-peterx@redhat.com>
Message-Id: <20190121102024.GB19725@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Mike Kravetz <mike.kravetz@oracle.com>, Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>

On Mon, Jan 21, 2019 at 03:56:59PM +0800, Peter Xu wrote:
> There's plenty of places around __get_user_pages() that has a parameter
> "nonblocking" which does not really mean that "it won't block" (because
> it can really block) but instead it shows whether the mmap_sem is
> released by up_read() during the page fault handling mostly when
> VM_FAULT_RETRY is returned.
> 
> We have the correct naming in e.g. get_user_pages_locked() or
> get_user_pages_remote() as "locked", however there're still many places
> that are using the "nonblocking" as name.
> 
> Renaming the places to "locked" where proper to better suite the
> functionality of the variable.  While at it, fixing up some of the
> comments accordingly.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  mm/gup.c     | 44 +++++++++++++++++++++-----------------------
>  mm/hugetlb.c |  8 ++++----
>  2 files changed, 25 insertions(+), 27 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index 8cb68a50dbdf..7b1f452cc2ef 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -506,12 +506,12 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
>  }
> 
>  /*
> - * mmap_sem must be held on entry.  If @nonblocking != NULL and
> - * *@flags does not include FOLL_NOWAIT, the mmap_sem may be released.
> - * If it is, *@nonblocking will be set to 0 and -EBUSY returned.
> + * mmap_sem must be held on entry.  If @locked != NULL and *@flags
> + * does not include FOLL_NOWAIT, the mmap_sem may be released.  If it
> + * is, *@locked will be set to 0 and -EBUSY returned.
>   */
>  static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
> -		unsigned long address, unsigned int *flags, int *nonblocking)
> +		unsigned long address, unsigned int *flags, int *locked)
>  {
>  	unsigned int fault_flags = 0;
>  	vm_fault_t ret;
> @@ -523,7 +523,7 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
>  		fault_flags |= FAULT_FLAG_WRITE;
>  	if (*flags & FOLL_REMOTE)
>  		fault_flags |= FAULT_FLAG_REMOTE;
> -	if (nonblocking)
> +	if (locked)
>  		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
>  	if (*flags & FOLL_NOWAIT)
>  		fault_flags |= FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
> @@ -549,8 +549,8 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
>  	}
> 
>  	if (ret & VM_FAULT_RETRY) {
> -		if (nonblocking && !(fault_flags & FAULT_FLAG_RETRY_NOWAIT))
> -			*nonblocking = 0;
> +		if (locked && !(fault_flags & FAULT_FLAG_RETRY_NOWAIT))
> +			*locked = 0;
>  		return -EBUSY;
>  	}
> 
> @@ -627,7 +627,7 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
>   *		only intends to ensure the pages are faulted in.
>   * @vmas:	array of pointers to vmas corresponding to each page.
>   *		Or NULL if the caller does not require them.
> - * @nonblocking: whether waiting for disk IO or mmap_sem contention
> + * @locked:     whether we're still with the mmap_sem held
>   *
>   * Returns number of pages pinned. This may be fewer than the number
>   * requested. If nr_pages is 0 or negative, returns 0. If no pages
> @@ -656,13 +656,11 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
>   * appropriate) must be called after the page is finished with, and
>   * before put_page is called.
>   *
> - * If @nonblocking != NULL, __get_user_pages will not wait for disk IO
> - * or mmap_sem contention, and if waiting is needed to pin all pages,
> - * *@nonblocking will be set to 0.  Further, if @gup_flags does not
> - * include FOLL_NOWAIT, the mmap_sem will be released via up_read() in
> - * this case.
> + * If @locked != NULL, *@locked will be set to 0 when mmap_sem is
> + * released by an up_read().  That can happen if @gup_flags does not
> + * has FOLL_NOWAIT.
>   *
> - * A caller using such a combination of @nonblocking and @gup_flags
> + * A caller using such a combination of @locked and @gup_flags
>   * must therefore hold the mmap_sem for reading only, and recognize
>   * when it's been released.  Otherwise, it must be held for either
>   * reading or writing and will not be released.
> @@ -674,7 +672,7 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
>  static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		unsigned long start, unsigned long nr_pages,
>  		unsigned int gup_flags, struct page **pages,
> -		struct vm_area_struct **vmas, int *nonblocking)
> +		struct vm_area_struct **vmas, int *locked)
>  {
>  	long ret = 0, i = 0;
>  	struct vm_area_struct *vma = NULL;
> @@ -718,7 +716,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  			if (is_vm_hugetlb_page(vma)) {
>  				i = follow_hugetlb_page(mm, vma, pages, vmas,
>  						&start, &nr_pages, i,
> -						gup_flags, nonblocking);
> +						gup_flags, locked);
>  				continue;
>  			}
>  		}
> @@ -736,7 +734,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		page = follow_page_mask(vma, start, foll_flags, &ctx);
>  		if (!page) {
>  			ret = faultin_page(tsk, vma, start, &foll_flags,
> -					nonblocking);
> +					   locked);
>  			switch (ret) {
>  			case 0:
>  				goto retry;
> @@ -1195,7 +1193,7 @@ EXPORT_SYMBOL(get_user_pages_longterm);
>   * @vma:   target vma
>   * @start: start address
>   * @end:   end address
> - * @nonblocking:
> + * @locked: whether the mmap_sem is still held
>   *
>   * This takes care of mlocking the pages too if VM_LOCKED is set.
>   *
> @@ -1203,14 +1201,14 @@ EXPORT_SYMBOL(get_user_pages_longterm);
>   *
>   * vma->vm_mm->mmap_sem must be held.
>   *
> - * If @nonblocking is NULL, it may be held for read or write and will
> + * If @locked is NULL, it may be held for read or write and will
>   * be unperturbed.
>   *
> - * If @nonblocking is non-NULL, it must held for read only and may be
> - * released.  If it's released, *@nonblocking will be set to 0.
> + * If @locked is non-NULL, it must held for read only and may be
> + * released.  If it's released, *@locked will be set to 0.
>   */
>  long populate_vma_page_range(struct vm_area_struct *vma,
> -		unsigned long start, unsigned long end, int *nonblocking)
> +		unsigned long start, unsigned long end, int *locked)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	unsigned long nr_pages = (end - start) / PAGE_SIZE;
> @@ -1245,7 +1243,7 @@ long populate_vma_page_range(struct vm_area_struct *vma,
>  	 * not result in a stack expansion that recurses back here.
>  	 */
>  	return __get_user_pages(current, mm, start, nr_pages, gup_flags,
> -				NULL, NULL, nonblocking);
> +				NULL, NULL, locked);
>  }
> 
>  /*
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 705a3e9cc910..05b879bda10a 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4181,7 +4181,7 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
>  long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			 struct page **pages, struct vm_area_struct **vmas,
>  			 unsigned long *position, unsigned long *nr_pages,
> -			 long i, unsigned int flags, int *nonblocking)
> +			 long i, unsigned int flags, int *locked)
>  {
>  	unsigned long pfn_offset;
>  	unsigned long vaddr = *position;
> @@ -4252,7 +4252,7 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  				spin_unlock(ptl);
>  			if (flags & FOLL_WRITE)
>  				fault_flags |= FAULT_FLAG_WRITE;
> -			if (nonblocking)
> +			if (locked)
>  				fault_flags |= FAULT_FLAG_ALLOW_RETRY;
>  			if (flags & FOLL_NOWAIT)
>  				fault_flags |= FAULT_FLAG_ALLOW_RETRY |
> @@ -4269,8 +4269,8 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  				break;
>  			}
>  			if (ret & VM_FAULT_RETRY) {
> -				if (nonblocking)
> -					*nonblocking = 0;
> +				if (locked)
> +					*locked = 0;
>  				*nr_pages = 0;
>  				/*
>  				 * VM_FAULT_RETRY must not return an
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.
