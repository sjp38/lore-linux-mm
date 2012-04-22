Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 990006B004D
	for <linux-mm@kvack.org>; Sun, 22 Apr 2012 10:52:27 -0400 (EDT)
Date: Sun, 22 Apr 2012 22:46:49 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120422144649.GA7066@localhost>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404175124.GA8931@localhost>
 <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120406095934.GA10465@localhost>
 <20120417223854.GG19975@google.com>
 <20120419142343.GA12684@localhost>
 <20120419202635.GA4795@quack.suse.cz>
 <20120420133441.GA7035@localhost>
 <20120420190844.GH32324@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120420190844.GH32324@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, vgoyal@redhat.com, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>

Hi Tejun,

On Fri, Apr 20, 2012 at 12:08:44PM -0700, Tejun Heo wrote:
> Hello, Fengguang.
> 
> On Fri, Apr 20, 2012 at 09:34:41PM +0800, Fengguang Wu wrote:
> > >   Yup. This just shows that you have to have per-cgroup dirty limits. Once
> > > you have those, things start working again.
> > 
> > Right. I think Tejun was more of less aware of this.
> 
> I'm fairly sure I'm on the "less" side of it.

OK. Sorry I should have explained why memcg dirty limit is not the
right tool for back pressure based throttling.

To limit memcg dirty pages, two thresholds will be introduced:


0                 call for flush                    dirty limit
------------------------*--------------------------------*----------------------->
                                                                memcg dirty pages

1) when dirty pages increase to "call for flush" point, the memcg will
   explicitly ask the flusher thread to focus more on this memcg's inodes

2) when "dirty limit" is reached, the dirtier tasks will be throttled
   the hard way

When there are few memcgs, or when the safety margin between the two
thresholds are large enough, the dirty limit won't be hit and all goes
virtually as smooth as when there are only global dirty limits.

Otherwise the memcg dirty limit will be occasionally hit, but still
should drop soon when the flusher thread round-robin to this memcg. 

Basically the more memcgs with dirty limits, the more hard time for
the flusher to serve them fairly and knock down their dirty pages in
time. Because the flusher works inode by inode, each one may take up
to 0.5 second, and there may be many memcgs asking for the flusher's
attention. Also the more memcgs, the global dirty pages pool are
partitioned into smaller pieces, which means smaller safety margin for
each memcg. Adding these two effects up, there may be constantly some
memcgs hitting their dirty limits when there are dozens of memcgs.

Hitting the dirty limits means all dirtiers tasks, including the light
dirtiers who do occasional writes, become painfully slow. It's a bad
state that should be avoided by any means.

Now consider the back pressure case. When the user configured two
blkcgs with 10:1 weights, the flusher will have great difficulties
writeout pages for the latter blkcg. The corresponding memcg's dirty
pages rush straightly to its dirty limit, _stay_ there and can never
drop to normal. This means the latter blkcg's tasks will constantly
see second-long time stalls.

The solution would be to create an adaptive threshold blkcg.bdi.dirty_setpoint
that's proportional to its buffered writeout bandwidth and teach
balance_dirty_pages() to balance dirty pages around that target.

It avoids the worst case of hitting dirty_limit. However it may still
present big challenges to balance_dirty_pages(). For example, when
there are 10 blkcgs and 12 JBOD disks, it may create up to 10*12=120
dirty balance targets. Wow I cannot imagine how it's going to fulfill
so many different targets.

> > I was rather upset by this per-memcg dirty_limit idea indeed. I never
> > expect it to work well when used extensively. My plan was to set the
> > default memcg dirty_limit high enough, so that it's not hit in normal.
> > Then Tejun came and proposed to (mis-)use dirty_limit as the way to
> > convert the dirty pages' backpressure into real dirty throttling rate.
> > No, that's just crazy idea!
> 
> I'll tell you what's crazy.
> 
> We're not gonna cut three more kernel releases and then change jobs.
> Some of the stuff we put in the kernel ends up staying there for over
> a decade.  While ignoring fundamental designs and violating layers may
> look like rendering a quick solution.  They tend to come back and bite
> our collective asses.  Ask Vivek.  The iosched / blkcg API was messed
> up to the extent that bugs were so difficult to track down and it was
> nearly impossible to add new features, let alone new blkcg policy or
> elevator and people did suffer for that for long time.  I ended up
> cleaning up the mess.  It took me longer than three months and even
> then we have to carry on with a lot of ugly stuff for compatibility.

"block/cfq-iosched.c" 3930L

Yeah it's a big pile of tricky code. In despite of that, the code
structure still looks pretty neat, kudos to all of you!

> Unfortunately, your proposed solution is far worse than blkcg was or
> ever could be.  It's not even contained in a single subsystem and it's
> not even clear what it achieves.

Yeah it's cross subsystems, mainly due to there are two natural
throttling points: balance_dirty_pages() and cfq. It requires both
sides to work properly.

In my proposal, balance_dirty_pages() takes care to update the
weights for async/direct IO on every 200ms and store it in blkcg.
cfq then grabs the weights to update the cfq group's vdisktime.

Such cross subsystem coordinations still look natural to me because
"weight" is a fundamental and general parameter. It's really a blkcg
thing (determined by the blkio.weight user interface) rather than
specifically tied to cfq. When another kernel entity (eg. NFS or noop)
decides to add support for proportional weight IO control in future,
it can make use of the weights calculated by balance_dirty_pages(), too.

That scheme does involve non-trivial complexities in the calculations,
however IMHO sucks much less than let cfq take control and convey the
information all the way up to balance_dirty_pages() via "backpressure".

When balance_dirty_pages() takes part in the job, it merely costs some
per-cpu accounting and calculations on every 200ms -- both scales
pretty well.  Virtually nothing changed (how buffered IO is performed)
before/after applying IO controllers. From the users' perspective:

        - No more latency
        - No performance drop
        - No bumpy progress and stalls
        - No need to attach memcg to blkcg
        - Feel free to create 1000+ IO controllers, to heart's content
          w/o worrying about costs (if any, it would be some existing
          scalability issues)

On the other hand, the back pressure scheme makes Linux more clumsy by
vectorizing everything from bottom to up, giving rise to a number of
problems:

- in cfq, by splitting up the global async queue, cfq suddenly sees a
  number of cfq groups full of async requests lining up competing for
  the disk time. This could obscure things up and add difficulties to
  maintain low latency for sync requests.

- in cfq, it will now be switching inodes based on the 40ms async
  slice time, which defeats the flusher thread's 500ms inode slice
  time. The below numbers show the performance cost of lowering the
  flusher's slices to ~40ms:

  3.4.0-rc2             3.4.0-rc2-4M+  
-----------  ------------------------  
     114.02        -4.2%       109.23  snb/thresh=8G/xfs-1dd-1-3.4.0-rc2
     102.25       -11.7%        90.24  snb/thresh=8G/xfs-10dd-1-3.4.0-rc2
     104.17       -17.5%        85.91  snb/thresh=8G/xfs-20dd-1-3.4.0-rc2
     104.94       -18.7%        85.28  snb/thresh=8G/xfs-30dd-1-3.4.0-rc2
     104.76       -21.9%        81.82  snb/thresh=8G/xfs-100dd-1-3.4.0-rc2

  We can do the optimization of increasing cfq async time slice when
  there are no sync IO. However in general cases it could still hurt.

- in cfq, the lots more async queues will be holding much more async
  requests in order to prevent queue underrun. This proportionally
  scales up the number of writeback pages, which in turn exponentially
  scales up the difficulty to reclaim high order pages:

          P(reclaimable for THP) = P(non-PG_writeback)^512

  That means we cannot comfortably use THP in a system with more than
  0.1% writeback pages. Perhaps we need to work out some general
  optimizations to make writeback pages more concentrated in the
  physical memory space.

  Besides, when there are N seconds worth of writeback pages, it may
  take N/2 seconds on average for wait_on_page_writeback() to finish.
  So the total time cost of running into a random writeback page and
  waiting on it is also O(n^2):

        E(PG_writeback waits) = P(hit PG_writeback) * E(wait on it)

  That means we can hardly keep more than 1-second worth of writeback
  pages w/o worrying about long waits on PG_writeback in various parts
  of the kernel.

- in the flusher, we'll need to vectorize the dirty inode lists,
  that's fine. However we either need to create one flusher per blkcg,
  which has the problem of intensify various fs lock contentions, or
  let one single flusher to walk through the blkcgs, which risks more
  cfq queue underruns. We may decrease the flusher's time slice or
  increase the queue size to mitigate this, however neither looks
  the exciting way.

- balance_dirty_pages() will need to keep each blkcg's dirty pages at
  reasonable level, otherwise there may be starvations to defeat the
  low level IO controllers and to hurt IO size. Thus comes the very
  undesirable need to attach memcg to blkcg to track dirty pages.
  
  It's also not fun to work with dozens of dirty pages targets because
  dirty pages tend to fluctuate a lot. In comparison, it's far more
  easier for balance_dirty_pages() to dirty ratelimit 1000+ dd tasks
  in the global context.

In summary, the back pressure scheme looks obvious at first sight,
however there are some fundamental problems in the way. Cgroups are
expected to be *light weight* facilities. Unfortunately this scheme
will likely present too much burden and side effects to the system.
It might become uncomfortable for the user to run 10+ blkcgs...

> Neither weight or hard limit can be
> properly enforced without another layer of controlling at the block
> layer (some use cases do expect strict enforcement) and we're baking
> assumptions about use cases, interfaces and underlying hardware across
> multiple subsystems (some ssds work fine with per-iops switching).

cfq still has the freedom to do per-iops switching, based on the same
weight values computed by balance_dirty_pages(). cfq will need to feed
back some "IO cost" stats based on either disk time or iops, upon
which balance_dirty_pages() scales the throttling bandwidth for the
dirtier tasks by the "IO cost". balance_dirty_pages() can also do IOPS
hard limits based on the scaled throttling bandwidth.

> For your suggested solution, the moment it's best fit is now and it'll
> be a long painful way down until someone snaps and reimplements the
> whole thing.
>
> The kernel is larger than balance_dirty_pages() or writeback.  Each
> subsystem should do what it's supposed to do.  Let's solve problems
> where they belong and pay overheads where they're due.  Let's not
> contort the whole stack for the short term goal of shoving writeback
> support into the existing, still-developing, blkcg cfq proportional IO
> implementation.  Because that's pure insanity.

To be frank I would be very pleased to avoid going into the pains of
doing all the hairy computations to graft balance_dirty_pages() onto
cfq, if ever the back pressure idea is not so upsetting. And if there
are proper ways to address its problems, it would be a great relief
for me to stop pondering on the details of disk time/IOPS feedback and
the hierarchical support (yeah I think it's somehow possible now), and
the foreseeable _numerous_ experiments to get the ideas into shape...

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
