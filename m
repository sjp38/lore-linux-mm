Date: Sat, 20 Dec 2003 21:33:34 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: load control demotion/promotion policy
Message-ID: <Pine.LNX.4.44.0312202125580.26393-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Luethi <rl@hellgate.ch>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, Andrew Morton <akpm@digeo.com>
List-ID: <linux-mm.kvack.org>

Hi,

I've got an idea for a load control / memory scheduling
policy that is inspired by the following requirements
and data points:

1) wli pointed out that one of the better performing load
   control mechanisms is one that swaps out the SMALLEST
   process (easy to swap out, removes one process worth of
   IO load from the system)

2) small processes, like root shells, should not be
   swapped out for a long time, but should be swapped
   back in relatively quickly

3) because swapping big processes in or out is a lot of
   work, we should do that infrequently

4) however, once a big process is swapped out, it should
   stay out for a long time because it greatly reduces
   the amount of memory the system needs

The swapout selection loop would be as follows:
- calculate (rss / resident time) for every process
- swap out the process where this value is lowest
- remember the rss and swapout time in the task struct

At swapin time we can do the opposite, looking at
every process in the swapped out queue and waking up
the process where (swap_rss / now - swap_time) is
the smallest.

What do you think ?

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
