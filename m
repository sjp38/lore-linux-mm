Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA08782
	for <linux-mm@kvack.org>; Fri, 12 Dec 1997 02:10:50 -0500
Date: Fri, 12 Dec 1997 07:57:16 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: pageable page tables
In-Reply-To: <19971210161108.02428@Elf.mj.gts.cz>
Message-ID: <Pine.LNX.3.91.971212074748.466A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@Elf.mj.gts.cz>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Dec 1997, Pavel Machek wrote:

> > > > > Simple task might be 'memory priorities'. Something like priorities
> > > > > for scheduler but for memory. (I tried to implement them, and they
> > > > > gave <1% performance gain ;-), but I have interface to set such
> > > > > parameter if you want to play).
> > > > 
> > > > sounds rather good... (swapout-priorities??)
> > > 
> > > But proved to be pretty ineffective. I came to this idea when I
> > > realized that to cook machine, running 100 processes will not hurt too
> > > much. But running 10 processes, 50 megabytes each will cook almost
> > > anything...

... this is where things started falling into place :)

> > I think it will be more of a scheduling issue...
> > Suspending low-priority, background jobs for a minute
> > (in turn) will make swapping / running possible again
> > (even without changes to the swapping code).
> > 
> > To do this, we could create a new scheduling class: SCHED_BG
> > Processes in this class are run:
> > - one at a time (possibly two??)
> > - for LONG slices, getting longer after each slice (a'la CTSS)
> 
> What is CTSS?

Central (?) Time Sharing System... From somewhere in
the '60s... It had the following properties:
- no VM, only one process could be loaded at the same time
- if you want to switch to another process, you'd have to
  swap the current one out and the other one in 
  --> extremely slow task switching
- it was a multi-user system
- with some people using it for _long_ computations
- so they came up with the following solution:
  - a process starts with a timeslice of length 1
  - every following time, the length of the slice get's
    doubled (and the process get's scheduled less often)
  - if the process is interactive (ie. keyboard input)
    the process is moved to the highest (short ts) class

> > - so only one of them has to be in memory...
> > - at a lower priority than interactive jobs.
> > - CPU time and memory used by these processes aren't charged
> >   when user quota's are inforced... this should encourage users
> >   to run large jobs (and even medium compiles) as SCHED_BG jobs
> 
> Not sure this is good idea.

Many systems use something like NQS for large jobs, but
this would be a nice scheme for 'medium' jobs. The
machine at our school, for instance, has a 5minute CPU
limit (per process)...
Doing a large compile (glibc :-) on such a machine would
not only fail, but it would also annoy other users. This
SCHED_BG scheme doesn't really load the rest of the system...
> 
> > about the time-slicing:
> > - the SCHED_BG process is run when no interactive process is
> >   runnable
> > - it starts with a 1 second slice, followed by 2, 4, 8, 16, 
> >   and longer timeslices (in order to reduce swapping).
> > - these slices are only interrupted by:
> >   - an interactive process wanting the CPU
> >   - blocking on a resource
>       ~~~~~~~~~~~~~~~~~~~~~~
> Bad idea. If that jobs read disks (sometime), they will lose their
> (extremely long) timeslice. (BTW page fault requiring swap-in is also
> blocking on a resource. 

Uh, that's not what I meant to say... If it blocks on a
resource, and the wainting time is too high (and there's
enough memory, and idle time) you could wake up another
process... Of course the slice won't end...

> > - the SCHED_BG processes can run together/in parrallel when
> >   available memory is above a certain threshold (then they
> >   can receive 'normal' timeslices)
> > 
> > And when free memory stays below free_pages_low for more
> > than 5 seconds, we can choose to have even normal processes
> > queued for some time (in order to reduce paging)

someone else have an opinion on this?

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
