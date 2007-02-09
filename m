Date: Thu, 8 Feb 2007 16:39:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Drop PageReclaim()
Message-Id: <20070208163953.ab2bd694.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0702081613300.15669@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702070612010.14171@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0702071428590.30412@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0702081319530.12048@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0702081331290.12167@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0702081340380.13255@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0702081351270.14036@schroedinger.engr.sgi.com>
	<20070208140338.971b3f53.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702081411030.14424@schroedinger.engr.sgi.com>
	<20070208142431.eb81ae70.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702081425000.14424@schroedinger.engr.sgi.com>
	<20070208143746.79c000f5.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702081438510.15063@schroedinger.engr.sgi.com>
	<20070208151341.7e27ca59.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702081613300.15669@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Feb 2007 16:22:17 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 8 Feb 2007, Andrew Morton wrote:
> 
> > I expect that'll be OK for pages which were written back by the vm scanner.
> >  But it also means that pages which were written back by
> > pdflush/balance_dirty_pages/fsync/etc will now all also be eligible for
> > rotation.  ie: the vast majority of written-back pages.
> > 
> > Whether that will make much difference to page aging I don't know.  But it
> > will cause more lru->lock traffic.
> 
> I'd rather avoid more lru lock traffic. Could we simply drop the rotation?

I doubt it.  One would need to troll five-year-old changelogs and mailing
list discussion, but iirc that rotation was a large win in certain
workloads, preventing scanning meltdowns and general memory stress.

It's probably more useful than tracking mlocked pages, put it that way.

> Writeback is typically a relatively long process. The page should 
> have made some progress through the inactive list by the time the 
> write is complete.

huuuuuuge amounts of testing went into this stuff, on a large number of
machine configurations and workloads.  Plus a few tens of millions of
machine-years in the field.

Possibly we could do it, but it'd be a ton of work in validating the
change.

> One additional issue that is raised by the writeback pages remaining on 
> the LRU lists is that we can get into the same livelock situation as with 
> mlocked pages if we keep on skipping over writeback pages.

That's why we rotate the reclaimable pages back to the head-of-queue.

The vm scanner will throttle twelve times before it fully traverses the
inactive list.  And the extent of that throttling is dependent upon completion of
writeback.  We expect that after a throttled reclaimer has been woken, the
waker has dumped a pile of immediately-reclaimable pages at the tail of
the LRU.

> However, the 
> system is already slow due to us waiting for I/O. I guess we just do not 
> notice.

Well.  IO.  People still seem to thing that vmscan.c is about page
replacement.  It ain't.  Most of the problems in there and most of the work
which has gone into it are IO-related.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
