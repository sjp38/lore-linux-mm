Date: Mon, 1 May 2000 16:33:45 -0700
Message-Id: <200005012333.QAA31200@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <Pine.LNX.4.21.0005012017300.7508-100000@duckman.conectiva>
	(message from Rik van Riel on Mon, 1 May 2000 20:23:43 -0300 (BRST))
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
References: <Pine.LNX.4.21.0005012017300.7508-100000@duckman.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: roger.larsson@norran.net, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   We can simply "move" the list_head when we're done scanning and
   continue from where we left off last time. That way we'll be much
   less cpu intensive and scan all pages fairly.

   Using not one but 2 or 3 bits for aging the pages can result in
   something closer to lru and cheaper than the scheme we have now.

   What do you (and others) think about this idea?

Why not have two lists, an active and an inactive list.  As reference
bits clear, pages move to the inactive list.  If a reference bit stays
clear up until when the page moves up to the head of the inactive
list, we then try to free it.  For the active list, you do the "move
the list head" technique.

So you have two passes, one populates the inactive list, the next
inspects the inactive list for pages to free up.  The toplevel
shrink_mmap scheme can look something like:

	free_unreferenced_pages_in_inactive_list();
	repopulate_inactive_list();

And you define some heuristics to decide how populated you wish to
try to keep the inactive list.

Next, during periods of inactivity you have kswapd or some other
daemon periodically (once every 5 seconds, something like this)
perform an inactive list population run.

The inactive lru population can be done cheaply, using the above
ideas, roughly like:

	LIST_HEAD(inactive_queue);
	struct list_head * active_scan_point = &lru_active;

	for_each_active_lru_page() {
		if (!test_and_clear_referenced(page)) {
			list_del(entry);
			list_add(entry, &inactive_queue);
		} else
			active_scan_point = entry;
	}

	list_splice(&inactive_queue, &lru_inactive);
	list_head_move(&lru_active, active_scan_point);

This way you only do list manipulations for actual work done
(ie. moving inactive page candidates to the inactive list).

I may try to toss together and example implementation, but feel
free to beat me to it :-)

Later,
David S. Miller
davem@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
