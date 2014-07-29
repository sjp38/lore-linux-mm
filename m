Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 6C08A6B0038
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 07:33:47 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id g10so11617834pdj.1
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 04:33:47 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id 1si10433897pdf.153.2014.07.29.04.33.46
        for <linux-mm@kvack.org>;
        Tue, 29 Jul 2014 04:33:46 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/2] mm: close race between do_fault_around() and fault_around_bytes_set()
Date: Tue, 29 Jul 2014 14:33:28 +0300
Message-Id: <1406633609-17586-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1406633609-17586-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1406633609-17586-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Sasha Levin <sasha.levin@oracle.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Things can go wrong if fault_around_bytes will be changed under
do_fault_around(): between fault_around_mask() and fault_around_pages().

Let's read fault_around_bytes only once during do_fault_around() and
calculate mask based on the reading.

Note: fault_around_bytes can only be updated via debug interface. Also
I've tried but was not able to trigger a bad behaviour without the
patch. So I would not consider this patch as urgent.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 9d66bc66f338..2ce07dc9b52b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2772,12 +2772,12 @@ static unsigned long fault_around_bytes = rounddown_pow_of_two(65536);
 
 static inline unsigned long fault_around_pages(void)
 {
-	return fault_around_bytes >> PAGE_SHIFT;
+	return ACCESS_ONCE(fault_around_bytes) >> PAGE_SHIFT;
 }
 
-static inline unsigned long fault_around_mask(void)
+static inline unsigned long fault_around_mask(unsigned long nr_pages)
 {
-	return ~(fault_around_bytes - 1) & PAGE_MASK;
+	return ~(nr_pages * PAGE_SIZE - 1) & PAGE_MASK;
 }
 
 
@@ -2844,12 +2844,17 @@ late_initcall(fault_around_debugfs);
 static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
 		pte_t *pte, pgoff_t pgoff, unsigned int flags)
 {
-	unsigned long start_addr;
+	unsigned long start_addr, nr_pages;
 	pgoff_t max_pgoff;
 	struct vm_fault vmf;
 	int off;
 
-	start_addr = max(address & fault_around_mask(), vma->vm_start);
+	nr_pages = fault_around_pages();
+	/* race with fault_around_bytes_set() */
+	if (nr_pages <= 1)
+		return;
+
+	start_addr = max(address & fault_around_mask(nr_pages), vma->vm_start);
 	off = ((address - start_addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
 	pte -= off;
 	pgoff -= off;
@@ -2861,7 +2866,7 @@ static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
 	max_pgoff = pgoff - ((start_addr >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)) +
 		PTRS_PER_PTE - 1;
 	max_pgoff = min3(max_pgoff, vma_pages(vma) + vma->vm_pgoff - 1,
-			pgoff + fault_around_pages() - 1);
+			pgoff + nr_pages - 1);
 
 	/* Check if it makes any sense to call ->map_pages */
 	while (!pte_none(*pte)) {
-- 
2.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
