Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id A4E76828E4
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 11:45:25 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id nq2so17878833lbc.3
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 08:45:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p2si36962761wjy.64.2016.06.21.08.45.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Jun 2016 08:45:23 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 2/3] mm: Export follow_pte()
Date: Tue, 21 Jun 2016 17:45:14 +0200
Message-Id: <1466523915-14644-3-git-send-email-jack@suse.cz>
In-Reply-To: <1466523915-14644-1-git-send-email-jack@suse.cz>
References: <1466523915-14644-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>

DAX will need to implement its own version of check_page_address(). To
avoid duplicating page table walking code, export follow_pte() which
does what we need.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/mm.h | 2 ++
 mm/memory.c        | 5 +++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5df5feb49575..989f5d949db3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1193,6 +1193,8 @@ int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
+int follow_pte(struct mm_struct *mm, unsigned long address, pte_t **ptepp,
+	       spinlock_t **ptlp);
 int follow_pfn(struct vm_area_struct *vma, unsigned long address,
 	unsigned long *pfn);
 int follow_phys(struct vm_area_struct *vma, unsigned long address,
diff --git a/mm/memory.c b/mm/memory.c
index 15322b73636b..f6175d63c2e9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3647,8 +3647,8 @@ out:
 	return -EINVAL;
 }
 
-static inline int follow_pte(struct mm_struct *mm, unsigned long address,
-			     pte_t **ptepp, spinlock_t **ptlp)
+int follow_pte(struct mm_struct *mm, unsigned long address, pte_t **ptepp,
+	       spinlock_t **ptlp)
 {
 	int res;
 
@@ -3657,6 +3657,7 @@ static inline int follow_pte(struct mm_struct *mm, unsigned long address,
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
