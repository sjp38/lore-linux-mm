Message-Id: <20080130180940.788340000@sgi.com>
References: <20080130180940.022172000@sgi.com>
Date: Wed, 30 Jan 2008 10:09:45 -0800
From: travis@sgi.com
Subject: [PATCH 5/6] powerpc: Use generic per cpu linux-2.6.git
Content-Disposition: inline; filename=power_generic_percpu
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, mingo@elte.hu, Thomas Gleixner <tglx@linutronix.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>
List-ID: <linux-mm.kvack.org>

Powerpc has a way to determine the address of the per cpu area of the
currently executing processor via the paca and the array of per cpu
offsets is avoided by looking up the per cpu area from the remote
paca's (copying x86_64).

Based on latest linux-2.6.git

Cc: Paul Mackerras <paulus@samba.org>
Cc: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>

Signed-off-by: Mike Travis <travis@sgi.com>
---
linux-2.6.git:
  - added back in missing pieces from x86.git merge
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
