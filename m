From: Mark_H_Johnson.RTS@raytheon.com
Message-ID: <852568E0.0056F0BB.00@raylex-gh01.eo.ray.com>
Date: Mon, 15 May 2000 09:50:38 -0500
Subject: Re: pre8: where has the anti-hog code gone?
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org, riel@conectiva.com.br, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>


I guess I have a "philosophy question" - one where I can't quite understand the
situation that we are in.
  What is the problem that killing processes is curing?
I understand that the code that [has been/still is?] killing processes is doing
so because there is no "free physical memory" - right now. Yet we have had code
to do a schedule() instead of killing the job, and gave the system the chance to
"fix" the lack of free physical memory problem (e.g., by writing dirty pages to
a mapped file or swap space on disk). From what I read from Juan's message
below, I guess this code has been lost or replaced by something more hostile to
user applications.

The problem as I see it is that we are seeing a situation where the system can
"generate" dirty pages far faster than the dirty pages make it to disk. The
relationship of
  [extremely fast CPU] --- is much faster than -> [relatively slow disk]
    -- results in --> [no free physical memory] -- system kills job--> [killed
process]
is causing the system to trigger the process killing code. The alternative I'm
suggesting is
  --> [no free memory] -- system does reschedule --> [dirty pages written & free
physical memory]
  -- resume suspended job -->  [job runs to completion, and no jobs are killed]
to give the system time to act on the situation.

If you are truly out of memory [physical memory and ALL swap space], then SOME
job has to free up memory. I think we would all agree with this premise. I
suggest we remove automatic job killing as a solution. If it must remain as a
solution, there must be several other attempts tried first.

If this is an interactive system, the user should be able to close a window or
otherwise kill a job [preferably the rogue job] to make some space available. If
this is a standalone system (say a server), the long term solution is likely
"get more memory or swap space". However, that doesn't fix the problem "right
now". In this case, give the developer or operator of that system an opportunity
to make the choice on which job to kill. Perhaps reserving a small amount of
memory [just like the disk reserve] for privileged users is a solution. Making
the job killing choice at a low level of the kernel, based on "what's currently
running" does not appear to be the "right" answer. Making this choice in the
kernel and killing "init" (as Juan notes below) is almost certainly the "wrong"
answer.

I see a choice in alternatives...
 [1] replace the raise SIGKILL code with schedule(). I've tried this in older
kernels (2.2.14) & it helps preserve system operation with mapped files, but
doesn't help when the swap file is full. [this may fix Juan's symptoms]
 [2] return "out of memory" when swap is full - let application code handle it.
If no action in "X" time, then kill a job. Add to kswapd?
 [3] long term - add a "reserve" to physical memory for root (or privileged
code). [not sure how to implement]
 [4] Protect init (could be as simple as if pid==1, then schedule() & kill
something else)
 [5] Long term - reduce resident set sizes to slow the generation of dirty
pages. Let me use a "file copy" as an example. I can use "cp A B" to do this. I
can also write a program that maps files "A" and "B" into memory & copy the
contents of "A" into "B" and then unmap the two files [Multics used to do
something like this for all file accesses]. These two methods SHOULD have
similar characteristics in terms of CPU time, memory used, elapsed time, etc.
The current VM system in Linux handles the "cp" example much better than the
memory mapped example - I think this is due to overhead in memory management
with large resident set sizes. [make code active to enforce RSSLIM].

As a system administrator and user of Linux, I am concerned about jobs getting
"killed" - please make this a "last resort". Do it only after giving me and my
users time to "fix" the problem. Thanks.

--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>


|--------+----------------------->
|        |          "Juan J.     |
|        |          Quintela"    |
|        |          <quintela@fi.|
|        |          udc.es>      |
|        |                       |
|        |          05/13/00     |
|        |          01:14 PM     |
|        |                       |
|--------+----------------------->
  >----------------------------------------------------------------------------|
  |                                                                            |
  |       To:     Linus Torvalds <torvalds@transmeta.com>                      |
  |       cc:     Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org,    |
  |       (bcc: Mark H Johnson/RTS/Raytheon/US)                                |
  |       Subject:     Re: pre8: where has the anti-hog code gone?             |
  >----------------------------------------------------------------------------|



>>>>> "linus" == Linus Torvalds <torvalds@transmeta.com> writes:

Hi

linus> So pre-8 with your suggested for for kswapd() looks pretty good,
actually,
linus> but still has this issue that try_to_free_pages() seems to give up too
linus> easily and return failure when it shouldn't. I'll happily apply patches
linus> that make for nicer behaviour once this is clearly fixed, but not before
linus> (unless the "nicer behaviour" patch _also_ fixes the "pathological
linus> behaviour" case ;)

Here pre8, pre8 with any of the Rik patchs and pre9-1 looks bad.  If I
ran mmap002 in that machines it will be killed allways, now a lot of
times in around 30 seconds (in previous kernels the tests lasts around
3 min before being killed).  The system continues doing kills until
init dies, then all the system freezes, no net, no ping answer, no
keyboard answer (sysrq didn't work).  No information in logs, except
that some processes have been killed, no messages in the console
either.  If you need to reproduce the efect is easy, here in less than
5 min mmap002 test, the system is frozen.

If you need more information, let me know.

Later, Juan.


--
In theory, practice and theory are the same, but in practice they
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
