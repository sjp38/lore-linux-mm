Date: Tue, 27 Mar 2001 21:00:57 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Prevent OOM from killing init
In-Reply-To: <Pine.LNX.4.21.0103270854350.25071-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.21.0103272049250.8261-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Scott F. Kaplan" <sfkaplan@cs.amherst.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 27 Mar 2001, Scott F. Kaplan wrote:
> On Sat, 24 Mar 2001, Rik van Riel wrote:
> 
> > [...]  I need to implement load control code (so we suspend
> > processes in turn to keep the load low enough so we can avoid
> > thrashing).
> 
> I am curious as to how you plan to go about implementing this load
> control.  I ask because it's a current area of research for me.
> Detecting the point at which thrashing occurs (that is, the point at
> which process utilization starts to fall because every active process
> is waiting for page faults, and nothing is ready to run) is not
> necessarily easy.
>
> There was a whole bunch of theory about how to detect this kind of
> over-commitment with Working Set.  Unfortunately, I'm reasonably
> convinced that there are some serious holes in that theory, and that
> nobody has developed a well founded answer to this question.  Do you
> have ideas (taken from others or developed yourself) about how you're
> going to approach it?

Cool, you've noticed too  ;))

Current theory _really_ seems to be lacking and I'm still busy
trying to come up with an idea that works ...

> My specific concerns are things like:  What will your definition of
> "thrashing" be?  How do you plan to detect it?  When you suspend a
> process, what will happen to that process?  Will its main memory
> allocation be taken away immediately?  When will it be re-activated?

I plan to "detect" thrashing by keeping a kind of "swap load
average", that is, measuring in the same way as the load average
how many tasks are waiting on page faults simultaneously.

When this swap load average will get too high (too high in
relation to the "normal" load average ???) and possibly a few
other conditions are true we will select a process to suspend.

This process will not be suspended immediately, but only on the
next page fault. It's pages will be stolen by kswapd in the normal
way.

We will not start reactivating processes until the swap load is
below the threshold again (which is automatically a reasonable
indication because it's a long-term floating average).

> Basically, these problems used to have easier answers on old batch
> systems with a lesser notion of fairness and more uniform workloads.
> It's not clear what to do here; by suspending processes, you're
> introducing a kind of long-term scheduler that decides when a process
> can enter the pool of candidates from which the usual, short-term
> scheduler chooses.  There seems to be some real scheduling issues that
> go along with this problem, including a substantial modification to
> the fairness with which suspended processes are treated.
> 
> I'd like very much to see a well developed, generalized model for this
> kind of problem.  Obviously, the answer will depend on what the
> intended use of the system is.  It would be wonderful to avoid ad-hoc
> solutions for different cases, and instead have one approach that can
> be adjusted to serve different needs.

Definately.  You can count on me to help think about these things
and help testing, etc...

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
