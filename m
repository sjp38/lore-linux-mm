Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0CC0F6B0032
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 18:46:03 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so7923799pad.10
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 15:46:02 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id dx4si5660838pbb.90.2015.01.07.15.46.00
        for <linux-mm@kvack.org>;
        Wed, 07 Jan 2015 15:46:01 -0800 (PST)
Date: Thu, 8 Jan 2015 10:45:32 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCHSET RFC block/for-next] writeback: cgroup writeback support
Message-ID: <20150107234532.GD25000@dastard>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
 <20150106214426.GA24106@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150106214426.GA24106@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com

On Tue, Jan 06, 2015 at 04:44:26PM -0500, Tejun Heo wrote:
> Hello, again.  A bit of addition.
> 
> On Tue, Jan 06, 2015 at 04:25:37PM -0500, Tejun Heo wrote:
> ...
> > Overall design
> > --------------
> 
> What's going on in this patchset is fairly straight forward.  The main
> thing which is happening is that a bdi is being split into multiple
> per-cgroup pieces.  Each split bdi, represented by bdi_writeback,
> behaves mostly identically with how bdi behaved before.

I like the overall direction you've taken, Tejun, but I have
a couple of questions...

> Complications mostly arise from filesystems and inodes having to deal
> with multiple split bdi's instead of one, but those are mostly
> straight-forward 1:N mapping issues.  It does get tedious here and
> there but doesn't complicate the overall picture.

Some filesystems don't track metadata-dirty inode state in the bdi
lists, and instead track that in their own lists (usually deep
inside the journalling subsystem). i.e. I_DIRTY_PAGES are the only
dirty state that is tracked in the VFS. i.e. inode metadata
writeback will still be considered global, but pages won't be. Hence
you might get pages written back quickly, but the inodes are going
to remain dirty and unreclaimable until the filesystem flushes some
time in the future after the journal is committed and the inode
written...

There has also been talk of allowing filesystems to directly track
dirty page state as well - the discussion came out of the way tux3
was tracking and committing delta changes to file data. Now that
hasn't gone anywhere, but I'm wondering what impact this patch set
would have on such proposals?

Similarly, I'm concerned about additional overhead in the writeback
path - we can easily drive the flusher thread to be CPU bound on IO
subsystems that have decent bandwidth (low GB/s), so adding more
overhead to every page we have to flush is going to reduce
performance on these systems. Do you have any idea what impact
just enabling the memcg/blkcg tracking has on writeback performance
and CPU consumption?

A further complication for data writeback is that some filesystems
do their own adjacent page write clustering own inside their own
->writepages/->writepage implementations. Both ext4 and XFS do this,
and it makes no sense from a system and filesystem performance
perspective to turn sequential ranges of dirty pages into much
slower, semi-random IO just because the pages belong to different
memcgs. It's not a good idea to compromise bulk writeback
throughput under memory pressure just because a different memcgs
write to the same files, so what is going to be the impact of
filesystems ignoring memcg ownership during writeback clustering?

Finally, distros are going to ship with this always enabled, so what
is the overall increase in the size of the struct inode on a 64
bit system with it enabled?

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
