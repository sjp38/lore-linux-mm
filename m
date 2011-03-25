Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 634358D0040
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 09:44:15 -0400 (EDT)
Date: Fri, 25 Mar 2011 21:44:11 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH RFC 0/5] IO-less balance_dirty_pages() v2 (simple
 approach)
Message-ID: <20110325134411.GA8645@localhost>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
 <20110318143001.GA6173@localhost>
 <20110322214314.GC19716@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110322214314.GC19716@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>

Hi Jan,

On Wed, Mar 23, 2011 at 05:43:14AM +0800, Jan Kara wrote:
>   Hello Fengguang,
> 
> On Fri 18-03-11 22:30:01, Wu Fengguang wrote:
> > On Wed, Mar 09, 2011 at 06:31:10AM +0800, Jan Kara wrote:
> > > 
> > >   Hello,
> > > 
> > >   I'm posting second version of my IO-less balance_dirty_pages() patches. This
> > > is alternative approach to Fengguang's patches - much simpler I believe (only
> > > 300 lines added) - but obviously I does not provide so sophisticated control.
> > 
> > Well, it may be too early to claim "simplicity" as an advantage, until
> > you achieve the following performance/feature comparability (most of
> > them are not optional ones). AFAICS this work is kind of heavy lifting
> > that will consume a lot of time and attention. You'd better find some
> > more fundamental needs before go on the reworking.
> > 
> > (1)  latency
> > (2)  fairness
> > (3)  smoothness
> > (4)  scalability
> > (5)  per-task IO controller
> > (6)  per-cgroup IO controller (TBD)
> > (7)  free combinations of per-task/per-cgroup and bandwidth/priority controllers
> > (8)  think time compensation
> > (9)  backed by both theory and tests
> > (10) adapt pause time up on 100+ dirtiers
> > (11) adapt pause time down on low dirty pages 
> > (12) adapt to new dirty threshold/goal
> > (13) safeguard against dirty exceeding
> > (14) safeguard against device queue underflow
>   I think this is a misunderstanding of my goals ;). My main goal is to
> explore, how far we can get with a relatively simple approach to IO-less
> balance_dirty_pages(). I guess what I have is better than the current
> balance_dirty_pages() but it sure does not even try to provide all the
> features you try to provide.

OK.

> I'm thinking about tweaking ratelimiting logic to reduce latencies in some
> tests, possibly add compensation when we waited for too long in
> balance_dirty_pages() (e.g. because of bumpy IO completion) but that's
> about it...
> 
> Basically I do this so that we can compare and decide whether what my
> simple approach offers is OK or whether we want some more complex solution
> like your patches...

Yeah, now both results are on the website. Let's see whether they are
acceptable for others.

> > > The basic idea (implemented in the third patch) is that processes throttled
> > > in balance_dirty_pages() wait for enough IO to complete. The waiting is
> > > implemented as follows: Whenever we decide to throttle a task in
> > > balance_dirty_pages(), task adds itself to a list of tasks that are throttled
> > > against that bdi and goes to sleep waiting to receive specified amount of page
> > > IO completions. Once in a while (currently HZ/10, in patch 5 the interval is
> > > autotuned based on observed IO rate), accumulated page IO completions are
> > > distributed equally among waiting tasks.
> > > 
> > > This waiting scheme has been chosen so that waiting time in
> > > balance_dirty_pages() is proportional to
> > >   number_waited_pages * number_of_waiters.
> > > In particular it does not depend on the total number of pages being waited for,
> > > thus providing possibly a fairer results.
> > 
> > When there comes no IO completion in 1 second (normal in NFS), the
> > tasks will all get stuck. It is fixable based on your v2 code base
> > (detailed below), however will likely bring the same level of
> > complexity as the base bandwidth solution.
>   I have some plans how to account for bumpy IO completion when we wait for
> a long time and then get completion of much more IO than we actually need.
> But in case where processes use all the bandwidth and the latency of the
> device is high, sure they take the penalty and have to wait for a long time
> in balance_dirty_pages().

No, I don't think it's good to block for long time in
balance_dirty_pages(). This seems to be our biggest branch point.

> > As for v2, there are still big gap to fill. NFS dirtiers are
> > constantly doing 20-25 seconds long delays
> > 
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/jan-bdp-v2b/3G/nfs-1dd-1M-8p-2945M-20%25-2.6.38-rc8-jan-bdp+-2011-03-10-16-31/balance_dirty_pages-pause.png
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/jan-bdp-v2b/3G/nfs-10dd-1M-8p-2945M-20%25-2.6.38-rc8-jan-bdp+-2011-03-10-16-38/balance_dirty_pages-pause.png
>   Yeah, this is because they want lots of pages each
> (3/2*MAX_WRITEBACK_PAGES). I'll try to change ratelimiting to make several
> shorter sleeps. But ultimately you have to wait this much. Just you can
> split those big sleeps in more of smaller ones.

Ideally I prefer less than 100ms sleep time for achieving smooth
responsiveness and IO pipeline.

> > and the tasks are bumping forwards
> > 
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/jan-bdp-v2b/3G/nfs-10dd-1M-8p-2945M-20%25-2.6.38-rc8-jan-bdp+-2011-03-10-16-38/balance_dirty_pages-task-bw.png
>   Yeah, that's a result of bumpy NFS writeout and basically the consequence
> of the above. Maybe it can be helped but I don't find this to be a problem on
> its own...

ditto.

> > > Since last version I've implemented cleanups as suggested by Peter Zilstra.
> > > The patches undergone more throughout testing. So far I've tested different
> > > filesystems (ext2, ext3, ext4, xfs, nfs), also a combination of a local
> > > filesystem and nfs. The load was either various number of dd threads or
> > > fio with several threads each dirtying pages at different speed.
> > > 
> > > Results and test scripts can be found at
> > >   http://beta.suse.com/private/jack/balance_dirty_pages-v2/
> > > See README file for some explanation of test framework, tests, and graphs.
> > > Except for ext3 in data=ordered mode, where kjournald creates high
> > > fluctuations in waiting time of throttled processes (and also high latencies),
> > > the results look OK. Parallel dd threads are being throttled in the same way
> > > (in a 2s window threads spend the same time waiting) and also latencies of
> > > individual waits seem OK - except for ext3 they fit in 100 ms for local
> > > filesystems. They are in 200-500 ms range for NFS, which isn't that nice but
> > > to fix that we'd have to modify current ratelimiting scheme to take into
> > > account on which bdi a page is dirtied. Then we could ratelimit slower BDIs
> > > more often thus reducing latencies in individual waits...
> > 
> > Yes the per-cpu rate limit is a problem, so I'm switching to per-task
> > rate limit.
>   BTW: Have you considered per-bdi ratelimiting? Both per-task and per-bdi
> make sense just they are going to have slightly different properties...
> Current per-cpu ratelimit counters tend to behave like per-task
> ratelimiting at least for fast dirtiers because once a task is blocked in
> balance_dirty_pages() another task runs on that cpu and uses the counter
> for itself. So I wouldn't expect big differences from per-task
> ratelimiting...

Good point. It should be enough to have per-bdi rate limiting threshold.
However I still need to keep per-task nr_dirtied for doing per-task
throttling bandwidth. The per-cpu bdp_ratelimits mix dirtied pages
from different tasks and bdis, which is unacceptable for me.

> > The direct input from IO completion is another issue. It leaves the
> > dirty tasks at the mercy of low layer (VFS/FS/bdev) fluctuations and
> > latencies. So I'm introducing the base bandwidth as a buffer layer.
> > You may employ the similar technique: to simulate a more smooth flow
> > of IO completion events based on the average write bandwidth. Then it
> > naturally introduce the problem of rate mismatch between
> > simulated/real IO completions, and the need to do more elaborated
> > position control.
>   Exacttly, that's why I don't want to base throttling on some computed
> value (well, I also somehow estimate necessary sleep time but that's more a
> performance optimization) but rather leave tasks "at the mercy of lower
> layers" as you write ;) I don't think it's necessarily a bad thing. 

Again, the same branch point :)

> > > The results for different bandwidths fio load is interesting. There are 8
> > > threads dirtying pages at 1,2,4,..,128 MB/s rate. Due to different task
> > > bdi dirty limits, what happens is that three most aggresive tasks get
> > > throttled so they end up at bandwidths 24, 26, and 30 MB/s and the lighter
> > > dirtiers run unthrottled.
> > 
> > The base bandwidth based throttling can do better and provide almost
> > perfect fairness, because all tasks writing to one bdi derive their
> > own throttle bandwidth based on the same per-bdi base bandwidth. So
> > the heavier dirtiers will converge to equal dirty rate and weight.
>   So what do you consider a perfect fairness in this case and are you sure
> it is desirable? I was thinking about this and I'm not sure...

Perfect fairness could be 1, 2, 4, 8, N, N, N MB/s, where

        N = (write_bandwidth - 1 - 2 - 4 - 8) / 3.

I guess its usefulness is largely depending on the user space
applications.  Most of them should not be sensible to it.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
