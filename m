Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA10692
	for <linux-mm@kvack.org>; Tue, 9 Dec 1997 09:53:21 -0500
Date: Tue, 9 Dec 1997 15:37:36 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: pageable page tables
In-Reply-To: <19971209122346.02899@Elf.mj.gts.cz>
Message-ID: <Pine.LNX.3.91.971209152121.584D-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@Elf.mj.gts.cz>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Dec 1997, Pavel Machek wrote:

> Hi!
> 
> > > Simple task might be 'memory priorities'. Something like priorities
> > > for scheduler but for memory. (I tried to implement them, and they
> > > gave <1% performance gain ;-), but I have interface to set such
> > > parameter if you want to play).
> > 
> > sounds rather good... (swapout-priorities??)
> 
> But proved to be pretty ineffective. I came to this idea when I
> realized that to cook machine, running 100 processes will not hurt too
> much. But running 10 processes, 50 megabytes each will cook almost
> anything...

I think it will be more of a scheduling issue...
Suspending low-priority, background jobs for a minute
(in turn) will make swapping / running possible again
(even without changes to the swapping code).

To do this, we could create a new scheduling class: SCHED_BG
Processes in this class are run:
- one at a time (possibly two??)
- for LONG slices, getting longer after each slice (a'la CTSS)
- so only one of them has to be in memory...
- at a lower priority than interactive jobs.
- CPU time and memory used by these processes aren't charged
  when user quota's are inforced... this should encourage users
  to run large jobs (and even medium compiles) as SCHED_BG jobs

about the time-slicing:
- the SCHED_BG process is run when no interactive process is
  runnable
- it starts with a 1 second slice, followed by 2, 4, 8, 16, 
  and longer timeslices (in order to reduce swapping).
- these slices are only interrupted by:
  - an interactive process wanting the CPU
  - blocking on a resource
  - another SCHED_BG process is woken up
- after the timeslice is over, the process is put to sleep
  for a duration of: last_timeslice * nr_background_processes
- when no background process is running/runnable, the next
  SCHED_BG process to be woken up is made runnable
- the SCHED_BG processes can run together/in parrallel when
  available memory is above a certain threshold (then they
  can receive 'normal' timeslices)

And when free memory stays below free_pages_low for more
than 5 seconds, we can choose to have even normal processes
queued for some time (in order to reduce paging)

Where Do You Want Us To Take You Today ? (tm)

Rik.

--
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
