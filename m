Message-Id: <20080118182954.456392000@sgi.com>
References: <20080118182953.748071000@sgi.com>
Date: Fri, 18 Jan 2008 10:29:58 -0800
From: travis@sgi.com
Subject: [PATCH 5/7] Powerpc: Use generic per cpu
Content-Disposition: inline; filename=power_generic_percpu
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>
List-ID: <linux-mm.kvack.org>

Powerpc has a way to determine the address of the per cpu area of the
currently executing processor via the paca and the array of per cpu
offsets is avoided by looking up the per cpu area from the remote
paca's (copying x86_64).

Cc: Paul Mackerras <paulus@samba.org>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Mike Travis <travis@sgi.com>
---

V1->V2:
- add missing #endif

V2->V3:
- use generic percpy_modcopy()

---
 include/asm-powerpc/percpu.h |   20 ++------------------
 1 file changed, 2 insertions(+), 18 deletions(-)

--- a/include/asm-powerpc/percpu.h
+++ b/include/asm-powerpc/percpu.h
@@ -16,25 +16,9 @@
 #define __my_cpu_offset() get_paca()->data_offset
 #define per_cpu_offset(x) (__per_cpu_offset(x))
 
-/* var is in discarded region: offset to particular copy we want */
-#define per_cpu(var, cpu) (*RELOC_HIDE(&per_cpu__##var, __per_cpu_offset(cpu)))
-#define __get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __my_cpu_offset()))
-#define __raw_get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, local_paca->data_offset))
+#endif /* CONFIG_SMP */
+#endif /* __powerpc64__ */
 
-extern void setup_per_cpu_areas(void);
-
-#else /* ! SMP */
-
-#define per_cpu(var, cpu)			(*((void)(cpu), &per_cpu__##var))
-#define __get_cpu_var(var)			per_cpu__##var
-#define __raw_get_cpu_var(var)			per_cpu__##var
-
-#endif	/* SMP */
-
-#define DECLARE_PER_CPU(type, name) extern __typeof__(type) per_cpu__##name
-
-#else
 #include <asm-generic/percpu.h>
-#endif
 
 #endif /* _ASM_POWERPC_PERCPU_H_ */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
