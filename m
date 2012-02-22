Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id E380E6B004A
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 03:18:09 -0500 (EST)
Received: by dadv6 with SMTP id v6so9616854dad.14
        for <linux-mm@kvack.org>; Wed, 22 Feb 2012 00:18:09 -0800 (PST)
Date: Wed, 22 Feb 2012 00:17:38 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: hugetlb: break COW earlier for resv owner
In-Reply-To: <CAJd=RBBY8yzH6wk7GFttvukLq0Pxzw_ExCO+F5N5ChQwk1Q94A@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1202212350070.3944@eggly.anvils>
References: <CAJd=RBBY8yzH6wk7GFttvukLq0Pxzw_ExCO+F5N5ChQwk1Q94A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

On Sat, 18 Feb 2012, Hillf Danton wrote:
> When a process owning a MAP_PRIVATE mapping fails to COW, due to references
> held by a child and insufficient huge page pool, page is unmapped from the
> child process to guarantee the original mappers reliability, and the child
> may get SIGKILLed if it later faults.

I think I understand you there.

> 
> With that guarantee, COW is broken earlier on behalf of owners, and they will
> go less page faults.

As usual, I have to guess that here you're describing what (you think)
happens after your patch.

But I don't understand, or it doesn't seem to describe what happens in
your patch.  "COW is broken" only in the sense that you are breaking
the way COW is supposed to behave, and I believe your patch is wrong.

> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
> 
> --- a/mm/hugetlb.c	Tue Feb 14 20:10:46 2012
> +++ b/mm/hugetlb.c	Sat Feb 18 13:29:58 2012
> @@ -2145,10 +2145,12 @@ int copy_hugetlb_page_range(struct mm_st
>  	struct page *ptepage;
>  	unsigned long addr;
>  	int cow;
> +	int owner;
>  	struct hstate *h = hstate_vma(vma);
>  	unsigned long sz = huge_page_size(h);
> 
>  	cow = (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
> +	owner = is_vma_resv_set(vma, HPAGE_RESV_OWNER);
> 
>  	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
>  		src_pte = huge_pte_offset(src, addr);
> @@ -2164,10 +2166,19 @@ int copy_hugetlb_page_range(struct mm_st
> 
>  		spin_lock(&dst->page_table_lock);
>  		spin_lock_nested(&src->page_table_lock, SINGLE_DEPTH_NESTING);
> -		if (!huge_pte_none(huge_ptep_get(src_pte))) {
> +		entry = huge_ptep_get(src_pte);
> +		if (!huge_pte_none(entry)) {
>  			if (cow)
> -				huge_ptep_set_wrprotect(src, addr, src_pte);
> -			entry = huge_ptep_get(src_pte);
> +				if (owner) {
> +					/*
> +					 * Break COW for resv owner to go less
> +					 * page faults later
> +					 */
> +					entry = huge_pte_wrprotect(entry);

So, the change you are making is that if the vma being copied (and I had
to check with dup_mmap() to see that vma here is indeed the src vma) is
the original "owner", then its pte is left (perhaps) writable, and only
the child's is write-protected.

But that means that modifications made to this page by the parent after
the fork will still be visible to the child, until such time as the child
writes to this area, if ever.

That is not how COW protection behaves for a normal page: it's symmetric,
neither parent nor child sees modifications made by the other after fork.

Now, hugetlb pages are not normal in all kinds of ways, but here you
appear to be changing the semantics of private hugetlb mappings, in
a way that could break applications, and has security implications.

Or am I misunderstanding?

Hugh

> +				} else {
> +					huge_ptep_set_wrprotect(src, addr, src_pte);
> +					entry = huge_ptep_get(src_pte);
> +				}
>  			ptepage = pte_page(entry);
>  			get_page(ptepage);
>  			page_dup_rmap(ptepage);
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
