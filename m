Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4D2D16B004D
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 02:34:44 -0400 (EDT)
Date: Mon, 17 Aug 2009 08:34:38 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] fs: turn iprune_mutex into rwsem
Message-ID: <20090817063438.GA9962@wotan.suse.de>
References: <20090814152504.GA19195@wotan.suse.de> <20090815195742.GA14842@infradead.org> <20090816221159.GR5931@webber.adilger.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090816221159.GR5931@webber.adilger.int>
Sender: owner-linux-mm@kvack.org
To: Andreas Dilger <adilger@sun.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, Aug 16, 2009 at 04:11:59PM -0600, Andreas Dilger wrote:
> On Aug 15, 2009  15:57 -0400, Christoph Hellwig wrote:
> > On Fri, Aug 14, 2009 at 05:25:05PM +0200, Nick Piggin wrote:
> > > Now I think the main problem is having the filesystem block (and do IO
> > > in inode reclaim. The problem is that this doesn't get accounted well
> > > and penalizes a random allocator with a big latency spike caused by
> > > work generated from elsewhere.
> > > 
> > > I think the best idea would be to avoid this. By design if possible,
> > > or by deferring the hard work to an asynchronous context. If the latter,
> > > then the fs would probably want to throttle creation of new work with
> > > queue size of the deferred work, but let's not get into those details.
> > 
> > I don't really see a good way to avoid this.  For any filesystem that
> > does some sort of preallocations we need to drop them in ->clear_inode.
> 
> One of the problems I've seen in the past is that filesystem memory reclaim
> (in particular dentry/inode cleanup) cannot happen within filesystems due
> to potential deadlocks.  This is particularly problematic when there is a
> lot of memory pressure from within the kernel and very little from userspace
> (e.g. updatedb or find).

Hm OK. It should still kick off kswapd at least which can reclaim GFP_FS.

 
> However, many/most inodes/dentries in the filesystem could be discarded
> quite easily and would not deadlock the system.  I wonder if it makes
> sense to keep a mask in the inode that the filesystem could set that
> determines whether it is safe to clean up the inode even though __GFP_FS
> is not set?  That would potentially allow e.g. shrink_icache_memory()
> to free a large number of "non-tricky" inodes if needed (e.g. ones without
> locks/preallocation/expensive cleanup).

I guess it would be possible but even before calling into the FS it
requires taking some locks. So we would need to make all existing
~__GFP_FS allocations have all the FS bits clear, and then where safe
they could be converted to just set some of the FS bits but not
others.

It's rather complex though. Do you have any specific workloads you
can reproduce? Because we could also look at well this patch to start
with but also maybe like another callback which can schedule slow
work on tricky inodes.

Hmm, I guess we could just trylock on the iprune_mutex and inode_lock
if GFP_FS is not set, then the fs would have to work out what to do
with the gfp_mask it has.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
