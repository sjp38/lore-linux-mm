Received: from localhost (riel@localhost)
	by duckman.distro.conectiva (8.9.3/8.8.7) with ESMTP id OAA26953
	for <linux-mm@kvack.org>; Wed, 24 May 2000 14:17:05 -0300
Date: Wed, 24 May 2000 09:16:45 -0700 (PDT)
From: Matthew Dillon <dillon@apollo.backplane.com>
Message-Id: <200005241616.JAA75488@apollo.backplane.com>
Subject: Re: [RFC] 2.3/4 VM queues idea
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.21.0005241417010.24993@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

     All right!  I think your spec is coming together nicely!   The
     multi-queue approach is the right way to go (for the same reason
     FBsd took that approach).  The most important aspect of using
     a multi-queue design is to *not* blow-off the page weighting tests
     within each queue.  Having N queues alone is not fine enough granularity,
     but having N queues and locating the lowest (in FreeBSD's case 0)
     weighted pages within a queue is the magic of making it work well.

     I actually tried to blow off the weighting tests in FreeBSD, even just
     a little, but when I did FreeBSD immediately started to stall as the
     load increased.  Needless to say I threw away that patchset :-).


     I have three comments:

     * On the laundry list.  In FreeBSD 3.x we laundered pages as we went
       through the inactive queue.   In 4.x I changed this to a two-pass
       algorithm (vm_pageout_scan() line 674 vm/vm_pageout.c around the 
       rescan0: label).  It tries to locate clean inactive pages in pass1,
       and if there is still a page shortage (line 927 vm/vm_pageout.c,
       the launder_loop conditional) we go back up and try again, this 
       time laundering pages.

       There is also a heuristic prior to the first loop, around line 650
       ('Figure out what to do with dirty pages...'), where it tries to 
       figure out whether it is worth doing two passes or whether it should
       just start laundering pages immediately.

     * On page aging.   This is going to be the most difficult item for you
       to implement under linux.  In FreeBSD the PV entry mmu tracking 
       structures make it fairly easy to scan *physical* pages then check
       whether they've been used or not by locating all the pte's mapping them,
       via the PV structures.  

       In linux this is harder to do, but I still believe it is the right
       way to do it - that is, have the main page scan loop scan physical 
       pages rather then virtual pages, for reasons I've outlined in previous
       emails (fairness in the weighting calculation).

       (I am *not* advocating a PV tracking structure for linux.  I really 
       hate the PV stuff in FBsd).

     * On write clustering.  In a completely fair aging design, the pages
       you extract for laundering will tend to appear to be 'random'.  
       Flushing them to disk can be expensive due to seeking.

       Two things can be done:  First, you collect a bunch of pages to be
       laundered before issuing the I/O, allowing you to sort the I/O
       (this is what you suggest in your design ideas email).  (p.p.s.
       don't launder more then 64 or so pages at a time, doing so will just
       stall other processes trying to do normal I/O).

       Second, you can locate other pages nearby the ones you've decided to
       launder and launder them as well, getting the most out of the disk
       seeking you have to do anyway.

       The first item is important.  The second item will help extend the
       life of the system in a heavy-load environment by being able to
       sustain a higher pagout rate.  

       In tests with FBsd, the nearby-write-clustering doubled the pageout
       rate capability under high disk load situations.  This is one of the
       main reasons why we do 'the weird two-level page scan' stuff.

       (ok to reprint this email too!)

						-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
