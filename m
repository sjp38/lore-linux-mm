From: Daniel Phillips <phillips@innominate.de>
Subject: Re: Random thoughts on sustained write performance
Date: Sat, 27 Jan 2001 18:23:55 +0100
Content-Type: text/plain
References: <Pine.LNX.3.96.1010123205643.7482A-100000@kanga.kvack.org> <01012615062602.20169@gimli> <y7rzogdkssm.fsf@sytry.doc.ic.ac.uk>
In-Reply-To: <y7rzogdkssm.fsf@sytry.doc.ic.ac.uk>
MIME-Version: 1.0
Message-Id: <01012718341801.28895@gimli>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Wragg <dpw@doc.ic.ac.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 27 Jan 2001, David Wragg wrote:
> Daniel Phillips <phillips@innominate.de> writes:
> > Actually, this doesn't account for all the slowdown we observe with
> > streaming writes to multimegabyte files in Ext2.  I'm still thinking
> > about what the rest of it might be - Ext2 has been observed to suffer
> > considerably more than this when files get large.
> 
> It might be worth hacking ext2 to save a timestamped log of all the
> reads and writes it does.

Yes, that would be interesting and useful.  Also check out the Linux
Trace Toolkit:

  http://www.opersys.com/LTT/screenshots.html

> > > Could deferred allocation help here, if it's implementated
> > > appropriately?  When writing a page, defer allocation until:
> > > 
> > > - We have all the necessary indirect blocks in memory
> > > 
> > > - And if the indirect block doesn't give an allocation for the page,
> > > and we have filled the relevant block bitmap, defer further until we
> > > have a block bitmap that does have free space.
> > > 
> > > A write would still have to wait until the metadata reads its location
> > > depends on were done, but it wouldn't cause later writes to stall.
> > 
> > Yes, correct.  Deferred allocation could let us run some filesystem
> > transactions in parallel with the needed metadata reads.  Did you see
> > my "[RFC] Generic deferred file writing" patch on lkml?  For each page
> > in the generic_file_write we'd call the filesystem and it would
> > initiate IO for the needed metadata.  The last of these reads could be
> > asynchronous, and just prior to carrying out the deferred writes we'd
> > wait for all the metadata reads to complete.  This hack would most
> > likely be good for a few percent throughput improvement. It's a
> > subtle point, isn't it? 
> 
> What's the reason for only making the last read asynchronous, rather
> than all of them?

You don't know the block number of the bottom-level index block until
you read its parents.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
