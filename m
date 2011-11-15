Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A491C6B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 10:38:57 -0500 (EST)
Date: Tue, 15 Nov 2011 16:38:51 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] hugetlb: release pages in the error path of hugetlb_cow()
Message-ID: <20111115153851.GB7551@tiehlicka.suse.cz>
References: <CAJd=RBC5Q48r0sYeqF9bucaBJPv3LR4UTAannUZ8KXxoXY_Qcw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBC5Q48r0sYeqF9bucaBJPv3LR4UTAannUZ8KXxoXY_Qcw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri 11-11-11 21:01:20, Hillf Danton wrote:
> If fail to prepare anon_vma, {new, old}_page should be released, or they will
> escape the track and/or control of memory management.

Looks good (intrduced by in .36 by 0fe6e20b: hugetlb, rmap: add reverse
mapping for hugepage). The failure case is really not probable but I
guess this is still a candidate for stable kernel.

> 
> Thanks
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
> 
> --- a/mm/hugetlb.c	Fri Nov 11 20:36:32 2011
> +++ b/mm/hugetlb.c	Fri Nov 11 20:43:06 2011
> @@ -2422,6 +2422,8 @@ retry_avoidcopy:
>  	 * anon_vma prepared.
>  	 */
>  	if (unlikely(anon_vma_prepare(vma))) {
> +		page_cache_release(new_page);
> +		page_cache_release(old_page);
>  		/* Caller expects lock to be held */
>  		spin_lock(&mm->page_table_lock);
>  		return VM_FAULT_OOM;
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

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
