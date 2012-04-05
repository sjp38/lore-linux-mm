Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 300B16B0092
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 19:53:38 -0400 (EDT)
Date: Thu, 5 Apr 2012 16:53:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: Do not open code accesses to res_counter members
Message-Id: <20120405165335.be409dc6.akpm@linux-foundation.org>
In-Reply-To: <1332262424-13484-1-git-send-email-glommer@parallels.com>
References: <1332262424-13484-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, 20 Mar 2012 20:53:44 +0400
Glauber Costa <glommer@parallels.com> wrote:

> We should use the acessor res_counter_read_u64 for that.
> Although a purely cosmetic change is sometimes better of delayed,
> to avoid conflicting with other people's work, we are starting to
> have people touching this code as well, and reproducing the open
> code behavior because that's the standard =)
> 
> ...
>
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

Actually this fixes bugs on 32-bit machines.  Good luck trying to
demonstrate them at runtime though ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
