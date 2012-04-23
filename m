Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 1F9216B004A
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 08:42:44 -0400 (EDT)
Date: Mon, 23 Apr 2012 14:42:40 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120423124240.GE6512@quack.suse.cz>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404175124.GA8931@localhost>
 <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120406095934.GA10465@localhost>
 <20120417223854.GG19975@google.com>
 <20120419142343.GA12684@localhost>
 <20120419202635.GA4795@quack.suse.cz>
 <20120420133441.GA7035@localhost>
 <20120423091432.GC6512@quack.suse.cz>
 <20120423102420.GA13262@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120423102420.GA13262@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, vgoyal@redhat.com, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>

On Mon 23-04-12 18:24:20, Wu Fengguang wrote:
> On Mon, Apr 23, 2012 at 11:14:32AM +0200, Jan Kara wrote:
> > On Fri 20-04-12 21:34:41, Wu Fengguang wrote:
> > > > ...
> > > > > > > To me, balance_dirty_pages() is *the* proper layer for buffered writes.
> > > > > > > It's always there doing 1:1 proportional throttling. Then you try to
> > > > > > > kick in to add *double* throttling in block/cfq layer. Now the low
> > > > > > > layer may enforce 10:1 throttling and push balance_dirty_pages() away
> > > > > > > from its balanced state, leading to large fluctuations and program
> > > > > > > stalls.
> > > > > > 
> > > > > > Just do the same 1:1 inside each cgroup.
> > > > > 
> > > > > Sure. But the ratio mismatch I'm talking about is inter-cgroup.
> > > > > For example there are only 2 dd tasks doing buffered writes in the
> > > > > system. Now consider the mismatch that cfq is dispatching their IO
> > > > > requests at 10:1 weights, while balance_dirty_pages() is throttling
> > > > > the dd tasks at 1:1 equal split because it's not aware of the cgroup
> > > > > weights.
> > > > > 
> > > > > What will happen in the end? The 1:1 ratio imposed by
> > > > > balance_dirty_pages() will take effect and the dd tasks will progress
> > > > > at the same pace. The cfq weights will be defeated because the async
> > > > > queue for the second dd (and cgroup) constantly runs empty.
> > > >   Yup. This just shows that you have to have per-cgroup dirty limits. Once
> > > > you have those, things start working again.
> > > 
> > > Right. I think Tejun was more of less aware of this.
> > > 
> > > I was rather upset by this per-memcg dirty_limit idea indeed. I never
> > > expect it to work well when used extensively. My plan was to set the
> > > default memcg dirty_limit high enough, so that it's not hit in normal.
> > > Then Tejun came and proposed to (mis-)use dirty_limit as the way to
> > > convert the dirty pages' backpressure into real dirty throttling rate.
> > > No, that's just crazy idea!
> > > 
> > > Come on, let's not over-use memcg's dirty_limit. It's there as the
> > > *last resort* to keep dirty pages under control so as to maintain
> > > interactive performance inside the cgroup. However if used extensively
> > > in the system (like dozens of memcgs all hit their dirty limits), the
> > > limit itself may stall random dirtiers and create interactive
> > > performance issues!
> > > 
> > > In the recent days I've come up with the idea of memcg.dirty_setpoint
> > > for the blkcg backpressure stuff. We can use that instead.
> > > 
> > > memcg.dirty_setpoint will scale proportionally with blkcg.writeout_rate.
> > > Imagine bdi_setpoint. It's all the same concepts. Why we need this?
> > > Because if blkcg A and B does 10:1 weights and are both doing buffered
> > > writes, their dirty pages should better be maintained around 10:1
> > > ratio to avoid underrun and hopefully achieve better IO size.
> > > memcg.dirty_limit cannot guarantee that goal.
> >   I agree that to avoid stalls of throttled processes we shouldn't be
> > hitting memcg.dirty_limit on a regular basis. When I wrote we need "per
> > cgroup dirty limits" I actually imagined something like you write above -
> > do complete throttling computations within each memcg - estimate throughput
> > available for it, compute appropriate dirty rates for it's processes and
> > from its dirty limit estimate appropriate setpoint to balance around.
> > 
> 
> Yes. balance_dirty_pages() will need both dirty pages and dirty page
> writeout rate for the cgroup to do proper dirty throttling for it.
> 
> > > But be warned! Partitioning the dirty pages always means more
> > > fluctuations of dirty rates (and even stalls) that's perceivable by
> > > the user. Which means another limiting factor for the backpressure
> > > based IO controller to scale well.
> >   Sure, the smaller the memcg gets, the more noticeable these fluctuations
> > would be. I would not expect memcg with 200 MB of memory to behave better
> > (and also not much worse) than if I have a machine with that much memory...
> 
> It would be much worse if it's one single flusher thread round robin
> over the cgroups...
> 
> For a small machine with 200MB memory, its IO completion events can
> arrive continuously over time. However if its a 2000MB box divided
> into 10 cgroups and the flusher is writing out dirty pages, spending
> 0.5s on each cgroup and then go on to the next, then for any single
> cgroup, its IO completion events go quiet for every 9.5s and goes up
> on the other 0.5s. It becomes really hard to control the number of
> dirty pages.
  Umm, but flusher does not spend 0.5s on each cgroup. It submits 0.5s
worth of IO for each cgroup. Since the throughput computed for each cgroup
will be scaled down accordingly (and thus write_chunk will be scaled down
as well), it should end up submitting 0.5s worth of IO for the whole system
after it traverses all the cgroups, shouldn't it? Effectively we will work
with smaller write_chunk which will lead to lower total throughput - that's
the price of partitioning and higher fairness requirements (previously the
requirement was to switch to a new inode every 0.5s, now the requirement is
to switch to a new inode in each cgroup every 0.5s). In the end, we may end
up increasing the write_chunk by some factor like \sqrt(number of memcgs)
to get some middle ground between the guaranteed small latency and
reasonable total throughput but before I'd go for such hacks, I'd wait to
see real numbers - e.g. paying 10% of total throughput for partitioning the
machine into 10 IO intensive cgroups (as in your tests with dd's) would be
a reasonable cost in my opinion.

Also the granularity of IO completions should depend more on the
granularity of IO scheduler (CFQ) rather than the granularity of flusher
thread as such so I wouldn't think that would be a problem.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
