Date: Fri, 30 May 2003 16:34:15 -0700
From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: [PATCH] vm_operation to avoid pagefault/inval race
Message-ID: <20030530163415.A26729@us.ibm.com>
Reply-To: paulmck@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@digeo.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

Rediffed to 2.5.70-mm2.

This patch provides one way for a distributed filesystem to avoid
the pagefault/cross-node-invalidation race described in:

	http://marc.theaimsgroup.com/?l=linux-kernel&m=105286345316249&w=2

The advantage of this patch is that it is quite small and quite well
tested.  A different approach follows in a separate message.

						Thanx, Paul

diff -urN -X dontdiff linux-2.5.70-mm2/include/linux/mm.h linux-2.5.70-mm2.nopagedone/include/linux/mm.h
--- linux-2.5.70-mm2/include/linux/mm.h	Fri May 30 14:51:05 2003
+++ linux-2.5.70-mm2.nopagedone/include/linux/mm.h	Fri May 30 15:11:24 2003
@@ -143,6 +143,7 @@
 	void (*open)(struct vm_area_struct * area);
 	void (*close)(struct vm_area_struct * area);
 	struct page * (*nopage)(struct vm_area_struct * area, unsigned long address, int unused);
+	void (*nopagedone)(struct vm_area_struct * area, unsigned long address, int status);
 	int (*populate)(struct vm_area_struct * area, unsigned long address, unsigned long len, pgprot_t prot, unsigned long pgoff, int nonblock);
 };
 
diff -urN -X dontdiff linux-2.5.70-mm2/mm/memory.c linux-2.5.70-mm2.nopagedone/mm/memory.c
--- linux-2.5.70-mm2/mm/memory.c	Fri May 30 14:51:06 2003
+++ linux-2.5.70-mm2.nopagedone/mm/memory.c	Fri May 30 15:11:24 2003
@@ -1468,6 +1468,9 @@
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
