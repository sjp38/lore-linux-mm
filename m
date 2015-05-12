Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3A86B006E
	for <linux-mm@kvack.org>; Tue, 12 May 2015 05:43:13 -0400 (EDT)
Received: by lagv1 with SMTP id v1so1211151lag.3
        for <linux-mm@kvack.org>; Tue, 12 May 2015 02:43:12 -0700 (PDT)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [2a02:6b8:0:801::10])
        by mx.google.com with ESMTPS id rs2si9992602lbb.106.2015.05.12.02.43.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 02:43:09 -0700 (PDT)
Subject: [PATCH v2 2/3] pagemap: hide physical addresses from non-privileged
 users
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 12 May 2015 12:43:05 +0300
Message-ID: <20150512094305.24768.51807.stgit@buzz>
In-Reply-To: <20150512090156.24768.2521.stgit@buzz>
References: <20150512090156.24768.2521.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Williamson <mwilliamson@undo-software.com>, Pavel Emelyanov <xemul@parallels.com>, linux-api@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Machek <pavel@ucw.cz>, Mark Seaborn <mseaborn@chromium.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, Daniel James <djames@undo-software.com>, Finn Grimwood <fgrimwood@undo-software.com>

This patch makes pagemap readable for normal users back but hides physical
addresses from them. For some use cases PFN isn't required at all: flags
give information about presence, page type (anon/file/swap), soft-dirty mark,
and hint about page mapcount state: exclusive(mapcount = 1) or (mapcount > 1).

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Fixes: ab676b7d6fbf ("pagemap: do not leak physical addresses to non-privileged userspace")
Link: lkml.kernel.org/r/1425935472-17949-1-git-send-email-kirill@shutemov.name
---
 fs/proc/task_mmu.c |   36 ++++++++++++++++++++++--------------
 1 file changed, 22 insertions(+), 14 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 29febec65de4..0b7a8ffec95f 100644
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
@@ -1260,6 +1269,8 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 	if (!count)
 		goto out_task;
 
+	/* do not disclose physical addresses: attack vector */
+	pm.show_pfn = capable(CAP_SYS_ADMIN);
 	pm.v2 = soft_dirty_cleared;
 	pm.len = (PAGEMAP_WALK_SIZE >> PAGE_SHIFT);
 	pm.buffer = kmalloc(pm.len * PM_ENTRY_BYTES, GFP_TEMPORARY);
@@ -1335,9 +1346,6 @@ out:
 
 static int pagemap_open(struct inode *inode, struct file *file)
 {
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
