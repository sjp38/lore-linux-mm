Message-ID: <3D2DF5CB.471024F9@zip.com.au>
Date: Thu, 11 Jul 2002 14:16:59 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] Optimize out pte_chain take three
References: <3D2DEDAD.A38AFF25@zip.com.au> <Pine.LNX.4.44L.0207111750050.14432-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Thu, 11 Jul 2002, Andrew Morton wrote:
> > Rik van Riel wrote:
> > > ...
> > > > useful pagecache and swapping everything out.  Our kernels have
> > > > O_STREAMING because of this.   It simply removes as much pagecache
> > > > as it can, each time ->nrpages reaches 256.  It's rather effective.
> > >
> > > Now why does that remind me of drop-behind ? ;)
> >
> > I looked at 2.4-ac as well.  Seems that the dropbehind there only
> > addresses reads?
> 
> It should also work on linear writes.

The only call site for drop_behind() in -ac is generic_file_readahead().

> > I suspect the best fix here is to not have dirty or writeback
> > pagecache pages on the LRU at all.  Throttle on memory coming
> > reclaimable, put the pages back on the LRU when they're clean,
> > etc.  As we have often discussed.  Big change.
> 
> That just doesn't make sense, if you don't put the dirty pages
> on the LRU then what incentive _do_ you have to write them out ?

We have dirty page accounting.  If the page reclaim code decides
there's too much dirty memory then kick pdflush, and sleep on
IO completion's movement of reclaimable pages back onto the LRU.

Making page reclaimers perform writeback in shrink_cache()
just has awful latency problems.  If we don't do that then
there's just no point in keeping those pages on the LRU
because all we do is scan past them and blow cycles.

> ...
> If the throttling is wrong, I propose we fix the trottling.

How?  (Without adding more list scanning)

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
