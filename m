Message-Id: <20071228001618.816048000@sgi.com>
References: <20071228001617.597161000@sgi.com>
Date: Thu, 27 Dec 2007 16:16:26 -0800
From: travis@sgi.com
Subject: [PATCH 09/10] ia64: Use generic percpu
Content-Disposition: inline; filename=ia64_generic_percpu
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

- Merge fixes
- Remove transitional check for PER_CPU_ATTRIBUTES from linux/percpu.h

ia64 has a special processor specific mapping that can be used to locate the
offset for the current per cpu area.

Cc: linux-ia64@vger.kernel.org
Cc: tony.luck@intel.com
Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Mike Travis <travis@sgi.com>

---
 include/asm-ia64/percpu.h |   25 +++++++------------------
 include/linux/percpu.h    |    4 ----
 2 files changed, 7 insertions(+), 22 deletions(-)

--- a/include/asm-ia64/percpu.h
+++ b/include/asm-ia64/percpu.h
@@ -12,36 +12,20 @@
 # define THIS_CPU(var)	(per_cpu__##var)  /* use this to mark accesses to per-CPU variables... */
 #else /* !__ASSEMBLY__ */
 
-
 #include <linux/threads.h>
 
 #ifdef HAVE_MODEL_SMALL_ATTRIBUTE
 # define PER_CPU_ATTRIBUTES	__attribute__((__model__ (__small__)))
 #endif
 
-#define DECLARE_PER_CPU(type, name)				\
-	extern PER_CPU_ATTRIBUTES __typeof__(type) per_cpu__##name
-
 #ifdef CONFIG_SMP
 
-extern unsigned long __per_cpu_offset[NR_CPUS];
-#define per_cpu_offset(x) (__per_cpu_offset[x])
-
-/* Equal to __per_cpu_offset[smp_processor_id()], but faster to access: */
-DECLARE_PER_CPU(unsigned long, local_per_cpu_offset);
-
-#define per_cpu(var, cpu)  (*RELOC_HIDE(&per_cpu__##var, __per_cpu_offset[cpu]))
-#define __get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __ia64_per_cpu_var(local_per_cpu_offset)))
-#define __raw_get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __ia64_per_cpu_var(local_per_cpu_offset)))
+#define __my_cpu_offset	__ia64_per_cpu_var(local_per_cpu_offset)
 
-extern void setup_per_cpu_areas (void);
 extern void *per_cpu_init(void);
 
 #else /* ! SMP */
 
-#define per_cpu(var, cpu)			(*((void)(cpu), &per_cpu__##var))
-#define __get_cpu_var(var)			per_cpu__##var
-#define __raw_get_cpu_var(var)			per_cpu__##var
 #define per_cpu_init()				(__phys_per_cpu_start)
 
 #endif	/* SMP */
@@ -52,7 +36,12 @@ extern void *per_cpu_init(void);
  * On the positive side, using __ia64_per_cpu_var() instead of __get_cpu_var() is slightly
  * more efficient.
  */
-#define __ia64_per_cpu_var(var)	(per_cpu__##var)
+#define __ia64_per_cpu_var(var)	per_cpu__##var
+
+#include <asm-generic/percpu.h>
+
+/* Equal to __per_cpu_offset[smp_processor_id()], but faster to access: */
+DECLARE_PER_CPU(unsigned long, local_per_cpu_offset);
 
 #endif /* !__ASSEMBLY__ */
 
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -9,10 +9,6 @@
 
 #include <asm/percpu.h>
 
-#ifndef PER_CPU_ATTRIBUTES
-#define PER_CPU_ATTRIBUTES
-#endif
-
 #define DEFINE_PER_CPU(type, name)					\
 	__attribute__((__section__(".data.percpu")))			\
 	PER_CPU_ATTRIBUTES __typeof__(type) per_cpu__##name

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
