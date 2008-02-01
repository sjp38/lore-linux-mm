Message-Id: <20080201191415.143702000@sgi.com>
References: <20080201191414.961558000@sgi.com>
Date: Fri, 01 Feb 2008 11:14:15 -0800
From: travis@sgi.com
Subject: [PATCH 1/4] generic: Percpu infrastructure to rebase the per cpu area to zero
Content-Disposition: inline; filename=zero_based_infrastructure
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

	CONFIG_HAVE_ZERO_BASED_PER_CPU

      that makes offsets for per cpu variables to start at zero.

      If a percpu area starts at zero then:

	-  We do not need RELOC_HIDE anymore

	-  Provides for the future capability of architectures providing
	   a per cpu allocator that returns offsets instead of pointers.
	   The offsets would be independent of the processor so that
	   address calculations can be done in a processor independent way.
	   Per cpu instructions can then add the processor specific offset
	   at the last minute possibly in an atomic instruction.

      The data the linker provides is different for zero based percpu segments:

	__per_cpu_load	-> The address at which the percpu area was loaded
	__per_cpu_size	-> The length of the per cpu area

      For non-zero-based percpu segments, the above symbols are adjusted to
      maintain compatibility with existing architectures.

    * Removes the &__per_cpu_x in lockdep. The __per_cpu_x are already
      pointers. There is no need to take the address.

Based on linux-2.6.git + x86.git

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 include/asm-generic/percpu.h      |    5 +++++
 include/asm-generic/sections.h    |   10 ++++++++++
 include/asm-generic/vmlinux.lds.h |   14 ++++++++++++++
 kernel/lockdep.c                  |    4 ++--
 kernel/module.c                   |   10 ++++------
 5 files changed, 35 insertions(+), 8 deletions(-)

--- a/include/asm-generic/percpu.h
+++ b/include/asm-generic/percpu.h
@@ -43,7 +43,12 @@ extern unsigned long __per_cpu_offset[NR
  * Only S390 provides its own means of moving the pointer.
  */
 #ifndef SHIFT_PERCPU_PTR
+#ifndef CONFIG_HAVE_ZERO_BASED_PER_CPU
 #define SHIFT_PERCPU_PTR(__p, __offset)	RELOC_HIDE((__p), (__offset))
+#else
+#define SHIFT_PERCPU_PTR(__p, __offset) \
+	((__typeof(__p))(((void *)(__p)) + (__offset)))
+#endif
 #endif
 
 /*
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -11,7 +11,17 @@ extern char _sinittext[], _einittext[];
 extern char _sextratext[] __attribute__((weak));
 extern char _eextratext[] __attribute__((weak));
 extern char _end[];
+#ifdef CONFIG_HAVE_ZERO_BASED_PER_CPU
+extern char __per_cpu_load[];
+extern char ____per_cpu_size[];
+#define __per_cpu_size ((unsigned long)&____per_cpu_size)
+#define __per_cpu_start ((char *)0)
+#define __per_cpu_end ((char *)__per_cpu_size)
+#else
 extern char __per_cpu_start[], __per_cpu_end[];
+#define __per_cpu_load __per_cpu_start
+#define __per_cpu_size (__per_cpu_end - __per_cpu_start)
+#endif
 extern char __kprobes_text_start[], __kprobes_text_end[];
 extern char __initdata_begin[], __initdata_end[];
 extern char __start_rodata[], __end_rodata[];
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -341,6 +341,19 @@
   	*(.initcall7.init)						\
   	*(.initcall7s.init)
 
+#ifdef CONFIG_HAVE_ZERO_BASED_PER_CPU
+#define PERCPU(align)							\
+	. = ALIGN(align);						\
+	percpu : { } :percpu						\
+	__per_cpu_load = .;						\
+	.data.percpu 0 : AT(__per_cpu_load - LOAD_OFFSET) {		\
+		*(.data.percpu)						\
+		*(.data.percpu.shared_aligned)				\
+		____per_cpu_size = .;					\
+	}								\
+	. = __per_cpu_load + ____per_cpu_size;				\
+	data : { } :data
+#else
 #define PERCPU(align)							\
 	. = ALIGN(align);						\
 	__per_cpu_start = .;						\
@@ -349,3 +362,4 @@
 		*(.data.percpu.shared_aligned)				\
 	}								\
 	__per_cpu_end = .;
+#endif
--- a/kernel/lockdep.c
+++ b/kernel/lockdep.c
@@ -609,8 +609,8 @@ static int static_obj(void *obj)
 	 * percpu var?
 	 */
 	for_each_possible_cpu(i) {
-		start = (unsigned long) &__per_cpu_start + per_cpu_offset(i);
-		end   = (unsigned long) &__per_cpu_start + PERCPU_ENOUGH_ROOM
+		start = (unsigned long) __per_cpu_start + per_cpu_offset(i);
+		end   = (unsigned long) __per_cpu_start + PERCPU_ENOUGH_ROOM
 					+ per_cpu_offset(i);
 
 		if ((addr >= start) && (addr < end))
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -45,6 +45,7 @@
 #include <asm/uaccess.h>
 #include <asm/semaphore.h>
 #include <asm/cacheflush.h>
+#include <asm/sections.h>
 #include <linux/license.h>
 
 #if 0
@@ -344,9 +345,6 @@ static inline unsigned int block_size(in
 	return val;
 }
 
-/* Created by linker magic */
-extern char __per_cpu_start[], __per_cpu_end[];
-
 static void *percpu_modalloc(unsigned long size, unsigned long align,
 			     const char *name)
 {
@@ -360,7 +358,7 @@ static void *percpu_modalloc(unsigned lo
 		align = PAGE_SIZE;
 	}
 
-	ptr = __per_cpu_start;
+	ptr = __per_cpu_load;
 	for (i = 0; i < pcpu_num_used; ptr += block_size(pcpu_size[i]), i++) {
 		/* Extra for alignment requirement. */
 		extra = ALIGN((unsigned long)ptr, align) - (unsigned long)ptr;
@@ -395,7 +393,7 @@ static void *percpu_modalloc(unsigned lo
 static void percpu_modfree(void *freeme)
 {
 	unsigned int i;
-	void *ptr = __per_cpu_start + block_size(pcpu_size[0]);
+	void *ptr = __per_cpu_load + block_size(pcpu_size[0]);
 
 	/* First entry is core kernel percpu data. */
 	for (i = 1; i < pcpu_num_used; ptr += block_size(pcpu_size[i]), i++) {
@@ -446,7 +444,7 @@ static int percpu_modinit(void)
 	pcpu_size = kmalloc(sizeof(pcpu_size[0]) * pcpu_num_allocated,
 			    GFP_KERNEL);
 	/* Static in-kernel percpu data (used). */
-	pcpu_size[0] = -(__per_cpu_end-__per_cpu_start);
+	pcpu_size[0] = -__per_cpu_size;
 	/* Free room. */
 	pcpu_size[1] = PERCPU_ENOUGH_ROOM + pcpu_size[0];
 	if (pcpu_size[1] < 0) {

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
