Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8329728028D
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 12:08:41 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l132so12165780wmf.0
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 09:08:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bi8si3068916wjb.3.2016.09.27.09.08.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 09:08:34 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 17/20] mm: Export follow_pte()
Date: Tue, 27 Sep 2016 18:08:21 +0200
Message-Id: <1474992504-20133-18-git-send-email-jack@suse.cz>
In-Reply-To: <1474992504-20133-1-git-send-email-jack@suse.cz>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>

DAX will need to implement its own version of page_check_address(). To
avoid duplicating page table walking code, export follow_pte() which
does what we need.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/mm.h | 2 ++
 mm/memory.c        | 4 ++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index e5a014be8932..133fabe4bb4c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1224,6 +1224,8 @@ int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
+int follow_pte(struct mm_struct *mm, unsigned long address, pte_t **ptepp,
+	       spinlock_t **ptlp);
 int follow_pfn(struct vm_area_struct *vma, unsigned long address,
 	unsigned long *pfn);
 int follow_phys(struct vm_area_struct *vma, unsigned long address,
diff --git a/mm/memory.c b/mm/memory.c
index 8c8cb7f2133e..e7a4a30a5e88 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3763,8 +3763,8 @@ out:
 	return -EINVAL;
 }
 
-static inline int follow_pte(struct mm_struct *mm, unsigned long address,
-			     pte_t **ptepp, spinlock_t **ptlp)
+int follow_pte(struct mm_struct *mm, unsigned long address, pte_t **ptepp,
+	       spinlock_t **ptlp)
 {
 	int res;
 
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
