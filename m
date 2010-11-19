Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A7D426B008A
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 03:23:28 -0500 (EST)
Date: Fri, 19 Nov 2010 17:15:58 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm: remove call to find_vma in pagewalk for non-hugetlbfs
Message-ID: <20101119081558.GA11081@spritzera.linux.bs1.fc.nec.co.jp>
References: <1290127197-20360-1-git-send-email-dsterba@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <1290127197-20360-1-git-send-email-dsterba@suse.cz>
Sender: owner-linux-mm@kvack.org
To: David Sterba <dsterba@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Andy Whitcroft <apw@canonical.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 19, 2010 at 01:39:57AM +0100, David Sterba wrote:
> Commit d33b9f45 introduces a check if a vma is a hugetlbfs one and
> later in 5dc37642 is moved under #ifdef CONFIG_HUGETLB_PAGE but
> a needless find_vma call is left behind and it's result not used
> anywhere else in the function.
> 
> The sideefect of caching vma for @addr inside walk->mm is neither
> utilized in walk_page_range() nor in called functions.
> 
> Signed-off-by: David Sterba <dsterba@suse.cz>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Andi Kleen <ak@linux.intel.com>
> Cc: Andy Whitcroft <apw@canonical.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/pagewalk.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
> index 8b1a2ce..38cc58b 100644
> --- a/mm/pagewalk.c
> +++ b/mm/pagewalk.c
> @@ -139,7 +139,6 @@ int walk_page_range(unsigned long addr, unsigned long end,
>  	pgd_t *pgd;
>  	unsigned long next;
>  	int err = 0;
> -	struct vm_area_struct *vma;
>  
>  	if (addr >= end)
>  		return err;
> @@ -149,15 +148,17 @@ int walk_page_range(unsigned long addr, unsigned long end,
>  
>  	pgd = pgd_offset(walk->mm, addr);
>  	do {
> +		struct vm_area_struct *uninitialized_var(vma);
> +
>  		next = pgd_addr_end(addr, end);
>  
> +#ifdef CONFIG_HUGETLB_PAGE
>  		/*
>  		 * handle hugetlb vma individually because pagetable walk for
>  		 * the hugetlb page is dependent on the architecture and
>  		 * we can't handled it in the same manner as non-huge pages.
>  		 */
>  		vma = find_vma(walk->mm, addr);
> -#ifdef CONFIG_HUGETLB_PAGE
>  		if (vma && is_vm_hugetlb_page(vma)) {
>  			if (vma->vm_end < next)
>  				next = vma->vm_end;

Looks good to me.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
