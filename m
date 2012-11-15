Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 923CE6B00A2
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 03:45:39 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 193023EE0B5
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 17:45:38 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F29A745DE52
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 17:45:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CD60545DE51
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 17:45:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BD7FD1DB8040
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 17:45:37 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 60C6E1DB8042
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 17:45:37 +0900 (JST)
Message-ID: <50A4AB9E.4030106@jp.fujitsu.com>
Date: Thu, 15 Nov 2012 17:45:18 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 2/4] mm, oom: cleanup pagefault oom handler
References: <alpine.DEB.2.00.1211140111190.32125@chino.kir.corp.google.com> <alpine.DEB.2.00.1211140113020.32125@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1211140113020.32125@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(2012/11/14 18:15), David Rientjes wrote:
> To lock the entire system from parallel oom killing, it's possible to
> pass in a zonelist with all zones rather than using
> for_each_populated_zone() for the iteration.  This obsoletes
> try_set_system_oom() and clear_system_oom() so that they can be removed.
>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: David Rientjes <rientjes@google.com>

I'm sorry if I missed something...

> ---
>   mm/oom_kill.c |   49 +++++++------------------------------------------
>   1 files changed, 7 insertions(+), 42 deletions(-)
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -591,43 +591,6 @@ void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_mask)
>   	spin_unlock(&zone_scan_lock);
>   }
>
> -/*
> - * Try to acquire the oom killer lock for all system zones.  Returns zero if a
> - * parallel oom killing is taking place, otherwise locks all zones and returns
> - * non-zero.
> - */
> -static int try_set_system_oom(void)
> -{
> -	struct zone *zone;
> -	int ret = 1;
> -
> -	spin_lock(&zone_scan_lock);
> -	for_each_populated_zone(zone)
> -		if (zone_is_oom_locked(zone)) {
> -			ret = 0;
> -			goto out;
> -		}
> -	for_each_populated_zone(zone)
> -		zone_set_flag(zone, ZONE_OOM_LOCKED);
> -out:
> -	spin_unlock(&zone_scan_lock);
> -	return ret;
> -}
> -
> -/*
> - * Clears ZONE_OOM_LOCKED for all system zones so that failed allocation
> - * attempts or page faults may now recall the oom killer, if necessary.
> - */
> -static void clear_system_oom(void)
> -{
> -	struct zone *zone;
> -
> -	spin_lock(&zone_scan_lock);
> -	for_each_populated_zone(zone)
> -		zone_clear_flag(zone, ZONE_OOM_LOCKED);
> -	spin_unlock(&zone_scan_lock);
> -}
> -
>   /**
>    * out_of_memory - kill the "best" process when we run out of memory
>    * @zonelist: zonelist pointer
> @@ -708,15 +671,17 @@ out:
>
>   /*
>    * The pagefault handler calls here because it is out of memory, so kill a
> - * memory-hogging task.  If a populated zone has ZONE_OOM_LOCKED set, a parallel
> - * oom killing is already in progress so do nothing.  If a task is found with
> - * TIF_MEMDIE set, it has been killed so do nothing and allow it to exit.
> + * memory-hogging task.  If any populated zone has ZONE_OOM_LOCKED set, a
> + * parallel oom killing is already in progress so do nothing.
>    */
>   void pagefault_out_of_memory(void)
>   {
> -	if (try_set_system_oom()) {
> +	struct zonelist *zonelist = node_zonelist(first_online_node,
> +						  GFP_KERNEL);


why GFP_KERNEL ? not GFP_HIGHUSER_MOVABLE ?

Thanks,
-Kame

> +
> +	if (try_set_zonelist_oom(zonelist, GFP_KERNEL)) {
>   		out_of_memory(NULL, 0, 0, NULL, false);
> -		clear_system_oom();
> +		clear_zonelist_oom(zonelist, GFP_KERNEL);
>   	}
>   	schedule_timeout_killable(1);
>   }
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
