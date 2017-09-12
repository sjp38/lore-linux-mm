Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE67F6B026A
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 11:40:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id f84so5671212pfj.0
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 08:40:29 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 184si6704519pfd.583.2017.09.12.08.40.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Sep 2017 08:40:28 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 10/11] mm: Do not loose dirty and access bits in pmdp_invalidate()
Date: Tue, 12 Sep 2017 18:39:40 +0300
Message-Id: <20170912153941.47012-11-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170912153941.47012-1-kirill.shutemov@linux.intel.com>
References: <20170912153941.47012-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>

Vlastimil noted that pmdp_invalidate() is not atomic and we can loose
dirty and access bits if CPU sets them after pmdp dereference, but
before set_pmd_at().

The patch change pmdp_invalidate() to make the entry non-present atomically and
return previous value of the entry. This value can be used to check if
CPU set dirty/accessed bits under us.

The race window is very small and I haven't seen any reports that can be
attributed to the bug. For this reason, I don't think backporting to
stable trees needed.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
---
 include/asm-generic/pgtable.h | 2 +-
 mm/pgtable-generic.c          | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index bf0889eb774d..9df1da175fb0 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -324,7 +324,7 @@ static inline pmd_t generic_pmdp_establish(struct vm_area_struct *vma,
 #endif
 
 #ifndef __HAVE_ARCH_PMDP_INVALIDATE
-extern void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
+extern pmd_t pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 			    pmd_t *pmdp);
 #endif
 
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index 1175f6a24fdb..3db8f2f76666 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -180,12 +180,12 @@ pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 #endif
 
 #ifndef __HAVE_ARCH_PMDP_INVALIDATE
-void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
+pmd_t pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 		     pmd_t *pmdp)
 {
-	pmd_t entry = *pmdp;
-	set_pmd_at(vma->vm_mm, address, pmdp, pmd_mknotpresent(entry));
+	pmd_t old = pmdp_establish(vma, address, pmdp, pmd_mknotpresent(*pmdp));
 	flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+	return old;
 }
 #endif
 
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
