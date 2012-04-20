Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 1C9F76B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 09:40:02 -0400 (EDT)
Date: Fri, 20 Apr 2012 21:34:41 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120420133441.GA7035@localhost>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404175124.GA8931@localhost>
 <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120406095934.GA10465@localhost>
 <20120417223854.GG19975@google.com>
 <20120419142343.GA12684@localhost>
 <20120419202635.GA4795@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120419202635.GA4795@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, vgoyal@redhat.com, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>

On Thu, Apr 19, 2012 at 10:26:35PM +0200, Jan Kara wrote:
> On Thu 19-04-12 22:23:43, Wu Fengguang wrote:
> > For one instance, splitting the request queues will give rise to
> > PG_writeback pages.  Those pages have been the biggest source of
> > latency issues in the various parts of the system.
>   Well, if we allow more requests to be in flight in total then yes, number
> of PG_Writeback pages can be higher as well.

Exactly.  

> > It's not uncommon for me to see filesystems sleep on PG_writeback
> > pages during heavy writeback, within some lock or transaction, which in
> > turn stall many tasks that try to do IO or merely dirty some page in
> > memory. Random writes are especially susceptible to such stalls. The
> > stable page feature also vastly increase the chances of stalls by
> > locking the writeback pages. 
> > 
> > Page reclaim may also block on PG_writeback and/or PG_dirty pages. In
> > the case of direct reclaim, it means blocking random tasks that are
> > allocating memory in the system.
> > 
> > PG_writeback pages are much worse than PG_dirty pages in that they are
> > not movable. This makes a big difference for high-order page allocations.
> > To make room for a 2MB huge page, vmscan has the option to migrate
> > PG_dirty pages, but for PG_writeback it has no better choices than to
> > wait for IO completion.
> > 
> > The difficulty of THP allocation goes up *exponentially* with the
> > number of PG_writeback pages. Assume PG_writeback pages are randomly
> > distributed in the physical memory space. Then we have formula
> > 
> >         P(reclaimable for THP) = 1 - P(hit PG_writeback)^256
>   Well, this implicitely assumes that PG_Writeback pages are scattered
> across memory uniformly at random. I'm not sure to which extent this is
> true...

Yeah, when describing the problem I was also thinking about the
possibilities of optimization (it would be a very good general
improvements). Or maybe Mel already has some solutions :)

> Also as a nitpick, this isn't really an exponential growth since
> the exponent is fixed (256 - actually it should be 512, right?). It's just

Right, 512 4k pages to form one x86_64 2MB huge pages.

> a polynomial with a big exponent. But sure, growth in number of PG_Writeback
> pages will cause relatively steep drop in the number of available huge
> pages.

It's exponential indeed, because "1 - p(x)" here means "p(!x)".
It's exponential for a 10x increase in x resulting in 100x drop of y.

> ...
> > It's worth to note that running multiple flusher threads per bdi means
> > not only disk seeks for spin disks, smaller IO size for SSD, but also
> > lock contentions and cache bouncing for metadata heavy workloads and
> > fast storage.
>   Well, this heavily depends on particular implementation (and chosen
> data structures). But yes, we should have that in mind.

The lock contentions and cache bouncing actually mainly happen in fs
code due to concurrent IO submissions. Also when replying Vivek's
email I realized that the disk seeks and/or smaller IO size are more
fundamentally tied to the split async queues in cfq which makes it
switch inodes on every async slice time (typically 40ms).

> ...
> > > > To me, balance_dirty_pages() is *the* proper layer for buffered writes.
> > > > It's always there doing 1:1 proportional throttling. Then you try to
> > > > kick in to add *double* throttling in block/cfq layer. Now the low
> > > > layer may enforce 10:1 throttling and push balance_dirty_pages() away
> > > > from its balanced state, leading to large fluctuations and program
> > > > stalls.
> > > 
> > > Just do the same 1:1 inside each cgroup.
> > 
> > Sure. But the ratio mismatch I'm talking about is inter-cgroup.
> > For example there are only 2 dd tasks doing buffered writes in the
> > system. Now consider the mismatch that cfq is dispatching their IO
> > requests at 10:1 weights, while balance_dirty_pages() is throttling
> > the dd tasks at 1:1 equal split because it's not aware of the cgroup
> > weights.
> > 
> > What will happen in the end? The 1:1 ratio imposed by
> > balance_dirty_pages() will take effect and the dd tasks will progress
> > at the same pace. The cfq weights will be defeated because the async
> > queue for the second dd (and cgroup) constantly runs empty.
>   Yup. This just shows that you have to have per-cgroup dirty limits. Once
> you have those, things start working again.

Right. I think Tejun was more of less aware of this.

I was rather upset by this per-memcg dirty_limit idea indeed. I never
expect it to work well when used extensively. My plan was to set the
default memcg dirty_limit high enough, so that it's not hit in normal.
Then Tejun came and proposed to (mis-)use dirty_limit as the way to
convert the dirty pages' backpressure into real dirty throttling rate.
No, that's just crazy idea!

Come on, let's not over-use memcg's dirty_limit. It's there as the
*last resort* to keep dirty pages under control so as to maintain
interactive performance inside the cgroup. However if used extensively
in the system (like dozens of memcgs all hit their dirty limits), the
limit itself may stall random dirtiers and create interactive
performance issues!

In the recent days I've come up with the idea of memcg.dirty_setpoint
for the blkcg backpressure stuff. We can use that instead.

memcg.dirty_setpoint will scale proportionally with blkcg.writeout_rate.
Imagine bdi_setpoint. It's all the same concepts. Why we need this?
Because if blkcg A and B does 10:1 weights and are both doing buffered
writes, their dirty pages should better be maintained around 10:1
ratio to avoid underrun and hopefully achieve better IO size.
memcg.dirty_limit cannot guarantee that goal.

But be warned! Partitioning the dirty pages always means more
fluctuations of dirty rates (and even stalls) that's perceivable by
the user. Which means another limiting factor for the backpressure
based IO controller to scale well.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
