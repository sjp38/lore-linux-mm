Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DB4CE6B0078
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 05:16:11 -0500 (EST)
From: Lubos Lunak <l.lunak@suse.cz>
Subject: Re: Improving OOM killer
Date: Thu, 11 Feb 2010 11:16:07 +0100
References: <201002012302.37380.l.lunak@suse.cz> <201002102154.39771.l.lunak@suse.cz> <alpine.DEB.2.00.1002101405530.29007@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1002101405530.29007@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <201002111116.07211.l.lunak@suse.cz>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Wednesday 10 of February 2010, David Rientjes wrote:
> On Wed, 10 Feb 2010, Lubos Lunak wrote:
> >  Which is why I suggested summing up the memory of the parent and its
> > children.
>
> That's almost identical to the current heuristic where we sum half the
> size of the children's VM size, unfortunately it's not a good indicator of
> forkbombs since in your particular example it would be detrimental to
> kdeinit.

 I believe that with the algorithm no longer using VmSize and being careful 
not to count shared memory more than once this would not be an issue and 
kdeinit would be reasonably safe. KDE does not use _that_ much memory to 
score higher than something that caused OOM :).

> My heursitic considers runtime of the children as an indicator 
> of a forkbombing parent since such tasks don't typically get to run
> anyway.  The rss or swap usage of a child with a seperate address space
> simply isn't relevant to the badness score of the parent, it unfairly
> penalizes medium/large server jobs.

 Our definitions of 'forkbomb' then perhaps differ a bit. I 
consider 'make -j100' a kind of a forkbomb too, it will very likely overload 
the machine too as soon as the gcc instances use up all the memory. For that 
reason also using CPU time <1second will not work here, while using real time 
<1minute would.

 That long timeout would have the weakness that when running at the same time 
reasonable 'make -j4' and Firefox that'd immediatelly go crazy, then maybe 
the make job could be targeted instead if its total cost would go higher. 
However, here I again believe that the fixed metrics for computing memory 
usage would work well enough to let that happen only when the total cost of 
the make job would be actually higher than that of the offender and in that 
case it is kind of an offender too.

 Your protection seems to cover only "for(;;) if(fork() == 0) break;" , while 
I believe mine could handle also "make -j100" or the bash forkbomb ":()
{ :|:& };:" (i.e. "for(;;) fork();").

> > > We can't address recursive forkbombing in the oom killer with any
> > > efficiency, but luckily those cases aren't very common.
> >
> >  Right, I've never run a recursive make that brought my machine to its
> > knees. Oh, wait.
>
> That's completely outside the scope of the oom killer, though: it is _not_
> the oom killer's responsibility for enforcing a kernel-wide forkbomb
> policy

 Why? It repeatedly causes OOM here (and in fact it is the only common OOM or 
forkbomb I ever encounter). If OOM killer is the right place to protect 
against a forkbomb that spawns a large number of 1st level children, then I 
don't see how this is different.

> >  And why exactly is iterating over 1st level children efficient enough
> > and doing that recursively is not? I don't find it significantly more
> > expensive and badness() is hardly a bottleneck anyway.
>
> If we look at children's memory usage recursively, then we'll always end
> up selecting init_task.

 Not if the algorithm does not propagate the top of the problematic subtree 
higher, see my reply to Alan Cox.

> >  Why exactly do you think only 1st generation children matter? Look again
> > at the process tree posted by me and you'll see it solves nothing there.
> > I still fail to see why counting also all other generations should be
> > considered anything more than a negligible penalty for something that's
> > not a bottleneck at all.
>
> You're specifying a problem that is outside the scope of the oom killer,
> sorry.

 But it could be inside of the scope, since it causes OOM, and I don't think 
it's an unrealistic or rare use case. I don't consider it less likely than 
spawning a large number of direct children. If you want to cover only 
certified reasons for causing OOM, it can be as well said that userspace is 
not allowed to cause OOM at all.

-- 
 Lubos Lunak
 openSUSE Boosters team, KDE developer
 l.lunak@suse.cz , l.lunak@kde.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
