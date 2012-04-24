Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 813F56B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 04:04:08 -0400 (EDT)
Date: Tue, 24 Apr 2012 15:58:53 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120424075853.GA8391@localhost>
References: <20120404175124.GA8931@localhost>
 <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120406095934.GA10465@localhost>
 <20120417223854.GG19975@google.com>
 <20120419142343.GA12684@localhost>
 <20120419202635.GA4795@quack.suse.cz>
 <20120420133441.GA7035@localhost>
 <20120420190844.GH32324@google.com>
 <20120422144649.GA7066@localhost>
 <20120423165626.GB5406@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120423165626.GB5406@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, vgoyal@redhat.com, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>

Hi Tejun,

On Mon, Apr 23, 2012 at 09:56:26AM -0700, Tejun Heo wrote:
> Hello, Fengguang.
>
> On Sun, Apr 22, 2012 at 10:46:49PM +0800, Fengguang Wu wrote:
> > OK. Sorry I should have explained why memcg dirty limit is not the
> > right tool for back pressure based throttling.
>
> I have two questions.  Why do we need memcg for this?  Writeback
> currently works without memcg, right?  Why does that change with blkcg
> aware bdi?

Yeah currently writeback does not depend on memcg. As for blkcg, it's
necessary to keep a number of dirty pages for each blkcg, so that the
cfq groups' async IO queue does not go empty and lose its turn to do
IO. memcg provides the proper infrastructure to account dirty pages.

In a previous email, we have an example of two 10:1 weight cgroups,
each running one dd. They will make two IO pipes, each holding a number
of dirty pages. Since cfq honors dd-1 much more IO bandwidth, dd-1's
dirty pages are consumed quickly. However balance_dirty_pages(),
without knowing about cfq's bandwidth divisions, is throttling the
two dd tasks equally. So dd-1 will be producing dirty pages much
slower than cfq is consuming them. The flusher thus won't send enough
dirty pages down to fill the corresponding async IO queue for dd-1.
cfq cannot really give dd-1 more bandwidth share due to lack of data
feed. The end result will be: the two cgroups get 1:1 bandwidth share
honored by balance_dirty_pages() even though cfq honors 10:1 weights
to them.

1:1 balance_dirty_pages() bandwidth split

  [          dd-1              |           dd-2             ]
  |                             \                           |
  |                              \**************************|
  |                               \*************************|
  |                                \************************|
  |                                 \***********************|
  |                                  \**********************|
  |                                   \*********************|
  |                                    \********************|
  |                                     \*******************|
  |                                      \******************|
  |                                       \*****************|
  |                                        \****************|
  |                                         \***************|
  |                                          \**************|
  |                                           \*************|
  |                                            \************|
  |                                             \***********|
  |                                              \**********|
  |                                               \*********|
  |                                                \********|
  |                                                 \*******|
  |                                                  \******|
  |************************   (constantly underrun)   \*****|

10:1 cfq bandwidth split                      [*] dirty pages

Ideally is,

  [                      dd-1                         | dd-2]
  |                                                   |     |
  |                                                   |     |
  |                                                   |     |
  |                                                   |     |
  |                                                   |     |
  |                                                   |     |
  |                                                   |     |
  |                                                   |     |
  |                                                   |     |
  |                                                   |     |
  |                                                   |     |
  |                                                   |     |
  |                                                   |     |
  |                                                   |     |
  |***************************************************|*****|
  |***************************************************|*****|
  |***************************************************|*****|
  |***************************************************|*****|
  |***************************************************|*****|
  |***************************************************|*****|
  |***************************************************|*****|
  |***************************************************|*****|
  |***************************************************|*****|
  |***************************************************|*****|

Or better, one single pipe :)

  [                      dd-1                         | dd-2]
  |                                                         |
  |                                                         |
  |                                                         |
  |                                                         |
  |                                                         |
  |                                                         |
  |                                                         |
  |                                                         |
  |                                                         |
  |                                                         |
  |                                                         |
  |                                                         |
  |                                                         |
  |                                                         |
  |*********************************************************|
  |*********************************************************|
  |*********************************************************|
  |*********************************************************|
  |*********************************************************|
  |*********************************************************|
  |*********************************************************|
  |*********************************************************|
  |*********************************************************|
  |*********************************************************|

> > Basically the more memcgs with dirty limits, the more hard time for
> > the flusher to serve them fairly and knock down their dirty pages in
> > time. Because the flusher works inode by inode, each one may take up
> > to 0.5 second, and there may be many memcgs asking for the flusher's
> > attention. Also the more memcgs, the global dirty pages pool are
> > partitioned into smaller pieces, which means smaller safety margin for
> > each memcg. Adding these two effects up, there may be constantly some
> > memcgs hitting their dirty limits when there are dozens of memcgs.
>
> And how is this different from a machine with smaller memory?  If so,
> why?

In a small memory box, dd and flusher produce/consume dirty pages
continuously, so that over time the number of dirty pages can remain
roughly stable.

  ^ dirty pages
  |
  +dirty limit
  |                    | dd continously dirtying pages
  |dirty setpoint      v
  +*******************************************************************
  |                    |
  |                    v flusher continously clean pages
  |
  +-------------------------------------------------------------------->
                                                                    time

However if it's a large memory machine whose dirty pages get
partitioned to 100 cgroups, the flusher will be serving them
in round robin fashion. For a particular cgroup, the flusher
only comes and consumes its dirty pages once on every (100*flusher_slice)
seconds. The interval would be 50s for the current 0.5s flusher slice,
or 5s if lowering flusher slice to 50ms.

I'm not sure whether it's practical to decrease the flusher slice for
ext4, which for the sake of write performance and avoid fragmentation,
increases the write chunk size to 128MB internally.

For a number of reasons, the flusher's behavior cannot be exactly
controlled. The intervals the flusher come to each cgroup go up and
down, fairness can only be coarsely assured.

The dirty pages for each cgroup will be going up and down irregularly
across very large dynamic ranges. Now you should be able to imagine
the challenges to avoid hitting the dirty limit, to balance the dirty
pages around the per-cgroup-per-bdi dirty setpoints and to avoid
underruns. When there are 10 cgroups and 12 bdi's, the dirty setpoints
could explode up to 10*12.

  ^ dirty pages
  |
  |                                       dd continously dirtying pages
  + dirty limit        dd stalled
  |                      ******             |
  |                    *      *             |           *
  |                  *        *             |         *  *
  |                *          *             |       *    *
  | dirty        *            *             |     *      *
  + setpoint   *              *             |   *        *
  |          *                *             v *          *
  |        *                   *            *            *
  |      *                     *          *              *
  |    *                       *        *                *      *
  |  *                         *      *                   *   *
  |*                           *    *                     * *
  |                            *  *                       *
  |                             *
  |                           ^^ the flusher comes around to this cgroup
  |
  +-------------------------------------------------------------------->
                                                                    time

> > Such cross subsystem coordinations still look natural to me because
> > "weight" is a fundamental and general parameter. It's really a blkcg
> > thing (determined by the blkio.weight user interface) rather than
> > specifically tied to cfq. When another kernel entity (eg. NFS or noop)
> > decides to add support for proportional weight IO control in future,
> > it can make use of the weights calculated by balance_dirty_pages(), too.
>
> It is not fundamental and natural at all and is already made cfq
> specific in the devel branch.  You seem to think "weight" is somehow a
> global concept which everyone can agree on but it is not.  Weight of
> what?  Is it disktime, bandwidth, iops or something else?  cfq deals
> primarily with disktime because that makes sense for spinning drives
> with single head.  For SSDs with smart enough FTLs, the unit should
> probably be iops.  For storage technology bottlenecked on bus speed,
> bw would make sense.

"Weight" is sure a global concept that reflects the "importance"
deemed by the user for that cgroup. cfq (or NFS, whatever on the horizon)
then interprets the importance number as disk time, IOPS, bandwidth,
whatever semantic that best fits the backing storage and workload.

blkio.weight will be the "number" shared and interpreted by all IO
controller entities, whether it be cfq, NFS or balance_dirty_pages().
And I can assure you that balance_dirty_pages() will be interpreting
it the _same_ way the underlying cfq/NFS interprets it, via the feedback
scheme described below.

> IIUC, writeback is primarily dealing with abstracted bandwidth which
> is applied per-inode, which is fine at that layer as details like
> block allocations isn't and shouldn't be visible there and files (or
> inodes) are the level of abstraction.
>
> However, this doesn't necessarily translate easily into the actual
> underlying IO resource.  For devices with spindle, seek time dominates
> and the same amount of IO may consume vastly different amount of IO
> and the disk time becomes the primary resource, not the iops or
> bandwidth.  Naturally, people want to allocate and limit the primary
> resource, so cfq distributes disk time across different cgroups as
> configured.

Right. balance_dirty_pages() is always doing dirty throttling wrt.
bandwidth, even in your back pressure scheme, isn't it? In this regard,
there are nothing fundamentally different between our proposals. They
will both employ some way to convert the cfq's disk time or IOPS
notion to balance_dirty_pages()'s bandwidth notion. See below for my
way of conversion.

> Your suggested solution is applying the same a number - the weight -
> to one portion of a mostly arbitrarily split resource using a
> different unit.  I don't even understand what that achieves.

You seem to miss my stated plan: next step, balance_dirty_pages() will
get some feedback information from cfq to adjust its bandwidth targets
accordingly. That information will be

        io_cost = charge/sectors

The charge value is exactly the value computed in cfq_group_served(),
which is the slice time or IOs dispatched depending the mode cfq is
operating in. By dividing ratelimit by the normalized io_cost,
balance_dirty_pages() will automatically get the same weight
interpretation as cfq. For example, on spin disks, it will be able to
allocate lower bandwidth to seeky cgroups due to the larger io_cost
reported by cfq.

> The requirement is to be able to split IO resource according to
> cgroups in configurable way and enforce the limits established by the
> configuration, which we're currently failing to do for async IOs.
> Your proposed solution applies some arbitrary ratio according to some
> arbitrary interpretation of cfq IO time weight way up in the stack
> which, when propagated to the lower layer, would cause significant
> amount of delay and fluctuation which behaves completely independent
> from how (using what unit, in what granularity and in what time scale)
> actual IO resource is handled, split and accounted, which would result
> in something which probably has some semblance of interpreting
> blkcg.weight as vague best-effort priority at its luckiest moments.

Interestingly, our proposals are once again on the same plane
regarding the delays and fluctuations. Due to the long delays between
dirty and writeout time, the access pattern for the newly generated
dirty pages and the access pattern for the under-writeback pages may
have changed. So even if cfq is throttling the stream proportional to
its IO cost, the user on the other side of the pipe (with long delay)
may still see the strange behavior of lower throughput for sequential
writes and higher throughput for random writes. Let's accept the fact:
it's a natural problem/property of the buffered writes. What we can do
is to aim for _long term_ rate matching.

> So, I don't think your suggested solution is a solution at all.  I'm
> in fact not even sure what it achieves at the cost of the gross
> layering violation and fundamental design braindamage.

It doesn't make anything perform better (nor worse). In face of the
challenging problem, both proposals suck. My solution just sucks less
as in the below listing.

> >         - No more latency
> >         - No performance drop
> >         - No bumpy progress and stalls
> >         - No need to attach memcg to blkcg
> >         - Feel free to create 1000+ IO controllers, to heart's content
> >           w/o worrying about costs (if any, it would be some existing
> >           scalability issues)
>
> I'm not sure why memcg suddenly becomes necessary with blkcg and I
> don't think having per-blkcg writeback and reasonable async
> optimization from iosched would be considerably worse.  It sure will
> add some overhead (e.g. from split buffering) but there will be proper
> working isolation which is what this fuss is all about.  Also, I just
> don't see how creating 1000+ (relatively active, I presume) blkcgs on
> a single spindle would be sane and how is the end result gonna be
> significantly better for your suggested solution, so let's please put
> aside the silly non-use case.

There are big disk arrays with lots of spindles inside, or arrays of
fast SSDs. People may want to create lots of cgroups on them.  IO
controllers should be made cheap and scalable to meet the demands from
our variety user base, now and future.

> In terms of overhead, I suspect the biggest would be the increased
> buffering coming from split channels but that seems like the cost of
> business to me.

I know that the back pressure idea actually come a long way (several
years?) and it's kind of become a common agreement that there will be
inevitable costs incur to the isolation. So I can understand why you
keep ignoring all the overheads, costs and scalability issues because
there seems no other way out. However here comes the solution that can
magically avoid the partition and all the resulted problems, and still
be able to provide the isolation.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
