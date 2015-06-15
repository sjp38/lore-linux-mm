Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id DFAED6B0071
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 13:22:23 -0400 (EDT)
Received: by qkdm188 with SMTP id m188so36111352qkd.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 10:22:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k39si13404868qgk.87.2015.06.15.10.22.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 10:22:17 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/7] userfaultfd: propagate the full address in THP faults
Date: Mon, 15 Jun 2015 19:22:06 +0200
Message-Id: <1434388931-24487-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1434388931-24487-1-git-send-email-aarcange@redhat.com>
References: <1434388931-24487-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

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
index 80d4ae1..73eb404 100644
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
