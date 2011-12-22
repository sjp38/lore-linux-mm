Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id BFC756B005A
	for <linux-mm@kvack.org>; Thu, 22 Dec 2011 11:36:07 -0500 (EST)
Date: Thu, 22 Dec 2011 17:36:04 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: hugetlb: undo change to page mapcount in fault
 handler
Message-ID: <20111222163604.GB14983@tiehlicka.suse.cz>
References: <CAJd=RBBF=K5hHvEwb6uwZJwS4=jHKBCNYBTJq-pSbJ9j_ZaiaA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBBF=K5hHvEwb6uwZJwS4=jHKBCNYBTJq-pSbJ9j_ZaiaA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu 22-12-11 21:36:34, Hillf Danton wrote:
> Page mapcount is changed only when it is folded into page table entry.

The changelog is rather cryptic. What about something like:

Page mapcount should be updated only if we are sure that the page ends
up in the page table otherwise we would leak if we couldn't COW due to
reservations or if idx is out of bounds.

The patch itself looks correct.

> 
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Hillf Danton <dhillf@gmail.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

Thanks
> ---
> 
> --- a/mm/hugetlb.c	Tue Dec 20 21:26:30 2011
> +++ b/mm/hugetlb.c	Thu Dec 22 21:29:42 2011
> @@ -2509,6 +2509,7 @@ static int hugetlb_no_page(struct mm_str
>  {
>  	struct hstate *h = hstate_vma(vma);
>  	int ret = VM_FAULT_SIGBUS;
> +	int anon_rmap = 0;
>  	pgoff_t idx;
>  	unsigned long size;
>  	struct page *page;
> @@ -2563,14 +2564,13 @@ retry:
>  			spin_lock(&inode->i_lock);
>  			inode->i_blocks += blocks_per_huge_page(h);
>  			spin_unlock(&inode->i_lock);
> -			page_dup_rmap(page);
>  		} else {
>  			lock_page(page);
>  			if (unlikely(anon_vma_prepare(vma))) {
>  				ret = VM_FAULT_OOM;
>  				goto backout_unlocked;
>  			}
> -			hugepage_add_new_anon_rmap(page, vma, address);
> +			anon_rmap = 1;
>  		}
>  	} else {
>  		/*
> @@ -2583,7 +2583,6 @@ retry:
>  			      VM_FAULT_SET_HINDEX(h - hstates);
>  			goto backout_unlocked;
>  		}
> -		page_dup_rmap(page);
>  	}
> 
>  	/*
> @@ -2607,6 +2606,10 @@ retry:
>  	if (!huge_pte_none(huge_ptep_get(ptep)))
>  		goto backout;
> 
> +	if (anon_rmap)
> +		hugepage_add_new_anon_rmap(page, vma, address);
> +	else
> +		page_dup_rmap(page);
>  	new_pte = make_huge_pte(vma, page, ((vma->vm_flags & VM_WRITE)
>  				&& (vma->vm_flags & VM_SHARED)));
>  	set_huge_pte_at(mm, address, ptep, new_pte);

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
