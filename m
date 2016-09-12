Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F100A6B0038
	for <linux-mm@kvack.org>; Sun, 11 Sep 2016 20:47:31 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 128so99335009pfb.2
        for <linux-mm@kvack.org>; Sun, 11 Sep 2016 17:47:31 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id h16si18478166pfj.245.2016.09.11.17.47.30
        for <linux-mm@kvack.org>;
        Sun, 11 Sep 2016 17:47:31 -0700 (PDT)
Date: Mon, 12 Sep 2016 10:46:56 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/3] writeback: allow for dirty metadata accounting
Message-ID: <20160912004656.GA30497@dastard>
References: <1471887302-12730-1-git-send-email-jbacik@fb.com>
 <1471887302-12730-3-git-send-email-jbacik@fb.com>
 <20160909081743.GC22777@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160909081743.GC22777@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, jack@suse.com, viro@zeniv.linux.org.uk, dchinner@redhat.com, hch@lst.de, linux-mm@kvack.org

On Fri, Sep 09, 2016 at 10:17:43AM +0200, Jan Kara wrote:
> On Mon 22-08-16 13:35:01, Josef Bacik wrote:
> > Provide a mechanism for file systems to indicate how much dirty metadata they
> > are holding.  This introduces a few things
> > 
> > 1) Zone stats for dirty metadata, which is the same as the NR_FILE_DIRTY.
> > 2) WB stat for dirty metadata.  This way we know if we need to try and call into
> > the file system to write out metadata.  This could potentially be used in the
> > future to make balancing of dirty pages smarter.
> 
> So I'm curious about one thing: In the previous posting you have mentioned
> that the main motivation for this work is to have a simple support for
> sub-pagesize dirty metadata blocks that need tracking in btrfs. However you
> do the dirty accounting at page granularity. What are your plans to handle
> this mismatch?
> 
> The thing is you actually shouldn't miscount by too much as that could
> upset some checks in mm checking how much dirty pages a node has directing
> how reclaim should be done... But it's a question whether NR_METADATA_DIRTY
> should be actually used in the checks in node_limits_ok() or in
> node_pagecache_reclaimable() at all because once you start accounting dirty
> slab objects, you are really on a thin ice...

The other thing I'm concerned about is that it's a btrfs-only thing,
which means having dirty btrfs metadata on a system with different
filesystems (e.g. btrfs root/home, XFS data) is going to affect how
memory balance and throttling is run on other filesystems. i.e. it's
going ot make a filesystem specific issue into a problem that
affects global behaviour.
> 
> > diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> > index 56c8fda..d329f89 100644
> > --- a/fs/fs-writeback.c
> > +++ b/fs/fs-writeback.c
> > @@ -1809,6 +1809,7 @@ static unsigned long get_nr_dirty_pages(void)
> >  {
> >  	return global_node_page_state(NR_FILE_DIRTY) +
> >  		global_node_page_state(NR_UNSTABLE_NFS) +
> > +		global_node_page_state(NR_METADATA_DIRTY) +
> >  		get_nr_dirty_inodes();
> 
> With my question is also connected this - when we have NR_METADATA_DIRTY,
> we could just account dirty inodes there and get rid of this
> get_nr_dirty_inodes() hack...

Accounting of dirty inodes would have to applied to every
filesystem before that could be done, but....

> But actually getting this to work right to be able to track dirty inodes would
> be useful on its own - some throlling of creation of dirty inodes would be
> useful for several filesystems (ext4, xfs, ...).

... this relies on the VFS being able to track and control all
dirtying of inodes and metadata.

Which, it should be noted, cannot be done unconditionally because
some filesystems /explicitly avoid/ dirtying VFS inodes for anything
other than dirty data and provide no mechanism to the VFS for
writeback inodes or their related metadata. e.g. XFS, where all
metadata changes are transactional and so all dirty inode tracking
and writeback control is internal the to the XFS transaction
subsystem.

Adding an external throttle to dirtying of metadata doesn't make any
sense in this sort of architecture - in XFS we already have all the
throttles and expedited writeback triggers integrated into the
transaction subsystem (e.g transaction reservation limits, log space
limits, periodic background writeback, memory reclaim triggers,
etc). It's all so tightly integrated around the physical structure
of the filesystem I can't see any way to sanely abstract it to work
with a generic "dirty list" accounting and writeback engine at this
point...

I can see how tracking of information such as the global amount of
dirty metadata is useful for diagnostics, but I'm not convinced we
should be using it for globally scoped external control of deeply
integrated and highly specific internal filesystem functionality.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
