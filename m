Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id CE5D66B0032
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 19:38:26 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id p10so20180041pdj.13
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 16:38:26 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id tj1si15228519pab.224.2015.01.09.16.38.23
        for <linux-mm@kvack.org>;
        Fri, 09 Jan 2015 16:38:25 -0800 (PST)
Date: Sat, 10 Jan 2015 11:38:19 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCHSET RFC block/for-next] writeback: cgroup writeback support
Message-ID: <20150110003819.GP31508@dastard>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
 <20150106214426.GA24106@htj.dyndns.org>
 <20150107234532.GD25000@dastard>
 <20150109212336.GB2785@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150109212336.GB2785@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com

On Fri, Jan 09, 2015 at 04:23:36PM -0500, Tejun Heo wrote:
> Hello, Dave.
> 
> On Thu, Jan 08, 2015 at 10:45:32AM +1100, Dave Chinner wrote:
> > > Complications mostly arise from filesystems and inodes having to deal
> > > with multiple split bdi's instead of one, but those are mostly
> > > straight-forward 1:N mapping issues.  It does get tedious here and
> > > there but doesn't complicate the overall picture.
> > 
> > Some filesystems don't track metadata-dirty inode state in the bdi
> > lists, and instead track that in their own lists (usually deep
> > inside the journalling subsystem). i.e. I_DIRTY_PAGES are the only
> > dirty state that is tracked in the VFS. i.e. inode metadata
> > writeback will still be considered global, but pages won't be. Hence
> > you might get pages written back quickly, but the inodes are going
> > to remain dirty and unreclaimable until the filesystem flushes some
> > time in the future after the journal is committed and the inode
> > written...
> 
> I'm not sure I'm following.  What writeback layer provides is cgroup
> awareness when dealing with I_DIRTY_PAGES.  Metadata writebacks will
> become automatically cgroup-aware to the extent they go through
> regular page dirtying mechanism.

That's my point - inode metadata drtying/writeback don't go through
the regular page dirtying mechanisms.

> What's implemented in this patchset is
> propagation of memcg tags for pagecache pages.  If necessary, further
> mechanisms can be added, but this should cover the basics.

Sure, but I'm just pointing out that if you dirty a million inodes
in a memcg (e.g. chown -R), memcg-based writeback will not cause
them to be written...

> > There has also been talk of allowing filesystems to directly track
> > dirty page state as well - the discussion came out of the way tux3
> > was tracking and committing delta changes to file data. Now that
> > hasn't gone anywhere, but I'm wondering what impact this patch set
> > would have on such proposals?
> 
> Would such a filesystem take over writeback mechanism too?

That was the intent.
> The
> implemented mechanism is fairly modular and the counterparts in each
> filesystem should be able to use them the same way the core writeback
> code does.  I'm afraid I can't say much without knowing further
> details.

Ok,you haven't said "that's impossible", so that's good enough for
now ;)

> > Similarly, I'm concerned about additional overhead in the writeback
> > path - we can easily drive the flusher thread to be CPU bound on IO
> > subsystems that have decent bandwidth (low GB/s), so adding more
> > overhead to every page we have to flush is going to reduce
> > performance on these systems. Do you have any idea what impact
> > just enabling the memcg/blkcg tracking has on writeback performance
> > and CPU consumption?
> 
> I measured avg sys+user time of 50 iterations of
> 
>   fs_mark -d /mnt/tmp/ -s 104857600 -n 32
> 
> on an ext2 on a ramdisk, which should put the hot path part - page
> faulting and inode dirtying - under spotlight.  cgroup writeback
> enabled but not used case consumes around 1% more cpu time - AVG 6.616
> STDEV 0.050 w/o this patchset, AVG 6.682 STDEV 0.046 with.  This is an
> extreme case and while it isn't free the overhead is fairly low.

What's the throughput for these numbers? CPU usage without any idea
of the number of pages being scanned doesn't tell us a whole lot.

> > A further complication for data writeback is that some filesystems
> > do their own adjacent page write clustering own inside their own
> > ->writepages/->writepage implementations. Both ext4 and XFS do this,
> > and it makes no sense from a system and filesystem performance
> > perspective to turn sequential ranges of dirty pages into much
> > slower, semi-random IO just because the pages belong to different
> > memcgs. It's not a good idea to compromise bulk writeback
> > throughput under memory pressure just because a different memcgs
> > write to the same files, so what is going to be the impact of
> > filesystems ignoring memcg ownership during writeback clustering?
> 
> I don't think that's a good idea.  Implementing that isn't hard.
> Range writeback can simply avoid skipping pages from different
> cgroups; however, different cgroups can have vastly different
> characteristics.  One may be configured to have a majority of the
> available bandwidth while another has to scrap by with few hundreds of
> k's per sec.  Initiating write out on pages which belong to the former
> from the writeback of the latter may cause serious priority inversion
> issues.

I'd suggest that you should provide mechanisms at the block layer
for accounting the pages in the bio to the memcg they belong to,
not make a sweeping directive that filesystems can only write back
pages from one memcg at a time.

If you account for pages to their memcg and decide on bio priority
at bio_add_page() time you would avoid the inversion and cross-cg
accounting problems.  If you do this, the filesystem doesn't need to
care at all what memcg pages belong to; they just do optimal IO to
clean sequential dirty pages and it is accounted and throttled
appropriately by the lower layers.

> Maybe we can think of optimizations down the road but I'd strongly
> prefer to stick to simple and clear divisions among cgroups.  Also, a
> file highly interleaved by multiple cgroups isn't a particularly
> likely use case.

That's true, and that's a further reason why I think we should not
be caring about this case in the filesystem writeback code at all.

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
