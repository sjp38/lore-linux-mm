Received: from mail.suse.de (Cantor.suse.de [194.112.123.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA02211
	for <linux-mm@kvack.org>; Mon, 25 Jan 1999 15:50:19 -0500
Message-ID: <19990125214929.A28382@Galois.suse.de>
Date: Mon, 25 Jan 1999 21:49:29 +0100
From: "Dr. Werner Fink" <werner@suse.de>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
References: <19990125141409.A29248@boole.suse.de> <Pine.LNX.3.96.990125193551.422A-100000@laser.bogus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.96.990125193551.422A-100000@laser.bogus>; from Andrea Arcangeli on Mon, Jan 25, 1999 at 08:10:34PM +0100
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>, "Dr. Werner Fink" <werner@suse.de>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@humbolt.geo.uu.nl>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Linus Torvalds <torvalds@transmeta.com>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > load to 25 ... 30+ *and* a brutal break down of that performance
> > at this point.  The system is a PentiumII 400MHz with 32, 64, 128MB
> 
> Here with a double-PII 450Mhz but with 1 sloww IDE hd (6mbyte sec
> reported by hdparm -t /dev/hda, seek time is far worse ;). Everything is
> in the same phys HD and there's only two partitions one for the swap and
> one for ext2 (rootfs).

Ok its a bit better than a single PII 400 MHz :-)
... with less than 64MB the break downs are going to be the common state
whereas with 128MB the system is usable.  Nevertheless whenever both make
loops taking the filesystem tree at the same time, the system performance
slows down dramatically (a `break down').

> > What's about a `PG_recently_swapped_in' bit for pages which arn't found
> > anymore with the swap cache?  This isn't a prediction but a protection
> > against throwing out the same page in the following cycle.
> 
> I am not sure to have understood well but if the page is been throw out
> from the swap cache it means that the page is gone and so it will be
> difficult to mark the page PG_recently_swapped_in ;). But we could use the
> same logic with a bit in the swap entry to handle that (we have 6 custom
> bit to use and only one is used right now, and it's SHM_SWP_TYPE).

This hypothetical bit should only be set if the page is read physical
from the swap device/file.  That means it would take one step more
to swap out this page again (test_and_clear_bit of both 
PG_recently_swapped_in and PG_referenced).

> 
> But I don't think it's the right approch. The swap_cache should just be
> able to throw out only the right pages. See below ... 
> 
> > > People keep playing with ignoring PG_referenced in shrink_mmap for the
> > > swap cache,
> > > because it doesn't seem terribly important.  If you could demonstrate
> > > this is a problem we can stop ignoring it.
> 
> Eric, it's important infact. I am handling aging in the swap cache here.
> That's an _important_ point for performances. I don't remeber if I pointed
> out this before.


              Werner
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
