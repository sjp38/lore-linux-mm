Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F2A1D6B004D
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 20:41:52 -0500 (EST)
Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id o131flWN025896
	for <linux-mm@kvack.org>; Tue, 2 Feb 2010 17:41:48 -0800
Received: from pxi30 (pxi30.prod.google.com [10.243.27.30])
	by spaceape13.eur.corp.google.com with ESMTP id o131fQRO008458
	for <linux-mm@kvack.org>; Tue, 2 Feb 2010 17:41:46 -0800
Received: by pxi30 with SMTP id 30so725562pxi.14
        for <linux-mm@kvack.org>; Tue, 02 Feb 2010 17:41:45 -0800 (PST)
Date: Tue, 2 Feb 2010 17:41:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Improving OOM killer
In-Reply-To: <201002022210.06760.l.lunak@suse.cz>
Message-ID: <alpine.DEB.2.00.1002021643240.3393@chino.kir.corp.google.com>
References: <201002012302.37380.l.lunak@suse.cz> <alpine.DEB.2.00.1002011523280.19457@chino.kir.corp.google.com> <201002022210.06760.l.lunak@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lubos Lunak <l.lunak@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Feb 2010, Lubos Lunak wrote:

> > > init
> > >   |- kdeinit
> > >   |  |- ksmserver
> > >   |  |  |- kwin
> > >   |  |- <other>
> > >   |- konsole
> > >      |- make
> > >         |- sh
> > >         |  |- meinproc4
> > >         |- sh
> > >         |  |- meinproc4
> > >         |- <etc>
> > >
> > >  What happens is that OOM killer usually selects either ksmserver (KDE
> > > session manager) or kdeinit (KDE master process that spawns most KDE
> > > processes). Note that in either case OOM killer does not reach the point
> > > of killing the actual offender - it will randomly kill in the tree under
> > > kdeinit until it decides to kill ksmserver, which means terminating the
> > > desktop session. As konsole is a KUniqueApplication, it forks into
> > > background and gets reparented to init, thus getting away from the
> > > kdeinit subtree. Since the memory pressure is distributed among several
> > > meinproc4 processes, the badness does not get summed up in its make
> > > grandparent, as badness() does this only for direct parents.
> >
> > There's no randomness involved in selecting a task to kill;
> 
>  That was rather a figure of speech, but even if you want to take it 
> literally, then from the user's point of view it is random. Badness of 
> kdeinit depends on the number of children it has spawned, badness of 
> ksmserver depends for example on the number and size of windows open (as its 
> child kwin is a window and compositing manager).
> 

As I've mentioned, I believe Kame (now cc'd) is working on replacing the 
heuristic that adds the VM size for children into the parent task's 
badness score with a forkbomb detector.  That should certainly help to 
reduce oom killing for parents whose children consume a lot of memory, 
especially in your scenario where kdeinit is responsible for forking most 
KDE processes.

>  Not that it really matters - the net result is that OOM killer usually 
> decides to kill kdeinit or ksmserver, starts killing their children, vital 
> KDE processes, and since the offenders are not among them, it ends up either 
> terminating the whole session by killing ksmserver or killing enough vital 
> processes there to free enough memory for the offenders to finish their work 
> cleanly.
> 

The kernel cannot possibly know what you consider a "vital" process, for 
that understanding you need to tell it using the very powerful 
/proc/pid/oom_adj tunable.  I suspect if you were to product all of 
kdeinit's children by patching it to be OOM_DISABLE so that all threads it 
forks will inherit that value you'd actually see much improved behavior.  
I'd also encourage you to talk to the KDE developers to ensure that proper 
precautions are taken to protect it in such conditions since people who 
use such desktop environments typically don't want them to be sacrificed 
for memory.  The kernel, however, can only provide a mechanism for users 
to define what they believe to be critical since it will vary widely 
depending on how Linux is used for desktops, servers, and embedded 
devices.  Our servers, for example, have vital threads that are running on 
each machine and they need to be protected in the same way.  They set 
themselves to be OOM_DISABLE.

On a side note, it's only possible to lower an oom_adj value for a thread 
if you have CAP_SYS_RESOURCE.  So that would be a prerequisite to setting 
OOM_DISABLE for any thread.  If that's not feasible, there's a workaround: 
user tasks can always increase their own oom_adj value so that they are 
always preferred in oom conditions.  This will act to protect those vital 
tasks by preempting them from getting oom killed without any special 
capability.

> > The process tree that you posted shows a textbook case for using
> > /proc/pid/oom_adj to ensure a critical task, such as kdeinit is to you, is
> > protected from getting selected for oom kill.  In your own words, this
> > "spawns most KDE processes," so it's an ideal place to set an oom_adj
> > value of OOM_DISABLE since that value is inheritable to children and,
> > thus, all children are implicitly protected as well.
> 
>  Yes, it's a textbook case, sadly textbook cases are theory and not practice. 
> I didn't mention it in my first mail to keep it shorter, but we have actually 
> tried it. First of all, it's rather cumbersome - as it requires root 
> priviledges, there is one wrapped needed for setuid and another one to avoid 
> setuid side-effects, moreover the setuid root process needs to stay running 
> and unset the protection on all children, or it'd be useless again.
> 

It only requires CAP_SYS_RESOURCE, actually, and your apparent difficulty 
in writing to a kernel tunable is outside the scope of this discussion, 
unfortunately.  The bottomline is that the kernel provides a very well 
defined interface for tuning the oom killer's badness heuristic so that 
userspace can define what is "vital," whether that is kdeinit, ksmserver, 
or any other thread.  The choice needs to be made to use it, however.

>  Worse, it worked for about a year or two and now it has only shifted the 
> problem elsewhere and that's it. We now protect kdeinit, which means the OOM 
> killer's choice will very likely ksmserver then. Ok, so let's say now we 
> start protecting also ksmserver, that's some additional hassle setting it up, 
> but that's doable. Now there's a good chance the OOM killer's choice will be 
> kwin (as a compositing manager it can have quite large mappings because of 
> graphics drivers). So ok, we need to protect the window manager, but since 
> that's not a hardcoded component like ksmserver, that's even more hassle.
> 

No, you don't need to protect every KDE process from the oom killer unless 
it is going to be a contender for selection.  You could certainly do so 
for completeness, but it shouldn't be required unless the nature of the 
thread demands it such that it forks many vital tasks (kdeinit) or its 
first-generation children's memory consumption can't be known either 
because it depends on how many children it can fork or their memory 
consumption is influenced by the user's work.

> > Using VmSize, however, allows us to define the most important task to kill
> > for the oom killer: memory leakers.  Memory leakers are the single most
> > important tasks to identify with the oom killer and aren't obvious when
> > using rss because leaked memory does not stay resident in RAM.  I
> > understand your system may not have such a leaker and it is simply
> > overcommitted on a 2GB machine, but using rss loses that ability.
> 
>  Interesting point. Am I getting it right that you're saying that VmRSS is 
> unsuitable because badness should take into account not only the RAM used by 
> the process but also the swap space used by the process? If yes, then this 
> rather brings up the question why doesn't the badness calculation then do it 
> and uses VmSize instead?
> 

We don't want to discount VM_RESERVED because the memory it represents 
cannot be swapped, which is also an important indicator of the overall 
memory usage of any particular application.  I understand that your 
particular use case may benefit from waiting on block congestion during 
the page allocation that triggered the oom killer without making any 
progress in direct reclaim, but discounting VM_RESERVED because of its 
(sometimes erroneous) use with VM_IO isn't an appropriate indicator of the 
thread's memory use since we're not considering the amount mapped for I/O.

>  I mean, as already demonstrated in the original mail, VmSize clearly can be 
> very wrong as a representation of memory used. I would actually argue that 
> VmRSS is still better, as the leaker would eventually fill the swap and start 
> taking up RAM, but either way, how about this then?
> 

We simply can't afford to wait for a memory leaker to fill up all of swap 
before the heuristic works to identify it, that would be extremely slow 
depending on the speed of I/O and would actually increase the probability 
of needlessly killing the wrong task because the memory leaker will fill 
up all of swap while other tasks get killed because they have a large rss.  
That heuristic works antagonist to finding the memory leaker since it will 
always keep its rss low since that memory will never be touched again once 
it is leaked.

>  Hmm, maybe you're thinking server setup and that's different, I don't know. 
> Does the kernel have any "desktop mode"? I wouldn't mind if VmSize was used 
> on servers if you insist it is better, but on desktop VmSize is just plain 
> wrong. And, again, I think VmRSS+InSwap is better then either.
> 

The heuristics are always well debated in this forum and there's little 
chance that we'll ever settle on a single formula that works for all 
possible use cases.  That makes oom_adj even more vital to the overall 
efficiency of the oom killer, I really hope you start to use it to your 
advantage.

There are a couple of things that we'll always agree on: its needless to 
kill a task that shares a different set of allowed nodes than the 
triggering page allocation, for example, since it cannot access that 
memory even if freed, and there should be some penalty for tasks that have 
a shorter uptime to break ties.  I agree that most of the penalties as 
currently implemented, however, aren't scientific and don't appropriately 
adjust the score in those cases.  Dividing the entire VM size by 2, for 
example, because the task has a certain trait isn't an ideal formula.

There's also at least one thing that we'd both like to remove: the 
factoring of each child's VM size into the badness score for the parent as 
a way of detecting a forkbomb.  Kame has been working on the forkbomb 
detector specifically to address this issue, so we should stay tuned.

The one thing that I must stress, however, is the need for us to be able 
to define what a "vital" task is and to define what a "memory leaker" is.  
Both of those are currently possible with oom_adj, so we cannot loose this 
functionality.  Changing the baseline to be rss would be highly dynamic 
and not allow us to accurately set an oom_adj value to define when a task 
is rogue on a shared system.

That said, I don't think a complete rewrite of the badness function would 
be a non-starter: we could easily make all tasks scale to have a badness 
score ranging from 0 (never kill) to 1000 (always kill), for example.  We 
just need to propose a sane set of heuristics so that we don't lose the 
configurability from userspace.

I've also disagreed before with always killing the most memory consuming 
task whenever we have an oom.  I agree with you that sometimes that task 
may be the most vital to the system and setting it to be OOM_DISABLE 
should not always be required for a simple order-0 allocation that fails 
somewhere, especially if its ~__GFP_NOFAIL.  What I've recommended to you 
would work with current mainline and at least kernels released within the 
past few years, but I think there may be many more changes we can look to 
make in the future.

> > the consumer of the largest amount 
> > of rss is not necessarily the task we always want to kill.  Just because
> > an order-0 page allocation fails does not mean we want to kill the task
> > that would free the largest amount of RAM.
> 
>  It's still much better than killing the task that would free the largest 
> amount of address space. And I cannot think of any better metric than 
> VmRSS+InSwap. Can you?
> 

Yes, baselining on total_vm so that we understand the total amount of 
memory that will no longer be mapped to that particular process if killed, 
regardless if its a shared library or not, so that we can define vital 
tasks and memory leakers from userspace.

> > I understand that KDE is extremely important to your work environment and
> > if you lose it, it seems like a failure of Linux and the VM.  However, the
> > kernel cannot possibly know what applications you believe to be the most
> > important.  For that reason, userspace is able to tune the badness() score
> > by writing to /proc/pid/oom_adj as I've suggested you do for kdeinit.  You
> > have the ability to protect KDE from getting oom killed, you just need to
> > use it.
> 
>  As already explained, I can't. Besides, I'm not expecting a miracle, I simply 
> expect the kernel to kill the process that takes up the most memory, and the 
> kernel can possibly know that, it just doesn't do it. What other evidence do 
> you want to be shown that badness calculated for two processes on their 
> actual memory usage differs by a multiple of 5 or more?
> 

This is highly likely related to the child VM sizes being accumulated in 
the parent's badness score, we'll have to see how your results vary once 
the forkbomb detector is merged.  I disagree that we always need to kill 
the application consuming the most memory, though, we need to determine 
when it's better to simply fail a ~__GFP_NOFAIL allocation and when 
killing a smaller, lower priority task may be more beneficial to the 
user's work.

> > Right, I believe Kame is working on a forkbomb detector that would replace
> > this logic.
> 
>  Until then, can we dump the current code? Because I have provided one case 
> where it makes things worse and nobody has provided any case where it makes 
> things better or any other justification for its existence. There's no point 
> in keeping code for which nobody knows how it improves things (in reality, 
> not some textbook case).
> 

First of all, I don't think the forkbomb detector is that far in the 
future since a preliminary version of it was also posted, but I think we 
also need a way to address those particular cases in the heuristic.  There 
are real-life cases where out of memory conditions occur specifically 
because of forkbombs so not addressing the issue in the heuristic in some 
way is not appropriate.

>  And, in case the justification for it is something like "Apache", can we 
> fast-forward to my improved suggestion to limit this only to children that 
> are forked but not exec()-ed?
> 

The amount of memory you'll be freeing in simply killing such tasks will 
be minimal, I don't think that's an appropriate heuristic if they all 
share their memory with the parent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
