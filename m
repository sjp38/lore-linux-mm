Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 02ED26B004D
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 10:29:06 -0400 (EDT)
Date: Thu, 19 Apr 2012 22:23:43 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120419142343.GA12684@localhost>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404175124.GA8931@localhost>
 <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120406095934.GA10465@localhost>
 <20120417223854.GG19975@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120417223854.GG19975@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, vgoyal@redhat.com, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

Hi Tejun,

On Tue, Apr 17, 2012 at 03:38:54PM -0700, Tejun Heo wrote:
> Hello, Fengguang.
> 
> On Fri, Apr 06, 2012 at 02:59:34AM -0700, Fengguang Wu wrote:
> > Fortunately, the above gap can be easily filled judging from the
> > block/cfq IO controller code. By adding some direct IO accounting
> > and changing several lines of my patches to make use of the collected
> > stats, the semantics of the blkio.throttle.write_bps interfaces can be
> > changed from "limit for direct IO" to "limit for direct+buffered IOs".
> > Ditto for blkio.weight and blkio.write_iops, as long as some
> > iops/device time stats are made available to balance_dirty_pages().
> > 
> > It would be a fairly *easy* change. :-) It's merely adding some
> > accounting code and there is no need to change the block IO
> > controlling algorithm at all. I'll do the work of accounting (which
> > is basically independent of the IO controlling) and use the new stats
> > in balance_dirty_pages().
> 
> I don't really understand how this can work.  For hard limits, maybe,

Yeah, hard limits are the easiest.

> but for proportional IO, you have to know which cgroups have IOs
> before assigning the proportions, so blkcg assigning IO bandwidth
> without knowing async writes simply can't work.
> 
> For example, let's say cgroups A and B have 2:8 split.  If A has IOs
> on queue and B doesn't, blkcg will assign all IO bandwidth to A.  I
> can't wrap my head around how writeback is gonna make use of the
> resulting stats but let's say it decides it needs to put out some IOs
> out for both cgroups.  What happens then?  Do all the async writes go
> through the root cgroup controlled by and affecting the ratio between
> rootcg and cgroup A and B?  Or do they have to be accounted as part of
> cgroups A and B?  If so, what if the added bandwidth goes over the
> limit?  Let's say if we implement overcharge; then, I suppose we'll
> have to communicate that upwards too, right?

The trick is to do the throttling for buffered writes at page dirty
time, when balance_dirty_pages() knows exactly what cgroup the dirtier
task belongs to, the dirty rate and whether or not it's an aggressive
dirtier. The cgroup's direct IO rate can also be measured. The only
missing information is whether it's a non-aggressive direct writer
(only cfq may know about that). Now I'm simply assuming direct writers
are all aggressive.

So if A and B have 2:8 split and A only submits async IO and B only
submits direct IO, there will be no cfqg exist for A at all. cfq will
be serving B and root cgroup interleavely. In the patch I just posted,
blkcg_update_dirty_ratelimit() will transfer A's weight 2 to the root
cgroup for use by the flusher. In the end the flusher gets weight 2
and B gets weight 8. Here we need to distinguish the weight assigned
by user and the weight after the async/sync adjustment.

The other missing information is the real cost when the dirtied pages
eventually hit the disk after perhaps dozens of seconds.  For that
part I'm assuming simple dd at this time and balance_dirty_pages()
is now splitting out the flusher's overall writeout progress to the
dirtier tasks' dirty ratelimit based on bandwidth fairness.

> This is still easy.  What about hierarchical propio?  What happens
> then?  You can't do hierarchical proportional allocation without
> knowing how much IOs are pending for which group.  How is that
> information gonna be communicated between blkcg and writeback?  Are we
> gonna have two separate hierarchical proportional IO allocators?  How
> is that gonna work at all?  If we're gonna have single allocator in
> block layer, writeback would have to feed the amount of IOs it may
> generate into the allocator, get the resulting allocation and then
> issue IO and then block layer again will have to account these to the
> originating cgroups.  It's just crazy.

No I have not got the idea on how to do the hierarchical proportional
IO controller without physically splitting up the async IO streams.
It's pretty hard and I'd better break out before it drives me crazy.

So in the following discussion, let's assume cfq will move async
requests from the current root cgroup to individual IO issuer's cfqgs
and schedule service for the async streams there. And thus the need to
create "backpressure" for balance_dirty_pages() to eventually throttle
the individual dirtier tasks.

That said, I still don't think we've come up with any satisfactory
solutions. It's hard problem after all.

> > The only problem I can see now, is that balance_dirty_pages() works
> > per-bdi and blkcg works per-device. So the two ends may not match
> > nicely if the user configures lv0 on sda+sdb and lv1 on sdb+sdc where
> > sdb is shared by lv0 and lv1. However it should be rare situations and
> > be much more acceptable than the problems arise from the "push back"
> > approach which impacts everyone.
> 
> I don't know.  What problems?  AFAICS, the biggest issue is writeback
> of different inodes getting mixed resulting in poor performance, but
> if you think about it, that's about the frequency of switching cgroups
> and a problem which can and should be dealt with from block layer
> (e.g. use larger time slice if all the pending IOs are async).

Yeah increasing time slice would help that case. In general it's not
merely the frequency of switching cgroup if take hard disk' writeback
cache into account.  Think about some inodes with async IO: A1, A2,
A3, .., and inodes with sync IO: D1, D2, D3, ..., all from different
cgroups. So when the root cgroup holds all async inodes, the cfq may
schedule IO interleavely like this

        A1,    A1,    A1,    A2,    A1,    A2,    ...
           D1,    D2,    D3,    D4,    D5,    D6, ...

Now it becomes

        A1,    A2,    A3,    A4,    A5,    A6,    ...
           D1,    D2,    D3,    D4,    D5,    D6, ...

The difference is that it's now switching the async inodes each time.
At cfq level, the seek costs look the same, however the disk's
writeback cache may help merge the data chunks from the same inode A1.
Well, it may cost some latency for spin disks. But how about SSD? It
can run deeper queue and benefit from large writes.

> Writeback's duty is generating stream of async writes which can be
> served efficiently for the *cgroup* and keeping the buffer filled as
> necessary and chaining the backpressure from there to the actual
> dirtier.  That's what writeback does without cgroup.  Nothing
> fundamental changes with cgroup.  It's just finer grained.

Believe me, physically partitioning the dirty pages and async IO
streams comes at big costs. It won't scale well in many ways.

For one instance, splitting the request queues will give rise to
PG_writeback pages.  Those pages have been the biggest source of
latency issues in the various parts of the system.

It's not uncommon for me to see filesystems sleep on PG_writeback
pages during heavy writeback, within some lock or transaction, which in
turn stall many tasks that try to do IO or merely dirty some page in
memory. Random writes are especially susceptible to such stalls. The
stable page feature also vastly increase the chances of stalls by
locking the writeback pages. 

Page reclaim may also block on PG_writeback and/or PG_dirty pages. In
the case of direct reclaim, it means blocking random tasks that are
allocating memory in the system.

PG_writeback pages are much worse than PG_dirty pages in that they are
not movable. This makes a big difference for high-order page allocations.
To make room for a 2MB huge page, vmscan has the option to migrate
PG_dirty pages, but for PG_writeback it has no better choices than to
wait for IO completion.

The difficulty of THP allocation goes up *exponentially* with the
number of PG_writeback pages. Assume PG_writeback pages are randomly
distributed in the physical memory space. Then we have formula

        P(reclaimable for THP) = 1 - P(hit PG_writeback)^256

That's the possibly for a contiguous range of 256 pages to be free of
PG_writeback, so that it's immediately reclaimable for use by
transparent huge page. This ruby script shows us the concrete numbers.

irb> 1.upto(10) { |i| j=i/1000.0; printf "%.3f\t\t\t%.3f\n", j, (1-j)**512 }

        P(hit PG_writeback)     P(reclaimable for THP)
        0.001                   0.599
        0.002                   0.359
        0.003                   0.215
        0.004                   0.128
        0.005                   0.077
        0.006                   0.046
        0.007                   0.027
        0.008                   0.016
        0.009                   0.010
        0.010                   0.006

The numbers show that when the PG_writeback pages go up from 0.1% to
1% of system memory, the THP reclaim success ratio drops quickly from
60% to 0.6%. It indicates that in order to use THP without constantly
running into stalls, the reasonable PG_writeback ratio is <= 0.1%.
Going beyond that threshold, it quickly becomes intolerable.

That makes a limit of 256MB writeback pages for a mem=256GB system.
Looking at the real vmstat:nr_writeback numbers in dd write tests:

JBOD-12SSD-thresh=8G/ext4-1dd-1-3.3.0/vmstat-end:nr_writeback 217009
JBOD-12SSD-thresh=8G/ext4-10dd-1-3.3.0/vmstat-end:nr_writeback 198335
JBOD-12SSD-thresh=8G/xfs-1dd-1-3.3.0/vmstat-end:nr_writeback 306026
JBOD-12SSD-thresh=8G/xfs-10dd-1-3.3.0/vmstat-end:nr_writeback 315099
JBOD-12SSD-thresh=8G/btrfs-1dd-1-3.3.0/vmstat-end:nr_writeback 1216058
JBOD-12SSD-thresh=8G/btrfs-10dd-1-3.3.0/vmstat-end:nr_writeback 895335

Oops btrfs has 4GB writeback pages -- which asks for some bug fixing.
Even ext4's 800MB still looks way too high, but that's ~1s worth of
data per queue (or 130ms worth of data for the high performance Intel
SSD, which is perhaps in danger of queue underruns?). So this system
would require 512GB memory to comfortably run KVM instances with THP
support.

Judging from the above numbers, we can hardly afford to split up the
IO queues and proliferate writeback pages.

It's worth to note that running multiple flusher threads per bdi means
not only disk seeks for spin disks, smaller IO size for SSD, but also
lock contentions and cache bouncing for metadata heavy workloads and
fast storage.

To give some concrete examples on how much CPU overheads can be saved
by reducing multiple IO submitters, here are some summaries for the
IO-less dirty throttling gains. Tests show that it yields huge
benefits for reducing IO seeks as well as CPU overheads.

For example, the fs_mark benchmark on a 12-drive software RAID0 goes
from CPU bound to IO bound, freeing "3-4 CPUs worth of spinlock
contention". (by Dave Chinner)

- "CPU usage has dropped by ~55%", "it certainly appears that most of
  the CPU time saving comes from the removal of contention on the
  inode_wb_list_lock"
  (IMHO at least 10% comes from the reduction of cacheline bouncing,
  because the new code is able to call much less frequently into
  balance_dirty_pages() and hence access the _global_ page states)

- the user space "App overhead" is reduced by 20%, by avoiding the
  cacheline pollution by the complex writeback code path

- "for a ~5% throughput reduction", "the number of write IOs have
  dropped by ~25%", and the elapsed time reduced from 41:42.17 to
  40:53.23.

And for simple dd tests

- "throughput for a _single_ large dd (100GB) increase from ~650MB/s
  to 700MB/s"

- "On a simple test of 100 dd, it reduces the CPU %system time from
  30% to 3%, and improves IO throughput from 38MB/s to 42MB/s."

> > > No, no, it's not about standing in my way.  As Vivek said in the other
> > > reply, it's that the "gap" that you filled was created *because*
> > > writeback wasn't cgroup aware and now you're in turn filling that gap
> > > by making writeback work around that "gap".  I mean, my mind boggles.
> > > Doesn't yours?  I strongly believe everyone's should.
> > 
> > Heh. It's a hard problem indeed. I felt great pains in the IO-less
> > dirty throttling work. I did a lot reasoning about it, and have in
> > fact kept cgroup IO controller in mind since its early days. Now I'd
> > say it's hands down for it to adapt to the gap between the total IO
> > limit and what's carried out by the block IO controller.
> 
> You're not providing any valid counter arguments about the issues
> being raised about the messed up design.  How is anything "hands down"
> here?

Yeah sadly, it turns out to be not "hands down" when it comes to the
proportional async/sync splits, and it's even prohibiting when comes
to the hierarchical support..

> > > There's where I'm confused.  How is the said split supposed to work?
> > > They aren't independent.  I mean, who gets to decide what and where
> > > are those decisions enforced?
> > 
> > Yeah it's not independent. It's about
> > 
> > - keep block IO cgroup untouched (in its current algorithm, for
> >   throttling direct IO)
> > 
> > - let balance_dirty_pages() adapt to the throttling target
> >   
> >         buffered_write_limit = total_limit - direct_IOs
> 
> Think about proportional allocation.  You don't have a number until
> you know who have pending IOs and how much.

We have the IO rate. The above formula is actually working on "rates".
That's good enough for calculating the ratelimit for buffered writes.
We don't have to know every transient states of the pending IOs.
Because the direct IOs are handled by cfq based on cfqg weight and 
for async IOs, there are plenty of dirty pages for
buffering/tolerating small errors in the dirty rate control.

> > To me, balance_dirty_pages() is *the* proper layer for buffered writes.
> > It's always there doing 1:1 proportional throttling. Then you try to
> > kick in to add *double* throttling in block/cfq layer. Now the low
> > layer may enforce 10:1 throttling and push balance_dirty_pages() away
> > from its balanced state, leading to large fluctuations and program
> > stalls.
> 
> Just do the same 1:1 inside each cgroup.

Sure. But the ratio mismatch I'm talking about is inter-cgroup.
For example there are only 2 dd tasks doing buffered writes in the
system. Now consider the mismatch that cfq is dispatching their IO
requests at 10:1 weights, while balance_dirty_pages() is throttling
the dd tasks at 1:1 equal split because it's not aware of the cgroup
weights.

What will happen in the end? The 1:1 ratio imposed by
balance_dirty_pages() will take effect and the dd tasks will progress
at the same pace. The cfq weights will be defeated because the async
queue for the second dd (and cgroup) constantly runs empty.

> >  This can be avoided by telling balance_dirty_pages(): "your
> > balance goal is no longer 1:1, but 10:1". With this information
> > balance_dirty_pages() will behave right. Then there is the question:
> > if balance_dirty_pages() will work just well provided the information,
> > why bother doing the throttling at low layer and "push back" the
> > pressure all the way up?
> 
> Because splitting a resource into two pieces arbitrarily with
> different amount of consumptions on each side and then applying the
> same proportion on both doesn't mean anything?

Sorry, I don't quite catch your words here.

> > The balance_dirty_pages() is already deeply involved in dirty throttling.
> > As you can see from this patchset, the same algorithms can be extended
> > trivially to work with cgroup IO limits.
> > 
> > buffered write IO controller in balance_dirty_pages()
> > https://lkml.org/lkml/2012/3/28/275
> 
> It is half broken thing with fundamental design flaws which can't be
> corrected without complete reimplementation.  I don't know what to
> say.

I'm fully aware of that, and so have been exploring new ways out :)

> > In the "back pressure" scheme, memcg is a must because only it has all
> > the infrastructure to track dirty pages upon which you can apply some
> > dirty_limits. Don't tell me you want to account dirty pages in blkcg...
> 
> For now, per-inode tracking seems good enough.

There are actually two directions of information passing.

1) pass the dirtier ownership down to bio. For this part, it's mostly
   enough to do the light weight per-inode tracking.

2) pass the backpressure up, from cfq (IO dispatch) to flusher (IO
submit) as well as to balance_dirty_pages() (to actually throttle the
dirty tasks). The flusher naturally works on inode granularities.
However balance_dirty_pages() is about limiting dirty pages. For this
part, it needs to know the total number of dirty pages and writeout
bandwidth for each cgroup in order to do proper dirty throttling. And
to maintain proper number of dirty pages to avoid the queue underrun
issue explained in the above 2-dd example.

> > What I can see is, it looks pretty simple and nature to let
> > balance_dirty_pages() fill the gap towards a total solution :-)
> > 
> > - add direct IO accounting in some convenient point of the IO path
> >   IO submission or completion point, either is fine.
> > 
> > - change several lines of the buffered write IO controller to
> >   integrate the direct IO rate into the formula to fit the "total
> >   IO" limit
> > 
> > - in future, add more accounting as well as feedback control to make
> >   balance_dirty_pages() work with IOPS and disk time
> 
> To me, you seem to be not addressing the issues I've been raising at
> all and just repeating the same points again and again.  If I'm
> misunderstanding something, please point out.

Hopefully the renewed patch can dismiss some of your questions. It's a
pity that I didn't thought about the hierarchical requirement at the
time. Otherwise the complexity of calculations still looks manageable.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
