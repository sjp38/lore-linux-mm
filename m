Date: Wed, 14 May 2008 06:35:11 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 1/2] read_barrier_depends arch fixlets
Message-ID: <20080514043511.GD23578@wotan.suse.de>
References: <20080505112021.GC5018@wotan.suse.de> <20080505121240.GD5018@wotan.suse.de> <alpine.LFD.1.10.0805050828120.32269@woody.linux-foundation.org> <20080506095138.GE10141@wotan.suse.de> <alpine.LFD.1.10.0805060750430.32269@woody.linux-foundation.org> <20080513080143.GB19870@wotan.suse.de> <alpine.LFD.1.10.0805130844000.3019@woody.linux-foundation.org> <20080514003417.GA24516@wotan.suse.de> <alpine.LFD.1.10.0805131753150.3019@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0805131753150.3019@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Paul McKenney <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

read_barrie_depends has always been a noop (not a compiler barrier) on all
architectures except SMP alpha. This brings UP alpha and frv into line with all
other architectures, and fixes incorrect documentation.

Signed-off-by: Nick Piggin <npiggin@suse.de>
Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

---
 Documentation/memory-barriers.txt |   12 +++++++++++-
 include/asm-alpha/barrier.h       |    2 +-
 include/asm-frv/system.h          |    2 +-
 3 files changed, 13 insertions(+), 3 deletions(-)

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
Index: linux-2.6/Documentation/memory-barriers.txt
===================================================================
--- linux-2.6.orig/Documentation/memory-barriers.txt
+++ linux-2.6/Documentation/memory-barriers.txt
@@ -994,7 +994,17 @@ The Linux kernel has eight basic CPU mem
 	DATA DEPENDENCY	read_barrier_depends()	smp_read_barrier_depends()
 
 
-All CPU memory barriers unconditionally imply compiler barriers.
+All memory barriers except the data dependency barriers imply a compiler
+barrier. Data dependencies do not impose any additional compiler ordering.
+
+Aside: In the case of data dependencies, the compiler would be expected to
+issue the loads in the correct order (eg. `a[b]` would have to load the value
+of b before loading a[b]), however there is no guarantee in the C specification
+that the compiler may not speculate the value of b (eg. is equal to 1) and load
+a before b (eg. tmp = a[1]; if (b != 1) tmp = a[b]; ). There is also the
+problem of a compiler reloading b after having loaded a[b], thus having a newer
+copy of b than a[b]. A consensus has not yet been reached about these problems,
+however the ACCESS_ONCE macro is a good place to start looking.
 
 SMP memory barriers are reduced to compiler barriers on uniprocessor compiled
 systems because it is assumed that a CPU will appear to be self-consistent,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
