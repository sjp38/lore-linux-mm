Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B79256B0069
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 01:00:25 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y68so541150970pfb.6
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 22:00:25 -0800 (PST)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id f22si17971216pli.271.2016.12.05.22.00.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 22:00:24 -0800 (PST)
Received: by mail-pf0-x235.google.com with SMTP id 189so68478524pfz.3
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 22:00:24 -0800 (PST)
Date: Mon, 5 Dec 2016 22:00:22 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: add cond_resched() in gather_pte_stats()
Message-ID: <alpine.LSU.2.11.1612052157400.13021@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-mm@kvack.org

The other pagetable walks in task_mmu.c have a cond_resched() after
walking their ptes: add a cond_resched() in gather_pte_stats() too,
for reading /proc/<id>/numa_maps.  Only pagemap_pmd_range() has a
cond_resched() in its (unusually expensive) pmd_trans_huge case:
more should probably be added, but leave them unchanged for now.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 fs/proc/task_mmu.c |    1 +
 1 file changed, 1 insertion(+)

--- 4.9-rc8/fs/proc/task_mmu.c	2016-10-23 17:33:00.156860538 -0700
+++ linux/fs/proc/task_mmu.c	2016-12-05 20:27:04.084531599 -0800
@@ -1588,6 +1588,7 @@ static int gather_pte_stats(pmd_t *pmd,
 
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	pte_unmap_unlock(orig_pte, ptl);
+	cond_resched();
 	return 0;
 }
 #ifdef CONFIG_HUGETLB_PAGE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
