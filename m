Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA11596
	for <linux-mm@kvack.org>; Tue, 26 Jan 1999 09:01:32 -0500
Date: Tue, 26 Jan 1999 13:23:33 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.95.990125125512.411B-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.03.9901261314450.26867-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Dr. Werner Fink" <werner@suse.de>, Andrea Arcangeli <andrea@e-mind.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Jan 1999, Linus Torvalds wrote:
> On Mon, 25 Jan 1999, Dr. Werner Fink wrote:
> > 
> > This hypothetical bit should only be set if the page is read physical
> > from the swap device/file.  That means it would take one step more
> > to swap out this page again (test_and_clear_bit of both 
> > PG_recently_swapped_in and PG_referenced).
> 
> Ehh - it is already marked "accessed" in the page tables, which
> essentially amounts to exactly that kind of two-level aging (the
> PG_referenced bit only takes effect once the swapped-in page has
> once more been evicted from the page tables)

With a bit of imagination, you might even be able to
call our current scheme two-handed...

Even though it's a bit different, it seems like we
have all advantages and none of the disadvantages of
a two-handed system. The main difference is that we
do I/O on the first hand and page eviction on the
second. This gives us a buffer of ready-to-evict
pages which we can easily free when we're in a hurry.

The only thing we really need now is a way to keep
track of (and manage) that buffer of freeable pages.
I believe Andrea has a patch for that -- we should
check it out and incorporate something like that ASAP.

There are several reasons why we need it:
- we should never run out of freeable pages
  because that can introduce too much latency
  and possibly even system instability
- page aging only is effective/optimal when the
  freeable buffer is large enough
- when the freeable buffer is too large, we might
  have too many soft pagefaults or other overhead
  (not very much of a concern, but still...)
- keeping a more or less fixed distance between
  both hands could make the I/O less bursty and
  improve system I/O performance

Rik -- If a Microsoft product fails, who do you sue?
+-------------------------------------------------------------------+
| Linux memory management tour guide.             riel@nl.linux.org |
| Scouting Vries cubscout leader.     http://www.nl.linux.org/~riel |
+-------------------------------------------------------------------+

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
