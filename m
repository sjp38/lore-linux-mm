Date: Thu, 26 Jul 2007 03:37:28 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH RFC] extent mapped page cache
Message-ID: <20070726013728.GB20727@wotan.suse.de>
References: <20070710210326.GA29963@think.oraclecorp.com> <20070724160032.7a7097db@think.oraclecorp.com> <1185307985.6586.50.camel@localhost> <1185312343.5535.5.camel@lappy> <20070724192509.5bc9b3fe@think.oraclecorp.com> <20070725023217.GA32076@wotan.suse.de> <20070725081853.4b325e7f@think.oraclecorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070725081853.4b325e7f@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 25, 2007 at 08:18:53AM -0400, Chris Mason wrote:
> On Wed, 25 Jul 2007 04:32:17 +0200
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > Having another tree to store block state I think is a good idea as I
> > said in the fsblock thread with Dave, but I haven't clicked as to why
> > it is a big advantage to use it to manage pagecache state. (and I can
> > see some possible disadvantages in locking and tree manipulation
> > overhead).
> 
> Yes, there are definitely costs with the state tree, it will take some
> careful benchmarking to convince me it is a feasible solution. But,
> storing all the state in the pages themselves is impossible unless the
> block size equals the page size. So, we end up with something like
> fsblock/buffer heads or the state tree.

Yep, we have to have something.

 
> One advantage to the state tree is that it separates the state from
> the memory being described, allowing a simple kmap style interface
> that covers subpages, highmem and superpages.

I suppose so, although we should have added those interfaces long
ago ;) The variants in fsblock are pretty good, and you could always
do an arbitrary extent (rather than block) based API using the
pagecache tree if it would be helpful.
 

> It also more naturally matches the way we want to do IO, making for
> easy clustering.

Well the pagecache tree is used to reasonable effect for that now.
OK the code isn't beautiful ;). Granted, this might be an area where
the seperate state tree ends up being better. We'll see.

 
> O_DIRECT becomes a special case of readpages and writepages....the
> memory used for IO just comes from userland instead of the page cache.

Could be, although you'll probably also need to teach the mm about
the state tree and/or still manipulate the pagecache tree to prevent
concurrency?

But isn't the main aim of O_DIRECT to do as little locking and
synchronisation with the pagecache as possible? I thought this is
why your race fixing patches got put on the back burner (although
they did look fairly nice from a correctness POV).

Well I'm kind of handwaving when it comes to O_DIRECT ;) It does look
like this might be another advantage of the state tree (although you
aren't allowed to slow down buffered IO to achieve the locking ;)).

 
> The ability to put in additional tracking info like the process that
> first dirtied a range is also significant.  So, I think it is worth
> trying.

Definitely, and I'm glad you are. You haven't converted me yet, but
I look forward to finding the best ideas from our two approaches when
the patches are further along (ext2 port of fsblock coming along, so
we'll be able to have races soon :P).

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
