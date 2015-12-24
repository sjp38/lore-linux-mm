Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id CAABE82F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 11:20:47 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id cy9so68147984pac.0
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 08:20:47 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id y21si26062305pfi.136.2015.12.24.08.20.44
        for <linux-mm@kvack.org>;
        Thu, 24 Dec 2015 08:20:44 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 2/8] mincore: Add support for PUDs
Date: Thu, 24 Dec 2015 11:20:31 -0500
Message-Id: <1450974037-24775-3-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1450974037-24775-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1450974037-24775-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

From: Matthew Wilcox <willy@linux.intel.com>

We don't actually care about the contents of the PUD, just set the bits
to indicate presence and return.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 mm/mincore.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/mm/mincore.c b/mm/mincore.c
index 2a565ed..8e6ce12 100644
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
@@ -176,6 +188,7 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
 	unsigned long end;
 	int err;
 	struct mm_walk mincore_walk = {
+		.pud_entry = mincore_pud_range,
 		.pmd_entry = mincore_pte_range,
 		.pte_hole = mincore_unmapped_range,
 		.hugetlb_entry = mincore_hugetlb,
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
