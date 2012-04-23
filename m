Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id E61356B004A
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 10:36:21 -0400 (EDT)
Date: Mon, 23 Apr 2012 22:31:03 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120423143103.GA14642@localhost>
References: <20120404175124.GA8931@localhost>
 <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120406095934.GA10465@localhost>
 <20120417223854.GG19975@google.com>
 <20120419142343.GA12684@localhost>
 <20120419202635.GA4795@quack.suse.cz>
 <20120420133441.GA7035@localhost>
 <20120423091432.GC6512@quack.suse.cz>
 <20120423102420.GA13262@localhost>
 <20120423124240.GE6512@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120423124240.GE6512@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, vgoyal@redhat.com, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>

On Mon, Apr 23, 2012 at 02:42:40PM +0200, Jan Kara wrote:
> On Mon 23-04-12 18:24:20, Wu Fengguang wrote:
> > On Mon, Apr 23, 2012 at 11:14:32AM +0200, Jan Kara wrote:
> > > On Fri 20-04-12 21:34:41, Wu Fengguang wrote:

> > > > But be warned! Partitioning the dirty pages always means more
> > > > fluctuations of dirty rates (and even stalls) that's perceivable by
> > > > the user. Which means another limiting factor for the backpressure
> > > > based IO controller to scale well.
> > >   Sure, the smaller the memcg gets, the more noticeable these fluctuations
> > > would be. I would not expect memcg with 200 MB of memory to behave better
> > > (and also not much worse) than if I have a machine with that much memory...
> > 
> > It would be much worse if it's one single flusher thread round robin
> > over the cgroups...
> > 
> > For a small machine with 200MB memory, its IO completion events can
> > arrive continuously over time. However if its a 2000MB box divided
> > into 10 cgroups and the flusher is writing out dirty pages, spending
> > 0.5s on each cgroup and then go on to the next, then for any single
> > cgroup, its IO completion events go quiet for every 9.5s and goes up
> > on the other 0.5s. It becomes really hard to control the number of
> > dirty pages.
>   Umm, but flusher does not spend 0.5s on each cgroup. It submits 0.5s
> worth of IO for each cgroup.

Right.

> Since the throughput computed for each cgroup
> will be scaled down accordingly (and thus write_chunk will be scaled down
> as well), it should end up submitting 0.5s worth of IO for the whole system
> after it traverses all the cgroups, shouldn't it? Effectively we will work
> with smaller write_chunk which will lead to lower total throughput - that's
> the price of partitioning and higher fairness requirements (previously the

Sure you can do that. However I think we were talking about memcg
dirty limits, in which case we still have good chances to keep the
0.5s per inode granularity by making the dirty limits high so that it
won't be hit normally. Only when there comes lots of memory cgroups
that the flusher cannot easily safeguard fairness among them, we may
consider decreasing the writeback chunk size.

> requirement was to switch to a new inode every 0.5s, now the requirement is
> to switch to a new inode in each cgroup every 0.5s). In the end, we may end
> up increasing the write_chunk by some factor like \sqrt(number of memcgs)
> to get some middle ground between the guaranteed small latency and
> reasonable total throughput but before I'd go for such hacks, I'd wait to
> see real numbers - e.g. paying 10% of total throughput for partitioning the
> machine into 10 IO intensive cgroups (as in your tests with dd's) would be
> a reasonable cost in my opinion.

For IO cgroups, I'd always prefer to avoid partitioning the dirty pages
and async IO queue so as to avoid such embarrassing tradeoffs in the
first place :-)

> Also the granularity of IO completions should depend more on the
> granularity of IO scheduler (CFQ) rather than the granularity of flusher
> thread as such so I wouldn't think that would be a problem.

By avoiding the partitions, we'll cancel the fairness problem. So
the coarse granularity of flusher won't be a problem for IO cgroups at
all.  balance_dirty_pages() will do proper throttling when dirty pages
are created, based directly on the blkcg weights and ongoing IO.
After that all async IOs go as a single stream from the flusher to the
storage. There are no need for page tracking. No split inode lists and
hence granularity or shared inodes issues for the flusher. Above all
there will be no degradation of performance at all, whether it be
throughput, latency or responsiveness. 

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
