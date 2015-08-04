Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 73C7C6B0254
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 15:58:14 -0400 (EDT)
Received: by pacgq8 with SMTP id gq8so15957539pac.3
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 12:58:14 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id x8si815737pde.111.2015.08.04.12.58.12
        for <linux-mm@kvack.org>;
        Tue, 04 Aug 2015 12:58:12 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 03/11] dax: Improve comment about truncate race
Date: Tue,  4 Aug 2015 15:57:57 -0400
Message-Id: <1438718285-21168-4-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

Jan Kara pointed out I should be more explicit here about the perils of
racing against truncate.  The comment is mostly the same as for the PTE
case.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 fs/dax.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/dax.c b/fs/dax.c
index 15f8ffc..0a13118 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -553,7 +553,12 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE)
 		goto fallback;
 
-	/* Guard against a race with truncate */
+	/*
+	 * If a truncate happened while we were allocating blocks, we may
+	 * leave blocks allocated to the file that are beyond EOF.  We can't
+	 * take i_mutex here, so just leave them hanging; they'll be freed
+	 * when the file is deleted.
+	 */
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (pgoff >= size) {
 		result = VM_FAULT_SIGBUS;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
