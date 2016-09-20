Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id C97BD6B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 01:03:28 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g22so26169954ioj.1
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 22:03:28 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id b204si25717966itc.126.2016.09.19.22.03.27
        for <linux-mm@kvack.org>;
        Mon, 19 Sep 2016 22:03:27 -0700 (PDT)
Date: Tue, 20 Sep 2016 14:00:19 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v3 15/15] lockdep: Crossrelease feature documentation
Message-ID: <20160920045556.GK2279@X58A-UD3R>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <1473759914-17003-16-git-send-email-byungchul.park@lge.com>
 <CACbG30_Nh_AEY8CC2TzbUO2rnZuBvVNfUYDwgYaTsRuE-nJRPg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACbG30_Nh_AEY8CC2TzbUO2rnZuBvVNfUYDwgYaTsRuE-nJRPg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nilay Vaish <nilayvaish@gmail.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Fri, Sep 16, 2016 at 10:47:06AM -0500, Nilay Vaish wrote:
> > +==========
> > +Background
> > +==========
> > +
> > +What causes deadlock
> > +--------------------
> > +
> > +A deadlock occurs when a context is waiting for an event to be issued
> > +which cannot be issued because the context or another context who can
> > +issue the event is also waiting for an event to be issued which cannot
> > +be issued.
> 
> I think 'some event happened' and 'context triggered an event' is
> better than 'some event issued' or 'context issued an event'.  I think
> 'happen' and 'trigger' are more widely used words when we talk about
> events.  For example, I would prefer the following version of the
> above:
> 
> A deadlock occurs when a context is waiting for an event to happen,
> which cannot happen because the context which can trigger the event is
> also waiting for an event to happen which cannot happen either.

Looks good.

> 
> > +Single context or more than one context both waiting for an
> > +event and issuing an event may paricipate in a deadlock.
> 
> I am not able to make sense of the line above.

I meant that only one context can be in deadlock by itself, like

A
=
lock a <= waiting
lock b
lock a
unlock a <= triggering
unlock b
unlock a

and more than one context also can be in deadlock, like

A		B
=		=
lock b		lock a
lock a		lock b
unlock a	unlock b
unlock b	unlock a

Is there any alterative to describ it?

> 
> > +
> > +For example,
> > +
> > +A context who can issue event D is waiting for event A to be issued.
> > +A context who can issue event A is waiting for event B to be issued.
> > +A context who can issue event B is waiting for event C to be issued.
> > +A context who can issue event C is waiting for event D to be issued.
> > +
> > +A deadlock occurs when these four operations are run at a time because
> > +event D cannot be issued if event A isn't issued which in turn cannot be
> > +issued if event B isn't issued which in turn cannot be issued if event C
> > +isn't issued which in turn cannot be issued if event D isn't issued. No
> > +event can be issued since any of them never meets its precondition.
> > +
> > +We can easily recognize that each wait operation creates a dependency
> > +between two issuings e.g. between issuing D and issuing A like, 'event D
> > +cannot be issued if event A isn't issued', in other words, 'issuing
> > +event D depends on issuing event A'. So the whole example can be
> > +rewritten in terms of dependency,
> > +
> > +Do an operation making 'event D cannot be issued if event A isn't issued'.
> > +Do an operation making 'event A cannot be issued if event B isn't issued'.
> > +Do an operation making 'event B cannot be issued if event C isn't issued'.
> > +Do an operation making 'event C cannot be issued if event D isn't issued'.
> > +
> > +or,
> 
> I think we can remove the text above.  The example only needs to be
> provided once.

I tried not to miss any subtle desciption AFAP. I thought and decided that
I need to explain what a dependecy is, without any hole in logic.

> 
> > +
> > +Do an operation making 'issuing event D depends on issuing event A'.
> > +Do an operation making 'issuing event A depends on issuing event B'.
> > +Do an operation making 'issuing event B depends on issuing event C'.
> > +Do an operation making 'issuing event C depends on issuing event D'.
> > +
> > +What causes a deadlock is a set of dependencies a chain of which forms a
> > +cycle, which means that issuing event D depending on issuing event A
> > +depending on issuing event B depending on issuing event C depending on
> > +issuing event D, finally depends on issuing event D itself, which means
> > +no event can be issued.
> > +
> > +Any set of operations creating dependencies causes a deadlock. The set
> > +of lock operations e.g. acquire and release is an example. Waiting for a
> > +lock to be released corresponds to waiting for an event and releasing a
> > +lock corresponds to issuing an event. So the description of dependency
> > +above can be altered to one in terms of lock.
> > +
> > +In terms of event, issuing event A depends on issuing event B if,
> > +
> > +       Event A cannot be issued if event B isn't issued.
> > +
> > +In terms of lock, releasing lock A depends on releasing lock B if,
> > +
> > +       Lock A cannot be released if lock B isn't released.
> > +
> > +CONCLUSION
> > +
> > +A set of dependencies a chain of which forms a cycle, causes a deadlock,
> 
> I think 'a chain of' is not required in the sentence above.

Do you think so? Actually a chain forms a cycle. I thought dependencies
are not stuffs making a cycle.

> 
> > +no matter what creates the dependencies.
> > +
> > +
> > +What lockdep detects
> > +--------------------
> > +
> > +A deadlock actually occurs only when all operations creating problematic
> 
> Instead of 'problematic', I would use 'cyclic'.

I'd like to highlight _problematic_. Is it better to use a specific word,
like 'cycle'?

> 
> > +dependencies are run at a time. However, even if it has not happend, the
> 
> dependencies happen at run time.  However, even if they don't, the

It ends in "operations happen". Is it a right expression?

> 
> > +deadlock potentially can occur if the problematic dependencies obviously
> 
> remove obviously

Ok.

> 
> > +exist. Thus it's meaningful to detect not only an actual deadlock but
> > +also its possibility. Lockdep does the both.
> > +
> > +Whether a deadlock actually occurs or not depends on several factors,
> > +which means a deadlock may not occur even though problematic
> 
> cyclic instead of problematic
> 
> > +dependencies exist. For example, what order contexts are switched in is
> > +a factor. A deadlock will occur when contexts are switched so that all
> > +operations causing a deadlock become run simultaneously.
> 
> delete become.

Ok.

> 
> > +
> > +Lockdep tries to detect a deadlock or its possibility aggressively,
> > +though it also tries to avoid false positive detections. So lockdep is
> > +designed to consider all possible combinations of dependencies so that
> > +it can detect all potential possibilities of deadlock in advance. What
> > +lockdep tries in order to consider all possibilities are,
> > +
> > +1. Use a global dependency graph including all dependencies.
> > +
> > +   What lockdep checks is based on dependencies instead of what actually
> > +   happened. So no matter which context or call path a new dependency is
> > +   detected in, it's just referred to as a global factor.
> 
> Can you explain more what 'global factor' means?

I'm sorry. My words might be wrong. :(
I wanted to say "there's only one global data managing dependencies".

> 
> 
> > +
> > +2. Use lock classes than lock instances when checking dependencies.
> > +
> > +   What actually causes a deadlock is lock instances. However, lockdep
> > +   uses lock classes than its instances when checking dependencies since
> > +   any instance of a same lock class can be altered anytime.
> 
> I am unable to make sense of the sentence above.  Do you want to say
> the following:
> 
> However, lockdep uses lock classes than its instances when checking
> dependencies since instances from the same lock class behave in the
> same (or similar) fashion.

I wanted to say,

For example,

do_handle_something(struct data *d)
{
  lock d->a of class A
  handle data protected by d->a
  unlcok d->a
}

where d can be different between calls but it's always one of class A.

I expressed it as 'altered'.

> 
> > +
> > +So lockdep detects both an actual deadlock and its possibility. But the
> > +latter is more valuable than the former. When a deadlock actually
> > +occures, we can identify what happens in the system by some means or
> > +other even without lockdep. However, there's no way to detect possiblity
> > +without lockdep unless the whole code is parsed in head. It's terrible.
> > +
> > +CONCLUSION
> > +
> > +Lockdep does, the fisrt one is more valuable,
> > +
> > +1. Detecting and reporting deadlock possibility.
> > +2. Detecting and reporting a deadlock actually occured.
> > +
> > +
> > +How lockdep works
> > +-----------------
> > +
> > +What lockdep should do, to detect a deadlock or its possibility are,
> > +
> > +1. Detect a new dependency created.
> > +2. Keep the dependency in a global data structure esp. graph.
> > +3. Check if any of all possible chains of dependencies forms a cycle.
> > +4. Report a deadlock or its possibility if a cycle is detected.
> > +
> > +A graph used by lockdep to keep all dependencies looks like,
> > +
> > +A -> B -        -> F -> G
> > +        \      /
> > +         -> E -        -> L
> > +        /      \      /
> > +C -> D -        -> H -
> > +                      \
> > +                       -> I -> K
> > +                      /
> > +                   J -
> > +
> > +where A, B,..., L are different lock classes.
> > +
> > +Lockdep adds a dependency into graph when a new dependency is detected.
> > +For example, it adds a dependency 'A -> B' when a dependency between
> > +releasing lock A and releasing lock B, which has not been added yet, is
> > +detected. It does same thing on other dependencies, too. See 'What
> > +causes deadlock' section.
> 
> Just from the text above I am not able to understand at what point the
> dependency A-> B is added.  If I was implementing lockdep, I would
> probably track all the locks that can be acquired between acquisition
> and release of A.  For example,
> 
> acquire A
> 
> if (/* some condition */)
>     acquire B
> else
>     acquire C
> 
> release A
> 
> 
> I would add to the dependency graph that 'release A' depends on
> 'acquire B' and 'acquire C'.

It's not wrong. But each acquire B(or C) in turn depends on each release
B(or C) when it fails to acquire them right away.

Thus, 'release A depends on release B and release C'.

That's what I wanted to say.

> 
> > +
> > +NOTE: Precisely speaking, a dependency is one between releasing a lock
> > +and releasing another lock as described in 'What causes deadlock'
> > +section. However from now on, we will describe a dependency as if it's
> > +one between a lock and another lock for simplicity. Then 'A -> B' can be
> > +described as a dependency between lock A and lock B.
> > +
> > +We already checked how a problematic set of dependencies causes a
> > +deadlock in 'What causes deadlock' section. This time let's check if a
> > +deadlock or its possibility can be detected using a problematic set of
> > +dependencies. Assume that 'A -> B', 'B -> E' and 'E -> A' were added in
> > +the sequence into graph. Then the graph finally will be,
> > +
> > + -> A -> B -> E -
> > +/                \
> > +\                /
> > + ----------------
> > +
> > +where A, B and E are different lock classes.
> > +
> > +From adding three dependencies, a cycle was created which means, by
> > +definition of dependency, the situation 'lock E must be released to
> > +release lock B which in turn must be released to release lock A which in
> > +turn must be released to release lock E which in turn must be released
> > +to release B and so on infinitely' can happen.
> > +
> > +Once the situation happens, no lock can be released since any of them
> > +can never meet each precondition. It's a deadlock. Lockdep can detect a
> > +deadlock or its possibility with checking if a cycle was created after
> > +adding each dependency into graph. This is how lockdep detects a
> > +deadlock or its possibility.
> 
> I think the text here is just repeating what was said above in the
> 'What causes deadlock' section.  You probably should remove of the
> text here.

Yes. I will check it.

> 
> > +
> > +CONCLUSION
> > +
> > +Lockdep detects a deadlock or its possibility with checking if a cycle
> > +was created after adding each dependency into graph.
> > +
> > +
> > +==========
> > +Limitation
> > +==========
> > +
> > +Limit to typical lock
> > +---------------------
> > +
> > +Limiting what lockdep has to consider to only ones satisfying the
> > +following condition, the implementation of adding dependencies becomes
> > +simple while its capacity for detection becomes limited. Typical lock
> > +e.g. spin lock and mutex is the case. Let's check what pros and cons of
> > +it are, in next section.
> > +
> > +       A lock should be released within the context holding the lock.
> 
> I would rephrase the above in the following way:  Lockdep is limited
> to checking dependencies on locks that are released within the context
> that acquired them.  This makes adding dependencies simple but limits
> lockdep's capacity for detection.

It looks better to me. I'll try to rephrase it.

> 
> 
> > +
> > +CONCLUSION
> > +
> > +Limiting what lockdep has to consider to typical lock e.g. spin lock and
> > +mutex, the implmentation becomes simple while it has a limited capacity.
> 
> I would drop the conclusion altogether.  The above paragraph is too
> small to require a conclusion.

I'm not sure. I want to let one read only conclusions, who want to get only
conclusions.

> 
> > +
> > +
> > +Pros from the limitation
> > +------------------------
> > +
> > +Given the limitation, when acquiring a lock, any lock being in
> > +held_locks of the acquire context cannot be released if the lock to
> 
> What does held_locks mean here?  Is it some structure maintained by
> the Linux kernel?

Exactly. It's embedded in struct task as an array.

> 
> > +acquire was not released yet. Yes. It's the exact case to add a new
> > +dependency 'A -> B' into graph, where lock A represents each lock being
> > +in held_locks and lock B represents the lock to acquire.
> > +
> > +For example, only considering typical lock,
> > +
> > +       PROCESS X
> > +       --------------
> > +       acquire A
> > +
> > +       acquire B -> add a dependency 'A -> B'
> > +
> > +       acquire C -> add a dependency 'B -> C'
> > +
> > +       release C
> > +
> > +       release B
> > +
> > +       release A
> > +
> > +where A, B and C are different lock classes.
> > +
> > +When acquiring lock A, there's nothing in held_locks of PROCESS X thus
> > +no dependency is added. When acquiring lock B, lockdep detects and adds
> > +a new dependency 'A -> B' between lock A being in held_locks and lock B.
> > +And when acquiring lock C, lockdep also adds another dependency 'B -> C'
> > +for same reason. They are added when acquiring each lock, simply.
> > +
> > +NOTE: Even though every lock being in held_locks depends on the lock to
> > +acquire, lockdep does not add all dependencies between them because all
> > +of them can be covered by other dependencies except one dependency
> > +between the lock on top of held_locks and the lock to acquire, which
> > +must be added.
> 
> I am unable to understand the above sentence.  Can you break it into
> two more sentences?

Sorry. I will try to explain it in more detail.

> 
> > +
> > +Besides, we can expect several advantages from the limitation.
> > +
> > +1. Any lock being in held_locks cannot be released unconditionally if
> > +   the context is stuck, thus we can easily identify a dependency when
> > +   acquiring a lock.
> > +
> > +2. Considering only locks being in local held_locks of a single context
> > +   makes some races avoidable, even though it fails of course when
> > +   modifying its global dependency graph.
> > +
> > +3. To build a dependency graph, lockdep only needs to keep locks not
> > +   released yet. However relaxing the limitation, it might need to keep
> > +   even locks already released, additionally. See 'Crossrelease' section.
> > +
> > +CONCLUSION
> > +
> > +Given the limitation, the implementation becomes simple and efficient.
> > +
> > +
> > +Cons from the limitation
> > +------------------------
> > +
> > +Given the limitation, lockdep is applicable only to typical lock. For
> > +example, page lock for page access or completion for synchronization
> > +cannot play with lockdep having the limitation. However since page lock
> > +or completion also causes a deadlock, it would be better to detect a
> > +deadlock or its possibility even for them.
> > +
> > +Can we detect deadlocks below with lockdep having the limitation?
> > +
> > +Example 1:
> > +
> > +       PROCESS X       PROCESS Y
> > +       --------------  --------------
> > +       mutext_lock A
> > +                       lock_page B
> > +       lock_page B
> > +                       mutext_lock A // DEADLOCK
> > +       unlock_page B
> > +                       mutext_unlock A
> > +       mutex_unlock A
> > +                       unlock_page B
> > +
> > +where A and B are different lock classes.
> 
> I think the formatting is slightly off.  The events corresponding to
> process Y should be shifted more towards right.  The vertical ordering
> would still clearly indicate the order in which the events happened.

Do you think it's better to shift it?

> 
> 
> > +
> > +No, we cannot.
> 
> I do not follow this example.  The context that acquired the mutex A
> or lock B also released it.  Should not lockdep be able to detect
> this?  I am guessing I have misunderstood which events occurred in
> which context.   Here is what I think the example is showing:
> 
> X acquired mutex A --> Y acquired lock B --> X tries to acquire B -->
> Y tries to acquire A -->  X and Y are in a deadlock since each of them
> holds a resource that the other needs.

Current lockdep is not able to deal with (un)lock_page thingy at all.

> > +Let's look at how commit works for crosslock.
> > +
> > +       RELEASE CONTEXT of a    ACQUIRE CONTEXT of a
> > +       --------------------    --------------------
> > +                               acquire a -> mark a as started
> > +
> > +       (serialized by some means e.g. barrier)
> > +
> > +       acquire D -> queue D
> > +                               acquire B -> queue B
> > +       release D
> > +                               acquire C -> add 'B -> C' and queue C
> > +       acquire E -> queue E
> > +                               acquire D -> add 'C -> D' and queue D
> > +       release E
> > +                               release D
> > +       release a -> commit a -> add 'a -> D' and 'a -> E'
> > +                               release C
> > +
> > +                               release B
> > +
> > +where a, B,..., E are different lock classes, and upper case letters
> > +represent typical lock while lower case letters represent crosslock.
> > +
> > +When acquiring crosslock a, no dependency can be added since there's
> > +nothing in the held_locks. However, crossrelease feature marks the
> > +crosslock as started, which means all locks to acquire from now are
> > +candidates which might create new dependencies later when identifying
> > +release context.
> > +
> > +When acquiring lock B, lockdep does what it originally does for typical
> > +lock and additionally queues the lock for later commit to refer to
> > +because it might be a dependent lock of the crosslock. It does same
> > +thing on lock C, D and E. And then two dependencies 'a -> D' and 'a -> E'
> > +are added when identifying the release context, at commit step.
> > +
> > +The final graph is, with crossrelease feature using commit,
> > +
> > +B -> C -
> > +        \
> > +         -> D
> > +        /
> > +     a -
> > +        \
> > +         -> E
> > +
> 
> Would not the graph also contain edges a->B and a->C, which lockdep
> would add as it usually does?

No. 'a' is a crosslock. We should not add 'a->B(or C)' dependency.
In other words, 'a' can be released without releasing B(or C), by another
context.

> Overall, I think I have generally understood what you are trying to do
> and how are doing it.  I think now I'll be able to better review the
> patches with actual.

Thanks a lot. Your comment would be helpful.

Thank you,
Byungchul

> 
> Thanks!
> Nilay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
