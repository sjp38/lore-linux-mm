Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3B14D6B003D
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 22:50:59 -0500 (EST)
Date: Sat, 12 Dec 2009 12:50:46 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [PATCH RFC v2 3/4] memcg: rework usage of stats by soft limit
Message-Id: <20091212125046.14df3134.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <747ea0ec22b9348208c80f86f7a813728bf8e50a.1260571675.git.kirill@shutemov.name>
References: <cover.1260571675.git.kirill@shutemov.name>
	<ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
	<c1847dfb5c4fed1374b7add236d38e0db02eeef3.1260571675.git.kirill@shutemov.name>
	<747ea0ec22b9348208c80f86f7a813728bf8e50a.1260571675.git.kirill@shutemov.name>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Sorry, I disagree this change.

mem_cgroup_soft_limit_check() is used for checking how much current usage exceeds
the soft_limit_in_bytes and updating softlimit tree asynchronously, instead of
checking every charge/uncharge. What if you change the soft_limit_in_bytes,
but the number of charges and uncharges are very balanced afterwards ?
The softlimit tree will not be updated for a long time.

And IIUC, it's the same for your threshold feature, right ?
I think it would be better:

- discard this change.
- in 4/4, rename mem_cgroup_soft_limit_check to mem_cgroup_event_check,
  and instead of adding a new STAT counter, do like:

	if (mem_cgroup_event_check(mem)) {
		mem_cgroup_update_tree(mem, page);
		mem_cgroup_threshold(mem);
	}

Ah, yes. Current code doesn't call mem_cgroup_soft_limit_check() for root cgroup
in charge path as you said in http://marc.info/?l=linux-mm&m=126021128400687&w=2.
I think you can change there as you want, I can change my patch
(http://marc.info/?l=linux-mm&m=126023467303178&w=2, it has not yet sent to
Andrew anyway) to check mem_cgroup_is_root() in mem_cgroup_update_tree().

Thanks,
Daisuke Nishimura.

On Sat, 12 Dec 2009 00:59:18 +0200
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
> ---
>  mm/memcontrol.c |   19 ++++++++++++++-----
>  1 files changed, 14 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 0ff65ed..c6081cc 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -69,8 +69,9 @@ enum mem_cgroup_stat_index {
>  	MEM_CGROUP_STAT_MAPPED_FILE,  /* # of pages charged as file rss */
>  	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
>  	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
> -	MEM_CGROUP_STAT_EVENTS,	/* sum of pagein + pageout for internal use */
>  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> +	MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each page in/out.
> +					used by soft limit implementation */
>  
>  	MEM_CGROUP_STAT_NSTATS,
>  };
> @@ -90,6 +91,13 @@ __mem_cgroup_stat_reset_safe(struct mem_cgroup_stat_cpu *stat,
>  	stat->count[idx] = 0;
>  }
>  
> +static inline void
> +__mem_cgroup_stat_set(struct mem_cgroup_stat_cpu *stat,
> +		enum mem_cgroup_stat_index idx, s64 val)
> +{
> +	stat->count[idx] = val;
> +}
> +
>  static inline s64
>  __mem_cgroup_stat_read_local(struct mem_cgroup_stat_cpu *stat,
>  				enum mem_cgroup_stat_index idx)
> @@ -374,9 +382,10 @@ static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
>  
>  	cpu = get_cpu();
>  	cpustat = &mem->stat.cpustat[cpu];
> -	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_EVENTS);
> -	if (unlikely(val > SOFTLIMIT_EVENTS_THRESH)) {
> -		__mem_cgroup_stat_reset_safe(cpustat, MEM_CGROUP_STAT_EVENTS);
> +	val = __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP_STAT_SOFTLIMIT);
> +	if (unlikely(val < 0)) {
> +		__mem_cgroup_stat_set(cpustat, MEM_CGROUP_STAT_SOFTLIMIT,
> +				SOFTLIMIT_EVENTS_THRESH);
>  		ret = true;
>  	}
>  	put_cpu();
> @@ -509,7 +518,7 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
>  	else
>  		__mem_cgroup_stat_add_safe(cpustat,
>  				MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
> -	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_EVENTS, 1);
> +	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_SOFTLIMIT, -1);
>  	put_cpu();
>  }
>  
> -- 
> 1.6.5.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
