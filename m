Message-ID: <5FE9B713CCCDD311A03400508B8B30130828EDA8@bdr-xcln.corp.matchlogic.com>
From: Charles Randall <crandall@matchlogic.com>
Subject: RE: on load control / process swapping
Date: Wed, 16 May 2001 09:17:21 -0600
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Matt Dillon' <dillon@earth.backplane.com>, Roger Larsson <roger.larsson@norran.net>
Cc: Rik van Riel <riel@conectiva.com.br>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

On a related note, we have a process (currently on Solaris, but possibly
moving to FreeBSD) that reads a 26 GB file just once for a database load. On
Solaris, we use the directio() function call to tell the filesystem to
bypass the buffer cache for this file descriptor.

>From the Solaris directio() man page,

     DIRECTIO_ON
             The system behaves as though the application is  not
             going  to reuse the file data in the near future. In
             other words, the file data  is  not  cached  in  the
             system's memory pages.

We found that without this, Solaris was aggressively trying to cache the
huge input file at the expense of database load performance (but we knew
that we'd never access it again). For some applications this is a huge win
(random I/O on a file much larger than memory seems to be another case).

Would there be an advantage to having a similar feature in FreeBSD (if not
already present)?

-Charles

-----Original Message-----
From: Matt Dillon [mailto:dillon@earth.backplane.com]
Sent: Tuesday, May 15, 2001 6:17 PM
To: Roger Larsson
Cc: Rik van Riel; arch@FreeBSD.ORG; linux-mm@kvack.org;
sfkaplan@cs.amherst.edu
Subject: Re: on load control / process swapping



:Are the heuristics persistent? 
:Or will the first use after  boot use the rough prediction? 
:For how long time will the heuristic stick? Suppose it is suddenly used in
:a slightly different way. Like two sequential readers instead of one...
:
:/RogerL
:Roger Larsson
:Skelleftea
:Sweden

    It's based on the VM page cache, so its adaptive over time.  I wouldn't
    call it persistent, it is nothing more then a simple heuristic that
    'normally' throws a page away but 'sometimes' caches it.  In otherwords,
    you lose some performance on the frontend in order to gain some later
    on.  If you loop through a file enough times, most of the file
    winds up getting cached.  It's still experimental so it is only
    lightly tied into the system.  It seems to work, though, so at some
    point in the future I'll probably try to put some significant prediction
    in.  But as I said, it's a very difficult thing to predict.  You can't
    just put your foot down and say 'I'll cache X amount of file Y'.  That
    doesn't work at all.

						-Matt


To Unsubscribe: send mail to majordomo@FreeBSD.org
with "unsubscribe freebsd-arch" in the body of the message
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
