Date: Thu, 31 Jul 2008 18:21:11 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [patch v3] splice: fix race with page invalidation
Message-ID: <20080731172111.GA23644@shareable.org>
References: <E1KOIYA-0002FG-Rg@pomaz-ex.szeredi.hu> <20080731001131.GA30900@shareable.org> <20080731004214.GA32207@shareable.org> <alpine.LFD.1.10.0807301746500.3277@nehalem.linux-foundation.org> <20080731061201.GA7156@shareable.org> <alpine.LFD.1.10.0807310925360.3277@nehalem.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0807310925360.3277@nehalem.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, jens.axboe@oracle.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> >			, or (b) while sendfile claims those
> > pages, they are marked COW.
> 
> .. and this one shows that you have no clue about performance of a memcpy.
> 
> Once you do that COW, you're actually MUCH BETTER OFF just copying.
> Copying a page is much cheaper than doing COW on it.

That sounds familiar :-)

But did you miss the bit where you DON'T COPY ANYTHING EVER*?  COW is
able provide _correctness_ for the rare corner cases which you're not
optimising for.  You don't actually copy more than 0.0% (*approx).

Copying is supposed to be _so_ rare, in this, that it doesn't count.

Correctness is so you can say "I've written that, when the syscall
returns I know what data the other end will receive, if it succeeds".
Knowing what can happen in what order is bread and butter around here,
you know how useful that can.

The cost of COW is TLB flushes*.  But for splice, there ARE NO TLB
FLUSHES because such files are not mapped writable!  And you don't
intend to write the file soon either.  A program would be daft to use
splice _intending_ to do those things, it obviously would be poor use
of the interface.  The kernel may as well copy the data if they did
(and it's in a good position to decide).

> Doing a "write()" really isn't that expensive. People think that
> memory is slow, but memory isn't all that slow, and caches work
> really well. Yes, memory is slow compared to a few reference count
> increments, but memory is absolutely *not* slow when compared to the
> overhead of TLB invalidates across CPUs etc.

You're missing the real point of network splice().

It's not just for speed.

It's for sharing data.  Your TCP buffers can share data, when the same
big lump is in flight to lots of clients.  Think static file / web /
FTP server, the kind with 80% of hits to 0.01% of the files roughly
the same of your RAM.

You want network splice() for the same reason you want shared
libraries.  So that memory use scales better with some loads**.

You don't know how much good that will do, only, like shared
libraries, that it's intrinsically good if it doesn't cost anything.
And I'm suggesting that since no TLB flushes or COW copies are
expected, and you can just copy at sendfile time if the page is
already write-mapped anywhere, so the page references aren't
complicated, it shouldn't cost anything.

** - Admittedly this is rather load dependent.  But it's potentially
O(c*d) for write vs. O(d) for sendfile, hand-wavingly, where c is the
number of connections using d data.  (Then again, as I work out the
figures, RAM is getting cheaper faster than bandwidth-latency products
are getting bigger...  It's not a motivator except for cheapskates.
But doesn't detract from intrinsic goodness.)

-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
