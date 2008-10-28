Message-ID: <4906CBCA.6060908@goop.org>
Date: Tue, 28 Oct 2008 19:22:34 +1100
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: [PATCH 1/2] vmap: cope with vm_unmap_aliases before vmalloc_init()
References: <49010D41.1080305@goop.org> <200810281619.10388.nickpiggin@yahoo.com.au>
In-Reply-To: <200810281619.10388.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Xen can end up calling vm_unmap_aliases() before vmalloc_init() has
been called.  In this case its safe to make it a simple no-op.

Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
---
 mm/vmalloc.c |    7 +++++++
 1 file changed, 7 insertions(+)

===================================================================
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -592,6 +592,8 @@
 
 #define VMAP_BLOCK_SIZE		(VMAP_BBMAP_BITS * PAGE_SIZE)
 
+static bool vmap_initialized __read_mostly = false;
+
 struct vmap_block_queue {
 	spinlock_t lock;
 	struct list_head free;
@@ -828,6 +830,9 @@
 	int cpu;
 	int flush = 0;
 
+	if (unlikely(!vmap_initialized))
+		return;
+
 	for_each_possible_cpu(cpu) {
 		struct vmap_block_queue *vbq = &per_cpu(vmap_block_queue, cpu);
 		struct vmap_block *vb;
@@ -941,6 +946,8 @@
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
