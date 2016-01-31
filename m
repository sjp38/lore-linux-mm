Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0F9886B0005
	for <linux-mm@kvack.org>; Sun, 31 Jan 2016 07:09:45 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id uo6so67419778pac.1
        for <linux-mm@kvack.org>; Sun, 31 Jan 2016 04:09:45 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id po3si17658441pac.148.2016.01.31.04.09.43
        for <linux-mm@kvack.org>;
        Sun, 31 Jan 2016 04:09:44 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v4 4/8] mincore: Add support for PUDs
Date: Sun, 31 Jan 2016 23:09:31 +1100
Message-Id: <1454242175-16870-5-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1454242175-16870-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1454242175-16870-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

From: Matthew Wilcox <willy@linux.intel.com>

We don't actually care about the contents of the PUD, as long as it's
present (which is checked by the pagewalk code), so just set the bits
to indicate presence and return.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 mm/mincore.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/mm/mincore.c b/mm/mincore.c
index 563f320..948a906 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -108,6 +108,18 @@ static int mincore_unmapped_range(unsigned long addr, unsigned long end,
 	return 0;
 }
 
+static int mincore_pud_range(pud_t *pud, unsigned long addr, unsigned long end,
+			struct mm_walk *walk)
+{
+	unsigned char *vec = walk->private;
+	int nr = (end - addr) >> PAGE_SHIFT;
+
+	memset(vec, 1, nr);
+	walk->private += nr;
+
+	return 0;
+}
+
 static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			struct mm_walk *walk)
 {
@@ -177,6 +189,7 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
 	unsigned long end;
 	int err;
 	struct mm_walk mincore_walk = {
+		.pud_entry = mincore_pud_range,
 		.pmd_entry = mincore_pte_range,
 		.pte_hole = mincore_unmapped_range,
 		.hugetlb_entry = mincore_hugetlb,
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
