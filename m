Subject: Re: [DATAPOINT] pre7-6 will not swap
References: <Pine.LNX.4.10.10005061225460.1470-100000@penguin.transmeta.com>
From: "Quintela Carreira Juan J." <quintela@vexeta.dc.fi.udc.es>
In-Reply-To: Linus Torvalds's message of "Sat, 6 May 2000 12:35:00 -0700 (PDT)"
Date: 09 May 2000 03:52:46 +0200
Message-ID: <ytt66sov6a9.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, Andrea Arcangeli <andrea@suse.de>, Benjamin Redelings I <bredelin@ucla.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "linus" == Linus Torvalds <torvalds@transmeta.com> writes:


linus> in vmscan.c, and that seems to be quite well-behaved too (but if somebody
linus> has the energy to test the two different versions, I'd absolutely love to
linus> hear results..)

Hi Linus, 
   I have tested two versions of the patch (against vanilla
pre7-6), the first was to remove the test altogether (I think this is
from Rajagopal):

--- pre7-6/mm/vmscan.c	Fri May  5 23:58:56 2000
+++ testing/mm/vmscan.c	Mon May  8 23:30:52 2000
@@ -114,8 +114,9 @@
 	 * Don't do any of the expensive stuff if
 	 * we're not really interested in this zone.
 	 */
-	if (!page->zone->zone_wake_kswapd)
+/*	if (!page->zone->zone_wake_kswapd)
 		goto out_unlock;
+*/
 
 	/*
 	 * Ok, it's really dirty. That means that

Second one  is the Linus suggestion, change the test for:

diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7-6/mm/vmscan.c testing2/mm/vmscan.c
--- pre7-6/mm/vmscan.c	Fri May  5 23:58:56 2000
+++ testing2/mm/vmscan.c	Tue May  9 01:46:08 2000
@@ -114,7 +114,7 @@
 	 * Don't do any of the expensive stuff if
 	 * we're not really interested in this zone.
 	 */
-	if (!page->zone->zone_wake_kswapd)
+	if (page->zone->free_pages > page->zone->pages_high)
 		goto out_unlock;
 
 	/*
and thred one was the classzone-25 patch from Andrea.

The test is one of my tests:
    while (true); do time ./mmap002; done
which the size parameter adjusted to the size of te memory of the
system.

        The results are:
vanilla pre7-6 kills *all* my processes after 2 minutes and a half 
pre7-6 + Rajagopal:  Works quite well, times are stable between 2m20
                     and 3m10 (didn't kill any processes)

pre7-6 + Linus:      Kill all the processes after 3m and a few
                     seconds.

pre7-6 + classzone25: between 2m8 seconds and 2m23.

2.2.15: between 1m50 and 2m15 (the time is quite stable around 1m50)
        It has killed one process in 7 so far.

If you need more information, let me know.  As always comments,
suggestions are welcome.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
