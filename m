Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 27ED06B003D
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 03:52:11 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id e49so1268967eek.21
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 00:52:10 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id s42si2252041eew.98.2013.12.03.00.52.10
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 00:52:10 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/15] mm: numa: Ensure anon_vma is locked to prevent parallel THP splits
Date: Tue,  3 Dec 2013 08:51:56 +0000
Message-Id: <1386060721-3794-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1386060721-3794-1-git-send-email-mgorman@suse.de>
References: <1386060721-3794-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The anon_vma lock prevents parallel THP splits and any associated complexity
that arises when handling splits during THP migration. This patch checks
if the lock was successfully acquired and bails from THP migration if it
failed for any reason.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/huge_memory.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d6c3bf4..98b6a79 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1342,6 +1342,13 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto out_unlock;
 	}
 
+	/* Bail if we fail to protect against THP splits for any reason */
+	if (unlikely(!anon_vma)) {
+		put_page(page);
+		page_nid = -1;
+		goto clear_pmdnuma;
+	}
+
 	/*
 	 * Migrate the THP to the requested node, returns with page unlocked
 	 * and pmd_numa cleared.
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
