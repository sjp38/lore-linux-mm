Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f53.google.com (mail-lf0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5EFDC6B0009
	for <linux-mm@kvack.org>; Sat, 23 Jan 2016 15:52:36 -0500 (EST)
Received: by mail-lf0-f53.google.com with SMTP id m198so65359352lfm.0
        for <linux-mm@kvack.org>; Sat, 23 Jan 2016 12:52:36 -0800 (PST)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id p2si5905635lfb.55.2016.01.23.12.52.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Jan 2016 12:52:34 -0800 (PST)
Received: by mail-lf0-x244.google.com with SMTP id n70so5891778lfn.1
        for <linux-mm@kvack.org>; Sat, 23 Jan 2016 12:52:34 -0800 (PST)
Subject: [PATCH v3] mm: warn about VmData over RLIMIT_DATA
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 23 Jan 2016 23:52:29 +0300
Message-ID: <145358234948.18573.2681359119037889087.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linuxfoundation.org>, linux-kernel@vger.kernel.org
Cc: Vegard Nossum <vegard.nossum@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andy Lutomirski <luto@amacapital.net>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Kees Cook <keescook@google.com>, Willy Tarreau <w@1wt.eu>, Pavel Emelyanov <xemul@virtuozzo.com>

This patch fixes 84638335900f ("mm: rework virtual memory accounting")

Before that commit RLIMIT_DATA have control only over size of the brk region.
But that change have caused problems with all existing versions of valgrind,
because it set RLIMIT_DATA to zero.

This patch fixes rlimit check (limit actually in bytes, not pages)
and by default turns it into warning which prints at first VmData misuse:
"mmap: top (795): VmData 516096 exceed data ulimit 512000. Will be forbidden soon."

Behavior is controlled by boot param ignore_rlimit_data=y/n and by sysfs
/sys/module/kernel/parameters/ignore_rlimit_data. For now it set to "y".

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
Link: http://lkml.kernel.org/r/20151228211015.GL2194@uranus
Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
---
 Documentation/kernel-parameters.txt |    5 +++++
 mm/internal.h                       |   16 ++++++++++++++++
 mm/mmap.c                           |   23 +++++++++++++++++------
 3 files changed, 38 insertions(+), 6 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index cfb2c0f1a4a8..e3507c2e14b0 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1461,6 +1461,11 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			could change it dynamically, usually by
 			/sys/module/printk/parameters/ignore_loglevel.
 
+	ignore_rlimit_data
+			Ignore RLIMIT_DATA setting for data mappings,
+			print warning at first misuse. Could be changed by
+			/sys/module/kernel/parameters/ignore_rlimit_data.
+
 	ihash_entries=	[KNL]
 			Set number of hash buckets for inode cache.
 
diff --git a/mm/internal.h b/mm/internal.h
index ed8b5ffcf9b1..6e976302ddd8 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -216,6 +216,22 @@ static inline bool is_cow_mapping(vm_flags_t flags)
 	return (flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
 }
 
+static inline bool is_exec_mapping(vm_flags_t flags)
+{
+	return (flags & (VM_EXEC | VM_WRITE)) == VM_EXEC;
+}
+
+static inline bool is_stack_mapping(vm_flags_t flags)
+{
+	return (flags & (VM_STACK_FLAGS & (VM_GROWSUP | VM_GROWSDOWN))) != 0;
+}
+
+static inline bool is_data_mapping(vm_flags_t flags)
+{
+	return (flags & ((VM_STACK_FLAGS & (VM_GROWSUP | VM_GROWSDOWN)) |
+					VM_WRITE | VM_SHARED)) == VM_WRITE;
+}
+
 /* mm/util.c */
 void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct vm_area_struct *prev, struct rb_node *rb_parent);
diff --git a/mm/mmap.c b/mm/mmap.c
index 84b12624ceb0..cfc0cdca421e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -42,6 +42,7 @@
 #include <linux/memory.h>
 #include <linux/printk.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/moduleparam.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -69,6 +70,8 @@ const int mmap_rnd_compat_bits_max = CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX;
 int mmap_rnd_compat_bits __read_mostly = CONFIG_ARCH_MMAP_RND_COMPAT_BITS;
 #endif
 
+static bool ignore_rlimit_data = true;
+core_param(ignore_rlimit_data, ignore_rlimit_data, bool, 0644);
 
 static void unmap_region(struct mm_struct *mm,
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
@@ -2982,9 +2985,17 @@ bool may_expand_vm(struct mm_struct *mm, vm_flags_t flags, unsigned long npages)
 	if (mm->total_vm + npages > rlimit(RLIMIT_AS) >> PAGE_SHIFT)
 		return false;
 
-	if ((flags & (VM_WRITE | VM_SHARED | (VM_STACK_FLAGS &
-				(VM_GROWSUP | VM_GROWSDOWN)))) == VM_WRITE)
-		return mm->data_vm + npages <= rlimit(RLIMIT_DATA);
+	if (is_data_mapping(flags) &&
+	    mm->data_vm + npages > rlimit(RLIMIT_DATA) >> PAGE_SHIFT) {
+		if (ignore_rlimit_data)
+			pr_warn_once("%s (%d): VmData %lu exceed data ulimit "
+				     "%lu. Will be forbidden soon.\n",
+				     current->comm, current->pid,
+				     (mm->data_vm + npages) << PAGE_SHIFT,
+				     rlimit(RLIMIT_DATA));
+		else
+			return false;
+	}
 
 	return true;
 }
@@ -2993,11 +3004,11 @@ void vm_stat_account(struct mm_struct *mm, vm_flags_t flags, long npages)
 {
 	mm->total_vm += npages;
 
-	if ((flags & (VM_EXEC | VM_WRITE)) == VM_EXEC)
+	if (is_exec_mapping(flags))
 		mm->exec_vm += npages;
-	else if (flags & (VM_STACK_FLAGS & (VM_GROWSUP | VM_GROWSDOWN)))
+	else if (is_stack_mapping(flags))
 		mm->stack_vm += npages;
-	else if ((flags & (VM_WRITE | VM_SHARED)) == VM_WRITE)
+	else if (is_data_mapping(flags))
 		mm->data_vm += npages;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
