Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4F4CB828E1
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 08:20:10 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p41so72034823lfi.0
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 05:20:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r2si9821071wmd.100.2016.07.22.05.19.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 05:19:51 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 08/15] mm: Export follow_pte()
Date: Fri, 22 Jul 2016 14:19:34 +0200
Message-Id: <1469189981-19000-9-git-send-email-jack@suse.cz>
In-Reply-To: <1469189981-19000-1-git-send-email-jack@suse.cz>
References: <1469189981-19000-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>

DAX will need to implement its own version of page_check_address(). To
avoid duplicating page table walking code, export follow_pte() which
does what we need.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/mm.h | 2 ++
 mm/memory.c        | 5 +++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index d2f2816d78ca..daf690fccc0c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1191,6 +1191,8 @@ int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
+int follow_pte(struct mm_struct *mm, unsigned long address, pte_t **ptepp,
+	       spinlock_t **ptlp);
 int follow_pfn(struct vm_area_struct *vma, unsigned long address,
 	unsigned long *pfn);
 int follow_phys(struct vm_area_struct *vma, unsigned long address,
diff --git a/mm/memory.c b/mm/memory.c
index cfae2d5cc1e0..6780e5d8145c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3635,8 +3635,8 @@ out:
 	return -EINVAL;
 }
 
-static inline int follow_pte(struct mm_struct *mm, unsigned long address,
-			     pte_t **ptepp, spinlock_t **ptlp)
+int follow_pte(struct mm_struct *mm, unsigned long address, pte_t **ptepp,
+	       spinlock_t **ptlp)
 {
 	int res;
 
@@ -3645,6 +3645,7 @@ static inline int follow_pte(struct mm_struct *mm, unsigned long address,
 			   !(res = __follow_pte(mm, address, ptepp, ptlp)));
 	return res;
 }
+EXPORT_SYMBOL(follow_pte);
 
 /**
  * follow_pfn - look up PFN at a user virtual address
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
