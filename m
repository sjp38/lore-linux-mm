Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 290656B0292
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 09:36:14 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so33362751wic.1
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 06:36:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id rz15si9015350wjb.115.2015.10.02.06.36.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 Oct 2015 06:36:05 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v4 4/4] mm, procfs: Display VmAnon, VmFile and VmShm in /proc/pid/status
Date: Fri,  2 Oct 2015 15:35:51 +0200
Message-Id: <1443792951-13944-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1443792951-13944-1-git-send-email-vbabka@suse.cz>
References: <1443792951-13944-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Vlastimil Babka <vbabka@suse.cz>

From: Jerome Marchand <jmarchan@redhat.com>

It's currently inconvenient to retrieve MM_ANONPAGES value from status
and statm files and there is no way to separate MM_FILEPAGES and
MM_SHMEMPAGES. Add RssAnon, RssFile and RssShm lines in /proc/<pid>/status
to solve these issues.

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 Documentation/filesystems/proc.txt | 10 +++++++++-
 fs/proc/task_mmu.c                 | 14 ++++++++++++--
 2 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 82d3657..c887a42 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -169,6 +169,9 @@ For example, to get the status information of a process, all you have to do is
   VmLck:         0 kB
   VmHWM:       476 kB
   VmRSS:       476 kB
+  RssAnon      352 kB
+  RssFile:     120 kB
+  RssShm:        4 kB
   VmData:      156 kB
   VmStk:        88 kB
   VmExe:        68 kB
@@ -231,7 +234,12 @@ Table 1-2: Contents of the status files (as of 4.1)
  VmSize                      total program size
  VmLck                       locked memory size
  VmHWM                       peak resident set size ("high water mark")
- VmRSS                       size of memory portions
+ VmRSS                       size of memory portions. It contains the three
+                             following parts (VmRSS = RssAnon + RssFile + RssShm)
+ RssAnon                     size of resident anonymous memory
+ RssFile                     size of resident file mappings
+ RssShm                      size of resident shmem memory (includes SysV shm,
+                             mapping of tmpfs and shared anonymous mappings)
  VmData                      size of data, stack, and text segments
  VmStk                       size of data, stack, and text segments
  VmExe                       size of text segment
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 9b9708e..7332afd 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -23,9 +23,13 @@
 
 void task_mem(struct seq_file *m, struct mm_struct *mm)
 {
-	unsigned long data, text, lib, swap, ptes, pmds;
+	unsigned long data, text, lib, swap, ptes, pmds, anon, file, shmem;
 	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
 
+	anon = get_mm_counter(mm, MM_ANONPAGES);
+	file = get_mm_counter(mm, MM_FILEPAGES);
+	shmem = get_mm_counter(mm, MM_SHMEMPAGES);
+
 	/*
 	 * Note: to minimize their overhead, mm maintains hiwater_vm and
 	 * hiwater_rss only when about to *lower* total_vm or rss.  Any
@@ -36,7 +40,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 	hiwater_vm = total_vm = mm->total_vm;
 	if (hiwater_vm < mm->hiwater_vm)
 		hiwater_vm = mm->hiwater_vm;
-	hiwater_rss = total_rss = get_mm_rss(mm);
+	hiwater_rss = total_rss = anon + file + shmem;
 	if (hiwater_rss < mm->hiwater_rss)
 		hiwater_rss = mm->hiwater_rss;
 
@@ -53,6 +57,9 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		"VmPin:\t%8lu kB\n"
 		"VmHWM:\t%8lu kB\n"
 		"VmRSS:\t%8lu kB\n"
+		"RssAnon:\t%8lu kB\n"
+		"RssFile:\t%8lu kB\n"
+		"RssShm:\t%8lu kB\n"
 		"VmData:\t%8lu kB\n"
 		"VmStk:\t%8lu kB\n"
 		"VmExe:\t%8lu kB\n"
@@ -66,6 +73,9 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		mm->pinned_vm << (PAGE_SHIFT-10),
 		hiwater_rss << (PAGE_SHIFT-10),
 		total_rss << (PAGE_SHIFT-10),
+		anon << (PAGE_SHIFT-10),
+		file << (PAGE_SHIFT-10),
+		shmem << (PAGE_SHIFT-10),
 		data << (PAGE_SHIFT-10),
 		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
 		ptes >> 10,
-- 
2.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
