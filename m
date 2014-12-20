Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 02C6C6B006E
	for <linux-mm@kvack.org>; Sat, 20 Dec 2014 09:36:17 -0500 (EST)
Received: by mail-qc0-f177.google.com with SMTP id x3so1804996qcv.8
        for <linux-mm@kvack.org>; Sat, 20 Dec 2014 06:36:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 88si14343640qgg.124.2014.12.20.06.36.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Dec 2014 06:36:15 -0800 (PST)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH] proc: task_mmu: show page size in /proc/<pid>/numa_maps
Date: Sat, 20 Dec 2014 08:54:45 -0500
Message-Id: <c97f30472ec5fe79cb8fa8be66cc3d8509777990.1419079617.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, dave.hansen@linux.intel.com, rientjes@google.com, linux-mm@kvack.org

This patch introduces 'pagesize' line element to /proc/<pid>/numa_maps
report file in order to help disambiguating the size of pages that are
backing memory areas mapped by a task. When the VMA backing page size
is observed different from kernel's default PAGE_SIZE, the new element 
is printed out to complement report output. This is specially useful to
help differentiating between HUGE and GIGANTIC page VMAs.

This patch is based on Dave Hansen's proposal and reviewer's follow ups 
taken from this dicussion: https://lkml.org/lkml/2011/9/21/454

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 fs/proc/task_mmu.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 246eae8..9f2e2c8 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1479,6 +1479,7 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	struct mm_struct *mm = vma->vm_mm;
 	struct mm_walk walk = {};
 	struct mempolicy *pol;
+	unsigned long page_size;
 	char buffer[64];
 	int nid;
 
@@ -1533,6 +1534,10 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	if (!md->pages)
 		goto out;
 
+	page_size = vma_kernel_pagesize(vma);
+	if (page_size != PAGE_SIZE)
+		seq_printf(m, " pagesize=%lu", page_size);
+
 	if (md->anon)
 		seq_printf(m, " anon=%lu", md->anon);
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
