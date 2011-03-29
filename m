Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 584D18D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:39:16 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp07.in.ibm.com (8.14.4/8.13.1) with ESMTP id p2TFd32r013023
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 21:09:03 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2TFcwXK4354274
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 21:09:03 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2TFcvCA002489
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 02:38:58 +1100
Date: Tue, 29 Mar 2011 21:08:53 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] check the return value of soft_limit reclaim
Message-ID: <20110329153853.GD2879@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1301292775-4091-1-git-send-email-yinghan@google.com>
 <1301292775-4091-2-git-send-email-yinghan@google.com>
 <20110328163311.127575fa.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110328163311.127575fa.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2011-03-28 16:33:11]:

> Hi,
> 
> This patch looks good to me, except for one nitpick.
> 
> On Sun, 27 Mar 2011 23:12:54 -0700
> Ying Han <yinghan@google.com> wrote:
> 
> > In the global background reclaim, we do soft reclaim before scanning the
> > per-zone LRU. However, the return value is ignored. This patch adds the logic
> > where no per-zone reclaim happens if the soft reclaim raise the free pages
> > above the zone's high_wmark.
> > 
> > I did notice a similar check exists but instead leaving a "gap" above the
> > high_wmark(the code right after my change in vmscan.c). There are discussions
> > on whether or not removing the "gap" which intends to balance pressures across
> > zones over time. Without fully understand the logic behind, I didn't try to
> > merge them into one, but instead adding the condition only for memcg users
> > who care a lot on memory isolation.
> > 
> > Signed-off-by: Ying Han <yinghan@google.com>
> > ---
> >  mm/vmscan.c |   16 +++++++++++++++-
> >  1 files changed, 15 insertions(+), 1 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 060e4c1..e4601c5 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2320,6 +2320,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
> >  	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
> >  	unsigned long total_scanned;
> >  	struct reclaim_state *reclaim_state = current->reclaim_state;
> > +	unsigned long nr_soft_reclaimed;
> >  	struct scan_control sc = {
> >  		.gfp_mask = GFP_KERNEL,
> >  		.may_unmap = 1,
> > @@ -2413,7 +2414,20 @@ loop_again:
> >  			 * Call soft limit reclaim before calling shrink_zone.
> >  			 * For now we ignore the return value
> 
> You should remove this comment too.
> 
> But, Balbir-san, do you remember why did you ignore the return value here ?
>

We do that since soft limit reclaim cannot help us make a decision
from the return value. balance_gap is recomputed following this
routine. May be it might make sense to increment sc.nr_reclaimed based
on the return value? 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
