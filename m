Date: Thu, 11 Jul 2002 18:41:27 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Optimize out pte_chain take three
In-Reply-To: <3D2DF5CB.471024F9@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207111837060.14432-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 11 Jul 2002, Andrew Morton wrote:
> Rik van Riel wrote:

> > > I looked at 2.4-ac as well.  Seems that the dropbehind there only
> > > addresses reads?
> >
> > It should also work on linear writes.
>
> The only call site for drop_behind() in -ac is generic_file_readahead().

generic_file_write() calls deactivate_page() if it crosses
the page boundary (ie. if it is done writing this page)

> > > I suspect the best fix here is to not have dirty or writeback
> > > pagecache pages on the LRU at all.  Throttle on memory coming
> > > reclaimable, put the pages back on the LRU when they're clean,
> > > etc.  As we have often discussed.  Big change.
> >
> > That just doesn't make sense, if you don't put the dirty pages
> > on the LRU then what incentive _do_ you have to write them out ?
>
> We have dirty page accounting.  If the page reclaim code decides
> there's too much dirty memory then kick pdflush, and sleep on
> IO completion's movement of reclaimable pages back onto the LRU.

At what point in the LRU ?

Are you proposing to reclaim free pages before considering
dirty pages ?

> Making page reclaimers perform writeback in shrink_cache()
> just has awful latency problems.  If we don't do that then
> there's just no point in keeping those pages on the LRU
> because all we do is scan past them and blow cycles.

Why does it have latency problems ?

Keeping them on the LRU _does_ make sense since we know
when we want to evict these pages.  Putting them aside
on a laundry list might make sense though, provided that
they are immediately made a candidate for replacement
after IO completion.

> > ...
> > If the throttling is wrong, I propose we fix the trottling.
>
> How?  (Without adding more list scanning)

For one, we shouldn't let every process go into
try_to_free_pages() and check for itself if the
pages really aren't freeable.

It is enough if one thread (kswapd) does this,
scanning more often won't change the status of
the pages.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
