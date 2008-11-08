Message-Id: <20081108022013.669674000@nick.local0.net>
References: <20081108021512.686515000@suse.de>
Date: Sat, 08 Nov 2008 13:15:14 +1100
From: npiggin@suse.de
Subject: [patch 2/9] mm: vmalloc failure flush fix
Content-Disposition: inline; filename=mm-vmalloc-flush-fix.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, glommer@redhat.com, rjw@sisk.pl
List-ID: <linux-mm.kvack.org>

An initial vmalloc failure should start off a synchronous flush of lazy
areas, in case someone is in progress flushing them already, which could
cause us to return an allocation failure even if there is plenty of KVA
free.
 
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -522,13 +522,24 @@ static void __purge_vmap_area_lazy(unsig
 }
 
 /*
+ * Kick off a purge of the outstanding lazy areas. Don't bother if somebody
+ * is already purging.
+ */
+static void try_purge_vmap_area_lazy(void)
+{
+	unsigned long start = ULONG_MAX, end = 0;
+
+	__purge_vmap_area_lazy(&start, &end, 0, 0);
+}
+
+/*
  * Kick off a purge of the outstanding lazy areas.
  */
 static void purge_vmap_area_lazy(void)
 {
 	unsigned long start = ULONG_MAX, end = 0;
 
-	__purge_vmap_area_lazy(&start, &end, 0, 0);
+	__purge_vmap_area_lazy(&start, &end, 1, 0);
 }
 
 /*
@@ -539,7 +550,7 @@ static void free_unmap_vmap_area(struct 
 	va->flags |= VM_LAZY_FREE;
 	atomic_add((va->va_end - va->va_start) >> PAGE_SHIFT, &vmap_lazy_nr);
 	if (unlikely(atomic_read(&vmap_lazy_nr) > lazy_max_pages()))
-		purge_vmap_area_lazy();
+		try_purge_vmap_area_lazy();
 }
 
 static struct vmap_area *find_vmap_area(unsigned long addr)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
