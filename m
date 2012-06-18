Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 5B0026B0062
	for <linux-mm@kvack.org>; Sun, 17 Jun 2012 22:56:27 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 486953EE0C0
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 11:56:25 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E51D45DE59
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 11:56:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CDA045DE52
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 11:56:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EA4B01DB802C
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 11:56:24 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C26B1DB803E
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 11:56:24 +0900 (JST)
Message-ID: <4FDE9857.7000801@jp.fujitsu.com>
Date: Mon, 18 Jun 2012 11:54:15 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] mm: memcg detect no memcgs above softlimit under
 zone reclaim.
References: <1339007031-10527-1-git-send-email-yinghan@google.com>
In-Reply-To: <1339007031-10527-1-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

(2012/06/07 3:23), Ying Han wrote:
> In memcg kernel, cgroup under its softlimit is not targeted under global
> reclaim. It could be possible that all memcgs are under their softlimit for
> a particular zone. If that is the case, the current implementation will
> burn extra cpu cycles without making forward progress.
> 
> The idea is from LSF discussion where we detect it after the first round of
> scanning and restart the reclaim by not looking at softlimit at all. This
> allows us to make forward progress on shrink_zone().
> 
> Signed-off-by: Ying Han<yinghan@google.com>

Hm, how about adding sc->ignore_softlimit and preserve the result among priority loops ?

Is it better to check 'ignore_softlimit' at every priority updates ?

Thanks,
-Kame

> ---
>   mm/vmscan.c |   18 ++++++++++++++++--
>   1 files changed, 16 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 0560783..5d036f5 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2142,6 +2142,10 @@ static void shrink_zone(int priority, struct zone *zone,
>   		.priority = priority,
>   	};
>   	struct mem_cgroup *memcg;
> +	bool over_softlimit, ignore_softlimit = false;
> +
> +restart:
> +	over_softlimit = false;
> 
>   	memcg = mem_cgroup_iter(root, NULL,&reclaim);
>   	do {
> @@ -2163,9 +2167,14 @@ static void shrink_zone(int priority, struct zone *zone,
>   		 * we have to reclaim under softlimit instead of burning more
>   		 * cpu cycles.
>   		 */
> -		if (!global_reclaim(sc) || priority<  DEF_PRIORITY - 2 ||
> -				should_reclaim_mem_cgroup(memcg))
> +		if (ignore_softlimit || !global_reclaim(sc) ||
> +				priority<  DEF_PRIORITY - 2 ||
> +				should_reclaim_mem_cgroup(memcg)) {
>   			shrink_mem_cgroup_zone(priority,&mz, sc);
> +
> +			over_softlimit = true;
> +		}
> +
>   		/*
>   		 * Limit reclaim has historically picked one memcg and
>   		 * scanned it with decreasing priority levels until
> @@ -2182,6 +2191,11 @@ static void shrink_zone(int priority, struct zone *zone,
>   		}
>   		memcg = mem_cgroup_iter(root, memcg,&reclaim);
>   	} while (memcg);
> +
> +	if (!over_softlimit) {
> +		ignore_softlimit = true;
> +		goto restart;
> +	}
>   }
> 
>   /* Returns true if compaction should go ahead for a high-order request */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
