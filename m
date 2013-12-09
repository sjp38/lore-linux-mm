Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id F15426B0035
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 02:09:20 -0500 (EST)
Received: by mail-ee0-f54.google.com with SMTP id e51so1321697eek.41
        for <linux-mm@kvack.org>; Sun, 08 Dec 2013 23:09:20 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id h45si8244114eeo.46.2013.12.08.23.09.18
        for <linux-mm@kvack.org>;
        Sun, 08 Dec 2013 23:09:18 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 05/18] mm: numa: Do not clear PTE for pte_numa update
Date: Mon,  9 Dec 2013 07:08:59 +0000
Message-Id: <1386572952-1191-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-1-git-send-email-mgorman@suse.de>
References: <1386572952-1191-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The TLB must be flushed if the PTE is updated but change_pte_range is clearing
the PTE while marking PTEs pte_numa without necessarily flushing the TLB if it
reinserts the same entry. Without the flush, it's conceivable that two processors
have different TLBs for the same virtual address and at the very least it would
generate spurious faults. This patch only unmaps the pages in change_pte_range for
a full protection change.

Cc: stable@vger.kernel.org
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/mprotect.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 2666797..0a07e2d 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -52,13 +52,14 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 			pte_t ptent;
 			bool updated = false;
 
-			ptent = ptep_modify_prot_start(mm, addr, pte);
 			if (!prot_numa) {
+				ptent = ptep_modify_prot_start(mm, addr, pte);
 				ptent = pte_modify(ptent, newprot);
 				updated = true;
 			} else {
 				struct page *page;
 
+				ptent = *pte;
 				page = vm_normal_page(vma, addr, oldpte);
 				if (page) {
 					if (!pte_numa(oldpte)) {
@@ -79,7 +80,10 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 
 			if (updated)
 				pages++;
-			ptep_modify_prot_commit(mm, addr, pte, ptent);
+
+			/* Only !prot_numa always clears the pte */
+			if (!prot_numa)
+				ptep_modify_prot_commit(mm, addr, pte, ptent);
 		} else if (IS_ENABLED(CONFIG_MIGRATION) && !pte_file(oldpte)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
 
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
