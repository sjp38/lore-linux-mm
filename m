Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8694E8E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 18:32:32 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id c8-v6so8658024pfn.2
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 15:32:32 -0700 (PDT)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id v13-v6si6053008plo.182.2018.09.28.15.32.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Sep 2018 15:32:29 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH] mm: enforce THP for VM_NOHUGEPAGE dax mappings
Date: Sat, 29 Sep 2018 06:31:56 +0800
Message-Id: <1538173916-95849-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.j.williams@intel.com, jack@suse.cz, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

commit baabda261424517110ea98c6651f632ebf2561e3 ("mm: always enable thp
for dax mappings") says madvise hguepage policy makes less sense for
dax, and force enabling thp for dax mappings in all cases, even though
THP is set to "never".

However, transparent_hugepage_enabled() may return false if
VM_NOHUGEPAGE is set even though the mapping is dax.

So, move is_vma_dax() check to the very beginning to enforce THP for dax
mappings in all cases.

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
I didn't find anyone mention the check should be before VM_NOHUGEPAGE in
the review for Dan's original patch. And, that patch commit log states
clearly that THP for dax mapping for all cases even though THP is never.
So, I'm supposed it should behave in this way.

 include/linux/huge_mm.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 99c19b0..b2ad305 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -95,6 +95,9 @@ extern ssize_t single_hugepage_flag_show(struct kobject *kobj,
 
 static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
 {
+	if (vma_is_dax(vma))
+		return true;
+
 	if (vma->vm_flags & VM_NOHUGEPAGE)
 		return false;
 
@@ -107,9 +110,6 @@ static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
 	if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
 		return true;
 
-	if (vma_is_dax(vma))
-		return true;
-
 	if (transparent_hugepage_flags &
 				(1 << TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG))
 		return !!(vma->vm_flags & VM_HUGEPAGE);
-- 
1.8.3.1
