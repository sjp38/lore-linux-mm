Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id B2F8B6B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 09:24:13 -0400 (EDT)
Date: Mon, 6 Aug 2012 15:24:10 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2] hugetlb: correct page offset index for sharing pmd
Message-ID: <20120806132410.GA6150@dhcp22.suse.cz>
References: <CAJd=RBC9HhKh5Q0-yXi3W0x3guXJPFz4BNsniyOFmp0TjBdFqg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBC9HhKh5Q0-yXi3W0x3guXJPFz4BNsniyOFmp0TjBdFqg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat 04-08-12 14:08:31, Hillf Danton wrote:
> The computation of page offset index is incorrect to be used in scanning
> prio tree, as huge page offset is required, and is fixed with well
> defined routine.
> 
> Changes from v1
> 	o s/linear_page_index/linear_hugepage_index/ for clearer code
> 	o hp_idx variable added for less change
> 
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
> 
> --- a/arch/x86/mm/hugetlbpage.c	Fri Aug  3 20:34:58 2012
> +++ b/arch/x86/mm/hugetlbpage.c	Fri Aug  3 20:40:16 2012
> @@ -62,6 +62,7 @@ static void huge_pmd_share(struct mm_str
>  {
>  	struct vm_area_struct *vma = find_vma(mm, addr);
>  	struct address_space *mapping = vma->vm_file->f_mapping;
> +	pgoff_t hp_idx;
>  	pgoff_t idx = ((addr - vma->vm_start) >> PAGE_SHIFT) +
>  			vma->vm_pgoff;

So we have two indexes now. That is just plain ugly!

>  	struct prio_tree_iter iter;
> @@ -72,8 +73,10 @@ static void huge_pmd_share(struct mm_str
>  	if (!vma_shareable(vma, addr))
>  		return;
> 
> +	hp_idx = linear_hugepage_index(vma, addr);
> +
>  	mutex_lock(&mapping->i_mmap_mutex);
> -	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, idx, idx) {
> +	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, hp_idx, hp_idx) {
>  		if (svma == vma)
>  			continue;
> 
> --

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
