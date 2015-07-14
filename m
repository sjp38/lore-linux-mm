Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 39367280250
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 11:37:52 -0400 (EDT)
Received: by laem6 with SMTP id m6so8437247lae.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 08:37:51 -0700 (PDT)
Received: from forward-corp1o.mail.yandex.net (forward-corp1o.mail.yandex.net. [37.140.190.172])
        by mx.google.com with ESMTPS id p8si1269770laf.10.2015.07.14.08.37.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 08:37:50 -0700 (PDT)
Subject: [PATCH v4 4/5] pagemap: hide physical addresses from non-privileged
 users
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 14 Jul 2015 18:37:47 +0300
Message-ID: <20150714153747.29844.13543.stgit@buzz>
In-Reply-To: <20150714152516.29844.69929.stgit@buzz>
References: <20150714152516.29844.69929.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Mark Williamson <mwilliamson@undo-software.com>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

This patch makes pagemap readable for normal users and hides physical
addresses from them. For some use-cases PFN isn't required at all.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Fixes: ab676b7d6fbf ("pagemap: do not leak physical addresses to non-privileged userspace")
Link: http://lkml.kernel.org/r/1425935472-17949-1-git-send-email-kirill@shutemov.name
---
 fs/proc/task_mmu.c |   25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 040721fa405a..3a5d338ea219 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -937,6 +937,7 @@ typedef struct {
 struct pagemapread {
 	int pos, len;		/* units: PM_ENTRY_BYTES, not bytes */
 	pagemap_entry_t *buffer;
+	bool show_pfn;
 };
 
 #define PAGEMAP_WALK_SIZE	(PMD_SIZE)
@@ -1013,7 +1014,8 @@ static pagemap_entry_t pte_to_pagemap_entry(struct pagemapread *pm,
 	struct page *page = NULL;
 
 	if (pte_present(pte)) {
-		frame = pte_pfn(pte);
+		if (pm->show_pfn)
+			frame = pte_pfn(pte);
 		flags |= PM_PRESENT;
 		page = vm_normal_page(vma, addr, pte);
 		if (pte_soft_dirty(pte))
@@ -1063,8 +1065,9 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
 		 */
 		if (pmd_present(pmd)) {
 			flags |= PM_PRESENT;
-			frame = pmd_pfn(pmd) +
-				((addr & ~PMD_MASK) >> PAGE_SHIFT);
+			if (pm->show_pfn)
+				frame = pmd_pfn(pmd) +
+					((addr & ~PMD_MASK) >> PAGE_SHIFT);
 		}
 
 		for (; addr != end; addr += PAGE_SIZE) {
@@ -1073,7 +1076,7 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
 			err = add_to_pagemap(addr, &pme, pm);
 			if (err)
 				break;
-			if (flags & PM_PRESENT)
+			if (pm->show_pfn && (flags & PM_PRESENT))
 				frame++;
 		}
 		spin_unlock(ptl);
@@ -1127,8 +1130,9 @@ static int pagemap_hugetlb_range(pte_t *ptep, unsigned long hmask,
 			flags |= PM_FILE;
 
 		flags |= PM_PRESENT;
-		frame = pte_pfn(pte) +
-			((addr & ~hmask) >> PAGE_SHIFT);
+		if (pm->show_pfn)
+			frame = pte_pfn(pte) +
+				((addr & ~hmask) >> PAGE_SHIFT);
 	}
 
 	for (; addr != end; addr += PAGE_SIZE) {
@@ -1137,7 +1141,7 @@ static int pagemap_hugetlb_range(pte_t *ptep, unsigned long hmask,
 		err = add_to_pagemap(addr, &pme, pm);
 		if (err)
 			return err;
-		if (flags & PM_PRESENT)
+		if (pm->show_pfn && (flags & PM_PRESENT))
 			frame++;
 	}
 
@@ -1196,6 +1200,9 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 	if (!count)
 		goto out_mm;
 
+	/* do not disclose physical addresses: attack vector */
+	pm.show_pfn = file_ns_capable(file, &init_user_ns, CAP_SYS_ADMIN);
+
 	pm.len = (PAGEMAP_WALK_SIZE >> PAGE_SHIFT);
 	pm.buffer = kmalloc(pm.len * PM_ENTRY_BYTES, GFP_TEMPORARY);
 	ret = -ENOMEM;
@@ -1265,10 +1272,6 @@ static int pagemap_open(struct inode *inode, struct file *file)
 {
 	struct mm_struct *mm;
 
-	/* do not disclose physical addresses: attack vector */
-	if (!capable(CAP_SYS_ADMIN))
-		return -EPERM;
-
 	mm = proc_mem_open(inode, PTRACE_MODE_READ);
 	if (IS_ERR(mm))
 		return PTR_ERR(mm);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
