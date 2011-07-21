Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0DB5C6B0092
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 20:04:05 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 13C1D3EE0BB
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 09:04:03 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EE91C45DE5A
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 09:04:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C181145DE56
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 09:04:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B02CF1DB8058
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 09:04:02 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E8F11DB805A
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 09:04:02 +0900 (JST)
Date: Fri, 22 Jul 2011 08:56:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] memcg: prevent from reclaiming if there are per-cpu
 cached charges
Message-Id: <20110722085652.759aded2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110721123012.GD27855@tiehlicka.suse.cz>
References: <cover.1311241300.git.mhocko@suse.cz>
	<0ed59a22cc84037d6e42b258981c75e3a6063899.1311241300.git.mhocko@suse.cz>
	<20110721195411.f4fa9f91.kamezawa.hiroyu@jp.fujitsu.com>
	<20110721123012.GD27855@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Thu, 21 Jul 2011 14:30:12 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 21-07-11 19:54:11, KAMEZAWA Hiroyuki wrote:
> > On Thu, 21 Jul 2011 10:28:10 +0200
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > If we fail to charge an allocation for a cgroup we usually have to fall
> > > back into direct reclaim (mem_cgroup_hierarchical_reclaim).
> > > The charging code, however, currently doesn't care about per-cpu charge
> > > caches which might have up to (nr_cpus - 1) * CHARGE_BATCH pre charged
> > > pages (the current cache is already drained, otherwise we wouldn't get
> > > to mem_cgroup_do_charge).
> > > That can be quite a lot on boxes with big amounts of CPUs so we can end
> > > up reclaiming even though there are charges that could be used. This
> > > will typically happen in a multi-threaded applications pined to many CPUs
> > > which allocates memory heavily.
> > > 
> > 
> > Do you have example and score, numbers on your test ?
> 
> As I said, I haven't seen anything that would affect visibly performance
> but I have seen situations where we reclaimed even though there were
> pre-charges on other CPUs.
> 
> > > Currently we are draining caches during reclaim
> > > (mem_cgroup_hierarchical_reclaim) but this can be already late as we
> > > could have already reclaimed from other groups in the hierarchy.
> > > 
> > > The solution for this would be to synchronously drain charges early when
> > > we fail to charge and retry the charge once more.
> > > I think it still makes sense to keep async draining in the reclaim path
> > > as it is used from other code paths as well (e.g. limit resize). It will
> > > not do any work if we drained previously anyway.
> > > 
> > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > 
> > I don't like this solution, at all.
> > 
> > Assume 2 cpu SMP, (a special case), and 2 applications running under
> > a memcg.
> > 
> >  - one is running in SCHED_FIFO.
> >  - another is running into mem_cgroup_do_charge() and call drain_all_stock_sync().
> > 
> > Then, the application stops until SCHED_FIFO application release the cpu.
> 
> It would have to back off during reclaim anyaway (because we check
> cond_resched during reclaim), right? 
> 

just have cond_resched() on a cpu which calls some reclaim stuff. It will no help.


> > In general, I don't think waiting for schedule_work() against multiple cpus
> > is not quicker than short memory reclaim. 
> 
> You are right, but if you consider small groups then the reclaim can
> make the situation much worse.
> 

If the system has many memory and the container has many cgroup, memory is not
small because ...to use cpu properly, you need memroy. It's a mis-configuration.



> > Adding flush_work() here means that a context switch is requred before
> > calling direct reclaim.
> 
> Is that really a problem? We would context switch during reclaim if
> there is something else that wants CPU anyway.
> Maybe we could drain only if we get a reasonable number of pages back?
> This would require two passes over per-cpu caches to find the number -
> not nice. Or we could drain only those caches that have at least some
> threshold of pages.
> 
> > That's bad. (At leaset, please check __GFP_NOWAIT.)
> 
> Definitely a good idea. Fixed.
> 
> > Please find another way, I think calling synchronous drain here is overkill.
> > There are not important file caches in the most case and reclaim is quick.
> 
> This is, however, really hard to know in advance. If there are used-once
> unmaped file pages then it is much easier to reclaim them for sure.
> Maybe I could check the statistics and decide whether to drain according
> pages we have in the group. Let me think about that.
> 
> > (And async draining runs.)
> > 
> > How about automatically adjusting CHARGE_BATCH and make it small when the
> > system is near to limit ? 
> 
> Hmm, we are already bypassing batching if we are close to the limit,
> aren't we? If we get to the reclaim we fallback to nr_pages allocation
> and so we do not refill the stock.
> Maybe we could check how much we have reclaimed and update the batch
> size accordingly.
> 

Please wait until "background reclaim" stuff. I don't stop it and it will
make this cpu-caching stuff better because we can drain before hitting
limit.

If you cannot wait....

One idea is to have a threshold to call async "drain". For example,

 threshould = limit_of_memory - nr_online_cpu() * (BATCH_SIZE + 1)

 if (usage > threshould)
	drain_all_stock_async().

Then, situation will be much better.



Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
