Date: Sun, 23 Nov 2008 21:55:11 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 1/8] mm: gup persist for write permission
In-Reply-To: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
Message-ID: <Pine.LNX.4.64.0811232154120.4142@blonde.site>
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Robin Holt <holt@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

do_wp_page()'s VM_FAULT_WRITE return value tells __get_user_pages() that
COW has been done if necessary, though it may be leaving the pte without
write permission - for the odd case of forced writing to a readonly vma
for ptrace.  At present GUP then retries the follow_page() without asking
for write permission, to escape an endless loop when forced.

But an application may be relying on GUP to guarantee a writable page
which won't be COWed again when written from userspace, whereas a race
here might leave a readonly pte in place?  Change the VM_FAULT_WRITE
handling to ask follow_page() for write permission again, except in
that odd case of forced writing to a readonly vma.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/memory.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

--- swapfree0/mm/memory.c	2008-11-19 15:26:28.000000000 +0000
+++ swapfree1/mm/memory.c	2008-11-21 18:50:41.000000000 +0000
@@ -1251,9 +1251,15 @@ int __get_user_pages(struct task_struct 
 				 * do_wp_page has broken COW when necessary,
 				 * even if maybe_mkwrite decided not to set
 				 * pte_write. We can thus safely do subsequent
-				 * page lookups as if they were reads.
+				 * page lookups as if they were reads. But only
+				 * do so when looping for pte_write is futile:
+				 * in some cases userspace may also be wanting
+				 * to write to the gotten user page, which a
+				 * read fault here might prevent (a readonly
+				 * page might get reCOWed by userspace write).
 				 */
-				if (ret & VM_FAULT_WRITE)
+				if ((ret & VM_FAULT_WRITE) &&
+				    !(vma->vm_flags & VM_WRITE))
 					foll_flags &= ~FOLL_WRITE;
 
 				cond_resched();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
