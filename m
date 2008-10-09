Date: Thu, 9 Oct 2008 16:47:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: git-slab plus git-tip breaks i386 allnoconfig
Message-Id: <20081009164700.c9042902.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In file included from include/linux/rcupdate.h:39,
                 from include/linux/marker.h:16,
                 from include/linux/kmemtrace.h:13,
                 from include/linux/slub_def.h:13,
                 from include/linux/slab.h:184,
                 from include/asm/pgtable_32.h:21,
                 from include/asm/pgtable.h:394,
                 from include/linux/mm.h:40,
                 from arch/x86/mm/pgtable.c:1:
include/linux/percpu.h: In function '__percpu_alloc_mask':
include/linux/percpu.h:108: error: implicit declaration of function 'kzalloc'
include/linux/percpu.h:108: warning: return makes pointer from integer without a cast
In file included from include/asm/pgtable_32.h:21,
                 from include/asm/pgtable.h:394,
                 from include/linux/mm.h:40,
                 from arch/x86/mm/pgtable.c:1:
include/linux/slab.h: At top level:
include/linux/slab.h:336: error: conflicting types for 'kzalloc'
include/linux/percpu.h:108: error: previous implicit declaration of 'kzalloc' was here
In file included from include/linux/rcupdate.h:39,


but that file includes slab.h, so I suspect we have some recursive
include snafu somewhere which caused the slab.h inclusion to get
skipped.

Shudder.   I'll locally use this notapatch:

--- a/include/linux/percpu.h~a
+++ a/include/linux/percpu.h
@@ -103,15 +103,12 @@ extern void percpu_free(void *__pdata);
 
 #define percpu_ptr(ptr, cpu) ({ (void)(cpu); (ptr); })
 
-static __always_inline void *__percpu_alloc_mask(size_t size, gfp_t gfp, cpumask_t *mask)
-{
-	return kzalloc(size, gfp);
-}
-
-static inline void percpu_free(void *__pdata)
-{
-	kfree(__pdata);
-}
+/*
+ * __percpu_alloc_mask() and percpu_free() are macros to simplify header
+ * dependencies
+ */
+#define __percpu_alloc_mask(size, gfp, maskp) kzalloc(size, gfp)
+#define percpu_free(pdata) kfree(pdata)
 
 #endif /* CONFIG_SMP */
 

Whoever merges second gets to fix this for real - have fun ;)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
