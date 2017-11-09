Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B567440460
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 02:41:55 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id b186so7973065iof.21
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 23:41:55 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id v2si5517835pgo.163.2017.11.08.23.41.52
        for <linux-mm@kvack.org>;
        Wed, 08 Nov 2017 23:41:53 -0800 (PST)
Date: Thu, 9 Nov 2017 16:41:38 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v2] locking/lockdep: Revise
 Documentation/locking/crossrelease.txt
Message-ID: <20171109074138.GB24935@X58A-UD3R>
References: <1510212036-22008-1-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510212036-22008-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com

On Thu, Nov 09, 2017 at 04:20:36PM +0900, Byungchul Park wrote:
> Changes from v1
> - Run several tools checking english spell and grammar over the text.
> - Simplify the document more.

Checker tools also reported other words e.g. crosslock, crossrelease,
lockdep, mutex, lockless, and so on, but I left them unchanged since
I thought it's better to leave it. Please let me know if I was wrong.

Thanks,
Byungchul

> -----8<-----
> >From 412bc9eb0d22791f70f7364bda189feb41899ff9 Mon Sep 17 00:00:00 2001
> From: Byungchul Park <byungchul.park@lge.com>
> Date: Thu, 9 Nov 2017 16:12:23 +0900
> Subject: [PATCH v2] locking/lockdep: Revise Documentation/locking/crossrelease.txt
> 
> Revise Documentation/locking/crossrelease.txt to enhance its readability.
> 
> Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> ---
>  Documentation/locking/crossrelease.txt | 492 +++++++++++++++------------------
>  1 file changed, 227 insertions(+), 265 deletions(-)
> 
> diff --git a/Documentation/locking/crossrelease.txt b/Documentation/locking/crossrelease.txt
> index bdf1423..11e3e3b 100644
> --- a/Documentation/locking/crossrelease.txt
> +++ b/Documentation/locking/crossrelease.txt
> @@ -12,10 +12,10 @@ Contents:
>  
>   (*) Limitation
>  
> -     - Limit lockdep
> +     - Limiting lockdep
>       - Pros from the limitation
>       - Cons from the limitation
> -     - Relax the limitation
> +     - Relaxing the limitation
>  
>   (*) Crossrelease
>  
> @@ -30,9 +30,9 @@ Contents:
>   (*) Optimizations
>  
>       - Avoid duplication
> -     - Lockless for hot paths
> +     - Make hot paths lockless
>  
> - (*) APPENDIX A: What lockdep does to work aggresively
> + (*) APPENDIX A: How to add dependencies aggressively
>  
>   (*) APPENDIX B: How to avoid adding false dependencies
>  
> @@ -51,36 +51,30 @@ also impossible due to the same reason.
>  
>  For example:
>  
> -   A context going to trigger event C is waiting for event A to happen.
> -   A context going to trigger event A is waiting for event B to happen.
> -   A context going to trigger event B is waiting for event C to happen.
> +   A context going to trigger event C is waiting for event A.
> +   A context going to trigger event A is waiting for event B.
> +   A context going to trigger event B is waiting for event C.
>  
> -A deadlock occurs when these three wait operations run at the same time,
> -because event C cannot be triggered if event A does not happen, which in
> -turn cannot be triggered if event B does not happen, which in turn
> -cannot be triggered if event C does not happen. After all, no event can
> -be triggered since any of them never meets its condition to wake up.
> +A deadlock occurs when the three waiters run at the same time, because
> +event C cannot be triggered if event A does not happen, which in turn
> +cannot be triggered if event B does not happen, which in turn cannot be
> +triggered if event C does not happen. After all, no event can be
> +triggered since any of them never meets its condition to wake up.
>  
> -A dependency might exist between two waiters and a deadlock might happen
> -due to an incorrect releationship between dependencies. Thus, we must
> -define what a dependency is first. A dependency exists between them if:
> +A dependency exists between two waiters, and a deadlock happens due to
> +an incorrect relationship between dependencies. Thus, we must define
> +what a dependency is first. A dependency exists between waiters if:
>  
>     1. There are two waiters waiting for each event at a given time.
>     2. The only way to wake up each waiter is to trigger its event.
>     3. Whether one can be woken up depends on whether the other can.
>  
> -Each wait in the example creates its dependency like:
> +Each waiter in the example creates its dependency like:
>  
>     Event C depends on event A.
>     Event A depends on event B.
>     Event B depends on event C.
>  
> -   NOTE: Precisely speaking, a dependency is one between whether a
> -   waiter for an event can be woken up and whether another waiter for
> -   another event can be woken up. However from now on, we will describe
> -   a dependency as if it's one between an event and another event for
> -   simplicity.
> -
>  And they form circular dependencies like:
>  
>      -> C -> A -> B -
> @@ -101,19 +95,18 @@ Circular dependencies cause a deadlock.
>  How lockdep works
>  -----------------
>  
> -Lockdep tries to detect a deadlock by checking dependencies created by
> -lock operations, acquire and release. Waiting for a lock corresponds to
> -waiting for an event, and releasing a lock corresponds to triggering an
> -event in the previous section.
> +Lockdep tries to detect a deadlock by checking circular dependencies
> +created by lock operations, acquire and release, which are wait and
> +event respectively.
>  
>  In short, lockdep does:
>  
>     1. Detect a new dependency.
> -   2. Add the dependency into a global graph.
> +   2. Add the dependency to a global graph.
>     3. Check if that makes dependencies circular.
> -   4. Report a deadlock or its possibility if so.
> +   4. Report the deadlock if so.
>  
> -For example, consider a graph built by lockdep that looks like:
> +For example, the graph has been built like:
>  
>     A -> B -
>             \
> @@ -123,7 +116,7 @@ For example, consider a graph built by lockdep that looks like:
>  
>     where A, B,..., E are different lock classes.
>  
> -Lockdep will add a dependency into the graph on detection of a new
> +Lockdep will add a dependency to the graph on detection of a new
>  dependency. For example, it will add a dependency 'E -> C' when a new
>  dependency between lock E and lock C is detected. Then the graph will be:
>  
> @@ -147,7 +140,7 @@ This graph contains a subgraph which demonstrates circular dependencies:
>     \                  /
>      ------------------
>  
> -   where C, D and E are different lock classes.
> +   where C, D, and E are different lock classes.
>  
>  This is the condition under which a deadlock might occur. Lockdep
>  reports it on detection after adding a new dependency. This is the way
> @@ -155,33 +148,29 @@ how lockdep works.
>  
>  CONCLUSION
>  
> -Lockdep detects a deadlock or its possibility by checking if circular
> -dependencies were created after adding each new dependency.
> +Lockdep detects a deadlock by checking if circular dependencies were
> +created after adding each new dependency.
>  
>  
>  ==========
>  Limitation
>  ==========
>  
> -Limit lockdep
> --------------
> +Limiting lockdep
> +----------------
>  
> -Limiting lockdep to work on only typical locks e.g. spin locks and
> -mutexes, which are released within the acquire context, the
> -implementation becomes simple but its capacity for detection becomes
> -limited. Let's check pros and cons in next section.
> +Limiting lockdep to work with only typical locks e.g. spin locks and
> +mutexes, the implementation becomes simple because it ensures that
> +they are released within the acquire context, but its capacity for
> +detection becomes limited. Let's check pros and cons in the next two
> +sections.
>  
>  
>  Pros from the limitation
>  ------------------------
>  
> -Given the limitation, when acquiring a lock, locks in a held_locks
> -cannot be released if the context cannot acquire it so has to wait to
> -acquire it, which means all waiters for the locks in the held_locks are
> -stuck. It's an exact case to create dependencies between each lock in
> -the held_locks and the lock to acquire.
> -
> -For example:
> +Given the limitation, a dependency can be identified at the time
> +acquiring a lock. For example:
>  
>     CONTEXT X
>     ---------
> @@ -192,25 +181,37 @@ For example:
>  
>     where A and B are different lock classes.
>  
> -When acquiring lock A, the held_locks of CONTEXT X is empty thus no
> -dependency is added. But when acquiring lock B, lockdep detects and adds
> -a new dependency 'A -> B' between lock A in the held_locks and lock B.
> -They can be simply added whenever acquiring each lock.
> +Remind what a dependency is. A dependency exists if:
> +
> +   1. There are two waiters waiting for each event at a given time.
> +   2. The only way to wake up each waiter is to trigger its event.
> +   3. Whether one can be woken up depends on whether the other can.
> +
> +Therefore, a dependency 'A -> B' exists since:
> +
> +   1. A waiter for A and a waiter for B might exist when acquiring B.
> +   2. The only way to wake up each is to release what it waits for.
> +   3. Whether the waiter for A can be woken up depends on whether the
> +      other can. In other words, CONTEXT X cannot release A if it's stuck
> +      in the acquisition of B.
> +
> +And the decision easily can be made at the time acquiring B.
>  
> -And data required by lockdep exists in a local structure, held_locks
> -embedded in task_struct. Forcing to access the data within the context,
> -lockdep can avoid racy problems without explicit locks while handling
> -the local data.
> +Furthermore, data used to create a dependency can be kept in local
> +structure, task_struct, under the limitation. Thus, by forcing to access
> +the data within the context, lockdep can avoid racy problems without
> +explicit protection.
>  
> -Lastly, lockdep only needs to keep locks currently being held, to build
> -a dependency graph. However, relaxing the limitation, it needs to keep
> -even locks already released, because a decision whether they created
> -dependencies might be long-deferred.
> +Lastly, lockdep only needs to keep locks currently being held. However,
> +relaxing the limitation, it needs to keep even locks already released,
> +because the decision, whether they create dependencies, should be
> +long-deferred.
>  
>  To sum up, we can expect several advantages from the limitation:
>  
>     1. Lockdep can easily identify a dependency when acquiring a lock.
> -   2. Races are avoidable while accessing local locks in a held_locks.
> +   2. Races are avoidable without explicit protection while accessing
> +      local locks.
>     3. Lockdep only needs to keep locks currently being held.
>  
>  CONCLUSION
> @@ -221,9 +222,9 @@ Given the limitation, the implementation becomes simple and efficient.
>  Cons from the limitation
>  ------------------------
>  
> -Given the limitation, lockdep is applicable only to typical locks. For
> -example, page locks for page access or completions for synchronization
> -cannot work with lockdep.
> +Given the limitation, however, lockdep is applicable only to typical
> +locks. For example, page locks for page access or completions for
> +synchronization cannot work with lockdep.
>  
>  Can we detect deadlocks below, under the limitation?
>  
> @@ -261,54 +262,53 @@ No, we cannot.
>  
>  CONCLUSION
>  
> -Given the limitation, lockdep cannot detect a deadlock or its
> -possibility caused by page locks or completions.
> +Given the limitation, lockdep cannot detect a deadlock caused by page
> +locks or completions.
>  
>  
> -Relax the limitation
> ---------------------
> +Relaxing the limitation
> +-----------------------
>  
>  Under the limitation, things to create dependencies are limited to
>  typical locks. However, synchronization primitives like page locks and
> -completions, which are allowed to be released in any context, also
> -create dependencies and can cause a deadlock. So lockdep should track
> -these locks to do a better job. We have to relax the limitation for
> -these locks to work with lockdep.
> +completions allowed to be released in any context, also create
> +dependencies and can cause a deadlock. So lockdep should track these
> +locks to do a better job. We have to relax the limitation for these
> +locks to work with lockdep.
>  
>  Detecting dependencies is very important for lockdep to work because
>  adding a dependency means adding an opportunity to check whether it
>  causes a deadlock. The more lockdep adds dependencies, the more it
> -thoroughly works. Thus Lockdep has to do its best to detect and add as
> -many true dependencies into a graph as possible.
> +thoroughly works. Thus, lockdep has to do its best to detect and add as
> +many true dependencies to the graph as possible.
>  
> -For example, considering only typical locks, lockdep builds a graph like:
> +For example:
>  
> -   A -> B -
> -           \
> -            -> E
> -           /
> -   C -> D -
> +   CONTEXT X			   CONTEXT Y
> +   ---------			   ---------
> +				   acquire A
> +   acquire B /* A dependency 'A -> B' exists */
> +   release B
> +   release A held by Y
>  
> -   where A, B,..., E are different lock classes.
> +   where A and B are different lock classes.
>  
> -On the other hand, under the relaxation, additional dependencies might
> -be created and added. Assuming additional 'FX -> C' and 'E -> GX' are
> -added thanks to the relaxation, the graph will be:
> +In this case, a dependency 'A -> B' exists since:
>  
> -         A -> B -
> -                 \
> -                  -> E -> GX
> -                 /
> -   FX -> C -> D -
> +   1. A waiter for A and a waiter for B might exist when acquiring B.
> +   2. The only way to wake up each is to release what it waits for.
> +   3. Whether the waiter for A can be woken up depends on whether the
> +      other can. In other words, CONTEXT X cannot release A if it's stuck
> +      in the acquisition of B.
>  
> -   where A, B,..., E, FX and GX are different lock classes, and a suffix
> -   'X' is added on non-typical locks.
> +Considering only typical locks, lockdep won't add any dependency here.
> +However, relaxing the limitation, a true dependency 'A -> B' can be
> +added. Then, we can have more chances to check circular dependencies.
>  
> -The latter graph gives us more chances to check circular dependencies
> -than the former. However, it might suffer performance degradation since
> -relaxing the limitation, with which design and implementation of lockdep
> -can be efficient, might introduce inefficiency inevitably. So lockdep
> -should provide two options, strong detection and efficient detection.
> +However, it might suffer performance degradation since relaxing the
> +limitation, with which design and implementation of lockdep can be
> +efficient, might introduce inefficiency inevitably. So lockdep should
> +provide two options i.e. strong detection and efficient detection.
>  
>  Choosing efficient detection:
>  
> @@ -333,37 +333,30 @@ Crossrelease
>  Introduce crossrelease
>  ----------------------
>  
> -In order to allow lockdep to handle additional dependencies by what
> -might be released in any context, namely 'crosslock', we have to be able
> -to identify those created by crosslocks. The proposed 'crossrelease'
> -feature provoides a way to do that.
> +To allow lockdep to handle the additional dependencies created by namely
> +'crosslock', we propose 'crossrelease' feature.
>  
> -Crossrelease feature has to do:
> +Crossrelease feature does:
>  
>     1. Identify dependencies created by crosslocks.
> -   2. Add the dependencies into a dependency graph.
> +   2. Add the dependencies to the dependency graph.
>  
> -That's all. Once a meaningful dependency is added into graph, then
> +That's all. Once a meaningful dependency is added to the graph, then
>  lockdep would work with the graph as it did. The most important thing
>  crossrelease feature has to do is to correctly identify and add true
> -dependencies into the global graph.
> +dependencies to the graph.
>  
>  A dependency e.g. 'A -> B' can be identified only in the A's release
> -context because a decision required to identify the dependency can be
> -made only in the release context. That is to decide whether A can be
> -released so that a waiter for A can be woken up. It cannot be made in
> -other than the A's release context.
> -
> -It's no matter for typical locks because each acquire context is same as
> -its release context, thus lockdep can decide whether a lock can be
> -released in the acquire context. However for crosslocks, lockdep cannot
> -make the decision in the acquire context but has to wait until the
> -release context is identified.
> -
> -Therefore, deadlocks by crosslocks cannot be detected just when it
> -happens, because those cannot be identified until the crosslocks are
> -released. However, deadlock possibilities can be detected and it's very
> -worth. See 'APPENDIX A' section to check why.
> +context, because a decision required to identify the dependency can be
> +made only in the release context. In other words, the decision whether A
> +can be released and wake up waiters for it, cannot be made in other than
> +the A's release context.
> +
> +Of course, it's no matter for typical locks because each acquire context
> +is the same as its release context, thus lockdep can decide whether a
> +lock can be released, in the acquire context. However, for crosslocks,
> +lockdep cannot make the decision in the acquire context but has to wait
> +until the release context is identified.
>  
>  CONCLUSION
>  
> @@ -375,12 +368,13 @@ Introduce commit
>  ----------------
>  
>  Since crossrelease defers the work adding true dependencies of
> -crosslocks until they are actually released, crossrelease has to queue
> -all acquisitions which might create dependencies with the crosslocks.
> -Then it identifies dependencies using the queued data in batches at a
> -proper time. We call it 'commit'.
> +crosslocks until they are eventually released, we have to queue all
> +acquisitions, which might create dependencies with the crosslocks, so
> +true dependencies can be identified using the queued data in batches at
> +a proper time. We call the step adding true dependencies to the graph in
> +batches, 'commit'.
>  
> -There are four types of dependencies:
> +We have four types of dependencies:
>  
>  1. TT type: 'typical lock A -> typical lock B'
>  
> @@ -407,16 +401,16 @@ There are four types of dependencies:
>     to wait until the decision can be made. Commit is necessary.
>     But, handling CC type is not implemented yet. It's a future work.
>  
> -Lockdep can work without commit for typical locks, but commit step is
> +Lockdep can work without commit for typical locks, but the step is
>  necessary once crosslocks are involved. Introducing commit, lockdep
> -performs three steps. What lockdep does in each step is:
> +performs three steps:
>  
>  1. Acquisition: For typical locks, lockdep does what it originally did
>     and queues the lock so that CT type dependencies can be checked using
>     it at the commit step. For crosslocks, it saves data which will be
>     used at the commit step and increases a reference count for it.
>  
> -2. Commit: No action is reauired for typical locks. For crosslocks,
> +2. Commit: No action is required for typical locks. For crosslocks,
>     lockdep adds CT type dependencies using the data saved at the
>     acquisition step.
>  
> @@ -442,9 +436,9 @@ Crossrelease introduces two main data structures.
>  
>     This is an array embedded in task_struct, for keeping lock history so
>     that dependencies can be added using them at the commit step. Since
> -   it's local data, it can be accessed locklessly in the owner context.
> -   The array is filled at the acquisition step and consumed at the
> -   commit step. And it's managed in circular manner.
> +   they are local data, they can be accessed locklessly in the owner
> +   context. The array is filled at the acquisition step and consumed at
> +   the commit step. And it's managed in a circular manner.
>  
>  2. cross_lock
>  
> @@ -455,48 +449,36 @@ Crossrelease introduces two main data structures.
>  How crossrelease works
>  ----------------------
>  
> -It's the key of how crossrelease works, to defer necessary works to an
> -appropriate point in time and perform in at once at the commit step.
> -Let's take a look with examples step by step, starting from how lockdep
> -works without crossrelease for typical locks.
> -
> -   acquire A /* Push A onto held_locks */
> -   acquire B /* Push B onto held_locks and add 'A -> B' */
> -   acquire C /* Push C onto held_locks and add 'B -> C' */
> -   release C /* Pop C from held_locks */
> -   release B /* Pop B from held_locks */
> -   release A /* Pop A from held_locks */
> -
> -   where A, B and C are different lock classes.
> +Let's take a look at examples step by step, starting from how lockdep
> +works for typical locks, without crossrelease.
>  
> -   NOTE: This document assumes that readers already understand how
> -   lockdep works without crossrelease thus omits details. But there's
> -   one thing to note. Lockdep pretends to pop a lock from held_locks
> -   when releasing it. But it's subtly different from the original pop
> -   operation because lockdep allows other than the top to be poped.
> +   acquire A
> +   acquire B
> +   acquire C
> +   release C
> +   release B
> +   release A
>  
> -In this case, lockdep adds 'the top of held_locks -> the lock to acquire'
> -dependency every time acquiring a lock.
> +   where A, B, and C are different lock classes.
>  
> -After adding 'A -> B', a dependency graph will be:
> +When acquiring B, a dependency 'A -> B' is added:
>  
>     A -> B
>  
>     where A and B are different lock classes.
>  
> -And after adding 'B -> C', the graph will be:
> +And when acquiring C, a dependency 'B -> C' is added:
>  
>     A -> B -> C
>  
> -   where A, B and C are different lock classes.
> +   where A, B, and C are different lock classes.
>  
> -Let's performs commit step even for typical locks to add dependencies.
> -Of course, commit step is not necessary for them, however, it would work
> -well because this is a more general way.
> +Now, let's apply the commit step into the example. Of course, the step
> +is not necessary for typical locks, but it would also work like:
>  
>     acquire A
>     /*
> -    * Queue A into hist_locks
> +    * Queue A in hist_locks
>      *
>      * In hist_locks: A
>      * In graph: Empty
> @@ -504,7 +486,7 @@ well because this is a more general way.
>  
>     acquire B
>     /*
> -    * Queue B into hist_locks
> +    * Queue B in hist_locks
>      *
>      * In hist_locks: A, B
>      * In graph: Empty
> @@ -512,7 +494,7 @@ well because this is a more general way.
>  
>     acquire C
>     /*
> -    * Queue C into hist_locks
> +    * Queue C in hist_locks
>      *
>      * In hist_locks: A, B, C
>      * In graph: Empty
> @@ -520,9 +502,8 @@ well because this is a more general way.
>  
>     commit C
>     /*
> -    * Add 'C -> ?'
> -    * Answer the following to decide '?'
> -    * What has been queued since acquire C: Nothing
> +    * Add 'C -> ?' after deciding '?'
> +    * What has been queued since acquire C (='?'): Nothing
>      *
>      * In hist_locks: A, B, C
>      * In graph: Empty
> @@ -532,9 +513,8 @@ well because this is a more general way.
>  
>     commit B
>     /*
> -    * Add 'B -> ?'
> -    * Answer the following to decide '?'
> -    * What has been queued since acquire B: C
> +    * Add 'B -> ?' after deciding '?'
> +    * What has been queued since acquire B (='?'): C
>      *
>      * In hist_locks: A, B, C
>      * In graph: 'B -> C'
> @@ -544,9 +524,8 @@ well because this is a more general way.
>  
>     commit A
>     /*
> -    * Add 'A -> ?'
> -    * Answer the following to decide '?'
> -    * What has been queued since acquire A: B, C
> +    * Add 'A -> ?' after deciding '?'
> +    * What has been queued since acquire A (='?'): B, C
>      *
>      * In hist_locks: A, B, C
>      * In graph: 'B -> C', 'A -> B', 'A -> C'
> @@ -554,34 +533,32 @@ well because this is a more general way.
>  
>     release A
>  
> -   where A, B and C are different lock classes.
> -
> -In this case, dependencies are added at the commit step as described.
> +   where A, B, and C are different lock classes.
>  
> -After commits for A, B and C, the graph will be:
> +Dependencies are added at the commit step as described. After commits
> +for A, B, and C, the graph becomes:
>  
>     A -> B -> C
>  
> -   where A, B and C are different lock classes.
> +   where A, B, and C are different lock classes.
>  
>     NOTE: A dependency 'A -> C' is optimized out.
>  
> -We can see the former graph built without commit step is same as the
> -latter graph built using commit steps. Of course the former way leads to
> -earlier finish for building the graph, which means we can detect a
> -deadlock or its possibility sooner. So the former way would be prefered
> -when possible. But we cannot avoid using the latter way for crosslocks.
> +We can see the former graph is the same as the latter graph. Of course,
> +the former way leads to earlier finish for building the graph, which
> +means we can detect a deadlock or its possibility sooner. So the former
> +way would be preferred when possible. But, we cannot avoid using the
> +latter way for crosslocks.
>  
> -Let's look at how commit steps work for crosslocks. In this case, the
> -commit step is performed only on crosslock AX as real. And it assumes
> -that the AX release context is different from the AX acquire context.
> +Lastly, let's look at how commit works for crosslocks in practice.
>  
>     BX RELEASE CONTEXT		   BX ACQUIRE CONTEXT
>     ------------------		   ------------------
>  				   acquire A
>  				   /*
> -				    * Push A onto held_locks
> -				    * Queue A into hist_locks
> +				    * Add 'the top of held_locks -> A'
> +				    * Push A to held_locks
> +				    * Queue A in hist_locks
>  				    *
>  				    * In held_locks: A
>  				    * In hist_locks: A
> @@ -604,8 +581,9 @@ that the AX release context is different from the AX acquire context.
>  
>     acquire C
>     /*
> -    * Push C onto held_locks
> -    * Queue C into hist_locks
> +    * Add 'the top of held_locks -> C'
> +    * Push C to held_locks
> +    * Queue C in hist_locks
>      *
>      * In held_locks: C
>      * In hist_locks: C
> @@ -622,9 +600,9 @@ that the AX release context is different from the AX acquire context.
>      */
>  				   acquire D
>  				   /*
> -				    * Push D onto held_locks
> -				    * Queue D into hist_locks
>  				    * Add 'the top of held_locks -> D'
> +				    * Push D to held_locks
> +				    * Queue D in hist_locks
>  				    *
>  				    * In held_locks: A, D
>  				    * In hist_locks: A, D
> @@ -632,8 +610,9 @@ that the AX release context is different from the AX acquire context.
>  				    */
>     acquire E
>     /*
> -    * Push E onto held_locks
> -    * Queue E into hist_locks
> +    * Add 'the top of held_locks -> E'
> +    * Push E to held_locks
> +    * Queue E in hist_locks
>      *
>      * In held_locks: E
>      * In hist_locks: C, E
> @@ -658,8 +637,8 @@ that the AX release context is different from the AX acquire context.
>  				    */
>     commit BX
>     /*
> -    * Add 'BX -> ?'
> -    * What has been queued since acquire BX: C, E
> +    * Add 'BX -> ?' after deciding '?'
> +    * What has been queued since acquire BX (='?'): C, E
>      *
>      * In held_locks: Empty
>      * In hist_locks: D, E
> @@ -684,17 +663,13 @@ that the AX release context is different from the AX acquire context.
>  				    *           'BX -> C', 'BX -> E'
>  				    */
>  
> -   where A, BX, C,..., E are different lock classes, and a suffix 'X' is
> -   added on crosslocks.
> +   where A, BX, C,..., E are different lock classes and a suffix 'X' is
> +   added at crosslocks.
>  
> -Crossrelease considers all acquisitions after acqiuring BX are
> -candidates which might create dependencies with BX. True dependencies
> -will be determined when identifying the release context of BX. Meanwhile,
> -all typical locks are queued so that they can be used at the commit step.
> -And then two dependencies 'BX -> C' and 'BX -> E' are added at the
> -commit step when identifying the release context.
> +All typical locks are queued so that they can be used at the commit step.
> +And then two dependencies 'BX -> C' and 'BX -> E' are added at the step.
>  
> -The final graph will be, with crossrelease:
> +The final graph would be, with crossrelease:
>  
>                 -> C
>                /
> @@ -704,10 +679,10 @@ The final graph will be, with crossrelease:
>        \
>         -> D
>  
> -   where A, BX, C,..., E are different lock classes, and a suffix 'X' is
> -   added on crosslocks.
> +   where A, BX, C,..., E are different lock classes and a suffix 'X' is
> +   added at crosslocks.
>  
> -However, the final graph will be, without crossrelease:
> +However, the final graph would be, without crossrelease:
>  
>     A -> D
>  
> @@ -720,7 +695,7 @@ caused by crosslocks.
>  
>  CONCLUSION
>  
> -We checked how crossrelease works with several examples.
> +We checked how crossrelease works, with several examples.
>  
>  
>  =============
> @@ -730,42 +705,44 @@ Optimizations
>  Avoid duplication
>  -----------------
>  
> -Crossrelease feature uses a cache like what lockdep already uses for
> +Crossrelease feature uses a cache, like what lockdep already uses for
>  dependency chains, but this time it's for caching CT type dependencies.
> -Once that dependency is cached, the same will never be added again.
> +Once a dependency is cached, the same will never be added again.
>  
>  
> -Lockless for hot paths
> -----------------------
> +Make hot paths lockless
> +-----------------------
>  
> -To keep all locks for later use at the commit step, crossrelease adopts
> -a local array embedded in task_struct, which makes access to the data
> -lockless by forcing it to happen only within the owner context. It's
> -like how lockdep handles held_locks. Lockless implmentation is important
> -since typical locks are very frequently acquired and released.
> +To keep all locks for later use, crossrelease adopts a local array in
> +task_struct, which makes the data locklessly accessible by forcing it to
> +happen within the owner context. It's like how lockdep handles locks in
> +held_locks. Achieving it is very important since typical locks are very
> +frequently acquired and released.
>  
>  
> -=================================================
> -APPENDIX A: What lockdep does to work aggresively
> -=================================================
> +================================================
> +APPENDIX A: How to add dependencies aggressively
> +================================================
>  
> -A deadlock actually occurs when all wait operations creating circular
> +A deadlock actually occurs only when all waiters creating circular
>  dependencies run at the same time. Even though they don't, a potential
> -deadlock exists if the problematic dependencies exist. Thus it's
> -meaningful to detect not only an actual deadlock but also its potential
> -possibility. The latter is rather valuable. When a deadlock occurs
> -actually, we can identify what happens in the system by some means or
> -other even without lockdep. However, there's no way to detect possiblity
> -without lockdep unless the whole code is parsed in head. It's terrible.
> -Lockdep does the both, and crossrelease only focuses on the latter.
> +deadlock exists if the problematic dependencies exist.
> +
> +So we have to detect not only an actual deadlock but also its potential
> +possibility. The latter is rather valuable. When a deadlock actually
> +occurs, we can identify what happens in the system by some means or
> +other. However, there's no way to detect the possibilities without tools,
> +unless the whole code is parsed in the head. It's terrible. Lockdep does
> +the both, and crossrelease focuses on the latter.
>  
>  Whether or not a deadlock actually occurs depends on several factors.
> -For example, what order contexts are switched in is a factor. Assuming
> +For example, the order in which contexts are scheduled is a factor. If
>  circular dependencies exist, a deadlock would occur when contexts are
> -switched so that all wait operations creating the dependencies run
> -simultaneously. Thus to detect a deadlock possibility even in the case
> -that it has not occured yet, lockdep should consider all possible
> -combinations of dependencies, trying to:
> +scheduled so that all waiters creating the dependencies run at the same
> +time.
> +
> +To detect the possibilities, lockdep should consider all possible
> +scenarios aggressively, trying to:
>  
>  1. Use a global dependency graph.
>  
> @@ -776,7 +753,7 @@ combinations of dependencies, trying to:
>  
>  2. Check dependencies between classes instead of instances.
>  
> -   What actually causes a deadlock are instances of lock. However,
> +   What actually causes a deadlock are instances of locks. However,
>     lockdep checks dependencies between classes instead of instances.
>     This way lockdep can detect a deadlock which has not happened but
>     might happen in future by others but the same class.
> @@ -789,8 +766,8 @@ combinations of dependencies, trying to:
>  
>  CONCLUSION
>  
> -Lockdep detects not only an actual deadlock but also its possibility,
> -and the latter is more valuable.
> +Lockdep detects not only an actual deadlock but also its possibility
> +aggressively, and the latter is more valuable.
>  
>  
>  ==================================================
> @@ -805,44 +782,28 @@ Remind what a dependency is. A dependency exists if:
>  
>  For example:
>  
> -   acquire A
> -   acquire B /* A dependency 'A -> B' exists */
> -   release B
> -   release A
> -
> -   where A and B are different lock classes.
> -
> -A depedency 'A -> B' exists since:
> -
> -   1. A waiter for A and a waiter for B might exist when acquiring B.
> -   2. Only way to wake up each is to release what it waits for.
> -   3. Whether the waiter for A can be woken up depends on whether the
> -      other can. IOW, TASK X cannot release A if it fails to acquire B.
> -
> -For another example:
> -
> -   TASK X			   TASK Y
> -   ------			   ------
> +   CONTEXT X			   CONTEXT Y
> +   ---------			   ---------
>  				   acquire AX
>     acquire B /* A dependency 'AX -> B' exists */
>     release B
>     release AX held by Y
>  
> -   where AX and B are different lock classes, and a suffix 'X' is added
> -   on crosslocks.
> +   where AX and B are different lock classes and a suffix 'X' is added
> +   at crosslocks.
>  
> -Even in this case involving crosslocks, the same rule can be applied. A
> -depedency 'AX -> B' exists since:
> +A dependency 'AX -> B' exists since:
>  
>     1. A waiter for AX and a waiter for B might exist when acquiring B.
> -   2. Only way to wake up each is to release what it waits for.
> +   2. The only way to wake up each is to release what it waits for.
>     3. Whether the waiter for AX can be woken up depends on whether the
> -      other can. IOW, TASK X cannot release AX if it fails to acquire B.
> +      other can. In other words, CONTEXT X cannot release AX if it's
> +      stuck in the acquisition of B.
>  
> -Let's take a look at more complicated example:
> +Let's take a look at a more complicated example:
>  
> -   TASK X			   TASK Y
> -   ------			   ------
> +   CONTEXT X			   CONTEXT Y
> +   ---------			   ---------
>     acquire B
>     release B
>     fork Y
> @@ -851,22 +812,23 @@ Let's take a look at more complicated example:
>     release C
>     release AX held by Y
>  
> -   where AX, B and C are different lock classes, and a suffix 'X' is
> -   added on crosslocks.
> +   where AX, B, and C are different lock classes and a suffix 'X' is
> +   added at crosslocks.
>  
>  Does a dependency 'AX -> B' exist? Nope.
>  
>  Two waiters are essential to create a dependency. However, waiters for
>  AX and B to create 'AX -> B' cannot exist at the same time in this
> -example. Thus the dependency 'AX -> B' cannot be created.
> +example. Thus, the dependency 'AX -> B' cannot be created.
>  
>  It would be ideal if the full set of true ones can be considered. But
>  we can ensure nothing but what actually happened. Relying on what
> -actually happens at runtime, we can anyway add only true ones, though
> -they might be a subset of true ones. It's similar to how lockdep works
> -for typical locks. There might be more true dependencies than what
> -lockdep has detected in runtime. Lockdep has no choice but to rely on
> -what actually happens. Crossrelease also relies on it.
> +actually happens at runtime, we can avoid adding false ones anyway,
> +they might be a subset of true ones though.
> +
> +It's similar to how lockdep works for typical locks. There might be more
> +true dependencies than lockdep has detected. Lockdep has no choice but
> +to rely on what actually happens. Crossrelease also relies on it.
>  
>  CONCLUSION
>  
> -- 
> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
