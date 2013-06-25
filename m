Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id E65536B0032
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 16:47:01 -0400 (EDT)
Received: by mail-ea0-f182.google.com with SMTP id d10so7165652eaj.13
        for <linux-mm@kvack.org>; Tue, 25 Jun 2013 13:47:00 -0700 (PDT)
Date: Tue, 25 Jun 2013 22:46:57 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: add interface to specify thresholds of vmpressure
Message-ID: <20130625204657.GD24002@dhcp22.suse.cz>
References: <20130620121649.GB27196@dhcp22.suse.cz>
 <001e01ce6e15$3d183bd0$b748b370$%kim@samsung.com>
 <001f01ce6e15$b7109950$2531cbf0$%kim@samsung.com>
 <20130621012234.GF11659@bbox>
 <20130621091944.GC12424@dhcp22.suse.cz>
 <20130621162743.GA2837@gmail.com>
 <CAOK=xRMhwvWrao_ve8GFsk0JBHAcWh_SB_kM6fCujp8WThPimw@mail.gmail.com>
 <CAOK=xRNEMp3igfwQfrz0ffApmoAL19OM0EGLaBJ5RerZy9ddtw@mail.gmail.com>
 <005601ce6f0c$5948ff90$0bdafeb0$%kim@samsung.com>
 <005801ce6f1a$f1664f90$d432eeb0$%kim@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <005801ce6f1a$f1664f90$d432eeb0$%kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hyunhee Kim <hyunhee.kim@samsung.com>
Cc: 'Minchan Kim' <minchan@kernel.org>, 'Anton Vorontsov' <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, 'Kyungmin Park' <kyungmin.park@samsung.com>

On Sat 22-06-13 16:34:34, Hyunhee Kim wrote:
> Memory pressure is calculated based on scanned/reclaimed ratio.

It is done that way _now_ and there is no guarantee it will do that in
future. There was a reason why the interface is so mean on any details.

I am sorry to repeat myself but this is a user interface and we will have
to maintain it for _ever_. We cannot export random knobs that work just
now. Future implementation of the reclaim might change considerably and
scaned vs. reclaimed might no longer mean the same thing.

So no, again, please do not try to push random things to handle you
current and very specific use case.

Nack to this patch.

> The higher
> the value, the more number unsuccessful reclaims there were. These thresholds
> can be specified when each event is registered by writing it next to the
> string of level. Default value is 60 for "medium" and 95 for "critical"
> 
> Signed-off-by: Hyunhee Kim <hyunhee.kim@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  Documentation/cgroups/memory.txt |    8 +++++-
>  mm/vmpressure.c                  |   54 +++++++++++++++++++++++++++-----------
>  2 files changed, 45 insertions(+), 17 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index ddf4f93..bd9cf46 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -807,13 +807,19 @@ register a notification, an application must:
>  
>  - create an eventfd using eventfd(2);
>  - open memory.pressure_level;
> -- write string like "<event_fd> <fd of memory.pressure_level> <level>"
> +- write string like "<event_fd> <fd of memory.pressure_level> <level> <threshold>"
>    to cgroup.event_control.
>  
>  Application will be notified through eventfd when memory pressure is at
>  the specific level (or higher). Read/write operations to
>  memory.pressure_level are no implemented.
>  
> +We account memory pressure based on scanned/reclaimed ratio. The higher
> +the value, the more number unsuccessful reclaims there were. These thresholds
> +can be specified when each event is registered by writing it next to the
> +string of level. Default value is 60 for "medium" and 95 for "critical".
> +If nothing is input as threshold, default values are used.
> +
>  Test:
>  
>     Here is a small script example that makes a new cgroup, sets up a
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index 736a601..52b266c 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -40,15 +40,6 @@
>  static const unsigned long vmpressure_win = SWAP_CLUSTER_MAX * 16;
>  
>  /*
> - * These thresholds are used when we account memory pressure through
> - * scanned/reclaimed ratio. The current values were chosen empirically. In
> - * essence, they are percents: the higher the value, the more number
> - * unsuccessful reclaims there were.
> - */
> -static const unsigned int vmpressure_level_med = 60;
> -static const unsigned int vmpressure_level_critical = 95;
> -
> -/*
>   * When there are too little pages left to scan, vmpressure() may miss the
>   * critical pressure as number of pages will be less than "window size".
>   * However, in that case the vmscan priority will raise fast as the
> @@ -97,6 +88,19 @@ enum vmpressure_levels {
>  	VMPRESSURE_NUM_LEVELS,
>  };
>  
> +/*
> + * These thresholds are used when we account memory pressure through
> + * scanned/reclaimed ratio. In essence, they are percents: the higher
> + * the value, the more number unsuccessful reclaims there were.
> + * These thresholds can be specified when each event is registered.
> + */
> +
> +static unsigned int vmpressure_threshold_levels[] = {
> +	[VMPRESSURE_LOW] = 0,
> +	[VMPRESSURE_MEDIUM] = 60,
> +	[VMPRESSURE_CRITICAL] = 95,
> +};
> +
>  static const char * const vmpressure_str_levels[] = {
>  	[VMPRESSURE_LOW] = "low",
>  	[VMPRESSURE_MEDIUM] = "medium",
> @@ -105,11 +109,14 @@ static const char * const vmpressure_str_levels[] = {
>  
>  static enum vmpressure_levels vmpressure_level(unsigned long pressure)
>  {
> -	if (pressure >= vmpressure_level_critical)
> -		return VMPRESSURE_CRITICAL;
> -	else if (pressure >= vmpressure_level_med)
> -		return VMPRESSURE_MEDIUM;
> -	return VMPRESSURE_LOW;
> +	int level;
> +
> +	for (level = VMPRESSURE_NUM_LEVELS - 1; level >= 0; level--) {
> +		if (pressure >= vmpressure_threshold_levels[level])
> +			break;
> +	}
> +
> +	return level;
>  }
>  
>  static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
> @@ -303,10 +310,21 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
>  {
>  	struct vmpressure *vmpr = cg_to_vmpressure(cg);
>  	struct vmpressure_event *ev;
> -	int level;
> +	char *strlevel, *strthres;
> +	int level, thres = -1;
> +
> +	strlevel = args;
> +	strthres = strchr(args, ' ');
> +
> +	if (strthres) {
> +		*strthres = '\0';
> +		strthres++;
> +		if(kstrtoint(strthres, 10, &thres))
> +			return -EINVAL;
> +	}
>  
>  	for (level = 0; level < VMPRESSURE_NUM_LEVELS; level++) {
> -		if (!strcmp(vmpressure_str_levels[level], args))
> +		if (!strcmp(vmpressure_str_levels[level], strlevel))
>  			break;
>  	}
>  
> @@ -320,6 +338,10 @@ int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
>  	ev->efd = eventfd;
>  	ev->level = level;
>  
> +	/* If user input threshold is not valid value, use default value */
> +	if (thres <= 100 && thres >= 0)
> +		vmpressure_threshold_levels[level] = thres;
> +
>  	mutex_lock(&vmpr->events_lock);
>  	list_add(&ev->node, &vmpr->events);
>  	mutex_unlock(&vmpr->events_lock);
> -- 
> 1.7.9.5
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
