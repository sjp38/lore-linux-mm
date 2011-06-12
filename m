Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 600BC6B0012
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 06:32:26 -0400 (EDT)
Date: Sun, 12 Jun 2011 12:32:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: thp: minor lock simplification in __khugepaged_exit
Message-ID: <20110612103214.GB19493@tiehlicka.suse.cz>
References: <20110610233355.GO23047@sequoia.sous-sol.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110610233355.GO23047@sequoia.sous-sol.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wright <chrisw@sous-sol.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 10-06-11 16:33:55, Chris Wright wrote:
> The lock is released first thing in all three branches.  Simplify this
> by unconditionally releasing lock and remove else clause which was only
> there to be sure lock was released.
> 
> Signed-off-by: Chris Wright <chrisw@sous-sol.org>

Nice cleanup.
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/huge_memory.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 615d974..a032ddd 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1596,14 +1596,13 @@ void __khugepaged_exit(struct mm_struct *mm)
>  		list_del(&mm_slot->mm_node);
>  		free = 1;
>  	}
> +	spin_unlock(&khugepaged_mm_lock);
>  
>  	if (free) {
> -		spin_unlock(&khugepaged_mm_lock);
>  		clear_bit(MMF_VM_HUGEPAGE, &mm->flags);
>  		free_mm_slot(mm_slot);
>  		mmdrop(mm);
>  	} else if (mm_slot) {
> -		spin_unlock(&khugepaged_mm_lock);
>  		/*
>  		 * This is required to serialize against
>  		 * khugepaged_test_exit() (which is guaranteed to run
> @@ -1614,8 +1613,7 @@ void __khugepaged_exit(struct mm_struct *mm)
>  		 */
>  		down_write(&mm->mmap_sem);
>  		up_write(&mm->mmap_sem);
> -	} else
> -		spin_unlock(&khugepaged_mm_lock);
> +	}
>  }
>  
>  static void release_pte_page(struct page *page)
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
