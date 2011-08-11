Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4226F900137
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 16:43:11 -0400 (EDT)
Date: Thu, 11 Aug 2011 16:42:55 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 0/5] IO-less dirty throttling v8
Message-ID: <20110811204255.GH8552@redhat.com>
References: <20110806084447.388624428@intel.com>
 <20110809020127.GA3700@redhat.com>
 <20110811032143.GB11404@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110811032143.GB11404@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 11, 2011 at 11:21:43AM +0800, Wu Fengguang wrote:
> > [...] it only deals with controlling buffered write IO and nothing
> > else. So on the same block device, other direct writes might be
> > going on from same group and in this scheme a user will not have any
> > control.
> 
> The IO-less balance_dirty_pages() will be able to throttle DIRECT
> writes. There is nothing fundamental in the way.
> 
> The basic approach will be to add a balance_dirty_pages_ratelimited_nr()
> call in the DIRECT write path, and to call into balance_dirty_pages()
> regardless of the various dirty thresholds.
> 
> Then the IO-less balance_dirty_pages() has all the facilities to
> throttle a task at any auto-estimated or user-specified ratelimit.

A direct IO being routed through balance_dirty_pages() when it is really
not dirtying anything, sounds really odd to me.

What about direct AIO. Throttling direct IO at balance_dirty_pages() is
little different than throttling at device level where we build a buffer
of requests and submit requests asynchronously (even when submitter
has crossed the threshold/rate). Submitter does not have to block and
can go back to user space and do other things while waiting for
completion of submitted IO. 

You know what, since the beginning you have been talking about how
this mechanism can be extended to do some IO control. That's fine.
I think a more fruitul discussion can happen if we approach the
problem in a different way and that is lets figure out what are
the requirements, what are the problems, what do we need to control,
what is the best place to control something and how the interface
is going to look like.

Once we figure out interfaces and what are we trying to achieve
then rest of it is just mechanism and your method is one possible
way of implementing things and then we can discuss advantages and
disadvantages of various mechanisms.

What do we want
---------------

To me I see basic problem is as follows. We primarily want to provide
two controls, atleast at cgroup level. If the same can be extended
to task level, that's a bonus.

- Notion of iopriority (work conserving control, proportional IO)
- Absolute limits (non work conserving control, throttling)

What do we currently have
-------------------------
- Proportional IO is implemented at device level in CFQ IO scheduler.
	- It works both at task level (ioprio) and group level
	  (blkio.weight). The only problem is it works only for
	  synchronous IO and does not cover buffered WRITES. 

- Throttling
	- Implemented at block layer (per device). Works for groups. There
	  is no per task interface. Again works for synchronous IO and
 	  does not cover buffered writes.

So to me in current scheme of things there is only one big problem to
be solved.

- How to control buffered writes.
	- prportional IO
	- Absolute throttling.

Proportional IO
---------------
- Because we lose all the context information of submitter by the time IO
  reaches CFQ, for task ioprio, it is probably best to do something about
  it when writting to bdi. So your scheme sounds like a good candiate
  for that.

- At cgroup level, things get little more complicated as priority belongs
  to the whole group and a group could be doing some READs, some direct
  WRITES and some buffered WRITEs. If we implement a group's proportional
  write control at page cache level, we have following issue.

	- bdi based control does not know about READs and direct WRITEs.
	  Now assume that a high prio group is doing just buffered writes
	  and a low prio group is doing READs. CFQ will choke WRITEs
	  behind READs and effectively a higher prio group did not get
	  its share.

  So I think doing proportional IO control at device level provides
  better control overall and better integration with cgroups.

Throttling
----------
-  Throttling of buffered WRITEs can be done at page cache level and it
   makes sense to me in general. There seem to be two primary issue we
   need to think about.

	- It should gel well with current IO controller interfaces. Either
	  we provide a separate control file in blkio controller which
	  only controls buffered write rate or we come up with a way so
	  that common control knows both about direct and buffered writes
	  and control can come out of common quota. For example if
	  somebody says that 10MB/s is limit for write for this cgroup
	  on device 8:32, then that limit is effective both for direct
	  write as well as buffered write.

	  Alternatively we could implement a separate control file say
	  blkio.throttle.buffered_write_bps_device where one specifies
	  the buffered write rate of a cgroup on a device and your logic
	  parses it and controls it. And direct IO control limit comes
	  from a separate existing file. blkio.throttle.write_bps_device.
	  In my opinion it is less integrated appraoch and user will
	  find it less friendly to configure.

	- IO spike at device when flusher clean up dirty memory. I know
	  you have been saying that IO scheduler's somehow should take
	  care of it, but IO schedulers provide ony so much of protection
	  against WRITE. On top of that protection is not predictable.
	  CFQ still provides good protection against WRITEs but what
	  about deadline and noop. There spikes for sure will lead to
	  less predictable IO latencies for READs. 

  If we implement throttling for buffered write at device level and
  feedback mechanism reduces the dirty rate for the cgroup automatically
  that will take care of both the above issues. The only issue we will
  have to worry about how to take care of priority inversion issues
  where a high prio IO does not get throttled behind low prio IO. For
  that file systems will have to be more parallel. 

  Throttling at page cache level has this advantage that it has to
  worry less about this serializaiton.

So I see following immediate extension of your scheme possible.

- Inherit ioprio from iocontext and provide buffered write service
  differentiation for writers.

- Create a per task buffered write throttling interface and do
  absolute throttling of task.

- We can possibly do the idea of throttling group wide buffered
  writes only control at this layer using this mechanism.

Thoughts?

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
