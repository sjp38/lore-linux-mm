From: Mark_H_Johnson.RTS@raytheon.com
Message-ID: <852568C8.00490F70.00@raylex-gh01.eo.ray.com>
Date: Fri, 21 Apr 2000 08:22:47 -0500
Subject: Re: swapping from pagecache?
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cacophonix <cacophonix@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


I have a few questions & comments on this [and related memory resource items].

 - Are you saying that the performance of 2.3.99 is below that of 2.2 because
the system is swapping?
 - If so, why do you consider swapping to be "bad"?

In the "good old days" (mid 70's to early 80's), most systems had enough
physical memory to keep a few jobs in memory and the rest had to be swapped.
Many of these systems could be called "aggressive" in swapping to push a few
extra jobs into the swap area so that currently running jobs could grow and so
that new jobs could be brought into memory immediately. This tends to improve
interactive response time at the cost of making some periodic tasks [e.g., a job
that wakes up every 15 minutes to forward email] run slightly slower.

As paging was added to systems (e.g., in VAX/VMS) a lot of effort was expended
to continue to use memory efficiently. There were several parameters that you
could set for users or as system wide settings that adjusted how much physical
memory would be allocated to a running process. You could tune the system so
that one or many jobs could get more memory (and less paging) if the system was
lightly loaded. When the system became heavily loaded (10am to 2pm), the
physical memory allocated to each job was reduced - increasing paging, but
allowing "fair" access to system resources.

My experience so far w/ Linux 2.2 (both .10 and .14) is that it is "lazy" in
swapping and paging. It attempts to keep memory fully utilized. There are costs
and benefits of such an approach. Your application may do better with such
tuning. My experience is that a "rogue" program, one that allocates a lot of
virtual memory and keeps it busy, can cause serious degradation to a Linux
system. Let me use an example a prime number finder using Eratosthenes  sieve.
It walks through memory setting every second, third, fifth, seventh, and so on
item in a large array, marking it as "non-prime". It generates a HUGE number of
dirty pages. Since physical memory limits aren't imposed on Linux 2.2, this
program gobbles up all physical memory. Most, if not all other jobs get swapped,
and system performance is awful. Running this same program on a VMS system,
properly tuned, would result in slower performance for the sieve, higher paging
rates, but still reasonable interactive performance. I would like to see Linux
in 2001 have better performance than VMS did in the early 80's.

My current application area is with large, real time systems. Our current target
system has 24 CPU's w/ 2 G of physical memory. In these systems, I don't want
any paging nor swapping when the real time application is running. I want to
lock everything needed into physical memory & actually want to disable paging
and swapping if I could [I can, but it severely restricts my choice in OS and
causes other problems].

Now, I can't afford to buy a system like that for each developer. Therefore, I
can't use it for most of the development activity. I want to be able to develop
that application on a $5k PC, run it in "slower than real time", take the paging
and swapping hits and get some work done instead of waiting until 3am when time
is available on the $1,500K simulator. So, to get what I want, I need good
performance out of the memory management system. It needs to be able to page &
swap to maintain good interactive response times. It would be better if it was
tunable to handle a wide variety of applications - perhaps that would be a
better solution than biasing the system to or away from paging and swapping.

--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>


|--------+----------------------->
|        |          Cacophonix   |
|        |          <cacophonix@y|
|        |          ahoo.com>    |
|        |                       |
|        |          04/20/00     |
|        |          04:07 PM     |
|        |                       |
|--------+----------------------->
  >----------------------------------------------------------------------------|
  |                                                                            |
  |       To:     linux-mm@kvack.org                                           |
  |       cc:     (bcc: Mark H Johnson/RTS/Raytheon/US)                        |
  |       Subject:     swapping from pagecache?                                |
  >----------------------------------------------------------------------------|



Hello all,
I've been running a few webserver tests with 2.3.99-pre6-2, and there seems
to be some difference in behavior between 2.2.x and 2.3.99-pre.

Specifically, on 2.3.99, it appears that unused pages from the page cache
are swapped to disk, while in 2.2, unused pages are not swapped. As a result,
performance on 2.3.99-pre drops to below 2.2. levels under such a scenario.

[detailed procinfo removed]

A procinfo under 2.2.16-pre1 with a similar scenario shows memory being
shared (mainly by the web server, which has an internal cache), and does
not swap at all.

Any comments on this behavior? (shm is mounted of course).  Thanks for
any advice.

cheers,
karthik


__________________________________________________
Do You Yahoo!?
Send online invitations with Yahoo! Invites.
http://invites.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
