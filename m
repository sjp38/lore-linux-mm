Date: Wed, 25 Feb 1998 13:02:02 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Fairness in love and swapping
In-Reply-To: <199802252032.UAA01920@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.95.980225125221.8068A-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Rik van Riel <H.H.vanRiel@fys.ruu.nl>, Itai Nahshon <nahshon@actcom.co.il>, Alan Cox <alan@lxorguk.ukuu.org.uk>, paubert@iram.es, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Wed, 25 Feb 1998, Stephen C. Tweedie wrote:
> 
> I noticed something rather unfortunate when starting up two of these
> tests simultaneously, each test using a bit less than total physical
> memory.  The first test gobbled up the whole of ram as expected, but the
> second test did not.  What happened was that the contention for memory
> was keeping swap active all the time, but the processes which were
> already all in memory just kept running at full speed and so their pages
> all remained fresh in the page age table.  The newcomer processes were
> never able to keep a page in memory long enough for their age to compete
> with the old process' pages, and so I had a number of identical
> processes, half of which were fully swapped in and half of which were
> swapping madly.
> 
> Needless to say, this is highly unfair, but I'm not sure whether there
> is any easy way round it --- any clock algorithm will have the same
> problem, unless we start implementing dynamic resident set size limits.

Yes. This is similar to what I observed when I (a long time ago) made the
swap-out a lot more strictly "least recently used": what that ended up
showing very clearly was that interactive processes got swapped out very
aggressively indeed, because they had tended to touch their pages much
less than the memory-hogging ones.. 

What I _think_ should be done is that every time the accessed bit is
cleared in a process during the clock scan, the "swap-out priority" of
that process is _increased_. Right now it works the other way around: 
having the accessed bit set _decreases_ the priority for swapping, because
the pager thinks that that page shouldn't be paged out. 

Note that these are two different priorities: you have a "per-page" 
priority and a "per-process" priority, and they should have a reverse
relationship: being accessed should obviously make the "per-page" thing
less likely to page out, but it should make the "per process" thing _more_
likely to page out. 

The per-page thing we already obviously have. And we currently have
something that comes close to being a "per process"  priority, which is
the "p->swap_cnt" thing. But it is not updated on accessed bits, but
rather differently based on the rss, and there is precious little
interaction between the two: at some point we should make the comparison
between "is the per-page priority lower than the per-process priority"? 
Right now we have a "absolute" comparison of the per-page priority for
determining whether to throw the page out or not, which isn't associated
with the per-process priority at all. 

(Note: in this context "per-process" really is "per-page-table", ie it
should probably be in p->mm->swap_cnt rather than in p->swap_cnt..) 

I think this is something to look at.. 

		Linus
