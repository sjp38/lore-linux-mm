Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id E80926B002C
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 00:14:25 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5520B3EE0BD
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:14:23 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B7CA45DEB4
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:14:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 18A5745DE9E
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:14:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 09BEB1DB8041
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:14:23 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AE8BD1DB803B
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:14:22 +0900 (JST)
Date: Fri, 2 Mar 2012 14:12:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] mm/memcg: scanning_global_lru means
 mem_cgroup_disabled
Message-Id: <20120302141251.4f434632.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120229091539.29236.57783.stgit@zurg>
References: <20120229090748.29236.35489.stgit@zurg>
	<20120229091539.29236.57783.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 29 Feb 2012 13:15:39 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> From: Hugh Dickins <hughd@google.com>
> 
> Although one has to admire the skill with which it has been concealed,
> scanning_global_lru(mz) is actually just an interesting way to test
> mem_cgroup_disabled().  Too many developer hours have been wasted on
> confusing it with global_reclaim(): just use mem_cgroup_disabled().
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Acked-by: KAMEZWA Hiroyuki <kamezawa.hiroyu@jp.fujitu.com>


> ---
>  mm/vmscan.c |   18 ++++--------------
>  1 files changed, 4 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 003b3f5..082fbc2 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -164,26 +164,16 @@ static bool global_reclaim(struct scan_control *sc)
>  {
>  	return !sc->target_mem_cgroup;
>  }
> -
> -static bool scanning_global_lru(struct mem_cgroup_zone *mz)
> -{
> -	return !mz->mem_cgroup;
> -}
>  #else
>  static bool global_reclaim(struct scan_control *sc)
>  {
>  	return true;
>  }
> -
> -static bool scanning_global_lru(struct mem_cgroup_zone *mz)
> -{
> -	return true;
> -}
>  #endif
>  
>  static struct zone_reclaim_stat *get_reclaim_stat(struct mem_cgroup_zone *mz)
>  {
> -	if (!scanning_global_lru(mz))
> +	if (!mem_cgroup_disabled())
>  		return mem_cgroup_get_reclaim_stat(mz->mem_cgroup, mz->zone);
>  
>  	return &mz->zone->reclaim_stat;
> @@ -192,7 +182,7 @@ static struct zone_reclaim_stat *get_reclaim_stat(struct mem_cgroup_zone *mz)
>  static unsigned long zone_nr_lru_pages(struct mem_cgroup_zone *mz,
>  				       enum lru_list lru)
>  {
> -	if (!scanning_global_lru(mz))
> +	if (!mem_cgroup_disabled())
>  		return mem_cgroup_zone_nr_lru_pages(mz->mem_cgroup,
>  						    zone_to_nid(mz->zone),
>  						    zone_idx(mz->zone),
> @@ -1806,7 +1796,7 @@ static int inactive_anon_is_low(struct mem_cgroup_zone *mz)
>  	if (!total_swap_pages)
>  		return 0;
>  
> -	if (!scanning_global_lru(mz))
> +	if (!mem_cgroup_disabled())
>  		return mem_cgroup_inactive_anon_is_low(mz->mem_cgroup,
>  						       mz->zone);
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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
