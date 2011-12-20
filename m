Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 479496B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 09:14:41 -0500 (EST)
Date: Tue, 20 Dec 2011 15:14:37 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: hugetlb: fix pgoff computation when unmapping page
 from vma
Message-ID: <20111220141437.GJ10565@tiehlicka.suse.cz>
References: <CAJd=RBDC9hxAFbbTvSWVa=t1kuyBH8=UoTYxRDtDm6iXLGkQWg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBDC9hxAFbbTvSWVa=t1kuyBH8=UoTYxRDtDm6iXLGkQWg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

[CCing Mel]

On Tue 20-12-11 21:45:51, Hillf Danton wrote:
> The computation for pgoff is incorrect, at least with
> 
> 	(vma->vm_pgoff >> PAGE_SHIFT)
> 
> involved. It is fixed with the available method if HPAGE_SIZE is concerned in
> page cache lookup.

Have you seen this as a real issue? I guess nobody noticed as it is
quite rare error case.
Anyways, yes, looks good. 

> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Hillf Danton <dhillf@gmail.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
> 
> --- a/mm/hugetlb.c	Tue Dec 20 21:26:30 2011
> +++ b/mm/hugetlb.c	Tue Dec 20 21:40:44 2011
> @@ -2315,8 +2315,7 @@ static int unmap_ref_private(struct mm_s
>  	 * from page cache lookup which is in HPAGE_SIZE units.
>  	 */
>  	address = address & huge_page_mask(h);
> -	pgoff = ((address - vma->vm_start) >> PAGE_SHIFT)
> -		+ (vma->vm_pgoff >> PAGE_SHIFT);
> +	pgoff = linear_hugepage_index(vma, address);

You have hstate so you can use vma_hugecache_offset directly

>  	mapping = (struct address_space *)page_private(page);
> 
>  	/*
> 

Thanks
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
