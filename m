Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 572DE6B0069
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 19:02:03 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id o7so338489134oif.0
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 16:02:03 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id q195si6099263iod.241.2016.09.12.16.01.56
        for <linux-mm@kvack.org>;
        Mon, 12 Sep 2016 16:01:57 -0700 (PDT)
Date: Tue, 13 Sep 2016 09:01:52 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/3] writeback: allow for dirty metadata accounting
Message-ID: <20160912230152.GJ22388@dastard>
References: <1471887302-12730-1-git-send-email-jbacik@fb.com>
 <1471887302-12730-3-git-send-email-jbacik@fb.com>
 <20160909081743.GC22777@quack2.suse.cz>
 <20160912004656.GA30497@dastard>
 <20160912073418.GA23870@quack2.suse.cz>
 <fc294980-dad2-512b-7768-165f4c7460f8@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fc294980-dad2-512b-7768-165f4c7460f8@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <jbacik@fb.com>
Cc: Jan Kara <jack@suse.cz>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, jack@suse.com, viro@zeniv.linux.org.uk, dchinner@redhat.com, hch@lst.de, linux-mm@kvack.org

On Mon, Sep 12, 2016 at 10:24:12AM -0400, Josef Bacik wrote:
> Dave your reply got eaten somewhere along the way for me, so all i
> have is this email.  I'm going to respond to your stuff here.

No worries, I'll do a 2-in-1 reply :P

> On 09/12/2016 03:34 AM, Jan Kara wrote:
> >On Mon 12-09-16 10:46:56, Dave Chinner wrote:
> >>On Fri, Sep 09, 2016 at 10:17:43AM +0200, Jan Kara wrote:
> >>>On Mon 22-08-16 13:35:01, Josef Bacik wrote:
> >>>>Provide a mechanism for file systems to indicate how much dirty metadata they
> >>>>are holding.  This introduces a few things
> >>>>
> >>>>1) Zone stats for dirty metadata, which is the same as the NR_FILE_DIRTY.
> >>>>2) WB stat for dirty metadata.  This way we know if we need to try and call into
> >>>>the file system to write out metadata.  This could potentially be used in the
> >>>>future to make balancing of dirty pages smarter.
> >>>
> >>>So I'm curious about one thing: In the previous posting you have mentioned
> >>>that the main motivation for this work is to have a simple support for
> >>>sub-pagesize dirty metadata blocks that need tracking in btrfs. However you
> >>>do the dirty accounting at page granularity. What are your plans to handle
> >>>this mismatch?
> >>>
> >>>The thing is you actually shouldn't miscount by too much as that could
> >>>upset some checks in mm checking how much dirty pages a node has directing
> >>>how reclaim should be done... But it's a question whether NR_METADATA_DIRTY
> >>>should be actually used in the checks in node_limits_ok() or in
> >>>node_pagecache_reclaimable() at all because once you start accounting dirty
> >>>slab objects, you are really on a thin ice...
> >>
> >>The other thing I'm concerned about is that it's a btrfs-only thing,
> >>which means having dirty btrfs metadata on a system with different
> >>filesystems (e.g. btrfs root/home, XFS data) is going to affect how
> >>memory balance and throttling is run on other filesystems. i.e. it's
> >>going ot make a filesystem specific issue into a problem that
> >>affects global behaviour.
> >
> >Umm, I don't think it will be different than currently. Currently btrfs
> >dirty metadata is accounted as dirty page cache because they have this
> >virtual fs inode which owns all metadata pages.

Yes, so effectively they are treated the same as file data pages
w.r.t. throttling, writeback and reclaim....

> >It is pretty similar to
> >e.g. ext2 where you have bdev inode which effectively owns all metadata
> >pages and these dirty pages account towards the dirty limits. For ext4
> >things are more complicated due to journaling and thus ext4 hides the fact
> >that a metadata page is dirty until the corresponding transaction is
> >committed.  But from that moment on dirty metadata is again just a dirty
> >pagecache page in the bdev inode.

Yeah, though those filesystems don't suffer from the uncontrolled
explosion of metadata that btrfs is suffering from, so simply
treating them as another dirty inode that needs flushing works just
fine.

> >So current Josef's patch just splits the counter in which btrfs metadata
> >pages would be accounted but effectively there should be no change in the
> >behavior.

Yup, I missed the addition to the node_pagecache_reclaimable() that
ensures reclaim sees the same number or dirty pages...

> >It is just a question whether this approach is workable in the
> >future when they'd like to track different objects than just pages in the
> >counter.

I don't think it can. Because the counters directly influences the
page lru reclaim scanning algorithms, it can only be used to
account for pages that are in the LRUs. Other objects like slab
objects need to be accounted for and reclaimed by the shrinker
infrastructure.

Accounting for metadata writeback is a different issue - it could
track slab objects if we wanted to, but the issue is that these are
often difficult to determine the amount of IO needed to clean them
so generic balancing is hard. (e.g. effect of inode write
clustering).

> +1 to what Jan said.  Btrfs's dirty metadata is always going to
> affect any other file systems in the system, no matter how we deal
> with it.  In fact it's worse with our btree_inode approach as the
> dirtied_when thing will likely screw somebody and make us skip
> writing out dirty metadata when we want to.

XFS takes care of metadata flushing with a periodic background work
controlled by /proc/sys/fs/xfs/xfssyncd_centisecs. We trigger both
background async inode reclaim and background dirty metadata
flushing from this (run on workqueues) if the system is idle or
hasn't had some other trigger fire to run these sooner.  It works
well enough that I can't remember the last time someone asked a
question about needing to tune this parameter, or had a problem that
required tuning it to fix....

> At least with this
> framework in place we can start to make the throttling smarter, so
> say make us flush metadata if that is the bigger % of the dirty
> pages in the system.  All I do now is move the status quo around, we
> are no worse, and arguably better with these patches than we were
> without them.

Agreed - I misread part of the patch, so I was a little off-target.

> >OK, thanks for providing the details about XFS. So my idea was (and Josef's
> >patches seem to be working towards this), that filesystems that decide to
> >use the generic throttling, would just account the dirty metadata in some
> >counter. That counter would be included in the limits checked by
> >balance_dirty_pages(). Filesystem that don't want to use generic throttling
> >would have the counter 0 and thus for them there'd be no difference. And in
> >appropriate points after metadata was dirtied, filesystems that care could
> >call balance_dirty_pages() to throttle the process creating dirty
> >metadata.
> >
> >>I can see how tracking of information such as the global amount of
> >>dirty metadata is useful for diagnostics, but I'm not convinced we
> >>should be using it for globally scoped external control of deeply
> >>integrated and highly specific internal filesystem functionality.
> >
> >You are right that when journalling comes in, things get more complex. But
> >btrfs already uses a scheme similar to the above and I believe ext4 could
> >be made to use a similar scheme as well. If you have something better for
> >XFS, then that's good for you and we should make sure we don't interfere
> >with that. Currently I don't think we will.
> 
> XFS doesn't have the problem that btrfs has, so I don't expect it to
> take advantage of this.  Your writeback throttling is tied to your
> journal transactions, which are already limited in size.  Btrfs on
> the other hand is only limited by the amount of memory in the
> system, which is why I want to leverage the global throttling code.
> Btrfs doesn't have the benefit of a arbitrary journal size
> constraint on it's dirty metadata, so we have to rely on the global
> limits to make sure we're kept in check.

Though you do have a transaction reservation system, so I would
expect that be the place where a dirty metadata throttling could be
applied sanely. i.e. if there's too much dirty metadata in the
system, then you can't get a reservation to dirty more until some
of the metadata has been cleaned.

> The only thing my patches
> do is allow us to account for this separately and trigger writeback
> specifically.  Thanks,

I'm not sure that global metadata accounting makes sense if there is
no mechanism provided for per-sb throttling based purely on metadata
demand. Sure, global dirty metadata might be a way of measuring how
much metadata all the active filesystems have created, but then
you're going to throttle filesystems with no dirty metadata because
some other filesystem is being a massive hog.

I suspect that for a well balanced system we are going to need some
kind of "in-between" solution that shares the dirty metadata limits
across all bdis somewhat fairly similar to file data. How that ties
into the bdi writeback rate estimates and other IO/dirty page
throttling feedback loops is an interesting question - to me this
isn't as obviously simple as it simply separating out metadata
accounting...

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
