Date: Mon, 7 May 2001 18:16:57 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: on load control / process swapping
Message-ID: <Pine.LNX.4.21.0105061924160.582-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: arch@freebsd.org
Cc: linux-mm@kvack.org, Matt Dillon <dillon@earth.backplane.com>, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

Hi,

after staring at the code for a long long time, I finally
figured out exactly why FreeBSD's load control code (the
process swapping in vm_glue.c) can never work in many
scenarios.

In short, the process suspension / wake up code only does
load control in the sense that system load is reduced, but
absolutely no effort is made to ensure that individual
programs can run without thrashing. This, of course, kind of
defeats the purpose of doing load control in the first place.


To see this situation in some more detail, lets first look
at how the current process suspension code has evolved over
time.  Early paging Unixes, including earlier BSDs, had a
rate-limited clock algorithm for the pageout code, where
the VM subsystem would only scan (and page) memory out at
a rate of fastscan pages per second.

Whenever the paging system wasn't able to keep up, free
memory would get below a certain threshold and memory load
control (in the form of process suspension) kicked in.  As
soon as free memory (averaged over a few seconds) got over
this threshold, processes get swapped in again.  Because of
the exact "speed limit" for the paging code, this would give
a slow rotation of memory-resident progesses at a paging rate
well below the thashing threshold.


More modern Unixes, like FreeBSD, NetBSD or Linux, however,
don't have the artificial speed limit on pageout.  This means
the pageout code can go on freeing memory until well beyond
the trashing point of the system.  It also means that the
amount of free memory is no longer any indication of whether
the system is thrashing or not.

Add to that the fact that the classical load control in BSD
resumes a suspended task whenever the system is above the
(now not very meaningful) free memory threshold, regardless
of whether the resident tasks have had the opportunity to
make any progress ... which of course only encourages more
thrashing instead of letting the system work itself out of
the overload situation.


Any solution will have to address the following points:

1) allow the resident processes to stay resident long
   enough to make progess
2) make sure the resident processes aren't thrashing,
   that is, don't let new processes back in memory if
   none of the currently resident processes is "ready"
   to be suspended
3) have a mechanism to detect thrashing in a VM
   subsystem which isn't rate-limited  (hard?)

and, for extra brownie points:
4) fairness, small processes can be paged in and out
   faster, so we can suspend&resume them faster; this
   has the side effect of leaving the proverbial root
   shell more usable
5) make sure already resident processes cannot create
   a situation that'll keep the swapped out tasks out
   of memory forever ... but don't kill performance either,
   since bad performance means we cannot get out of the
   bad situation we're in


Points 1), 2) and 4) are relatively easy to address by simply
keeping resident tasks unswappable for a long enough time that
they've been able to do real work in an environment where
3) indicates we're not thrashing.


3) is the hard part. We know we're not thrashing when we don't
have ongoing page faults all the time, but (say) only 50% of the
time. However, I still have no idea to determine when we _are_
thrashing, since a system which always has 10 ongoing page faults
may still be functioning without thrashing...  This is the part
where I cannot hand a ready solution but where we have to figure
out a solution together.

(and it's also the reason I cannot "send a patch" ... I know the
current scheme cannot possibly work all the time, I understand why,
but I just don't have a solution to the problem ... yet)

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
