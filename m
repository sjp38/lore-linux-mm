Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id CB2416B002C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 17:30:29 -0500 (EST)
Date: Mon, 5 Mar 2012 14:30:29 -0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [ATTEND] [LSF/MM TOPIC] Buffered writes throttling
Message-ID: <20120305223029.GB16807@localhost>
References: <4F507453.1020604@suse.com>
 <20120302153322.GB26315@redhat.com>
 <20120305192226.GA3670@localhost>
 <20120305211114.GF18546@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120305211114.GF18546@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Suresh Jayaraman <sjayaraman@suse.com>, lsf-pc@lists.linux-foundation.org, Andrea Righi <andrea@betterlinux.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, Greg Thelen <gthelen@google.com>

On Mon, Mar 05, 2012 at 04:11:15PM -0500, Vivek Goyal wrote:
> On Mon, Mar 05, 2012 at 11:22:26AM -0800, Fengguang Wu wrote:
> 
> [..]
> > > This is an interesting and complicated topic. As you mentioned we have had
> > > tried to solve it but nothing has been merged yet. Personally, I am still
> > > interested in having a discussion and see if we can come up with a way
> > > forward.
> > 
> > I'm interested, too. Here is my attempt on the problem a year ago:
> > 
> > blk-cgroup: async write IO controller ("buffered write" would be more precise)
> > https://github.com/fengguang/linux/commit/99b1ca4549a79af736ab03247805f6a9fc31ca2d
> > https://lkml.org/lkml/2011/4/4/205
> 
> That was a proof of concept. Now we will need to provide actual user 
> visibale knobs and integrate with one of the existing controller (memcg
> or blkcg).

The next commit adds the interface to blkcg:

throttle.async_write_bps

Note that it's simply exporting the knobs via blkcg and does not
really depend on the blkcg functionalities.

> [..]
> > > Anyway, ideas to have better control of write rates are welcome. We have
> > > seen issues wheren a virtual machine cloning operation is going on and
> > > we also want a small direct write to be on disk and it can take a long
> > > time with deadline. CFQ should still be fine as direct IO is synchronous
> > > but deadline treats all WRITEs the same way.
> > > 
> > > May be deadline should be modified to differentiate between SYNC and ASYNC
> > > IO instead of READ/WRITE. Jens?
> > 
> > In general users definitely need higher priorities for SYNC writes. It
> > will also enable the "buffered write I/O controller" and "direct write
> > I/O controller" to co-exist well and operate independently this way:
> > the direct writes always enjoy higher priority than the flusher, but
> > will be rate limited by the already upstreamed blk-cgroup I/O
> > controller. The remaining disk bandwidth will be split among the
> > buffered write tasks by another I/O controller operating at the
> > balance_dirty_pages() level.
> 
> Ok, so differentiating IO among SYNC/ASYNC makes sense and it probably
> will make sense in case of deadline too. (Until and unless there is a
> reason to keep it existing way).

Agreed. But note that the deadline I/O scheduler has nothing to do
with the I/O controllers.

> I am little vary of keeping "dirty rate limit" separate from rest of the
> limits as configuration of groups becomes even harder. Once you put a
> workload in a cgroup, now you need to configure multiple rate limits.
> "reads and direct writes" limit + "buffered write rate limit".

Good point. If we really want it, it's technically possible to provide
one single write rate limit to the user. The way is to account the
current DIRECT write bandwidth. Subtract it from the general write
rate limit, we get the limit available for buffered writes.

Thus we'll be providing some "throttle.total_write_bps" rather than
"throttle.async_write_bps". Oh it may be difficult to implement
total_write_bps for direct writes, which is implemented at the device
level. But still if it's the right interface to have, we can make it
happen by calling into balance_dirty_pages() (or some algorithm
abstracted from it) at the end of each direct write and let it handle
the global wise throttling.

> To add
> to the confusion, it is not just direct write limit, it also is a limit
> on writethrough writes where fsync writes will show up in the context
> of writing thread.

Sorry I'm not sure I caught the words. Is it that O_SYNC writes can
and would be (confusingly) rate limited at both levels?

> But looks like we don't much choice. As buffered writes can be controlled
> at two levels, we probably need two knobs. Also controlling writes while
> entring cache limits will be global and not per device (unlinke currnet
> per device limit in blkio controller). Having separate control for "dirty
> rate limit" leaves the scope for implementing write control at device
> level in the future (As some people prefer that). In possibly two 
> solutions can co-exist in future.

Good point. balance_dirty_pages() has no idea about the devices at
all. So the rate limit for buffered writes can hardly be unified with
the per-device rate limit for direct writes.

BTW it may have technically merits to enforce per-bdi buffered write
rate limits for each cgroup: imagine it's writing concurrently to a
10MB/s USB key and a 100MB/s disk. But perhaps also de-merits when all
the user want is the gross write rate, rather than to care about the
unnecessarily partition between sda1 and sda2.

> Assuming this means that we both agree that three should be some sort of
> knob to control "dirty rate", question is where should it be. In memcg
> or blkcg. Given the fact we are controlling the write to memory and
> we are already planning to have per memcg dirty ratio and dirty bytes,
> to me it will make more sense to integrate this new limit with memcg
> instead of blkcg. Block layer does not even come into the picture at
> that level hence implementing something in blkcg will be little out of
> place?

I personally prefer memcg for dirty sizes and blkcg for dirty rates.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
