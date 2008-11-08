Message-Id: <20081108022014.313731000@nick.local0.net>
References: <20081108021512.686515000@suse.de>
Date: Sat, 08 Nov 2008 13:15:20 +1100
From: npiggin@suse.de
Subject: [patch 8/9] mm: vmalloc make guard configurable
Content-Disposition: inline; filename=mm-vmalloc-guard-config.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, glommer@redhat.com, rjw@sisk.pl
List-ID: <linux-mm.kvack.org>

In mm/vmalloc.c, make usage of guard pages dependant on CONFIG_DEBUG_PAGEALLOC.

Signed-off-by: Glauber Costa <glommer@redhat.com>

Reworked so the guard size logic remains inside the allocator.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 mm/vmalloc.c |   25 +++++++++++++++----------
 1 files changed, 15 insertions(+), 10 deletions(-)

Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -29,6 +29,16 @@
 #include <asm/uaccess.h>
 #include <asm/tlbflush.h>
 
+/*
+ * Add a guard page between each kernel virtual address allocation if
+ * DEBUG_PAGEALLOC is turned on (could be a separate config option, but
+ * no big deal).
+ */
+#ifdef CONFIG_DEBUG_PAGEALLOC
+#define GUARD_SIZE PAGE_SIZE
+#else
+#define GUARD_SIZE 0
+#endif
 
 /*** Page table manipulation functions ***/
 
@@ -364,7 +374,7 @@ retry:
 		}
 
 		while (addr + size > first->va_start && addr + size <= vend) {
-			addr = ALIGN(first->va_end + PAGE_SIZE, align);
+			addr = ALIGN(first->va_end + GUARD_SIZE, align);
 
 			n = rb_next(&first->rb_node);
 			if (n)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
