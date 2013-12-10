Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 62AE56B0044
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 10:51:43 -0500 (EST)
Received: by mail-ee0-f47.google.com with SMTP id e51so2248616eek.20
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 07:51:42 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id t6si14852305eeh.213.2013.12.10.07.51.42
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 07:51:42 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 08/18] sched: numa: Skip inaccessible VMAs
Date: Tue, 10 Dec 2013 15:51:26 +0000
Message-Id: <1386690695-27380-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1386690695-27380-1-git-send-email-mgorman@suse.de>
References: <1386690695-27380-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Inaccessible VMA should not be trapping NUMA hint faults. Skip them.

Cc: stable@vger.kernel.org
Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 kernel/sched/fair.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index fd773ad..18bf84e 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1752,6 +1752,13 @@ void task_numa_work(struct callback_head *work)
 		    (vma->vm_file && (vma->vm_flags & (VM_READ|VM_WRITE)) == (VM_READ)))
 			continue;
 
+		/*
+		 * Skip inaccessible VMAs to avoid any confusion between
+		 * PROT_NONE and NUMA hinting ptes
+		 */
+		if (!(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE)))
+			continue;
+
 		do {
 			start = max(start, vma->vm_start);
 			end = ALIGN(start + (pages << PAGE_SHIFT), HPAGE_SIZE);
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
