Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7755F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 11:10:05 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <20090407509.382219156@firstfloor.org>
In-Reply-To: <20090407509.382219156@firstfloor.org>
Subject: [PATCH] [7/16] POISON: Add basic support for poisoned pages in fault handler
Message-Id: <20090407151004.2F5D21D0470@basil.firstfloor.org>
Date: Tue,  7 Apr 2009 17:10:04 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>


- Add a new VM_FAULT_POISON error code to handle_mm_fault. Right now
architectures have to explicitely enable poison page support, so
this is forward compatible to all architectures. They only need
to add it when they enable poison page support.
- Add poison page handling in swap in fault code

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 include/linux/mm.h |    3 ++-
 mm/memory.c        |   17 ++++++++++++++---
 2 files changed, 16 insertions(+), 4 deletions(-)

Index: linux/mm/memory.c
===================================================================
--- linux.orig/mm/memory.c	2009-04-07 16:39:24.000000000 +0200
+++ linux/mm/memory.c	2009-04-07 16:43:06.000000000 +0200
@@ -1315,7 +1315,8 @@
 				if (ret & VM_FAULT_ERROR) {
 					if (ret & VM_FAULT_OOM)
 						return i ? i : -ENOMEM;
-					else if (ret & VM_FAULT_SIGBUS)
+					if (ret &
+					    (VM_FAULT_POISON|VM_FAULT_SIGBUS))
 						return i ? i : -EFAULT;
 					BUG();
 				}
@@ -2426,8 +2427,15 @@
 		goto out;
 
 	entry = pte_to_swp_entry(orig_pte);
-	if (is_migration_entry(entry)) {
-		migration_entry_wait(mm, pmd, address);
+	if (unlikely(non_swap_entry(entry))) {
+		if (is_migration_entry(entry)) {
+			migration_entry_wait(mm, pmd, address);
+		} else if (is_poison_entry(entry)) {
+			ret = VM_FAULT_POISON;
+		} else {
+			print_bad_pte(vma, address, pte, NULL);
+			ret = VM_FAULT_OOM;
+		}
 		goto out;
 	}
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
@@ -2451,6 +2459,9 @@
 		/* Had to read the page from swap area: Major fault */
 		ret = VM_FAULT_MAJOR;
 		count_vm_event(PGMAJFAULT);
+	} else if (PagePoison(page)) {
+		ret = VM_FAULT_POISON;
+		goto out;
 	}
 
 	lock_page(page);
Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h	2009-04-07 16:39:24.000000000 +0200
+++ linux/include/linux/mm.h	2009-04-07 16:43:05.000000000 +0200
@@ -702,11 +702,12 @@
 #define VM_FAULT_SIGBUS	0x0002
 #define VM_FAULT_MAJOR	0x0004
 #define VM_FAULT_WRITE	0x0008	/* Special case for get_user_pages */
+#define VM_FAULT_POISON 0x0010	/* Hit poisoned page */
 
 #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
 
-#define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS)
+#define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_POISON)
 
 /*
  * Can be called by the pagefault handler when it gets a VM_FAULT_OOM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
