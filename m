Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f173.google.com (mail-ea0-f173.google.com [209.85.215.173])
	by kanga.kvack.org (Postfix) with ESMTP id C03256B0055
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 03:52:12 -0500 (EST)
Received: by mail-ea0-f173.google.com with SMTP id g15so9807328eak.18
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 00:52:12 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id s42si2229757eew.161.2013.12.03.00.52.12
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 00:52:12 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 11/15] sched: numa: Skip inaccessible VMAs
Date: Tue,  3 Dec 2013 08:51:58 +0000
Message-Id: <1386060721-3794-12-git-send-email-mgorman@suse.de>
In-Reply-To: <1386060721-3794-1-git-send-email-mgorman@suse.de>
References: <1386060721-3794-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Inaccessible VMA should not be trapping NUMA hint faults. Skip them.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 7c70201..40d8ea3 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -970,6 +970,13 @@ void task_numa_work(struct callback_head *work)
 		if (!vma_migratable(vma))
 			continue;
 
+		/*
+		 * Skip inaccessible VMAs to avoid any confusion between
+		 * PROT_NONE and NUMA hinting ptes
+		 */
+		if (!(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE)))
+			continue;
+
 		/* Skip small VMAs. They are not likely to be of relevance */
 		if (vma->vm_end - vma->vm_start < HPAGE_SIZE)
 			continue;
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
