Message-Id: <200010092208.e99M8CE14230@eng2.sequent.com>
Reply-To: Gerrit.Huizenga@us.ibm.com
From: Gerrit.Huizenga@us.ibm.com
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler 
In-reply-to: Your message of Mon, 09 Oct 2000 18:05:57 -0300.
             <Pine.LNX.4.21.0010091759400.1562-100000@duckman.distro.conectiva>
Date: Mon, 09 Oct 2000 15:08:12 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

At Sequent, we found that there are a small set of processes which are
"critical" to the system's operation in that they should not be killed
on swap shortage, memory shortage, etc.  This included things like init,
potentially inetd, the swapper, page daemon, clusters heartbeat daemon,
and generally any core system service which had a user process component.
If there wasn't enough memory for those processes, or if those processes
weren't already responsible in their use of memory/resources, you were
already toast.

Anyway, there is/was an API in PTX to say (either from in-kernel or through
some user machinations) "I Am a System Process".  Turns on a bit in the
proc struct (task struct) that made it exempt from death from a variety
of sources, e.g. OOM, generic user signals, portions of system shutdown,
etc.

Then, the code looking for things to kill simply skips those that are
intelligently marked, taking most of the decision making/policy making
out of the scheduler/memory manager.

gerrit

> On Mon, 9 Oct 2000, Linus Torvalds wrote:
> > On Mon, 9 Oct 2000, Andi Kleen wrote:
> > > 
> > > netscape usually has child processes: the dns helper. 
> > 
> > Yeah.
> > 
> > One thing we _can_ (and probably should do) is to do a per-user
> > memory pressure thing - we have easy access to the "struct
> > user_struct" (every process has a direct pointer to it), and it
> > should not be too bad to maintain a per-user "VM pressure"
> > counter.
> > 
> > Then, instead of trying to use heuristics like "does this
> > process have children" etc, you'd have things like "is this user
> > a nasty user", which is a much more valid thing to do and can be
> > used to find people who fork tons of processes that are
> > mid-sized but use a lot of memory due to just being many..
> 
> Sure we could do all of this, but does OOM really happen that
> often that we want to make the algorithm this complex ?
> 
> The current algorithm seems to work quite well and is already
> at the limit of how complex I'd like to see it. Having a less
> complex OOM killer turned out to not work very well, but having
> a more complex one is - IMHO - probably overkill ...
> 
> regards,
> 
> Rik
> --
> "What you're running that piece of shit Gnome?!?!"
>        -- Miguel de Icaza, UKUUG 2000
> 
> http://www.conectiva.com/		http://www.surriel.com/
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
