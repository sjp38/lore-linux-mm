Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 646176B004A
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 16:07:01 -0500 (EST)
Date: Wed, 22 Feb 2012 13:06:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: hugetlb: bail out unmapping after serving reference
 page
Message-Id: <20120222130659.d75b6f69.akpm@linux-foundation.org>
In-Reply-To: <CAJd=RBALNtedfq+PLPnGKd4i4D0mLiVPdW_7pWWopnSZNC_vqA@mail.gmail.com>
References: <CAJd=RBALNtedfq+PLPnGKd4i4D0mLiVPdW_7pWWopnSZNC_vqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>

On Wed, 22 Feb 2012 20:35:34 +0800
Hillf Danton <dhillf@gmail.com> wrote:

> When unmapping given VM range, we could bail out if a reference page is
> supplied and it is unmapped, which is a minor optimization.
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
> 
> --- a/mm/hugetlb.c	Wed Feb 22 19:34:12 2012
> +++ b/mm/hugetlb.c	Wed Feb 22 19:50:26 2012
> @@ -2280,6 +2280,9 @@ void __unmap_hugepage_range(struct vm_ar
>  		if (pte_dirty(pte))
>  			set_page_dirty(page);
>  		list_add(&page->lru, &page_list);
> +
> +		if (page == ref_page)
> +			break;
>  	}
>  	spin_unlock(&mm->page_table_lock);
>  	flush_tlb_range(vma, start, end);

Perhaps add a little comment to this explaining what's going on?


It would be sufficient to do

	if (ref_page)
		break;

This is more efficient, and doesn't make people worry about whether
this value of `page' is the same as the one which
pte_page(huge_ptep_get()) earlier returned.

Why do we evaluate `page' twice inside that loop anyway?  And why do we
check for huge_pte_none() twice?  It looks all messed up.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
