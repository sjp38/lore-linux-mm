Message-Id: <20080118182954.323802000@sgi.com>
References: <20080118182953.748071000@sgi.com>
Date: Fri, 18 Jan 2008 10:29:57 -0800
From: travis@sgi.com
Subject: [PATCH 4/7] ia64: Use generic percpu
Content-Disposition: inline; filename=ia64_generic_percpu
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

ia64 has a special processor specific mapping that can be used to locate the
offset for the current per cpu area.

Cc: linux-ia64@vger.kernel.org
Cc: tony.luck@intel.com
Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Mike Travis <travis@sgi.com>
---

V1->V2:
- Merge fixes
- Remove transitional check for PER_CPU_ATTRIBUTES from linux/percpu.h

V2-.V3:
- use generic percpy_modcopy()

---
 include/asm-ia64/percpu.h |   24 +++++++-----------------
 include/linux/percpu.h    |    4 ----
 2 files changed, 7 insertions(+), 21 deletions(-)

--- a/include/asm-ia64/percpu.h
+++ b/include/asm-ia64/percpu.h
@@ -19,29 +19,14 @@
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
@@ -52,7 +37,12 @@ extern void *per_cpu_init(void);
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
 #ifdef CONFIG_SMP
 #define DEFINE_PER_CPU(type, name)					\
 	__attribute__((__section__(".data.percpu")))			\

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
