Received: (from john@localhost)
	by boreas.southchinaseas (8.9.3/8.9.3) id OAA00408
	for <linux-mm@kvack.org>; Sun, 4 Jun 2000 14:54:17 +0100
Subject: Re: Long time spent in swap_out &co
References: <Pine.LNX.4.21.0006032219070.17414-100000@duckman.distro.conectiva>
From: "John Fremlin" <vii@penguinpowered.com>
Date: 04 Jun 2000 14:54:13 +0100
In-Reply-To: Rik van Riel's message of "Sat, 3 Jun 2000 22:28:43 -0300 (BRST)"
Message-ID: <m2wvk54kmy.fsf@boreas.southchinaseas>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> On 4 Jun 2000, John Fremlin wrote:
> 
> >         (a) The entire list of processes is scanned through each time
> >         at least once. (Slow, and holding a lock.)
> 
> This is not very slow, since it only looks at something like
> 3 or 4 numbers and flags per process.

Perhaps, but you're traversing a linked list. That means that the
task_struct entries will probably be widely dispersed, so that each
one has to be fetched from main RAM, Then you look at the mm_struct
(another miss?). According to "Modern Compiler Implementation in ML"
(Andrew W. Appel, Cambridge University Press, 1998) a secondary cache
miss is typically 100-200 cycles.  So if we say around 300-400 cycles
per iteration of the loop (assuming that the needed data in the two
structs are fetched completely for each miss penalty), everything
taken together. I'd say that's quite slow, but I guess assembly
programming skews your outlook considerably ;-)

Supposing 1000 tasks, that's a millisecond to do this scan once on a
300 MHz machine. (That is, the process is O(N) or worse due to cache
hierarchies and so doesn't scale well).

You could keep an list of 1st biggest, 2nd biggest, 3rd biggest,
etc. up to "count" biggest so that you don't scan the list for each
count.
> 
> >         (b) The biggest rss is chosen. Admittedly the swap_cnt
> >         heuristics help a bit but it means that a large process that
> >         is on touching its pages will keep distracting attention from
> >         more smaller processes that may or may not be more wasteful.
> 
> Please look at the 'assign' variable. We will chose the process
> with the biggest swap_cnt until swap_cnt for *all* processes is
> 0.

Yes, I saw that. But always picking on the very biggest first once the
swap_cnts hit 0 seems unfair and wasteful. 

> Then we will reassign swap_cnt. This ensures that all processes
> get scanned fairly.

But why bother always picking the biggest first? Just pick the first
that's got a non-zero swap_cnt would be faster and no less fair. I'll
see if I can get a noticable improvement.

> Also, note the counter variable, we'll only scan up to a few

Supposing 
        priority        nr_threads              counter
        64              100                     0 => 1
        32              100                     1 => 1

So that it is unlikely that we iterate more than a single time. Have I
got my priorities wrong? ;-) 

If I choose 16:

        16              100                     25 => 25
        

> processes, and we'll return after we have freed just one page.

Hmm. Seems a false speed economy (quicker to do a lot in one place
that to do a little in many).

We are scanning through all the running threads or all the threads?

-- 

	http://altern.org/vii
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
