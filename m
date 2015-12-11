Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id B837A6B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 15:49:43 -0500 (EST)
Received: by lbblt2 with SMTP id lt2so77619222lbb.3
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 12:49:43 -0800 (PST)
Received: from mail-lf0-x229.google.com (mail-lf0-x229.google.com. [2a00:1450:4010:c07::229])
        by mx.google.com with ESMTPS id zm8si11405203lbb.100.2015.12.11.12.49.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 12:49:42 -0800 (PST)
Received: by lfed137 with SMTP id d137so35767036lfe.3
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 12:49:42 -0800 (PST)
Date: Fri, 11 Dec 2015 23:49:39 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [RFC] mm: Account anon mappings as RLIMIT_DATA
Message-ID: <20151211204939.GA2604@uranus>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Cc: Quentin Casasnovas <quentin.casasnovas@oracle.com>, Vegard Nossum <vegard.nossum@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Willy Tarreau <w@1wt.eu>, Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

When inspecting a vague code inside prctl(PR_SET_MM_MEM)
call (which testing the RLIMIT_DATA value to figure out
if we're allowed to assign new @start_brk, @brk, @start_data,
@end_data from mm_struct) it's been commited that RLIMIT_DATA
in a form it's implemented now doesn't do anything useful
because most of user-space libraries use mmap() syscall
for dynamic memory allocations.

So Linus suggested to convert RLIMIT_DATA rlimit into something
suitable for anonymous memory accounting. Here we introduce
new @anon_vm member into mm descriptor which is updated
every vm_stat_account call. When mmap_region() is called
we test if current RLIMIT_DATA limit is not exceeded.

This should give a way to control the amount of anonymous
memory allocated.

p.s.: This rfc not for application, I would like to
hear if I move in right direction in general. In
particular I need to add hugetlb anon mappings here
as well and update docs and etc.

So comments are highly appreciated.

CC: Quentin Casasnovas <quentin.casasnovas@oracle.com>
CC: Vegard Nossum <vegard.nossum@oracle.com>
CC: Linus Torvalds <torvalds@linux-foundation.org>
CC: Willy Tarreau <w@1wt.eu>
CC: Andy Lutomirski <luto@amacapital.net>
CC: Kees Cook <keescook@google.com>
CC: Vladimir Davydov <vdavydov@virtuozzo.com>
CC: Konstantin Khlebnikov <koct9i@gmail.com>
CC: Pavel Emelyanov <xemul@virtuozzo.com>
CC: Vladimir Davydov <vdavydov@virtuozzo.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 fs/proc/task_mmu.c       |    2 ++
 include/linux/mm_types.h |    1 +
 mm/mmap.c                |   22 ++++++++++++++++++++++
 3 files changed, 25 insertions(+)

Index: linux-ml.git/fs/proc/task_mmu.c
===================================================================
--- linux-ml.git.orig/fs/proc/task_mmu.c
+++ linux-ml.git/fs/proc/task_mmu.c
@@ -53,6 +53,7 @@ void task_mem(struct seq_file *m, struct
 		"VmHWM:\t%8lu kB\n"
 		"VmRSS:\t%8lu kB\n"
 		"VmData:\t%8lu kB\n"
+		"VmAnon:\t%8lu kB\n"
 		"VmStk:\t%8lu kB\n"
 		"VmExe:\t%8lu kB\n"
 		"VmLib:\t%8lu kB\n"
@@ -66,6 +67,7 @@ void task_mem(struct seq_file *m, struct
 		hiwater_rss << (PAGE_SHIFT-10),
 		total_rss << (PAGE_SHIFT-10),
 		data << (PAGE_SHIFT-10),
+		mm->anon_vm << (PAGE_SHIFT-10),
 		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
 		ptes >> 10,
 		pmds >> 10,
Index: linux-ml.git/include/linux/mm_types.h
===================================================================
--- linux-ml.git.orig/include/linux/mm_types.h
+++ linux-ml.git/include/linux/mm_types.h
@@ -429,6 +429,7 @@ struct mm_struct {
 	unsigned long shared_vm;	/* Shared pages (files) */
 	unsigned long exec_vm;		/* VM_EXEC & ~VM_WRITE */
 	unsigned long stack_vm;		/* VM_GROWSUP/DOWN */
+	unsigned long anon_vm;		/* Anonymous pages mapped */
 	unsigned long def_flags;
 	unsigned long start_code, end_code, start_data, end_data;
 	unsigned long start_brk, brk, start_stack;
Index: linux-ml.git/mm/mmap.c
===================================================================
--- linux-ml.git.orig/mm/mmap.c
+++ linux-ml.git/mm/mmap.c
@@ -1214,6 +1214,8 @@ void vm_stat_account(struct mm_struct *m
 {
 	const unsigned long stack_flags
 		= VM_STACK_FLAGS & (VM_GROWSUP|VM_GROWSDOWN);
+	const unsigned long not_anon_acc
+		= VM_GROWSUP | VM_GROWSDOWN | VM_SHARED | VM_MAYSHARE;
 
 	mm->total_vm += pages;
 
@@ -1223,6 +1225,9 @@ void vm_stat_account(struct mm_struct *m
 			mm->exec_vm += pages;
 	} else if (flags & stack_flags)
 		mm->stack_vm += pages;
+
+	if (!file && (flags & not_anon_acc) == 0)
+		mm->anon_vm += pages;
 }
 #endif /* CONFIG_PROC_FS */
 
@@ -1534,6 +1539,13 @@ static inline int accountable_mapping(st
 	return (vm_flags & (VM_NORESERVE | VM_SHARED | VM_WRITE)) == VM_WRITE;
 }
 
+static inline int anon_accountable_mapping(struct file *file, vm_flags_t vm_flags)
+{
+	return !file &&
+		(vm_flags & (VM_GROWSDOWN | VM_GROWSUP |
+			     VM_SHARED | VM_MAYSHARE)) == 0;
+}
+
 unsigned long mmap_region(struct file *file, unsigned long addr,
 		unsigned long len, vm_flags_t vm_flags, unsigned long pgoff)
 {
@@ -1578,6 +1590,16 @@ unsigned long mmap_region(struct file *f
 	}
 
 	/*
+	 * For anon mappings make sure we don't exceed the limit.
+	 */
+	if (anon_accountable_mapping(file, vm_flags)) {
+		unsigned long lim = rlimit(RLIMIT_DATA) >> PAGE_SHIFT;
+
+		if (lim < (mm->anon_vm + (len >> PAGE_SHIFT)))
+			return -ENOMEM;
+	}
+
+	/*
 	 * Can we just expand an old mapping?
 	 */
 	vma = vma_merge(mm, prev, addr, addr + len, vm_flags,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
