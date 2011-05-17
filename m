Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6AF8590010B
	for <linux-mm@kvack.org>; Tue, 17 May 2011 19:56:19 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 67BB63EE0BD
	for <linux-mm@kvack.org>; Wed, 18 May 2011 08:56:15 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F6A845DE58
	for <linux-mm@kvack.org>; Wed, 18 May 2011 08:56:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FDDF45DE54
	for <linux-mm@kvack.org>; Wed, 18 May 2011 08:56:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 23ACF1DB8049
	for <linux-mm@kvack.org>; Wed, 18 May 2011 08:56:15 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D64261DB8047
	for <linux-mm@kvack.org>; Wed, 18 May 2011 08:56:14 +0900 (JST)
Date: Wed, 18 May 2011 08:49:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: fix typo in the soft_limit stats.
Message-Id: <20110518084919.988d3d41.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110516171820.124a8fbc.akpm@linux-foundation.org>
References: <1305583230-2111-1-git-send-email-yinghan@google.com>
	<20110516231512.GW16531@cmpxchg.org>
	<BANLkTinohFTQRTViyU5NQ6EGi95xieXwOA@mail.gmail.com>
	<20110516171820.124a8fbc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Mon, 16 May 2011 17:18:20 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 16 May 2011 17:05:02 -0700
> Ying Han <yinghan@google.com> wrote:
> 
> > On Mon, May 16, 2011 at 4:15 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > 
> > > On Mon, May 16, 2011 at 03:00:30PM -0700, Ying Han wrote:
> > > > This fixes the typo in the memory.stat including the following two
> > > > stats:
> > > >
> > > > $ cat /dev/cgroup/memory/A/memory.stat
> > > > total_soft_steal 0
> > > > total_soft_scan 0
> > > >
> > > > And change it to:
> > > >
> > > > $ cat /dev/cgroup/memory/A/memory.stat
> > > > total_soft_kswapd_steal 0
> > > > total_soft_kswapd_scan 0
> > > >
> > > > Signed-off-by: Ying Han <yinghan@google.com>
> > >
> > > I am currently proposing and working on a scheme that makes the soft
> > > limit not only a factor for global memory pressure, but for
> > > hierarchical reclaim in general, to prefer child memcgs during reclaim
> > > that are in excess of their soft limit.
> > >
> > > Because this means prioritizing memcgs over one another, rather than
> > > having explicit soft limit reclaim runs, there is no natural counter
> > > for pages reclaimed due to the soft limit anymore.
> > >
> > > Thus, for the patch that introduces this counter:
> > >
> > > Nacked-by: Johannes Weiner <hannes@cmpxchg.org>
> > >
> > 
> > This patch is fixing a typo of the stats being integrated into mmotm. Does
> > it make sense to fix the
> > existing stats first while we are discussing other approaches?
> > 
> 
> It would be quite bad to add new userspace-visible stats and to then
> take them away again.
> 
yes.

> But given that memcg-add-stats-to-monitor-soft_limit-reclaim.patch is
> queued for 2.6.39-rc1, we could proceed with that plan and then make
> sure that Johannes's changes are merged either prior to 2.6.40 or
> they are never merged at all.
> 
> Or we could just leave out the stats until we're sure.  Not having them
> for a while is not as bad as adding them and then removing them.
> 

I agree. I'm okay with removing them for a while. Johannes and Ying, could you
make a concensus ? IMHO, Johannes' work for making soft-limit co-operative with
hirerachical reclaim makes sense and agree to leave counter name as it is.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
