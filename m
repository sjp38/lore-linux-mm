Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D41956B0022
	for <linux-mm@kvack.org>; Fri, 13 May 2011 02:17:37 -0400 (EDT)
Date: Thu, 12 May 2011 23:25:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH][BUGFIX] memcg fix zone congestion
Message-Id: <20110512232500.2ce372da.akpm@linux-foundation.org>
In-Reply-To: <20110513121030.08fcae08.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110513121030.08fcae08.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>

On Fri, 13 May 2011 12:10:30 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 
> ZONE_CONGESTED should be a state of global memory reclaim.
> If not, a busy memcg sets this and give unnecessary throttoling in
> wait_iff_congested() against memory recalim in other contexts. This makes
> system performance bad.
> 
> I'll think about "memcg is congested!" flag is required or not, later.
> But this fix is required 1st.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/vmscan.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> Index: mmotm-May11/mm/vmscan.c
> ===================================================================
> --- mmotm-May11.orig/mm/vmscan.c
> +++ mmotm-May11/mm/vmscan.c
> @@ -941,7 +941,8 @@ keep_lumpy:
>  	 * back off and wait for congestion to clear because further reclaim
>  	 * will encounter the same problem
>  	 */
> -	if (nr_dirty == nr_congested && nr_dirty != 0)
> +	if (scanning_global_lru(sc) &&
> +	    nr_dirty == nr_congested && nr_dirty != 0)
>  		zone_set_flag(zone, ZONE_CONGESTED);
>  

nit: which is more probable?  nr_dirty==nr_congested or
scanning_global_lru(sc)?  

If the user is actually _using_ memcg then

--- a/mm/vmscan.c~a
+++ a/mm/vmscan.c
@@ -937,7 +937,7 @@ keep_lumpy:
 	 * back off and wait for congestion to clear because further reclaim
 	 * will encounter the same problem
 	 */
-	if (nr_dirty == nr_congested && nr_dirty != 0)
+	if (nr_dirty == nr_congested && scanning_global_lru(sc) && nr_dirty)
 		zone_set_flag(zone, ZONE_CONGESTED);
 
 	free_page_list(&free_pages);


is more efficient.  If the user isn't using memcg then your patch is faster?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
