Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 84B776B0176
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 17:14:55 -0400 (EDT)
Date: Tue, 23 Aug 2011 14:14:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3 of 3] thp: mremap support and TLB optimization
Message-Id: <20110823141445.35864dc8.akpm@linux-foundation.org>
In-Reply-To: <10a29e95223e52e49a61.1312649885@localhost>
References: <patchbomb.1312649882@localhost>
	<10a29e95223e52e49a61.1312649885@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Sat, 06 Aug 2011 18:58:05 +0200
aarcange@redhat.com wrote:

> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> This adds THP support to mremap (decreases the number of split_huge_page
> called).
>
> ...

I have some nitpicking.
 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1054,6 +1054,52 @@ int mincore_huge_pmd(struct vm_area_stru
>  	return ret;
>  }
>  
> +int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
> +		  unsigned long old_addr,
> +		  unsigned long new_addr, unsigned long old_end,
> +		  pmd_t *old_pmd, pmd_t *new_pmd)
> +{
> +	int ret = 0;
> +	pmd_t pmd;
> +
> +	struct mm_struct *mm = vma->vm_mm;
> +
> +	if ((old_addr & ~HPAGE_PMD_MASK) ||
> +	    (new_addr & ~HPAGE_PMD_MASK) ||
> +	    (old_addr + HPAGE_PMD_SIZE) > old_end ||

Can (old_addr + HPAGE_PMD_SIZE) wrap past zero?

> +	    new_vma->vm_flags & VM_NOHUGEPAGE)

This should be parenthesized, IMO, like the other sub-expressions.

> +		goto out;
> +
> +	/*
> +	 * The destination pmd shouldn't be established, free_pgtables()
> +	 * should have release it.
> +	 */
> +	if (!pmd_none(*new_pmd)) {
> +		WARN_ON(1);

We can use the WARN_ON return value trick here.

> +		VM_BUG_ON(pmd_trans_huge(*new_pmd));
> +		goto out;
> +	}
> +
> +	spin_lock(&mm->page_table_lock);
> +	if (likely(pmd_trans_huge(*old_pmd))) {
> +		if (pmd_trans_splitting(*old_pmd)) {
> +			spin_unlock(&mm->page_table_lock);
> +			wait_split_huge_page(vma->anon_vma, old_pmd);
> +			ret = -1;
> +		} else {
> +			pmd = pmdp_get_and_clear(mm, old_addr, old_pmd);
> +			VM_BUG_ON(!pmd_none(*new_pmd));
> +			set_pmd_at(mm, new_addr, new_pmd, pmd);
> +			spin_unlock(&mm->page_table_lock);
> +			ret = 1;
> +		}
> +	} else
> +		spin_unlock(&mm->page_table_lock);

If the "if" part has braces, it's conventional to also add them to the
"else" part.

> +out:
> +	return ret;
> +}
> +

Result:

diff -puN mm/huge_memory.c~thp-mremap-support-and-tlb-optimization-fix mm/huge_memory.c
--- a/mm/huge_memory.c~thp-mremap-support-and-tlb-optimization-fix
+++ a/mm/huge_memory.c
@@ -1065,15 +1065,14 @@ int move_huge_pmd(struct vm_area_struct 
 	if ((old_addr & ~HPAGE_PMD_MASK) ||
 	    (new_addr & ~HPAGE_PMD_MASK) ||
 	    (old_addr + HPAGE_PMD_SIZE) > old_end ||
-	    new_vma->vm_flags & VM_NOHUGEPAGE)
+	    (new_vma->vm_flags & VM_NOHUGEPAGE))
 		goto out;
 
 	/*
 	 * The destination pmd shouldn't be established, free_pgtables()
 	 * should have release it.
 	 */
-	if (!pmd_none(*new_pmd)) {
-		WARN_ON(1);
+	if (!WARN_ON(pmd_none(*new_pmd))) {
 		VM_BUG_ON(pmd_trans_huge(*new_pmd));
 		goto out;
 	}
@@ -1091,9 +1090,9 @@ int move_huge_pmd(struct vm_area_struct 
 			spin_unlock(&mm->page_table_lock);
 			ret = 1;
 		}
-	} else
+	} else {
 		spin_unlock(&mm->page_table_lock);
-
+	}
 out:
 	return ret;
 }
--- a/mm/mremap.c~thp-mremap-support-and-tlb-optimization-fix
+++ a/mm/mremap.c
@@ -155,13 +155,13 @@ unsigned long move_page_tables(struct vm
 			if (err > 0) {
 				need_flush = true;
 				continue;
-			} else if (!err)
+			} else if (!err) {
 				split_huge_page_pmd(vma->vm_mm, old_pmd);
+			}
 			VM_BUG_ON(pmd_trans_huge(*old_pmd));
 		}
 		if (pmd_none(*new_pmd) && __pte_alloc(new_vma->vm_mm, new_vma,
-						      new_pmd,
-						      new_addr))
+						      new_pmd, new_addr))
 			break;
 		next = (new_addr + PMD_SIZE) & PMD_MASK;
 		if (extent > next - new_addr)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
