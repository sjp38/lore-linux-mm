Date: Sun, 28 Jan 2007 16:17:00 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] mm: remove global locks from mm/highmem.c
Message-ID: <20070128151700.GA7644@elte.hu>
References: <1169993494.10987.23.camel@lappy> <20070128144933.GD16552@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070128144933.GD16552@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

* Christoph Hellwig <hch@infradead.org> wrote:

> On Sun, Jan 28, 2007 at 03:11:34PM +0100, Peter Zijlstra wrote:
> > Eradicate global locks.
> > 
> >  - kmap_lock is removed by extensive use of atomic_t, a new flush
> >    scheme and modifying set_page_address to only allow NULL<->virt
> >    transitions.
> 
> What's the point for this? [...]

scalability. I did lock profiling on the -rt kernel, which exposes such 
things nicely. Half of the lock contention events during kernel compile 
were due to kmap(). (The system had 2 GB of RAM, so 40% lowmem, 60% 
highmem.)

> [...] In doubt we just need to convert that caller to kmap_atomic.

the pagecache ones cannot be converted to kmap_atomic, because we can 
block while holding them. Plus kmap_atomic is quite a bit slower than 
this scalable version of kmap().

	Ingo

ps. please fix your mailer to not emit Mail-Followup-To headers. In Mutt
    you can do this via "set followup_to=no" in your .muttrc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
