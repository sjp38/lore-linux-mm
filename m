Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A2DFF6B0025
	for <linux-mm@kvack.org>; Thu, 12 May 2011 19:57:12 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A66453EE0B6
	for <linux-mm@kvack.org>; Fri, 13 May 2011 08:57:09 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DC1F45DE9A
	for <linux-mm@kvack.org>; Fri, 13 May 2011 08:57:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A97545DE92
	for <linux-mm@kvack.org>; Fri, 13 May 2011 08:57:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AE5DE08004
	for <linux-mm@kvack.org>; Fri, 13 May 2011 08:57:09 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2007E1DB8038
	for <linux-mm@kvack.org>; Fri, 13 May 2011 08:57:09 +0900 (JST)
Date: Fri, 13 May 2011 08:50:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [rfc patch 2/6] vmscan: make distinction between memcg reclaim
 and LRU list selection
Message-Id: <20110513085027.25b25a47.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1305212038-15445-3-git-send-email-hannes@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
	<1305212038-15445-3-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 12 May 2011 16:53:54 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> The reclaim code has a single predicate for whether it currently
> reclaims on behalf of a memory cgroup, as well as whether it is
> reclaiming from the global LRU list or a memory cgroup LRU list.
> 
> Up to now, both cases always coincide, but subsequent patches will
> change things such that global reclaim will scan memory cgroup lists.
> 
> This patch adds a new predicate that tells global reclaim from memory
> cgroup reclaim, and then changes all callsites that are actually about
> global reclaim heuristics rather than strict LRU list selection.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>


Hmm, isn't it better to merge this to patches where the meaning of
new variable gets clearer ?

> ---
>  mm/vmscan.c |   96 ++++++++++++++++++++++++++++++++++------------------------
>  1 files changed, 56 insertions(+), 40 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f6b435c..ceeb2a5 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -104,8 +104,12 @@ struct scan_control {
>  	 */
>  	reclaim_mode_t reclaim_mode;
>  
> -	/* Which cgroup do we reclaim from */
> -	struct mem_cgroup *mem_cgroup;
> +	/*
> +	 * The memory cgroup we reclaim on behalf of, and the one we
> +	 * are currently reclaiming from.
> +	 */
> +	struct mem_cgroup *memcg;
> +	struct mem_cgroup *current_memcg;
>  

I wonder if you avoid renaming exisiting one, the patch will
be clearer...



>  	/*
>  	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
> @@ -154,16 +158,24 @@ static LIST_HEAD(shrinker_list);
>  static DECLARE_RWSEM(shrinker_rwsem);
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> -#define scanning_global_lru(sc)	(!(sc)->mem_cgroup)
> +static bool global_reclaim(struct scan_control *sc)
> +{
> +	return !sc->memcg;
> +}
> +static bool scanning_global_lru(struct scan_control *sc)
> +{
> +	return !sc->current_memcg;
> +}


Could you add comments ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
