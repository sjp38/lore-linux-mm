Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 6040E6B00AB
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 18:18:46 -0400 (EDT)
Date: Wed, 12 Sep 2012 15:18:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] thp: move release mmap_sem lock out of
 khugepaged_alloc_page
Message-Id: <20120912151844.a2f17f98.akpm@linux-foundation.org>
In-Reply-To: <50508689.50904@linux.vnet.ibm.com>
References: <50508632.9090003@linux.vnet.ibm.com>
	<50508689.50904@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Hugh Dickins <hughd@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 12 Sep 2012 20:56:41 +0800
Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com> wrote:

> To make the code more clear, move release the lock out of khugepaged_alloc_page
> 
> ...
>
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1854,11 +1854,6 @@ static struct page
>  	*hpage  = alloc_hugepage_vma(khugepaged_defrag(), vma, address,
>  				      node, __GFP_OTHER_NODE);
> 
> -	/*
> -	 * After allocating the hugepage, release the mmap_sem read lock in
> -	 * preparation for taking it in write mode.
> -	 */
> -	up_read(&mm->mmap_sem);
>  	if (unlikely(!*hpage)) {
>  		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
>  		*hpage = ERR_PTR(-ENOMEM);
> @@ -1905,7 +1900,6 @@ static struct page
>  		       struct vm_area_struct *vma, unsigned long address,
>  		       int node)
>  {
> -	up_read(&mm->mmap_sem);
>  	VM_BUG_ON(!*hpage);
>  	return  *hpage;
>  }
> @@ -1931,8 +1925,14 @@ static void collapse_huge_page(struct mm_struct *mm,
> 
>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> 
> -	/* release the mmap_sem read lock. */
>  	new_page = khugepaged_alloc_page(hpage, mm, vma, address, node);
> +
> +	/*
> +	 * After allocating the hugepage, release the mmap_sem read lock in
> +	 * preparation for taking it in write mode.
> +	 */
> +	up_read(&mm->mmap_sem);
> +
>  	if (!new_page)
>  		return;

Well that's a pretty minor improvement: one still has to go off on a
big hunt to locate the matching down_read().

And the patch will increase mmap_sem hold times by a teeny amount.  Do
we really want to do this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
