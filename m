Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C7B016B0069
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 11:47:50 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id q92so78317841ioi.3
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 08:47:50 -0700 (PDT)
Received: from mail-io0-x22b.google.com (mail-io0-x22b.google.com. [2607:f8b0:4001:c06::22b])
        by mx.google.com with ESMTPS id x66si13695198ioi.203.2016.09.16.08.47.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Sep 2016 08:47:48 -0700 (PDT)
Received: by mail-io0-x22b.google.com with SMTP id q92so29938035ioi.1
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 08:47:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1473759914-17003-16-git-send-email-byungchul.park@lge.com>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com> <1473759914-17003-16-git-send-email-byungchul.park@lge.com>
From: Nilay Vaish <nilayvaish@gmail.com>
Date: Fri, 16 Sep 2016 10:47:06 -0500
Message-ID: <CACbG30_Nh_AEY8CC2TzbUO2rnZuBvVNfUYDwgYaTsRuE-nJRPg@mail.gmail.com>
Subject: Re: [PATCH v3 15/15] lockdep: Crossrelease feature documentation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On 13 September 2016 at 04:45, Byungchul Park <byungchul.park@lge.com> wrote:
> This document describes the concept of crossrelease feature, which
> generalizes what causes a deadlock and how can detect a deadlock.
>
> Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> ---
>  Documentation/locking/crossrelease.txt | 785 +++++++++++++++++++++++++++++++++
>  1 file changed, 785 insertions(+)
>  create mode 100644 Documentation/locking/crossrelease.txt
>
> diff --git a/Documentation/locking/crossrelease.txt b/Documentation/locking/crossrelease.txt
> new file mode 100644
> index 0000000..78558af
> --- /dev/null
> +++ b/Documentation/locking/crossrelease.txt
> @@ -0,0 +1,785 @@
> +Crossrelease
> +============
> +
> +Started by Byungchul Park <byungchul.park@lge.com>
> +
> +Contents:
> +
> + (*) Background.
> +
> +     - What causes deadlock.
> +     - What lockdep detects.
> +     - How lockdep works.
> +
> + (*) Limitation.
> +
> +     - Limit to typical lock.
> +     - Pros from the limitation.
> +     - Cons from the limitation.
> +
> + (*) Generalization.
> +
> +     - Relax the limitation.
> +
> + (*) Crossrelease.
> +
> +     - Introduce crossrelease.
> +     - Introduce commit.
> +
> + (*) Implementation.
> +
> +     - Data structures.
> +     - How crossrelease works.
> +
> + (*) Optimizations.
> +
> +     - Avoid duplication.
> +     - Avoid lock contention.
> +
> +
> +==========
> +Background
> +==========
> +
> +What causes deadlock
> +--------------------
> +
> +A deadlock occurs when a context is waiting for an event to be issued
> +which cannot be issued because the context or another context who can
> +issue the event is also waiting for an event to be issued which cannot
> +be issued.

I think 'some event happened' and 'context triggered an event' is
better than 'some event issued' or 'context issued an event'.  I think
'happen' and 'trigger' are more widely used words when we talk about
events.  For example, I would prefer the following version of the
above:

A deadlock occurs when a context is waiting for an event to happen,
which cannot happen because the context which can trigger the event is
also waiting for an event to happen which cannot happen either.

> +Single context or more than one context both waiting for an
> +event and issuing an event may paricipate in a deadlock.

I am not able to make sense of the line above.

> +
> +For example,
> +
> +A context who can issue event D is waiting for event A to be issued.
> +A context who can issue event A is waiting for event B to be issued.
> +A context who can issue event B is waiting for event C to be issued.
> +A context who can issue event C is waiting for event D to be issued.
> +
> +A deadlock occurs when these four operations are run at a time because
> +event D cannot be issued if event A isn't issued which in turn cannot be
> +issued if event B isn't issued which in turn cannot be issued if event C
> +isn't issued which in turn cannot be issued if event D isn't issued. No
> +event can be issued since any of them never meets its precondition.
> +
> +We can easily recognize that each wait operation creates a dependency
> +between two issuings e.g. between issuing D and issuing A like, 'event D
> +cannot be issued if event A isn't issued', in other words, 'issuing
> +event D depends on issuing event A'. So the whole example can be
> +rewritten in terms of dependency,
> +
> +Do an operation making 'event D cannot be issued if event A isn't issued'.
> +Do an operation making 'event A cannot be issued if event B isn't issued'.
> +Do an operation making 'event B cannot be issued if event C isn't issued'.
> +Do an operation making 'event C cannot be issued if event D isn't issued'.
> +
> +or,

I think we can remove the text above.  The example only needs to be
provided once.

> +
> +Do an operation making 'issuing event D depends on issuing event A'.
> +Do an operation making 'issuing event A depends on issuing event B'.
> +Do an operation making 'issuing event B depends on issuing event C'.
> +Do an operation making 'issuing event C depends on issuing event D'.
> +
> +What causes a deadlock is a set of dependencies a chain of which forms a
> +cycle, which means that issuing event D depending on issuing event A
> +depending on issuing event B depending on issuing event C depending on
> +issuing event D, finally depends on issuing event D itself, which means
> +no event can be issued.
> +
> +Any set of operations creating dependencies causes a deadlock. The set
> +of lock operations e.g. acquire and release is an example. Waiting for a
> +lock to be released corresponds to waiting for an event and releasing a
> +lock corresponds to issuing an event. So the description of dependency
> +above can be altered to one in terms of lock.
> +
> +In terms of event, issuing event A depends on issuing event B if,
> +
> +       Event A cannot be issued if event B isn't issued.
> +
> +In terms of lock, releasing lock A depends on releasing lock B if,
> +
> +       Lock A cannot be released if lock B isn't released.
> +
> +CONCLUSION
> +
> +A set of dependencies a chain of which forms a cycle, causes a deadlock,

I think 'a chain of' is not required in the sentence above.

> +no matter what creates the dependencies.
> +
> +
> +What lockdep detects
> +--------------------
> +
> +A deadlock actually occurs only when all operations creating problematic

Instead of 'problematic', I would use 'cyclic'.

> +dependencies are run at a time. However, even if it has not happend, the

dependencies happen at run time.  However, even if they don't, the

> +deadlock potentially can occur if the problematic dependencies obviously

remove obviously

> +exist. Thus it's meaningful to detect not only an actual deadlock but
> +also its possibility. Lockdep does the both.
> +
> +Whether a deadlock actually occurs or not depends on several factors,
> +which means a deadlock may not occur even though problematic

cyclic instead of problematic

> +dependencies exist. For example, what order contexts are switched in is
> +a factor. A deadlock will occur when contexts are switched so that all
> +operations causing a deadlock become run simultaneously.

delete become.

> +
> +Lockdep tries to detect a deadlock or its possibility aggressively,
> +though it also tries to avoid false positive detections. So lockdep is
> +designed to consider all possible combinations of dependencies so that
> +it can detect all potential possibilities of deadlock in advance. What
> +lockdep tries in order to consider all possibilities are,
> +
> +1. Use a global dependency graph including all dependencies.
> +
> +   What lockdep checks is based on dependencies instead of what actually
> +   happened. So no matter which context or call path a new dependency is
> +   detected in, it's just referred to as a global factor.

Can you explain more what 'global factor' means?


> +
> +2. Use lock classes than lock instances when checking dependencies.
> +
> +   What actually causes a deadlock is lock instances. However, lockdep
> +   uses lock classes than its instances when checking dependencies since
> +   any instance of a same lock class can be altered anytime.

I am unable to make sense of the sentence above.  Do you want to say
the following:

However, lockdep uses lock classes than its instances when checking
dependencies since instances from the same lock class behave in the
same (or similar) fashion.

> +
> +So lockdep detects both an actual deadlock and its possibility. But the
> +latter is more valuable than the former. When a deadlock actually
> +occures, we can identify what happens in the system by some means or
> +other even without lockdep. However, there's no way to detect possiblity
> +without lockdep unless the whole code is parsed in head. It's terrible.
> +
> +CONCLUSION
> +
> +Lockdep does, the fisrt one is more valuable,
> +
> +1. Detecting and reporting deadlock possibility.
> +2. Detecting and reporting a deadlock actually occured.
> +
> +
> +How lockdep works
> +-----------------
> +
> +What lockdep should do, to detect a deadlock or its possibility are,
> +
> +1. Detect a new dependency created.
> +2. Keep the dependency in a global data structure esp. graph.
> +3. Check if any of all possible chains of dependencies forms a cycle.
> +4. Report a deadlock or its possibility if a cycle is detected.
> +
> +A graph used by lockdep to keep all dependencies looks like,
> +
> +A -> B -        -> F -> G
> +        \      /
> +         -> E -        -> L
> +        /      \      /
> +C -> D -        -> H -
> +                      \
> +                       -> I -> K
> +                      /
> +                   J -
> +
> +where A, B,..., L are different lock classes.
> +
> +Lockdep adds a dependency into graph when a new dependency is detected.
> +For example, it adds a dependency 'A -> B' when a dependency between
> +releasing lock A and releasing lock B, which has not been added yet, is
> +detected. It does same thing on other dependencies, too. See 'What
> +causes deadlock' section.

Just from the text above I am not able to understand at what point the
dependency A-> B is added.  If I was implementing lockdep, I would
probably track all the locks that can be acquired between acquisition
and release of A.  For example,

acquire A

if (/* some condition */)
    acquire B
else
    acquire C

release A


I would add to the dependency graph that 'release A' depends on
'acquire B' and 'acquire C'.

> +
> +NOTE: Precisely speaking, a dependency is one between releasing a lock
> +and releasing another lock as described in 'What causes deadlock'
> +section. However from now on, we will describe a dependency as if it's
> +one between a lock and another lock for simplicity. Then 'A -> B' can be
> +described as a dependency between lock A and lock B.
> +
> +We already checked how a problematic set of dependencies causes a
> +deadlock in 'What causes deadlock' section. This time let's check if a
> +deadlock or its possibility can be detected using a problematic set of
> +dependencies. Assume that 'A -> B', 'B -> E' and 'E -> A' were added in
> +the sequence into graph. Then the graph finally will be,
> +
> + -> A -> B -> E -
> +/                \
> +\                /
> + ----------------
> +
> +where A, B and E are different lock classes.
> +
> +From adding three dependencies, a cycle was created which means, by
> +definition of dependency, the situation 'lock E must be released to
> +release lock B which in turn must be released to release lock A which in
> +turn must be released to release lock E which in turn must be released
> +to release B and so on infinitely' can happen.
> +
> +Once the situation happens, no lock can be released since any of them
> +can never meet each precondition. It's a deadlock. Lockdep can detect a
> +deadlock or its possibility with checking if a cycle was created after
> +adding each dependency into graph. This is how lockdep detects a
> +deadlock or its possibility.

I think the text here is just repeating what was said above in the
'What causes deadlock' section.  You probably should remove of the
text here.

> +
> +CONCLUSION
> +
> +Lockdep detects a deadlock or its possibility with checking if a cycle
> +was created after adding each dependency into graph.
> +
> +
> +==========
> +Limitation
> +==========
> +
> +Limit to typical lock
> +---------------------
> +
> +Limiting what lockdep has to consider to only ones satisfying the
> +following condition, the implementation of adding dependencies becomes
> +simple while its capacity for detection becomes limited. Typical lock
> +e.g. spin lock and mutex is the case. Let's check what pros and cons of
> +it are, in next section.
> +
> +       A lock should be released within the context holding the lock.

I would rephrase the above in the following way:  Lockdep is limited
to checking dependencies on locks that are released within the context
that acquired them.  This makes adding dependencies simple but limits
lockdep's capacity for detection.


> +
> +CONCLUSION
> +
> +Limiting what lockdep has to consider to typical lock e.g. spin lock and
> +mutex, the implmentation becomes simple while it has a limited capacity.

I would drop the conclusion altogether.  The above paragraph is too
small to require a conclusion.

> +
> +
> +Pros from the limitation
> +------------------------
> +
> +Given the limitation, when acquiring a lock, any lock being in
> +held_locks of the acquire context cannot be released if the lock to

What does held_locks mean here?  Is it some structure maintained by
the Linux kernel?

> +acquire was not released yet. Yes. It's the exact case to add a new
> +dependency 'A -> B' into graph, where lock A represents each lock being
> +in held_locks and lock B represents the lock to acquire.
> +
> +For example, only considering typical lock,
> +
> +       PROCESS X
> +       --------------
> +       acquire A
> +
> +       acquire B -> add a dependency 'A -> B'
> +
> +       acquire C -> add a dependency 'B -> C'
> +
> +       release C
> +
> +       release B
> +
> +       release A
> +
> +where A, B and C are different lock classes.
> +
> +When acquiring lock A, there's nothing in held_locks of PROCESS X thus
> +no dependency is added. When acquiring lock B, lockdep detects and adds
> +a new dependency 'A -> B' between lock A being in held_locks and lock B.
> +And when acquiring lock C, lockdep also adds another dependency 'B -> C'
> +for same reason. They are added when acquiring each lock, simply.
> +
> +NOTE: Even though every lock being in held_locks depends on the lock to
> +acquire, lockdep does not add all dependencies between them because all
> +of them can be covered by other dependencies except one dependency
> +between the lock on top of held_locks and the lock to acquire, which
> +must be added.

I am unable to understand the above sentence.  Can you break it into
two more sentences?

> +
> +Besides, we can expect several advantages from the limitation.
> +
> +1. Any lock being in held_locks cannot be released unconditionally if
> +   the context is stuck, thus we can easily identify a dependency when
> +   acquiring a lock.
> +
> +2. Considering only locks being in local held_locks of a single context
> +   makes some races avoidable, even though it fails of course when
> +   modifying its global dependency graph.
> +
> +3. To build a dependency graph, lockdep only needs to keep locks not
> +   released yet. However relaxing the limitation, it might need to keep
> +   even locks already released, additionally. See 'Crossrelease' section.
> +
> +CONCLUSION
> +
> +Given the limitation, the implementation becomes simple and efficient.
> +
> +
> +Cons from the limitation
> +------------------------
> +
> +Given the limitation, lockdep is applicable only to typical lock. For
> +example, page lock for page access or completion for synchronization
> +cannot play with lockdep having the limitation. However since page lock
> +or completion also causes a deadlock, it would be better to detect a
> +deadlock or its possibility even for them.
> +
> +Can we detect deadlocks below with lockdep having the limitation?
> +
> +Example 1:
> +
> +       PROCESS X       PROCESS Y
> +       --------------  --------------
> +       mutext_lock A
> +                       lock_page B
> +       lock_page B
> +                       mutext_lock A // DEADLOCK
> +       unlock_page B
> +                       mutext_unlock A
> +       mutex_unlock A
> +                       unlock_page B
> +
> +where A and B are different lock classes.

I think the formatting is slightly off.  The events corresponding to
process Y should be shifted more towards right.  The vertical ordering
would still clearly indicate the order in which the events happened.


> +
> +No, we cannot.

I do not follow this example.  The context that acquired the mutex A
or lock B also released it.  Should not lockdep be able to detect
this?  I am guessing I have misunderstood which events occurred in
which context.   Here is what I think the example is showing:

X acquired mutex A --> Y acquired lock B --> X tries to acquire B -->
Y tries to acquire A -->  X and Y are in a deadlock since each of them
holds a resource that the other needs.

> +
> +Example 2:
> +
> +       PROCESS X       PROCESS Y       PROCESS Z
> +       --------------  --------------  --------------
> +                       mutex_lock A
> +       lock_page B
> +                       lock_page B
> +                                       mutext_lock A // DEADLOCK
> +                                       mutext_unlock A
> +
> +                                       unlock_page B held by X
> +                       unlock_page B
> +                       mutex_unlock A
> +
> +where A and B are different lock classes.
> +
> +No, we cannot.
> +
> +Example 3:
> +
> +       PROCESS X       PROCESS Y
> +       --------------  --------------
> +                       mutex_lock A
> +       mutex_lock A
> +       mutex_unlock A
> +                       wait_for_complete B // DEADLOCK
> +       complete B
> +                       mutex_unlock A
> +
> +where A is a lock class and B is a completion variable.
> +
> +No, we cannot.
> +
> +CONCLUSION
> +
> +Given the limitation, lockdep cannot detect a deadlock or its
> +possibility caused by page lock or completion.
> +
> +
> +==============
> +Generalization
> +==============
> +
> +Relax the limitation
> +--------------------
> +
> +Detecting and adding new dependencies into graph is very important for
> +lockdep to work because adding a dependency means adding a chance to
> +check if it causes a deadlock. More dependencies lockdep adds, more
> +throughly it can work. Therefore Lockdep has to do its best to add as
> +many true dependencies as possible.
> +
> +Relaxing the limitation, lockdep can add additional dependencies since
> +it makes lockdep deal with additional ones creating the dependencies e.g.
> +page lock or completion, which might be released in any context. Even so,
> +it needs to be noted that behaviors adding dependencies created by
> +typical lock don't need to be changed at all.
> +
> +For example, only considering typical lock, lockdep builds a graph like,
> +
> +A -> B -        -> F -> G
> +        \      /
> +         -> E -        -> L
> +        /      \      /
> +C -> D -        -> H -
> +                      \
> +                       -> I -> K
> +                      /
> +                   J -
> +
> +where A, B,..., L are different lock classes, and upper case letters
> +represent typical lock.
> +
> +After the relaxing, the graph will have additional dependencies like,
> +
> +A -> B -        -> F -> G
> +        \      /
> +         -> E -        -> L -> c
> +        /      \      /
> +C -> D -        -> H -
> +               /      \
> +            a -        -> I -> K
> +                      /
> +              b -> J -
> +
> +where a, b, c, A, B,..., L are different lock classes, and upper case
> +letters represent typical lock while lower case letters represent
> +non-typical lock e.g. page lock and completion.
> +
> +However, it might suffer performance degradation since relaxing the
> +limitation with which design and implementation of lockdep become
> +efficient might introduce inefficiency inevitably. Each option, that is,
> +strong detection or efficient detection has its pros and cons, thus the
> +right of choice between two options should be given to users.
> +
> +Choosing efficient detection, lockdep only deals with locks satisfying,
> +
> +       A lock should be released within the context holding the lock.
> +
> +Choosing strong detection, lockdep deals with any locks satisfying,
> +
> +       A lock can be released in any context.
> +
> +In the latter, of course, some contexts are not allowed if they
> +themselves cause a deadlock. For example, acquiring a lock in irq-safe
> +context before releasing the lock in irq-unsafe context is not allowed,
> +which after all ends in a cycle of a dependency chain, meaning a
> +deadlock. Otherwise, any contexts are allowed to release it.
> +
> +CONCLUSION
> +
> +Relaxing the limitation, lockdep adds additional dependencies and gets
> +additional chances to check if they cause a deadlock. It makes lockdep
> +additionally deal with what might be released in any context.
> +
> +
> +============
> +Crossrelease
> +============
> +
> +Introduce crossrelease
> +----------------------
> +
> +To allow lockdep to add additional dependencies created by what might be
> +released in any context, which we call 'crosslock', it's necessary to
> +introduce a new feature which makes it possible to identify and add the
> +dependencies. We call the feature 'crossrelease'. Crossrelease feature
> +has to do,
> +
> +1. Identify a new dependency created by crosslock.
> +2. Add the dependency into graph when identifying it.
> +
> +That's all. Once a meaningful dependency is added into graph, lockdep
> +will work with the graph as it did. So the most important thing to do is
> +to identify a dependency created by crosslock. Remind what a dependency
> +is. For example, Lock A depends on lock B if 'lock A cannot be released
> +if lock B isn't released'. See 'What causes deadlock' section.
> +
> +By definition, a lock depends on every lock having been added into
> +held_locks in the lock's release context since the lock was acquired,
> +because the lock cannot be released if the release context is stuck by
> +any of dependent locks, not released. So lockdep should technically
> +consider release contexts of locks to identify dependencies.
> +
> +It's no matter of course to typical lock because acquire context is same
> +as release context for typical lock, which means lockdep would work with
> +considering only acquire contexts for typical lock. However, for
> +crosslock, lockdep cannot identify release context and any dependency
> +until the crosslock will be actually released.
> +
> +Regarding crosslock, lockdep has to record all history by queueing all
> +locks potentially creating dependencies so that real dependencies can be
> +added using the history recorded when identifying release context. We
> +call it 'commit', that is, to add dependencies in batches. See
> +'Introduce commit' section.
> +
> +Of course, some actual deadlocks caused by crosslock cannot be detected
> +at the time it happened, because the deadlocks cannot be indentified and
> +detected until the crosslock will be actually released. But this way
> +deadlock possibility can be detected and it's worth just possibility
> +detection of deadlock. See 'What lockdep does' section.
> +
> +CONCLUSION
> +
> +With crossrelease feature, lockdep can works with what might be released
> +in any context, namely, crosslock.
> +
> +
> +Introduce commit
> +----------------
> +
> +Crossrelease feature names it 'commit' to identify and add dependencies
> +into graph in batches. Lockdep is already doing what commit does when
> +acquiring a lock, for typical lock. However, that way must be changed
> +for crosslock so that it identifies the crosslock's release context
> +first and then does commit.
> +
> +The main reason why lockdep performs additional step, namely commit, for
> +crosslock is that some dependencies by crosslock cannot be identified
> +until the crosslock's release context is eventually identified, though
> +some other dependencies by crosslock can. There are four kinds of
> +dependencies to consider.
> +
> +1. 'typical lock A -> typical lock B' dependency
> +
> +   Just when acquiring lock B, lockdep can identify the dependency
> +   between lock A and lock B as it did. Commit is unnecessary.
> +
> +2. 'typical lock A -> crosslock b' dependency
> +
> +   Just when acquiring crosslock b, lockdep can identify the dependency
> +   between lock A and crosslock B as well. Commit is unnecessary, too.
> +
> +3. 'crosslock a -> typical lock B' dependency
> +
> +   When acquiring lock B, lockdep cannot identify the dependency. It can
> +   be identified only when crosslock a is released. Commit is necessary.
> +
> +4. 'crosslock a -> crosslock b' dependency
> +
> +   Creating this kind of dependency directly is unnecessary since it can
> +   be covered by other kinds of dependencies.
> +
> +Lockdep works without commit during dealing with only typical locks.
> +However, it needs to perform commit step, once at least one crosslock is
> +acquired, until all crosslocks in progress are released. Introducing
> +commit, lockdep performs three steps i.e. acquire, commit and release.
> +What lockdep should do in each step is like,
> +
> +1. Acquire
> +
> +   1) For typical lock
> +
> +       Lockdep does what it originally does and queues the lock so
> +       that lockdep can check dependencies using it at commit step.
> +
> +   2) For crosslock
> +
> +       The crosslock is added to a global linked list so that lockdep
> +       can check dependencies using it at commit step.
> +
> +2. Commit
> +
> +   1) For typical lock
> +
> +       N/A.
> +
> +   2) For crosslock
> +
> +       Lockdep checks and adds dependencies using data saved at acquire
> +       step, as if the dependencies were added without commit step.
> +
> +3. Release
> +
> +   1) For typical lock
> +
> +       No change.
> +
> +   2) For crosslock
> +
> +       Lockdep just remove the crosslock from the global linked list,
> +       to which it was added at acquire step.
> +
> +CONCLUSION
> +
> +Lockdep can detect a deadlock or its possibility caused by what might be
> +released in any context, using commit step, where it checks and adds
> +dependencies in batches.
> +
> +
> +==============
> +Implementation
> +==============
> +
> +Data structures
> +---------------
> +
> +Crossrelease feature introduces two main data structures.
> +
> +1. pend_lock (or plock)
> +
> +   This is an array embedded in task_struct, for keeping locks queued so
> +   that real dependencies can be added using them at commit step. So
> +   this data can be accessed locklessly within the owner context. The
> +   array is filled when acquiring a typical lock and consumed when doing
> +   commit. And it's managed in circular manner.
> +
> +2. cross_lock (or xlock)
> +
> +   This is a global linked list, for keeping all crosslocks in progress.
> +   The list grows when acquiring a crosslock and is shrunk when
> +   releasing the crosslock. lockdep_init_map_crosslock() should be used
> +   to initialize a crosslock instance instead of lockdep_init_map() so
> +   that lockdep can recognize it as crosslock.
> +
> +CONCLUSION
> +
> +Crossrelease feature uses two main data structures.
> +
> +1. A pend_lock array for queueing typical locks in circular manner.
> +2. A cross_lock linked list for managing crosslocks in progress.
> +

Drop these conclusion, not need at all.


> +
> +How crossrelease works
> +----------------------
> +
> +Let's take look at how crossrelease feature works step by step, starting
> +from how lockdep works without crossrelease feaure.
> +
> +For example, the below is how lockdep works for typical lock.
> +
> +       RELEASE CONTEXT of A (= ACQUIRE CONTEXT of A)
> +       --------------------
> +       acquire A
> +
> +       acquire B -> add a dependency 'A -> B'
> +
> +       acquire C -> add a dependency 'B -> C'
> +
> +       release C
> +
> +       release B
> +
> +       release A
> +
> +where A, B and C are different lock classes, and upper case letters
> +represent typical lock.
> +
> +After adding 'A -> B', the dependency graph will be,
> +
> +A -> B
> +
> +where A and B are different lock classes, and upper case letters
> +represent typical lock.
> +
> +And after adding 'B -> C', the graph will be,
> +
> +A -> B -> C
> +
> +where A, B and C are different lock classes, and upper case letters
> +represent typical lock.
> +
> +What if applying commit on typical locks? It's not necessary for typical
> +lock. Just for showing what commit does.
> +
> +       RELEASE CONTEXT of A (= ACQUIRE CONTEXT of A)
> +       --------------------
> +       acquire A -> mark A as started (nothing before, no queueing)
> +
> +       acquire B -> mark B as started and queue B
> +
> +       acquire C -> mark C as started and queue C
> +
> +       release C -> commit C (nothing queued since C started)
> +
> +       release B -> commit B -> add a dependency 'B -> C'
> +
> +       release A -> commit A -> add dependencies 'A -> B' and 'A -> C'
> +
> +where A, B and C are different lock classes, and upper case letters
> +represent typical lock.
> +
> +After doing commit A, B and C, the dependency graph becomes like,
> +
> +A -> B -> C
> +
> +where A, B and C are different lock classes, and upper case letters
> +represent typical lock.
> +
> +NOTE: A dependency 'A -> C' is optimized out.
> +
> +Here we can see the final graph is same as the graph built without
> +commit. Of course the former way leads to finish building the graph
> +earlier than the latter way, which means we can detect a deadlock or its
> +possibility sooner. So the former way would be prefered if possible. But
> +we cannot avoid using the latter way using commit, for crosslock.
> +
> +Let's look at how commit works for crosslock.
> +
> +       RELEASE CONTEXT of a    ACQUIRE CONTEXT of a
> +       --------------------    --------------------
> +                               acquire a -> mark a as started
> +
> +       (serialized by some means e.g. barrier)
> +
> +       acquire D -> queue D
> +                               acquire B -> queue B
> +       release D
> +                               acquire C -> add 'B -> C' and queue C
> +       acquire E -> queue E
> +                               acquire D -> add 'C -> D' and queue D
> +       release E
> +                               release D
> +       release a -> commit a -> add 'a -> D' and 'a -> E'
> +                               release C
> +
> +                               release B
> +
> +where a, B,..., E are different lock classes, and upper case letters
> +represent typical lock while lower case letters represent crosslock.
> +
> +When acquiring crosslock a, no dependency can be added since there's
> +nothing in the held_locks. However, crossrelease feature marks the
> +crosslock as started, which means all locks to acquire from now are
> +candidates which might create new dependencies later when identifying
> +release context.
> +
> +When acquiring lock B, lockdep does what it originally does for typical
> +lock and additionally queues the lock for later commit to refer to
> +because it might be a dependent lock of the crosslock. It does same
> +thing on lock C, D and E. And then two dependencies 'a -> D' and 'a -> E'
> +are added when identifying the release context, at commit step.
> +
> +The final graph is, with crossrelease feature using commit,
> +
> +B -> C -
> +        \
> +         -> D
> +        /
> +     a -
> +        \
> +         -> E
> +

Would not the graph also contain edges a->B and a->C, which lockdep
would add as it usually does?


> +where a, B,..., E are different lock classes, and upper case letters
> +represent typical lock while lower case letters represent crosslock.
> +
> +However, without crossrelease feature, the final graph will be,
> +
> +B -> C -> D
> +
> +where B and C are different lock classes, and upper case letters
> +represent typical lock.
> +
> +The former graph has two more dependencies 'a -> D' and 'a -> E' giving
> +additional chances to check if they cause a deadlock. This way lockdep
> +can detect a deadlock or its possibility caused by crosslock. Again,
> +behaviors adding dependencies created by only typical locks are not
> +changed at all.
> +
> +CONCLUSION
> +
> +Crossrelease works using commit for crosslock, leaving behaviors adding
> +dependencies between only typical locks unchanged.
> +
> +
> +=============
> +Optimizations
> +=============
> +
> +Avoid duplication
> +-----------------
> +
> +Crossrelease feature uses a cache like what lockdep already uses for
> +dependency chains, but this time it's for caching one dependency like
> +'crosslock -> typical lock' crossing between two different context. Once
> +that dependency is cached, same dependency will never be added any more.
> +Even queueing unnecessary locks is also prevented based on the cache.
> +
> +CONCLUSION
> +
> +Crossrelease does not add any duplicate dependency.
> +

No need for conclusion.

> +
> +Avoid lock contention
> +---------------------
> +
> +To keep all typical locks for later use, crossrelease feature adopts a
> +local array embedded in task_struct, which makes accesses to arrays
> +lockless by forcing each array to be accessed only within each own
> +context. It's like how held_locks is accessed. Lockless implmentation is
> +important since typical locks are very frequently accessed.
> +
> +CONCLUSION
> +
> +Crossrelease avoids lock contection as far as possible.
> --
> 1.9.1
>


No need for conclusion.


Overall, I think I have generally understood what you are trying to do
and how are doing it.  I think now I'll be able to better review the
patches with actual.

Thanks!
Nilay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
