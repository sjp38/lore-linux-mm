Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9F5096B0038
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 12:04:02 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id l15so4587190wiw.2
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 09:04:02 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ep2si14556804wib.0.2015.01.08.09.04.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jan 2015 09:04:00 -0800 (PST)
Date: Thu, 8 Jan 2015 12:03:49 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] vmscan: force scan offline memory cgroups
Message-ID: <20150108170349.GA32079@phnom.home.cmpxchg.org>
References: <1420728669-16889-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420728669-16889-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 08, 2015 at 05:51:09PM +0300, Vladimir Davydov wrote:
> Since commit b2052564e66d ("mm: memcontrol: continue cache reclaim from
> offlined groups") pages charged to a memory cgroup are not reparented
> when the cgroup is removed. Instead, they are supposed to be reclaimed
> in a regular way, along with pages accounted to online memory cgroups.
> 
> However, an lruvec of an offline memory cgroup will sooner or later get
> so small that it will be scanned only at low scan priorities (see
> get_scan_count()). Therefore, if there are enough reclaimable pages in
> big lruvecs, pages accounted to offline memory cgroups will never be
> scanned at all, wasting memory.
> 
> Fix this by unconditionally forcing scanning dead lruvecs from kswapd.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Yes, it makes sense to continue draining them at this point.  I just
have a few comments inline:

> @@ -1367,6 +1367,20 @@ int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
>  	return inactive * inactive_ratio < active;
>  }
>  
> +bool mem_cgroup_need_force_scan(struct lruvec *lruvec)
> +{
> +	struct mem_cgroup_per_zone *mz;
> +	struct mem_cgroup *memcg;
> +
> +	if (mem_cgroup_disabled())
> +		return false;
> +
> +	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
> +	memcg = mz->memcg;
> +
> +	return !(memcg->css.flags & CSS_ONLINE);
> +}

It's better to name functions after what they do, rather than what
they are used for, to make reuse easy.  mem_cgroup_lruvec_online()?

> @@ -1935,7 +1935,8 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
>  	 * latencies, so it's better to scan a minimum amount there as
>  	 * well.
>  	 */
> -	if (current_is_kswapd() && !zone_reclaimable(zone))
> +	if (current_is_kswapd() &&
> +	    (!zone_reclaimable(zone) || mem_cgroup_need_force_scan(lruvec)))
>  		force_scan = true;

This would probably be easier on the eyes if you broke that up:

if (current_is_kswapd()) {
        if (!zone_reclaimable(zone))
                force_scan = true;
        else if (!mem_cgroup_online_from_lruvec(lruvec))
                force_scan = true;
} else if (!global_reclaim(sc)) {
                force_scan = true;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
