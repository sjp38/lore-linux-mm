Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 60FA86B0264
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 05:32:06 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id da8so22837311obb.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:32:06 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id w144si2664205itc.63.2016.07.07.02.31.51
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 02:31:52 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [RFC v2 13/13] lockdep: Add a document describing crossrelease feature
Date: Thu,  7 Jul 2016 18:30:03 +0900
Message-Id: <1467883803-29132-14-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
References: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, npiggin@kernel.dk, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Crossrelease feature introduces new concept and data structure. Thus
the document is necessary. So added it.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 Documentation/locking/crossrelease.txt | 457 +++++++++++++++++++++++++++++++++
 1 file changed, 457 insertions(+)
 create mode 100644 Documentation/locking/crossrelease.txt

diff --git a/Documentation/locking/crossrelease.txt b/Documentation/locking/crossrelease.txt
new file mode 100644
index 0000000..51b583b
--- /dev/null
+++ b/Documentation/locking/crossrelease.txt
@@ -0,0 +1,457 @@
+Crossrelease dependency check
+=============================
+
+Started by Byungchul Park <byungchul.park@lge.com>
+
+Contents:
+
+ (*) Introduction.
+
+     - What the lockdep checks.
+
+ (*) What is a problem?
+
+     - Examples.
+     - Lockdep's assumption.
+     - Lockdep's limitation.
+
+ (*) How to solve the problem.
+
+     - What causes deadlock?
+     - Relax the assumption.
+     - Relax the limitation.
+
+ (*) Implementation.
+
+     - Introduce crosslock.
+     - Introduce commit stage.
+     - Acquire vs commit vs release.
+     - Data structures.
+
+ (*) Optimizations.
+
+
+============
+Introduction
+============
+
+What the lockdep checks
+-----------------------
+
+Lockdep checks dependency between locks and reports it if a deadlock
+possibility is detected in advance or if an actual deadlock occures at
+the time checking it.
+
+The former is more valuable because the possibility detection without
+lockdep is much harder. When an actual deadlock occures, we can identify
+what happens in the system by some means or other, even without lockdep.
+
+It checks dependency between locks (exactly lock classes, see
+Documentation/locking/lockdep-design.txt for more) and builds the
+relationship between them when the lock is acquired. Eventually it forms
+the global dependency graph which connects between related locks based
+on dependency they have, like e.g.
+
+A - B -       - F - G
+       \     /
+        - E -       - L
+       /     \     /
+C - D -       - H -
+                   \
+                    - I - K
+                   /
+                J -
+
+where A, B, C,..., L are different lock classes.
+
+Lockdep basically works based on this global dependency graph. The more
+nodes it has, the stronger check can be performed.
+
+For example, lockdep can detect a deadlock when acquiring a C class lock
+while it already held a K class lock, because it forms a cycle which
+means deadlock, like
+
+A - B -       - F - G
+       \     /
+        - E -       - L
+       /     \     /
+C - D -       - H -
+|                  \
+|                   - I - K
+|                  /      |
+|               J -       |
++-------------------------+
+
+where A, B, C,..., L are different lock classes.
+
+If any of nodes making up the cycle was not built into the graph, we
+cannot detect this kind of deadlock because there's no cycle. For
+example, it might be
+
+A - B -       - F - G
+       \     /
+        - E -       L
+       /
+C - D -
+|
+|                   - I - K
+|                  /      |
+|               J -       |
++-------------------------+
+
+where A, B, C,..., L are different lock classes.
+
+Adding nodes and edges gives us additional opportunity to check if it
+causes deadlock or not, so makes the detection stronger.
+
+
+=================
+What is a problem
+=================
+
+Examples
+--------
+
+Can we detect deadlocks descriped below, with lockdep? No.
+
+Example 1)
+
+	PROCESS X	PROCESS Y
+	--------------	--------------
+	mutext_lock A
+			lock_page B
+	lock_page B
+			mutext_lock A // DEADLOCK
+	unlock_page B
+			mutext_unlock A
+	mutex_unlock A
+			unlock_page B
+
+We are not checking the dependency for lock_page() at all now.
+
+Example 2)
+
+	PROCESS X	PROCESS Y	PROCESS Z
+	--------------	--------------	--------------
+			mutex_lock A
+	lock_page B
+			lock_page B
+					mutext_lock A // DEADLOCK
+					mutext_unlock A
+					unlock_page B
+					(B was held by PROCESS X)
+			unlock_page B
+			mutex_unlock A
+
+We cannot detect this kind of deadlock with lockdep, even though we
+apply the dependency check using lockdep on lock_page().
+
+Example 3)
+
+	PROCESS X	PROCESS Y
+	--------------	--------------
+			mutex_lock A
+	mutex_lock A
+	mutex_unlock A
+			wait_for_complete B // DEADLOCK
+	complete B
+			mutex_unlock A
+
+wait_for_complete() and complete() also can cause a deadlock, however
+we cannot detect it with lockdep, either.
+
+
+lockdep's assumption
+--------------------
+
+Lockdep (not crossrelease featured one) assumes that,
+
+	A lock will be unlocked within the context holding the lock.
+
+Thus we can say that a lock has dependency with all locks being already
+in held_locks. So we can check dependency and build the dependency graph
+when acquiring it.
+
+
+lockdep's limitation
+--------------------
+
+It can be applied only to typical lock operations, e.g. spin_lock,
+mutex and so on. However, e.g. lock_page() cannot play with the lockdep
+thingy because it violates assumptions of lockdep, even though it's
+considered as a lock for the page access.
+
+In the view point of lockdep, it must be released within the context
+which held the lock, however, the page lock can be released by different
+context from the context which held it. Another example,
+wait_for_complete() and complete() are also the case by nature, which
+the lockdep cannot deal with.
+
+
+========================
+How to solve the problem
+========================
+
+What causes deadlock
+--------------------
+
+Not only lock operations, but also any operations causing to wait or
+spin for something can cause deadlock unless it's eventually *released*
+by someone. The important point here is that the waiting or spinning
+must be *released* by someone. In other words, we have to focus whether
+the waiting or spinning can be *released* or not to check a deadlock
+possibility, rather than the waiting or spinning itself.
+
+In this point of view, typical lock is a special case where the acquire
+context is same as the release context, so no matter in which context
+the checking is performed for typical lock.
+
+Of course, in order to be able to report deadlock imediately at the time
+real deadlock actually occures, the checking must be performed before
+actual blocking or spinning happens when acquiring it. However, deadlock
+*possibility* can be detected and reported even the checking is done
+when releasing it, which means the time we can identify the release
+context.
+
+
+Relax the assumption
+--------------------
+
+Since whether waiting or spinning can be released or not is more
+important to check deadlock possibility as decribed above, we can relax
+the assumtion the lockdep has.
+
+	A lock can be unlocked in any context, unless the context
+	itself causes a deadlock e.g. acquiring a lock in irq-safe
+	context before releasing the lock in irq-unsafe context.
+
+A lock has dependency with all locks in the release context, having been
+held since the lock was held. Thus basically we can check the dependency
+only after we identify the release context at first. Of course, we can
+identify the release context at the time acquiring a lock for typical
+lock because the acquire context is same as the release context.
+
+However, generally if we cannot identify the release context at the time
+acquiring a lock, we have to wait until the lock having been held will
+be eventually released to identify the release context.
+
+
+Relax the limitation
+--------------------
+
+Given that the assumption is relaxed, we can check dependency and detect
+deadlock possibility not only for typical lock, but also for lock_page()
+using PG_locked, wait_for_xxx() and so on which might be released by
+different context from the context which held the lock.
+
+
+==============
+Implementation
+==============
+
+Introduce crosslock
+-------------------
+
+Crossrelease feature names a lock "crosslock" if it is releasable by a
+different context from the context which held the lock. All locks
+having been held in the context unlocking the crosslock, since the
+crosslock was held until eventually it's unlocked, have dependency with
+the crosslock. That's the key idea to implement crossrelease feature.
+
+
+Introduce commit stage
+----------------------
+
+Crossrelease feature names it "commit", to check dependency and build
+the dependency graph and chain in batches. Lockdep already performs what
+the commit does, when acquiring a lock. This way it works for typical
+lock, since it's guarrented that the acquire context is same as the
+release context for that. However, that way must be changed for
+crosslock so that it identify the release context when releasing the
+crosslock and then performs the commit.
+
+Let's demonstrate it though several examples.
+
+The below is how the current lockdep works for typical lock. Note that
+context 1 == context 2 for typical lock.
+
+	CONTEXT 1	CONTEXT 2
+	acquiring A	releasing A
+	-------------	-------------
+	acquire A	acquire A
+
+	acquire B	acquire B -> build "A - B"
+
+	acquire C	acquire C -> build "A - C"
+
+	release C	release C
+
+	release B	release B
+
+	release A	release A
+
+After building "A - B", the dependency graph forms like,
+
+A - B
+
+And after building "A - C", the dependency graph forms like,
+
+    - B
+   /
+A -
+   \
+    - C
+
+What if we apply the commit to lockdep for typical lock? Of course, it's
+not necessary for typical lock. Just a example for what the commit does.
+
+	CONTEXT 1	CONTEXT 2
+	acquiring A	releasing A
+	-------------	-------------
+	acquire A	acquire A -> mark A started
+
+	acquire B	acquire B -> queue B
+
+	acquire C	acquire C -> queue C
+
+	release C	release C
+
+	release B	release B
+
+	release A	release A -> commit A (build "A - B", "A - C")
+
+After commiting A, the dependency graph forms like, at a time
+
+    - B
+   /
+A -
+   \
+    - C
+
+Here we can see both the former and the latter end in building a same
+dependency graph consisting of "A - B" and "A - C". Of course, the
+former can build the graph earlier than the latter, which means the
+former can detect a deadlock sooner, maybe, as soon as possible. So the
+former would be prefered if possible.
+
+Let's look at the way the commit works for crosslock.
+
+	CONTEXT 1	CONTEXT 2
+	acquiring A	releasing A
+	-------------	-------------
+	lock A
+	acquire A -> mark A started
+
+	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ <- serialized by some means
+
+			acquire X -> queue X
+			lock X
+	acquire B
+			release X
+	acquire C
+			acquire Y -> queue Y
+	release C
+			release Y
+	release B
+			release A -> commit A (build "A - X", "A - Y")
+
+where A is a crosslock and the others are typical locks.
+
+Since a crosslock is held, it starts to queue all candidates whenever
+acquiring typical lock, and keep it until finally it will be released.
+Then it can commit all proper candidates queued until now. In other
+words, it checks dependency and builds the dependency graph and chain
+at the commit stage.
+
+And it is serialized so that the sequence, A -> X -> Y can be seen,
+using atomic operations and proper barriers.
+
+
+Acquire vs commit vs release
+----------------------------
+
+What the lockdep should do in each stage to make it work even for
+crosslock is like, (Note that it does not change any current logic
+by which lockdep works, but only adds additional detection capability.)
+
+1. Acquire
+
+	1) For typical lock
+
+		It's queued into additional data structure so that the
+		commit stage can check depedndency and build the
+		dependency graph and chain with this later.
+
+	2) For crosslock
+
+		It's added to the global linked list so that the commit
+		stage can check dependency and build the dependency
+		graph and chain with this later.
+
+2. Commit
+
+	1) For typical lock
+
+		N/A.
+
+	2) For crosslock
+
+		It checks dependency and builds the dependency graph and
+		chain with data saved in the acquire stage. Here, we
+		establish dependency between the crosslock we are
+		unlocking now and all locks in that context, having been
+		held since the lock was held. Of course, it avoids
+		unnecessary checking and building as far as possible.
+
+3. Release
+
+	1) For typical lock
+
+		No change.
+
+	2) For crosslock
+
+		Just remove this crosslock from the global linked list,
+		to which the crosslock was added at acquire stage.
+		Release operation should be used with commit operation
+		together for crosslock.
+
+
+Data structures
+---------------
+
+Crossrelease feature introduces two new data structures.
+
+1. pend_lock (or plock)
+
+	This is for keeping locks waiting to be committed so that the
+	actual dependency graph and chain can be built in the commit
+	stage. Every task_struct has a pend_lock array to keep these
+	locks. pend_lock entry will be consumed and filled whenever
+	lock_acquire() is called for typical lock and will be flushed,
+	namely committed at proper time. And this array is managed by
+	circular buffer mean.
+
+2. cross_lock (or xlock)
+
+	This keeps some additional data only for crosslock. One
+	instance exists per one crosslock's lockdep_map.
+	lockdep_init_map_crosslock() should be used instead of
+	lockdep_init_map() to use a lock as a crosslock.
+
+
+=============
+Optimizations
+=============
+
+Adding a pend_lock is an operation which very frequently happened
+because it happens whenever a typical lock is acquired. So the operation
+is implemented locklessly using rcu mechanism if possible. Unfortunitly,
+we cannot apply this optimization if any object managed by rcu e.g.
+xlock is on stack or somewhere else where it can be freed or destroyed
+unpredictably.
+
+And chain cache for crosslock is also used to avoid unnecessary checking
+and building dependency, like how the lockdep is already doing for that
+purpose for typical lock.
+
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
