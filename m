Message-ID: <3D766999.A9C14E1E@zip.com.au>
Date: Wed, 04 Sep 2002 13:14:17 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: nonblocking-vm.patch
References: <3D76549B.3C53D0AC@zip.com.au> <Pine.LNX.4.44L.0209041640171.1857-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Wed, 4 Sep 2002, Andrew Morton wrote:
> 
> > We do need something in there to prevent kswapd from going berzerk.
> 
> Agreed, but it can be a lot simpler than your idea.
> 
> As long as we can free up to zone->pages_high pages,
> we don't need to throttle since we're succeeding in
> keeping enough pages free to not be woken up for a
> while.

OK, so after we've taken a scan through shrink_caches,
if we didn't reclaim the required pages then take a
nap.

Suspect that would work.  I get a bit upset over scanning non-reclaimable
pages (they shouldn't have been on that list!) But instrumentation
indicates that perhaps I'm being silly ;)

> If we don't succeed in freeing enough pages, that is
> because the pages are still under IO and haven't hit
> the disk yet.  In this case, we need to wait for the
> IO to finish, or at least for some of the pages to
> get cleaned.  We can do this by simply refusing to
> scan that zone again for a number of jiffies, say
> 1/4 of a second.

Well, it may be better to terminate that sleep earlier if IO
completes.  We can do that in end_page_writeback or in
blk_congestion_wait().   The latter takes a timeout, and
wakes you up earlier if _any_ queue exits congestion, or
if any queue puts back a request against an uncongested queue.

Which is, I think, precisely what we want - a request typically
covers a whole bunch of pages.  If the dirty memory is backed
by an non-request-oriented device (are there any such?  NFS seems
to be synchronous a lot of the time) then you'll hit the timeout.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
