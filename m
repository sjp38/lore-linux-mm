Message-ID: <37F0E19E.55677E0E@nibiru.pauls.erfurt.thur.de>
Date: Tue, 28 Sep 1999 15:41:18 +0000
From: Enrico Weigelt <weigelt@nibiru.pauls.erfurt.thur.de>
Reply-To: weigelt@nibiru.pauls.erfurt.thur.de
MIME-Version: 1.0
Subject: Re: Dynamic Swap - How to do it ?
References: <37E98460.9731265@nibiru.pauls.erfurt.thur.de> <m1so3zg0sj.fsf@alogconduit1ai.ccr.net>
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Eric W. Biederman" wrote:
> 
> Enrico Weigelt <weigelt@nibiru.pauls.erfurt.thur.de> writes:
> 
> > hi folks,
> >
> > i've trying to develop a dynamic swap manager.
> >
<snip> 
> That is a feature.  In particular consider a rogue program.
> that (a) forks like crazy and (b) attempts to allocate and touch
> a visisble 3 GB.  Hostile programs will & should have problems.
> 
> > so it would be better, if these applications are blocked until the swap
> > deamon has allocated the memory or definitively can't/won't allocate it.
> 
> kill -SIGSTOP
the not really necessary, i think. the malloc() function in the kernel
(or however it's called.) blocks, until it get's memory or an timeout - 
just like the io functions block the process, if there's no data to read
from the input devices.

> If you reach the point where the kernel would be killing off tasks.
> You are too late.  The kernel must get memory or it can't function.
that's right. it needs memory. so there could be a reserved memory pool,
which is reserved for the mm. (also some outer parts of the kernel, like 
fs drivers,... could be blocked, if it's possible. 
only the mm and it's threads _must_ get accesss to this reserved pool 
to work.
ahh... i forgot: the filesystem _must_ _not_ be blocked! (otherwise
there's
no way to increase the swap. perhaps there are some drivers which could
be
blocked, but this decicion has the author of this driver...

> > but how should the kernel know which processes may be blocked and which
> > not. and how to reserve memory for the swap deamon ?
> > there should be a flag in the process status field, which tells the
> > kernel
> > that this process won't be affected by this - because it _manages_ this.
> > (let's say an process type MEMORY_MANAGER or something like that)
> > and there has to be some code in the kernel, which tells the swap deamon
> > when it's time to increase the swap sapce.
> >
> > what do you think about this ?
> 
> Implement it in user space first, and see how far you can go.
> The amount of swap space allocated is a policy question.
> Also consider mlockall (on the a statically linked daemon)
> so it doesn't page.
hmm. i already had a try. it doesn't satisfy me. if my applications
request much memory in a short time, if failed.
(started it on a machine with 16MB and no static swap ... started XF86
...
booom. got SEGFAULT. out of memory. )

> Also someone I forget who has played with this before
> so you might want to look around a little.
> 
> Eric

ew.

-------------------------------------------
lets go to another world ... oberon
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
