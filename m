Date: Thu, 5 Oct 2006 16:06:34 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: NOPAGE_RETRY and 2.6.19
Message-Id: <20061005160634.5932ba78.akpm@osdl.org>
In-Reply-To: <1160088050.22232.90.camel@localhost.localdomain>
References: <1160088050.22232.90.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 06 Oct 2006 08:40:50 +1000
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> Any chance that can be merged in 2.6.19 ?

Not if you don't show it to anyone ;)

I renamed your NOPAGE_RETRY to NOPAGE_REFAULT.  Because I think that
better communicates the fact that it returns all the way to userspace to
redo the fault.  Later, a NOPAGE_RETRY would be a lower-level thing which
doesn't redo the fault.


From: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Add a way for a no_page() handler to request a retry of the faulting
instruction.  It goes back to userland on page faults and just tries again
in get_user_pages().  I added a cond_resched() in the loop in that later
case.

The problem I have with signal and spufs is an actual bug affecting apps and I
don't see other ways of fixing it.  

In addition, we are having issues with infiniband and 64k pages (related to
the way the hypervisor deals with some HV cards) that will require us to muck
around with the MMU from within the IB driver's no_page() (it's a pSeries
specific driver) and return to the caller the same way using NOPAGE_REFAULT.  

And to add to this, the graphics folks have been following a new approach of
memory management that involves transparently swapping objects between video
ram and main meory.  To do that, they need installing PTEs from a no_page()
handler as well and that also requires returning with NOPAGE_REFAULT.

(For the later, they are currently using io_remap_pfn_range to install one PTE
from no_page() which is a bit racy, we need to add a check for the PTE having
already been installed afer taking the lock, but that's ok, they are only at
the proof-of-concept stage.  I'll send a patch adding a "clean" function to do
that, we can use that from spufs too and get rid of the sparsemem hacks we do
to create struct page for SPEs.  Basically, that provides a generic solution
for being able to have no_page() map hardware devices, which is something that
I think sound driver folks have been asking for some time too).

All of these things depend on having the NOPAGE_REFAULT exit path from
no_page() handlers.

Signed-off-by: Benjamin Herrenchmidt <benh@kernel.crashing.org>
Cc: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 include/linux/mm.h |    1 +
 mm/memory.c        |    9 ++++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff -puN include/linux/mm.h~page-fault-retry-with-nopage_retry include/linux/mm.h
--- a/include/linux/mm.h~page-fault-retry-with-nopage_retry
+++ a/include/linux/mm.h
@@ -593,6 +593,7 @@ static inline int page_mapped(struct pag
  */
 #define NOPAGE_SIGBUS	(NULL)
 #define NOPAGE_OOM	((struct page *) (-1))
+#define NOPAGE_REFAULT	((struct page *) (-2))	/* Return to userspace, rerun */
 
 /*
  * Error return values for the *_nopfn functions
diff -puN mm/memory.c~page-fault-retry-with-nopage_retry mm/memory.c
--- a/mm/memory.c~page-fault-retry-with-nopage_retry
+++ a/mm/memory.c
@@ -1086,6 +1086,7 @@ int get_user_pages(struct task_struct *t
 				default:
 					BUG();
 				}
+				cond_resched();
 			}
 			if (pages) {
 				pages[i] = page;
@@ -2169,11 +2170,13 @@ retry:
 	 * after the next truncate_count read.
 	 */
 
-	/* no page was available -- either SIGBUS or OOM */
-	if (new_page == NOPAGE_SIGBUS)
+	/* no page was available -- either SIGBUS, OOM or REFAULT */
+	if (unlikely(new_page == NOPAGE_SIGBUS))
 		return VM_FAULT_SIGBUS;
-	if (new_page == NOPAGE_OOM)
+	else if (unlikely(new_page == NOPAGE_OOM))
 		return VM_FAULT_OOM;
+	else if (unlikely(new_page == NOPAGE_REFAULT))
+		return VM_FAULT_MINOR;
 
 	/*
 	 * Should we do an early C-O-W break?
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
