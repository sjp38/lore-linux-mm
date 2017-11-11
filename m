Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B401C440D52
	for <linux-mm@kvack.org>; Sat, 11 Nov 2017 15:20:01 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id r6so10839067pfj.14
        for <linux-mm@kvack.org>; Sat, 11 Nov 2017 12:20:01 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id p11si12334403pfd.118.2017.11.11.12.20.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Nov 2017 12:20:00 -0800 (PST)
Subject: [PATCH v2 2/4] mm: replace pud_write with pud_access_permitted in
 fault + gup paths
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 11 Nov 2017 12:11:44 -0800
Message-ID: <151043110453.2842.2166049702068628177.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151043109403.2842.11607911965674122836.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151043109403.2842.11607911965674122836.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-nvdimm@lists.01.org, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The 'access_permitted' helper is used in the gup-fast path and goes
beyond the simple _PAGE_RW check to also:

* validate that the mapping is writable from a protection keys
  standpoint

* validate that the pte has _PAGE_USER set since all fault paths where
  pud_write is must be referencing user-memory.

Cc: Dave Hansen <dave.hansen@intel.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/s390/include/asm/pgtable.h |    6 ++++++
 arch/sparc/mm/gup.c             |    2 +-
 mm/huge_memory.c                |    2 +-
 mm/memory.c                     |    2 +-
 4 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index d7fe9838084d..1f36a01e22f6 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -1264,6 +1264,12 @@ static inline pud_t pud_mkwrite(pud_t pud)
 	return pud;
 }
 
+#define __HAVE_ARCH_PUD_WRITE
+static inline int pud_write(pud_t pud)
+{
+	return (pud_val(pud) & _REGION3_ENTRY_WRITE) != 0;
+}
+
 static inline pud_t pud_mkclean(pud_t pud)
 {
 	if (pud_large(pud)) {
diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
index 5335ba3c850e..5ae2d0a01a70 100644
--- a/arch/sparc/mm/gup.c
+++ b/arch/sparc/mm/gup.c
@@ -114,7 +114,7 @@ static int gup_huge_pud(pud_t *pudp, pud_t pud, unsigned long addr,
 	if (!(pud_val(pud) & _PAGE_VALID))
 		return 0;
 
-	if (write && !pud_write(pud))
+	if (!pud_access_permitted(pud, write))
 		return 0;
 
 	refs = 0;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1981ed697dab..1e4e11275856 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1022,7 +1022,7 @@ struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
 
 	assert_spin_locked(pud_lockptr(mm, pud));
 
-	if (flags & FOLL_WRITE && !pud_write(*pud))
+	if (!pud_access_permitted(*pud, flags & FOLL_WRITE))
 		return NULL;
 
 	if (pud_present(*pud) && pud_devmap(*pud))
diff --git a/mm/memory.c b/mm/memory.c
index a728bed16c20..64f86beadcca 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3987,7 +3987,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 
 			/* NUMA case for anonymous PUDs would go here */
 
-			if (dirty && !pud_write(orig_pud)) {
+			if (dirty && !pud_access_permitted(orig_pud, WRITE)) {
 				ret = wp_huge_pud(&vmf, orig_pud);
 				if (!(ret & VM_FAULT_FALLBACK))
 					return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
