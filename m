Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA39440D4A
	for <linux-mm@kvack.org>; Sat, 11 Nov 2017 08:26:38 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 4so10461960pge.8
        for <linux-mm@kvack.org>; Sat, 11 Nov 2017 05:26:38 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id u16si11640781pfi.124.2017.11.11.05.26.35
        for <linux-mm@kvack.org>;
        Sat, 11 Nov 2017 05:26:36 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v3 3/5] locking/Documentation: Fix weird expressions.
Date: Sat, 11 Nov 2017 22:26:30 +0900
Message-Id: <1510406792-28676-4-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1510406792-28676-1-git-send-email-byungchul.park@lge.com>
References: <1510406792-28676-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com

Fix Weird expressions not reported by checker tools by myself.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 Documentation/locking/crossrelease.txt | 87 ++++++++++++++++++----------------
 1 file changed, 45 insertions(+), 42 deletions(-)

diff --git a/Documentation/locking/crossrelease.txt b/Documentation/locking/crossrelease.txt
index 48ef689..bb449e8 100644
--- a/Documentation/locking/crossrelease.txt
+++ b/Documentation/locking/crossrelease.txt
@@ -30,7 +30,7 @@ Contents:
  (*) Optimizations
 
      - Avoid duplication
-     - Lockless for hot paths
+     - Make hot paths lockless
 
  (*) APPENDIX A: What lockdep does to work aggressively
 
@@ -195,12 +195,11 @@ For example:
 When acquiring lock A, the held_locks of CONTEXT X is empty thus no
 dependency is added. But when acquiring lock B, lockdep detects and adds
 a new dependency 'A -> B' between lock A in the held_locks and lock B.
-They can be simply added whenever acquiring each lock.
+Dependencies can be simply added this way, whenever acquiring each lock.
 
-And data required by lockdep exists in a local structure, held_locks
-embedded in task_struct. Forcing to access the data within the context,
-lockdep can avoid racy problems without explicit locks while handling
-the local data.
+Furthermore, since data required to create a dependency can be kept in
+local task_struct, lockdep can avoid racy problems without explicit
+protection by forcing to access the data within the context.
 
 Lastly, lockdep only needs to keep locks currently being held, to build
 the dependency graph. However, relaxing the limitation, it needs to keep
@@ -210,7 +209,8 @@ dependencies might be long-deferred.
 To sum up, we can expect several advantages from the limitation:
 
    1. Lockdep can easily identify a dependency when acquiring a lock.
-   2. Races are avoidable while accessing local locks in a held_locks.
+   2. Races are avoidable without explicit protection while accessing
+      local locks in a held_locks.
    3. Lockdep only needs to keep locks currently being held.
 
 CONCLUSION
@@ -353,8 +353,9 @@ Introduce commit
 Since crossrelease defers the work adding true dependencies of
 crosslocks until they are eventually released, crossrelease has to queue
 all acquisitions which might create dependencies with the crosslocks.
-Then it identifies dependencies using the queued data in batches at a
-proper time. We call it 'commit'.
+Then lockdep can identify dependencies using the queued data in batches
+at a proper time. We call the step adding true dependencies to the graph
+in batches, 'commit'.
 
 There are four types of dependencies:
 
@@ -433,6 +434,7 @@ How crossrelease works
 
 It's the key of how crossrelease works, to defer necessary works to an
 appropriate point in time and perform the works at the commit step.
+
 Let's take a look at examples step by step, starting from how lockdep
 works for typical locks, without crossrelease.
 
@@ -460,9 +462,9 @@ And after adding 'B -> C', the graph will be:
 
    where A, B, and C are different lock classes.
 
-Let's performs commit step even for typical locks to add dependencies.
-Of course, commit step is not necessary for them, however, it would work
-well because this is a more general way.
+Let's build the graph using the commit step with the same example. Of
+course, the step is not necessary for typical locks, however, it would
+also work because this is a more general way.
 
    acquire A
    /*
@@ -526,9 +528,8 @@ well because this is a more general way.
 
    where A, B, and C are different lock classes.
 
-In this case, dependencies are added at the commit step as described.
-
-After commits for A, B and C, the graph will be:
+Dependencies are added at the commit step as described. After commits
+for A, B, and C, the graph will be:
 
    A -> B -> C
 
@@ -537,19 +538,18 @@ After commits for A, B and C, the graph will be:
    NOTE: A dependency 'A -> C' is optimized out.
 
 We can see the former graph built without the commit step is same as the
-latter graph built using commit steps. Of course, the former way leads to
+latter graph. Of course, the former way leads to
 earlier finish for building the graph, which means we can detect a
 deadlock or its possibility sooner. So the former way would be preferred
 when possible. But we cannot avoid using the latter way for crosslocks.
 
-Let's look at how commit steps work for crosslocks. In this case, the
-commit step is performed only on crosslock AX as real. And it assumes
-that the AX release context is different from the AX acquire context.
+Lastly, let's look at how commit works for crosslocks in practice.
 
    BX RELEASE CONTEXT		   BX ACQUIRE CONTEXT
    ------------------		   ------------------
 				   acquire A
 				   /*
+				    * Add 'the top of held_locks -> A'
 				    * Push A to held_locks
 				    * Queue A in hist_locks
 				    *
@@ -574,6 +574,7 @@ that the AX release context is different from the AX acquire context.
 
    acquire C
    /*
+    * Add 'the top of held_locks -> C'
     * Push C to held_locks
     * Queue C in hist_locks
     *
@@ -592,9 +593,9 @@ that the AX release context is different from the AX acquire context.
     */
 				   acquire D
 				   /*
+				    * Add 'the top of held_locks -> D'
 				    * Push D to held_locks
 				    * Queue D in hist_locks
-				    * Add 'the top of held_locks -> D'
 				    *
 				    * In held_locks: A, D
 				    * In hist_locks: A, D
@@ -602,6 +603,7 @@ that the AX release context is different from the AX acquire context.
 				    */
    acquire E
    /*
+    * Add 'the top of held_locks -> E'
     * Push E to held_locks
     * Queue E in hist_locks
     *
@@ -629,6 +631,7 @@ that the AX release context is different from the AX acquire context.
    commit BX
    /*
     * Add 'BX -> ?'
+    * Answer the following to decide '?'
     * What has been queued since acquire BX: C, E
     *
     * In held_locks: Empty
@@ -657,12 +660,12 @@ that the AX release context is different from the AX acquire context.
    where A, BX, C,..., E are different lock classes and a suffix 'X' is
    added at crosslocks.
 
-Crossrelease considers all acquisitions after acquiring BX are
-candidates which might create dependencies with BX. True dependencies
-will be determined when identifying the release context of BX. Meanwhile,
+Crossrelease considers all acquisitions following acquiring BX because
+they can create dependencies with BX. The dependencies will be
+determined in the release context of BX. Meanwhile,
 all typical locks are queued so that they can be used at the commit step.
-And then two dependencies 'BX -> C' and 'BX -> E' are added at the
-commit step when identifying the release context.
+Finally, two dependencies 'BX -> C' and 'BX -> E' will be added at the
+commit step, when identifying the release context.
 
 The final graph will be, with crossrelease:
 
@@ -705,12 +708,12 @@ dependency chains, but this time it's for caching CT type dependencies.
 Once a dependency is cached, the same will never be added again.
 
 
-Lockless for hot paths
-----------------------
+Make hot paths lockless
+-----------------------
 
 To keep all locks for later use at the commit step, crossrelease adopts
-a local array embedded in task_struct, which makes access to the data
-lockless by forcing it to happen only within the owner context. It's
+a local array embedded in task_struct, which makes the data locklessly
+accessible by forcing it to happen only within the owner context. It's
 like how lockdep handles held_locks. Lockless implementation is important
 since typical locks are very frequently acquired and released.
 
@@ -723,10 +726,10 @@ A deadlock actually occurs when all waiters creating circular
 dependencies run at the same time. Even though they don't, a potential
 deadlock exists if the problematic dependencies exist. Thus, it's
 meaningful to detect not only an actual deadlock but also its potential
-possibility. The latter is rather valuable. When a deadlock occurs
-actually, we can identify what happens in the system by some means or
-other even without lockdep. However, there's no way to detect possibility
-without lockdep unless the whole code is parsed in the head. It's terrible.
+possibility. The latter is rather valuable. When a deadlock actually
+occurs, we can identify what happens in the system by some means or
+other even without lockdep. However, there's no way to detect a possibility
+without lockdep, unless the whole code is parsed in the head. It's terrible.
 Lockdep does the both, and crossrelease only focuses on the latter.
 
 Whether or not a deadlock actually occurs depends on several factors.
@@ -775,8 +778,8 @@ Remind what a dependency is. A dependency exists if:
 
 For example:
 
-   TASK X			   TASK Y
-   ------			   ------
+   CONTEXT X			   CONTEXT Y
+   ---------			   ---------
 				   acquire AX
    acquire B /* A dependency 'AX -> B' exists */
    release B
@@ -785,18 +788,18 @@ For example:
    where AX and B are different lock classes and a suffix 'X' is added
    at crosslocks.
 
-Even in this case involving crosslocks, the same rule can be applied. A
-dependency 'AX -> B' exists since:
+Here, a dependency 'AX -> B' exists since:
 
    1. A waiter for AX and a waiter for B might exist when acquiring B.
    2. The only way to wake up each is to release what it waits for.
    3. Whether the waiter for AX can be woken up depends on whether the
-      other can. IOW, TASK X cannot release AX if it fails to acquire B.
+      other can. In other words, CONTEXT X cannot release AX if it fails
+      to acquire B.
 
 Let's take a look at a more complicated example:
 
-   TASK X			   TASK Y
-   ------			   ------
+   CONTEXT X			   CONTEXT Y
+   ---------			   ---------
    acquire B
    release B
    fork Y
@@ -818,8 +821,8 @@ It would be ideal if the full set of true ones can be considered. But
 we can ensure nothing but what actually happened. Relying on what
 actually happens at runtime, we can anyway add only true ones, though
 they might be a subset of true ones. It's similar to how lockdep works
-for typical locks. There might be more true dependencies than what
-lockdep has detected at runtime. Lockdep has no choice but to rely on
+for typical locks. There might be more true dependencies than lockdep
+has detected. Lockdep has no choice but to rely on
 what actually happens. Crossrelease also relies on it.
 
 CONCLUSION
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
