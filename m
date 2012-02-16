Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 2496D6B004A
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 02:37:58 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E72E93EE0C7
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 16:37:55 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AF6A745DEC4
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 16:37:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 322EC45DEBF
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 16:37:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 046421DB803B
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 16:37:53 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A3E4E1DB8047
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 16:37:52 +0900 (JST)
Date: Thu, 16 Feb 2012 16:36:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: rework inactive_ratio logic
Message-Id: <20120216163620.3794d217.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4F3CA8CA.8020004@openvz.org>
References: <20120215162442.13588.21790.stgit@zurg>
	<20120216103842.0c3e9258.kamezawa.hiroyu@jp.fujitsu.com>
	<4F3CA8CA.8020004@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, 16 Feb 2012 10:57:14 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Wed, 15 Feb 2012 20:24:42 +0400
> > Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
> >
> >> This patch adds mem_cgroup->inactive_ratio calculated from hierarchical memory limit.
> >> It updated at each limit change before shrinking cgroup to this new limit.
> >> Ratios for all child cgroups are updated too, because parent limit can affect them.
> >> Update precedure can be greatly optimized if its performance becomes the problem.
> >> Inactive ratio for unlimited or huge limit does not matter, because we'll never hit it.
> >>
> >> At global reclaim always use global ratio from zone->inactive_ratio.
> >> At mem-cgroup reclaim use inactive_ratio from target memory cgroup,
> >> this is cgroup which hit its limit and cause this reclaimer invocation.
> >>
> >> Thus, global memory reclaimer will try to keep ratio for all lru lists in zone
> >> above one mark, this guarantee that total ratio in this zone will be above too.
> >> Meanwhile mem-cgroup will do the same thing for its lru lists in all zones, and
> >> for all lru lists in all sub-cgroups in hierarchy.
> >>
> >> Also this patch removes some redundant code.
> >>
> >> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
> >
> > Hmm, the main purpose of this patch is to remove calculation per get_scan_ratio() ?
> 
> Technically, it was preparation for "mm: unify inactive_list_is_low()" from "memory book keeping" patchset.
> So, actually its main purpose is moving all active/inactive size calculation to mm/vmscan.c
> 
> Also I trying to figure out most sane logic for inactive_ratio calculation,
> currently global memory reclaimer sometimes uses memcg-calculated ratio, it looks strange.
> 
> >> ---
> >>   include/linux/memcontrol.h |   16 ++------
> >>   mm/memcontrol.c            |   85 ++++++++++++++++++++++++--------------------
> >>   mm/vmscan.c                |   82 +++++++++++++++++++++++-------------------
> >>   3 files changed, 93 insertions(+), 90 deletions(-)
> >>   static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
> >>                                unsigned long long val)
> >>   {
> 
> <cut>
> 
> >> @@ -3422,6 +3416,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
> >>                        else
> >>                                memcg->memsw_is_minimum = false;
> >>                }
> >> +             mem_cgroup_update_inactive_ratio(memcg, val);
> >>                mutex_unlock(&set_limit_mutex);
> >>
> >>                if (!ret)
> >> @@ -3439,6 +3434,12 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
> >>        if (!ret&&  enlarge)
> >>                memcg_oom_recover(memcg);
> >>
> >> +     if (ret) {
> >> +             mutex_lock(&set_limit_mutex);
> >> +             mem_cgroup_update_inactive_ratio(memcg, RESOURCE_MAX);
> >> +             mutex_unlock(&set_limit_mutex);
> >> +     }
> >
> > Why RESOUECE_MAX ?
> 
> resize was failed, so we return back normal value calculated from the current limit.
> target == RESOURCE_MAX isn't clip limit: min(RESOURCE_MAX, limit) == limit
> 

Hm, ok. Thank you.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
