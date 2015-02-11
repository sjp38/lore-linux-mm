Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1BD446B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 16:04:14 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id x13so6012287wgg.12
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 13:04:13 -0800 (PST)
Received: from mail-wg0-x231.google.com (mail-wg0-x231.google.com. [2a00:1450:400c:c00::231])
        by mx.google.com with ESMTPS id fq13si3324382wjc.186.2015.02.11.13.04.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 13:04:12 -0800 (PST)
Received: by mail-wg0-f49.google.com with SMTP id l18so6065057wgh.8
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 13:04:12 -0800 (PST)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH v2] mm: incorporate zero pages into transparent huge pages
Date: Wed, 11 Feb 2015 23:03:55 +0200
Message-Id: <1423688635-4306-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, riel@redhat.com, aarcange@redhat.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

This patch improves THP collapse rates, by allowing zero pages.

Currently THP can collapse 4kB pages into a THP when there
are up to khugepaged_max_ptes_none pte_none ptes in a 2MB
range.  This patch counts pte none and mapped zero pages
with the same variable.

The patch was tested with a program that allocates 800MB of
memory, and performs interleaved reads and writes, in a pattern
that causes some 2MB areas to first see read accesses, resulting
in the zero pfn being mapped there.

To simulate memory fragmentation at allocation time, I modified
do_huge_pmd_anonymous_page to return VM_FAULT_FALLBACK for read
faults.

Without the patch, only %50 of the program was collapsed into
THP and the percentage did not increase over time.

With this patch after 10 minutes of waiting khugepaged had
collapsed %99 of the program's memory.

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
Changes in v2:
 - Check zero pfn in release_pte_pages() (Andrea Arcangeli)

 mm/huge_memory.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e08e37a..a87a691 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2139,7 +2139,7 @@ static void release_pte_pages(pte_t *pte, pte_t *_pte)
 {
 	while (--_pte >= pte) {
 		pte_t pteval = *_pte;
-		if (!pte_none(pteval))
+		if (!pte_none(pteval) && !is_zero_pfn(pte_pfn(pteval)))
 			release_pte_page(pte_page(pteval));
 	}
 }
@@ -2150,13 +2150,13 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 {
 	struct page *page;
 	pte_t *_pte;
-	int none = 0;
+	int none_or_zero = 0;
 	bool referenced = false, writable = false;
 	for (_pte = pte; _pte < pte+HPAGE_PMD_NR;
 	     _pte++, address += PAGE_SIZE) {
 		pte_t pteval = *_pte;
-		if (pte_none(pteval)) {
-			if (++none <= khugepaged_max_ptes_none)
+		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
+			if (++none_or_zero <= khugepaged_max_ptes_none)
 				continue;
 			else
 				goto out;
@@ -2237,7 +2237,7 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 		pte_t pteval = *_pte;
 		struct page *src_page;
 
-		if (pte_none(pteval)) {
+		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
 			clear_user_highpage(page, address);
 			add_mm_counter(vma->vm_mm, MM_ANONPAGES, 1);
 		} else {
@@ -2573,7 +2573,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 {
 	pmd_t *pmd;
 	pte_t *pte, *_pte;
-	int ret = 0, none = 0;
+	int ret = 0, none_or_zero = 0;
 	struct page *page;
 	unsigned long _address;
 	spinlock_t *ptl;
@@ -2591,8 +2591,8 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	for (_address = address, _pte = pte; _pte < pte+HPAGE_PMD_NR;
 	     _pte++, _address += PAGE_SIZE) {
 		pte_t pteval = *_pte;
-		if (pte_none(pteval)) {
-			if (++none <= khugepaged_max_ptes_none)
+		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
+			if (++none_or_zero <= khugepaged_max_ptes_none)
 				continue;
 			else
 				goto out_unmap;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
