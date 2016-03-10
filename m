Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB89828E1
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 18:55:49 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id 124so80727674pfg.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 15:55:49 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id e69si1448939pfd.66.2016.03.10.15.55.40
        for <linux-mm@kvack.org>;
        Thu, 10 Mar 2016 15:55:40 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v5 05/14] mincore: Add support for PUDs
Date: Thu, 10 Mar 2016 18:55:22 -0500
Message-Id: <1457654131-4562-6-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1457654131-4562-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1457654131-4562-1-git-send-email-matthew.r.wilcox@intel.com>
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
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
