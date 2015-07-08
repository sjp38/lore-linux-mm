Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id A927C6B0254
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 06:50:15 -0400 (EDT)
Received: by qget71 with SMTP id t71so97559466qge.2
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 03:50:15 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l80si1632133qkh.114.2015.07.08.03.50.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 03:50:12 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 3/5] userfaultfd: propagate the full address in THP faults
Date: Wed,  8 Jul 2015 12:50:06 +0200
Message-Id: <1436352608-8455-4-git-send-email-aarcange@redhat.com>
In-Reply-To: <1436352608-8455-1-git-send-email-aarcange@redhat.com>
References: <1436352608-8455-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, Dave Hansen <dave.hansen@intel.com>

The THP faults were not propagating the original fault address. The latest
version of the API with uffd.arg.pagefault.address is supposed to propagate the
full address through THP faults.

This was not a kernel crashing bug and it wouldn't risk to corrupt
user memory, but it would cause a SIGBUS failure because the wrong page was
being copied.

For various reasons this wasn't easily reproducible in the qemu
workload, but the strestest exposed the problem immediately.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 68fb507..f9f3337 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -717,13 +717,14 @@ static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
 
 static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 					struct vm_area_struct *vma,
-					unsigned long haddr, pmd_t *pmd,
+					unsigned long address, pmd_t *pmd,
 					struct page *page, gfp_t gfp,
 					unsigned int flags)
 {
 	struct mem_cgroup *memcg;
 	pgtable_t pgtable;
 	spinlock_t *ptl;
+	unsigned long haddr = address & HPAGE_PMD_MASK;
 
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 
@@ -765,7 +766,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 			mem_cgroup_cancel_charge(page, memcg);
 			put_page(page);
 			pte_free(mm, pgtable);
-			ret = handle_userfault(vma, haddr, flags,
+			ret = handle_userfault(vma, address, flags,
 					       VM_UFFD_MISSING);
 			VM_BUG_ON(ret & VM_FAULT_FALLBACK);
 			return ret;
@@ -841,7 +842,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (pmd_none(*pmd)) {
 			if (userfaultfd_missing(vma)) {
 				spin_unlock(ptl);
-				ret = handle_userfault(vma, haddr, flags,
+				ret = handle_userfault(vma, address, flags,
 						       VM_UFFD_MISSING);
 				VM_BUG_ON(ret & VM_FAULT_FALLBACK);
 			} else {
@@ -865,7 +866,8 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
 	}
-	return __do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page, gfp, flags);
+	return __do_huge_pmd_anonymous_page(mm, vma, address, pmd, page, gfp,
+					    flags);
 }
 
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
