Date: Tue, 17 Apr 2007 05:07:55 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] rename page_count for lockless pagecache
Message-ID: <20070417030755.GA25513@wotan.suse.de>
References: <20070412103151.5564.16127.sendpatchset@linux.site> <20070412103340.5564.23286.sendpatchset@linux.site> <Pine.LNX.4.64.0704131229510.19073@blonde.wat.veritas.com> <20070413121347.GC966@wotan.suse.de> <20070414022407.GC14544@wotan.suse.de> <Pine.LNX.4.64.0704161913230.10887@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704161913230.10887@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 16, 2007 at 07:28:33PM +0100, Hugh Dickins wrote:
> On Sat, 14 Apr 2007, Nick Piggin wrote:
> > On Fri, Apr 13, 2007 at 02:13:47PM +0200, Nick Piggin wrote:
> > > On Fri, Apr 13, 2007 at 12:53:05PM +0100, Hugh Dickins wrote:
> > > > Might it be more profitable for a DEBUG mode to inject random
> > > > variations into page_count?
> > > 
> > > I think that's a very fine idea, and much more suitable for an
> > > everyday kernel than my test threads. Doesn't help if they use the
> > > field somehow without the accessors, but we must discourage that.
> > > Thanks, I'll add such a debug mode.
> > 
> > Something like this boots and survives some stress testing here.
> > 
> > I guess it should be under something other than CONFIG_DEBUG_VM,
> > because it could harm performance and scalability significantly on
> > bigger boxes... or maybe it should use per-cpu counters? ;)
> > 
> > --
> > Add some debugging for lockless pagecache as suggested by Hugh.
> > 
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> Hmm, maybe.  Would be rather cleaner if in this case page_count()
> were not inlined but EXPORTed, with the ll_count static within it.
> 
> But I'm not terribly proud of the idea, and wonder whether we just
> forget it?  How are we going to recognize it if this (or your
> lpctest) ever does cause a problem?  Seems like a good thing for
> you or I to try when developing, but whether it should go on into
> the tree I'm less sure.

Yeah, good question. I guess we could hope that if it is used in
drivers or things for something other than page refcounting, they
might stop working in short order.

Otherwise maybe we'd get page leaks... I think this is going to cause
some swapcache pages to "leak" more than usual, but of course they
should end up getting cleaned off the LRU. I guess anything more
obscure (eg. leaks in some driver private pages) might not actually
be noticable unless it was running for a long time. So that's a bit
sad for a debugging option. But it could be useful to catch an out of
tree driver using page_count privately...

I wonder if we could do sweeps over pages that are not free in the
allocator, and BUG if any of them have a zero page count? Hmm, no I
don't know if that can really happen unless someone is abusing
init_page_count.

I don't know whether it should go into the tree. I think I'd like to
put it in -mm and turn it on for a few releases though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
