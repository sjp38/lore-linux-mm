Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: shared pagetable benchmarking
Date: Fri, 27 Dec 2002 16:59:09 +0100
References: <3E02FACD.5B300794@digeo.com> <E18RqyB-0001ui-00@starship> <3E0C2462.ADF727C7@digeo.com>
In-Reply-To: <3E0C2462.ADF727C7@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E18RwtV-0001up-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, Daniel Phillips <phillips@arcor.de>
Cc: Dave McCracken <dmccr@us.ibm.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

On Friday 27 December 2002 10:58, Andrew Morton wrote:
> > A feature of my original demonstration patch was that I could
> > enable/disable sharing with a per-fork granularity.  This is a good
> > thing.  You can use this by detecting the case you can't optimize, i.e.,
> > forking from bash, and essentially using the old code.  The sawoff for
> > improved efficiency comes in somewhere over 4 meg worth of shared memory,
> > which just doesn't happen in fork+exec from bash.  Then there is
> > always-unshare situation with the stack, which I'm sure you're aware of,
> > where it's never worth doing the share.
>
> Yes, Dave did a prototype of that, and I am sure that it will pull back
> the small additional cost of pagetable sharing in those cases.
>
> But that's not the problem.  The problem is that it doesn't *speed up*
> that case.  Which appears to be the only thing which interests Linus
> in shared pagetables at this time: he "_hate_"s the fact that fork/exec
> got slower.

Did you ask Linus?  To my thinking, if it breaks even on small forks and wins
on the big forks that are bothering the database people etc (and aren't we 
all database people in the end) it's a clear win.

> > That said, was not Ingo working on a replacement for fork+exec that
> > doesn't do the useless fork?  Would this not make the vast majority of
> > impossible-to-optimize cases go away?
>
> That's news to me.
>
> posix_spawn() has been suggested by Ulrich, and he says that things like
> bash could easily be converted.

Yes, that's the reference.  I somehow got Ingo mixed in there because they 
were doing the thread cleanups together at the time, which quite possibly 
inspired that rather badly needed improvement.

> I don't how much it would gain - possibly not a huge amount; the rmap
> setup in exec seems to be where the major cost lies.  Plus there's still
> exit().

What you'd lose is the useless setup/teardown of three page table pages every 
fork+exec, a good thing regardless of page table sharing, but especially 
convenient for sharing, as it carves away a good percentage of the 
non-improved cases, allowing the improved ones to stand out more.

Anyway, I'll bow out of the rmap-optimizing game until next cycle.  There are 
still some nice optimizations that can be done, but what's the hurry?  There 
is plenty of longstanding kernel badness that dwarves this in importance 
(knfsd comes to mind).  I am just glad that rmap has stuck, as I am very 
happy to trade a few percentage points of speed in some applications that 
suck by design, in return for a VM that actually gives BSD a run for its 
money in terms of stability.

I guess that if pte sharing doesn't make it into Linus's tree then Redhat 
will be only too pleased to make it part of Advanced Server, as there are a 
couple of ridiculously big tech companies I could name that need it so badly 
it hurts.

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
