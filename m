Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1779A6B0047
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 15:40:47 -0400 (EDT)
Message-Id: <20100831193924.317733624@chello.nl>
Date: Tue, 31 Aug 2010 21:26:22 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 5/5] mm: highmem documentation
References: <20100831192617.441439071@chello.nl>
Content-Disposition: inline; filename=kmap-doc.patch
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Russell King <rmk@arm.linux.org.uk>, David Howells <dhowells@redhat.com>, Ralf Baechle <ralf@linux-mips.org>, David Miller <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

David asked if I could make a start at documenting some of the highmem issues.

Requested-by: David Howells <dhowells@redhat.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 Documentation/vm/highmem.txt |   99 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 99 insertions(+)

Index: linux-2.6/Documentation/vm/highmem.txt
===================================================================
--- /dev/null
+++ linux-2.6/Documentation/vm/highmem.txt
@@ -0,0 +1,99 @@
+
+ - What is highmem?
+
+Highmem comes about when the physical memory size approaches the virtual
+memory size. At that point it is impossible for the kernel to keep all of
+physical memory mapped. This means the kernel needs to start managing
+temporary maps of pieces of physical memory it wants to access.
+
+The part of (physical) memory not covered by a permanent map is what we
+call highmem. There's various architecture dependent constraints on where
+exactly that border lies.
+
+On i386 for example we chose to map the kernel into every process so as not
+to have to pay the full TLB invalidation costs for kernel entry/exit. This
+means the virtual memory space (of 32bits, 4G) will have to be divided
+between user and kernel space.
+
+The traditional split for architectures using this approach is 3:1, 3G for
+userspace and the top 1G for kernel space. This means that we can at most
+map 1G of physical memory at any one time, but because we need (virtual)
+space for other things; including these temporary maps to access the rest
+of physical memory; the actual direct map will typically be less (usually
+around ~896M).
+
+Other architectures that have mm context tagged TLBs can have a separate
+kernel and user maps -- however some hardware (like some ARMs) have limited
+virtual space when they use mm context tags.
+
+ - So what about these temporary maps?
+
+The kernel contains several ways of creating temporary maps:
+
+ * vmap        -- useful for mapping multiple pages into a contiguous
+                  virtual space; needs global synchronization to unmap.
+
+ * kmap        -- useful for mapping a single page; needs global
+		  synchronization, but is amortized somewhat. Is also
+		  prone to deadlocks when using in a nested fashion.
+                  [not recommended for new code]
+
+ * kmap_atomic -- useful for mapping a single page; cpu local invalidate
+                  makes it perform well, however since you need to stay
+                  on the cpu it requires atomicity (not allowed to sleep)
+                  which also allows for usage in interrupt contexts.
+
+
+
+ - Right, so about this kmap_atomic, when/how do I use it?
+
+Both are straight forward, you use it when you want to access the contents
+of a page that might be allocated from highmem (see __GFP_HIGHMEM), say a
+page-cache page:
+
+	struct page *page = find_get_page(mapping, offset);
+	void *vaddr = kmap_atomic(page);
+
+	memset(vaddr, 0, PAGE_SIZE);
+
+	kunmap_atomic(vaddr);
+
+Note that the kunmap_atomic() call takes the result of the kmap_atomic()
+call not the argument.
+
+If you need to map two pages because you want to copy from one page to
+another you need to keep the kmap_atomic calls strictly nested, like:
+
+	vaddr1 = kmap_atomic(page1);
+	vaddr2 = kmap_atomic(page2);
+
+	memcpy(vaddr1, vaddr2, PAGE_SIZE);
+
+	kunmap_atomic(vaddr2);
+	kunmap_atomic(vaddr1);
+
+
+
+ - So all this temporary mapping stuff, isn't that expensive?
+
+Yes, it is, get a 64bit machine.
+
+
+
+ - Seriously, so I can stick 64G in my i386-PAE machine, sweet!
+
+Well, yes you can, but Linux won't make you happy. Linux needs a page-frame
+structure for each page in the system and the pageframes need to live in
+the permanent map. That means that you can have 896M/sizeof(struct page)
+page-frames at most; with struct page being 32-bytes that would end up
+being something in the order of 112G worth of pages, however the kernel
+needs to store more than just page-frames in that memory.
+
+The general recommendation is that you don't use more than 8G on a 32-bit
+machine, although more might work for you and your workload you're pretty
+much on your own -- don't expect kernel developers to really care much if
+things come apart.
+
+Also, PAE makes your page-tables larger, which means slowdowns due to more
+data to traverse in TLB fills and the like. The advantage is that PAE has
+more PTE bits and can provide advanced features like NX and PAT.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
