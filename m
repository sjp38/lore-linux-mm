Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 21CE08D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 02:44:50 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DD6783EE0BB
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 15:44:46 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C1B1145DE54
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 15:44:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AAC1545DE50
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 15:44:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D18F1DB802F
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 15:44:46 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CF52E78005
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 15:44:46 +0900 (JST)
Date: Thu, 21 Apr 2011 15:38:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] weight for memcg background reclaim (Was Re: [PATCH
 V6 00/10] memcg: per cgroup background reclaim
Message-Id: <20110421153804.6da5c5ea.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTimFASy=jsEk=1rZSH2o386-gDgvxA@mail.gmail.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421124059.79990661.kamezawa.hiroyu@jp.fujitsu.com>
	<20110421124836.16769ffc.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimFASy=jsEk=1rZSH2o386-gDgvxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Wed, 20 Apr 2011 23:11:42 -0700
Ying Han <yinghan@google.com> wrote:

> On Wed, Apr 20, 2011 at 8:48 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> >
> > memcg-kswapd visits each memcg in round-robin. But required
> > amounts of works depends on memcg' usage and hi/low watermark
> > and taking it into account will be good.
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/memcontrol.h |    1 +
> >  mm/memcontrol.c            |   17 +++++++++++++++++
> >  mm/vmscan.c                |    2 ++
> >  3 files changed, 20 insertions(+)
> >
> > Index: mmotm-Apr14/include/linux/memcontrol.h
> > ===================================================================
> > --- mmotm-Apr14.orig/include/linux/memcontrol.h
> > +++ mmotm-Apr14/include/linux/memcontrol.h
> > @@ -98,6 +98,7 @@ extern bool mem_cgroup_kswapd_can_sleep(
> >  extern struct mem_cgroup *mem_cgroup_get_shrink_target(void);
> >  extern void mem_cgroup_put_shrink_target(struct mem_cgroup *mem);
> >  extern wait_queue_head_t *mem_cgroup_kswapd_waitq(void);
> > +extern int mem_cgroup_kswapd_bonus(struct mem_cgroup *mem);
> >
> >  static inline
> >  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup
> > *cgroup)
> > Index: mmotm-Apr14/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-Apr14.orig/mm/memcontrol.c
> > +++ mmotm-Apr14/mm/memcontrol.c
> > @@ -4673,6 +4673,23 @@ struct memcg_kswapd_work
> >
> >  struct memcg_kswapd_work       memcg_kswapd_control;
> >
> > +int mem_cgroup_kswapd_bonus(struct mem_cgroup *mem)
> > +{
> > +       unsigned long long usage, lowat, hiwat;
> > +       int rate;
> > +
> > +       usage = res_counter_read_u64(&mem->res, RES_USAGE);
> > +       lowat = res_counter_read_u64(&mem->res, RES_LOW_WMARK_LIMIT);
> > +       hiwat = res_counter_read_u64(&mem->res, RES_HIGH_WMARK_LIMIT);
> > +       if (lowat == hiwat)
> > +               return 0;
> > +
> > +       rate = (usage - hiwat) * 10 / (lowat - hiwat);
> > +       /* If usage is big, we reclaim more */
> > +       return rate * SWAP_CLUSTER_MAX;

This may be buggy and we should have upper limit on this 'rate'.


> > +}
> > +
> >
> 
> 
> > I understand the logic in general, which we would like to reclaim more each
> > time if more work needs to be done. But not quite sure the calculation here,
> > the (usage - hiwat) determines the amount of work of kswapd. And why divide
> > by (lowat - hiwat)? My guess is because the larger the value, the later we
> > will trigger kswapd?
> 
Because memcg-kswapd will require more work on this memcg if usage-high is large.

At first, I'm not sure this logic is good but wanted to show there is a chance to
do some schedule.

We have 2 ways to implement this kind of weight

 1. modify to select memcg logic
    I think we'll see starvation easily. So, didn't this for this time.

 2. modify the amount to nr_to_reclaim
    We'll be able to determine the amount by some calculation using some statistics.

I selected "2" for this time. 

With HIGH/LOW watermark, the admin set LOW watermark as a kind of limit. Then,
if usage is more than LOW watermark, its priority will be higher than other memcg
which has lower (relative) usage. In general, memcg-kswapd can reduce memory down
to high watermak only when the system is not busy. So, this logic tries to remove
more memory from busy cgroup to reduce 'hit limit'.

And I wonder, a memcg containes pages which is related to each other. So, reducing
some amount of pages larger than 32pages at once may make sense.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
