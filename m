Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id B71096B487D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 09:45:01 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id d11so18292773wrw.4
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 06:45:01 -0800 (PST)
Received: from unicorn.mansr.com (unicorn.mansr.com. [81.2.72.234])
        by mx.google.com with ESMTPS id d9si3119593wrs.133.2018.11.27.06.44.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 06:44:59 -0800 (PST)
From: Mans Rullgard <mans@mansr.com>
Subject: [PATCH] mm: fix insert_pfn() return value
Date: Tue, 27 Nov 2018 14:43:51 +0000
Message-Id: <20181127144351.9137-1-mans@mansr.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Commit 9b5a8e00d479 ("mm: convert insert_pfn() to vm_fault_t") accidentally
made insert_pfn() always return an error.  Fix this.

Fixes: 9b5a8e00d479 ("mm: convert insert_pfn() to vm_fault_t")
Signed-off-by: Mans Rullgard <mans@mansr.com>
---
 mm/memory.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index 4ad2d293ddc2..15baf50e3908 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1524,12 +1524,14 @@ static vm_fault_t insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			pfn_t pfn, pgprot_t prot, bool mkwrite)
 {
 	struct mm_struct *mm = vma->vm_mm;
+	int retval;
 	pte_t *pte, entry;
 	spinlock_t *ptl;
 
 	pte = get_locked_pte(mm, addr, &ptl);
 	if (!pte)
 		return VM_FAULT_OOM;
+	retval = VM_FAULT_NOPAGE;
 	if (!pte_none(*pte)) {
 		if (mkwrite) {
 			/*
@@ -1567,9 +1569,10 @@ static vm_fault_t insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 	set_pte_at(mm, addr, pte, entry);
 	update_mmu_cache(vma, addr, pte); /* XXX: why not for insert_page? */
 
+	retval = 0;
 out_unlock:
 	pte_unmap_unlock(pte, ptl);
-	return VM_FAULT_NOPAGE;
+	return retval;
 }
 
 /**
-- 
2.19.2
