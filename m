Date: Wed, 25 Feb 1998 20:32:02 GMT
Message-Id: <199802252032.UAA01920@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Fairness in love and swapping
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Rik van Riel <H.H.vanRiel@fys.ruu.nl>, Itai Nahshon <nahshon@actcom.co.il>, Alan Cox <alan@lxorguk.ukuu.org.uk>, paubert@iram.es, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hmm.

I've been continuing to test the swapper stuff, and Linus has a couple
of patches which will help with spurious warnings --- I'll make a fresh
patch against 89pre1 shortly unless he beats me to it.  While testing, I
discovered a rather nasty behaviour inherent in the swapper.

The test program I was using allocates a large heap of pages and writes
different signatures to each page (keeping a copy of each signature in a
separate, compressed array).  It then forks off a number of reader
processes which continually validate the signatures in the heap pages,
and writer processes which do the same except that every so often they
write a new signature to a page and to the pattern table.  If the total
heap size exceeds available memory, then the whole thing has to swap
shared pages both in and out to work, and the writer tasks perform COW
on the shared pages.

I noticed something rather unfortunate when starting up two of these
tests simultaneously, each test using a bit less than total physical
memory.  The first test gobbled up the whole of ram as expected, but the
second test did not.  What happened was that the contention for memory
was keeping swap active all the time, but the processes which were
already all in memory just kept running at full speed and so their pages
all remained fresh in the page age table.  The newcomer processes were
never able to keep a page in memory long enough for their age to compete
with the old process' pages, and so I had a number of identical
processes, half of which were fully swapped in and half of which were
swapping madly.

Needless to say, this is highly unfair, but I'm not sure whether there
is any easy way round it --- any clock algorithm will have the same
problem, unless we start implementing dynamic resident set size limits.

Just a thought..

Cheers,
 Stephen.
