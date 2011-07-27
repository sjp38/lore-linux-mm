Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 514566B00EE
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 07:58:23 -0400 (EDT)
Date: Wed, 27 Jul 2011 13:58:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCHv4 09/11] memcg: Use *_dec_not_zero instead of *_add_unless
Message-ID: <20110727115815.GC4024@tiehlicka.suse.cz>
References: <1311760070-21532-1-git-send-email-sven@narfation.org>
 <1311760070-21532-9-git-send-email-sven@narfation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1311760070-21532-9-git-send-email-sven@narfation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sven Eckelmann <sven@narfation.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Wed 27-07-11 11:47:48, Sven Eckelmann wrote:
> atomic_dec_not_zero is defined for each architecture through
> <linux/atomic.h> to provide the functionality of
> atomic_add_unless(x, -1, 0).

yes, I like it because atomic_dec_* is more consistent (at least from
the code reading) with atomic_inc used by mem_cgroup_mark_under_oom
which.

> 
> Signed-off-by: Sven Eckelmann <sven@narfation.org>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: linux-mm@kvack.org

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5f84d23..00a7580 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1909,10 +1909,10 @@ static void mem_cgroup_unmark_under_oom(struct mem_cgroup *mem)
>  	/*
>  	 * When a new child is created while the hierarchy is under oom,
>  	 * mem_cgroup_oom_lock() may not be called. We have to use
> -	 * atomic_add_unless() here.
> +	 * atomic_dec_not_zero() here.
>  	 */
>  	for_each_mem_cgroup_tree(iter, mem)
> -		atomic_add_unless(&iter->under_oom, -1, 0);
> +		atomic_dec_not_zero(&iter->under_oom);
>  }
>  
>  static DEFINE_SPINLOCK(memcg_oom_lock);
> -- 
> 1.7.5.4
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
