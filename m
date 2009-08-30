Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AB8E36B0088
	for <linux-mm@kvack.org>; Sun, 30 Aug 2009 18:27:04 -0400 (EDT)
Date: Sun, 30 Aug 2009 18:27:10 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH, RFC] vm: Add an tuning knob for vm.max_writeback_pages
Message-ID: <20090830222710.GA9938@infradead.org>
References: <1251600858-21294-1-git-send-email-tytso@mit.edu> <20090830165229.GA5189@infradead.org> <20090830181731.GA20822@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090830181731.GA20822@mit.edu>
Sender: owner-linux-mm@kvack.org
To: Theodore Tso <tytso@mit.edu>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-fsdevel@vger.kernel.org, chris.mason@oracle.com, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

On Sun, Aug 30, 2009 at 02:17:31PM -0400, Theodore Tso wrote:
> > 
> > The current writeback sizes are defintively too small, we shoved in
> > a hack into XFS to bump up nr_to_write to four times the value the
> > VM sends us to be able to saturate medium sized RAID arrays in XFS.
> 
> Hmm, should we make it be a per-superblock tunable so that it can
> either be tuned on a per-block device basis or the filesystem code can
> adjust it to their liking?  I thought about it, but decided maybe it
> was better to keeping it simple.

I'm don't think tuning it on a per-filesystem basis is a good idea,
we had to resort to this for 2.6.30 as a quick hack, and we will ged
rid of it again in 2.6.31 one way or another.  I personally think we
should fight this cancer of per-filesystem hacks in the writeback code
as much as we can.  Right now people keep adding tuning hacks for
specific workloads there, and at least all the modern filesystems (ext4,
btrfs and XFS) have very similar requirements to the writeback code,
that is give the filesystem as much as possible to write at the same
time to do intelligent decisions based on that.  The VM writeback code
fails horribly at that right now.

> > Turns out this was not enough and at least for Chris Masons array
> > we only started seaturating at * 16.  I suspect you patch will give
> > a similar effect.
> 
> So you think 16384 would be a better default?  The reason why I picked
> 32768 was because that was the size of the ext4 block group, but it
> was otherwise it was totally arbitrary.  I haven't done any
> benchmarking yet, which is one of the reasons why I thought about
> making it a tunable.

It was just another arbitrary number.  My suspicion is that the exact
number does not matter, it just needs to be much much larger than the
current one.  And the latency concerns are also over-rated as the block
layer will tell us that we are congested if we push too much into a
queue.

> > And the other big question is how this interacts with Jens' new per-bdi
> > flushing code that we still hope to merge in 2.6.32.
> 
> Jens?  What do you think?  Fixing MAX_WRITEBACK_PAGES was something I
> really wanted to merge in 2.6.32 since it makes a huge difference for
> the block allocation layout for a "rsync -avH /old-fs /new-fs" when we
> are copying bunch of large files (say, 800 meg iso images) and so the
> fact that the writeback routine is writing out 4 megs at a time, means
> that our files get horribly interleaved and thus get fragmented.
> 
> I initially thought about adding some massive workarounds in the
> filesystem layer (which is I guess what XFS did),

XFS is relatively good at doing the disk block layout even with smaller
writeouts, so we do not have that fragmentation hack.  And the
for-2.6.30 big hack is one liner:

--- a/fs/xfs/linux-2.6/xfs_aops.c
+++ b/fs/xfs/linux-2.6/xfs_aops.c
@@ -1268,6 +1268,14 @@ xfs_vm_writepage(
 	if (!page_has_buffers(page))
 		create_empty_buffers(page, 1 << inode->i_blkbits, 0);
 
+
+	/*
+	 *  VM calculation for nr_to_write seems off.  Bump it way
+	 *  up, this gets simple streaming writes zippy again.
+	 *  To be reviewed again after Jens' writeback changes.
+	 */
+	wbc->nr_to_write *= 4;
+
 	/*
 	 * Convert delayed allocate, unwritten or unmapped space
 	 * to real space and flush out to disk.

This also went past -fsdevel, but I didn' manage to get the flames for
adding these hacks that I hoped to get ;-)

My stance is to wait for this until about -rc2 at which points Jens'
code is hopefully in and we can start doing all the fine-tuning,
including lots of benchmarking.

Btw, one thing I would really see from one of the big companies or
the LF is doing benchmarks like yours above or just a simple one or
two stream dd on some big machines weekly so we can immediately see
regressions once someones starts to tweak the VM again.  Preferably
including seekwatcher data.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
