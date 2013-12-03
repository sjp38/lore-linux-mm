Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 983226B005A
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 03:52:13 -0500 (EST)
Received: by mail-ee0-f54.google.com with SMTP id e51so1292204eek.27
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 00:52:13 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id p46si2227544eem.168.2013.12.03.00.52.12
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 00:52:12 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 12/15] Clear numa on mprotect
Date: Tue,  3 Dec 2013 08:51:59 +0000
Message-Id: <1386060721-3794-13-git-send-email-mgorman@suse.de>
In-Reply-To: <1386060721-3794-1-git-send-email-mgorman@suse.de>
References: <1386060721-3794-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

---
 mm/huge_memory.c | 2 ++
 mm/mprotect.c    | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 98b6a79..fa277fa 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1484,6 +1484,8 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 
 		if (!prot_numa) {
 			entry = pmdp_get_and_clear(mm, addr, pmd);
+			if (pmd_numa(entry))
+				entry = pmd_mknonnuma(entry);
 			entry = pmd_modify(entry, newprot);
 			BUG_ON(pmd_write(entry));
 			set_pmd_at(mm, addr, pmd, entry);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index c53e332..510f138 100644
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
