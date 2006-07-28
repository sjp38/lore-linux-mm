Date: Fri, 28 Jul 2006 09:29:50 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/9] cpuset: oom panic fix
Message-ID: <20060728072949.GA4161@wotan.suse.de>
References: <20060515210529.30275.74992.sendpatchset@linux.site> <20060515210556.30275.63352.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060515210556.30275.63352.sendpatchset@linux.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 28, 2006 at 09:21:11AM +0200, Nick Piggin wrote:
> cpuset_excl_nodes_overlap always returns 0 if current is exiting. This caused
> customer's systems to panic in the OOM killer when processes were having
> trouble getting memory for the final put_user in mm_release. Even though there
> were lots of processes to kill.
> 
> Change to returning 0 in this case. This achieves parity with !CONFIG_CPUSETS
> case, and was observed to fix the problem.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>

I forgot to mention, I think this one was also Acked-by: Paul Jackson.
CCing him...

> 
> Index: linux-2.6/kernel/cpuset.c
> ===================================================================
> --- linux-2.6.orig/kernel/cpuset.c
> +++ linux-2.6/kernel/cpuset.c
> @@ -2369,7 +2369,7 @@ EXPORT_SYMBOL_GPL(cpuset_mem_spread_node
>  int cpuset_excl_nodes_overlap(const struct task_struct *p)
>  {
>  	const struct cpuset *cs1, *cs2;	/* my and p's cpuset ancestors */
> -	int overlap = 0;		/* do cpusets overlap? */
> +	int overlap = 1;		/* do cpusets overlap? */
>  
>  	task_lock(current);
>  	if (current->flags & PF_EXITING) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
