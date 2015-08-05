Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id EF8D59003C8
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 09:02:24 -0400 (EDT)
Received: by wijp15 with SMTP id p15so47614828wij.0
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 06:02:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gb6si10158651wic.42.2015.08.05.06.02.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 06:02:20 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 4/4] mm, procfs: Display VmAnon, VmFile and VmShm in /proc/pid/status
Date: Wed,  5 Aug 2015 15:01:25 +0200
Message-Id: <1438779685-5227-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1438779685-5227-1-git-send-email-vbabka@suse.cz>
References: <1438779685-5227-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jerome Marchand <jmarchan@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Minchan Kim <minchan@kernel.org>

From: Jerome Marchand <jmarchan@redhat.com>

It's currently inconvenient to retrieve MM_ANONPAGES value from status
and statm files and there is no way to separate MM_FILEPAGES and
MM_SHMEMPAGES. Add VmAnon, VmFile and VmShm lines in /proc/<pid>/status
to solve these issues.

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 Documentation/filesystems/proc.txt | 10 +++++++++-
 fs/proc/task_mmu.c                 | 13 +++++++++++--
 2 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index fcf67c7..fadd1b3 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -168,6 +168,9 @@ For example, to get the status information of a process, all you have to do is
   VmLck:         0 kB
   VmHWM:       476 kB
   VmRSS:       476 kB
+  VmAnon:      352 kB
+  VmFile:      120 kB
+  VmShm:         4 kB
   VmData:      156 kB
   VmStk:        88 kB
   VmExe:        68 kB
@@ -229,7 +232,12 @@ Table 1-2: Contents of the status files (as of 4.1)
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
index 99b0efe..e299101 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -22,7 +22,7 @@
 
 void task_mem(struct seq_file *m, struct mm_struct *mm)
 {
-	unsigned long data, text, lib, swap, ptes, pmds;
+	unsigned long data, text, lib, swap, ptes, pmds, anon, file, shmem;
 	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
 
 	/*
@@ -39,6 +39,9 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 	if (hiwater_rss < mm->hiwater_rss)
 		hiwater_rss = mm->hiwater_rss;
 
+	anon = get_mm_counter(mm, MM_ANONPAGES);
+	file = get_mm_counter(mm, MM_FILEPAGES);
+	shmem = get_mm_counter_shmem(mm);
 	data = mm->total_vm - mm->shared_vm - mm->stack_vm;
 	text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK)) >> 10;
 	lib = (mm->exec_vm << (PAGE_SHIFT-10)) - text;
@@ -52,6 +55,9 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		"VmPin:\t%8lu kB\n"
 		"VmHWM:\t%8lu kB\n"
 		"VmRSS:\t%8lu kB\n"
+		"VmAnon:\t%8lu kB\n"
+		"VmFile:\t%8lu kB\n"
+		"VmShm:\t%8lu kB\n"
 		"VmData:\t%8lu kB\n"
 		"VmStk:\t%8lu kB\n"
 		"VmExe:\t%8lu kB\n"
@@ -65,6 +71,9 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		mm->pinned_vm << (PAGE_SHIFT-10),
 		hiwater_rss << (PAGE_SHIFT-10),
 		total_rss << (PAGE_SHIFT-10),
+		anon << (PAGE_SHIFT-10),
+		file << (PAGE_SHIFT-10),
+		shmem << (PAGE_SHIFT-10),
 		data << (PAGE_SHIFT-10),
 		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
 		ptes >> 10,
@@ -82,7 +91,7 @@ unsigned long task_statm(struct mm_struct *mm,
 			 unsigned long *data, unsigned long *resident)
 {
 	*shared = get_mm_counter(mm, MM_FILEPAGES) +
-		get_mm_counter(mm, MM_SHMEMPAGES);
+		get_mm_counter_shmem(mm);
 	*text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK))
 								>> PAGE_SHIFT;
 	*data = mm->total_vm - mm->shared_vm;
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
