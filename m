Received: from h005004952c84.ne.mediaone.net (IDENT:sfkaplan@h005004952c84.ne.mediaone.net [24.128.254.0])
	by chmls20.mediaone.net (8.11.1/8.11.1) with ESMTP id f2U3HIa18986
	for <linux-mm@kvack.org>; Thu, 29 Mar 2001 22:17:18 -0500 (EST)
Date: Thu, 29 Mar 2001 22:18:15 -0500 (EST)
From: "Scott F. Kaplan" <sfkaplan@cs.amherst.edu>
Subject: Re: [PATCH] Prevent OOM from killing init
In-Reply-To: <Pine.LNX.4.21.0103272049250.8261-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.LNX.4.21.0103292154330.31908-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Tue, 27 Mar 2001, Rik van Riel wrote:

> I plan to "detect" thrashing by keeping a kind of "swap load
> average", that is, measuring in the same way as the load average how
> many tasks are waiting on page faults simultaneously.

This seems a practical metric.  It is a bit indirect, as it's not
measuring the reference behavior of the processes.  For example, a
couple of processes may change phases, and make it seem, via heavy
faulting for a time, that memory is overcommitted.  However, that
faulting doesn't necessarily represent the inability of main memory to
cache the critical working sets of each active process.  It's not
"thrashing" in the sense that the CPU is doomed not to have ready
processes to run.

Important note:  I'm looking for a good model, and not necessarily a
practical solution that you'd want to put in a kernel.  I know that
there can be a difference!

> When this swap load average will get too high (too high in
> relation to the "normal" load average ???) and possibly a few
> other conditions are true we will select a process to suspend.

I think these may be some of the biggest questions.  Detecting that
there is serious strain on main memory can be done.  Detecting whether
or not it's worth trying to deactivate a process is another
matter...It's an expensive proposition, and fundamentally changes the
fairness with which the victim process is treated.

> This process will not be suspended immediately, but only on the next
> page fault. It's pages will be stolen by kswapd in the normal way.

That makes sense...but which process?  There are old heuristics
(youngest process, oldest, largest resident set, smallest, random,
etc.).  Some of them have been shown to work better than others, but
they're all "blind", in that there's no attempt to determine whether
or not the other processes, left active, will really receive the extra
space that they need once a process is selected.  That would seem to
be a useful piece of information.

An example -- one, nasty, greedy process that uses so much space that
it could force the deactivation of nearly all of the other processes.
If you do that, it's unfair to too many processes.  If you deactivate
the hog, then every time you bring it back, it will cause heavy
paging, and a deactivation.  Ugh.

> We will not start reactivating processes until the swap load is
> below the threshold again (which is automatically a reasonable
> indication because it's a long-term floating average).

It's good that this load doesn't fluctuate too quickly.  However,
that's no guarantee that a re-activated process won't cause
overcommitment again (depending on which process was selected),
leading to a nasty oscilatting behavior.  What if the load doesn't
drop below the threshold for a long time?  Starvation is no fun,
especially if that was your process.

> Definately.  You can count on me to help think about these things
> and help testing, etc...

Delighted to hear it!  I have more questions than answers about this
problem, and I don't think it's been given sufficient attention
anywhere.  Correct me if I'm wrong (please!), but I think few modern
systems even *try* to detect overcommitment, let alone do something
about it.  It certainly seems that for some uses, a system should have
the option of saving the rest of the workload by unfairly sacrificing
some process.  (And for other uses, such actions would be less
acceptable.)

Scott Kaplan
sfkaplan@cs.amherst.edu
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.4 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE6w/rD8eFdWQtoOmgRAuF6AJoDeVidI3oSnmrRDCB1Da2Xz0z0bgCbBc3B
urJKhaoyDtMo/tLPaH4UrDo=
=p62R
-----END PGP SIGNATURE-----


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
