Date: Mon, 1 May 2000 21:07:35 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
In-Reply-To: <200005012333.QAA31200@pizda.ninka.net>
Message-ID: <Pine.LNX.4.21.0005012059270.7508-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: roger.larsson@norran.net, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 May 2000, David S. Miller wrote:
>    Date: 	Mon, 1 May 2000 20:23:43 -0300 (BRST)
>    From: Rik van Riel <riel@conectiva.com.br>
> 
>    We can simply "move" the list_head when we're done scanning and
>    continue from where we left off last time. That way we'll be much
>    less cpu intensive and scan all pages fairly.
> 
>    Using not one but 2 or 3 bits for aging the pages can result in
>    something closer to lru and cheaper than the scheme we have now.
> 
>    What do you (and others) think about this idea?
> 
> Why not have two lists, an active and an inactive list.  As reference
> bits clear, pages move to the inactive list.  If a reference bit stays
> clear up until when the page moves up to the head of the inactive
> list, we then try to free it.  For the active list, you do the "move
> the list head" technique.

Sounds like a winning idea. Well, we also want to keep mapped pages
on the active list...

> And you define some heuristics to decide how populated you wish to
> try to keep the inactive list.

We can aim/tune the inactive list size for 25% reclaims by the
original applications and 75% page stealing for "use" by the
free list. If we have far too much reclaims we can shrink the
list, if we have to little reclaims we can grow the inactive
list (and scan the active list more agressively).

This should also "catch" IO intensive applications, by moving
a lot of stuff to the inactive list quickly.

> Next, during periods of inactivity you have kswapd or some other
> daemon periodically (once every 5 seconds, something like this)
> perform an inactive list population run.

*nod*

We should scan the inactive list and move all reactivated pages
back to the active list and then repopulate the inactive list.
Alternatively, all "reactivation" actions (mapping a page back
into the application, __find_page_nolock(), etc...) should put
pages back onto the active queue.

(and repopulate the active queue whenever we go below the low
watermark, which is a fraction of the dynamically tuned high
watermark)

> The inactive lru population can be done cheaply, using the above
> ideas, roughly like:
> 
> 	LIST_HEAD(inactive_queue);
> 	struct list_head * active_scan_point = &lru_active;
> 
> 	for_each_active_lru_page() {
> 		if (!test_and_clear_referenced(page)) {

I'd like to add the "if (!page->buffers && atomic_read(&page->count) > 1)"
test to this, since there is no way to free those pages and they may
well have "hidden" referenced bits in their page table entries...

> 			list_del(entry);
> 			list_add(entry, &inactive_queue);
> 		} else
> 			active_scan_point = entry;
> 	}
> 
> 	list_splice(&inactive_queue, &lru_inactive);
> 	list_head_move(&lru_active, active_scan_point);
> 
> This way you only do list manipulations for actual work done
> (ie. moving inactive page candidates to the inactive list).
>
> I may try to toss together and example implementation, but feel
> free to beat me to it :-)

If you have the time to spare, feel free to go ahead, but since
I'm working on this stuff full-time now I see no real reason you
should waste^Wspend your time on this ... there must be something
to do in the network layer or another more critical/subtle place
of the kernel.

cheers,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
