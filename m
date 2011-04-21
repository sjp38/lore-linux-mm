Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 69EB28D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 00:53:12 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 29FE43EE0C1
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 13:53:10 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0774C2AEA8F
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 13:53:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E02512E68C2
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 13:53:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CF1841DB804C
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 13:53:06 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 96D2E1DB8042
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 13:53:06 +0900 (JST)
Date: Thu, 21 Apr 2011 13:46:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V6 00/10] memcg: per cgroup background reclaim
Message-Id: <20110421134627.6a7a6ad5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTimp+=soLEH7M8yUpsLLssjgyKrL4w@mail.gmail.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421025107.GG2333@cmpxchg.org>
	<20110421130016.3333cb39.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimp+=soLEH7M8yUpsLLssjgyKrL4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Wed, 20 Apr 2011 21:24:07 -0700
Ying Han <yinghan@google.com> wrote:

> On Wed, Apr 20, 2011 at 9:00 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > > > Two watermarks ("high_wmark", "low_wmark") are added to trigger the
> > > > background reclaim and stop it. The watermarks are calculated based
> > > > on the cgroup's limit_in_bytes.
> > >
> > > Which brings me to the next issue: making the watermarks configurable.
> > >
> > > You argued that having them adjustable from userspace is required for
> > > overcommitting the hardlimits and per-memcg kswapd reclaim not kicking
> > > in in case of global memory pressure.  But that is only a problem
> > > because global kswapd reclaim is (apart from soft limit reclaim)
> > > unaware of memory control groups.
> > >
> > > I think the much better solution is to make global kswapd memcg aware
> > > (with the above mentioned round-robin reclaim scheduler), compared to
> > > adding new (and final!) kernel ABI to avoid an internal shortcoming.
> > >
> >
> > I don't think its a good idea to kick kswapd even when free memory is
> > enough.
> >
> > If memcg-kswapd implemted, I'd like to add auto-cgroup for memcg-kswapd and
> > limit its cpu usage because it works even when memory is not in-short.
> >
> 
> How are we gonna isolate the memcg-kswapd cpu usage under the workqueue
> model?
> 

Admin can limit the total cpu usage of memcg-kswapd. So, using private
workqueue model seems to make sense.
If background-reclaim uses up its cpu share, heavy worker memcg will hit
direct reclaim and need to consume its own cpu time. I think it's fair. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
