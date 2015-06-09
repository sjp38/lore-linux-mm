Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 163A46B006E
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 16:00:23 -0400 (EDT)
Received: by lbcue7 with SMTP id ue7so16645096lbc.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 13:00:22 -0700 (PDT)
Received: from mail-lb0-x242.google.com (mail-lb0-x242.google.com. [2a00:1450:4010:c04::242])
        by mx.google.com with ESMTPS id q2si6616192laq.102.2015.06.09.13.00.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 13:00:21 -0700 (PDT)
Received: by lbio15 with SMTP id o15so3295900lbi.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 13:00:20 -0700 (PDT)
Subject: [PATCH v3 2/4] pagemap: add mmap-exclusive bit for marking pages
 mapped only here
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Tue, 09 Jun 2015 23:00:17 +0300
Message-ID: <20150609200017.21971.23391.stgit@zurg>
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

This patch sets bit 56 in pagemap if this page is mapped only once.
It allows to detect exclusively used pages without exposing PFN:

present file exclusive state
0       0    0         non-present
1       1    0         file page mapped somewhere else
1       1    1         file page mapped only here
1       0    0         anon non-CoWed page (shared with parent/child)
1       0    1         anon CoWed page (or never forked)

CoWed pages in MAP_FILE|MAP_PRIVATE areas are anon in this context.

Mmap-exclusive bit doesn't reflect potential page-sharing via swapcache:
page could be mapped once but has several swap-ptes which point to it.
Application could detect that by swap bit in pagemap entry and touch
that pte via /proc/pid/mem to get real information.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Link: http://lkml.kernel.org/r/CAEVpBa+_RyACkhODZrRvQLs80iy0sqpdrd0AaP_-tgnX3Y9yNQ@mail.gmail.com

---

v2:
* handle transparent huge pages
* invert bit and rename shared -> exclusive (less confusing name)
---
 Documentation/vm/pagemap.txt |    3 ++-
 fs/proc/task_mmu.c           |   10 ++++++++++
 tools/vm/page-types.c        |   12 ++++++++++++
 3 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
index 6bfbc17..3cfbbb3 100644
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
index 21bc251..b02e38f 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -982,6 +982,7 @@ struct pagemapread {
 #define PM_STATUS2(v2, x)   (__PM_PSHIFT(v2 ? x : PAGE_SHIFT))
 
 #define __PM_SOFT_DIRTY      (1LL)
+#define __PM_MMAP_EXCLUSIVE  (2LL)
 #define PM_PRESENT          PM_STATUS(4LL)
 #define PM_SWAP             PM_STATUS(2LL)
 #define PM_FILE             PM_STATUS(1LL)
@@ -1074,6 +1075,8 @@ static void pte_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *pm,
 
 	if (page && !PageAnon(page))
 		flags |= PM_FILE;
+	if (page && page_mapcount(page) == 1)
+		flags2 |= __PM_MMAP_EXCLUSIVE;
 	if ((vma->vm_flags & VM_SOFTDIRTY))
 		flags2 |= __PM_SOFT_DIRTY;
 
@@ -1119,6 +1122,13 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 		else
 			pmd_flags2 = 0;
 
+		if (pmd_present(*pmd)) {
+			struct page *page = pmd_page(*pmd);
+
+			if (page_mapcount(page) == 1)
+				pmd_flags2 |= __PM_MMAP_EXCLUSIVE;
+		}
+
 		for (; addr != end; addr += PAGE_SIZE) {
 			unsigned long offset;
 			pagemap_entry_t pme;
diff --git a/tools/vm/page-types.c b/tools/vm/page-types.c
index 8bdf16b..3a9f193 100644
--- a/tools/vm/page-types.c
+++ b/tools/vm/page-types.c
@@ -70,9 +70,12 @@
 #define PM_PFRAME(x)        ((x) & PM_PFRAME_MASK)
 
 #define __PM_SOFT_DIRTY      (1LL)
+#define __PM_MMAP_EXCLUSIVE  (2LL)
 #define PM_PRESENT          PM_STATUS(4LL)
 #define PM_SWAP             PM_STATUS(2LL)
+#define PM_FILE             PM_STATUS(1LL)
 #define PM_SOFT_DIRTY       __PM_PSHIFT(__PM_SOFT_DIRTY)
+#define PM_MMAP_EXCLUSIVE   __PM_PSHIFT(__PM_MMAP_EXCLUSIVE)
 
 
 /*
@@ -100,6 +103,8 @@
 #define KPF_SLOB_FREE		49
 #define KPF_SLUB_FROZEN		50
 #define KPF_SLUB_DEBUG		51
+#define KPF_FILE		62
+#define KPF_MMAP_EXCLUSIVE	63
 
 #define KPF_ALL_BITS		((uint64_t)~0ULL)
 #define KPF_HACKERS_BITS	(0xffffULL << 32)
@@ -149,6 +154,9 @@ static const char * const page_flag_names[] = {
 	[KPF_SLOB_FREE]		= "P:slob_free",
 	[KPF_SLUB_FROZEN]	= "A:slub_frozen",
 	[KPF_SLUB_DEBUG]	= "E:slub_debug",
+
+	[KPF_FILE]		= "F:file",
+	[KPF_MMAP_EXCLUSIVE]	= "1:mmap_exclusive",
 };
 
 
@@ -452,6 +460,10 @@ static uint64_t expand_overloaded_flags(uint64_t flags, uint64_t pme)
 
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
