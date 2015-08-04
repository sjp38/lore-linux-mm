Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 191776B025C
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 15:58:31 -0400 (EDT)
Received: by pdco4 with SMTP id o4so8340575pdc.3
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 12:58:30 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id mx11si801739pbc.120.2015.08.04.12.58.13
        for <linux-mm@kvack.org>;
        Tue, 04 Aug 2015 12:58:14 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 10/11] dax: Ensure that zero pages are removed from other processes
Date: Tue,  4 Aug 2015 15:58:04 -0400
Message-Id: <1438718285-21168-11-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

If the first access to a huge page was a store, there would be no existing
zero pmd in this process's page tables.  There could be a zero pmd in
another process's page tables, if it had done a load.  We can detect this
case by noticing that the buffer_head returned from the filesystem is
New, and ensure that other processes mapping this huge page have their
page tables flushed.

Reported-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 fs/dax.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/dax.c b/fs/dax.c
index bf9a22b..233e61e 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -568,7 +568,11 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	if ((pgoff | PG_PMD_COLOUR) >= size)
 		goto fallback;
 
-	if (is_huge_zero_pmd(*pmd))
+	/*
+	 * If we allocated new storage, make sure no process has any
+	 * zero pages covering this hole
+	 */
+	if (buffer_new(&bh))
 		unmap_mapping_range(mapping, pgoff << PAGE_SHIFT, PMD_SIZE, 0);
 
 	if (!write && !buffer_mapped(&bh) && buffer_uptodate(&bh)) {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
