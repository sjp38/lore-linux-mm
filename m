Date: Tue, 25 Apr 2000 11:53:25 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 2.3.x mem balancing
In-Reply-To: <Pine.LNX.4.21.0004251437540.10408-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.10.10004251140450.847-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 25 Apr 2000, Rik van Riel wrote:
>
> There's only one small addition that I'd like to see. Memory
> should be reclaimed on a more or less _global_ level because
> the processes in node 0 could use much less memory than the
> processes in node 1.
> 
> Doing strict per-zone memory balancing in this case means that
> node 0 will have a bunch of idle pages lying around while node
> 1 is swapping...

This is why the page allocator has to have some knowledge about the whole
list of zones it allocates from.

The current one actually does that: before it tries to start paging it
first tries to find a zone that doesn't need any paging. So in this case
if node 0 is full, but there are empty pages in node 1, the page allocator
_will_ allocate from node 1 instead.

That is obviously not to say that the current code gets the heuristics
actually =right=. There are certainly bugs in the heuristics, as shown by
bad performance. David Miller pointed out that there also seems to be a
memory leak in the swap cache handling, so it can be more than just the
zone balancing that is wrong.

My argument is really not that the current code is perfect - it very
obviously is not. But I am 100% convinced that it is much better to have
independent memory-allocators with some common heuristics than it is to
try to force a global order on them.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
