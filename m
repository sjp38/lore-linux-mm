Message-ID: <3D7929F7.7B19C9C@zip.com.au>
Date: Fri, 06 Sep 2002 15:19:35 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: inactive_dirty list
References: <3D79250B.6D705166@zip.com.au> <Pine.LNX.4.44L.0209061902120.1857-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Fri, 6 Sep 2002, Andrew Morton wrote:
> 
> > hum.  I'm trying to find a model where the VM can just ignore
> > dirty|writeback pagecache.  We know how many pages are out
> > there, sure.  But we don't scan them.  Possible?
> 
> Owww duh, I see it now.
> 
> So basically pages should _only_ go into the inactive_dirty list
> when they are under writeout.

Or if they're just dirty.  The thing I'm trying to achieve
is to minimise the amount of scanning of unreclaimable pages.

So park them elsewhere, and don't scan them.  We know how many
pages are there, so we can make decisions based on that.  But let
IO completion bring them back onto the inactive_reclaimable(?)
list.

> Note that leaving dirty pages on the list can result in a waste
> of memory. Imagine the dirty limit being 40% and 30% of memory
> being dirty but not written out at the moment ...

Right.  So the VM needs to kick pdflush at the right time to 
get that happening.  The nonblocking pdflush is very effective - I
think it can keep a ton of queues saturated with just a single process.

swapcache is a wart, because pdflush doesn't write swapcache.
It certainly _could_, but you had reasons why that was the 
wrong thing to do?

And something needs to be done with clean but unreclaimable
pages.  These will be on inactive_clean - I guess we just
continue to activate these.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
