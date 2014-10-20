Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9E3ED6B006C
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 19:27:25 -0400 (EDT)
Received: by mail-qc0-f170.google.com with SMTP id m20so61818qcx.15
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 16:27:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j104si19101722qgd.15.2014.10.20.16.27.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 16:27:24 -0700 (PDT)
From: Petr Holasek <pholasek@redhat.com>
Subject: [RFC][PATCH] add pagesize field to /proc/pid/numa_maps
Date: Tue, 21 Oct 2014 01:27:14 +0200
Message-Id: <1413847634-20039-1-git-send-email-pholasek@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@intel.com>, pholasek@redhat.com

There were some similar attempts to add vma's pagesize to numa_maps in the past,
so I've distilled the most straightforward one - adding pagesize field
expressing size in kbytes to each line. Although page size can be also obtained
from smaps file, adding pagesize to numa_maps makes the interface more compact
and easier to use without need for traversing other files.

New numa_maps output looks like that:

2aaaaac00000 default file=/dev/hugepages/hugepagefile huge pagesize=2097152 dirty=1 N0=1
7f302441a000 default file=/usr/lib64/libc-2.17.so pagesize=4096 mapped=65 mapmax=38 N0=65

Signed-off-by: Petr Holasek <pholasek@redhat.com>
---
 fs/proc/task_mmu.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 4e0388c..964c4de 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1498,6 +1498,9 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	if (!md->pages)
 		goto out;
 
+	seq_puts(m, " pagesize=");
+	seq_printf(m, "%lu", vma_kernel_pagesize(vma));
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
