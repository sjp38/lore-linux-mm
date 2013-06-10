Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id B20A66B0031
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 11:22:48 -0400 (EDT)
Date: Mon, 10 Jun 2013 17:22:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: Add force_reclaim to reclaim tasks' memory in
 memcg.
Message-ID: <20130610152246.GB14295@dhcp22.suse.cz>
References: <021801ce65cb$f5b0bc50$e11234f0$%kim@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <021801ce65cb$f5b0bc50$e11234f0$%kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hyunhee Kim <hyunhee.kim@samsung.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>

On Mon 10-06-13 20:16:31, Hyunhee Kim wrote:
> These days, platforms tend to manage memory on low memory state
> like andloid's lowmemory killer. These platforms might want to
> reclaim memory from background tasks as well as kill victims
> to guarantee free memory at use space level. This patch provides
> an interface to reclaim a given memcg.

> After platform's low memory handler moves tasks that the platform
> wants to reclaim to a memcg and decides how many pages should be
> reclaimed, it can reclaim the pages from the tasks by writing the
> number of pages at memory.force_reclaim.

Why cannot you simply set the soft limit to 0 for the target group which
would enforce reclaim during the next global reclaim instead?

Or you can even use the hard limit for that. If you know how much memory
is used by those processes you can simply move them to a group with the
hard limit reduced by the amount of pages which you want to free and the
reclaim would happen during taks move.

> Signed-off-by: Hyunhee Kim <hyunhee.kim@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  mm/memcontrol.c |   26 ++++++++++++++++++++++++++
>  1 file changed, 26 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 010d6c1..21819c9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4980,6 +4980,28 @@ static int mem_cgroup_force_empty_write(struct cgroup
> *cont, unsigned int event)
>  	return ret;
>  }
>  
> +static int mem_cgroup_force_reclaim(struct cgroup *cont, struct cftype
> *cft, u64 val)
> +{
> +
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +	unsigned long nr_to_reclaim = val;
> +	unsigned long total = 0;
> +	int loop;
> +
> +	for (loop = 0; loop < MEM_CGROUP_MAX_RECLAIM_LOOPS; loop++) {
> +		total += try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL,
> false);
> +
> +		/*
> +		 * If nothing was reclaimed after two attempts, there
> +		 * may be no reclaimable pages in this hierarchy.
> +		 * If more than nr_to_reclaim pages were already reclaimed,
> +		 * finish force reclaim.
> +		 */
> +		if (loop && (!total || total > nr_to_reclaim))
> +			break;
> +	}
> +	return total;
> +}
>  
>  static u64 mem_cgroup_hierarchy_read(struct cgroup *cont, struct cftype
> *cft)
>  {
> @@ -5938,6 +5960,10 @@ static struct cftype mem_cgroup_files[] = {
>  		.trigger = mem_cgroup_force_empty_write,
>  	},
>  	{
> +		.name = "force_reclaim",
> +		.write_u64 = mem_cgroup_force_reclaim,
> +	},
> +	{
>  		.name = "use_hierarchy",
>  		.flags = CFTYPE_INSANE,
>  		.write_u64 = mem_cgroup_hierarchy_write,
> -- 
> 1.7.9.5
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
