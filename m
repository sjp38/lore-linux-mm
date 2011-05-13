Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC4C6B0025
	for <linux-mm@kvack.org>; Fri, 13 May 2011 02:59:45 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E0D3F3EE0C1
	for <linux-mm@kvack.org>; Fri, 13 May 2011 15:59:41 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C6BF445DE4D
	for <linux-mm@kvack.org>; Fri, 13 May 2011 15:59:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9214545DD74
	for <linux-mm@kvack.org>; Fri, 13 May 2011 15:59:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8203E1DB8041
	for <linux-mm@kvack.org>; Fri, 13 May 2011 15:59:41 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 440C81DB803A
	for <linux-mm@kvack.org>; Fri, 13 May 2011 15:59:41 +0900 (JST)
Date: Fri, 13 May 2011 15:52:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][BUGFIX] memcg fix zone congestion
Message-Id: <20110513155256.bc9295c5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110512232500.2ce372da.akpm@linux-foundation.org>
References: <20110513121030.08fcae08.kamezawa.hiroyu@jp.fujitsu.com>
	<20110512232500.2ce372da.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>

On Thu, 12 May 2011 23:25:00 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 13 May 2011 12:10:30 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > 
> > ZONE_CONGESTED should be a state of global memory reclaim.
> > If not, a busy memcg sets this and give unnecessary throttoling in
> > wait_iff_congested() against memory recalim in other contexts. This makes
> > system performance bad.
> > 
> > I'll think about "memcg is congested!" flag is required or not, later.
> > But this fix is required 1st.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/vmscan.c |    3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > Index: mmotm-May11/mm/vmscan.c
> > ===================================================================
> > --- mmotm-May11.orig/mm/vmscan.c
> > +++ mmotm-May11/mm/vmscan.c
> > @@ -941,7 +941,8 @@ keep_lumpy:
> >  	 * back off and wait for congestion to clear because further reclaim
> >  	 * will encounter the same problem
> >  	 */
> > -	if (nr_dirty == nr_congested && nr_dirty != 0)
> > +	if (scanning_global_lru(sc) &&
> > +	    nr_dirty == nr_congested && nr_dirty != 0)
> >  		zone_set_flag(zone, ZONE_CONGESTED);
> >  
> 
> nit: which is more probable?  nr_dirty==nr_congested or
> scanning_global_lru(sc)?  
> 
> If the user is actually _using_ memcg then
> 

If the user uses memcg, yes, nr_dirty == nr_congested is more probable.
If user doesn't, scanning_global_lru() returns always true.

> --- a/mm/vmscan.c~a
> +++ a/mm/vmscan.c
> @@ -937,7 +937,7 @@ keep_lumpy:
>  	 * back off and wait for congestion to clear because further reclaim
>  	 * will encounter the same problem
>  	 */
> -	if (nr_dirty == nr_congested && nr_dirty != 0)
> +	if (nr_dirty == nr_congested && scanning_global_lru(sc) && nr_dirty)
>  		zone_set_flag(zone, ZONE_CONGESTED);
>  
>  	free_page_list(&free_pages);
> 
> 
> is more efficient.  If the user isn't using memcg then your patch is faster?
> 

Hmm, maybe your fix is always faster. But in many case, if nr_congested == nr_dirty,
nr_dirty == 0 because vmscan just finds clean pages...fast path.
So, nr_dirty should be 1st ?

How about this ?
==

ZONE_CONGESTED should be a state of global memory reclaim.
Changelog:v1->v2
 - fixed the order of conditions.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: mmotm-May11/mm/vmscan.c
===================================================================
--- mmotm-May11.orig/mm/vmscan.c
+++ mmotm-May11/mm/vmscan.c
@@ -941,7 +941,7 @@ keep_lumpy:
 	 * back off and wait for congestion to clear because further reclaim
 	 * will encounter the same problem
 	 */
-	if (nr_dirty == nr_congested && nr_dirty != 0)
+	if (nr_dirty && nr_dirty == nr_congested &&  scanning_global_lru(sc))
 		zone_set_flag(zone, ZONE_CONGESTED);
 
 	free_page_list(&free_pages);





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
