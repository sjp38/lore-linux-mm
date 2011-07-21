Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E15E86B004A
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 06:38:04 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CD40C3EE081
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 19:38:00 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A9E6A45DE87
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 19:38:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8ED7C45DE68
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 19:38:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F2E3E08001
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 19:38:00 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4828A1DB8038
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 19:38:00 +0900 (JST)
Date: Thu, 21 Jul 2011 19:30:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] memcg: get rid of percpu_charge_mutex lock
Message-Id: <20110721193051.cd3266e5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <2bfb2b7687c1a6b39da2a04689190725075cc4f8.1311241300.git.mhocko@suse.cz>
References: <cover.1311241300.git.mhocko@suse.cz>
	<2bfb2b7687c1a6b39da2a04689190725075cc4f8.1311241300.git.mhocko@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Thu, 21 Jul 2011 09:58:24 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> percpu_charge_mutex protects from multiple simultaneous per-cpu charge
> caches draining because we might end up having too many work items.
> At least this was the case until 26fe6168 (memcg: fix percpu cached
> charge draining frequency) when we introduced a more targeted draining
> for async mode.
> Now that also sync draining is targeted we can safely remove mutex
> because we will not send more work than the current number of CPUs.
> FLUSHING_CACHED_CHARGE protects from sending the same work multiple
> times and stock->nr_pages == 0 protects from pointless sending a work
> if there is obviously nothing to be done. This is of course racy but we
> can live with it as the race window is really small (we would have to
> see FLUSHING_CACHED_CHARGE cleared while nr_pages would be still
> non-zero).
> The only remaining place where we can race is synchronous mode when we
> rely on FLUSHING_CACHED_CHARGE test which might have been set by other
> drainer on the same group but we should wait in that case as well.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

A concern.

> ---
>  mm/memcontrol.c |   12 ++----------
>  1 files changed, 2 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8180cd9..9d49a12 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2065,7 +2065,6 @@ struct memcg_stock_pcp {
>  #define FLUSHING_CACHED_CHARGE	(0)
>  };
>  static DEFINE_PER_CPU(struct memcg_stock_pcp, memcg_stock);
> -static DEFINE_MUTEX(percpu_charge_mutex);
>  
>  /*
>   * Try to consume stocked charge on this cpu. If success, one page is consumed
> @@ -2166,7 +2165,8 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
>  
>  	for_each_online_cpu(cpu) {
>  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> -		if (test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> +		if (root_mem == stock->cached &&
> +				test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
>  			flush_work(&stock->work);

Doesn't this new check handle hierarchy ?
css_is_ancestor() will be required if you do this check.

BTW, this change should be in other patch, I think.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
