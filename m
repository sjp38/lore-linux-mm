Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C5086B0253
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 07:32:40 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id d10so2097851lfg.4
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 04:32:40 -0700 (PDT)
Received: from forwardcorp1o.cmail.yandex.net (forwardcorp1o.cmail.yandex.net. [2a02:6b8:0:1a72::290])
        by mx.google.com with ESMTPS id z17si632374lje.90.2017.10.06.04.32.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 04:32:38 -0700 (PDT)
Subject: [PATCH] proc: do not show VmExe bigger than total executable
 virtual memory
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Fri, 06 Oct 2017 14:32:34 +0300
Message-ID: <150728955451.743749.11276392315459539583.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

If start_code / end_code pointers are screwed then "VmExe" could be bigger
than total executable virtual memory and "VmLib" becomes negative:

VmExe:	  294320 kB
VmLib:	18446744073709327564 kB

VmExe and VmLib documented as text segment and shared library code size.

Now their sum will be always equal to mm->exec_vm which sums size of
executable and not writable and not stack areas.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 fs/proc/task_mmu.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 5589b4bd4b85..d3819beb2d30 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -46,8 +46,11 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 	if (hiwater_rss < mm->hiwater_rss)
 		hiwater_rss = mm->hiwater_rss;
 
-	text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK)) >> 10;
-	lib = (mm->exec_vm << (PAGE_SHIFT-10)) - text;
+	/* split executable areas between text and lib */
+	text = PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK);
+	text = min(text, mm->exec_vm << PAGE_SHIFT);
+	lib = (mm->exec_vm << PAGE_SHIFT) - text;
+
 	swap = get_mm_counter(mm, MM_SWAPENTS);
 	ptes = PTRS_PER_PTE * sizeof(pte_t) * atomic_long_read(&mm->nr_ptes);
 	pmds = PTRS_PER_PMD * sizeof(pmd_t) * mm_nr_pmds(mm);
@@ -78,7 +81,9 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		file << (PAGE_SHIFT-10),
 		shmem << (PAGE_SHIFT-10),
 		mm->data_vm << (PAGE_SHIFT-10),
-		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
+		mm->stack_vm << (PAGE_SHIFT-10),
+		text >> 10,
+		lib >> 10,
 		ptes >> 10,
 		pmds >> 10,
 		swap << (PAGE_SHIFT-10));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
