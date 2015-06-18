Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8854E6B007D
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 15:21:25 -0400 (EDT)
Received: by igboe5 with SMTP id oe5so26631514igb.1
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 12:21:25 -0700 (PDT)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id i80si6810491ioi.31.2015.06.18.12.21.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jun 2015 12:21:24 -0700 (PDT)
Received: by igbzc4 with SMTP id zc4so2624572igb.0
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 12:21:24 -0700 (PDT)
Date: Thu, 18 Jun 2015 12:21:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] oom: Do not panic when OOM killer is sysrq
 triggered
In-Reply-To: <1434621447-21175-2-git-send-email-mhocko@suse.cz>
Message-ID: <alpine.DEB.2.10.1506181213400.3668@chino.kir.corp.google.com>
References: <1434621447-21175-1-git-send-email-mhocko@suse.cz> <1434621447-21175-2-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 18 Jun 2015, Michal Hocko wrote:

> OOM killer might be triggered externally via sysrq+f. This is supposed

I'm not sure what you mean by externally?  Perhaps "explicitly"?

> to kill a task no matter what e.g. a task is selected even though there
> is an OOM victim on the way to exit. This is a big hammer for an admin
> to help to resolve a memory short condition when the system is not able
> to cope with it on its own in a reasonable time frame (e.g. when the
> system is trashing or the OOM killer cannot make sufficient progress)
> 
> E.g. it doesn't make any sense to obey panic_on_oom setting because
> a) administrator could have used other sysrqs to achieve the
> panic/reboot and b) the policy would break an existing usecase to
> kill a memory hog which would be recoverable unlike the panic which
> might be configured for the real OOM condition.
> 
> It also doesn't make much sense to panic the system when there is no
> OOM killable task because administrator might choose to do additional
> steps before rebooting/panicing the system.
> 

s/panicing/panicking/

> While we are there also add a comment explaining why
> sysctl_oom_kill_allocating_task doesn't apply to sysrq triggered OOM
> killer even though there is no explicit check and we subtly rely
> on current->mm being NULL for the context from which it is triggered.
> 
> Also be more explicit about sysrq+f behavior in the documentation.
> 
> Requested-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  Documentation/sysrq.txt |  5 ++++-
>  mm/oom_kill.c           | 21 +++++++++++++++++----
>  2 files changed, 21 insertions(+), 5 deletions(-)
> 
> diff --git a/Documentation/sysrq.txt b/Documentation/sysrq.txt
> index 0e307c94809a..a5dd88b0aede 100644
> --- a/Documentation/sysrq.txt
> +++ b/Documentation/sysrq.txt
> @@ -75,7 +75,10 @@ On other - If you know of the key combos for other architectures, please
>  
>  'e'     - Send a SIGTERM to all processes, except for init.
>  
> -'f'	- Will call oom_kill to kill a memory hog process.
> +'f'	- Will call oom_kill to kill a memory hog process. Please note that
> +	  an ongoing OOM killer is ignored and a task is killed even though
> +	  there was an oom victim selected already. panic_on_oom is ignored
> +	  and the system doesn't panic if there are no oom killable tasks.

"an ongoing OOM killer" could probably be reworded to "parallel oom 
killings".

>  
>  'g'	- Used by kgdb (kernel debugger)
>  
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index dff991e0681e..0c312eaac834 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -687,8 +687,14 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  	constraint = constrained_alloc(zonelist, gfp_mask, nodemask,
>  						&totalpages);
>  	mpol_mask = (constraint == CONSTRAINT_MEMORY_POLICY) ? nodemask : NULL;
> -	check_panic_on_oom(constraint, gfp_mask, order, mpol_mask, NULL);
> +	/* Ignore panic_on_oom when the OOM killer is sysrq triggered */
> +	if (!force_kill)
> +		check_panic_on_oom(constraint, gfp_mask, order, mpol_mask, NULL);

I don't think the comment is necessary, it should be clear from the code 
that this only executes when force_kill == true.

You may want to reconsider my suggestion of renaming the formal as 
"sysrq".

>  
> +	/*
> +	 * not affecting force_kill because sysrq triggered OOM killer runs from
> +	 * the workqueue context so current->mm will be NULL
> +	 */

Unnecessary comment, nobody is reading this code with the short circuit in 
mind.

>  	if (sysctl_oom_kill_allocating_task && current->mm &&
>  	    !oom_unkillable_task(current, NULL, nodemask) &&
>  	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
> @@ -700,10 +706,17 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  	}
>  
>  	p = select_bad_process(&points, totalpages, mpol_mask, force_kill);
> -	/* Found nothing?!?! Either we hang forever, or we panic. */
> +	/*
> +	 * Found nothing?!?! Either we hang forever, or we panic.
> +	 * Do not panic when the OOM killer is sysrq triggered.
> +	 */

Again, it's clear what a conditional does in C code.

>  	if (!p) {
> -		dump_header(NULL, gfp_mask, order, NULL, mpol_mask);
> -		panic("Out of memory and no killable processes...\n");
> +		if (!force_kill) {
> +			dump_header(NULL, gfp_mask, order, NULL, mpol_mask);
> +			panic("Out of memory and no killable processes...\n");
> +		} else {
> +			pr_info("Forced out of memory. No killable task found...\n");
> +		}

This line could probably be reworded to specify that an oom kill was 
requested by a specific process and there was nothing avilable to kill.  
I'm not sure that "forced" implies that it was process triggered.

>  	}
>  	if (p != (void *)-1UL) {
>  		oom_kill_process(p, gfp_mask, order, points, totalpages, NULL,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
