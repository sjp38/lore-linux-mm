Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6FF2B280422
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 17:06:48 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m133so266018525pga.2
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 14:06:48 -0700 (PDT)
Received: from mail-pg0-x232.google.com (mail-pg0-x232.google.com. [2607:f8b0:400e:c05::232])
        by mx.google.com with ESMTPS id o1si7665197pge.344.2017.08.21.14.06.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Aug 2017 14:06:47 -0700 (PDT)
Received: by mail-pg0-x232.google.com with SMTP id t3so78235197pgt.0
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 14:06:47 -0700 (PDT)
Date: Mon, 21 Aug 2017 14:06:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] fs, proc: unconditional cond_resched when reading smaps
Message-ID: <alpine.DEB.2.10.1708211405520.131071@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

If there are large numbers of hugepages to iterate while reading
/proc/pid/smaps, the page walk never does cond_resched().  On archs
without split pmd locks, there can be significant and observable
contention on mm->page_table_lock which cause lengthy delays without
rescheduling.

Always reschedule in smaps_pte_range() if necessary since the pagewalk
iteration can be expensive.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 fs/proc/task_mmu.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -599,11 +599,11 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	if (ptl) {
 		smaps_pmd_entry(pmd, addr, walk);
 		spin_unlock(ptl);
-		return 0;
+		goto out;
 	}
 
 	if (pmd_trans_unstable(pmd))
-		return 0;
+		goto out;
 	/*
 	 * The mmap_sem held all the way back in m_start() is what
 	 * keeps khugepaged out of here and from collapsing things
@@ -613,6 +613,7 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	for (; addr != end; pte++, addr += PAGE_SIZE)
 		smaps_pte_entry(pte, addr, walk);
 	pte_unmap_unlock(pte - 1, ptl);
+out:
 	cond_resched();
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
