From: Christoph Lameter <cl@linux-foundation.org>
Subject: [patch 2/4] percpu: Rename variables PERCPU_ENOUGH_ROOM -> PERCPU_AREA_SIZE
Date: Mon, 29 Sep 2008 12:35:02 -0700
Message-ID: <20080929193516.007781469@quilx.com>
References: <20080929193500.470295078@quilx.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753700AbYI2ThV@vger.kernel.org>
Content-Disposition: inline; filename=cpu_alloc_rename
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, rusty@rustcorp.com.au, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-Id: linux-mm.kvack.org

Rename PERCPU_ENOUGH_ROOM to PERCPU_AREA_SIZE since its really specifying the
size of the percpu areas.

Rename PERCPU_MODULE_RESERVE to PERCPU_RESERVE_SIZE in anticipation of more
general use of that reserve.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 arch/ia64/include/asm/percpu.h |    2 +-
 arch/powerpc/kernel/setup_64.c |    4 ++--
 arch/sparc64/kernel/smp.c      |    2 +-
 arch/x86/kernel/setup_percpu.c |    3 +--
 include/linux/percpu.h         |   10 +++++-----
 init/main.c                    |    4 ++--
 kernel/lockdep.c               |    2 +-
 kernel/module.c                |    2 +-
 8 files changed, 14 insertions(+), 15 deletions(-)

Index: linux-2.6/arch/ia64/include/asm/percpu.h
===================================================================
--- linux-2.6.orig/arch/ia64/include/asm/percpu.h	2008-09-16 18:20:19.000000000 -0700
+++ linux-2.6/arch/ia64/include/asm/percpu.h	2008-09-16 18:27:10.000000000 -0700
@@ -6,7 +6,7 @@
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
-#define PERCPU_ENOUGH_ROOM PERCPU_PAGE_SIZE
+#define PERCPU_AREA_SIZE PERCPU_PAGE_SIZE
 
 #ifdef __ASSEMBLY__
 # define THIS_CPU(var)	(per_cpu__##var)  /* use this to mark accesses to per-CPU variables... */
Index: linux-2.6/include/linux/percpu.h
===================================================================
--- linux-2.6.orig/include/linux/percpu.h	2008-09-16 18:25:38.000000000 -0700
+++ linux-2.6/include/linux/percpu.h	2008-09-16 18:28:55.000000000 -0700
@@ -36,16 +36,16 @@
 
 extern unsigned int percpu_reserve;
 /* Enough to cover all DEFINE_PER_CPUs in kernel, including modules. */
-#ifndef PERCPU_ENOUGH_ROOM
+#ifndef PERCPU_AREA_SIZE
 #ifdef CONFIG_MODULES
-#define PERCPU_MODULE_RESERVE	8192
+#define PERCPU_RESERVE_SIZE	8192
 #else
-#define PERCPU_MODULE_RESERVE	0
+#define PERCPU_RESERVE_SIZE	0
 #endif
 
-#define PERCPU_ENOUGH_ROOM						\
+#define PERCPU_AREA_SIZE						\
 	(__per_cpu_end - __per_cpu_start + percpu_reserve)
-#endif	/* PERCPU_ENOUGH_ROOM */
+#endif	/* PERCPU_AREA_SIZE */
 
 /*
  * Must be an lvalue. Since @var must be a simple identifier,
Index: linux-2.6/arch/powerpc/kernel/setup_64.c
===================================================================
--- linux-2.6.orig/arch/powerpc/kernel/setup_64.c	2008-09-16 18:13:45.000000000 -0700
+++ linux-2.6/arch/powerpc/kernel/setup_64.c	2008-09-16 18:25:43.000000000 -0700
@@ -599,8 +599,8 @@ void __init setup_per_cpu_areas(void)
 	/* Copy section for each CPU (we discard the original) */
 	size = ALIGN(__per_cpu_end - __per_cpu_start, PAGE_SIZE);
 #ifdef CONFIG_MODULES
-	if (size < PERCPU_ENOUGH_ROOM)
-		size = PERCPU_ENOUGH_ROOM;
+	if (size < PERCPU_AREA_SIZE)
+		size = PERCPU_AREA_SIZE;
 #endif
 
 	for_each_possible_cpu(i) {
Index: linux-2.6/arch/sparc64/kernel/smp.c
===================================================================
--- linux-2.6.orig/arch/sparc64/kernel/smp.c	2008-09-16 18:13:45.000000000 -0700
+++ linux-2.6/arch/sparc64/kernel/smp.c	2008-09-16 18:25:43.000000000 -0700
@@ -1386,7 +1386,7 @@ void __init real_setup_per_cpu_areas(voi
 	char *ptr;
 
 	/* Copy section for each CPU (we discard the original) */
-	goal = PERCPU_ENOUGH_ROOM;
+	goal = PERCPU_AREA_SIZE;
 
 	__per_cpu_shift = PAGE_SHIFT;
 	for (size = PAGE_SIZE; size < goal; size <<= 1UL)
Index: linux-2.6/arch/x86/kernel/setup_percpu.c
===================================================================
--- linux-2.6.orig/arch/x86/kernel/setup_percpu.c	2008-09-16 18:13:45.000000000 -0700
+++ linux-2.6/arch/x86/kernel/setup_percpu.c	2008-09-16 18:25:43.000000000 -0700
@@ -140,7 +140,7 @@ static void __init setup_cpu_pda_map(voi
  */
 void __init setup_per_cpu_areas(void)
 {
-	ssize_t size = PERCPU_ENOUGH_ROOM;
+	ssize_t size = PERCPU_AREA_SIZE;
 	char *ptr;
 	int cpu;
 
@@ -148,7 +148,6 @@ void __init setup_per_cpu_areas(void)
 	setup_cpu_pda_map();
 
 	/* Copy section for each CPU (we discard the original) */
-	size = PERCPU_ENOUGH_ROOM;
 	printk(KERN_INFO "PERCPU: Allocating %zd bytes of per cpu data\n",
 			  size);
 
Index: linux-2.6/init/main.c
===================================================================
--- linux-2.6.orig/init/main.c	2008-09-16 18:25:38.000000000 -0700
+++ linux-2.6/init/main.c	2008-09-16 18:29:40.000000000 -0700
@@ -253,7 +253,7 @@ static int __init loglevel(char *str)
 
 early_param("loglevel", loglevel);
 
-unsigned int percpu_reserve = PERCPU_MODULE_RESERVE;
+unsigned int percpu_reserve = PERCPU_RESERVE_SIZE;
 
 static int __init init_percpu_reserve(char *str)
 {
@@ -406,7 +406,7 @@ static void __init setup_per_cpu_areas(v
 	unsigned long nr_possible_cpus = num_possible_cpus();
 
 	/* Copy section for each CPU (we discard the original) */
-	size = ALIGN(PERCPU_ENOUGH_ROOM, PAGE_SIZE);
+	size = ALIGN(PERCPU_AREA_SIZE, PAGE_SIZE);
 	printk(KERN_INFO "percpu area: %d bytes total, %d available.\n",
 			size, size - (__per_cpu_end - __per_cpu_start));
 
Index: linux-2.6/kernel/lockdep.c
===================================================================
--- linux-2.6.orig/kernel/lockdep.c	2008-09-16 18:13:45.000000000 -0700
+++ linux-2.6/kernel/lockdep.c	2008-09-16 18:25:43.000000000 -0700
@@ -639,7 +639,7 @@ static int static_obj(void *obj)
 	 */
 	for_each_possible_cpu(i) {
 		start = (unsigned long) &__per_cpu_start + per_cpu_offset(i);
-		end   = (unsigned long) &__per_cpu_start + PERCPU_ENOUGH_ROOM
+		end   = (unsigned long) &__per_cpu_start + PERCPU_AREA_SIZE
 					+ per_cpu_offset(i);
 
 		if ((addr >= start) && (addr < end))
Index: linux-2.6/kernel/module.c
===================================================================
--- linux-2.6.orig/kernel/module.c	2008-09-16 18:13:45.000000000 -0700
+++ linux-2.6/kernel/module.c	2008-09-16 18:25:43.000000000 -0700
@@ -476,7 +476,7 @@ static int percpu_modinit(void)
 	/* Static in-kernel percpu data (used). */
 	pcpu_size[0] = -(__per_cpu_end-__per_cpu_start);
 	/* Free room. */
-	pcpu_size[1] = PERCPU_ENOUGH_ROOM + pcpu_size[0];
+	pcpu_size[1] = PERCPU_AREA_SIZE + pcpu_size[0];
 	if (pcpu_size[1] < 0) {
 		printk(KERN_ERR "No per-cpu room for modules.\n");
 		pcpu_num_used = 1;

-- 
