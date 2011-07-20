Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1CC126B00FD
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 20:37:39 -0400 (EDT)
Date: Wed, 20 Jul 2011 02:36:53 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 7/8] vmscan: memcg-aware unevictable page rescue scanner
Message-ID: <20110720003653.GA667@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-8-git-send-email-hannes@cmpxchg.org>
 <CALWz4iwDGD8xoUbzi=9Sy7C-njcYqmka_25rQL8RhkN_ArLgDw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALWz4iwDGD8xoUbzi=9Sy7C-njcYqmka_25rQL8RhkN_ArLgDw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 19, 2011 at 03:47:43PM -0700, Ying Han wrote:
> On Tue, May 31, 2011 at 11:25 PM, Johannes Weiner <hannes@cmpxchg.org>wrote:
> 
> > Once the per-memcg lru lists are exclusive, the unevictable page
> > rescue scanner can no longer work on the global zone lru lists.
> >
> > This converts it to go through all memcgs and scan their respective
> > unevictable lists instead.
> >
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  include/linux/memcontrol.h |    2 +
> >  mm/memcontrol.c            |   11 +++++++++
> >  mm/vmscan.c                |   53
> > +++++++++++++++++++++++++++----------------
> >  3 files changed, 46 insertions(+), 20 deletions(-)
> >
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index cb02c00..56c1def 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -60,6 +60,8 @@ extern void mem_cgroup_cancel_charge_swapin(struct
> > mem_cgroup *ptr);
> >
> >  extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct
> > *mm,
> >                                        gfp_t gfp_mask);
> > +struct page *mem_cgroup_lru_to_page(struct zone *, struct mem_cgroup *,
> > +                                   enum lru_list);
> >
> 
> Did we miss a #ifdef case for this function? I got compile error by
> disabling memcg.

I assume it's because the call to it is not optimized away properly in
the disabled case.  I'll have it fixed in the next round, thanks for
letting me know.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
