Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 611C56B00EE
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 13:06:56 -0400 (EDT)
Date: Thu, 1 Sep 2011 10:06:50 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH -mm] add extra free kbytes tunable
Message-Id: <20110901100650.6d884589.rdunlap@xenotime.net>
In-Reply-To: <20110901105208.3849a8ff@annuminas.surriel.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Satoru Moriya <smoriya@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lwoodman@redhat.com, Seiji Aguchi <saguchi@redhat.com>, akpm@linux-foundation.org, hughd@google.com, hannes@cmpxchg.org

On Thu, 1 Sep 2011 10:52:08 -0400 Rik van Riel wrote:

> Add a userspace visible knob to tell the VM to keep an extra amount
> of memory free, by increasing the gap between each zone's min and
> low watermarks.
> 
> This is useful for realtime applications that call system
> calls and have a bound on the number of allocations that happen
> in any short time period.  In this application, extra_free_kbytes
> would be left at an amount equal to or larger than than the
> maximum number of allocations that happen in any burst.
> 
> It may also be useful to reduce the memory use of virtual
> machines (temporarily?), in a way that does not cause memory
> fragmentation like ballooning does.
> 
> Signed-off-by: Rik van Riel<riel@redhat.com>

Hi Rik,

Please add to Documentation/syctl/vm.txt ..

Thanks.


> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 11d65b5..01a9acd 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -96,6 +96,7 @@ extern char core_pattern[];
>  extern unsigned int core_pipe_limit;
>  extern int pid_max;
>  extern int min_free_kbytes;
> +extern int extra_free_kbytes;
>  extern int pid_max_min, pid_max_max;
>  extern int sysctl_drop_caches;
>  extern int percpu_pagelist_fraction;
> @@ -1189,6 +1190,14 @@ static struct ctl_table vm_table[] = {
>  		.extra1		= &zero,
>  	},
>  	{
> +		.procname	= "extra_free_kbytes",
> +		.data		= &extra_free_kbytes,
> +		.maxlen		= sizeof(extra_free_kbytes),
> +		.mode		= 0644,
> +		.proc_handler	= min_free_kbytes_sysctl_handler,
> +		.extra1		= &zero,
> +	},
> +	{
>  		.procname	= "percpu_pagelist_fraction",
>  		.data		= &percpu_pagelist_fraction,
>  		.maxlen		= sizeof(percpu_pagelist_fraction),
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6e8ecb6..47d185c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -175,8 +175,20 @@ static char * const zone_names[MAX_NR_ZONES] = {
>  	 "Movable",
>  };
>  
> +/*
> + * Try to keep at least this much lowmem free.  Do not allow normal
> + * allocations below this point, only high priority ones. Automatically
> + * tuned according to the amount of memory in the system.
> + */
>  int min_free_kbytes = 1024;
>  
> +/*
> + * Extra memory for the system to try freeing. Used to temporarily
> + * free memory, to make space for new workloads. Anyone can allocate
> + * down to the min watermarks controlled by min_free_kbytes above.
> + */
> +int extra_free_kbytes = 0;


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
