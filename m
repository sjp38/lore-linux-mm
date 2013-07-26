Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 940FE6B0031
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 09:07:23 -0400 (EDT)
Date: Fri, 26 Jul 2013 15:07:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/6] arch: mm: do not invoke OOM killer on kernel fault
 OOM
Message-ID: <20130726130721.GD17761@dhcp22.suse.cz>
References: <1374791138-15665-1-git-send-email-hannes@cmpxchg.org>
 <1374791138-15665-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374791138-15665-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 25-07-13 18:25:34, Johannes Weiner wrote:
> Kernel faults are expected to handle OOM conditions gracefully (gup,
> uaccess etc.), so they should never invoke the OOM killer.  Reserve
> this for faults triggered in user context when it is the only option.
> 
> Most architectures already do this, fix up the remaining few.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

I didn't go over all architectures to check whether something slipped
through but the converted ones look OK to me.

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  arch/arm/mm/fault.c       | 14 +++++++-------
>  arch/arm64/mm/fault.c     | 14 +++++++-------
>  arch/avr32/mm/fault.c     |  2 +-
>  arch/mips/mm/fault.c      |  2 ++
>  arch/um/kernel/trap.c     |  2 ++
>  arch/unicore32/mm/fault.c | 14 +++++++-------
>  6 files changed, 26 insertions(+), 22 deletions(-)
> 
> diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
> index c97f794..217bcbf 100644
> --- a/arch/arm/mm/fault.c
> +++ b/arch/arm/mm/fault.c
> @@ -349,6 +349,13 @@ retry:
>  	if (likely(!(fault & (VM_FAULT_ERROR | VM_FAULT_BADMAP | VM_FAULT_BADACCESS))))
>  		return 0;
>  
> +	/*
> +	 * If we are in kernel mode at this point, we
> +	 * have no context to handle this fault with.
> +	 */
> +	if (!user_mode(regs))
> +		goto no_context;
> +
>  	if (fault & VM_FAULT_OOM) {
>  		/*
>  		 * We ran out of memory, call the OOM killer, and return to
> @@ -359,13 +366,6 @@ retry:
>  		return 0;
>  	}
>  
> -	/*
> -	 * If we are in kernel mode at this point, we
> -	 * have no context to handle this fault with.
> -	 */
> -	if (!user_mode(regs))
> -		goto no_context;
> -
>  	if (fault & VM_FAULT_SIGBUS) {
>  		/*
>  		 * We had some memory, but were unable to
> diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
> index 0ecac89..dab1cfd 100644
> --- a/arch/arm64/mm/fault.c
> +++ b/arch/arm64/mm/fault.c
> @@ -294,6 +294,13 @@ retry:
>  			      VM_FAULT_BADACCESS))))
>  		return 0;
>  
> +	/*
> +	 * If we are in kernel mode at this point, we have no context to
> +	 * handle this fault with.
> +	 */
> +	if (!user_mode(regs))
> +		goto no_context;
> +
>  	if (fault & VM_FAULT_OOM) {
>  		/*
>  		 * We ran out of memory, call the OOM killer, and return to
> @@ -304,13 +311,6 @@ retry:
>  		return 0;
>  	}
>  
> -	/*
> -	 * If we are in kernel mode at this point, we have no context to
> -	 * handle this fault with.
> -	 */
> -	if (!user_mode(regs))
> -		goto no_context;
> -
>  	if (fault & VM_FAULT_SIGBUS) {
>  		/*
>  		 * We had some memory, but were unable to successfully fix up
> diff --git a/arch/avr32/mm/fault.c b/arch/avr32/mm/fault.c
> index b2f2d2d..2ca27b0 100644
> --- a/arch/avr32/mm/fault.c
> +++ b/arch/avr32/mm/fault.c
> @@ -228,9 +228,9 @@ no_context:
>  	 */
>  out_of_memory:
>  	up_read(&mm->mmap_sem);
> -	pagefault_out_of_memory();
>  	if (!user_mode(regs))
>  		goto no_context;
> +	pagefault_out_of_memory();
>  	return;
>  
>  do_sigbus:
> diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
> index 85df1cd..94d3a31 100644
> --- a/arch/mips/mm/fault.c
> +++ b/arch/mips/mm/fault.c
> @@ -241,6 +241,8 @@ out_of_memory:
>  	 * (which will retry the fault, or kill us if we got oom-killed).
>  	 */
>  	up_read(&mm->mmap_sem);
> +	if (!user_mode(regs))
> +		goto no_context;
>  	pagefault_out_of_memory();
>  	return;
>  
> diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
> index 089f398..b2f5adf 100644
> --- a/arch/um/kernel/trap.c
> +++ b/arch/um/kernel/trap.c
> @@ -124,6 +124,8 @@ out_of_memory:
>  	 * (which will retry the fault, or kill us if we got oom-killed).
>  	 */
>  	up_read(&mm->mmap_sem);
> +	if (!is_user)
> +		goto out_nosemaphore;
>  	pagefault_out_of_memory();
>  	return 0;
>  }
> diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
> index f9b5c10..8ed3c45 100644
> --- a/arch/unicore32/mm/fault.c
> +++ b/arch/unicore32/mm/fault.c
> @@ -278,6 +278,13 @@ retry:
>  	       (VM_FAULT_ERROR | VM_FAULT_BADMAP | VM_FAULT_BADACCESS))))
>  		return 0;
>  
> +	/*
> +	 * If we are in kernel mode at this point, we
> +	 * have no context to handle this fault with.
> +	 */
> +	if (!user_mode(regs))
> +		goto no_context;
> +
>  	if (fault & VM_FAULT_OOM) {
>  		/*
>  		 * We ran out of memory, call the OOM killer, and return to
> @@ -288,13 +295,6 @@ retry:
>  		return 0;
>  	}
>  
> -	/*
> -	 * If we are in kernel mode at this point, we
> -	 * have no context to handle this fault with.
> -	 */
> -	if (!user_mode(regs))
> -		goto no_context;
> -
>  	if (fault & VM_FAULT_SIGBUS) {
>  		/*
>  		 * We had some memory, but were unable to
> -- 
> 1.8.3.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
