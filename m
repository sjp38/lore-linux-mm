Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id E698B6B0070
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 16:00:24 -0400 (EDT)
Received: by lbcmx3 with SMTP id mx3so16587065lbc.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 13:00:24 -0700 (PDT)
Received: from mail-lb0-x244.google.com (mail-lb0-x244.google.com. [2a00:1450:4010:c04::244])
        by mx.google.com with ESMTPS id bb9si6601178lab.145.2015.06.09.13.00.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 13:00:23 -0700 (PDT)
Received: by lbiv13 with SMTP id v13so3283564lbi.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 13:00:22 -0700 (PDT)
Subject: [PATCH v3 3/4] pagemap: hide physical addresses from non-privileged
 users
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Tue, 09 Jun 2015 23:00:19 +0300
Message-ID: <20150609200019.21971.54721.stgit@zurg>
In-Reply-To: <20150609195333.21971.58194.stgit@zurg>
References: <20150609195333.21971.58194.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-api@vger.kernel.org, Mark Williamson <mwilliamson@undo-software.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

This patch makes pagemap readable for normal users back but hides physical
addresses from them. For some use cases PFN isn't required at all: flags
give information about presence, page type (anon/file/swap), soft-dirty mark,
and hint about page mapcount state: exclusive(mapcount = 1) or (mapcount > 1).

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Fixes: ab676b7d6fbf ("pagemap: do not leak physical addresses to non-privileged userspace")
Link: http://lkml.kernel.org/r/1425935472-17949-1-git-send-email-kirill@shutemov.name

---

v3: get capabilities from file
---
 fs/proc/task_mmu.c |   36 ++++++++++++++++++++++--------------
 1 file changed, 22 insertions(+), 14 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index b02e38f..f1b9ae8 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -962,6 +962,7 @@ struct pagemapread {
 	int pos, len;		/* units: PM_ENTRY_BYTES, not bytes */
 	pagemap_entry_t *buffer;
 	bool v2;
+	bool show_pfn;
 };
 
 #define PAGEMAP_WALK_SIZE	(PMD_SIZE)
@@ -1046,12 +1047,13 @@ out:
 static void pte_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *pm,
 		struct vm_area_struct *vma, unsigned long addr, pte_t pte)
 {
-	u64 frame, flags;
+	u64 frame = 0, flags;
 	struct page *page = NULL;
 	int flags2 = 0;
 
 	if (pte_present(pte)) {
-		frame = pte_pfn(pte);
+		if (pm->show_pfn)
+			frame = pte_pfn(pte);
 		flags = PM_PRESENT;
 		page = vm_normal_page(vma, addr, pte);
 		if (pte_soft_dirty(pte))
@@ -1087,15 +1089,19 @@ static void pte_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *pm,
 static void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *pm,
 		pmd_t pmd, int offset, int pmd_flags2)
 {
+	u64 frame = 0;
+
 	/*
 	 * Currently pmd for thp is always present because thp can not be
 	 * swapped-out, migrated, or HWPOISONed (split in such cases instead.)
 	 * This if-check is just to prepare for future implementation.
 	 */
-	if (pmd_present(pmd))
-		*pme = make_pme(PM_PFRAME(pmd_pfn(pmd) + offset)
-				| PM_STATUS2(pm->v2, pmd_flags2) | PM_PRESENT);
-	else
+	if (pmd_present(pmd)) {
+		if (pm->show_pfn)
+			frame = pmd_pfn(pmd) + offset;
+		*pme = make_pme(PM_PFRAME(frame) | PM_PRESENT |
+				PM_STATUS2(pm->v2, pmd_flags2));
+	} else
 		*pme = make_pme(PM_NOT_PRESENT(pm->v2) | PM_STATUS2(pm->v2, pmd_flags2));
 }
 #else
@@ -1171,11 +1177,14 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 static void huge_pte_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *pm,
 					pte_t pte, int offset, int flags2)
 {
-	if (pte_present(pte))
-		*pme = make_pme(PM_PFRAME(pte_pfn(pte) + offset)	|
-				PM_STATUS2(pm->v2, flags2)		|
-				PM_PRESENT);
-	else
+	u64 frame = 0;
+
+	if (pte_present(pte)) {
+		if (pm->show_pfn)
+			frame = pte_pfn(pte) + offset;
+		*pme = make_pme(PM_PFRAME(frame) | PM_PRESENT |
+				PM_STATUS2(pm->v2, flags2));
+	} else
 		*pme = make_pme(PM_NOT_PRESENT(pm->v2)			|
 				PM_STATUS2(pm->v2, flags2));
 }
@@ -1258,6 +1267,8 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 	if (!count)
 		goto out_mm;
 
+	/* do not disclose physical addresses: attack vector */
+	pm.show_pfn = file_ns_capable(file, &init_user_ns, CAP_SYS_ADMIN);
 	pm.v2 = soft_dirty_cleared;
 	pm.len = (PAGEMAP_WALK_SIZE >> PAGE_SHIFT);
 	pm.buffer = kmalloc(pm.len * PM_ENTRY_BYTES, GFP_TEMPORARY);
@@ -1328,9 +1339,6 @@ static int pagemap_open(struct inode *inode, struct file *file)
 {
 	struct mm_struct *mm;
 
-	/* do not disclose physical addresses: attack vector */
-	if (!capable(CAP_SYS_ADMIN))
-		return -EPERM;
 	pr_warn_once("Bits 55-60 of /proc/PID/pagemap entries are about "
 			"to stop being page-shift some time soon. See the "
 			"linux/Documentation/vm/pagemap.txt for details.\n");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
