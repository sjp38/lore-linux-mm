Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id A9D266B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 18:12:08 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id hu16so28625qab.13
        for <linux-mm@kvack.org>; Thu, 16 May 2013 15:12:07 -0700 (PDT)
Date: Thu, 16 May 2013 15:12:00 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch v3 -mm 1/3] memcg: integrate soft reclaim tighter with
 zone shrinking code
Message-ID: <20130516221200.GF7171@mtj.dyndns.org>
References: <1368431172-6844-1-git-send-email-mhocko@suse.cz>
 <1368431172-6844-2-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368431172-6844-2-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Balbir Singh <bsingharora@gmail.com>

Sorry about the delay.  Just getting back to memcg.

On Mon, May 13, 2013 at 09:46:10AM +0200, Michal Hocko wrote:
...
> during the first pass. Only groups which are over their soft limit or
> any of their parents up the hierarchy is over the limit are considered

ancestors?

> +static void shrink_zone(struct zone *zone, struct scan_control *sc)
> +{
> +	bool do_soft_reclaim = mem_cgroup_should_soft_reclaim(sc);
> +	unsigned long nr_scanned = sc->nr_scanned;
> +
> +	__shrink_zone(zone, sc, do_soft_reclaim);
> +
> +	/*
> +	 * No group is over the soft limit or those that are do not have
> +	 * pages in the zone we are reclaiming so we have to reclaim everybody
> +	 */
> +	if (do_soft_reclaim && (sc->nr_scanned == nr_scanned)) {
> +		__shrink_zone(zone, sc, false);
> +		return;
> +	}
> +}

Maybe the following is easier to follow?

	if (mem_cgroup_should_soft_reclaim(sc)) {
		__shrink_zone(zone, sc, true);
		if (sc->nr_scanned == nr_scanned)
			__shrink_zone(zone, sc, false);
	} else {
		__shrink_zone(zone, sc, false);
	}

But it's a minor point, please feel free to ignore.

  Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
