Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 01CD26B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 12:27:57 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id jt11so635134pbb.11
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 09:27:57 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id eb3si16231092pbd.47.2014.01.28.09.27.52
        for <linux-mm@kvack.org>;
        Tue, 28 Jan 2014 09:27:52 -0800 (PST)
Subject: [PATCH] mm: slub: do not VM_BUG_ON_PAGE() for temporary on-stack pages
From: Dave Hansen <dave@sr71.net>
Date: Tue, 28 Jan 2014 09:27:49 -0800
Message-Id: <20140128172749.BBF280B1@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Dave Hansen <dave@sr71.net>, sasha.levin@oracle.com, kirill@shutemov.name, akpm@linux-foundation.org, torvalds@linux-foundation.org, penberg@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

This patch:

	commit 309381feaee564281c3d9e90fbca8963bb7428ad
	Author: Sasha Levin <sasha.levin@oracle.com>
	Date:   Thu Jan 23 15:52:54 2014 -0800
	Subject: mm: dump page when hitting a VM_BUG_ON using VM_BUG_ON_PAGE

added a bunch of VM_BUG_ON_PAGE() calls.  But, most of the ones
in the slub code are for _temporary_ 'struct page's which are
declared on the stack and likely have lots of gunk in them.
Dumping their contents out will just confuse folks looking at
bad_page() output.  Plus, if we try to page_to_pfn() on them or
soemthing, we'll probably oops anyway.

Turn them back in to VM_BUG_ON()s.

I believe this is 3.14 material.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>

---

 b/mm/slub.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff -puN mm/slub.c~mm-slub-do-not-VM_BUG_ON-stack-pages mm/slub.c
--- a/mm/slub.c~mm-slub-do-not-VM_BUG_ON-stack-pages	2014-01-28 09:17:49.869780639 -0800
+++ b/mm/slub.c	2014-01-28 09:19:27.905212000 -0800
@@ -1559,7 +1559,7 @@ static inline void *acquire_slab(struct
 		new.freelist = freelist;
 	}
 
-	VM_BUG_ON_PAGE(new.frozen, &new);
+	VM_BUG_ON(new.frozen);
 	new.frozen = 1;
 
 	if (!__cmpxchg_double_slab(s, page,
@@ -1812,7 +1812,7 @@ static void deactivate_slab(struct kmem_
 			set_freepointer(s, freelist, prior);
 			new.counters = counters;
 			new.inuse--;
-			VM_BUG_ON_PAGE(!new.frozen, &new);
+			VM_BUG_ON(!new.frozen);
 
 		} while (!__cmpxchg_double_slab(s, page,
 			prior, counters,
@@ -1840,7 +1840,7 @@ redo:
 
 	old.freelist = page->freelist;
 	old.counters = page->counters;
-	VM_BUG_ON_PAGE(!old.frozen, &old);
+	VM_BUG_ON(!old.frozen);
 
 	/* Determine target state of the slab */
 	new.counters = old.counters;
@@ -1952,7 +1952,7 @@ static void unfreeze_partials(struct kme
 
 			old.freelist = page->freelist;
 			old.counters = page->counters;
-			VM_BUG_ON_PAGE(!old.frozen, &old);
+			VM_BUG_ON(!old.frozen);
 
 			new.counters = old.counters;
 			new.freelist = old.freelist;
@@ -2225,7 +2225,7 @@ static inline void *get_freelist(struct
 		counters = page->counters;
 
 		new.counters = counters;
-		VM_BUG_ON_PAGE(!new.frozen, &new);
+		VM_BUG_ON(!new.frozen);
 
 		new.inuse = page->objects;
 		new.frozen = freelist != NULL;
@@ -2319,7 +2319,7 @@ load_freelist:
 	 * page is pointing to the page from which the objects are obtained.
 	 * That page must be frozen for per cpu allocations to work.
 	 */
-	VM_BUG_ON_PAGE(!c->page->frozen, c->page);
+	VM_BUG_ON(!c->page->frozen);
 	c->freelist = get_freepointer(s, freelist);
 	c->tid = next_tid(c->tid);
 	local_irq_restore(flags);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
