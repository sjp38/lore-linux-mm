Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id CE1BA6B0037
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 10:25:34 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id q107so3932608qgd.5
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 07:25:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v20si14874520qav.94.2014.09.15.07.25.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Sep 2014 07:25:34 -0700 (PDT)
From: "Jerome Marchand" <jmarchan@redhat.com>
Subject: [RFC PATCH v2 2/5] mm, procfs: Display VmAnon, VmFile and VmShm in /proc/pid/status
Date: Mon, 15 Sep 2014 16:24:34 +0200
Message-Id: <1410791077-5300-3-git-send-email-jmarchan@redhat.com>
In-Reply-To: <1410791077-5300-1-git-send-email-jmarchan@redhat.com>
References: <1410791077-5300-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Randy Dunlap <rdunlap@infradead.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>

It's currently inconvenient to retrieve MM_ANONPAGES value from status
and statm files and there is no way to separate MM_FILEPAGES and
MM_SHMEMPAGES. Add VmAnon, VmFile and VmShm lines in /proc/<pid>/status
to solve these issues.

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 Documentation/filesystems/proc.txt | 10 +++++++++-
 fs/proc/task_mmu.c                 | 11 ++++++++++-
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 154a345..ffd4a7f 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -165,6 +165,9 @@ read the file /proc/PID/status:
   VmLck:         0 kB
   VmHWM:       476 kB
   VmRSS:       476 kB
+  VmAnon:      352 kB
+  VmFile:      124 kB
+  VmShm:         4 kB
   VmData:      156 kB
   VmStk:        88 kB
   VmExe:        68 kB
@@ -221,7 +224,12 @@ Table 1-2: Contents of the status files (as of 2.6.30-rc7)
  VmSize                      total program size
  VmLck                       locked memory size
  VmHWM                       peak resident set size ("high water mark")
- VmRSS                       size of memory portions
+ VmRSS                       size of memory portions. It contains the three
+                             following parts (VmRSS = VmAnon + VmFile + VmShm)
+ VmAnon                      size of resident anonymous memory
+ VmFile                      size of resident file mappings
+ VmShm                       size of resident shmem memory (includes SysV shm,
+                             mapping of tmpfs and shared anonymous mappings)
  VmData                      size of data, stack, and text segments
  VmStk                       size of data, stack, and text segments
  VmExe                       size of text segment
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 32657e3..762257f 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -21,7 +21,7 @@
 
 void task_mem(struct seq_file *m, struct mm_struct *mm)
 {
-	unsigned long data, text, lib, swap;
+	unsigned long data, text, lib, swap, anon, file, shmem;
 	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
 
 	/*
@@ -38,6 +38,9 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 	if (hiwater_rss < mm->hiwater_rss)
 		hiwater_rss = mm->hiwater_rss;
 
+	anon = get_mm_counter(mm, MM_ANONPAGES);
+	file = get_mm_counter(mm, MM_FILEPAGES);
+	shmem = get_mm_counter(mm, MM_SHMEMPAGES);
 	data = mm->total_vm - mm->shared_vm - mm->stack_vm;
 	text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK)) >> 10;
 	lib = (mm->exec_vm << (PAGE_SHIFT-10)) - text;
@@ -49,6 +52,9 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		"VmPin:\t%8lu kB\n"
 		"VmHWM:\t%8lu kB\n"
 		"VmRSS:\t%8lu kB\n"
+		"VmAnon:\t%8lu kB\n"
+		"VmFile:\t%8lu kB\n"
+		"VmShm:\t%8lu kB\n"
 		"VmData:\t%8lu kB\n"
 		"VmStk:\t%8lu kB\n"
 		"VmExe:\t%8lu kB\n"
@@ -61,6 +67,9 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		mm->pinned_vm << (PAGE_SHIFT-10),
 		hiwater_rss << (PAGE_SHIFT-10),
 		total_rss << (PAGE_SHIFT-10),
+		anon << (PAGE_SHIFT-10),
+		file << (PAGE_SHIFT-10),
+		shmem << (PAGE_SHIFT-10),
 		data << (PAGE_SHIFT-10),
 		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
 		(PTRS_PER_PTE * sizeof(pte_t) *
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
