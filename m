Date: Tue, 25 May 2004 05:43:26 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] ppc64: Fix possible race with set_pte on a present PTE
Message-ID: <20040525034326.GT29378@dualathlon.random>
References: <1085369393.15315.28.camel@gaston> <Pine.LNX.4.58.0405232046210.25502@ppc970.osdl.org> <1085371988.15281.38.camel@gaston> <Pine.LNX.4.58.0405232134480.25502@ppc970.osdl.org> <1085373839.14969.42.camel@gaston> <Pine.LNX.4.58.0405232149380.25502@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0405232149380.25502@ppc970.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 23, 2004 at 10:10:16PM -0700, Linus Torvalds wrote:
> what you found is actually a (really really) unlikely race condition that
> can have serious consequences.

agreed, it could in theory lose the dirty bit.

> course, back then SMP wasn't an issue, and this seems to have survived all 
> the SMP fixes.

looks like to trigger this two threads needs to page fault on the same
not-present MAP_SHARED page at the same time and the second thread must be a
read-fault. The first thread will establish the pte writeable and
dirty, then the first thread releases the page_table_lock, then the VM
takes the page_table_lock (from kswapd or similar) then the VM transfers
the dirty bit from pte to page and it even starts the and completes the
I/O before the the read-fault has a chance to execute. Then after the
I/O is completed the second thread finally takes the page_table_lock and
reads the pte. Then the first thread writes to the page from userspace
marking the pte dirty , and finally the second thread completes the
page_fault running pte_establish and losing the dirty bit on the page.

Maybe it can trigger even without I/O in between, not sure, certainly it
can happen in the above scenario, but the I/O window is quite huge for
not being able to take a spinlock before the I/O is started.

The below patch should fix it, the only problem is that it can screwup
some arch that might use page-faults to keep track of the accessed bit,
I think for istance ia64 might do that, not sure if it's using it in
linux though. anyways the below should be the optimal fix for x86 and
x86-64 at least and the other archs will not corrupt memory anymore too
(at worst they will live lock in userspace, and the livelock should be
solvable gracefully with sigkill since it's an userspace one).

warning, patch is absolutely untested.

Index: mm/memory.c
===================================================================
RCS file: /home/andrea/crypto/cvs/linux-2.5/mm/memory.c,v
retrieving revision 1.154
diff -u -p -r1.154 memory.c
--- mm/memory.c	20 Apr 2004 14:22:03 -0000	1.154
+++ mm/memory.c	25 May 2004 03:04:48 -0000
@@ -1665,10 +1665,30 @@ static inline int handle_pte_fault(struc
 			return do_wp_page(mm, vma, address, pte, pmd, entry);
 
 		entry = pte_mkdirty(entry);
+
+		/*
+		 * We can overwrite the pte not atomically only if this is a
+		 * write fault or we can lose the dirty bit. The dirty and the
+		 * accessed bit are the only two things that can change form
+		 * under us even if we hold the page_table_lock, they're
+		 * set by hardware while other threads runs in userspace.
+		 *
+		 * This could cause an infinite loop with a read-fault if some
+		 * arch tries to keep track of the accessed bit with a kernel
+		 * page fault (but keeping track of the accessed bit with
+		 * kernel exceptions sounds very inefficient anyways).
+		 * If some arch infinite loops, they will have to implement
+		 * some sort of atomic ptep_stablish where they atomically
+		 * compare and swap, then we'll change the common code here
+		 * to learn how to atomic swap the pte.
+		 *
+		 * x86 and x86-64 are sure optimal without atomic ops here and
+		 * with this simple code.
+		 */
+		entry = pte_mkyoung(entry);
+		ptep_establish(vma, address, pte, entry);
+		update_mmu_cache(vma, address, entry);
 	}
-	entry = pte_mkyoung(entry);
-	ptep_establish(vma, address, pte, entry);
-	update_mmu_cache(vma, address, entry);
 	pte_unmap(pte);
 	spin_unlock(&mm->page_table_lock);
 	return VM_FAULT_MINOR;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
