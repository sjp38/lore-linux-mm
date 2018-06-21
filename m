Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2E06B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 19:16:15 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id w23-v6so1821050pgv.1
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 16:16:15 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id x6-v6si5710020pln.486.2018.06.21.16.16.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 16:16:14 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [v2 PATCH 1/2] mm: thp: register mm for khugepaged when merging vma for shmem
Date: Fri, 22 Jun 2018 07:15:48 +0800
Message-Id: <1529622949-75504-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When merging anonymous page vma, if the size of vma can fit in at least
one hugepage, the mm will be registered for khugepaged for collapsing
THP in the future.

But, it skips shmem vma. Doing so for shmem too, but not file-private
mapping, when merging vma in order to increase the odd to collapse
hugepage by khugepaged.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
---
v1 --> 2:
* Exclude file-private mapping per Kirill's comment

 mm/khugepaged.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index d7b2a4b..9b0ec30 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -440,8 +440,12 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
 		 * page fault if needed.
 		 */
 		return 0;
-	if (vma->vm_ops || (vm_flags & VM_NO_KHUGEPAGED))
-		/* khugepaged not yet working on file or special mappings */
+	if ((vma->vm_ops && (!shmem_file(vma->vm_file) || vma->anon_vma)) ||
+	    (vm_flags & VM_NO_KHUGEPAGED))
+		/*
+		 * khugepaged not yet working on non-shmem file or special
+		 * mappings. And, file-private shmem THP is not supported.
+		 */
 		return 0;
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
-- 
1.8.3.1
