Message-ID: <3913AF3E.470F26E@ucla.edu>
Date: Fri, 05 May 2000 22:35:58 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: Re: [DATAPOINT] pre7-6 will not swap
References: <Pine.LNX.4.10.10005061225460.1470-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> and I suspect that we mightactually make the vmscan.c test more eager to
> swap stuff out: my private source tree says
> 
>         /*
>          * Don't do any of the expensive stuff if
>          * we're not really interested in this zone.
>          */
>         if (z->free_pages > z->pages_high)
>                 goto out_unlock;
> 
> in vmscan.c, and that seems to be quite well-behaved too (but if somebody
> has the energy to test the two different versions, I'd absolutely love to
> hear results..)

Although I would have thought that putting this test in would have no
effect on performance, it actually kills performance.  Since the test
appears very reasonable, I think this means we have a bug elsewhere, and
that removing this reasonable test cures a symptom, but not the bug.

OK, details.
	With Linus's test, the kernel does not want to swap much.  It is a
little better than the pervious version of the test, but much lower than
if the test was removed.  One result is that the cache shrinks to low
sizes like 14Mb/64Mb, when there are several unused daemons that could 
be swapped out.	
	Also, the WRONG PROCESSES are swapped out.  Several large daemons that
were swapped out w/o the test, are now left in core.  Instead, RUNNING
programs are swapped out, like netscape.  Even worse, running xquake and
'tar -xf linux.tar' makes the system non-responsive - the VM continues
paging the quake ENGINE in and out and in and out :P
	It looks like some processes (my unused daemons) are scanned only once,
and then get stuck at the end of some list?  Is that a possible
explanation? <guessing> Perhaps Rik's moving list-head idea is needed?
</guessing>.

carry on,
-benRI
-- 
"I want to be in the light, as He is in the Light,
 I want to shine like the stars in the heavens." - DC Talk, "In the
Light"
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
