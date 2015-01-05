Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id 79EB36B0038
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 13:36:21 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id b13so17590788qcw.37
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 10:36:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w2si39092175qat.24.2015.01.05.10.36.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jan 2015 10:36:20 -0800 (PST)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v2] fs: proc: task_mmu: show page size in /proc/<pid>/numa_maps
Date: Mon,  5 Jan 2015 12:44:31 -0500
Message-Id: <734bca19b3a8f4e191ccc9055ad4740744b5b2b6.1420464466.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, jweiner@redhat.com, dave.hansen@linux.intel.com, rientjes@google.com, linux-mm@kvack.org

This patch introduces 'kernelpagesize_kB' line element to /proc/<pid>/numa_maps
report file in order to help identifying the size of pages that are backing
memory areas mapped by a given task. This is specially useful to
help differentiating between HUGE and GIGANTIC page backed VMAs.

This patch is based on Dave Hansen's proposal and reviewer's follow-ups
taken from the following dicussion threads:
 * https://lkml.org/lkml/2011/9/21/454
 * https://lkml.org/lkml/2014/12/20/66

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
* v2 changelog:
  . print kernel page size unconditionally (jweiner, dhansen)
  . rename pagesize to match smaps terminology (dhansen, drientjes)

 fs/proc/task_mmu.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 246eae8..3688d64 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1533,6 +1533,8 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	if (!md->pages)
 		goto out;
 
+	seq_printf(m, " kernelpagesize_kB=%lu", vma_kernel_pagesize(vma) >> 10);
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
