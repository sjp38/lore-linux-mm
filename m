Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0B61C280250
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 11:37:55 -0400 (EDT)
Received: by lahh5 with SMTP id h5so8427670lah.2
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 08:37:54 -0700 (PDT)
Received: from forward-corp1o.mail.yandex.net (forward-corp1o.mail.yandex.net. [2a02:6b8:0:1a2d::1010])
        by mx.google.com with ESMTPS id qo9si1245692lbc.100.2015.07.14.08.37.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 08:37:51 -0700 (PDT)
Subject: [PATCH v4 5/5] pagemap: add mmap-exclusive bit for marking pages
 mapped only here
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 14 Jul 2015 18:37:49 +0300
Message-ID: <20150714153749.29844.81954.stgit@buzz>
In-Reply-To: <20150714152516.29844.69929.stgit@buzz>
References: <20150714152516.29844.69929.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Mark Williamson <mwilliamson@undo-software.com>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

This patch sets bit 56 in pagemap if this page is mapped only once.
It allows to detect exclusively used pages without exposing PFN:

present file exclusive state
0       0    0         non-present
1       1    0         file page mapped somewhere else
1       1    1         file page mapped only here
1       0    0         anon non-CoWed page (shared with parent/child)
1       0    1         anon CoWed page (or never forked)

CoWed pages in (MAP_FILE | MAP_PRIVATE) areas are anon in this context.

MMap-exclusive bit doesn't reflect potential page-sharing via swapcache:
page could be mapped once but has several swap-ptes which point to it.
Application could detect that by swap bit in pagemap entry and touch
that pte via /proc/pid/mem to get real information.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Requested-by: Mark Williamson <mwilliamson@undo-software.com>
Link: http://lkml.kernel.org/r/CAEVpBa+_RyACkhODZrRvQLs80iy0sqpdrd0AaP_-tgnX3Y9yNQ@mail.gmail.com
---
 Documentation/vm/pagemap.txt |    3 ++-
 fs/proc/task_mmu.c           |   14 +++++++++++++-
 tools/vm/page-types.c        |   10 ++++++++++
 3 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
index 6bfbc172cdb9..3cfbbb333ea1 100644
--- a/Documentation/vm/pagemap.txt
+++ b/Documentation/vm/pagemap.txt
@@ -16,7 +16,8 @@ There are three components to pagemap:
     * Bits 0-4   swap type if swapped
     * Bits 5-54  swap offset if swapped
     * Bit  55    pte is soft-dirty (see Documentation/vm/soft-dirty.txt)
-    * Bits 56-60 zero
+    * Bit  56    page exlusively mapped
+    * Bits 57-60 zero
     * Bit  61    page is file-page or shared-anon
     * Bit  62    page swapped
     * Bit  63    page present
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 3a5d338ea219..bac4c97f8ff8 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -947,6 +947,7 @@ struct pagemapread {
 #define PM_PFRAME_BITS		55
 #define PM_PFRAME_MASK		GENMASK_ULL(PM_PFRAME_BITS - 1, 0)
 #define PM_SOFT_DIRTY		BIT_ULL(55)
+#define PM_MMAP_EXCLUSIVE	BIT_ULL(56)
 #define PM_FILE			BIT_ULL(61)
 #define PM_SWAP			BIT_ULL(62)
 #define PM_PRESENT		BIT_ULL(63)
@@ -1034,6 +1035,8 @@ static pagemap_entry_t pte_to_pagemap_entry(struct pagemapread *pm,
 
 	if (page && !PageAnon(page))
 		flags |= PM_FILE;
+	if (page && page_mapcount(page) == 1)
+		flags |= PM_MMAP_EXCLUSIVE;
 	if (vma->vm_flags & VM_SOFTDIRTY)
 		flags |= PM_SOFT_DIRTY;
 
@@ -1064,6 +1067,11 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
 		 * This if-check is just to prepare for future implementation.
 		 */
 		if (pmd_present(pmd)) {
+			struct page *page = pmd_page(pmd);
+
+			if (page_mapcount(page) == 1)
+				flags |= PM_MMAP_EXCLUSIVE;
+
 			flags |= PM_PRESENT;
 			if (pm->show_pfn)
 				frame = pmd_pfn(pmd) +
@@ -1129,6 +1137,9 @@ static int pagemap_hugetlb_range(pte_t *ptep, unsigned long hmask,
 		if (!PageAnon(page))
 			flags |= PM_FILE;
 
+		if (page_mapcount(page) == 1)
+			flags |= PM_MMAP_EXCLUSIVE;
+
 		flags |= PM_PRESENT;
 		if (pm->show_pfn)
 			frame = pte_pfn(pte) +
@@ -1161,7 +1172,8 @@ static int pagemap_hugetlb_range(pte_t *ptep, unsigned long hmask,
  * Bits 0-4   swap type if swapped
  * Bits 5-54  swap offset if swapped
  * Bit  55    pte is soft-dirty (see Documentation/vm/soft-dirty.txt)
- * Bits 56-60 zero
+ * Bit  56    page exclusively mapped
+ * Bits 57-60 zero
  * Bit  61    page is file-page or shared-anon
  * Bit  62    page swapped
  * Bit  63    page present
diff --git a/tools/vm/page-types.c b/tools/vm/page-types.c
index 603ec916716b..7f73fa32a590 100644
--- a/tools/vm/page-types.c
+++ b/tools/vm/page-types.c
@@ -62,6 +62,7 @@
 #define PM_PFRAME_MASK		((1LL << PM_PFRAME_BITS) - 1)
 #define PM_PFRAME(x)		((x) & PM_PFRAME_MASK)
 #define PM_SOFT_DIRTY		(1ULL << 55)
+#define PM_MMAP_EXCLUSIVE	(1ULL << 56)
 #define PM_FILE			(1ULL << 61)
 #define PM_SWAP			(1ULL << 62)
 #define PM_PRESENT		(1ULL << 63)
@@ -91,6 +92,8 @@
 #define KPF_SLOB_FREE		49
 #define KPF_SLUB_FROZEN		50
 #define KPF_SLUB_DEBUG		51
+#define KPF_FILE		62
+#define KPF_MMAP_EXCLUSIVE	63
 
 #define KPF_ALL_BITS		((uint64_t)~0ULL)
 #define KPF_HACKERS_BITS	(0xffffULL << 32)
@@ -140,6 +143,9 @@ static const char * const page_flag_names[] = {
 	[KPF_SLOB_FREE]		= "P:slob_free",
 	[KPF_SLUB_FROZEN]	= "A:slub_frozen",
 	[KPF_SLUB_DEBUG]	= "E:slub_debug",
+
+	[KPF_FILE]		= "F:file",
+	[KPF_MMAP_EXCLUSIVE]	= "1:mmap_exclusive",
 };
 
 
@@ -443,6 +449,10 @@ static uint64_t expand_overloaded_flags(uint64_t flags, uint64_t pme)
 
 	if (pme & PM_SOFT_DIRTY)
 		flags |= BIT(SOFTDIRTY);
+	if (pme & PM_FILE)
+		flags |= BIT(FILE);
+	if (pme & PM_MMAP_EXCLUSIVE)
+		flags |= BIT(MMAP_EXCLUSIVE);
 
 	return flags;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
