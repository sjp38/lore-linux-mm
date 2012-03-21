Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 052816B004A
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 09:26:26 -0400 (EDT)
Date: Wed, 21 Mar 2012 14:26:23 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: Do not open code accesses to res_counter members
Message-ID: <20120321132623.GA4251@tiehlicka.suse.cz>
References: <1332262424-13484-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1332262424-13484-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue 20-03-12 20:53:44, Glauber Costa wrote:
> We should use the acessor res_counter_read_u64 for that.
> Although a purely cosmetic change is sometimes better of delayed,
> to avoid conflicting with other people's work, we are starting to
> have people touching this code as well, and reproducing the open
> code behavior because that's the standard =)
> 
> Time to fix it, then.

Looks good to me
Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 87a1e21..27c1bfa 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3708,7 +3708,7 @@ move_account:
>  			goto try_to_free;
>  		cond_resched();
>  	/* "ret" should also be checked to ensure all lists are empty. */
> -	} while (memcg->res.usage > 0 || ret);
> +	} while (res_counter_read_u64(&memcg->res, RES_USAGE) > 0 || ret);
>  out:
>  	css_put(&memcg->css);
>  	return ret;
> @@ -3723,7 +3723,7 @@ try_to_free:
>  	lru_add_drain_all();
>  	/* try to free all pages in this cgroup */
>  	shrink = 1;
> -	while (nr_retries && memcg->res.usage > 0) {
> +	while (nr_retries && res_counter_read_u64(&memcg->res, RES_USAGE) > 0) {
>  		int progress;
>  
>  		if (signal_pending(current)) {
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

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
