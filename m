Date: Thu, 18 Oct 2007 15:15:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Avoid atomic operation for slab_unlock
Message-ID: <Pine.LNX.4.64.0710181514310.3584@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently page flags are only modified in SLUB under page lock. This means
that we do not need an atomic operation to release the lock since there
is nothing we can race against that is modifying page flags. We can simply
clear the bit without the use of an atomic operation and make sure that this
change becomes visible after the other changes to slab metadata through
a memory barrier.

The performance of slab_free() increases 10-15% (SMP configuration doing
a long series of remote frees).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-10-18 14:12:59.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-10-18 14:24:43.000000000 -0700
@@ -1180,9 +1180,22 @@ static __always_inline void slab_lock(st
 	bit_spin_lock(PG_locked, &page->flags);
 }
 
+/*
+ * Slab unlock version that avoids having to use atomic operations
+ * (echos some of the code of bit_spin_unlock!)
+ */
 static __always_inline void slab_unlock(struct page *page)
 {
-	bit_spin_unlock(PG_locked, &page->flags);
+#ifdef CONFIG_SMP
+	unsigned long flags;
+
+	flags = page->flags & ~(1 << PG_locked);
+
+	smp_wmb();
+	page->flags = flags;
+#endif
+	preempt_enable();
+	__release(bitlock);
 }
 
 static __always_inline int slab_trylock(struct page *page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
