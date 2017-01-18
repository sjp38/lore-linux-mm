Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 398076B0273
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:18:03 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 204so16736556pfx.1
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:18:03 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 123si220434pfe.90.2017.01.18.05.17.59
        for <linux-mm@kvack.org>;
        Wed, 18 Jan 2017 05:18:00 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v5 13/13] lockdep: Crossrelease feature documentation
Date: Wed, 18 Jan 2017 22:17:39 +0900
Message-Id: <1484745459-2055-14-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

This document describes the concept of crossrelease feature.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 Documentation/locking/crossrelease.txt | 1053 ++++++++++++++++++++++++++++++++
 1 file changed, 1053 insertions(+)
 create mode 100644 Documentation/locking/crossrelease.txt

diff --git a/Documentation/locking/crossrelease.txt b/Documentation/locking/crossrelease.txt
new file mode 100644
index 0000000..dec890c
--- /dev/null
+++ b/Documentation/locking/crossrelease.txt
@@ -0,0 +1,1053 @@
+Crossrelease
+============
+
+Started by Byungchul Park <byungchul.park@lge.com>
+
+Contents:
+
+ (*) Background.
+
+     - What causes deadlock.
+     - What lockdep detects.
+     - How lockdep works.
+
+ (*) Limitation.
+
+     - Limit to typical locks.
+     - Pros from the limitation.
+     - Cons from the limitation.
+
+ (*) Generalization.
+
+     - Relax the limitation.
+
+ (*) Crossrelease.
+
+     - Introduce crossrelease.
+     - Pick true dependencies.
+     - Introduce commit.
+
+ (*) Implementation.
+
+     - Data structures.
+     - How crossrelease works.
+
+ (*) Optimizations.
+
+     - Avoid duplication.
+     - Lockless for hot paths.
+
+
+==========
+Background
+==========
+
+What causes deadlock
+--------------------
+
+A deadlock occurs when a context is waiting for an event to happen,
+which is impossible because another (or the) context who can trigger the
+event is also waiting for another (or the) event to happen, which is
+also impossible due to the same reason. Single or more contexts
+paricipate in such a deadlock.
+
+For example,
+
+   A context going to trigger event D is waiting for event A to happen.
+   A context going to trigger event A is waiting for event B to happen.
+   A context going to trigger event B is waiting for event C to happen.
+   A context going to trigger event C is waiting for event D to happen.
+
+A deadlock occurs when these four wait operations run at the same time,
+because event D cannot be triggered if event A does not happen, which in
+turn cannot be triggered if event B does not happen, which in turn
+cannot be triggered if event C does not happen, which in turn cannot be
+triggered if event D does not happen. After all, no event can be
+triggered since any of them never meets its precondition to wake up.
+
+In terms of dependency, a wait for an event creates a dependency if the
+context is going to wake up another waiter by triggering an proper event.
+In other words, a dependency exists if,
+
+   COND 1. There are two waiters waiting for each event at the same time.
+   COND 2. Only way to wake up each waiter is to trigger its events.
+   COND 3. Whether one can be woken up depends on whether the other can.
+
+Each wait in the example creates its dependency like,
+
+   Event D depends on event A.
+   Event A depends on event B.
+   Event B depends on event C.
+   Event C depends on event D.
+
+   NOTE: Precisely speaking, a dependency is one between whether a
+   waiter for an event can be woken up and whether another waiter for
+   another event can be woken up. However from now on, we will describe
+   a dependency as if it's one between an event and another event for
+   simplicity, so e.g. 'event D depends on event A'.
+
+And they form circular dependencies like,
+
+    -> D -> A -> B -> C -
+   /                     \
+   \                     /
+    ---------------------
+
+   where A, B,..., D are different events, and '->' represents 'depends
+   on'.
+
+Such circular dependencies lead to a deadlock since no waiter can meet
+its precondition to wake up if they run simultaneously, as described.
+
+CONCLUSION
+
+Circular dependencies cause a deadlock.
+
+
+What lockdep detects
+--------------------
+
+Lockdep tries to detect a deadlock by checking dependencies created by
+lock operations e.i. acquire and release. Waiting for a lock to be
+released corresponds to waiting for an event to happen, and releasing a
+lock corresponds to triggering an event. See 'What causes deadlock'
+section.
+
+A deadlock actually occurs when all wait operations creating circular
+dependencies run at the same time. Even though they don't, a potential
+deadlock exists if the problematic dependencies exist. Thus it's
+meaningful to detect not only an actual deadlock but also its potential
+possibility. Lockdep does the both.
+
+Whether or not a deadlock actually occurs depends on several factors.
+For example, what order contexts are switched in is a factor. Assuming
+circular dependencies exist, a deadlock would occur when contexts are
+switched so that all wait operations creating the problematic
+dependencies run simultaneously.
+
+To detect a potential possibility which means a deadlock has not
+happened yet but might happen in future, lockdep considers all possible
+combinations of dependencies so that its potential possibility can be
+detected in advance. To do this, lockdep is trying to,
+
+1. Use a global dependency graph.
+
+   Lockdep combines all dependencies into one global graph and uses them,
+   regardless of which context generates them or what order contexts are
+   switched in. Aggregated dependencies are only considered so they are
+   prone to be circular if a problem exists.
+
+2. Check dependencies between classes instead of instances.
+
+   What actually causes a deadlock are instances of lock. However,
+   lockdep checks dependencies between classes instead of instances.
+   This way lockdep can detect a deadlock which has not happened but
+   might happen in future by others but the same classes.
+
+3. Assume all acquisitions lead to waiting.
+
+   Although locks might be acquired without waiting which is essential
+   to create dependencies, lockdep assumes all acquisitions lead to
+   waiting and generates dependencies, since it might be true some time
+   or another. Potential possibilities can be checked in this way.
+
+Lockdep detects both an actual deadlock and its possibility. But the
+latter is more valuable than the former. When a deadlock occurs actually,
+we can identify what happens in the system by some means or other even
+without lockdep. However, there's no way to detect possiblity without
+lockdep unless the whole code is parsed in head. It's terrible.
+
+CONCLUSION
+
+Lockdep detects and reports,
+
+   1. A deadlock possibility.
+   2. A deadlock which actually occured.
+
+
+How lockdep works
+-----------------
+
+Lockdep does,
+
+   1. Detect a new dependency created.
+   2. Keep the dependency in a global data structure, graph.
+   3. Check if circular dependencies exist.
+   4. Report a deadlock or its possibility if so.
+
+A graph built by lockdep looks like, e.g.
+
+   A -> B -        -> F -> G
+           \      /
+            -> E -        -> L
+           /      \      /
+   C -> D -        -> H -
+                         \
+                          -> I -> K
+                         /
+                      J -
+
+   where A, B,..., L are different lock classes.
+
+Lockdep will add a dependency into graph when a new dependency is
+detected. For example, it will add a dependency 'K -> J' when a new
+dependency between lock K and lock J is detected. Then the graph will be,
+
+   A -> B -        -> F -> G
+           \      /
+            -> E -        -> L
+           /      \      /
+   C -> D -        -> H -
+                         \
+                          -> I -> K -
+                         /           \
+                   -> J -             \
+                  /                   /
+                  \                  /
+                   ------------------
+
+   where A, B,..., L are different lock classes.
+
+Now, circular dependencies are detected like,
+
+           -> I -> K -
+          /           \
+    -> J -             \
+   /                   /
+   \                  /
+    ------------------
+
+   where J, I and K are different lock classes.
+
+As decribed in 'What causes deadlock', this is the condition under which
+a deadlock might occur. Lockdep detects a deadlock or its possibility by
+checking if circular dependencies were created after adding each new
+dependency into the global graph. This is the way how lockdep works.
+
+CONCLUSION
+
+Lockdep detects a deadlock or its possibility by checking if circular
+dependencies were created after adding each new dependency.
+
+
+==========
+Limitation
+==========
+
+Limit to typical locks
+----------------------
+
+Limiting lockdep to checking dependencies only on typical locks e.g.
+spin locks and mutexes, which should be released within the acquire
+context, the implementation of detecting and adding dependencies becomes
+simple but its capacity for detection becomes limited. Let's check what
+its pros and cons are, in next section.
+
+CONCLUSION
+
+Limiting lockdep to working on typical locks e.g. spin locks and mutexes,
+the implmentation becomes simple but limits its capacity.
+
+
+Pros from the limitation
+------------------------
+
+Given the limitation, when acquiring a lock, locks in the held_locks of
+the context cannot be released if the context fails to acquire it and
+has to wait for it. It also makes waiters for the locks in the
+held_locks stuck. It's the exact case to create a dependency 'A -> B',
+where lock A is each lock in held_locks and lock B is the lock to
+acquire. See 'What casues deadlock' section.
+
+For example,
+
+   CONTEXT X
+   ---------
+   acquire A
+
+   acquire B /* Add a dependency 'A -> B' */
+
+   acquire C /* Add a dependency 'B -> C' */
+
+   release C
+
+   release B
+
+   release A
+
+   where A, B and C are different lock classes.
+
+When acquiring lock A, the held_locks of CONTEXT X is empty thus no
+dependency is added. When acquiring lock B, lockdep detects and adds
+a new dependency 'A -> B' between lock A in held_locks and lock B. When
+acquiring lock C, lockdep also adds another dependency 'B -> C' for the
+same reason. They can be simply added whenever acquiring each lock.
+
+And most data required by lockdep exists in a local structure e.i.
+'task_struct -> held_locks'. Forcing to access those data within the
+context, lockdep can avoid racy problems without explicit locks while
+handling the local data.
+
+Lastly, lockdep only needs to keep locks currently being held, to build
+the dependency graph. However relaxing the limitation, it might need to
+keep even locks already released, because the decision of whether they
+created dependencies might be long-deferred. See 'Crossrelease' section.
+
+To sum up, we can expect several advantages from the limitation.
+
+1. Lockdep can easily identify a dependency when acquiring a lock.
+2. Requiring only local locks makes many races avoidable.
+3. Lockdep only needs to keep locks currently being held.
+
+CONCLUSION
+
+Given the limitation, the implementation becomes simple and efficient.
+
+
+Cons from the limitation
+------------------------
+
+Given the limitation, lockdep is applicable only to typical locks. For
+example, page locks for page access or completions for synchronization
+cannot play with lockdep under the limitation.
+
+Can we detect deadlocks below, under the limitation?
+
+Example 1:
+
+   CONTEXT X		   CONTEXT Y
+   ---------		   ---------
+   mutex_lock A
+			   lock_page B
+   lock_page B
+			   mutex_lock A /* DEADLOCK */
+   unlock_page B
+			   mutex_unlock A
+   mutex_unlock A
+			   unlock_page B
+
+   where A is a lock class and B is a page lock.
+
+No, we cannot.
+
+Example 2:
+
+   CONTEXT X	   CONTEXT Y	   CONTEXT Z
+   ---------	   ---------	   ----------
+		   mutex_lock A
+   lock_page B
+		   lock_page B
+				   mutex_lock A /* DEADLOCK */
+				   mutex_unlock A
+				   unlock_page B held by X
+		   unlock_page B
+		   mutex_unlock A
+
+   where A is a lock class and B is a page lock.
+
+No, we cannot.
+
+Example 3:
+
+   CONTEXT X		   CONTEXT Y
+   ---------		   ---------
+			   mutex_lock A
+   mutex_lock A
+			   wait_for_complete B /* DEADLOCK */
+   mutex_unlock A
+   complete B
+			   mutex_unlock A
+
+   where A is a lock class and B is a completion variable.
+
+No, we cannot.
+
+CONCLUSION
+
+Given the limitation, lockdep cannot detect a deadlock or its
+possibility caused by page locks or completions.
+
+
+==============
+Generalization
+==============
+
+Relax the limitation
+--------------------
+
+Under the limitation, things to create dependencies are limited to
+typical locks. However, e.g. page locks and completions which are not
+typical locks also create dependencies and cause a deadlock. Therefore
+it would be better for lockdep to detect a deadlock or its possibility
+even for them.
+
+Detecting and adding dependencies into graph is very important for
+lockdep to work because adding a dependency means adding a chance to
+check if it causes a deadlock. The more lockdep adds dependencies, the
+more it thoroughly works. Therefore Lockdep has to do its best to add as
+many true dependencies as possible into the graph.
+
+Relaxing the limitation, lockdep can add more dependencies since
+additional things e.g. page locks or completions create additional
+dependencies. However even so, it needs to be noted that the relaxation
+does not affect the behavior of adding dependencies for typical locks.
+
+For example, considering only typical locks, lockdep builds a graph like,
+
+   A -> B -        -> F -> G
+           \      /
+            -> E -        -> L
+           /      \      /
+   C -> D -        -> H -
+                         \
+                          -> I -> K
+                         /
+                      J -
+
+   where A, B,..., L are different lock classes.
+
+On the other hand, under the relaxation, additional dependencies might
+be created and added. Assuming additional 'MX -> H', 'L -> NX' and
+'OX -> J' dependencies are added thanks to the relaxation, the graph
+will be, giving additional chances to check circular dependencies,
+
+   A -> B -        -> F -> G
+           \      /
+            -> E -        -> L -> NX
+           /      \      /
+   C -> D -        -> H -
+                  /      \
+              MX -        -> I -> K
+                         /
+                   -> J -
+                  /
+              OX -
+
+   where A, B,..., L, MX, NX and OX are different lock classes, and
+   a suffix 'X' is added on non-typical locks e.g. page locks and
+   completions.
+
+However, it might suffer performance degradation since relaxing the
+limitation with which design and implementation of lockdep could be
+efficient might introduce inefficiency inevitably. Each option, strong
+detection or efficient detection, has its pros and cons, thus the right
+of choice between two options should be given to users.
+
+Choosing efficient detection, lockdep only deals with locks satisfying,
+
+   A lock should be released within the context holding the lock.
+
+Choosing strong detection, lockdep deals with any locks satisfying,
+
+   A lock can be released in any context.
+
+The latter, of course, doesn't allow illegal contexts to release a lock.
+For example, acquiring a lock in irq-safe context before releasing the
+lock in irq-unsafe context is not allowed, which after all ends in
+circular dependencies, meaning a deadlock. Otherwise, any contexts are
+allowed to release it.
+
+CONCLUSION
+
+Relaxing the limitation, lockdep can add additional dependencies and
+get additional chances to check if they cause deadlocks.
+
+
+============
+Crossrelease
+============
+
+Introduce crossrelease
+----------------------
+
+To allow lockdep to handle additional dependencies by what might be
+released in any context, namely 'crosslock', a new feature 'crossrelease'
+is introduced. Thanks to the feature, now lockdep can identify such
+dependencies. Crossrelease feature has to do,
+
+   1. Identify dependencies by crosslocks.
+   2. Add the dependencies into graph.
+
+That's all. Once a meaningful dependency is added into graph, then
+lockdep would work with the graph as it did. So the most important thing
+crossrelease feature has to do is to correctly identify and add true
+dependencies into the global graph.
+
+A dependency e.g. 'A -> B' can be identified only in the A's release
+context because a decision required to identify the dependency can be
+made only in the release context. That is to decide whether A can be
+released so that a waiter for A can be woken up. It cannot be made in
+other contexts than the A's release context. See 'What causes deadlock'
+section to remind what a dependency is.
+
+It's no matter for typical locks because each acquire context is same as
+its release context, thus lockdep can decide whether a lock can be
+released, in the acquire context. However for crosslocks, lockdep cannot
+make the decision in the acquire context but has to wait until the
+release context is identified.
+
+Therefore lockdep has to queue all acquisitions which might create
+dependencies until the decision can be made, so that they can be used
+when it proves they are the right ones. We call the step 'commit'. See
+'Introduce commit' section.
+
+Of course, some actual deadlocks caused by crosslocks cannot be detected
+just when it happens, because the deadlocks cannot be identified until
+the crosslocks is actually released. However, deadlock possibilities can
+be detected in this way. It's worth possibility detection of deadlock.
+See 'What lockdep does' section.
+
+CONCLUSION
+
+With crossrelease feature, lockdep can work with what might be released
+in any context, namely crosslock.
+
+
+Pick true dependencies
+----------------------
+
+Remind what a dependency is. A dependency exists if,
+
+   COND 1. There are two waiters waiting for each event at the same time.
+   COND 2. Only way to wake up each waiter is to trigger its events.
+   COND 3. Whether one can be woken up depends on whether the other can.
+
+For example,
+
+   TASK X
+   ------
+   acquire A
+
+   acquire B /* A dependency 'A -> B' exists */
+
+   acquire C /* A dependency 'B -> C' exists */
+
+   release C
+
+   release B
+
+   release A
+
+   where A, B and C are different lock classes.
+
+A depedency 'A -> B' exists since,
+
+   1. A waiter for A and a waiter for B might exist when acquiring B.
+   2. Only way to wake up each of them is to release what it waits for.
+   3. Whether the waiter for A can be woken up depends on whether the
+      other can. IOW, TASK X cannot release A if it cannot acquire B.
+
+Other dependencies 'B -> C' and 'A -> C' also exist for the same reason.
+But the second is ignored since it's covered by 'A -> B' and 'B -> C'.
+
+For another example,
+
+   TASK X			   TASK Y
+   ------			   ------
+				   acquire AX
+   acquire D
+   /* A dependency 'AX -> D' exists */
+				   acquire B
+   release D
+				   acquire C
+				   /* A dependency 'B -> C' exists */
+   acquire E
+   /* A dependency 'AX -> E' exists */
+				   acquire D
+				   /* A dependency 'C -> D' exists */
+   release E
+				   release D
+   release AX held by Y
+				   release C
+
+				   release B
+
+   where AX, B, C,..., E are different lock classes, and a suffix 'X' is
+   added on crosslocks.
+
+Even in this case involving crosslocks, the same rules can be applied. A
+depedency 'AX -> D' exists since,
+
+   1. A waiter for AX and a waiter for D might exist when acquiring D.
+   2. Only way to wake up each of them is to release what it waits for.
+   3. Whether the waiter for AX can be woken up depends on whether the
+      other can. IOW, TASK X cannot release AX if it cannot acquire D.
+
+The same rules can be applied to other dependencies, too.
+
+Let's take a look at more complicated example.
+
+   TASK X			   TASK Y
+   ------			   ------
+   acquire B
+
+   release B
+
+   acquire C
+
+   release C
+   (1)
+   fork Y
+				   acquire AX
+   acquire D
+   /* A dependency 'AX -> D' exists */
+				   acquire F
+   release D
+				   acquire G
+				   /* A dependency 'F -> G' exists */
+   acquire E
+   /* A dependency 'AX -> E' exists */
+				   acquire H
+				   /* A dependency 'G -> H' exists */
+   release E
+				   release H
+   release AX held by Y
+				   release G
+
+				   release F
+
+   where AX, B, C,..., H are different lock classes, and a suffix 'X' is
+   added on crosslocks.
+
+Does a dependency 'AX -> B' exist? Nope.
+
+Two waiters, one is for AX and the other is for B, are essential
+elements to create the dependency 'AX -> B'. However in this example,
+these two waiters cannot exist at the same time. Thus the dependency
+'AX -> B' cannot be created.
+
+In fact, AX depends on all acquisitions after (1) in TASK X e.i. D and E,
+but excluding all acquisitions before (1) in the context e.i. A and C.
+Thus only 'AX -> D' and 'AX -> E' are true dependencies by AX.
+
+It would be ideal if the full set of true ones can be added. But parsing
+the whole code is necessary to do it, which is impossible. Relying on
+what actually happens at runtime, we can anyway add only true ones even
+though they might be a subset of the full set. This way we can avoid
+adding false ones.
+
+It's similar to how lockdep works for typical locks. Ideally there might
+be more true dependencies than ones being in the gloabl dependency graph,
+however, lockdep has no choice but to rely on what actually happens
+since otherwise it's almost impossible.
+
+CONCLUSION
+
+Relying on what actually happens, adding false dependencies can be
+avoided.
+
+
+Introduce commit
+----------------
+
+Crossrelease feature names it 'commit' to identify and add dependencies
+into graph in batches. Lockdep is already doing what commit is supposed
+to do, when acquiring a lock for typical locks. However, that way must
+be changed for crosslocks so that it identifies a crosslock's release
+context first, then does commit.
+
+There are four types of dependencies.
+
+1. TT type: 'Typical lock A -> Typical lock B' dependency
+
+   Just when acquiring B, lockdep can see it's in the A's release
+   context. So the dependency between A and B can be identified
+   immediately. Commit is unnecessary.
+
+2. TC type: 'Typical lock A -> Crosslock BX' dependency
+
+   Just when acquiring BX, lockdep can see it's in the A's release
+   context. So the dependency between A and BX can be identified
+   immediately. Commit is unnecessary, too.
+
+3. CT type: 'Crosslock AX -> Typical lock B' dependency
+
+   When acquiring B, lockdep cannot identify the dependency because
+   there's no way to know whether it's in the AX's release context. It
+   has to wait until the decision can be made. Commit is necessary.
+
+4. CC type: 'Crosslock AX -> Crosslock BX' dependency
+
+   If there is a typical lock acting as a bridge so that 'AX -> a lock'
+   and 'the lock -> BX' can be added, then this dependency can be
+   detected. But direct ways are not implemented yet. It's a future work.
+
+Lockdep works even without commit for typical locks. However, commit
+step is necessary once crosslocks are involved, until all crosslocks in
+progress are released. Introducing commit, lockdep performs three steps
+i.e. acquire, commit and release. What lockdep does in each step is,
+
+1. Acquire
+
+   1) For typical lock
+
+      Lockdep does what it originally did and queues the lock so that
+      lockdep can check CT type dependencies using it at commit step.
+
+   2) For crosslock
+
+      The crosslock is added to a global linked list so that lockdep can
+      check CT type dependencies using it at commit step.
+
+2. Commit
+
+   1) For typical lock
+
+      N/A.
+
+   2) For crosslock
+
+      Lockdep checks and adds CT Type dependencies using data saved at
+      acquire step.
+
+3. Release
+
+   1) For typical lock
+
+      No change.
+
+   2) For crosslock
+
+      Lockdep just remove the crosslock from the global linked list, to
+      which it was added at acquire step.
+
+CONCLUSION
+
+Crossrelease feature introduces commit step to handle dependencies by
+crosslocks in batches, which lockdep cannot handle in its original way.
+
+
+==============
+Implementation
+==============
+
+Data structures
+---------------
+
+Crossrelease feature introduces two main data structures.
+
+1. pend_lock
+
+   This is an array embedded in task_struct, for keeping locks queued so
+   that real dependencies can be added using them at commit step. Since
+   it's local data, it can be accessed locklessly in the owner context.
+   The array is filled at acquire step and consumed at commit step. And
+   it's managed in circular manner.
+
+2. cross_lock
+
+   This is a global linked list, for keeping all crosslocks in progress.
+   The list grows at acquire step and is shrunk at release step.
+
+CONCLUSION
+
+Crossrelease feature introduces two main data structures.
+
+1. A pend_lock array for queueing typical locks in circular manner.
+2. A cross_lock linked list for managing crosslocks in progress.
+
+
+How crossrelease works
+----------------------
+
+Let's take a look at how crossrelease feature works step by step,
+starting from how lockdep works without crossrelease feaure.
+
+For example, the below is how lockdep works for typical locks.
+
+   A's RELEASE CONTEXT (= A's ACQUIRE CONTEXT)
+   -------------------------------------------
+   acquire A
+
+   acquire B /* Add 'A -> B' */
+
+   acquire C /* Add 'B -> C' */
+
+   release C
+
+   release B
+
+   release A
+
+   where A, B and C are different lock classes.
+
+After adding 'A -> B', the dependency graph will be,
+
+   A -> B
+
+   where A and B are different lock classes.
+
+And after adding 'B -> C', the graph will be,
+
+   A -> B -> C
+
+   where A, B and C are different lock classes.
+
+What if we use commit step to add dependencies even for typical locks?
+Commit step is not necessary for them, however it anyway would work well,
+because this is a more general way.
+
+   A's RELEASE CONTEXT (= A's ACQUIRE CONTEXT)
+   -------------------------------------------
+   acquire A
+   /*
+    * 1. Mark A as started
+    * 2. Queue A
+    *
+    * In pend_lock: A
+    * In graph: Empty
+    */
+
+   acquire B
+   /*
+    * 1. Mark B as started
+    * 2. Queue B
+    *
+    * In pend_lock: A, B
+    * In graph: Empty
+    */
+
+   acquire C
+   /*
+    * 1. Mark C as started
+    * 2. Queue C
+    *
+    * In pend_lock: A, B, C
+    * In graph: Empty
+    */
+
+   release C
+   /*
+    * 1. Commit C (= Add 'C -> ?')
+    *   a. What queued since C was marked: Nothing
+    *   b. Add nothing
+    *
+    * In pend_lock: A, B, C
+    * In graph: Empty
+    */
+
+   release B
+   /*
+    * 1. Commit B (= Add 'B -> ?')
+    *   a. What queued since B was marked: C
+    *   b. Add 'B -> C'
+    *
+    * In pend_lock: A, B, C
+    * In graph: 'B -> C'
+    */
+
+   release A
+   /*
+    * 1. Commit A (= Add 'A -> ?')
+    *   a. What queued since A was marked: B, C
+    *   b. Add 'A -> B'
+    *   c. Add 'A -> C'
+    *
+    * In pend_lock: A, B, C
+    * In graph: 'B -> C', 'A -> B', 'A -> C'
+    */
+
+   where A, B and C are different lock classes.
+
+After doing commit A, B and C, the dependency graph becomes like,
+
+   A -> B -> C
+
+   where A, B and C are different lock classes.
+
+   NOTE: A dependency 'A -> C' is optimized out.
+
+We can see the former graph built without commit step is same as the
+latter graph built using commit steps. Of course the former way leads to
+earlier finish for building the graph, which means we can detect a
+deadlock or its possibility sooner. So the former way would be prefered
+if possible. But we cannot avoid using the latter way for crosslocks.
+
+Let's look at how commit works for crosslocks.
+
+   AX's RELEASE CONTEXT		   AX's ACQUIRE CONTEXT
+   --------------------		   --------------------
+				   acquire AX
+				   /*
+				    * 1. Mark AX as started
+				    *
+				    * (No queuing for crosslocks)
+				    *
+				    * In pend_lock: Empty
+				    * In graph: Empty
+				    */
+
+   (serialized by some means e.g. barrier)
+
+   acquire D
+   /*
+    * (No marking for typical locks)
+    *
+    * 1. Queue D
+    *
+    * In pend_lock: D
+    * In graph: Empty
+    */
+				   acquire B
+				   /*
+				    * (No marking for typical locks)
+				    *
+				    * 1. Queue B
+				    *
+				    * In pend_lock: B
+				    * In graph: Empty
+				    */
+   release D
+   /*
+    * (No commit for typical locks)
+    *
+    * In pend_lock: D
+    * In graph: Empty
+    */
+				   acquire C
+				   /*
+				    * (No marking for typical locks)
+				    *
+				    * 1. Add 'B -> C' of TT type
+				    * 2. Queue C
+				    *
+				    * In pend_lock: B, C
+				    * In graph: 'B -> C'
+				    */
+   acquire E
+   /*
+    * (No marking for typical locks)
+    *
+    * 1. Queue E
+    *
+    * In pend_lock: D, E
+    * In graph: 'B -> C'
+    */
+				   acquire D
+				   /*
+				    * (No marking for typical locks)
+				    *
+				    * 1. Add 'C -> D' of TT type
+				    * 2. Queue D
+				    *
+				    * In pend_lock: B, C, D
+				    * In graph: 'B -> C', 'C -> D'
+				    */
+   release E
+   /*
+    * (No commit for typical locks)
+    *
+    * In pend_lock: D, E
+    * In graph: 'B -> C', 'C -> D'
+    */
+				   release D
+				   /*
+				    * (No commit for typical locks)
+				    *
+				    * In pend_lock: B, C, D
+				    * In graph: 'B -> C', 'C -> D'
+				    */
+   release AX
+   /*
+    * 1. Commit AX (= Add 'AX -> ?')
+    *   a. What queued since AX was marked: D, E
+    *   b. Add 'AX -> D' of CT type
+    *   c. Add 'AX -> E' of CT type
+    *
+    * In pend_lock: D, E
+    * In graph: 'B -> C', 'C -> D',
+    *           'AX -> D', 'AX -> E'
+    */
+				   release C
+				   /*
+				    * (No commit for typical locks)
+				    *
+				    * In pend_lock: B, C, D
+				    * In graph: 'B -> C', 'C -> D',
+				    *           'AX -> D', 'AX -> E'
+				    */
+
+				   release B
+				   /*
+				    * (No commit for typical locks)
+				    *
+				    * In pend_lock: B, C, D
+				    * In graph: 'B -> C', 'C -> D',
+				    *           'AX -> D', 'AX -> E'
+				    */
+
+   where AX, B, C,..., E are different lock classes, and a suffix 'X' is
+   added on crosslocks.
+
+When acquiring crosslock AX, crossrelease feature marks AX as started,
+which means all acquisitions from now are candidates which might create
+dependencies with AX. True dependencies will be determined when
+identifying the AX's release context.
+
+When acquiring typical lock B, lockdep queues B so that it can be used
+at commit step later since any crosslocks in progress might depends on B.
+The same thing is done on lock C, D and E. And then two dependencies
+'AX -> D' and 'AX -> E' are added at commit step, when identifying the
+AX's release context.
+
+The final graph is, with crossrelease feature using commit,
+
+   B -> C -
+           \
+            -> D
+           /
+       AX -
+           \
+            -> E
+
+   where AX, B, C,..., E are different lock classes, and a suffix 'X' is
+   added on crosslocks.
+
+However, without crossrelease feature, the final graph would be,
+
+   B -> C -> D
+
+   where B and C are different lock classes.
+
+The former graph has two more dependencies 'AX -> D' and 'AX -> E'
+giving additional chances to check if they cause deadlocks. This way
+lockdep can detect a deadlock or its possibility caused by crosslocks.
+Again, crossrelease feature does not affect the behavior of adding
+dependencies for typical locks.
+
+CONCLUSION
+
+Crossrelease works well for crosslock, thanks to commit step.
+
+
+=============
+Optimizations
+=============
+
+Avoid duplication
+-----------------
+
+Crossrelease feature uses a cache like what lockdep is already using for
+dependency chains, but this time it's for caching a dependency of CT
+type, crossing between two different context. Once that dependency is
+cached, same dependencies will never be added again. Queueing
+unnecessary locks is also prevented based on the cache.
+
+CONCLUSION
+
+Crossrelease does not add any duplicate dependencies.
+
+
+Lockless for hot paths
+----------------------
+
+To keep all typical locks for later use, crossrelease feature adopts a
+local array embedded in task_struct, which makes accesses to arrays
+lockless by forcing the accesses to happen only within the owner context.
+It's like how lockdep accesses held_locks. Lockless implmentation is
+important since typical locks are very frequently acquired and released.
+
+CONCLUSION
+
+Crossrelease is designed to use no lock for hot paths.
+
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
