Subject: Re: Random thoughts on sustained write performance
References: <Pine.LNX.3.96.1010123205643.7482A-100000@kanga.kvack.org>
	<01012513283301.19696@gimli> <y7rsnm7mai7.fsf@sytry.doc.ic.ac.uk>
	<01012615062602.20169@gimli>
From: David Wragg <dpw@doc.ic.ac.uk>
Date: 27 Jan 2001 13:50:49 +0000
In-Reply-To: Daniel Phillips's message of "Fri, 26 Jan 2001 12:19:16 +0100"
Message-ID: <y7rzogdkssm.fsf@sytry.doc.ic.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@innominate.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Daniel Phillips <phillips@innominate.de> writes:
> On Fri, 26 Jan 2001, David Wragg wrote:
> > Daniel Phillips <phillips@innominate.de> writes:
> > > I'll add my $0.02 here.  Besides reading the block bitmap you may have
> > > to read up to three levels of file index blocks as well.  If we stop
> > > pinning the group descriptors in memory you might need to read those as
> > > well.  So this adds up to 4-5 reads, all synchronous.  Worse, the
> > > bitmap block may be widely separated from the index blocks, in turn
> > > widely separated from the data block, and if group descriptors get
> > > added to the mix you may have to seek across the entire disk.  This all
> > > adds up to a pretty horrible worst case latency. 
> > 
> > In general, yes.
> > 
> > For my application, the files being written to are newly created, so
> > reading indirect index blocks isn't an issue.
> 
> But you still have to write them.  If you write full speed at 4
> blocks/ms it will be 250 ms, so 4 times a second you will have to seek
> back to the index block and write it.  The round trip costs 15-20
> ms, so there goes a significant chunk of bandwidth.  Holding the index
> block in cache doesn't help - when you do fill cache with index blocks
> you will have to seek back a lot further.

I see.  Since the optimal layout of index blocks among the data blocks
differs between writing the data and reading it, solving this could be
tricky.  Have other file system implementations developed strategies
to address this?

Some of the index block writes might just incur rotational latency,
rather than a true seek.  But I have no idea how significant this
could be.

> an index blocks and you'll have to read it back synchonously.
> 
> Actually, this doesn't account for all the slowdown we observe with
> streaming writes to multimegabyte files in Ext2.  I'm still thinking
> about what the rest of it might be - Ext2 has been observed to suffer
> considerably more than this when files get large.

It might be worth hacking ext2 to save a timestamped log of all the
reads and writes it does.

> 
> > > Mapping index blocks into the page cache should produce a noticable
> > > average case improvement because we can change from a top-down
> > > traversal of the index hierarchy:
> > > 
> > >   - get triple-indirect index block nr out of inode, getblk(tind)
> > >   - get double-ind nr, getblk(dind)
> > >   - get indirect nr, getblk(ind)
> > > 
> > > to bottom-up:
> > > 
> > >   - is the indirect index block in the page cache? 
> > >   - no? this is it mapped and just needs to be reread?
> > >   - no? then is the double-indirect block there?
> > >   - yes? ah, now we know the block nr of the triple-indirect block,
> > >     map it and read it in and we're done.
> > > 
> > > The common case for the page cache is even better:
> > > 
> > >   - is the indirect index block in the page cache? 
> > >   - yes, we're done.
> > > 
> > > The page cache approach is so much better because we directly compute
> > > the page cache index at which we should find the bottom-level index
> > > block.  The buffers-only approach requires us to traverse the whole
> > > chain every time.
> > 
> > Neat stuff!  Makes the traditional buffer-based implementations of
> > Unix filesystems seem a bit klugey.
> 
> And might have something to do with the logically indexed cache that
> BSD now uses?
> 
> > > [snip]
> > > 
> > > Getting back on-topic, we don't improve the worst case behaviour at all
> > > with the page-cache approach, which is what matters in rate-guaranteed
> > > io.  So the big buffer is still needed, and it might need to be even
> > > bigger than suggested.  If we are *really* unlucky and everything is
> > > not only out of cache but widely separated on disk, we could be hit
> > > with 4 reads at 5 ms each, total 20 ms.  If the disk transfers 16
> > > meg/sec (4 blocks/ms) and we're generating io at 8 meg/sec (2
> > > blocks/ms) then the metadata reads will create a backlog of 80 blocks
> > > which will take 40 ms to clear - hope we don't hit more synchronous
> > > reads during that time.
> > 
> > Could deferred allocation help here, if it's implementated
> > appropriately?  When writing a page, defer allocation until:
> > 
> > - We have all the necessary indirect blocks in memory
> > 
> > - And if the indirect block doesn't give an allocation for the page,
> > and we have filled the relevant block bitmap, defer further until we
> > have a block bitmap that does have free space.
> > 
> > A write would still have to wait until the metadata reads its location
> > depends on were done, but it wouldn't cause later writes to stall.
> 
> Yes, correct.  Deferred allocation could let us run some filesystem
> transactions in parallel with the needed metadata reads.  Did you see
> my "[RFC] Generic deferred file writing" patch on lkml?  For each page
> in the generic_file_write we'd call the filesystem and it would
> initiate IO for the needed metadata.  The last of these reads could be
> asynchronous, and just prior to carrying out the deferred writes we'd
> wait for all the metadata reads to complete.  This hack would most
> likely be good for a few percent throughput improvement. It's a
> subtle point, isn't it? 

What's the reason for only making the last read asynchronous, rather
than all of them?


David
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
