Date: Wed, 25 Feb 1998 22:44:19 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: Fairness in love and swapping
In-Reply-To: <Pine.LNX.3.95.980225125221.8068A-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.91.980225222601.884A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Itai Nahshon <nahshon@actcom.co.il>, Alan Cox <alan@lxorguk.ukuu.org.uk>, paubert@iram.es, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Feb 1998, Linus Torvalds wrote:
> On Wed, 25 Feb 1998, Stephen C. Tweedie wrote:
> > 
> > I noticed something rather unfortunate when starting up two of these
> > tests simultaneously, each test using a bit less than total physical
> > memory.  The first test gobbled up the whole of ram as expected, but the
> > second test did not.  What happened was that the contention for memory
> > was keeping swap active all the time, but the processes which were
> > already all in memory just kept running at full speed and so their pages
> > all remained fresh in the page age table.  The newcomer processes were
> > never able to keep a page in memory long enough for their age to compete
> > with the old process' pages, and so I had a number of identical
> > processes, half of which were fully swapped in and half of which were
> > swapping madly.
> 
> What I _think_ should be done is that every time the accessed bit is
> cleared in a process during the clock scan, the "swap-out priority" of
> that process is _increased_. Right now it works the other way around: 
> having the accessed bit set _decreases_ the priority for swapping, because
> the pager thinks that that page shouldn't be paged out. 
> 
> (Note: in this context "per-process" really is "per-page-table", ie it
> should probably be in p->mm->swap_cnt rather than in p->swap_cnt..) 

In the *BSDs (the original ones?), the last n pages of a
proces' memory were considered holy, and were never swapped
out (unless the process was suspended, then _everything_ was
swapped out, including wired structures).

Personally, I have found that aging pagecache pages helps
interactive processes very much (try my mmap-age patch to
see for yourself).

We could implement some balancing by limiting the maximum number
of pages a process can have when it's number of pagefaults/second
is lower than 1/2 of the systemwide pagefaults/second.

Alternatively, we can use a dynamic pagefault/megabyte
DSIZE tuning system, ie. when a process has less than
half of the average pagefault/megabyte number it's using
too much memory, and further memory allocation should
be satisfied by a swap_out_process(self, __GFP_IO|__GFP_WAIT)
instead of an allocation from the global pool.

The BSD solution seems to be hopelessly outdated, so
the choice is between the last two solutions, with the
latter one being my favorite (despite the more difficult
calculations).

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
