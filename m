Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id A3DDB6B002C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 17:58:06 -0500 (EST)
Date: Mon, 5 Mar 2012 23:58:01 +0100
From: Andrea Righi <andrea@betterlinux.com>
Subject: Re: [ATTEND] [LSF/MM TOPIC] Buffered writes throttling
Message-ID: <20120305225801.GB7545@thinkpad>
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
Cc: Fengguang Wu <fengguang.wu@intel.com>, Suresh Jayaraman <sjayaraman@suse.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, Greg Thelen <gthelen@google.com>

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
> 
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
> 
> I am little vary of keeping "dirty rate limit" separate from rest of the
> limits as configuration of groups becomes even harder. Once you put a
> workload in a cgroup, now you need to configure multiple rate limits.
> "reads and direct writes" limit + "buffered write rate limit". To add
> to the confusion, it is not just direct write limit, it also is a limit
> on writethrough writes where fsync writes will show up in the context
> of writing thread.
> 
> But looks like we don't much choice. As buffered writes can be controlled
> at two levels, we probably need two knobs. Also controlling writes while
> entring cache limits will be global and not per device (unlinke currnet
> per device limit in blkio controller). Having separate control for "dirty
> rate limit" leaves the scope for implementing write control at device
> level in the future (As some people prefer that). In possibly two 
> solutions can co-exist in future.
> 
> Assuming this means that we both agree that three should be some sort of
> knob to control "dirty rate", question is where should it be. In memcg
> or blkcg. Given the fact we are controlling the write to memory and
> we are already planning to have per memcg dirty ratio and dirty bytes,
> to me it will make more sense to integrate this new limit with memcg
> instead of blkcg. Block layer does not even come into the picture at
> that level hence implementing something in blkcg will be little out of
> place?
> 
> Thanks
> Vivek

What about this scenario? (Sorry, I've not followed some of the recent
discussions on this topic, so I'm sure I'm oversimplifying a bit or
ignoring some details):

 - track inodes per-memcg for writeback IO (provided Greg's patch)
 - provide per-memcg dirty limit (global, not per-device); when this
   limit is exceeded flusher threads are awekened and all tasks that
   continue to generate new dirty pages inside the memcg are put to
   sleep
 - flusher threads start to write some dirty inodes of this memcg (using
   the inode tracking feature), let say they start with a chunk of N
   pages of the first dirty inode
 - flusher threads can't flush in this way more than N pages / sec
   (where N * PAGE_SIZE / sec is the blkcg "buffered write rate limit"
   on the inode's block device); if a flusher thread exceeds this limit
   it won't be blocked directly, it just stops flushing pages for this
   memcg after the first chunk and it can continue to flush dirty pages
   of a different memcg.

In this way tasks are actively limited at the memcg layer and the
writeback rate is limited by the blkcg layer. The missing piece (that
has not been proposed yet) is to plug into the flusher threads the logic
"I can flush your memcg dirty pages only if your blkcg rate is ok,
otherwise let's see if someone else needs to flush some dirty pages".

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
