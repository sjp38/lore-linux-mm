Date: Mon, 18 Aug 2008 08:03:01 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: xip/ext2 fix block allocation race
Message-ID: <20080818060301.GC3011@wotan.suse.de>
References: <20080818053821.GA3011@wotan.suse.de> <20080818054409.GB3011@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080818054409.GB3011@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, cotte@de.ibm.com, borntraeger@de.ibm.com, Jared Hulbert <jaredeh@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

XIP can call into get_xip_mem concurrently with the same file,offset with
create=1.  This usually maps down to get_block, which expects the page lock
to prevent such a situation. This causes ext2 to explode for one reason or
another.

Serialise those calls for the moment. For common usages today, I suspect
get_xip_mem rarely is called to create new blocks. In future as XIP
technologies evolve we might need to look at which operations require
scalability, and rework the locking to suit.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/filemap_xip.c
===================================================================
--- linux-2.6.orig/mm/filemap_xip.c	2008-08-18 14:47:38.000000000 +1000
+++ linux-2.6/mm/filemap_xip.c	2008-08-18 14:53:11.000000000 +1000
@@ -248,15 +248,16 @@ again:
 		int err;
 
 		/* maybe shared writable, allocate new block */
+		mutex_lock(&xip_sparse_mutex);
 		error = mapping->a_ops->get_xip_mem(mapping, vmf->pgoff, 1,
 							&xip_mem, &xip_pfn);
+		mutex_unlock(&xip_sparse_mutex);
 		if (error)
 			return VM_FAULT_SIGBUS;
 		/* unmap sparse mappings at pgoff from all other vmas */
 		__xip_unmap(mapping, vmf->pgoff);
 
 found:
-		printk("%s insert %lx@%lx\n", current->comm, (unsigned long)vmf->virtual_address, xip_pfn);
 		err = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address,
 							xip_pfn);
 		if (err == -ENOMEM)
@@ -340,8 +341,10 @@ __xip_file_write(struct file *filp, cons
 						&xip_mem, &xip_pfn);
 		if (status == -ENODATA) {
 			/* we allocate a new page unmap it */
+			mutex_lock(&xip_sparse_mutex);
 			status = a_ops->get_xip_mem(mapping, index, 1,
 							&xip_mem, &xip_pfn);
+			mutex_unlock(&xip_sparse_mutex);
 			if (!status)
 				/* unmap page at pgoff from all other vmas */
 				__xip_unmap(mapping, index);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
