Date: Wed, 28 May 2008 19:38:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] hugetlb: fix lockdep error
Message-Id: <20080528193808.6e053dac.akpm@linux-foundation.org>
In-Reply-To: <20080529022919.GD3258@wotan.suse.de>
References: <20080529015956.GC3258@wotan.suse.de>
	<20080528191657.ba5f283c.akpm@linux-foundation.org>
	<20080529022919.GD3258@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: agl@us.ibm.com, nacc@us.ibm.com, Linux Memory Management List <linux-mm@kvack.org>, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 29 May 2008 04:29:19 +0200 Nick Piggin <npiggin@suse.de> wrote:

> Hi Andrew,
> 
> Can you merge this up please? It is helpful in testing to avoid lockdep
> tripping over. I have it at the start of the multiple hugepage size
> patchset, but it doesn't strictly belong there...
> 
> --
> hugetlb: fix lockdep error
> 
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Adam Litke <agl@us.ibm.com>
> Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Please prefer to quote the warning/error message/trace/etc when fixing it.

>  mm/hugetlb.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.orig/mm/hugetlb.c
> +++ linux-2.6/mm/hugetlb.c
> @@ -785,7 +785,7 @@ int copy_hugetlb_page_range(struct mm_st
>  			continue;
>  
>  		spin_lock(&dst->page_table_lock);
> -		spin_lock(&src->page_table_lock);
> +		spin_lock_nested(&src->page_table_lock, SINGLE_DEPTH_NESTING);
>  		if (!huge_pte_none(huge_ptep_get(src_pte))) {
>  			if (cow)
>  				huge_ptep_set_wrprotect(src, addr, src_pte);

Confused.  This code has been there since October 2005.  Why are we
only seeing lockdep warnings now?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
