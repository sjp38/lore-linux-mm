Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1116B0031
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 19:33:43 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id cc10so3816535wib.6
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 16:33:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id bz18si5430728wib.10.2014.06.12.16.33.40
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 16:33:41 -0700 (PDT)
Message-ID: <539a38d5.f25ab40a.52ef.1417SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 7/7] mincore: apply page table walker on do_mincore()
Date: Thu, 12 Jun 2014 19:33:30 -0400
In-Reply-To: <20140612150443.72809d03688bdce9a84164a6@linux-foundation.org>
References: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1402095520-10109-8-git-send-email-n-horiguchi@ah.jp.nec.com> <20140612150443.72809d03688bdce9a84164a6@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

On Thu, Jun 12, 2014 at 03:04:43PM -0700, Andrew Morton wrote:
> On Fri,  6 Jun 2014 18:58:40 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > @@ -233,12 +163,20 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
> >  
> >  	end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
> >  
> > -	if (is_vm_hugetlb_page(vma))
> > -		mincore_hugetlb_page_range(vma, addr, end, vec);
> > +	struct mm_walk mincore_walk = {
> > +		.pmd_entry = mincore_pmd,
> > +		.pte_entry = mincore_pte,
> > +		.pte_hole = mincore_hole,
> > +		.hugetlb_entry = mincore_hugetlb,
> > +		.mm = vma->vm_mm,
> > +		.vma = vma,
> > +		.private = vec,
> > +	};
> > +	err = walk_page_vma(vma, &mincore_walk);
> > +	if (err < 0)
> > +		return err;
> >  	else
> > -		mincore_page_range(vma, addr, end, vec);
> > -
> > -	return (end - addr) >> PAGE_SHIFT;
> > +		return (end - addr) >> PAGE_SHIFT;
> >  }
> >  
> >  /*
> 
> Please review carefully.
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mincore-apply-page-table-walker-on-do_mincore-fix
> 
> mm/mincore.c: In function 'do_mincore':
> mm/mincore.c:166: warning: ISO C90 forbids mixed declarations and code

Yes, this warning is fixed in patch 11/11 in ver.2.

> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/mincore.c |   28 +++++++++++++++-------------
>  1 file changed, 15 insertions(+), 13 deletions(-)
> 
> diff -puN mm/huge_memory.c~mincore-apply-page-table-walker-on-do_mincore-fix mm/huge_memory.c
> diff -puN mm/mincore.c~mincore-apply-page-table-walker-on-do_mincore-fix mm/mincore.c
> --- a/mm/mincore.c~mincore-apply-page-table-walker-on-do_mincore-fix
> +++ a/mm/mincore.c
> @@ -151,32 +151,34 @@ static int mincore_pmd(pmd_t *pmd, unsig
>   * all the arguments, we hold the mmap semaphore: we should
>   * just return the amount of info we're asked for.
>   */
> -static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *vec)
> +static long do_mincore(unsigned long addr, unsigned long pages,
> +		       unsigned char *vec)
>  {
>  	struct vm_area_struct *vma;
> -	unsigned long end;
>  	int err;
> -
> -	vma = find_vma(current->mm, addr);
> -	if (!vma || addr < vma->vm_start)
> -		return -ENOMEM;
> -
> -	end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
> -
>  	struct mm_walk mincore_walk = {
>  		.pmd_entry = mincore_pmd,
>  		.pte_entry = mincore_pte,
>  		.pte_hole = mincore_hole,
>  		.hugetlb_entry = mincore_hugetlb,
> -		.mm = vma->vm_mm,
> -		.vma = vma,
>  		.private = vec,
>  	};
> +
> +	vma = find_vma(current->mm, addr);
> +	if (!vma || addr < vma->vm_start)
> +		return -ENOMEM;
> +	mincore_walk.vma = vma;
> +	mincore_walk.mm = vma->vm_mm;
> +
>  	err = walk_page_vma(vma, &mincore_walk);
> -	if (err < 0)
> +	if (err < 0) {
>  		return err;
> -	else
> +	} else {
> +		unsigned long end;
> +
> +		end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
>  		return (end - addr) >> PAGE_SHIFT;
> +	}

Doesn't this min() with vma->vm_end break the mincore(2)'s behavior?
The return value of do_mincore() are subtracted from pages in sys_mincore
and the while loop is repeated until pages reaches 0, so if users call
mincore(2) over the virtual address range not backed by vma, the return
value is underestimated.  I think that in mincore's walk we should set vec
to 0 for such hole region (no vma backed,) so it should be counted in the
return value.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
