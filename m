Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9BC5D6B004A
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 05:55:03 -0400 (EDT)
Date: Fri, 22 Jul 2011 11:54:59 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/4] memcg: prevent from reclaiming if there are per-cpu
 cached charges
Message-ID: <20110722095459.GE4004@tiehlicka.suse.cz>
References: <cover.1311241300.git.mhocko@suse.cz>
 <0ed59a22cc84037d6e42b258981c75e3a6063899.1311241300.git.mhocko@suse.cz>
 <20110721195411.f4fa9f91.kamezawa.hiroyu@jp.fujitsu.com>
 <20110721123012.GD27855@tiehlicka.suse.cz>
 <20110722085652.759aded2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110722085652.759aded2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Fri 22-07-11 08:56:52, KAMEZAWA Hiroyuki wrote:
> On Thu, 21 Jul 2011 14:30:12 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Thu 21-07-11 19:54:11, KAMEZAWA Hiroyuki wrote:
> > > On Thu, 21 Jul 2011 10:28:10 +0200
[...]
> > > Assume 2 cpu SMP, (a special case), and 2 applications running under
> > > a memcg.
> > > 
> > >  - one is running in SCHED_FIFO.
> > >  - another is running into mem_cgroup_do_charge() and call drain_all_stock_sync().
> > > 
> > > Then, the application stops until SCHED_FIFO application release the cpu.
> > 
> > It would have to back off during reclaim anyaway (because we check
> > cond_resched during reclaim), right? 
> > 
> 
> just have cond_resched() on a cpu which calls some reclaim stuff. It will no help.

I do not understand what you are saying here. What I meant to say is
that the above example is not a big issue because SCHED_FIFO would throw
us away from the CPU during reclaim anyway so waiting for other CPUs
during draining will not too much overhead, although it definitely adds
some.

> > > In general, I don't think waiting for schedule_work() against multiple cpus
> > > is not quicker than short memory reclaim. 
> > 
> > You are right, but if you consider small groups then the reclaim can
> > make the situation much worse.
> > 
> 
> If the system has many memory and the container has many cgroup, memory is not
> small because ...to use cpu properly, you need memroy. It's a mis-configuration.

I don't think so. You might have small, well suited groups for a
specific workloads.

> > > Adding flush_work() here means that a context switch is requred before
> > > calling direct reclaim.
> > 
> > Is that really a problem? We would context switch during reclaim if
> > there is something else that wants CPU anyway.
> > Maybe we could drain only if we get a reasonable number of pages back?
> > This would require two passes over per-cpu caches to find the number -
> > not nice. Or we could drain only those caches that have at least some
> > threshold of pages.
> > 
> > > That's bad. (At leaset, please check __GFP_NOWAIT.)
> > 
> > Definitely a good idea. Fixed.
> > 
> > > Please find another way, I think calling synchronous drain here is overkill.
> > > There are not important file caches in the most case and reclaim is quick.
> > 
> > This is, however, really hard to know in advance. If there are used-once
> > unmaped file pages then it is much easier to reclaim them for sure.
> > Maybe I could check the statistics and decide whether to drain according
> > pages we have in the group. Let me think about that.
> > 
> > > (And async draining runs.)
> > > 
> > > How about automatically adjusting CHARGE_BATCH and make it small when the
> > > system is near to limit ? 
> > 
> > Hmm, we are already bypassing batching if we are close to the limit,
> > aren't we? If we get to the reclaim we fallback to nr_pages allocation
> > and so we do not refill the stock.
> > Maybe we could check how much we have reclaimed and update the batch
> > size accordingly.
> > 
> 
> Please wait until "background reclaim" stuff. I don't stop it and it will
> make this cpu-caching stuff better because we can drain before hitting
> limit.

As I said I haven't seen this hurting us so this can definitely wait.
I will drop the patch for now and keep just the clean up stuff. I will
repost it when I have some numbers in hands or if I am able to
workaround the current issues with too much waiting problem.

> 
> If you cannot wait....
> 
> One idea is to have a threshold to call async "drain". For example,
> 
>  threshould = limit_of_memory - nr_online_cpu() * (BATCH_SIZE + 1)
> 
>  if (usage > threshould)
> 	drain_all_stock_async().
> 
> Then, situation will be much better.

Will think about it. I am not sure whether this is too rough.

> Thanks,
> -Kame

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
