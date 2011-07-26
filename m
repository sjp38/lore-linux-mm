Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6726B016B
	for <linux-mm@kvack.org>; Tue, 26 Jul 2011 09:57:40 -0400 (EDT)
Date: Tue, 26 Jul 2011 15:57:30 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Properly reflect task dirty limits in
 dirty_exceeded logic
Message-ID: <20110726135730.GD20131@quack.suse.cz>
References: <1309458764-9153-1-git-send-email-jack@suse.cz>
 <20110704010618.GA3841@localhost>
 <20110711170605.GF5482@quack.suse.cz>
 <20110713230258.GA17011@localhost>
 <20110714213409.GB16415@quack.suse.cz>
 <20110723074344.GA31975@localhost>
 <20110725160429.GG6107@quack.suse.cz>
 <20110726041322.GA22180@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110726041322.GA22180@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On iue 26-07-11 12:13:22, Wu Fengguang wrote:
> On Tue, Jul 26, 2011 at 12:04:29AM +0800, Jan Kara wrote:
> > On Sat 23-07-11 15:43:45, Wu Fengguang wrote:
> > > On Fri, Jul 15, 2011 at 05:34:09AM +0800, Jan Kara wrote:
> > > > > - tasks dirtying close to 25% pages probably cannot be called light
> > > > >   dirtier and there is no need to protect such tasks
> > > >   The idea is interesting. The only problem is that we don't want to set
> > > > dirty_exceeded too late so that heavy dirtiers won't push light dirtiers
> > > > over their limits so easily due to ratelimiting. It did some computations:
> > > > We normally ratelimit after 4 MB. Take a low end desktop these days. Say
> > > > 1 GB of ram, 4 CPUs. So dirty limit will be ~200 MB and the area for task
> > > > differentiation ~25 MB. We enter balance_dirty_pages() after dirtying
> > > > num_cpu * ratelimit / 2 pages on average which gives 8 MB. So we should
> > > > set dirty_exceeded at latest at bdi_dirty / TASK_LIMIT_FRACTION / 2 or
> > > > task differentiation would have no effect because of ratelimiting.
> > > > 
> > > > So we could change the limit to something like:
> > > > bdi_dirty - min(bdi_dirty / TASK_LIMIT_FRACTION, ratelimit_pages *
> > > > num_online_cpus / 2 + bdi_dirty / TASK_LIMIT_FRACTION / 16)
> > > 
> > > Good analyze!
> > > 
> > > > But I'm not sure setups where this would make difference are common...
> > > 
> > > I think I'd prefer the original simple patch given that the common
> > > 1-dirtier is not impacted.
> >   OK, thanks. So will you merge the patch please?
> 
> The patch with a minor variable rename has been in writeback.git and
> linux-next for two weeks, and two days ago I updated it to your
> original patch:
> 
> http://git.kernel.org/?p=linux/kernel/git/wfg/writeback.git;a=commit;h=bcff25fc8aa47a13faff8b4b992589813f7b450a
  Ah, thanks.

> If you have no more problems with the patchset, I'll ask Linus
> to pull that branch.
  Umm, I thought we ultimately still push changes through Andrew? I don't
mind pushing them directly but I'm not sure e.g. Andrew is aware of this.

Regarding patches in your for_linus branch. I see there:
6e6938b writeback: introduce .tagged_writepages for the WB_SYNC_NONE sync stage
94c3dcb writeback: update dirtied_when for synced inode to prevent livelock
cb9bd11 writeback: introduce writeback_control.inodes_written
e6fb6da writeback: try more writeback as long as something was written
ba9aa83 writeback: the kupdate expire timestamp should be a moving target
424b351 writeback: refill b_io iff empty
f758eea writeback: split inode_wb_list_lock into bdi_writeback.list_lock
e8dfc30 writeback: elevate queue_io() into wb_writeback()
e185dda writeback: avoid extra sync work at enqueue time
6f71865 writeback: add bdi_dirty_limit() kernel-doc
3efaf0f writeback: skip balance_dirty_pages() for in-memory fs
b7a2441 writeback: remove writeback_control.more_io
846d5a0 writeback: remove .nonblocking and .encountered_congestion
251d6a4 writeback: trace event writeback_single_inode
e84d0a4 writeback: trace event writeback_queue_io
36715ce writeback: skip tmpfs early in balance_dirty_pages_ratelimited_nr()
d46db3d writeback: make writeback_control.nr_to_write straight

I believe the above patches were generally agreed upon so they can go in.

f7d2b1e writeback: account per-bdi accumulated written pages
e98be2d writeback: bdi write bandwidth estimation
00821b0 writeback: show bdi write bandwidth in debugfs
7762741 writeback: consolidate variable names in balance_dirty_pages()
c42843f writeback: introduce smoothed global dirty limit
ffd1f60 writeback: introduce max-pause and pass-good dirty limits
e1cbe23 writeback: trace global_dirty_state
1a12d8b writeback: scale IO chunk size up to half device bandwidth

But why do you think these patches should be merged? f7d2b1e, 7762741 are
probably OK to go but don't have much sense without the rest. The other
patches do not have any Acked-by or Reviewed-by from anyone and I don't
think they are really obvious enough to not deserve some.

fcc5c22 writeback: don't busy retry writeback on new/freeing inodes
bcff25f mm: properly reflect task dirty limits in dirty_exceeded logic

These two are fixes so they should go in as well.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
