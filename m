Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA01815
	for <linux-mm@kvack.org>; Mon, 25 Jan 1999 15:17:01 -0500
Date: Mon, 25 Jan 1999 20:10:34 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <19990125141409.A29248@boole.suse.de>
Message-ID: <Pine.LNX.3.96.990125193551.422A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@humbolt.geo.uu.nl>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Linus Torvalds <torvalds@transmeta.com>, Savochkin Andrey Vladimirovich <saw@msu.ru>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Jan 1999, Dr. Werner Fink wrote:

> I'm using simple two loops in different kernel trees:
> 
>       while true; do make clean; make MAKE='make -j10'; done

Tried now.

> which leads into load upper 30.  You can see a great performance upto

Here the load never goes over 25. There are always 35mbyte of swap used
with 128Mbyte of ram (I am using egcs-1.1.1 btw). So I guess that the
problem of pre9 you are reporting is the VM and nothing related to the
scheduler (maybe not?). 

I am writing this with the machine under load and here inside pine ;) it's
responsive as when it was idle. 

> load to 25 ... 30+ *and* a brutal break down of that performance
> at this point.  The system is a PentiumII 400MHz with 32, 64, 128MB

Here with a double-PII 450Mhz but with 1 sloww IDE hd (6mbyte sec
reported by hdparm -t /dev/hda, seek time is far worse ;). Everything is
in the same phys HD and there's only two partitions one for the swap and
one for ext2 (rootfs).

> (mem=xxx) and SCSI only.  In comparision to 2.0.36 the performance
> is *beside of this break down* much better ...  that means that only
> the performance break down at high load is the real problem.

I suggest you to try out my:

	ftp://e-mind.com/pub/linux/arca-tree/2.2.0-pre9_arca-2.gz

It's against 2.2.0-pre9 and has also my latest VM in it.

> What's about a `PG_recently_swapped_in' bit for pages which arn't found
> anymore with the swap cache?  This isn't a prediction but a protection
> against throwing out the same page in the following cycle.

I am not sure to have understood well but if the page is been throw out
from the swap cache it means that the page is gone and so it will be
difficult to mark the page PG_recently_swapped_in ;). But we could use the
same logic with a bit in the swap entry to handle that (we have 6 custom
bit to use and only one is used right now, and it's SHM_SWP_TYPE).

But I don't think it's the right approch. The swap_cache should just be
able to throw out only the right pages. See below ... 

> > People keep playing with ignoring PG_referenced in shrink_mmap for the swap cache,
> > because it doesn't seem terribly important.  If you could demonstrate
> > this is a problem we can stop ignoring it.

Eric, it's important infact. I am handling aging in the swap cache here.
That's an _important_ point for performances. I don't remeber if I pointed
out this before.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
