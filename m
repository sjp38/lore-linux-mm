Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 67222900001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 03:59:21 -0400 (EDT)
Date: Tue, 26 Apr 2011 09:59:18 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH followup] mm: get rid of CONFIG_STACK_GROWSUP ||
 CONFIG_IA64
Message-ID: <20110426075918.GD25857@tiehlicka.suse.cz>
References: <20110415135144.GE8828@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1104171952040.22679@sister.anvils>
 <20110418100131.GD8925@tiehlicka.suse.cz>
 <20110418135637.5baac204.akpm@linux-foundation.org>
 <20110419091022.GA21689@tiehlicka.suse.cz>
 <20110419110956.GD21689@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110419110956.GD21689@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Andrew,
this one probably got lost in the follow up "parisc doesn't boot" email
storm.

On Tue 19-04-11 13:09:56, Michal Hocko wrote:
> While I am in the cleanup mode. We should use VM_GROWSUP rather than
> tricky CONFIG_STACK_GROWSUP||CONFIG_IA64.
> 
> What do you think?
> --- 
> From fd832dd46b4918718901f2ebe994f4662f167999 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Tue, 19 Apr 2011 11:11:41 +0200
> Subject: [PATCH] mm: get rid of CONFIG_STACK_GROWSUP || CONFIG_IA64
> 
> IA64 needs some trickery for Register Backing Store so we have to
> export expand_stack_upwards for it even though the architecture expands
> its stack downwards normally. To avoid
> we have defined VM_GROWSUP which is defined only for the above
> configuration.
> 
> We still have places which use the original ifdefs so let's get rid of
> them finally.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/mmap.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 29c68b0..3ff9edf 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1726,7 +1726,7 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
>  	return 0;
>  }
>  
> -#if defined(CONFIG_STACK_GROWSUP) || defined(CONFIG_IA64)
> +#if VM_GROWSUP
>  /*
>   * PA-RISC uses this for its stack; IA64 for its Register Backing Store.
>   * vma is the last one with address > vma->vm_end.  Have to extend vma.
> @@ -1777,7 +1777,7 @@ int expand_stack_upwards(struct vm_area_struct *vma, unsigned long address)
>  	khugepaged_enter_vma_merge(vma);
>  	return error;
>  }
> -#endif /* CONFIG_STACK_GROWSUP || CONFIG_IA64 */
> +#endif /* VM_GROWSUP */
>  
>  /*
>   * vma is the first one with address < vma->vm_start.  Have to extend vma.

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
