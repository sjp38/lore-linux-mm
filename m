Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 858FD6B006E
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 11:19:00 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id eu11so12373148pac.7
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 08:19:00 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id yb6si2764103pbc.219.2015.02.12.08.18.59
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 08:18:59 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 09/24] thp, mlock: do not allow huge pages in mlocked area
Date: Thu, 12 Feb 2015 18:18:23 +0200
Message-Id: <1423757918-197669-10-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With new refcounting THP can belong to several VMAs. This makes tricky to
tracking THP pages, when they partially mlocked. It can lead to leaking
mlocked pages to non-VM_LOCKED vmas and other problems.

With this patch we will split all pages on mlock and avoid
fault-in/collapse new THP in VM_LOCKED vmas.

I've tried alternative approach: do not mark THP pages mlocked and keep
them on normal LRUs. This way vmscan could try to split huge pages on
memory pressure and free up subpages which doesn't belong to VM_LOCKED
vmas.  But this is user-visible change: we screw up Mlocked accouting
reported in meminfo, so I had to leave this approach aside.

We can bring something better later, but this should be good enough for
now.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 5 ++++-
 mm/mlock.c       | 3 +++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 156f34b9e334..284d1f13247a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -787,6 +787,8 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
 		return VM_FAULT_FALLBACK;
+	if (vma->vm_flags & VM_LOCKED)
+		return VM_FAULT_FALLBACK;
 	if (unlikely(anon_vma_prepare(vma)))
 		return VM_FAULT_OOM;
 	if (unlikely(khugepaged_enter(vma, vma->vm_flags)))
@@ -2553,7 +2555,8 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 	if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
 	    (vma->vm_flags & VM_NOHUGEPAGE))
 		return false;
-
+	if (vma->vm_flags & VM_LOCKED)
+		return false;
 	if (!vma->anon_vma || vma->vm_ops)
 		return false;
 	if (is_vma_temporary_stack(vma))
diff --git a/mm/mlock.c b/mm/mlock.c
index 73cf0987088c..40c6ab590cde 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -238,6 +238,9 @@ long __mlock_vma_pages_range(struct vm_area_struct *vma,
 	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
 
 	gup_flags = FOLL_TOUCH | FOLL_MLOCK;
+	if (vma->vm_flags & VM_LOCKED)
+		gup_flags |= FOLL_SPLIT;
+
 	/*
 	 * We want to touch writable mappings with a write fault in order
 	 * to break COW, except for shared mappings because these don't COW
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
