Date: Fri, 12 May 2000 15:53:34 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [RFC] process suspension (swapping)
Message-ID: <Pine.LNX.4.21.0005121253100.28943-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

I have been thinking about process suspension (as in swapping,
but have the removal of pages done by the normal paging logic)
for a number of weeks now and think I have come up with a good
algorithm.

<newbie>Process suspension (swapping) is useful when the memory
load in the system is so high that the paging system cannot keep
up with memory load and the system finds itself waiting for swap
all the time and getting no useful work done ... aka. thrashing.
</newbie>

This algorithm deals with:
- detecting when the system is thrashing
  (and when to swap something out)
- deciding when to swap something in
- deciding which process to swap in / out
- fairness, giving all processes an equal chance at making
  progress (where progress is measured as RSS*happy_time)


	The mechanism

Every N seconds (every 5 seconds, at load average recalculation?):

------------>
for_each_task(p) {
	p->mm->swap_rss -= (p->mm->swap_rss >> 6);  // MAGIC NUMBER
	p->mm->avg_swap_rss -= (p->mm->avg_swap_rss >> 6);
	p->mm->swap_rss += p->mm->rss;
	global_swap_rss += p->mm->rss;

	/* The task is "happy" / not swapping or waiting for IO. */B
	if (p->state == TASK_RUNNING || p->state == TASK_INTERRUPTIBLE) {
		p->mm->avg_swap_rss += p->mm->rss;
		global_avg_swap_rss += p->mm->rss;
	}
}
global_swap_rss -= (global_swap_rss >> 6);
global_avg_swap_rss -= (global_avg_swap_rss >> 6);
<---------

The result of this will be that if a process is waiting for IO
half of the time, it's avg_swap_rss will be half of it's rss...
This way we have an idea how much chance each process has to
make progress with whatever it was doing.


	When/what to swap out


Since we also keep a count for the system's _total_ swap_rss
and avg_swap_rss, we can look at the ratio between the two to
determine if the system is thrashing or not. This is the 3rd
magic number in our algorithm ;(

If ((global_avg_swap_rss / global_swap_rss) < 0.5) {
	suspend process with biggest avg_swap_rss;
}

(we'll call this the thrashing ratio)


	When/what to swap in


When to swap something back in is a bit more tricky, since
we need to avoid thrashing when there is swapping going on.
Since our aim is to have a system where little or no thrashing
is going on, we should use the above thrashing ratio in our
calculation of when to swap something in...

We should of course swap in the process with the smallest
avg_swap_count, to ensure fairness; I have the feeling we
can swap it in when we are fulfilling this condition:

A = swapped process with smallest avg_swap_count
B = non-swapped process with biggest avg_swap_count

A->avg_swap_rss < (B->avg_swap_rss * thrashing_ratio**2)


NOTE: the "swapping" doesn't actually swap anything, it
just makes sure the process isn't scheduled for a while
so it doesn't put memory pressure on the system.

Inspiration from this idea comes from ITS, the Incompatible
Timesharing System. Thanks go out to Richard D. Greenblatt
who did the original implementation (slightly different)
for ITS and to Richard Stallman who took the time to tell
me about this algorithm.

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
