Message-Id: <20080117223505.644199000@sgi.com>
References: <20080117223505.203884000@sgi.com>
Date: Thu, 17 Jan 2008 14:35:08 -0800
From: travis@sgi.com
Subject: [PATCH 3/6] Sparc64: Use generic percpu
Content-Disposition: inline; filename=sparc64_generic_percpu
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Sparc64 has a way of providing the base address for the per cpu area of the
currently executing processor in a global register.

Sparc64 also provides a way to calculate the address of a per cpu area
from a base address instead of performing an array lookup.

Cc: David Miller <davem@davemloft.net>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/sparc64/mm/init.c       |    5 +++++
 include/asm-sparc64/percpu.h |   22 +++-------------------
 2 files changed, 8 insertions(+), 19 deletions(-)

--- a/arch/sparc64/mm/init.c
+++ b/arch/sparc64/mm/init.c
@@ -1328,6 +1328,11 @@ pgd_t swapper_pg_dir[2048];
 static void sun4u_pgprot_init(void);
 static void sun4v_pgprot_init(void);
 
+/* Dummy function */
+void __init setup_per_cpu_areas(void)
+{
+}
+
 void __init paging_init(void)
 {
 	unsigned long end_pfn, pages_avail, shift, phys_base;
--- a/include/asm-sparc64/percpu.h
+++ b/include/asm-sparc64/percpu.h
@@ -7,7 +7,6 @@ register unsigned long __local_per_cpu_o
 
 #ifdef CONFIG_SMP
 
-#define setup_per_cpu_areas()			do { } while (0)
 extern void real_setup_per_cpu_areas(void);
 
 extern unsigned long __per_cpu_base;
@@ -16,29 +15,14 @@ extern unsigned long __per_cpu_shift;
 	(__per_cpu_base + ((unsigned long)(__cpu) << __per_cpu_shift))
 #define per_cpu_offset(x) (__per_cpu_offset(x))
 
-/* var is in discarded region: offset to particular copy we want */
-#define per_cpu(var, cpu) (*RELOC_HIDE(&per_cpu__##var, __per_cpu_offset(cpu)))
-#define __get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __local_per_cpu_offset))
-#define __raw_get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __local_per_cpu_offset))
-
-/* A macro to avoid #include hell... */
-#define percpu_modcopy(pcpudst, src, size)			\
-do {								\
-	unsigned int __i;					\
-	for_each_possible_cpu(__i)				\
-		memcpy((pcpudst)+__per_cpu_offset(__i),		\
-		       (src), (size));				\
-} while (0)
+#define __my_cpu_offset __local_per_cpu_offset
+
 #else /* ! SMP */
 
 #define real_setup_per_cpu_areas()		do { } while (0)
 
-#define per_cpu(var, cpu)			(*((void)cpu, &per_cpu__##var))
-#define __get_cpu_var(var)			per_cpu__##var
-#define __raw_get_cpu_var(var)			per_cpu__##var
-
 #endif	/* SMP */
 
-#define DECLARE_PER_CPU(type, name) extern __typeof__(type) per_cpu__##name
+#include <asm-generic/percpu.h>
 
 #endif /* __ARCH_SPARC64_PERCPU__ */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
