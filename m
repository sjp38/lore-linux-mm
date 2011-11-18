Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E112C6B006E
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 10:07:47 -0500 (EST)
Date: Fri, 18 Nov 2011 16:07:42 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] hugetlb: detect race if fail to COW
Message-ID: <20111118150742.GA23223@tiehlicka.suse.cz>
References: <CAJd=RBC+p8033bHNfP=WQ2SU1Y1zRpj+FEi9FdjuFKkjF_=_iA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBC+p8033bHNfP=WQ2SU1Y1zRpj+FEi9FdjuFKkjF_=_iA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 18-11-11 22:04:37, Hillf Danton wrote:
> In the error path that we fail to allocate new huge page, before try again, we
> have to check race since page_table_lock is re-acquired.

I do not think we can race here because we are serialized by
hugetlb_instantiation_mutex AFAIU. Without this lock, however, we could
fall into avoidcopy and shortcut despite the fact that other thread has
already did the job.

The mutex usage is not obvious in hugetlb_cow so maybe we want to be
explicit about it (either a comment or do the recheck).

> 
> If racing, our job is done.
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
> 
> --- a/mm/hugetlb.c	Fri Nov 18 21:38:30 2011
> +++ b/mm/hugetlb.c	Fri Nov 18 21:48:15 2011
> @@ -2407,7 +2407,14 @@ retry_avoidcopy:
>  				BUG_ON(page_count(old_page) != 1);
>  				BUG_ON(huge_pte_none(pte));
>  				spin_lock(&mm->page_table_lock);
> -				goto retry_avoidcopy;
> +				ptep = huge_pte_offset(mm, address & huge_page_mask(h));
> +				if (likely(pte_same(huge_ptep_get(ptep), pte)))
> +					goto retry_avoidcopy;
> +				/*
> +				 * race occurs while re-acquiring page_table_lock, and
> +				 * our job is done.
> +				 */
> +				return 0;
>  			}
>  			WARN_ON_ONCE(1);
>  		}
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
