Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0BE166B0044
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 10:51:43 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id f15so2321309eak.25
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 07:51:43 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id r9si14884139eeo.86.2013.12.10.07.51.43
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 07:51:43 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/18] mm: numa: Clear numa hinting information on mprotect
Date: Tue, 10 Dec 2013 15:51:27 +0000
Message-Id: <1386690695-27380-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1386690695-27380-1-git-send-email-mgorman@suse.de>
References: <1386690695-27380-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

On a protection change it is no longer clear if the page should be still
accessible.  This patch clears the NUMA hinting fault bits on a protection
change.

Cc: stable@vger.kernel.org
Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/huge_memory.c | 2 ++
 mm/mprotect.c    | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 0f00b96..0ecaba2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1522,6 +1522,8 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		ret = 1;
 		if (!prot_numa) {
 			entry = pmdp_get_and_clear(mm, addr, pmd);
+			if (pmd_numa(entry))
+				entry = pmd_mknonnuma(entry);
 			entry = pmd_modify(entry, newprot);
 			ret = HPAGE_PMD_NR;
 			BUG_ON(pmd_write(entry));
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 0a07e2d..eb2f349 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -54,6 +54,8 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 
 			if (!prot_numa) {
 				ptent = ptep_modify_prot_start(mm, addr, pte);
+				if (pte_numa(ptent))
+					ptent = pte_mknonnuma(ptent);
 				ptent = pte_modify(ptent, newprot);
 				updated = true;
 			} else {
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
