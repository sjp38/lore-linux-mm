Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A23826B01F3
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 15:33:40 -0400 (EDT)
Date: Sun, 18 Apr 2010 12:31:09 -0400
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-Id: <20100418123109.0953b7a5.akpm@linux-foundation.org>
In-Reply-To: <20100418190526.GA1692@infradead.org>
References: <20100413202021.GZ13327@think>
	<20100414014041.GD2493@dastard>
	<20100414155233.D153.A69D9226@jp.fujitsu.com>
	<20100414072830.GK2493@dastard>
	<20100414085132.GJ25756@csn.ul.ie>
	<20100415013436.GO2493@dastard>
	<20100415102837.GB10966@csn.ul.ie>
	<20100416041412.GY2493@dastard>
	<20100416151403.GM19264@csn.ul.ie>
	<20100417203239.dda79e88.akpm@linux-foundation.org>
	<20100418190526.GA1692@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 18 Apr 2010 15:05:26 -0400 Christoph Hellwig <hch@infradead.org> wrote:

> On Sat, Apr 17, 2010 at 08:32:39PM -0400, Andrew Morton wrote:
> > The poor IO patterns thing is a regression.  Some time several years
> > ago (around 2.6.16, perhaps), page reclaim started to do a LOT more
> > dirty-page writeback than it used to.  AFAIK nobody attempted to work
> > out why, nor attempted to try to fix it.
> 
> I just know that we XFS guys have been complaining about it a lot..
> 
> But that was mostly a tuning issue - before writeout mostly happened
> from pdflush.  If we got into kswapd or direct reclaim we already
> did get horrible I/O patterns - it just happened far less often.

Right.  It's intended that the great majority of writeout be performed
by the fs flusher threads and by the write()r in balance_dirty_pages().
Writeout off the LRU is supposed to be a rare emergency case.

This got broken.

> > Regarding simply not doing any writeout in direct reclaim (Dave's
> > initial proposal): the problem is that pageout() will clean a page in
> > the target zone.  Normal writeout won't do that, so we could get into a
> > situation where vast amounts of writeout is happening, but none of it
> > is cleaning pages in the zone which we're trying to allocate from. 
> > It's quite possibly livelockable, too.
> 
> As Chris mentioned currently btrfs and ext4 do not actually do delalloc
> conversions from this path, so for typical workloads the amount of
> writeout that can happen from this path is extremly limited.  And unless
> we get things fixed we will have to do the same for XFS.  I'd be much
> more happy if we could just sort it out at the VM level, because this
> means we have one sane place for this kind of policy instead of three
> or more hacks down inside the filesystems.  It's rather interesting
> that all people on the modern fs side completely agree here what the
> problem is, but it seems rather hard to convince the VM side to do
> anything about it.
> 
> > To solve the stack-usage thing: dunno, really.  One could envisage code
> > which skips pageout() if we're using more than X amount of stack, but
> > that sucks.
> 
> And it doesn't solve other issues, like the whole lock taking problem.
> 
> > Another possibility might be to hand the target page over
> > to another thread (I suppose kswapd will do) and then synchronise with
> > that thread - get_page()+wait_on_page_locked() is one way.  The helper
> > thread could of course do writearound.
> 
> Allowing the flusher threads to do targeted writeout would be the
> best from the FS POV.  We'll still have one source of the I/O, just
> with another know on how to select the exact region to write out.
> We can still synchronously wait for the I/O for lumpy reclaim if really
> nessecary.

Yeah, but it's all bandaids.  The first thing we should do is work out
why writeout-off-the-LRU increased so much and fix that.

Handing writeout off to separate threads might be used to solve the
stack consumption problem but we shouldn't use it to "solve" the
excess-writeout-from-page-reclaim problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
