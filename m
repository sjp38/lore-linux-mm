Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8169E6B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 07:27:12 -0500 (EST)
Received: by mail-ie0-f171.google.com with SMTP id ar1so2397475iec.2
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 04:27:12 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id m81si13730404iom.55.2015.01.13.04.27.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jan 2015 04:27:11 -0800 (PST)
From: Shiraz Hashim <shashim@codeaurora.org>
Subject: [PATCH 1/1] mm: pagemap: limit scan to virtual region being asked
Date: Tue, 13 Jan 2015 17:57:04 +0530
Message-Id: <1421152024-6204-1-git-send-email-shashim@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, Shiraz Hashim <shashim@codeaurora.org>

pagemap_read scans through the virtual address space of a
task till it prepares 'count' pagemaps or it reaches end
of task.

This presents a problem when the page walk doesn't happen
for vma with VM_PFNMAP set. In which case walk is silently
skipped and no pagemap is prepare, in turn making
pagemap_read to scan through task end, even crossing beyond
'count', landing into a different vma region. This leads to
wrong presentation of mappings for that vma.

Fix this by limiting end_vaddr to the end of the virtual
address region being scanned.

Signed-off-by: Shiraz Hashim <shashim@codeaurora.org>
---
 fs/proc/task_mmu.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 246eae8..04362e4 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1270,7 +1270,9 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 	src = *ppos;
 	svpfn = src / PM_ENTRY_BYTES;
 	start_vaddr = svpfn << PAGE_SHIFT;
-	end_vaddr = TASK_SIZE_OF(task);
+	end_vaddr = start_vaddr + ((count / PM_ENTRY_BYTES) << PAGE_SHIFT);
+	if ((end_vaddr > TASK_SIZE_OF(task)) || (end_vaddr < start_vaddr))
+		end_vaddr = TASK_SIZE_OF(task);
 
 	/* watch out for wraparound */
 	if (svpfn > TASK_SIZE_OF(task) >> PAGE_SHIFT)
-- 

QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
