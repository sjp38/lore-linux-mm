Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id A5C5A6B000D
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 05:17:11 -0500 (EST)
Message-ID: <5118C522.3070905@parallels.com>
Date: Mon, 11 Feb 2013 14:17:06 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: Add memory.pressure_level events
References: <20130211000220.GA28247@lizard.gateway.2wire.net>
In-Reply-To: <20130211000220.GA28247@lizard.gateway.2wire.net>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

Hi Anton,

> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> new file mode 100644
> index 0000000..7922503


> +struct vmpressure_event {
> +	struct eventfd_ctx *efd;
> +	enum vmpressure_levels level;
> +	struct list_head node;
> +};
> +
> +static bool vmpressure_event(struct vmpressure *vmpr,
> +			     unsigned long s, unsigned long r)
> +{
> +	struct vmpressure_event *ev;
> +	int level = vmpressure_calc_level(vmpressure_win, s, r);
> +	bool signalled = 0;
> +
> +	mutex_lock(&vmpr->events_lock);
> +
> +	list_for_each_entry(ev, &vmpr->events, node) {
> +		if (level >= ev->level) {
> +			eventfd_signal(ev->efd, 1);
> +			signalled++;
> +		}
> +	}
> +
> +	mutex_unlock(&vmpr->events_lock);
> +
> +	return signalled;
> +}
> +
> +static struct vmpressure *vmpressure_parent(struct vmpressure *vmpr)
> +{
> +	struct cgroup *cg = vmpr_to_css(vmpr)->cgroup->parent;
> +
> +	if (!cg)
> +		return NULL;
> +	return cg_to_vmpr(cg);
> +}

Unfortunately, "parent" in memcg have different meanings for information
propagation purposes depending on the value of the flag "use_hierarchy".
That is set for deprecation, but still...

I suggest you use the helper mem_cgroup_parent, that will already give
you the right parent (either immediate parent or root) with all that
taken into account.

> +
> +static int vmpressure_register_level(struct cgroup *cg, struct cftype *cft,
> +				     struct eventfd_ctx *eventfd,
> +				     const char *args)
> +{
> +	struct vmpressure *vmpr = cg_to_vmpr(cg);
> +	struct vmpressure_event *ev;
> +	int lvl;
> +
> +	for (lvl = 0; lvl < VMPRESSURE_NUM_LEVELS; lvl++) {
> +		if (!strcmp(vmpressure_str_levels[lvl], args))
> +			break;
> +	}
> +
> +	if (lvl >= VMPRESSURE_NUM_LEVELS)
> +		return -EINVAL;
> +
> +	ev = kzalloc(sizeof(*ev), GFP_KERNEL);
> +	if (!ev)
> +		return -ENOMEM;
> +
> +	ev->efd = eventfd;
> +	ev->level = lvl;
> +
> +	mutex_lock(&vmpr->events_lock);
> +	list_add(&ev->node, &vmpr->events);
> +	mutex_unlock(&vmpr->events_lock);
> +
> +	return 0;
> +}
> +
> +static void vmpressure_unregister_level(struct cgroup *cg, struct cftype *cft,
> +					struct eventfd_ctx *eventfd)
> +{
> +	struct vmpressure *vmpr = cg_to_vmpr(cg);
> +	struct vmpressure_event *ev;
> +
> +	mutex_lock(&vmpr->events_lock);
> +	list_for_each_entry(ev, &vmpr->events, node) {
> +		if (ev->efd != eventfd)
> +			continue;
> +		list_del(&ev->node);
> +		kfree(ev);
> +		break;
> +	}
> +	mutex_unlock(&vmpr->events_lock);
> +}
> +
> +static struct cftype vmpressure_cgroup_files[] = {
> +	{
> +		.name = "pressure_level",
> +		.read = vmpressure_read_level,
> +		.register_event = vmpressure_register_level,
> +		.unregister_event = vmpressure_unregister_level,
> +	},
> +	{},
> +};
> +

> +
> +void __init enable_pressure_cgroup(void)
> +{
> +	WARN_ON(cgroup_add_cftypes(&mem_cgroup_subsys,
> +				   vmpressure_cgroup_files));
> +}

There is no functionality discovery going on here, and this is
conditional on nothing. Isn't it better then to just add the register +
read functions to memcontrol.c and add the files in the memcontrol cftype ?

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 88c5fed..34f09b9 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1982,6 +1982,10 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>  			}
>  			memcg = mem_cgroup_iter(root, memcg, &reclaim);
>  		} while (memcg);
> +
> +		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
> +			   sc->nr_scanned - nr_scanned, nr_reclaimed);
> +
>  	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
>  					 sc->nr_scanned - nr_scanned, sc));
>  }
> @@ -2167,6 +2171,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		count_vm_event(ALLOCSTALL);
>  
>  	do {
> +		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
> +				sc->priority);
>  		sc->nr_scanned = 0;
>  		aborted_reclaim = shrink_zones(zonelist, sc);
>  
vmscan part seems okay to me.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
