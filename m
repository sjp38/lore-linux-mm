Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2A88E8D003B
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 03:43:47 -0400 (EDT)
Date: Mon, 28 Mar 2011 09:43:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: update documentation to describe usage_in_bytes
Message-ID: <20110328074341.GA5693@tiehlicka.suse.cz>
References: <20110318152532.GB18450@tiehlicka.suse.cz>
 <20110321093419.GA26047@tiehlicka.suse.cz>
 <20110321102420.GB26047@tiehlicka.suse.cz>
 <20110322091014.27677ab3.kamezawa.hiroyu@jp.fujitsu.com>
 <20110322104723.fd81dddc.nishimura@mxp.nes.nec.co.jp>
 <20110322073150.GA12940@tiehlicka.suse.cz>
 <20110323092708.021d555d.nishimura@mxp.nes.nec.co.jp>
 <20110323133517.de33d624.kamezawa.hiroyu@jp.fujitsu.com>
 <20110328085508.c236e929.nishimura@mxp.nes.nec.co.jp>
 <20110328132550.08be4389.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110328132550.08be4389.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 28-03-11 13:25:50, Daisuke Nishimura wrote:
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> Update the meaning of *.usage_in_bytes. They doesn't show the actual usage of
> RSS+Cache(+Swap). They show the res_counter->usage for memory and memory+swap.

Don't we want to add why this is not rss+cache? The reason is really non
trivial for somebody who is not familiar with the code and with the fact
that we are heavily caching charges.

> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  Documentation/cgroups/memory.txt |   16 ++++++++++++++--
>  1 files changed, 14 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 7781857..ab7d4c1 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -52,8 +52,10 @@ Brief summary of control files.
>   tasks				 # attach a task(thread) and show list of threads
>   cgroup.procs			 # show list of processes
>   cgroup.event_control		 # an interface for event_fd()
> - memory.usage_in_bytes		 # show current memory(RSS+Cache) usage.
> - memory.memsw.usage_in_bytes	 # show current memory+Swap usage
> + memory.usage_in_bytes		 # show current res_counter usage for memory
> +				 (See 5.5 for details)
> + memory.memsw.usage_in_bytes	 # show current res_counter usage for memory+Swap
> +				 (See 5.5 for details)
>   memory.limit_in_bytes		 # set/show limit of memory usage
>   memory.memsw.limit_in_bytes	 # set/show limit of memory+Swap usage
>   memory.failcnt			 # show the number of memory usage hits limits
> @@ -453,6 +455,16 @@ memory under it will be reclaimed.
>  You can reset failcnt by writing 0 to failcnt file.
>  # echo 0 > .../memory.failcnt
>  
> +5.5 usage_in_bytes
> +
> +As described in 2.1, memory cgroup uses res_counter for tracking and limiting
> +the memory usage. memory.usage_in_bytes shows the current res_counter usage for
> +memory, and DOESN'T show a actual usage of RSS and Cache. It is usually bigger
> +than the actual usage for a performance improvement reason. 

Isn't an explicit mention about caching charges better?

> If you want to know
> +the actual usage, you can use memory.stat(see 5.2).
> +It's the same for memory.memsw.usage_in_bytes, which shows the current
> +res_counter usage for memory+swap.

Should we clarify for who is this file intended? 

Thanks
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
