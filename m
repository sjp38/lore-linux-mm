Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A43556B00E7
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 20:57:46 -0500 (EST)
Date: Tue, 11 Jan 2011 02:57:42 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH mmotm] thp: transparent hugepage core fixlet
Message-ID: <20110111015742.GL9506@random.random>
References: <alpine.LSU.2.00.1101101652200.11559@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1101101652200.11559@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hugh,

On Mon, Jan 10, 2011 at 04:55:53PM -0800, Hugh Dickins wrote:
> If you configure THP in addition to HUGETLB_PAGE on x86_32 without PAE,
> the p?d-folding works out that munlock_vma_pages_range() can crash to
> follow_page()'s pud_huge() BUG_ON(flags & FOLL_GET): it needs the same
> VM_HUGETLB check already there on the pmd_huge() line.  Conveniently,
> openSUSE provides a "blogd" which tests this out at startup!
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> This massive rework belongs just after thp-transparent-hugepage-core.patch
> 
>  mm/memory.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- mmotm.orig/mm/memory.c	2011-01-10 16:31:29.000000000 -0800
> +++ mmotm/mm/memory.c	2011-01-10 16:33:16.000000000 -0800
> @@ -1288,7 +1288,7 @@ struct page *follow_page(struct vm_area_
>  	pud = pud_offset(pgd, address);
>  	if (pud_none(*pud))
>  		goto no_page_table;
> -	if (pud_huge(*pud)) {
> +	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
>  		BUG_ON(flags & FOLL_GET);
>  		page = follow_huge_pud(mm, address, pud, flags & FOLL_WRITE);
>  		goto out;

How is THP related to this? pud_trans_huge doesn't exist, if pud_huge
is true, vma is already guaranteed to belong to hugetlbfs without
requiring the additional check.

I added the check to pmd_huge already, there it is needed, but for
pud_huge it isn't as far as I can tell.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
