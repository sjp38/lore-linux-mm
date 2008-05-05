Date: Mon, 5 May 2008 13:20:21 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 1/2] read_barrier_depends fixlets
Message-ID: <20080505112021.GC5018@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Paul McKenney <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

While considering the impact of read_barrier_depends, it occurred to
me that it should really be really a noop for the compiler. At least, it is
better to have every arch the same than to have a few that are slightly
different. (Does this mean SMP Alpha's read_barrier_depends could drop the
"memory" clobber too?)
--
It would be a highly unusual compiler that might try to issue a load of
data1 before it loads a data2 which is data-dependant on data1.

There is the problem of the compiler trying to reload data1 _after_
loading data2, and thus having a newer data1 than data2. However if the
compiler is so inclined, then it could perform such a load at any point
after the barrier, so the barrier itself will not guarantee correctness.

I think we've mostly hoped the compiler would not to do that.

This brings alpha and frv into line with all other architectures.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/include/asm-alpha/barrier.h
===================================================================
--- linux-2.6.orig/include/asm-alpha/barrier.h
+++ linux-2.6/include/asm-alpha/barrier.h
@@ -24,7 +24,7 @@ __asm__ __volatile__("mb": : :"memory")
 #define smp_mb()	barrier()
 #define smp_rmb()	barrier()
 #define smp_wmb()	barrier()
-#define smp_read_barrier_depends()	barrier()
+#define smp_read_barrier_depends()	do { } while (0)
 #endif
 
 #define set_mb(var, value) \
Index: linux-2.6/include/asm-frv/system.h
===================================================================
--- linux-2.6.orig/include/asm-frv/system.h
+++ linux-2.6/include/asm-frv/system.h
@@ -179,7 +179,7 @@ do {							\
 #define mb()			asm volatile ("membar" : : :"memory")
 #define rmb()			asm volatile ("membar" : : :"memory")
 #define wmb()			asm volatile ("membar" : : :"memory")
-#define read_barrier_depends()	barrier()
+#define read_barrier_depends()	do { } while (0)
 
 #ifdef CONFIG_SMP
 #define smp_mb()			mb()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
