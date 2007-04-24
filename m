Subject: Re: [PATCH 10/10] mm: per device dirty threshold
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1HgGF4-00008p-00@dorka.pomaz.szeredi.hu>
References: <20070420155154.898600123@chello.nl>
	 <20070420155503.608300342@chello.nl>
	 <17965.29252.950216.971096@notabene.brown>
	 <1177398589.26937.40.camel@twins>
	 <E1HgGF4-00008p-00@dorka.pomaz.szeredi.hu>
Content-Type: text/plain
Date: Tue, 24 Apr 2007 10:31:33 +0200
Message-Id: <1177403494.26937.59.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: neilb@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, 2007-04-24 at 10:19 +0200, Miklos Szeredi wrote:
> > > This is probably a
> > >  reasonable thing to do but it doesn't feel like the right place.  I
> > >  think get_dirty_limits should return the raw threshold, and
> > >  balance_dirty_pages should do both tests - the bdi-local test and the
> > >  system-wide test.
> > 
> > Ok, that makes sense I guess.
> 
> Well, my narrow minded world view says it's not such a good idea,
> because it would again introduce the deadlock scenario, we're trying
> to avoid.

I was only referring to the placement of the clipping; and exactly where
that happens does not affect the deadlock.

> In a sense allowing a queue to go over the global limit just a little
> bit is a good thing.  Actually the very original code does that: if
> writeback was started for "write_chunk" number of pages, then we allow
> "ratelimit" (8) _new_ pages to be dirtied, effectively ignoring the
> global limit.

It might be time to get rid of that rate-limiting.
balance_dirty_pages()'s fast path is not nearly as heavy as it used to
be. All these fancy counter systems have removed quite a bit of
iteration from there.

> That's why I've been saying, that the current code is so unfair: if
> there are lots of dirty pages to be written back to a particular
> device, then balance_dirty_pages() allows the dirty producer to make
> even more pages dirty, but if there are _no_ dirty pages for a device,
> and we are over the limit, then that dirty producer is allowed
> absolutely no new dirty pages until the global counts subside.

Well, that got fixed on a per device basis with this patch, it is still
true for multiple tasks writing to the same device.

> I'm still not quite sure what purpose the above "soft" limiting
> serves.  It seems to just give advantage to writers, which managed to
> accumulate lots of dirty pages, and then can convert that into even
> more dirtyings.

The queues only limit the actual in-flight writeback pages,
balance_dirty_pages() considers all pages that might become writeback as
well as those that are.

> Would it make sense to remove this behavior, and ensure that
> balance_dirty_pages() doesn't return until the per-queue limits have
> been complied with?

I don't think that will help, balance_dirty_pages drives the queues.
That is, it converts pages from mere dirty to writeback.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
