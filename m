Date: Sat, 01 Mar 2008 22:35:44 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 09/21] (NEW) improve reclaim balancing
In-Reply-To: <20080228192928.648701083@redhat.com>
References: <20080228192908.126720629@redhat.com> <20080228192928.648701083@redhat.com>
Message-Id: <20080301221216.529E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi

> +	/*
> +	 * Even if we did not try to evict anon pages at all, we want to
> +	 * rebalance the anon lru active/inactive ratio.
> +	 */
> +	if (inactive_anon_low(zone))
> +		shrink_list(NR_ACTIVE_ANON, SWAP_CLUSTER_MAX, zone, sc,
> +								priority);
> +

you want check global zone status, right?
if so, this statement only do that at global scan.


- kosaki

---
 mm/vmscan.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c       2008-03-01 22:18:42.000000000 +0900
+++ b/mm/vmscan.c       2008-03-01 22:42:42.000000000 +0900
@@ -1319,9 +1319,9 @@ static unsigned long shrink_zone(int pri
         * Even if we did not try to evict anon pages at all, we want to
         * rebalance the anon lru active/inactive ratio.
         */
-       if (inactive_anon_low(zone))
+       if (scan_global_lru(sc) && inactive_anon_low(zone))
                shrink_list(NR_ACTIVE_ANON, SWAP_CLUSTER_MAX, zone, sc,
                                                               priority);

        throttle_vm_writeout(sc->gfp_mask);
        return nr_reclaimed;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
