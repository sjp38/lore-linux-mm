Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 754EC6B00EB
	for <linux-mm@kvack.org>; Tue, 15 May 2012 11:04:55 -0400 (EDT)
Date: Tue, 15 May 2012 17:04:52 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 5/6] mm: memcg: group swapped-out statistics counter
 logically
Message-ID: <20120515150452.GJ11346@tiehlicka.suse.cz>
References: <1337018451-27359-1-git-send-email-hannes@cmpxchg.org>
 <1337018451-27359-6-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1337018451-27359-6-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 14-05-12 20:00:50, Johannes Weiner wrote:
> The counter of currently swapped out pages in a memcg (hierarchy) is
> sitting amidst ever-increasing event counters.  Move this item to the
> other counters that reflect current state rather than history.
> 
> This technically breaks the kernel ABI, but hopefully nobody relies on
> the order of items in memory.stat.

We did that already in 456f998e. Nobody complained AFAIR.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |   12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 546e7db..3ee63f6 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4257,9 +4257,9 @@ enum {
>  	MCS_RSS,
>  	MCS_FILE_MAPPED,
>  	MCS_MLOCK,
> +	MCS_SWAP,
>  	MCS_PGPGIN,
>  	MCS_PGPGOUT,
> -	MCS_SWAP,
>  	MCS_PGFAULT,
>  	MCS_PGMAJFAULT,
>  	MCS_INACTIVE_ANON,
> @@ -4279,9 +4279,9 @@ static const char *memcg_stat_strings[NR_MCS_STAT] = {
>  	"rss",
>  	"mapped_file",
>  	"mlock",
> +	"swap",
>  	"pgpgin",
>  	"pgpgout",
> -	"swap",
>  	"pgfault",
>  	"pgmajfault",
>  	"inactive_anon",
> @@ -4306,14 +4306,14 @@ mem_cgroup_get_local_stat(struct mem_cgroup *memcg, struct mcs_total_stat *s)
>  	s->stat[MCS_FILE_MAPPED] += val * PAGE_SIZE;
>  	val = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_MLOCK);
>  	s->stat[MCS_MLOCK] += val * PAGE_SIZE;
> -	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGPGIN);
> -	s->stat[MCS_PGPGIN] += val;
> -	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGPGOUT);
> -	s->stat[MCS_PGPGOUT] += val;
>  	if (do_swap_account) {
>  		val = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_SWAPOUT);
>  		s->stat[MCS_SWAP] += val * PAGE_SIZE;
>  	}
> +	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGPGIN);
> +	s->stat[MCS_PGPGIN] += val;
> +	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGPGOUT);
> +	s->stat[MCS_PGPGOUT] += val;
>  	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGFAULT);
>  	s->stat[MCS_PGFAULT] += val;
>  	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGMAJFAULT);
> -- 
> 1.7.10.1
> 

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
