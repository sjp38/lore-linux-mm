Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f47.google.com (mail-lf0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id B7DEE6B0256
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 04:45:49 -0500 (EST)
Received: by mail-lf0-f47.google.com with SMTP id c192so23256301lfe.2
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 01:45:49 -0800 (PST)
Received: from mail-lb0-x232.google.com (mail-lb0-x232.google.com. [2a00:1450:4010:c04::232])
        by mx.google.com with ESMTPS id a5si5164043lbs.150.2016.01.28.01.45.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 01:45:48 -0800 (PST)
Received: by mail-lb0-x232.google.com with SMTP id cl12so20254430lbc.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 01:45:48 -0800 (PST)
Subject: [PATCH] mm: polish virtual memory accounting
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Thu, 28 Jan 2016 12:45:44 +0300
Message-ID: <145397434479.24456.7330581149702545550.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sudip Mukherjee <sudipm.mukherjee@gmail.com>

* add VM_STACK as alias for VM_GROWSUP/DOWN depending on architecture
* always account VMAs with flag VM_STACK as stack (as it was before)
* cleanup classifying helpers
* update comments and documentation

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 Documentation/filesystems/proc.txt |    4 ++--
 include/linux/mm.h                 |    6 ++++--
 include/linux/mm_types.h           |    6 +++---
 mm/internal.h                      |   23 +++++++++++++++++++----
 4 files changed, 28 insertions(+), 11 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index fde9fd06fa98..6a4da2a6d8c9 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -240,8 +240,8 @@ Table 1-2: Contents of the status files (as of 4.1)
  RssFile                     size of resident file mappings
  RssShmem                    size of resident shmem memory (includes SysV shm,
                              mapping of tmpfs and shared anonymous mappings)
- VmData                      size of data, stack, and text segments
- VmStk                       size of data, stack, and text segments
+ VmData                      size of private data segments
+ VmStk                       size of stack segments
  VmExe                       size of text segment
  VmLib                       size of shared library code
  VmPTE                       size of page table entries
diff --git a/include/linux/mm.h b/include/linux/mm.h
index f1cd22f2df1a..62fc828c7ec7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -201,11 +201,13 @@ extern unsigned int kobjsize(const void *objp);
 #endif
 
 #ifdef CONFIG_STACK_GROWSUP
-#define VM_STACK_FLAGS	(VM_GROWSUP | VM_STACK_DEFAULT_FLAGS | VM_ACCOUNT)
+#define VM_STACK	VM_GROWSUP
 #else
-#define VM_STACK_FLAGS	(VM_GROWSDOWN | VM_STACK_DEFAULT_FLAGS | VM_ACCOUNT)
+#define VM_STACK	VM_GROWSDOWN
 #endif
 
+#define VM_STACK_FLAGS	(VM_STACK | VM_STACK_DEFAULT_FLAGS | VM_ACCOUNT)
+
 /*
  * Special vmas that are non-mergable, non-mlock()able.
  * Note: mm/huge_memory.c VM_NO_THP depends on this definition.
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index d3ebb9d21a53..624b78b848b8 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -424,9 +424,9 @@ struct mm_struct {
 	unsigned long total_vm;		/* Total pages mapped */
 	unsigned long locked_vm;	/* Pages that have PG_mlocked set */
 	unsigned long pinned_vm;	/* Refcount permanently increased */
-	unsigned long data_vm;		/* VM_WRITE & ~VM_SHARED/GROWSDOWN */
-	unsigned long exec_vm;		/* VM_EXEC & ~VM_WRITE */
-	unsigned long stack_vm;		/* VM_GROWSUP/DOWN */
+	unsigned long data_vm;		/* VM_WRITE & ~VM_SHARED & ~VM_STACK */
+	unsigned long exec_vm;		/* VM_EXEC & ~VM_WRITE & ~VM_STACK */
+	unsigned long stack_vm;		/* VM_STACK */
 	unsigned long def_flags;
 	unsigned long start_code, end_code, start_data, end_data;
 	unsigned long start_brk, brk, start_stack;
diff --git a/mm/internal.h b/mm/internal.h
index 6e976302ddd8..a38a21ebddb4 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -216,20 +216,35 @@ static inline bool is_cow_mapping(vm_flags_t flags)
 	return (flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
 }
 
+/*
+ * These three helpers classifies VMAs for virtual memory accounting.
+ */
+
+/*
+ * Executable code area - executable, not writable, not stack
+ */
 static inline bool is_exec_mapping(vm_flags_t flags)
 {
-	return (flags & (VM_EXEC | VM_WRITE)) == VM_EXEC;
+	return (flags & (VM_EXEC | VM_WRITE | VM_STACK)) == VM_EXEC;
 }
 
+/*
+ * Stack area - atomatically grows in one direction
+ *
+ * VM_GROWSUP / VM_GROWSDOWN VMAs are always private anonymous:
+ * do_mmap() forbids all other combinations.
+ */
 static inline bool is_stack_mapping(vm_flags_t flags)
 {
-	return (flags & (VM_STACK_FLAGS & (VM_GROWSUP | VM_GROWSDOWN))) != 0;
+	return (flags & VM_STACK) == VM_STACK;
 }
 
+/*
+ * Data area - private, writable, not stack
+ */
 static inline bool is_data_mapping(vm_flags_t flags)
 {
-	return (flags & ((VM_STACK_FLAGS & (VM_GROWSUP | VM_GROWSDOWN)) |
-					VM_WRITE | VM_SHARED)) == VM_WRITE;
+	return (flags & (VM_WRITE | VM_SHARED | VM_STACK)) == VM_WRITE;
 }
 
 /* mm/util.c */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
