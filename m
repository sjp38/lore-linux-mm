Date: Tue, 13 May 2003 13:53:26 -0700
From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: [RFC][PATCH] vm_operation to avoid pagefault/inval race
Message-ID: <20030513135326.D2929@us.ibm.com>
Reply-To: paulmck@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@digeo.com
Cc: mjbligh@us.ibm.com
List-ID: <linux-mm.kvack.org>

This patch adds a vm_operations_struct function pointer that allows
networked and distributed filesystems to avoid a race between a
pagefault on an mmap and an invalidation request from some other
node.  The race goes as follows:

1.	A user process on node A accesses a portion of a mapped
	file, resulting in a page fault.  The pagefault handler
	invokes the corresponding nopage function, which reads
	the page into memory.

2.	A user process on node B writes to the same portion of
	the file (either via mmap or write()), therefore sending
	node A an invalidation request to node A.

3.	Node A receives this invalidate request, and dutifully
	invalidates all mmaps.  Except for the one that has
	not yet been fully mapped by step 1.

4.	Node A then executes the rest of do_no_page(), entering
	the now-invalid page into the PTEs.

5.	One way or another, life is now hard.

One solution would be for the distributed filesystem to hold
onto a lock or semaphore upon return from the nopage function.
The problem is that there is no way to determine (in a timely
fashion) when it safe to release this lock or semaphore.

The attached patch addresses this by adding a nopagedone
function for when do_no_page() exits.  The filesystem may then
drop the lock or semaphore in this nopagedone function.

Thoughts?  Is there some other existing way to get this done?

					Thanx, Paul


diff -urN -X dontdiff linux-2.5.69/include/linux/mm.h linux-2.5.69.stmmap/include/linux/mm.h
--- linux-2.5.69/include/linux/mm.h	Sun May  4 16:53:00 2003
+++ linux-2.5.69.stmmap/include/linux/mm.h	Fri May  9 09:30:37 2003
@@ -134,6 +134,7 @@
 	void (*open)(struct vm_area_struct * area);
 	void (*close)(struct vm_area_struct * area);
 	struct page * (*nopage)(struct vm_area_struct * area, unsigned long address, int unused);
+	void (*nopagedone)(struct vm_area_struct * area, unsigned long address, int status);
 	int (*populate)(struct vm_area_struct * area, unsigned long address, unsigned long len, pgprot_t prot, unsigned long pgoff, int nonblock);
 };
 
diff -urN -X dontdiff linux-2.5.69/mm/memory.c linux-2.5.69.stmmap/mm/memory.c
--- linux-2.5.69/mm/memory.c	Sun May  4 16:53:14 2003
+++ linux-2.5.69.stmmap/mm/memory.c	Fri May  9 17:04:09 2003
@@ -1426,6 +1487,9 @@
 	ret = VM_FAULT_OOM;
 out:
 	pte_chain_free(pte_chain);
+	if (vma->vm_ops && vma->vm_ops->nopagedone) {
+		vma->vm_ops->nopagedone(vma, address & PAGE_MASK, ret);
+	}
 	return ret;
 }
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
