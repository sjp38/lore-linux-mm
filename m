Date: Tue, 25 Apr 2000 14:50:12 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: 2.3.x mem balancing
In-Reply-To: <Pine.LNX.4.10.10004250932570.750-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0004251437540.10408-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Apr 2000, Linus Torvalds wrote:

> Andrea, how do you ever propose to handle the case of four
> different memory zones, all "equal", but all separate in that
> while all of memory isaccessible from each CPU, each zone is
> "closer" to certain CPU's? Let's say that CPU's 0-3 have direct
> access to zone 0, CPU's 4-7 have direct access to zone 1, etc
> etc.. Whenever a CPU touches memory on a non-local zone, it
> takes longer for the cache miss, but it still works.

[snip different zonelists for each node at allocation time]

There's only one small addition that I'd like to see. Memory
should be reclaimed on a more or less _global_ level because
the processes in node 0 could use much less memory than the
processes in node 1.

Doing strict per-zone memory balancing in this case means that
node 0 will have a bunch of idle pages lying around while node
1 is swapping...

(and yes, I have this implemented in the patch I'm working on
and it mostly works. It just needs to be tuned some more before
it's ready for inclusion)

Another thing which we probably want before 2.4 is scanning
big processes more agressively than small processes. I've
implemented most of what is needed for that and it seems to
have a good influence on performance because:
- small processes suffer less from the presence of memory hogs
- memory hogs have their pages aged more agressively, making it
  easier for them to do higher throughput from/to swap or disk

The algorithm I'm using for that now is quite simple. At the 
time where we assign mm->swap_cnt we remember the biggest
process. After that we do a second loop, and reduce mm->swap_cnt
for smaller processes using this simple formula:

                 /* small processes are swapped out less */
                 while ((mm->swap_cnt << 2 * i) < max_cnt)
                          i++;
                 mm->swap_cnt >>= i;
                 mm->swap_cnt += i; /* in case swap_cnt reaches 0 */

We may want to refine this a bit in the future, but this form
seems to work quite well. A possible addition is to set a flag
for all the "big" processes (where i is 0) and have them run
swap_out() on every memory allocation...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
