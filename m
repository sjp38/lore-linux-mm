Date: Tue, 24 Jul 2007 19:25:09 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH RFC] extent mapped page cache
Message-ID: <20070724192509.5bc9b3fe@think.oraclecorp.com>
In-Reply-To: <1185312343.5535.5.camel@lappy>
References: <20070710210326.GA29963@think.oraclecorp.com>
	<20070724160032.7a7097db@think.oraclecorp.com>
	<1185307985.6586.50.camel@localhost>
	<1185312343.5535.5.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 24 Jul 2007 23:25:43 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> On Tue, 2007-07-24 at 16:13 -0400, Trond Myklebust wrote:
> > On Tue, 2007-07-24 at 16:00 -0400, Chris Mason wrote:
> > > On Tue, 10 Jul 2007 17:03:26 -0400
> > > Chris Mason <chris.mason@oracle.com> wrote:
> > > 
> > > > This patch aims to demonstrate one way to replace buffer heads
> > > > with a few extent trees.  Buffer heads provide a few different
> > > > features:
> > > > 
> > > > 1) Mapping of logical file offset to blocks on disk
> > > > 2) Recording state (dirty, locked etc)
> > > > 3) Providing a mechanism to access sub-page sized blocks.
> > > > 
> > > > This patch covers #1 and #2, I'll start on #3 a little later
> > > > next week.
> > > > 
> > > Well, almost.  I decided to try out an rbtree instead of the
> > > radix, which turned out to be much faster.  Even though
> > > individual operations are slower, the rbtree was able to do many
> > > fewer ops to accomplish the same thing, especially for merging
> > > extents together.  It also uses much less ram.
> > 
> > The problem with an rbtree is that you can't use it together with
> > RCU to do lockless lookups. You can probably modify it to allocate
> > nodes dynamically (like the radix tree does) and thus make it
> > RCU-compatible, but then you risk losing the two main benefits that
> > you list above.

The tree is a critical part of the patch, but it is also the easiest to
rip out and replace.  Basically the code stores a range by inserting
an object at an index corresponding to the end of the range.

Then it does searches by looking forward from the start of the range.
More or less any tree that can search and return the first key >=
than the requested key will work.

So, I'd be happy to rip out the tree and replace with something else.
Going completely lockless will be tricky, its something that will deep
thought once the rest of the interface is sane.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
