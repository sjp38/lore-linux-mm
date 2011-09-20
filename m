Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 534FF9000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 03:14:15 -0400 (EDT)
Date: Tue, 20 Sep 2011 09:14:08 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/1] Trivial: Eliminate the ret variable from
 mm_take_all_locks
Message-ID: <20110920071408.GB26791@tiehlicka.suse.cz>
References: <1315909531-13419-1-git-send-email-consul.kautuk@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1315909531-13419-1-git-send-email-consul.kautuk@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Shaohua Li <shaohua.li@intel.com>, Jiri Kosina <trivial@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 13-09-11 15:55:31, Kautuk Consul wrote:
> The ret variable is really not needed in mm_take_all_locks as per
> the current flow of the mm_take_all_locks function.
> 
> So, eliminating this return variable.
> 
> Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>

The compiled code seems to be very same - compilers are clever enough to
reorganize the code but anyway the code reads better this way.

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/mmap.c |    8 +++-----
>  1 files changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index a65efd4..48bc056 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2558,7 +2558,6 @@ int mm_take_all_locks(struct mm_struct *mm)
>  {
>  	struct vm_area_struct *vma;
>  	struct anon_vma_chain *avc;
> -	int ret = -EINTR;
>  
>  	BUG_ON(down_read_trylock(&mm->mmap_sem));
>  
> @@ -2579,13 +2578,12 @@ int mm_take_all_locks(struct mm_struct *mm)
>  				vm_lock_anon_vma(mm, avc->anon_vma);
>  	}
>  
> -	ret = 0;
> +	return 0;
>  
>  out_unlock:
> -	if (ret)
> -		mm_drop_all_locks(mm);
> +	mm_drop_all_locks(mm);
>  
> -	return ret;
> +	return -EINTR;
>  }
>  
>  static void vm_unlock_anon_vma(struct anon_vma *anon_vma)
> -- 
> 1.7.6
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
