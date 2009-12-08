Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 89207600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:17:33 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [7/31] HWPOISON: Turn ref argument into flags argument
Message-Id: <20091208211623.55D1FB151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:23 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Now that "ref" is just a boolean turn it into
a flags argument. First step is only a single flag
that makes the code's intention more clear, but more
may follow.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 include/linux/mm.h  |    5 ++++-
 mm/madvise.c        |    2 +-
 mm/memory-failure.c |    5 +++--
 3 files changed, 8 insertions(+), 4 deletions(-)

Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h
+++ linux/include/linux/mm.h
@@ -1316,8 +1316,11 @@ extern int account_locked_memory(struct
 				 size_t size);
 extern void refund_locked_memory(struct mm_struct *mm, size_t size);
 
+enum mf_flags {
+	MF_COUNT_INCREASED = 1 << 0,
+};
 extern void memory_failure(unsigned long pfn, int trapno);
-extern int __memory_failure(unsigned long pfn, int trapno, int ref);
+extern int __memory_failure(unsigned long pfn, int trapno, int flags);
 extern int sysctl_memory_failure_early_kill;
 extern int sysctl_memory_failure_recovery;
 extern void shake_page(struct page *p);
Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c
+++ linux/mm/memory-failure.c
@@ -739,7 +739,7 @@ static void hwpoison_user_mappings(struc
 		      ret != SWAP_SUCCESS, pfn);
 }
 
-int __memory_failure(unsigned long pfn, int trapno, int ref)
+int __memory_failure(unsigned long pfn, int trapno, int flags)
 {
 	unsigned long lru_flag;
 	struct page_state *ps;
@@ -775,7 +775,8 @@ int __memory_failure(unsigned long pfn,
 	 * In fact it's dangerous to directly bump up page count from 0,
 	 * that may make page_freeze_refs()/page_unfreeze_refs() mismatch.
 	 */
-	if (!ref && !get_page_unless_zero(compound_head(p))) {
+	if (!(flags & MF_COUNT_INCREASED) &&
+		!get_page_unless_zero(compound_head(p))) {
 		action_result(pfn, "free or high order kernel", IGNORED);
 		return PageBuddy(compound_head(p)) ? 0 : -EBUSY;
 	}
Index: linux/mm/madvise.c
===================================================================
--- linux.orig/mm/madvise.c
+++ linux/mm/madvise.c
@@ -237,7 +237,7 @@ static int madvise_hwpoison(unsigned lon
 		printk(KERN_INFO "Injecting memory failure for page %lx at %lx\n",
 		       page_to_pfn(p), start);
 		/* Ignore return value for now */
-		__memory_failure(page_to_pfn(p), 0, 1);
+		__memory_failure(page_to_pfn(p), 0, MF_COUNT_INCREASED);
 	}
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
