Subject: Re: Dynamic Swap - How to do it ?
References: <37E98460.9731265@nibiru.pauls.erfurt.thur.de>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 27 Sep 1999 22:41:48 -0500
In-Reply-To: Enrico Weigelt's message of "Thu, 23 Sep 1999 01:37:36 +0000"
Message-ID: <m1so3zg0sj.fsf@alogconduit1ai.ccr.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: weigelt@nibiru.pauls.erfurt.thur.de
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Enrico Weigelt <weigelt@nibiru.pauls.erfurt.thur.de> writes:

> hi folks,
> 
> i've trying to develop a dynamic swap manager.
> 
> i've written a little deamon which frequently reads the memory
> usage from /proc and adds swapfiles if necessary. but this doesn't
> really satisfy me. so i'd like to do it at kernel level,
> because there could be some critical situations:
> 
> what if an application (ore more) requests very much memory very fast - 
> more than the swap deamon's min-space-range ? then the swap deamon
> cant't increase the swapspace as fast as necessary and the application
> doesn't get the memory - in the worst case the app doesnt care about it,
> tries to access the (not allocated) memory and gets an SIGSEG.

That is a feature.  In particular consider a rogue program.
that (a) forks like crazy and (b) attempts to allocate and touch
a visisble 3 GB.  Hostile programs will & should have problems.

> so it would be better, if these applications are blocked until the swap
> deamon has allocated the memory or definitively can't/won't allocate it.

kill -SIGSTOP

If you reach the point where the kernel would be killing off tasks.
You are too late.  The kernel must get memory or it can't function.

> 
> but how should the kernel know which processes may be blocked and which 
> not. and how to reserve memory for the swap deamon ?
> there should be a flag in the process status field, which tells the
> kernel
> that this process won't be affected by this - because it _manages_ this.
> (let's say an process type MEMORY_MANAGER or something like that)
> and there has to be some code in the kernel, which tells the swap deamon
> when it's time to increase the swap sapce.
> 
> what do you think about this ?

Implement it in user space first, and see how far you can go.
The amount of swap space allocated is a policy question.
Also consider mlockall (on the a statically linked daemon)
so it doesn't page.

Also someone I forget who has played with this before
so you might want to look around a little.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
