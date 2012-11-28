Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 6EF046B0073
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 11:29:29 -0500 (EST)
Date: Wed, 28 Nov 2012 17:29:24 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] Add mempressure cgroup
Message-ID: <20121128162924.GA22201@dhcp22.suse.cz>
References: <20121128102908.GA15415@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121128102908.GA15415@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Wed 28-11-12 02:29:08, Anton Vorontsov wrote:
> This is an attempt to implement David Rientjes' idea of mempressure
> cgroup.
> 
> The main characteristics are the same to what I've tried to add to vmevent
> API:
> 
>   Internally, it uses Mel Gorman's idea of scanned/reclaimed ratio for
>   pressure index calculation. But we don't expose the index to the
>   userland. Instead, there are three levels of the pressure:
> 
>   o low (just reclaiming, e.g. caches are draining);
>   o medium (allocation cost becomes high, e.g. swapping);
>   o oom (about to oom very soon).
> 
>   The rationale behind exposing levels and not the raw pressure index
>   described here: http://lkml.org/lkml/2012/11/16/675
> 
> The API uses standard cgroups eventfd notifications:
> 
>   $ gcc Documentation/cgroups/cgroup_event_listener.c -o \
> 	cgroup_event_listener
>   $ cd /sys/fs/cgroup/
>   $ mkdir mempressure
>   $ mount -t cgroup cgroup ./mempressure -o mempressure
>   $ cd mempressure
>   $ cgroup_event_listener ./mempressure.level low
>   ("low", "medium", "oom" are permitted values.)
> 
>   Upon hitting the threshold, you should see "/sys/fs/cgroup/mempressure
>   low: crossed" messages.
> 
> To test that it actually works on per-cgroup basis, I did a small trick: I
> moved all kswapd into a separate cgroup, and hooked the listener onto
> another (non-root) cgroup. The listener no longer received global reclaim
> pressure, which is expected.

Is this really expected? So you want to be notified only about the
direct reclaim?
I am not sure how much useful is that. If you co-mount with e.g. memcg then
the picture is different because even global memory pressure is spread
among groups so it would be just a matter of the proper accounting
(which can be handled similar to lruvec when your code doesn't have to
care about memcg internally).
Co-mounting with cpusets makes sense as well because then you get a
pressure notification based on the placement policy.

So does it make much sense to mount mempressure on its own without
co-mounting with other controllers?

> For a task it is possible to be in both cpusets, memcg and mempressure
> cgroups, so by rearranging the tasks it should be possible to watch a
> specific pressure.

Could you be more specific what you mean by rearranging? Creating a same
hierarchy? Co-mounting?

> Note that while this adds the cgroups support, the code is well separated
> and eventually we might add a lightweight, non-cgroups API, i.e. vmevent.
> But this is another story.

I think it would be nice to follow freezer and split this into 2 files.
Generic and cgroup spefici.

> Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
> ---
[...]
> +/* These are defaults. Might make them configurable one day. */
> +static const uint vmpressure_win = SWAP_CLUSTER_MAX * 16;

I realize this is just an RFC but could you be more specific what is the
meaning of vmpressure_win?

> +static const uint vmpressure_level_med = 60;
> +static const uint vmpressure_level_oom = 99;
> +static const uint vmpressure_level_oom_prio = 4;
> +
> +enum vmpressure_levels {
> +	VMPRESSURE_LOW = 0,
> +	VMPRESSURE_MEDIUM,
> +	VMPRESSURE_OOM,
> +	VMPRESSURE_NUM_LEVELS,
> +};
> +
> +static const char const *vmpressure_str_levels[] = {
> +	[VMPRESSURE_LOW] = "low",
> +	[VMPRESSURE_MEDIUM] = "medium",
> +	[VMPRESSURE_OOM] = "oom",
> +};
> +
> +static enum vmpressure_levels vmpressure_level(uint pressure)
> +{
> +	if (pressure >= vmpressure_level_oom)
> +		return VMPRESSURE_OOM;
> +	else if (pressure >= vmpressure_level_med)
> +		return VMPRESSURE_MEDIUM;
> +	return VMPRESSURE_LOW;
> +}
> +
> +static ulong vmpressure_calc_level(uint win, uint s, uint r)
> +{
> +	ulong p;
> +
> +	if (!s)
> +		return 0;
> +
> +	/*
> +	 * We calculate the ratio (in percents) of how many pages were
> +	 * scanned vs. reclaimed in a given time frame (window). Note that
> +	 * time is in VM reclaimer's "ticks", i.e. number of pages
> +	 * scanned. This makes it possible to set desired reaction time
> +	 * and serves as a ratelimit.
> +	 */
> +	p = win - (r * win / s);
> +	p = p * 100 / win;

Do we need the win at all?
	p = 100 - (100 * r / s);
> +
> +	pr_debug("%s: %3lu  (s: %6u  r: %6u)\n", __func__, p, s, r);
> +
> +	return vmpressure_level(p);
> +}
> +
[...]
> +static int mpc_pre_destroy(struct cgroup *cg)
> +{
> +	struct mpc_state *mpc = cg2mpc(cg);
> +	int ret = 0;
> +
> +	mutex_lock(&mpc->lock);
> +
> +	if (mpc->eventfd)
> +		ret = -EBUSY;

The current cgroup's core doesn't allow pre_destroy to fail anymore. The
code is marked for 3.8

[...]
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 48550c6..430d8a5 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1877,6 +1877,8 @@ restart:
>  		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
>  				   sc, LRU_ACTIVE_ANON);
>  
> +	vmpressure(sc->nr_scanned - nr_scanned, nr_reclaimed);
> +

I think this should already report to a proper group otherwise all the
global reclaim would go to a group where kswapd sits rather than to the
target group as I mentioned above (so it at least wouldn't work with a
co-mounted cases).

>  	/* reclaim/compaction might need reclaim to continue */
>  	if (should_continue_reclaim(lruvec, nr_reclaimed,
>  				    sc->nr_scanned - nr_scanned, sc))
> @@ -2099,6 +2101,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		count_vm_event(ALLOCSTALL);
>  
>  	do {
> +		vmpressure_prio(sc->priority);

Shouldn't this go into shrink_lruvec or somewhere at that level to catch
also kswapd low priorities? If you insist on the direct reclaim then you
should hook into __zone_reclaim as well.

>  		sc->nr_scanned = 0;
>  		aborted_reclaim = shrink_zones(zonelist, sc);

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
