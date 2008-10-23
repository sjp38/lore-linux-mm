Message-ID: <49010D41.1080305@goop.org>
Date: Thu, 23 Oct 2008 16:48:17 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: vm_unmap_aliases and Xen
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I've been having a few problems with Xen, I suspect as a result of the 
lazy unmapping in vmalloc.c.

One immediate one is that vm_unmap_aliases() will oops if you call it 
before vmalloc_init() is called, which can happen in the Xen case.  RFC 
patch below.

But the bigger problem I'm seeing is that despite calling 
vm_unmap_aliases() at the pertinent places, I'm still seeing errors 
resulting from stray aliases.  Is it possible that vm_unmap_aliases() 
could be missing some, or not completely synchronous?

Subject: vmap: cope with vm_unmap_aliases before vmalloc_init()

Xen can end up calling vm_unmap_aliases() before vmalloc_init() has
been called.  In this case its safe to make it a simple no-op.

Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
diff -r 42c8b29f7ccf mm/vmalloc.c
--- a/mm/vmalloc.c	Wed Oct 22 12:43:39 2008 -0700
+++ b/mm/vmalloc.c	Wed Oct 22 21:39:00 2008 -0700
@@ -591,6 +591,8 @@
 
 #define VMAP_BLOCK_SIZE		(VMAP_BBMAP_BITS * PAGE_SIZE)
 
+static bool vmap_initialized = false;
+
 struct vmap_block_queue {
 	spinlock_t lock;
 	struct list_head free;
@@ -827,6 +829,9 @@
 	int cpu;
 	int flush = 0;
 
+	if (!vmap_initialized)
+		return;
+
 	for_each_possible_cpu(cpu) {
 		struct vmap_block_queue *vbq = &per_cpu(vmap_block_queue, cpu);
 		struct vmap_block *vb;
@@ -940,6 +945,8 @@
 		INIT_LIST_HEAD(&vbq->dirty);
 		vbq->nr_dirty = 0;
 	}
+
+	vmap_initialized = true;
 }
 
 void unmap_kernel_range(unsigned long addr, unsigned long size)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
