Subject: Re: Random thoughts on sustained write performance
References: <Pine.LNX.3.96.1010123205643.7482A-100000@kanga.kvack.org>
	<01012615062602.20169@gimli> <y7rzogdkssm.fsf@sytry.doc.ic.ac.uk>
	<01012718341801.28895@gimli>
From: David Wragg <dpw@doc.ic.ac.uk>
Date: 27 Jan 2001 21:23:43 +0000
In-Reply-To: Daniel Phillips's message of "Sat, 27 Jan 2001 18:23:55 +0100"
Message-ID: <y7rbsssit9c.fsf@eagle.doc.ic.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@innominate.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Daniel Phillips <phillips@innominate.de> writes:
> > > Yes, correct.  Deferred allocation could let us run some filesystem
> > > transactions in parallel with the needed metadata reads.  Did you see
> > > my "[RFC] Generic deferred file writing" patch on lkml?  For each page
> > > in the generic_file_write we'd call the filesystem and it would
> > > initiate IO for the needed metadata.  The last of these reads could be
> > > asynchronous, and just prior to carrying out the deferred writes we'd
> > > wait for all the metadata reads to complete.  This hack would most
> > > likely be good for a few percent throughput improvement. It's a
> > > subtle point, isn't it? 
> > 
> > What's the reason for only making the last read asynchronous, rather
> > than all of them?
> 
> You don't know the block number of the bottom-level index block until
> you read its parents.

The index block reads need to be done in sequence before the write of
the block.  But I can't see why the process calling
generic_file_write needs to wait for any of the I/Os to complete.

I realize that this is a slight over-generalization, since ENOSPC
needs to be returned synchronously from write(2).


David
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
