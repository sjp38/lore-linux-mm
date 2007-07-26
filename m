Date: Wed, 25 Jul 2007 22:10:07 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH RFC] extent mapped page cache
Message-ID: <20070725221007.0edcc2dc@think.oraclecorp.com>
In-Reply-To: <20070726013728.GB20727@wotan.suse.de>
References: <20070710210326.GA29963@think.oraclecorp.com>
	<20070724160032.7a7097db@think.oraclecorp.com>
	<1185307985.6586.50.camel@localhost>
	<1185312343.5535.5.camel@lappy>
	<20070724192509.5bc9b3fe@think.oraclecorp.com>
	<20070725023217.GA32076@wotan.suse.de>
	<20070725081853.4b325e7f@think.oraclecorp.com>
	<20070726013728.GB20727@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Jul 2007 03:37:28 +0200
Nick Piggin <npiggin@suse.de> wrote:

>  
> > One advantage to the state tree is that it separates the state from
> > the memory being described, allowing a simple kmap style interface
> > that covers subpages, highmem and superpages.
> 
> I suppose so, although we should have added those interfaces long
> ago ;) The variants in fsblock are pretty good, and you could always
> do an arbitrary extent (rather than block) based API using the
> pagecache tree if it would be helpful.

Yes, you could use fsblock for the state bits and make a separate API
to map the actual pages.

>  
> 
> > It also more naturally matches the way we want to do IO, making for
> > easy clustering.
> 
> Well the pagecache tree is used to reasonable effect for that now.
> OK the code isn't beautiful ;). Granted, this might be an area where
> the seperate state tree ends up being better. We'll see.
> 

One thing it gains us is finding the start of the cluster.  Even if
called by kswapd, the state tree allows writepage to find the start of
the cluster and send down a big bio (provided I implement trylock to
avoid various deadlocks).

>  
> > O_DIRECT becomes a special case of readpages and writepages....the
> > memory used for IO just comes from userland instead of the page
> > cache.
> 
> Could be, although you'll probably also need to teach the mm about
> the state tree and/or still manipulate the pagecache tree to prevent
> concurrency?

Well, it isn't coded yet, but I should be able to do it from the FS
specific ops.

> 
> But isn't the main aim of O_DIRECT to do as little locking and
> synchronisation with the pagecache as possible? I thought this is
> why your race fixing patches got put on the back burner (although
> they did look fairly nice from a correctness POV).

I put the placeholder patches on hold because handling a corner case
where userland did O_DIRECT from a mmap'd region of the same file (Linus
pointed it out to me).  Basically my patches had to work in 64k chunks
to avoid a deadlock in get_user_pages.  With the state tree, I can
allow the page to be faulted in but still properly deal with it.

> 
> Well I'm kind of handwaving when it comes to O_DIRECT ;) It does look
> like this might be another advantage of the state tree (although you
> aren't allowed to slow down buffered IO to achieve the locking ;)).

;) The O_DIRECT benefit is a fringe thing.  I've long wanted to help
clean up that code, but the real point of the patch is to make general
usage faster and less complex.  If I can't get there, the O_DIRECT
stuff doesn't matter.
> 
>  
> > The ability to put in additional tracking info like the process that
> > first dirtied a range is also significant.  So, I think it is worth
> > trying.
> 
> Definitely, and I'm glad you are. You haven't converted me yet, but
> I look forward to finding the best ideas from our two approaches when
> the patches are further along (ext2 port of fsblock coming along, so
> we'll be able to have races soon :P).

I'm sure we can find some river in Cambridge, winner gets to throw
Axboe in.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
