Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id D8FCA6B0033
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 13:58:17 -0400 (EDT)
Date: Fri, 30 Aug 2013 13:57:45 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1377885465-j6jllnaq-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1377881897-138063-2-git-send-email-athorlton@sgi.com>
References: <1377881897-138063-1-git-send-email-athorlton@sgi.com>
 <1377881897-138063-2-git-send-email-athorlton@sgi.com>
Subject: Re: [RFC PATCH] Change THP code to use pud_page(pud)->ptl lock
 page_table_lock
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Robin Holt <robinmholt@gmail.com>, linux-mm@kvack.org

Hi Alex,

I'm interested in the same issue, and posted patches a few hours ago
too (Cc:ed you.) It can be interesting/helpful for you.

On Fri, Aug 30, 2013 at 11:58:17AM -0500, Alex Thorlton wrote:
> This patch changes out the page_table_lock for the pud_page ptl in the
> THP fault path; pretty self-explanatory.  I got lazy and commented out
> the spinlock assertion in follow_trans_huge_pmd instead of digging up
> the pud_page ptl in this function.  This is just a proof of concept, so
> I didn't feel that it was too important to keep around for now. 
> 
> ---
>  mm/huge_memory.c | 4 ++--
>  mm/memory.c      | 6 +++---
>  2 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index a92012a..d3b34e2f 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1240,10 +1240,10 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
>  				   pmd_t *pmd,
>  				   unsigned int flags)
>  {
> -	struct mm_struct *mm = vma->vm_mm;
> +//	struct mm_struct *mm = vma->vm_mm;
>  	struct page *page = NULL;
>  
> -	assert_spin_locked(&mm->page_table_lock);
> +//	assert_spin_locked(&mm->page_table_lock);
>  
>  	if (flags & FOLL_WRITE && !pmd_write(*pmd))
>  		goto out;
> diff --git a/mm/memory.c b/mm/memory.c
> index af84bc0..5b4e910 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1527,15 +1527,15 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
>  			split_huge_page_pmd(vma, address, pmd);
>  			goto split_fallthrough;
>  		}
> -		spin_lock(&mm->page_table_lock);
> +		spin_lock(&pud_page(*pud)->ptl);
>  		if (likely(pmd_trans_huge(*pmd))) {
>  			if (unlikely(pmd_trans_splitting(*pmd))) {
> -				spin_unlock(&mm->page_table_lock);
> +				spin_unlock(&pud_page(*pud)->ptl);
>  				wait_split_huge_page(vma->anon_vma, pmd);
>  			} else {
>  				page = follow_trans_huge_pmd(vma, address,
>  							     pmd, flags);
> -				spin_unlock(&mm->page_table_lock);
> +				spin_unlock(&pud_page(*pud)->ptl);
>  				*page_mask = HPAGE_PMD_NR - 1;
>  				goto out;
>  			}

I think that other ptl holders should use pud_page->ptl rather than
mm->page_table_lock. Otherwise we have a race that other threads can
change *pmd when running on this code.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
