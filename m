Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA32416
	for <linux-mm@kvack.org>; Mon, 7 Dec 1998 15:20:02 -0500
Date: Mon, 7 Dec 1998 21:17:56 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: readahead/behind algorithm
Message-ID: <Pine.LNX.3.96.981207195746.32057A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

Hi,

I've thought a bit about what the 'ideal' readahead/behind
algorithm would be and reached the following conclusion.

1. we test the presence of pages in the proximity of the
   faulting page (31 behind, 32 ahead) building a map of
   64 pages.
2. we see how many pages are already present and mapped
   in these locations:
   - 31-15 pages behind
   - 14-01 pages behind
   - 01-15 pages ahead
   - 16-32 pages ahead
3. if there are a lot of (20? 25?) pages behind and less
   than 8 pages ahead (from a previous readahead?) we read
   possibly up to the 32-page mark
4. same for read-behind (so a program can walk through it's
   address space the other way around at full speed :)
5. if there are only a very few pages present around us (only
   using the 'near' indexes) we read 7 behind and 8 ahead
6. if there are quite a lot of pages present in our vincinity,
   chances are that we've already had situation 5 so we can
   establish a sense of direction and read in 16 pages in that
   direction

Of course, we use the physical location of all these pages in
swap and ignore pages that are far away physically and cannot
efficiently be clustered with other I/O requests.

Ideally we'd also keep track of those pages (using 2 lists,
which we alternately zero to forget old requests) and test
the physical vincinity of our swap requests in order to
read in the ones that were too 'remote' previously...

This is not the most clear explanation of what I meant,
but my mind is too foggy now to make a complete explanation :)

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
