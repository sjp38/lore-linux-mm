Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 02B616B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 01:55:57 -0400 (EDT)
Date: Tue, 9 Aug 2011 15:55:51 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/5] IO-less dirty throttling v8
Message-ID: <20110809055551.GP3162@dastard>
References: <20110806084447.388624428@intel.com>
 <20110809020127.GA3700@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110809020127.GA3700@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 08, 2011 at 10:01:27PM -0400, Vivek Goyal wrote:
> On Sat, Aug 06, 2011 at 04:44:47PM +0800, Wu Fengguang wrote:
> > Hi all,
> > 
> > The _core_ bits of the IO-less balance_dirty_pages().
> > Heavily simplified and re-commented to make it easier to review.
> > 
> > 	git://git.kernel.org/pub/scm/linux/kernel/git/wfg/writeback.git dirty-throttling-v8
> > 
> > Only the bare minimal algorithms are presented, so you will find some rough
> > edges in the graphs below. But it's usable :)
> > 
> > 	http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v8/
> > 
> > And an introduction to the (more complete) algorithms:
> > 
> > 	http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/slides/smooth-dirty-throttling.pdf
> > 
> > Questions and reviews are highly appreciated!
> 
> Hi Wu,
> 
> I am going through the slide number 39 where you talk about it being
> future proof and it can be used for IO control purposes. You have listed
> following merits of this approach.
> 
> * per-bdi nature, works on NFS and Software RAID
> * no delayed response (working at the right layer)
> * no page tracking, hence decoupled from memcg
> * no interactions with FS and CFQ
> * get proportional IO controller for free
> * reuse/inherit all the base facilities/functions
> 
> I would say that it will also be a good idea to list the demerits of
> this approach in current form and that is that it only deals with
> controlling buffered write IO and nothing else.

That's not a demerit - that is all it is designed to do.

> So on the same block device, other direct writes might be going on
> from same group and in this scheme a user will not have any
> control.

But it is taken into account by the IO write throttling.

> Another disadvantage is that throttling at page cache
> level does not take care of IO spikes at device level.

And that is handled as well.

How? By the indirect effect other IO and IO spikes have on the
writeback rate. That is, other IO reduces the writeback bandwidth,
which then changes the throttling parameters via feedback loops.

The buffered write throttle is designed to reduce the page cache
dirtying rate to the current cleaning rate of the backing device
is. Increase the cleaning rate (i.e. device is otherwise idle) and
it will throttle less. Decrease the cleaning rate (i.e. other IO
spikes or block IO throttle activates) and it will throttle more.

We have to do vary buffered write throttling like this to adapt to
changing IO workloads (e.g.  someone starting a read-heavy workload
will slow down writeback rate, so we need to throttle buffered
writes more aggressively), so it has to be independent of any sort
of block layer IO controller.

Simply put: the block IO controller still has direct control over
the rate at which buffered writes drain out of the system. The
IO-less write throttle simply limits the rate at which buffered
writes come into the system to match whatever the IO path allows to
drain out....

> Now I think one could probably come up with more sophisticated scheme
> where throttling is done at bdi level but is also accounted at device
> level at IO controller. (Something similar I had done in the past but
> Dave Chinner did not like it).

I don't like it because it is solution to a specific problem and
requires complex coupling across multiple layers of the system. We
are trying to move away from that throttling model. More
fundamentally, though, is that it is not a general solution to the
entire class of "IO writeback rate changed" problems that buffered
write throttling needs to solve.

> Anyway, keeping track of per cgroup rate and throttling accordingly
> can definitely help implement an algorithm for per cgroup IO control.
> We probably just need to find a reasonable way to account all this
> IO to end device so that we have control of all kind of IO of a cgroup.
> How do you implement proportional control here? From overall bdi bandwidth
> vary per cgroup bandwidth regularly based on cgroup weight? Again the
> issue here is that it controls only buffered WRITES and nothing else and
> in this case co-ordinating with CFQ will probably be hard. So I guess
> usage of proportional IO just for buffered WRITES will have limited
> usage.

The whole point of doing the throttling this way is that we don't
need any sort of special connection between block IO throttling and
page cache (buffered write) throttling. We significantly reduce the
coupling between the layers by relying on feedback-driven control
loops to determine the buffered write throttling thresholds
adaptively. IOWs, the IO-less write throttling at the page cache
will adjust automatically to whatever throughput the block IO
throttling allows async writes to achieve.

However, before we have a "finished product", there is still another
piece of the puzzle to be put in place - memcg-aware buffered
writeback. That is, having a flusher thread do work on behalf of
memcg in the IO context of the memcg. Then the IO controller just
sees a stream of async writes in the context of the memcg the
buffered writes came from in the first place. The block layer
throttles them just like any other IO in the IO context of the
memcg...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
