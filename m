Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0920D60044A
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 18:59:51 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o03NxmFZ026572
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 4 Jan 2010 08:59:48 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 50A6745DE4E
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:59:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 217E545DE4C
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:59:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EF1041DB8038
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:59:47 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 77DD31DB8037
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:59:47 +0900 (JST)
Date: Mon, 4 Jan 2010 08:56:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 3/4] memcg: rework usage of stats by soft limit
Message-Id: <20100104085632.1ac97a5a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <03152dd4f660cff87b16bb581718b1c53d4775aa.1262186098.git.kirill@shutemov.name>
References: <cover.1262186097.git.kirill@shutemov.name>
	<9411cbdd545e1232c916bfef03a60cf95510016d.1262186098.git.kirill@shutemov.name>
	<34fedc324199dd64149889ed6eac5d8f9441a9db.1262186098.git.kirill@shutemov.name>
	<03152dd4f660cff87b16bb581718b1c53d4775aa.1262186098.git.kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 30 Dec 2009 17:57:58 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> Instead of incrementing counter on each page in/out and comparing it
> with constant, we set counter to constant, decrement counter on each
> page in/out and compare it with zero. We want to make comparing as fast
> as possible. On many RISC systems (probably not only RISC) comparing
> with zero is more effective than comparing with a constant, since not
> every constant can be immediate operand for compare instruction.
> 
> Also, I've renamed MEM_CGROUP_STAT_EVENTS to MEM_CGROUP_STAT_SOFTLIMIT,
> since really it's not a generic counter.
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> 
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
> 
> KAMEZAWA-san, I've changed the patch a bit. Can I reuse your Acked-by?
> 
> ---
>  mm/memcontrol.c |   18 ++++++++++--------
>  1 files changed, 10 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 1d71cb4..c36d4f3 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -69,8 +69,9 @@ enum mem_cgroup_stat_index {
>  	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
>  	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
>  	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
> -	MEM_CGROUP_STAT_EVENTS,	/* sum of pagein + pageout for internal use */
>  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> +	MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each page in/out.
> +					used by soft limit implementation */
>  
>  	MEM_CGROUP_STAT_NSTATS,
>  };
> @@ -84,10 +85,10 @@ struct mem_cgroup_stat {
>  };
>  
>  static inline void
> -__mem_cgroup_stat_reset_safe(struct mem_cgroup_stat_cpu *stat,
> -				enum mem_cgroup_stat_index idx)
> +__mem_cgroup_stat_set_safe(struct mem_cgroup_stat_cpu *stat,
> +				enum mem_cgroup_stat_index idx, s64 val)
>  {
> -	stat->count[idx] = 0;
> +	stat->count[idx] = val;
>  }
>  
>  static inline s64
> @@ -380,9 +381,10 @@ static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
>  
>  	cpu = get_cpu();
>  	cpustat = &mem->stat.cpustat[cpu];
> -	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_EVENTS);
> -	if (unlikely(val > SOFTLIMIT_EVENTS_THRESH)) {
> -		__mem_cgroup_stat_reset_safe(cpustat, MEM_CGROUP_STAT_EVENTS);
> +	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_SOFTLIMIT);
> +	if (unlikely(val < 0)) {
> +		__mem_cgroup_stat_set_safe(cpustat, MEM_CGROUP_STAT_SOFTLIMIT,
> +				SOFTLIMIT_EVENTS_THRESH);
>  		ret = true;
>  	}
>  	put_cpu();
> @@ -515,7 +517,7 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
>  	else
>  		__mem_cgroup_stat_add_safe(cpustat,
>  				MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
> -	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_EVENTS, 1);
> +	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_SOFTLIMIT, -1);
>  	put_cpu();
>  }
>  
> -- 
> 1.6.5.7
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
