Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 4D7B26B0044
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 11:04:33 -0400 (EDT)
Date: Mon, 26 Mar 2012 17:04:29 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v6 1/7] mm/memcg: scanning_global_lru means
 mem_cgroup_disabled
Message-ID: <20120326150429.GA22754@tiehlicka.suse.cz>
References: <20120322214944.27814.42039.stgit@zurg>
 <20120322215616.27814.40563.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120322215616.27814.40563.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>

[Adding Johannes to CC]

On Fri 23-03-12 01:56:16, Konstantin Khlebnikov wrote:
> From: Hugh Dickins <hughd@google.com>
> 
> Although one has to admire the skill with which it has been concealed,
> scanning_global_lru(mz) is actually just an interesting way to test
> mem_cgroup_disabled().  Too many developer hours have been wasted on
> confusing it with global_reclaim(): just use mem_cgroup_disabled().

Is this really correct?

> Signed-off-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Glauber Costa <glommer@parallels.com>
> ---
>  mm/vmscan.c |   18 ++++--------------
>  1 files changed, 4 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 49f15ef..c684f44 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
[...]
> @@ -1806,7 +1796,7 @@ static int inactive_anon_is_low(struct mem_cgroup_zone *mz)
>  	if (!total_swap_pages)
>  		return 0;
>  
> -	if (!scanning_global_lru(mz))
> +	if (!mem_cgroup_disabled())
>  		return mem_cgroup_inactive_anon_is_low(mz->mem_cgroup,
>  						       mz->zone);

mem_cgroup_inactive_anon_is_low calculation is slightly different than
what we have for cgroup_disabled case. calculate_zone_inactive_ratio
considers _all_ present pages in the zone while memcg variant only
active+inactive.

>  
> @@ -1845,7 +1835,7 @@ static int inactive_file_is_low_global(struct zone *zone)
>   */
>  static int inactive_file_is_low(struct mem_cgroup_zone *mz)
>  {
> -	if (!scanning_global_lru(mz))
> +	if (!mem_cgroup_disabled())
>  		return mem_cgroup_inactive_file_is_low(mz->mem_cgroup,
>  						       mz->zone);
>  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

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
