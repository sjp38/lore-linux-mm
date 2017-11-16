Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 537FE6B0276
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 19:05:07 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id i89so6611091pfj.9
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 16:05:07 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id n10si18160605plk.132.2017.11.15.16.05.04
        for <linux-mm@kvack.org>;
        Wed, 15 Nov 2017 16:05:04 -0800 (PST)
Date: Thu, 16 Nov 2017 09:04:56 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH] locking/Documentation: Revise
 Documentation/locking/crossrelease.txt
Message-ID: <20171116000456.GB4394@X58A-UD3R>
References: <1510406792-28676-1-git-send-email-byungchul.park@lge.com>
 <1510407214-31452-1-git-send-email-byungchul.park@lge.com>
 <20171111134524.GA16714@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171111134524.GA16714@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com

On Sat, Nov 11, 2017 at 10:45:24PM +0900, Byungchul Park wrote:
> This is the big one including all of version 3.
> 
> You can take only this.

Hello Ingo,

Could you consider this?

I want to offer a better base to someone who helps the doc enhanced. Of
course, in the case you agree with this modification..

I did my best to keep meaningful original contents as much as possible.

Give your opinion, please.

Thanks,
Byungchul

> Thanks,
> Byungchul
> 
> On Sat, Nov 11, 2017 at 10:33:34PM +0900, Byungchul Park wrote:
> > Revise Documentation/locking/crossrelease.txt to improve its readability.
> > 
> > Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> > ---
> >  Documentation/locking/crossrelease.txt | 329 ++++++++++++++++-----------------
> >  1 file changed, 155 insertions(+), 174 deletions(-)
> > 
> > diff --git a/Documentation/locking/crossrelease.txt b/Documentation/locking/crossrelease.txt
> > index bdf1423..c6d628b 100644
> > --- a/Documentation/locking/crossrelease.txt
> > +++ b/Documentation/locking/crossrelease.txt
> > @@ -12,10 +12,10 @@ Contents:
> >  
> >   (*) Limitation
> >  
> > -     - Limit lockdep
> > +     - Limiting lockdep
> >       - Pros from the limitation
> >       - Cons from the limitation
> > -     - Relax the limitation
> > +     - Relaxing the limitation
> >  
> >   (*) Crossrelease
> >  
> > @@ -30,9 +30,9 @@ Contents:
> >   (*) Optimizations
> >  
> >       - Avoid duplication
> > -     - Lockless for hot paths
> > +     - Make hot paths lockless
> >  
> > - (*) APPENDIX A: What lockdep does to work aggresively
> > + (*) APPENDIX A: What lockdep does to work aggressively
> >  
> >   (*) APPENDIX B: How to avoid adding false dependencies
> >  
> > @@ -55,21 +55,21 @@ For example:
> >     A context going to trigger event A is waiting for event B to happen.
> >     A context going to trigger event B is waiting for event C to happen.
> >  
> > -A deadlock occurs when these three wait operations run at the same time,
> > +A deadlock occurs when these three waiters run at the same time,
> >  because event C cannot be triggered if event A does not happen, which in
> >  turn cannot be triggered if event B does not happen, which in turn
> >  cannot be triggered if event C does not happen. After all, no event can
> >  be triggered since any of them never meets its condition to wake up.
> >  
> > -A dependency might exist between two waiters and a deadlock might happen
> > -due to an incorrect releationship between dependencies. Thus, we must
> > -define what a dependency is first. A dependency exists between them if:
> > +A dependency might exist between two waiters and a deadlock happens due
> > +to an incorrect relationship between dependencies. Thus, we must define
> > +what a dependency is first. A dependency exists if:
> >  
> >     1. There are two waiters waiting for each event at a given time.
> >     2. The only way to wake up each waiter is to trigger its event.
> >     3. Whether one can be woken up depends on whether the other can.
> >  
> > -Each wait in the example creates its dependency like:
> > +Each waiter in the example creates its dependency like:
> >  
> >     Event C depends on event A.
> >     Event A depends on event B.
> > @@ -77,7 +77,7 @@ Each wait in the example creates its dependency like:
> >  
> >     NOTE: Precisely speaking, a dependency is one between whether a
> >     waiter for an event can be woken up and whether another waiter for
> > -   another event can be woken up. However from now on, we will describe
> > +   another event can be woken up. However, from now on, we will describe
> >     a dependency as if it's one between an event and another event for
> >     simplicity.
> >  
> > @@ -109,9 +109,9 @@ event in the previous section.
> >  In short, lockdep does:
> >  
> >     1. Detect a new dependency.
> > -   2. Add the dependency into a global graph.
> > +   2. Add the dependency to a global graph.
> >     3. Check if that makes dependencies circular.
> > -   4. Report a deadlock or its possibility if so.
> > +   4. Report the deadlock or its possibility if so.
> >  
> >  For example, consider a graph built by lockdep that looks like:
> >  
> > @@ -123,7 +123,7 @@ For example, consider a graph built by lockdep that looks like:
> >  
> >     where A, B,..., E are different lock classes.
> >  
> > -Lockdep will add a dependency into the graph on detection of a new
> > +Lockdep will add a dependency to the graph on detection of a new
> >  dependency. For example, it will add a dependency 'E -> C' when a new
> >  dependency between lock E and lock C is detected. Then the graph will be:
> >  
> > @@ -147,7 +147,7 @@ This graph contains a subgraph which demonstrates circular dependencies:
> >     \                  /
> >      ------------------
> >  
> > -   where C, D and E are different lock classes.
> > +   where C, D, and E are different lock classes.
> >  
> >  This is the condition under which a deadlock might occur. Lockdep
> >  reports it on detection after adding a new dependency. This is the way
> > @@ -163,13 +163,13 @@ dependencies were created after adding each new dependency.
> >  Limitation
> >  ==========
> >  
> > -Limit lockdep
> > --------------
> > +Limiting lockdep
> > +----------------
> >  
> >  Limiting lockdep to work on only typical locks e.g. spin locks and
> > -mutexes, which are released within the acquire context, the
> > +mutexes, which are released within their acquire contexts, the
> >  implementation becomes simple but its capacity for detection becomes
> > -limited. Let's check pros and cons in next section.
> > +limited. Let's check pros and cons in the next two sections.
> >  
> >  
> >  Pros from the limitation
> > @@ -179,7 +179,7 @@ Given the limitation, when acquiring a lock, locks in a held_locks
> >  cannot be released if the context cannot acquire it so has to wait to
> >  acquire it, which means all waiters for the locks in the held_locks are
> >  stuck. It's an exact case to create dependencies between each lock in
> > -the held_locks and the lock to acquire.
> > +the held_locks and the lock to acquire at the moment.
> >  
> >  For example:
> >  
> > @@ -195,22 +195,22 @@ For example:
> >  When acquiring lock A, the held_locks of CONTEXT X is empty thus no
> >  dependency is added. But when acquiring lock B, lockdep detects and adds
> >  a new dependency 'A -> B' between lock A in the held_locks and lock B.
> > -They can be simply added whenever acquiring each lock.
> > +Dependencies can be simply added this way, whenever acquiring each lock.
> >  
> > -And data required by lockdep exists in a local structure, held_locks
> > -embedded in task_struct. Forcing to access the data within the context,
> > -lockdep can avoid racy problems without explicit locks while handling
> > -the local data.
> > +Furthermore, since data required to create a dependency can be kept in
> > +local task_struct, lockdep can avoid racy problems without explicit
> > +protection by forcing to access the data within the context.
> >  
> >  Lastly, lockdep only needs to keep locks currently being held, to build
> > -a dependency graph. However, relaxing the limitation, it needs to keep
> > -even locks already released, because a decision whether they created
> > +the dependency graph. However, relaxing the limitation, it needs to keep
> > +even locks already released, because the decision whether they created
> >  dependencies might be long-deferred.
> >  
> >  To sum up, we can expect several advantages from the limitation:
> >  
> >     1. Lockdep can easily identify a dependency when acquiring a lock.
> > -   2. Races are avoidable while accessing local locks in a held_locks.
> > +   2. Races are avoidable without explicit protection while accessing
> > +      local locks in a held_locks.
> >     3. Lockdep only needs to keep locks currently being held.
> >  
> >  CONCLUSION
> > @@ -265,8 +265,8 @@ Given the limitation, lockdep cannot detect a deadlock or its
> >  possibility caused by page locks or completions.
> >  
> >  
> > -Relax the limitation
> > ---------------------
> > +Relaxing the limitation
> > +-----------------------
> >  
> >  Under the limitation, things to create dependencies are limited to
> >  typical locks. However, synchronization primitives like page locks and
> > @@ -278,37 +278,36 @@ these locks to work with lockdep.
> >  Detecting dependencies is very important for lockdep to work because
> >  adding a dependency means adding an opportunity to check whether it
> >  causes a deadlock. The more lockdep adds dependencies, the more it
> > -thoroughly works. Thus Lockdep has to do its best to detect and add as
> > -many true dependencies into a graph as possible.
> > +thoroughly works. Thus, lockdep has to do its best to detect and add as
> > +many true dependencies to the graph as possible.
> >  
> > -For example, considering only typical locks, lockdep builds a graph like:
> > +For example:
> >  
> > -   A -> B -
> > -           \
> > -            -> E
> > -           /
> > -   C -> D -
> > +   CONTEXT X			   CONTEXT Y
> > +   ---------			   ---------
> > +				   acquire A
> > +   acquire B /* A dependency 'A -> B' exists */
> > +   release B
> > +   release A held by Y
> >  
> > -   where A, B,..., E are different lock classes.
> > +   where A and B are different lock classes.
> >  
> > -On the other hand, under the relaxation, additional dependencies might
> > -be created and added. Assuming additional 'FX -> C' and 'E -> GX' are
> > -added thanks to the relaxation, the graph will be:
> > +In this case, a dependency 'A -> B' exists since:
> >  
> > -         A -> B -
> > -                 \
> > -                  -> E -> GX
> > -                 /
> > -   FX -> C -> D -
> > +   1. A waiter for A and a waiter for B might exist when acquiring B.
> > +   2. The only way to wake up each is to release what it waits for.
> > +   3. Whether the waiter for A can be woken up depends on whether the
> > +      other can. In other words, CONTEXT X cannot release A if it fails
> > +      to acquire B.
> >  
> > -   where A, B,..., E, FX and GX are different lock classes, and a suffix
> > -   'X' is added on non-typical locks.
> > +Considering only typical locks, lockdep builds nothing. However,
> > +relaxing the limitation, a dependency 'A -> B' can be added, giving us
> > +more chances to check circular dependencies.
> >  
> > -The latter graph gives us more chances to check circular dependencies
> > -than the former. However, it might suffer performance degradation since
> > -relaxing the limitation, with which design and implementation of lockdep
> > -can be efficient, might introduce inefficiency inevitably. So lockdep
> > -should provide two options, strong detection and efficient detection.
> > +However, it might suffer performance degradation since relaxing the
> > +limitation, with which design and implementation of lockdep can be
> > +efficient, might introduce inefficiency inevitably. So lockdep should
> > +provide two options, strong detection and efficient detection.
> >  
> >  Choosing efficient detection:
> >  
> > @@ -336,27 +335,27 @@ Introduce crossrelease
> >  In order to allow lockdep to handle additional dependencies by what
> >  might be released in any context, namely 'crosslock', we have to be able
> >  to identify those created by crosslocks. The proposed 'crossrelease'
> > -feature provoides a way to do that.
> > +feature provides a way to do that.
> >  
> >  Crossrelease feature has to do:
> >  
> >     1. Identify dependencies created by crosslocks.
> > -   2. Add the dependencies into a dependency graph.
> > +   2. Add the dependencies to the dependency graph.
> >  
> > -That's all. Once a meaningful dependency is added into graph, then
> > +That's all. Once a meaningful dependency is added to the graph, then
> >  lockdep would work with the graph as it did. The most important thing
> >  crossrelease feature has to do is to correctly identify and add true
> > -dependencies into the global graph.
> > +dependencies to the global graph.
> >  
> >  A dependency e.g. 'A -> B' can be identified only in the A's release
> >  context because a decision required to identify the dependency can be
> >  made only in the release context. That is to decide whether A can be
> > -released so that a waiter for A can be woken up. It cannot be made in
> > +released so that waiters for A can be woken up. That cannot be made in
> >  other than the A's release context.
> >  
> >  It's no matter for typical locks because each acquire context is same as
> >  its release context, thus lockdep can decide whether a lock can be
> > -released in the acquire context. However for crosslocks, lockdep cannot
> > +released in the acquire context. However, for crosslocks, lockdep cannot
> >  make the decision in the acquire context but has to wait until the
> >  release context is identified.
> >  
> > @@ -375,10 +374,11 @@ Introduce commit
> >  ----------------
> >  
> >  Since crossrelease defers the work adding true dependencies of
> > -crosslocks until they are actually released, crossrelease has to queue
> > +crosslocks until they are eventually released, crossrelease has to queue
> >  all acquisitions which might create dependencies with the crosslocks.
> > -Then it identifies dependencies using the queued data in batches at a
> > -proper time. We call it 'commit'.
> > +Then lockdep can identify dependencies using the queued data in batches
> > +at a proper time. We call the step adding true dependencies to the graph
> > +in batches, 'commit'.
> >  
> >  There are four types of dependencies:
> >  
> > @@ -404,10 +404,10 @@ There are four types of dependencies:
> >  
> >     When acquiring BX, lockdep cannot identify the dependency because
> >     there's no way to know if it's in the AX's release context. It has
> > -   to wait until the decision can be made. Commit is necessary.
> > -   But, handling CC type is not implemented yet. It's a future work.
> > +   to wait until the decision can be made. Commit is necessary. But,
> > +   handling CC type is not implemented yet. It's a future work.
> >  
> > -Lockdep can work without commit for typical locks, but commit step is
> > +Lockdep can work without commit for typical locks, but the step is
> >  necessary once crosslocks are involved. Introducing commit, lockdep
> >  performs three steps. What lockdep does in each step is:
> >  
> > @@ -416,7 +416,7 @@ performs three steps. What lockdep does in each step is:
> >     it at the commit step. For crosslocks, it saves data which will be
> >     used at the commit step and increases a reference count for it.
> >  
> > -2. Commit: No action is reauired for typical locks. For crosslocks,
> > +2. Commit: No action is required for typical locks. For crosslocks,
> >     lockdep adds CT type dependencies using the data saved at the
> >     acquisition step.
> >  
> > @@ -442,9 +442,9 @@ Crossrelease introduces two main data structures.
> >  
> >     This is an array embedded in task_struct, for keeping lock history so
> >     that dependencies can be added using them at the commit step. Since
> > -   it's local data, it can be accessed locklessly in the owner context.
> > -   The array is filled at the acquisition step and consumed at the
> > -   commit step. And it's managed in circular manner.
> > +   they are local data, they can be accessed locklessly in the owner
> > +   context. The array is filled at the acquisition step and consumed at
> > +   the commit step. And it's managed in a circular manner.
> >  
> >  2. cross_lock
> >  
> > @@ -456,29 +456,24 @@ How crossrelease works
> >  ----------------------
> >  
> >  It's the key of how crossrelease works, to defer necessary works to an
> > -appropriate point in time and perform in at once at the commit step.
> > -Let's take a look with examples step by step, starting from how lockdep
> > -works without crossrelease for typical locks.
> > +appropriate point in time and perform the works at the commit step.
> > +
> > +Let's take a look at examples step by step, starting from how lockdep
> > +works for typical locks, without crossrelease.
> >  
> > -   acquire A /* Push A onto held_locks */
> > -   acquire B /* Push B onto held_locks and add 'A -> B' */
> > -   acquire C /* Push C onto held_locks and add 'B -> C' */
> > +   acquire A /* Push A to held_locks */
> > +   acquire B /* Push B to held_locks and add 'A -> B' */
> > +   acquire C /* Push C to held_locks and add 'B -> C' */
> >     release C /* Pop C from held_locks */
> >     release B /* Pop B from held_locks */
> >     release A /* Pop A from held_locks */
> >  
> > -   where A, B and C are different lock classes.
> > +   where A, B, and C are different lock classes.
> >  
> > -   NOTE: This document assumes that readers already understand how
> > -   lockdep works without crossrelease thus omits details. But there's
> > -   one thing to note. Lockdep pretends to pop a lock from held_locks
> > -   when releasing it. But it's subtly different from the original pop
> > -   operation because lockdep allows other than the top to be poped.
> > +Lockdep adds 'the top of held_locks -> the lock to acquire' dependency
> > +every time acquiring a lock.
> >  
> > -In this case, lockdep adds 'the top of held_locks -> the lock to acquire'
> > -dependency every time acquiring a lock.
> > -
> > -After adding 'A -> B', a dependency graph will be:
> > +After adding 'A -> B', the dependency graph will be:
> >  
> >     A -> B
> >  
> > @@ -488,15 +483,15 @@ And after adding 'B -> C', the graph will be:
> >  
> >     A -> B -> C
> >  
> > -   where A, B and C are different lock classes.
> > +   where A, B, and C are different lock classes.
> >  
> > -Let's performs commit step even for typical locks to add dependencies.
> > -Of course, commit step is not necessary for them, however, it would work
> > -well because this is a more general way.
> > +Let's build the graph using the commit step with the same example. Of
> > +course, the step is not necessary for typical locks, however, it would
> > +also work because this is a more general way.
> >  
> >     acquire A
> >     /*
> > -    * Queue A into hist_locks
> > +    * Queue A in hist_locks
> >      *
> >      * In hist_locks: A
> >      * In graph: Empty
> > @@ -504,7 +499,7 @@ well because this is a more general way.
> >  
> >     acquire B
> >     /*
> > -    * Queue B into hist_locks
> > +    * Queue B in hist_locks
> >      *
> >      * In hist_locks: A, B
> >      * In graph: Empty
> > @@ -512,7 +507,7 @@ well because this is a more general way.
> >  
> >     acquire C
> >     /*
> > -    * Queue C into hist_locks
> > +    * Queue C in hist_locks
> >      *
> >      * In hist_locks: A, B, C
> >      * In graph: Empty
> > @@ -554,34 +549,32 @@ well because this is a more general way.
> >  
> >     release A
> >  
> > -   where A, B and C are different lock classes.
> > -
> > -In this case, dependencies are added at the commit step as described.
> > +   where A, B, and C are different lock classes.
> >  
> > -After commits for A, B and C, the graph will be:
> > +Dependencies are added at the commit step as described. After commits
> > +for A, B, and C, the graph will be:
> >  
> >     A -> B -> C
> >  
> > -   where A, B and C are different lock classes.
> > +   where A, B, and C are different lock classes.
> >  
> >     NOTE: A dependency 'A -> C' is optimized out.
> >  
> > -We can see the former graph built without commit step is same as the
> > -latter graph built using commit steps. Of course the former way leads to
> > -earlier finish for building the graph, which means we can detect a
> > -deadlock or its possibility sooner. So the former way would be prefered
> > -when possible. But we cannot avoid using the latter way for crosslocks.
> > +We can see the former graph built without the commit step is same as the
> > +latter graph. Of course, the former way leads to earlier finish for
> > +building the graph, which means we can detect a deadlock or its
> > +possibility sooner. So the former way would be preferred when possible.
> > +But we cannot avoid using the latter way for crosslocks.
> >  
> > -Let's look at how commit steps work for crosslocks. In this case, the
> > -commit step is performed only on crosslock AX as real. And it assumes
> > -that the AX release context is different from the AX acquire context.
> > +Lastly, let's look at how commit works for crosslocks in practice.
> >  
> >     BX RELEASE CONTEXT		   BX ACQUIRE CONTEXT
> >     ------------------		   ------------------
> >  				   acquire A
> >  				   /*
> > -				    * Push A onto held_locks
> > -				    * Queue A into hist_locks
> > +				    * Add 'the top of held_locks -> A'
> > +				    * Push A to held_locks
> > +				    * Queue A in hist_locks
> >  				    *
> >  				    * In held_locks: A
> >  				    * In hist_locks: A
> > @@ -604,8 +597,9 @@ that the AX release context is different from the AX acquire context.
> >  
> >     acquire C
> >     /*
> > -    * Push C onto held_locks
> > -    * Queue C into hist_locks
> > +    * Add 'the top of held_locks -> C'
> > +    * Push C to held_locks
> > +    * Queue C in hist_locks
> >      *
> >      * In held_locks: C
> >      * In hist_locks: C
> > @@ -622,9 +616,9 @@ that the AX release context is different from the AX acquire context.
> >      */
> >  				   acquire D
> >  				   /*
> > -				    * Push D onto held_locks
> > -				    * Queue D into hist_locks
> >  				    * Add 'the top of held_locks -> D'
> > +				    * Push D to held_locks
> > +				    * Queue D in hist_locks
> >  				    *
> >  				    * In held_locks: A, D
> >  				    * In hist_locks: A, D
> > @@ -632,8 +626,9 @@ that the AX release context is different from the AX acquire context.
> >  				    */
> >     acquire E
> >     /*
> > -    * Push E onto held_locks
> > -    * Queue E into hist_locks
> > +    * Add 'the top of held_locks -> E'
> > +    * Push E to held_locks
> > +    * Queue E in hist_locks
> >      *
> >      * In held_locks: E
> >      * In hist_locks: C, E
> > @@ -659,6 +654,7 @@ that the AX release context is different from the AX acquire context.
> >     commit BX
> >     /*
> >      * Add 'BX -> ?'
> > +    * Answer the following to decide '?'
> >      * What has been queued since acquire BX: C, E
> >      *
> >      * In held_locks: Empty
> > @@ -684,15 +680,15 @@ that the AX release context is different from the AX acquire context.
> >  				    *           'BX -> C', 'BX -> E'
> >  				    */
> >  
> > -   where A, BX, C,..., E are different lock classes, and a suffix 'X' is
> > -   added on crosslocks.
> > +   where A, BX, C,..., E are different lock classes and a suffix 'X' is
> > +   added at crosslocks.
> >  
> > -Crossrelease considers all acquisitions after acqiuring BX are
> > -candidates which might create dependencies with BX. True dependencies
> > -will be determined when identifying the release context of BX. Meanwhile,
> > -all typical locks are queued so that they can be used at the commit step.
> > -And then two dependencies 'BX -> C' and 'BX -> E' are added at the
> > -commit step when identifying the release context.
> > +Crossrelease considers all acquisitions following acquiring BX because
> > +they can create dependencies with BX. The dependencies will be
> > +determined in the release context of BX. Meanwhile, all typical locks
> > +are queued so that they can be used at the commit step. Finally, two
> > +dependencies 'BX -> C' and 'BX -> E' will be added at the commit step,
> > +when identifying the release context.
> >  
> >  The final graph will be, with crossrelease:
> >  
> > @@ -704,8 +700,8 @@ The final graph will be, with crossrelease:
> >        \
> >         -> D
> >  
> > -   where A, BX, C,..., E are different lock classes, and a suffix 'X' is
> > -   added on crosslocks.
> > +   where A, BX, C,..., E are different lock classes and a suffix 'X' is
> > +   added at crosslocks.
> >  
> >  However, the final graph will be, without crossrelease:
> >  
> > @@ -732,39 +728,40 @@ Avoid duplication
> >  
> >  Crossrelease feature uses a cache like what lockdep already uses for
> >  dependency chains, but this time it's for caching CT type dependencies.
> > -Once that dependency is cached, the same will never be added again.
> > +Once a dependency is cached, the same will never be added again.
> >  
> >  
> > -Lockless for hot paths
> > -----------------------
> > +Make hot paths lockless
> > +-----------------------
> >  
> >  To keep all locks for later use at the commit step, crossrelease adopts
> > -a local array embedded in task_struct, which makes access to the data
> > -lockless by forcing it to happen only within the owner context. It's
> > -like how lockdep handles held_locks. Lockless implmentation is important
> > -since typical locks are very frequently acquired and released.
> > +a local array embedded in task_struct, which makes the data locklessly
> > +accessible by forcing it to happen only within the owner context. It's
> > +like how lockdep handles held_locks. Lockless implementation is
> > +important since typical locks are very frequently acquired and released.
> >  
> >  
> >  =================================================
> >  APPENDIX A: What lockdep does to work aggresively
> >  =================================================
> >  
> > -A deadlock actually occurs when all wait operations creating circular
> > +A deadlock actually occurs when all waiters creating circular
> >  dependencies run at the same time. Even though they don't, a potential
> > -deadlock exists if the problematic dependencies exist. Thus it's
> > +deadlock exists if the problematic dependencies exist. Thus, it's
> >  meaningful to detect not only an actual deadlock but also its potential
> > -possibility. The latter is rather valuable. When a deadlock occurs
> > -actually, we can identify what happens in the system by some means or
> > -other even without lockdep. However, there's no way to detect possiblity
> > -without lockdep unless the whole code is parsed in head. It's terrible.
> > -Lockdep does the both, and crossrelease only focuses on the latter.
> > +possibility. The latter is rather valuable. When a deadlock actually
> > +occurs, we can identify what happens in the system by some means or
> > +other even without lockdep. However, there's no way to detect a
> > +possibility without lockdep, unless the whole code is parsed in the head.
> > +It's terrible. Lockdep does the both, and crossrelease only focuses on
> > +the latter.
> >  
> >  Whether or not a deadlock actually occurs depends on several factors.
> >  For example, what order contexts are switched in is a factor. Assuming
> >  circular dependencies exist, a deadlock would occur when contexts are
> > -switched so that all wait operations creating the dependencies run
> > -simultaneously. Thus to detect a deadlock possibility even in the case
> > -that it has not occured yet, lockdep should consider all possible
> > +switched so that all waiters creating the dependencies run
> > +simultaneously. Thus, to detect a deadlock possibility even in the case
> > +that it has not occurred yet, lockdep should consider all possible
> >  combinations of dependencies, trying to:
> >  
> >  1. Use a global dependency graph.
> > @@ -776,7 +773,7 @@ combinations of dependencies, trying to:
> >  
> >  2. Check dependencies between classes instead of instances.
> >  
> > -   What actually causes a deadlock are instances of lock. However,
> > +   What actually causes a deadlock are instances of locks. However,
> >     lockdep checks dependencies between classes instead of instances.
> >     This way lockdep can detect a deadlock which has not happened but
> >     might happen in future by others but the same class.
> > @@ -805,44 +802,28 @@ Remind what a dependency is. A dependency exists if:
> >  
> >  For example:
> >  
> > -   acquire A
> > -   acquire B /* A dependency 'A -> B' exists */
> > -   release B
> > -   release A
> > -
> > -   where A and B are different lock classes.
> > -
> > -A depedency 'A -> B' exists since:
> > -
> > -   1. A waiter for A and a waiter for B might exist when acquiring B.
> > -   2. Only way to wake up each is to release what it waits for.
> > -   3. Whether the waiter for A can be woken up depends on whether the
> > -      other can. IOW, TASK X cannot release A if it fails to acquire B.
> > -
> > -For another example:
> > -
> > -   TASK X			   TASK Y
> > -   ------			   ------
> > +   CONTEXT X			   CONTEXT Y
> > +   ---------			   ---------
> >  				   acquire AX
> >     acquire B /* A dependency 'AX -> B' exists */
> >     release B
> >     release AX held by Y
> >  
> > -   where AX and B are different lock classes, and a suffix 'X' is added
> > -   on crosslocks.
> > +   where AX and B are different lock classes and a suffix 'X' is added
> > +   at crosslocks.
> >  
> > -Even in this case involving crosslocks, the same rule can be applied. A
> > -depedency 'AX -> B' exists since:
> > +Here, a dependency 'AX -> B' exists since:
> >  
> >     1. A waiter for AX and a waiter for B might exist when acquiring B.
> > -   2. Only way to wake up each is to release what it waits for.
> > +   2. The only way to wake up each is to release what it waits for.
> >     3. Whether the waiter for AX can be woken up depends on whether the
> > -      other can. IOW, TASK X cannot release AX if it fails to acquire B.
> > +      other can. In other words, CONTEXT X cannot release AX if it fails
> > +      to acquire B.
> >  
> > -Let's take a look at more complicated example:
> > +Let's take a look at a more complicated example:
> >  
> > -   TASK X			   TASK Y
> > -   ------			   ------
> > +   CONTEXT X			   CONTEXT Y
> > +   ---------			   ---------
> >     acquire B
> >     release B
> >     fork Y
> > @@ -851,22 +832,22 @@ Let's take a look at more complicated example:
> >     release C
> >     release AX held by Y
> >  
> > -   where AX, B and C are different lock classes, and a suffix 'X' is
> > -   added on crosslocks.
> > +   where AX, B, and C are different lock classes and a suffix 'X' is
> > +   added at crosslocks.
> >  
> >  Does a dependency 'AX -> B' exist? Nope.
> >  
> >  Two waiters are essential to create a dependency. However, waiters for
> >  AX and B to create 'AX -> B' cannot exist at the same time in this
> > -example. Thus the dependency 'AX -> B' cannot be created.
> > +example. Thus, the dependency 'AX -> B' cannot be created.
> >  
> >  It would be ideal if the full set of true ones can be considered. But
> >  we can ensure nothing but what actually happened. Relying on what
> >  actually happens at runtime, we can anyway add only true ones, though
> >  they might be a subset of true ones. It's similar to how lockdep works
> > -for typical locks. There might be more true dependencies than what
> > -lockdep has detected in runtime. Lockdep has no choice but to rely on
> > -what actually happens. Crossrelease also relies on it.
> > +for typical locks. There might be more true dependencies than lockdep
> > +has detected. Lockdep has no choice but to rely on what actually happens.
> > +Crossrelease also relies on it.
> >  
> >  CONCLUSION
> >  
> > -- 
> > 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
