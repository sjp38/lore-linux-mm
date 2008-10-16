Date: Thu, 16 Oct 2008 06:10:33 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: fix anon_vma races
Message-ID: <20081016041033.GB10371@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

Still would like independent confirmation of these problems and the fix, but
it still looks buggy to me...

---

There are some races in the anon_vma code.

The race comes about because adding our vma to the tail of anon_vma->head comes
after the assignment of vma->anon_vma to a new anon_vma pointer. In the case
where this is a new anon_vma, this is done without holding any locks.  So a
parallel anon_vma_prepare might see the vma already has an anon_vma, so it
won't serialise on the page_table_lock. It may proceed and the anon_vma to a
page in the page fault path. Another thread may then pick up the page from the
LRU list, find its mapcount incremented, and attempt to iterate over the
anon_vma's list concurrently with the first thread (because the first one is
not holding the anon_vma lock). This is a fairly subtle race, and only likely
to be hit in kernels where the spinlock is preemptible and the first thread is
preempted at the right time... but OTOH it is _possible_ to hit here; on bigger
SMP systems cacheline transfer latencies could be very large, or we could take
an NMI inside the lock or something. Fix this by initialising the list before
adding the anon_vma to vma.

After that, there is a similar data-race with memory ordering where the store
to make the anon_vma visible passes previous stores to initialize the anon_vma.
This race also includes stores to initialize the anon_vma spinlock by the
slab constructor. Add and comment appropriate barriers to solve this.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -81,8 +81,15 @@ int anon_vma_prepare(struct vm_area_stru
 		/* page_table_lock to protect against threads */
 		spin_lock(&mm->page_table_lock);
 		if (likely(!vma->anon_vma)) {
-			vma->anon_vma = anon_vma;
 			list_add_tail(&vma->anon_vma_node, &anon_vma->head);
+			/*
+			 * This smp_wmb() is required to order all previous
+			 * stores to initialize the anon_vma (by the slab
+			 * ctor) and add this vma, with the store to make it
+			 * visible to other CPUs via vma->anon_vma.
+			 */
+			smp_wmb();
+			vma->anon_vma = anon_vma;
 			allocated = NULL;
 		}
 		spin_unlock(&mm->page_table_lock);
@@ -91,6 +98,15 @@ int anon_vma_prepare(struct vm_area_stru
 			spin_unlock(&locked->lock);
 		if (unlikely(allocated))
 			anon_vma_free(allocated);
+	} else {
+		/*
+		 * This smp_read_barrier_depends is required to order the data
+		 * dependent loads of fields in anon_vma, with the load of the
+		 * anon_vma pointer vma->anon_vma. This complements the above
+		 * smp_wmb, and prevents a CPU from loading uninitialized
+		 * contents of anon_vma.
+		 */
+		smp_read_barrier_depends();
 	}
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
