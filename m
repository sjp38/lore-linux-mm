Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DF3E56B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 18:09:15 -0400 (EDT)
Date: Thu, 1 Sep 2011 15:09:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -v2 -mm] add extra free kbytes tunable
Message-Id: <20110901150901.48d92bc2.akpm@linux-foundation.org>
In-Reply-To: <20110901152650.7a63cb8b@annuminas.surriel.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com>
	<20110901100650.6d884589.rdunlap@xenotime.net>
	<20110901152650.7a63cb8b@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lwoodman@redhat.com, Seiji Aguchi <saguchi@redhat.com>, hughd@google.com, hannes@cmpxchg.org

On Thu, 1 Sep 2011 15:26:50 -0400
Rik van Riel <riel@redhat.com> wrote:

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
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -96,6 +96,7 @@ extern char core_pattern[];
>  extern unsigned int core_pipe_limit;
>  extern int pid_max;
>  extern int min_free_kbytes;
> +extern int extra_free_kbytes;

No externs in C, please.  Feel free to fix min_free_kbytes while you're
there ;)

swap.h is a common place to declare these things.  mmzone.h would make
sense too.


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

Lazy.  The function should be renamed to accurately reflect its role.

> +		.extra1		= &zero,
> +	},
> +	{
>  		.procname	= "percpu_pagelist_fraction",
>  		.data		= &percpu_pagelist_fraction,
>  		.maxlen		= sizeof(percpu_pagelist_fraction),
>
> ...
>
> +int extra_free_kbytes = 0;

I'm inclined to agree with checkpatch here - it's just noise.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
