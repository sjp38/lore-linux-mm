Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6ABC86B000D
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 06:17:28 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id e19-v6so2471003pgv.11
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 03:17:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k16-v6si8021554pgt.519.2018.07.02.03.17.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 03:17:27 -0700 (PDT)
Date: Mon, 2 Jul 2018 12:17:25 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 1/6] mm: get_user_pages: consolidate error handling
Message-ID: <20180702101725.esnjyo4zp3726i3n@quack2.suse.cz>
References: <20180702005654.20369-1-jhubbard@nvidia.com>
 <20180702005654.20369-2-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180702005654.20369-2-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

On Sun 01-07-18 17:56:49, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> An upcoming patch requires a way to operate on each page that
> any of the get_user_pages_*() variants returns.
> 
> In preparation for that, consolidate the error handling for
> __get_user_pages(). This provides a single location (the "out:" label)
> for operating on the collected set of pages that are about to be returned.
> 
> As long every use of the "ret" variable is being edited, rename
> "ret" --> "err", so that its name matches its true role.
> This also gets rid of two shadowed variable declarations, as a
> tiny beneficial a side effect.
> 
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>

This looks nice! You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/gup.c | 37 ++++++++++++++++++++++---------------
>  1 file changed, 22 insertions(+), 15 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index b70d7ba7cc13..73f0b3316fa7 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -660,6 +660,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		struct vm_area_struct **vmas, int *nonblocking)
>  {
>  	long i = 0;
> +	int err = 0;
>  	unsigned int page_mask;
>  	struct vm_area_struct *vma = NULL;
>  
> @@ -685,18 +686,19 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		if (!vma || start >= vma->vm_end) {
>  			vma = find_extend_vma(mm, start);
>  			if (!vma && in_gate_area(mm, start)) {
> -				int ret;
> -				ret = get_gate_page(mm, start & PAGE_MASK,
> +				err = get_gate_page(mm, start & PAGE_MASK,
>  						gup_flags, &vma,
>  						pages ? &pages[i] : NULL);
> -				if (ret)
> -					return i ? : ret;
> +				if (err)
> +					goto out;
>  				page_mask = 0;
>  				goto next_page;
>  			}
>  
> -			if (!vma || check_vma_flags(vma, gup_flags))
> -				return i ? : -EFAULT;
> +			if (!vma || check_vma_flags(vma, gup_flags)) {
> +				err = -EFAULT;
> +				goto out;
> +			}
>  			if (is_vm_hugetlb_page(vma)) {
>  				i = follow_hugetlb_page(mm, vma, pages, vmas,
>  						&start, &nr_pages, i,
> @@ -709,23 +711,25 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		 * If we have a pending SIGKILL, don't keep faulting pages and
>  		 * potentially allocating memory.
>  		 */
> -		if (unlikely(fatal_signal_pending(current)))
> -			return i ? i : -ERESTARTSYS;
> +		if (unlikely(fatal_signal_pending(current))) {
> +			err = -ERESTARTSYS;
> +			goto out;
> +		}
>  		cond_resched();
>  		page = follow_page_mask(vma, start, foll_flags, &page_mask);
>  		if (!page) {
> -			int ret;
> -			ret = faultin_page(tsk, vma, start, &foll_flags,
> +			err = faultin_page(tsk, vma, start, &foll_flags,
>  					nonblocking);
> -			switch (ret) {
> +			switch (err) {
>  			case 0:
>  				goto retry;
>  			case -EFAULT:
>  			case -ENOMEM:
>  			case -EHWPOISON:
> -				return i ? i : ret;
> +				goto out;
>  			case -EBUSY:
> -				return i;
> +				err = 0;
> +				goto out;
>  			case -ENOENT:
>  				goto next_page;
>  			}
> @@ -737,7 +741,8 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  			 */
>  			goto next_page;
>  		} else if (IS_ERR(page)) {
> -			return i ? i : PTR_ERR(page);
> +			err = PTR_ERR(page);
> +			goto out;
>  		}
>  		if (pages) {
>  			pages[i] = page;
> @@ -757,7 +762,9 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		start += page_increm * PAGE_SIZE;
>  		nr_pages -= page_increm;
>  	} while (nr_pages);
> -	return i;
> +
> +out:
> +	return i ? i : err;
>  }
>  
>  static bool vma_permits_fault(struct vm_area_struct *vma,
> -- 
> 2.18.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
