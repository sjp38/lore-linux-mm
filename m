Date: Thu, 25 May 2000 10:53:04 -0700 (PDT)
From: Matthew Dillon <dillon@apollo.backplane.com>
Message-Id: <200005251753.KAA83360@apollo.backplane.com>
Subject: Re: [RFC] 2.3/4 VM queues idea
References: <Pine.LNX.4.21.0005251405160.32434-100000@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Jamie Lokier <lk@tantalophile.demon.co.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

    Another big difference is that when you scan by physical page, you
    can collect a whole lot of information together to help you make
    the decision on how the adjust the weight.

    When you scan by physical page, then locate the VM mappings for that
    page, you have:

	* a count of the number of mappings
	* a count of how many of those referenced the page since the
	  last check.
	* more determinism (see below)

    When you scan by virtual page, then locate the physical mapping:

	* you cannot tell how many other virtual mappings referenced the
	  page (short of checking, at which point you might as well be
	  scanning by physical page)

	* you have no way of figuring out how many discrete physical pages
	  your virtual page scan has covered.  For all you know you could
	  scan 500 virtual mappings and still only have gotten through a
	  handful of physical pages.  Big problem!

	* you have much less information available to make the decision on
	  how to adjust the weight.

:> How so?  You're only scanning currently mapped ptes, and one
:> goal is to keep that number small enough that you can gather
:> good LRU stats of page usage.
:
:Page aging may well be cheaper than continuously unmapping ptes
:(including tlb flushes and cache flushes of the page tables) and
:softfaulting them back in.

    It's definitely cheaper.  If you unmap a page and then have to
    take a page fault to get it back, the cost is going to be
    roughly 300 instructions plus other overhead.

    Another example of why physical page scanning is better then
    virtual page scanning:  When there is memory pressure and you are
    scanning by physical page, and the weight reaches 0, you can then
    turn around and unmap ALL of its virtual pte's all at once (or mark
    them read-only for a dirty page to allow it to be flushed).  Sure
    you have to eat cpu to find those virtual pte's, but the end result
    is a page which is now cleanable or freeable.

    Now try this with a virtual scan:  You do a virtual scan, locate
    a page you decide is idle, and then... what?  Unmap just that one
    instance of the pte?  What about the others?  You would have to unmap
    them too, which would cost as much as it would when doing a physical
    page scan *EXCEPT* that you are running through a whole lot more virtual
    pages during the virtual page scan to get the same effect as with
    the physical page scan (when trying to locate idle pages).  It's
    the difference between O(N) and O(N^2).  If the physical page queues
    are reasonably well ordered, its the difference between O(1) and O(N^2).

					-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
