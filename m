Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id ECB018D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 01:48:46 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 89B143EE0BC
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:48:42 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6681745DE95
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:48:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EC1B45DE78
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:48:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F2E7E18002
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:48:42 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F2FA31DB8038
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 14:48:41 +0900 (JST)
Date: Thu, 21 Apr 2011 14:41:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V6 00/10] memcg: per cgroup background reclaim
Message-Id: <20110421144156.fc1ce9ec.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110421050851.GI2333@cmpxchg.org>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421025107.GG2333@cmpxchg.org>
	<20110421130016.3333cb39.kamezawa.hiroyu@jp.fujitsu.com>
	<20110421050851.GI2333@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 21 Apr 2011 07:08:51 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Thu, Apr 21, 2011 at 01:00:16PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu, 21 Apr 2011 04:51:07 +0200
> > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > 
> > > > If the cgroup is configured to use per cgroup background reclaim, a kswapd
> > > > thread is created which only scans the per-memcg LRU list.
> > > 
> > > We already have direct reclaim, direct reclaim on behalf of a memcg,
> > > and global kswapd-reclaim.  Please don't add yet another reclaim path
> > > that does its own thing and interacts unpredictably with the rest of
> > > them.
> > > 
> > > As discussed on LSF, we want to get rid of the global LRU.  So the
> > > goal is to have each reclaim entry end up at the same core part of
> > > reclaim that round-robin scans a subset of zones from a subset of
> > > memory control groups.
> > 
> > It's not related to this set. And I think even if we remove global LRU,
> > global-kswapd and memcg-kswapd need to do independent work.
> > 
> > global-kswapd : works for zone/node balancing and making free pages,
> >                 and compaction. select a memcg vicitm and ask it
> >                 to reduce memory with regard to gfp_mask. Starts its work
> >                 when zone/node is unbalanced.
> 
> For soft limit reclaim (which is triggered by global memory pressure),
> we want to scan a group of memory cgroups equally in round robin
> fashion.  I think at LSF we established that it is not fair to find
> the one that exceeds its limit the most and hammer it until memory
> pressure is resolved or there is another group with more excess.
> 

Why do you guys like to make a mixture discussion of softlimit and
high/low watermarks ?


> So even for global kswapd, sooner or later we need a mechanism to
> apply equal pressure to a set of memcgs.
> 

yes, please do rework.


> With the removal of the global LRU, we ALWAYS operate on a set of
> memcgs in a round-robin fashion, not just for soft limit reclaim.
> 
> So yes, these are two different things, but they have the same
> requirements.
> 

Please do make changes all again.


> > memcg-kswapd  : works for reducing usage of memory, no interests on
> >                 zone/nodes. Starts when high/low watermaks hits.
> 
> When the watermark is hit in the charge path, we want to wake up the
> daemon to reclaim from a specific memcg.
> 
> When multiple memcgs exceed their watermarks in parallel (after all,
> we DO allow concurrency), we again have a group of memcgs we want to
> reclaim from in a fair fashion until their watermarks are met again.
> 

It's never be reason to make kswapd wake up.


> And memcg reclaim is not oblivious to nodes and zones, right now, we
> also do mind the current node and respect the zone balancing when we
> do direct reclaim on behalf of a memcg.
> 
If you find problem, please fix.


> So, to be honest, I really don't see how both cases should be
> independent from each other.  On the contrary, I see very little
> difference between them.  The entry path differs slightly as well as
> the predicate for the set of memcgs to scan.  But most of the worker
> code is exactly the same, no?
> 

No. memcg-background-reclaim will need to have more better algorithm finally
as using file/anon ratio, swapiness, dirty-ratio on memecg. And it works
as a service for helping performance by kernel.

global-background-reclaim will need to depends on global file/anon ratio
and swapiness, dirty-ratio. This works as a service for maintaining free
memory, by kernel.

I don't want to make mixture here until we convice we can do that.

memcg-kswapd does.
 1. pick up memcg
 2. do scan and reclaim

global-kswapd does
 1. pick up zone.
 2. pick up suitable memcg for reclaiming this zone's page
 3. check zone balancing.

We _may_ be able to finally merge them, but I'm unsure. Total rework after
implementing nicely-work-memcg-kswapd is welcomed.

I want to fix problems one by one. Reworking around this at removing LRU is
not heavy burden, but will be a interesting job. At rework, 
global kswapd/global direct-reclaim need to consider
  - get free memory
  - compaction of multi-order pages.
  - balancing zones
  - balancing nodes
  - OOM.
  + balancing memcgs (with softlimit) and LRU ordering
  + dirty-ratio (it may be better to avoid picking busy memcg by kswapd.)
  + hi/low watermak (if you want).

"+" is new things added by memcg.
We need to establish each ones and needs performance/statistics check for each.

I don't think we can implement them all perfectly with a rush. I think I'll
see unexpected problems on my way to realistic solution

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
> > 
> > I don't think its a good idea to kick kswapd even when free memory is enough.
> 
> This depends on what kswapd is supposed to be doing.  I don't say we
> should reclaim from all memcgs (i.e. globally) just because one memcg
> hits its watermark, of course.
> 
> But the argument was that we need the watermarks configurable to force
> per-memcg reclaim even when the hard limits are overcommitted, because
> global reclaim does not do a fair job to balance memcgs.  

I cannot understand here. Why global reclaim need to do works other than
balancing zones ? And what is balancing memcg ? Mentioning softlimit ?

> My counter
> proposal is to fix global reclaim instead and apply equal pressure on
> memcgs, such that we never have to tweak per-memcg watermarks to
> achieve the same thing.
> 

I cannot undestand this, either. Don't you make a mixture of discussion
with softlimit ? Making global kswapd better is another discussion.

Hi/Low watermak is a feature as it is. It the 3rd way to limit memory
usage. Comaparing hard_limit, soft_limit, it works in moderate way in background
and works regardless of usage of global memory. I think it's valid to have
ineterfaces to tuning this.


Thanks,
-Kame

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
