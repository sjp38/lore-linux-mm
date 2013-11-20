Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1551E6B0031
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 19:26:18 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so3291247pde.28
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 16:26:17 -0800 (PST)
Received: from psmtp.com ([74.125.245.107])
        by mx.google.com with SMTP id sg3si12774407pbb.283.2013.11.19.16.26.16
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 16:26:16 -0800 (PST)
Date: Wed, 20 Nov 2013 01:26:00 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/3] mm: hugetlbfs: fix hugetlbfs optimization
Message-ID: <20131120002600.GF10493@redhat.com>
References: <1384537668-10283-1-git-send-email-aarcange@redhat.com>
 <1384537668-10283-2-git-send-email-aarcange@redhat.com>
 <20131119151146.a1e1f9073a0e5d35c4e83bab@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131119151146.a1e1f9073a0e5d35c4e83bab@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Pravin Shelar <pshelar@nicira.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ben Hutchings <bhutchings@solarflare.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Nov 19, 2013 at 03:11:46PM -0800, Andrew Morton wrote:
> This is all rather verbose.  How about we do this?
> 
> --- a/mm/hugetlb.c~mm-hugetlbc-simplify-pageheadhuge-and-pagehuge
> +++ a/mm/hugetlb.c
> @@ -690,15 +690,11 @@ static void prep_compound_gigantic_page(
>   */
>  int PageHuge(struct page *page)
>  {
> -	compound_page_dtor *dtor;
> -
>  	if (!PageCompound(page))
>  		return 0;
>  
>  	page = compound_head(page);
> -	dtor = get_compound_page_dtor(page);
> -
> -	return dtor == free_huge_page;
> +	return get_compound_page_dtor(page) == free_huge_page;
>  }
>  EXPORT_SYMBOL_GPL(PageHuge);
>  
> @@ -708,14 +704,10 @@ EXPORT_SYMBOL_GPL(PageHuge);
>   */
>  int PageHeadHuge(struct page *page_head)
>  {
> -	compound_page_dtor *dtor;
> -
>  	if (!PageHead(page_head))
>  		return 0;
>  
> -	dtor = get_compound_page_dtor(page_head);
> -
> -	return dtor == free_huge_page;
> +	return get_compound_page_dtor(page_head) == free_huge_page;
>  }
>  EXPORT_SYMBOL_GPL(PageHeadHuge);

Sure good idea!

> > @@ -82,19 +82,6 @@ static void __put_compound_page(struct page *page)
> >  
> >  static void put_compound_page(struct page *page)
> 
> This function has become quite crazy.  I sat down to refamiliarize but
> immediately failed.
> 
> : static void put_compound_page(struct page *page)
> : {
> : 	if (unlikely(PageTail(page))) {
> :	...
> : 	} else if (put_page_testzero(page)) {
> : 		if (PageHead(page))
> 
> How can a page be both PageTail() and PageHead()?

We execute the PageHead you quoted only if it's !PageTail. So then
PageHead tells us if if it's compound head or not compound by the time
all reference counts have been released (by the time the last
reference is released it can't be splitted anymore).

> 
> : 			__put_compound_page(page);
> : 		else
> : 			__put_single_page(page);
> : 	}
> : }
> : 
> : 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
