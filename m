Date: Fri, 30 Mar 2001 20:03:33 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Prevent OOM from killing init
In-Reply-To: <Pine.LNX.4.21.0103292154330.31908-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.21.0103301951090.23859-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Scott F. Kaplan" <sfkaplan@cs.amherst.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 Mar 2001, Scott F. Kaplan wrote:
> On Tue, 27 Mar 2001, Rik van Riel wrote:
> 
> > I plan to "detect" thrashing by keeping a kind of "swap load
> > average", that is, measuring in the same way as the load average how
> > many tasks are waiting on page faults simultaneously.
> 
> This seems a practical metric.  It is a bit indirect, as it's not
> measuring the reference behavior of the processes.  For example, a
> couple of processes may change phases, and make it seem, via heavy
> faulting for a time, that memory is overcommitted.  However, that
> faulting doesn't necessarily represent the inability of main memory to
> cache the critical working sets of each active process.  It's not
> "thrashing" in the sense that the CPU is doomed not to have ready
> processes to run.

If 3 processes get the CPU and 2 processes never get a 
chance to run (and are thrashing), that too is an issue
I'd like to get solved.

> > When this swap load average will get too high (too high in
> > relation to the "normal" load average ???) and possibly a few
> > other conditions are true we will select a process to suspend.
> 
> I think these may be some of the biggest questions.  Detecting that
> there is serious strain on main memory can be done.  Detecting whether
> or not it's worth trying to deactivate a process is another
> matter...It's an expensive proposition, and fundamentally changes the
> fairness with which the victim process is treated.

It's like a 2nd level scheduler, where processes become 'victim'
process in turns. But indeed, I realise that this doesn't solve
the selection problem ;)

> > This process will not be suspended immediately, but only on the next
> > page fault. It's pages will be stolen by kswapd in the normal way.
> 
> That makes sense...but which process?  There are old heuristics
> (youngest process, oldest, largest resident set, smallest, random,
> etc.).  Some of them have been shown to work better than others, but
> they're all "blind", in that there's no attempt to determine whether
> or not the other processes, left active, will really receive the extra
> space that they need once a process is selected.  That would seem to
> be a useful piece of information.
> 
> An example -- one, nasty, greedy process that uses so much space that
> it could force the deactivation of nearly all of the other processes.
> If you do that, it's unfair to too many processes.  If you deactivate
> the hog, then every time you bring it back, it will cause heavy
> paging, and a deactivation.  Ugh.

But it should cause deactivation of OTHER processes so every
process gets a chance to run...

> > We will not start reactivating processes until the swap load is
> > below the threshold again (which is automatically a reasonable
> > indication because it's a long-term floating average).
> 
> It's good that this load doesn't fluctuate too quickly.  However,
> that's no guarantee that a re-activated process won't cause
> overcommitment again (depending on which process was selected),
> leading to a nasty oscilatting behavior.  What if the load doesn't
> drop below the threshold for a long time?  Starvation is no fun,
> especially if that was your process.

The "trick" here would be to have the SAME watermark for suspending
and waking up processes and making sure that both the "swap load
average" and the rate at which processes get reactivated are slowly
changing so the re/de-activations don't cause their own thrashing.

> > Definately.  You can count on me to help think about these things
> > and help testing, etc...
> 
> Delighted to hear it!  I have more questions than answers about this
> problem, and I don't think it's been given sufficient attention
> anywhere.  Correct me if I'm wrong (please!), but I think few modern
> systems even *try* to detect overcommitment, let alone do something
> about it.  It certainly seems that for some uses, a system should have
> the option of saving the rest of the workload by unfairly sacrificing
> some process.  (And for other uses, such actions would be less
> acceptable.)

When memory is severely overcommitted, things will get slow.
What I want to make sure of is that things won't be slowing
down for one user every time while the other user always gets
to use his processes normally.

One thing I would like to do is penalise process space. One
metric we could use for this is to keep a process suspended
longer when it is bigger. For example, if we do 5 MB of swap
IO per second we could leave a 20 MB process suspended for
a minimum of 20/5 * SWAP_PENALTY = 4 * SWAP_PENALTY seconds,
while an "innocent" editor or mail reader will be suspended
for less time.

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
