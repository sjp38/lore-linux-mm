Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9585F8D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 10:30:05 -0400 (EDT)
Date: Fri, 18 Mar 2011 22:30:01 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH RFC 0/5] IO-less balance_dirty_pages() v2 (simple
 approach)
Message-ID: <20110318143001.GA6173@localhost>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1299623475-5512-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>

Hi Jan,

On Wed, Mar 09, 2011 at 06:31:10AM +0800, Jan Kara wrote:
> 
>   Hello,
> 
>   I'm posting second version of my IO-less balance_dirty_pages() patches. This
> is alternative approach to Fengguang's patches - much simpler I believe (only
> 300 lines added) - but obviously I does not provide so sophisticated control.

Well, it may be too early to claim "simplicity" as an advantage, until
you achieve the following performance/feature comparability (most of
them are not optional ones). AFAICS this work is kind of heavy lifting
that will consume a lot of time and attention. You'd better find some
more fundamental needs before go on the reworking.

(1)  latency
(2)  fairness
(3)  smoothness
(4)  scalability
(5)  per-task IO controller
(6)  per-cgroup IO controller (TBD)
(7)  free combinations of per-task/per-cgroup and bandwidth/priority controllers
(8)  think time compensation
(9)  backed by both theory and tests
(10) adapt pause time up on 100+ dirtiers
(11) adapt pause time down on low dirty pages 
(12) adapt to new dirty threshold/goal
(13) safeguard against dirty exceeding
(14) safeguard against device queue underflow

(brief listing first: I've just returned from travel)

> Fengguang is currently running some tests on my patches so that we can compare
> the approaches.
 
Yup, here are the tracing patches and graphs:

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/jan-bdp-v2b/

> The basic idea (implemented in the third patch) is that processes throttled
> in balance_dirty_pages() wait for enough IO to complete. The waiting is
> implemented as follows: Whenever we decide to throttle a task in
> balance_dirty_pages(), task adds itself to a list of tasks that are throttled
> against that bdi and goes to sleep waiting to receive specified amount of page
> IO completions. Once in a while (currently HZ/10, in patch 5 the interval is
> autotuned based on observed IO rate), accumulated page IO completions are
> distributed equally among waiting tasks.
> 
> This waiting scheme has been chosen so that waiting time in
> balance_dirty_pages() is proportional to
>   number_waited_pages * number_of_waiters.
> In particular it does not depend on the total number of pages being waited for,
> thus providing possibly a fairer results.

When there comes no IO completion in 1 second (normal in NFS), the
tasks will all get stuck. It is fixable based on your v2 code base
(detailed below), however will likely bring the same level of
complexity as the base bandwidth solution.

As for v2, there are still big gap to fill. NFS dirtiers are
constantly doing 20-25 seconds long delays

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/jan-bdp-v2b/3G/nfs-1dd-1M-8p-2945M-20%25-2.6.38-rc8-jan-bdp+-2011-03-10-16-31/balance_dirty_pages-pause.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/jan-bdp-v2b/3G/nfs-10dd-1M-8p-2945M-20%25-2.6.38-rc8-jan-bdp+-2011-03-10-16-38/balance_dirty_pages-pause.png

and the tasks are bumping forwards

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/jan-bdp-v2b/3G/nfs-10dd-1M-8p-2945M-20%25-2.6.38-rc8-jan-bdp+-2011-03-10-16-38/balance_dirty_pages-task-bw.png

> Since last version I've implemented cleanups as suggested by Peter Zilstra.
> The patches undergone more throughout testing. So far I've tested different
> filesystems (ext2, ext3, ext4, xfs, nfs), also a combination of a local
> filesystem and nfs. The load was either various number of dd threads or
> fio with several threads each dirtying pages at different speed.
> 
> Results and test scripts can be found at
>   http://beta.suse.com/private/jack/balance_dirty_pages-v2/
> See README file for some explanation of test framework, tests, and graphs.
> Except for ext3 in data=ordered mode, where kjournald creates high
> fluctuations in waiting time of throttled processes (and also high latencies),
> the results look OK. Parallel dd threads are being throttled in the same way
> (in a 2s window threads spend the same time waiting) and also latencies of
> individual waits seem OK - except for ext3 they fit in 100 ms for local
> filesystems. They are in 200-500 ms range for NFS, which isn't that nice but
> to fix that we'd have to modify current ratelimiting scheme to take into
> account on which bdi a page is dirtied. Then we could ratelimit slower BDIs
> more often thus reducing latencies in individual waits...

Yes the per-cpu rate limit is a problem, so I'm switching to per-task
rate limit.

The direct input from IO completion is another issue. It leaves the
dirty tasks at the mercy of low layer (VFS/FS/bdev) fluctuations and
latencies. So I'm introducing the base bandwidth as a buffer layer.
You may employ the similar technique: to simulate a more smooth flow
of IO completion events based on the average write bandwidth. Then it
naturally introduce the problem of rate mismatch between
simulated/real IO completions, and the need to do more elaborated
position control.

> The results for different bandwidths fio load is interesting. There are 8
> threads dirtying pages at 1,2,4,..,128 MB/s rate. Due to different task
> bdi dirty limits, what happens is that three most aggresive tasks get
> throttled so they end up at bandwidths 24, 26, and 30 MB/s and the lighter
> dirtiers run unthrottled.

The base bandwidth based throttling can do better and provide almost
perfect fairness, because all tasks writing to one bdi derive their
own throttle bandwidth based on the same per-bdi base bandwidth. So
the heavier dirtiers will converge to equal dirty rate and weight.

> I'm planning to run some tests with multiple SATA drives to verify whether
> there aren't some unexpected fluctuations. But currently I have some trouble
> with the HW...
> 
> As usual comments are welcome :).

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
