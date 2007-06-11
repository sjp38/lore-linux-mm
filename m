Date: Mon, 11 Jun 2007 17:36:14 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH] pte_update_defer to pte_update 
In-Reply-To: <20070420150920.7d3237c2.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0706111731400.8383@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0703252335560.4535@chino.kir.corp.google.com>
 <46082BE6.30402@vmware.com> <Pine.LNX.4.64.0704131838310.8399@blonde.wat.veritas.com>
 <461FD9BF.90609@vmware.com> <Pine.LNX.4.64.0704132108430.14740@blonde.wat.veritas.com>
 <461FEF1C.5010806@vmware.com> <Pine.LNX.4.64.0704161831500.8213@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0704161139020.12097@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0704161956510.13584@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0704161217310.12685@chino.kir.corp.google.com>
 <4623F3EF.9040406@vmware.com> <20070420150920.7d3237c2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Zachary Amsden <zach@vmware.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It is not safe to use pte_update_defer() in ptep_test_and_clear_young():
its only user, /proc/<pid>/clear_refs, drops pte lock before flushing TLB.
Use the safe though less efficient pte_update() paravirtop in its place.
Likewise in ptep_test_and_clear_dirty(), though that has no current use.

These are macros (header file dependency stops them from becoming inline
functions), so be more liberal with the underscores and parentheses.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
One for 2.6.22.

Sorry, Andrew, you passed this ball to the three of us in private mail on
20 April, but none of us responded.  David liked an earlier patch I made,
which did flush TLB within the pte lock, but only when modifications had
been made; however, I think he overestimated how often that condition
would make a difference, and underestimated the number of TLB flushes
added when at present they're batched into one.  Zach advised against
flushing inside the lock, and was resigned to the immediate pte_update
here.  We don't want the paravirt case to dictate against TLB batching.

 include/asm-i386/pgtable.h |   26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

--- 2.6.22-rc4/include/asm-i386/pgtable.h	2007-05-13 05:41:00.000000000 +0100
+++ linux/include/asm-i386/pgtable.h	2007-06-11 16:14:17.000000000 +0100
@@ -295,22 +295,24 @@ do {									\
 
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
 #define ptep_test_and_clear_dirty(vma, addr, ptep) ({			\
-	int ret = 0;							\
-	if (pte_dirty(*ptep))						\
-		ret = test_and_clear_bit(_PAGE_BIT_DIRTY, &ptep->pte_low); \
-	if (ret)							\
-		pte_update_defer(vma->vm_mm, addr, ptep);		\
-	ret;								\
+	int __ret = 0;							\
+	if (pte_dirty(*(ptep)))						\
+		__ret = test_and_clear_bit(_PAGE_BIT_DIRTY,		\
+						&(ptep)->pte_low);	\
+	if (__ret)							\
+		pte_update((vma)->vm_mm, addr, ptep);			\
+	__ret;								\
 })
 
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
 #define ptep_test_and_clear_young(vma, addr, ptep) ({			\
-	int ret = 0;							\
-	if (pte_young(*ptep))						\
-		ret = test_and_clear_bit(_PAGE_BIT_ACCESSED, &ptep->pte_low); \
-	if (ret)							\
-		pte_update_defer(vma->vm_mm, addr, ptep);		\
-	ret;								\
+	int __ret = 0;							\
+	if (pte_young(*(ptep)))						\
+		__ret = test_and_clear_bit(_PAGE_BIT_ACCESSED,		\
+						&(ptep)->pte_low);	\
+	if (__ret)							\
+		pte_update((vma)->vm_mm, addr, ptep);			\
+	__ret;								\
 })
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
