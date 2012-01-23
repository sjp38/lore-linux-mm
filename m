Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 6A5546B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 05:47:48 -0500 (EST)
Date: Mon, 23 Jan 2012 11:47:40 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: vmscan: check mem cgroup over reclaimed
Message-ID: <20120123104731.GA1707@cmpxchg.org>
References: <CAJd=RBBG5X8=vkdRTCZ1bvTaVxPAVun9O+yiX0SM6yDzrxDGDQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBBG5X8=vkdRTCZ1bvTaVxPAVun9O+yiX0SM6yDzrxDGDQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jan 23, 2012 at 09:55:07AM +0800, Hillf Danton wrote:
> To avoid reduction in performance of reclaimee, checking overreclaim is added
> after shrinking lru list, when pages are reclaimed from mem cgroup.
> 
> If over reclaim occurs, shrinking remaining lru lists is skipped, and no more
> reclaim for reclaim/compaction.
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
> 
> --- a/mm/vmscan.c	Mon Jan 23 00:23:10 2012
> +++ b/mm/vmscan.c	Mon Jan 23 09:57:20 2012
> @@ -2086,6 +2086,7 @@ static void shrink_mem_cgroup_zone(int p
>  	unsigned long nr_reclaimed, nr_scanned;
>  	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
>  	struct blk_plug plug;
> +	bool memcg_over_reclaimed = false;
> 
>  restart:
>  	nr_reclaimed = 0;
> @@ -2103,6 +2104,11 @@ restart:
> 
>  				nr_reclaimed += shrink_list(lru, nr_to_scan,
>  							    mz, sc, priority);
> +
> +				memcg_over_reclaimed = !scanning_global_lru(mz)
> +					&& (nr_reclaimed >= nr_to_reclaim);
> +				if (memcg_over_reclaimed)
> +					goto out;

Since this merge window, scanning_global_lru() is always false when
the memory controller is enabled, i.e. most common configurations and
distribution kernels.

This will with quite likely have bad effects on zone balancing,
pressure balancing between anon/file lru etc, while you haven't shown
that any workloads actually benefit from this.

Submitting patches like this without mentioning a problematic scenario
and numbers that demonstrate that the patch improve it is not helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
