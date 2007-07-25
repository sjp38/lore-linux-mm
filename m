Date: Wed, 25 Jul 2007 08:18:53 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH RFC] extent mapped page cache
Message-ID: <20070725081853.4b325e7f@think.oraclecorp.com>
In-Reply-To: <20070725023217.GA32076@wotan.suse.de>
References: <20070710210326.GA29963@think.oraclecorp.com>
	<20070724160032.7a7097db@think.oraclecorp.com>
	<1185307985.6586.50.camel@localhost>
	<1185312343.5535.5.camel@lappy>
	<20070724192509.5bc9b3fe@think.oraclecorp.com>
	<20070725023217.GA32076@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Jul 2007 04:32:17 +0200
Nick Piggin <npiggin@suse.de> wrote:

> On Tue, Jul 24, 2007 at 07:25:09PM -0400, Chris Mason wrote:
> > On Tue, 24 Jul 2007 23:25:43 +0200
> > Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > 
> > The tree is a critical part of the patch, but it is also the
> > easiest to rip out and replace.  Basically the code stores a range
> > by inserting an object at an index corresponding to the end of the
> > range.
> > 
> > Then it does searches by looking forward from the start of the
> > range. More or less any tree that can search and return the first
> > key >= than the requested key will work.
> > 
> > So, I'd be happy to rip out the tree and replace with something
> > else. Going completely lockless will be tricky, its something that
> > will deep thought once the rest of the interface is sane.
> 
> Just having the other tree and managing it is what makes me a little
> less positive of this approach, especially using it to store pagecache
> state when we already have the pagecache tree.
> 
> Having another tree to store block state I think is a good idea as I
> said in the fsblock thread with Dave, but I haven't clicked as to why
> it is a big advantage to use it to manage pagecache state. (and I can
> see some possible disadvantages in locking and tree manipulation
> overhead).

Yes, there are definitely costs with the state tree, it will take some
careful benchmarking to convince me it is a feasible solution. But,
storing all the state in the pages themselves is impossible unless the
block size equals the page size. So, we end up with something like
fsblock/buffer heads or the state tree.

One advantage to the state tree is that it separates the state from
the memory being described, allowing a simple kmap style interface
that covers subpages, highmem and superpages.

It also more naturally matches the way we want to do IO, making for
easy clustering.

O_DIRECT becomes a special case of readpages and writepages....the
memory used for IO just comes from userland instead of the page cache.

The ability to put in additional tracking info like the process that
first dirtied a range is also significant.  So, I think it is worth
trying.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
