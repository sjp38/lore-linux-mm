Date: Thu, 26 Jul 2007 09:05:15 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH RFC] extent mapped page cache
Message-ID: <20070726090515.5fd198d1@think.oraclecorp.com>
In-Reply-To: <20070726023639.GD20727@wotan.suse.de>
References: <20070710210326.GA29963@think.oraclecorp.com>
	<20070724160032.7a7097db@think.oraclecorp.com>
	<1185307985.6586.50.camel@localhost>
	<1185312343.5535.5.camel@lappy>
	<20070724192509.5bc9b3fe@think.oraclecorp.com>
	<20070725023217.GA32076@wotan.suse.de>
	<20070725081853.4b325e7f@think.oraclecorp.com>
	<20070726013728.GB20727@wotan.suse.de>
	<20070725221007.0edcc2dc@think.oraclecorp.com>
	<20070726023639.GD20727@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Jul 2007 04:36:39 +0200
Nick Piggin <npiggin@suse.de> wrote:

[ are state trees a good idea? ]

> > One thing it gains us is finding the start of the cluster.  Even if
> > called by kswapd, the state tree allows writepage to find the start
> > of the cluster and send down a big bio (provided I implement
> > trylock to avoid various deadlocks).
> 
> That's very true, we could potentially also do that with the block
> extent tree that I want to try with fsblock.

If fsblock records and extent of 200MB, and writepage is called on a
page in the middle of the extent, how do you walk the radix backwards
to find the first dirty & up to date page in the range?

> 
> I'm looking at "cleaning up" some of these aops APIs so hopefully
> most of the deadlock problems go away. Should be useful to both our
> efforts. Will post patches hopefully when I get time to finish the
> draft this weekend.

Great

> 
> 
> > > > O_DIRECT becomes a special case of readpages and
> > > > writepages....the memory used for IO just comes from userland
> > > > instead of the page cache.
> > > 
> > > Could be, although you'll probably also need to teach the mm about
> > > the state tree and/or still manipulate the pagecache tree to
> > > prevent concurrency?
> > 
> > Well, it isn't coded yet, but I should be able to do it from the FS
> > specific ops.
> 
> Probably, if you invalidate all the pagecache in the range beforehand
> you should be able to do it (and I guess you want to do the invalidate
> anyway). Although, below deadlock issues might still bite somehwere...

Well, O_DIRECT is french for deadlocks.  But I shouldn't have to worry
so much about evicting the pages themselves since I can tag the range.

> 
> 
> > > But isn't the main aim of O_DIRECT to do as little locking and
> > > synchronisation with the pagecache as possible? I thought this is
> > > why your race fixing patches got put on the back burner (although
> > > they did look fairly nice from a correctness POV).
> > 
> > I put the placeholder patches on hold because handling a corner case
> > where userland did O_DIRECT from a mmap'd region of the same file
> > (Linus pointed it out to me).  Basically my patches had to work in
> > 64k chunks to avoid a deadlock in get_user_pages.  With the state
> > tree, I can allow the page to be faulted in but still properly deal
> > with it.
> 
> Oh right, I didn't think of that one. Would you still have similar
> issues with the external state tree? I mean, the filesystem doesn't
> really know why the fault is taken. O_DIRECT read from a file into
> mmapped memory of the same block in the file is almost hopeless I
> think.

Racing is fine as long as we don't deadlock or expose garbage from disk.

> > > > The ability to put in additional tracking info like the process
> > > > that first dirtied a range is also significant.  So, I think it
> > > > is worth trying.
> > > 
> > > Definitely, and I'm glad you are. You haven't converted me yet,
> > > but I look forward to finding the best ideas from our two
> > > approaches when the patches are further along (ext2 port of
> > > fsblock coming along, so we'll be able to have races soon :P).
> > 
> > I'm sure we can find some river in Cambridge, winner gets to throw
> > Axboe in.
> 
> Very noble of you to donate your colleage to such a worthy cause.

Jens is always interested in helping solve such debates.  It's a
fantastic service he provides to the community.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
