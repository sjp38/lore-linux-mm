Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
From: michael@dgmo.org
References: <Pine.LNX.4.21.0005012059270.7508-100000@duckman.conectiva>
Date: 02 May 2000 17:56:11 +1000
In-Reply-To: Rik van Riel's message of "Mon, 1 May 2000 21:07:35 -0300 (BRST)"
Message-ID: <m1hfchcrms.fsf@mo.optusnet.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: "David S. Miller" <davem@redhat.com>, roger.larsson@norran.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:
> On Mon, 1 May 2000, David S. Miller wrote:
> > Why not have two lists, an active and an inactive list.  As reference
> > bits clear, pages move to the inactive list.  If a reference bit stays
> > clear up until when the page moves up to the head of the inactive
> > list, we then try to free it.  For the active list, you do the "move
> > the list head" technique.
[...]
> We should scan the inactive list and move all reactivated pages
> back to the active list and then repopulate the inactive list.
> Alternatively, all "reactivation" actions (mapping a page back
> into the application, __find_page_nolock(), etc...) should put
> pages back onto the active queue.
[..]

> > The inactive lru population can be done cheaply, using the above
> > ideas, roughly like:
> > 
> > 	LIST_HEAD(inactive_queue);
> > 	struct list_head * active_scan_point = &lru_active;
> > 
> > 	for_each_active_lru_page() {
> > 		if (!test_and_clear_referenced(page)) {

Tiny comment: You'd probably be better off waking up
more frequently, and just processing just a bit of the active
page queue.

I.e. Every 1/10th of a second, walk 2% of the active queue.
This would give you something closer to LRU, and smooth the
load, yes?

Or, I guess that could be ; every 1/10th of a second,
walk as much of the active queue as is needed to refill the
inactive list, starting from where you left of last time.
So if nothing is consuming out of the inactive queue, we
effectively stop walking. (This is basically pure clock).

Michael.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
