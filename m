Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6DDAD6B0003
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 16:53:05 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id w13-v6so13555652ybm.11
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 13:53:05 -0800 (PST)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id i4-v6sor12392135ybj.85.2018.11.14.13.53.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Nov 2018 13:53:04 -0800 (PST)
Date: Wed, 14 Nov 2018 16:51:53 -0500
In-Reply-To: <20181114215155.259978-1-brho@google.com>
Message-Id: <20181114215155.259978-2-brho@google.com>
Mime-Version: 1.0
References: <20181109203921.178363-1-brho@google.com> <20181114215155.259978-1-brho@google.com>
Subject: [PATCH v2 1/3] mm: make dev_pagemap_mapping_shift() externally visible
From: Barret Rhoden <brho@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, Ross Zwisler <zwisler@kernel.org>, Vishal Verma <vishal.l.verma@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, kvm@vger.kernel.org, yu.c.zhang@intel.com, yi.z.zhang@intel.com, linux-mm@kvack.org, David Hildenbrand <david@redhat.com>

KVM has a use case for determining the size of a dax mapping.  The KVM
code has easy access to the address and the mm; hence the change in
parameters.

Signed-off-by: Barret Rhoden <brho@google.com>
Reviewed-by: David Hildenbrand <david@redhat.com>
---
 include/linux/mm.h  |  3 +++
 mm/memory-failure.c | 38 +++-----------------------------------
 mm/util.c           | 34 ++++++++++++++++++++++++++++++++++
 3 files changed, 40 insertions(+), 35 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5411de93a363..51215d695753 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -935,6 +935,9 @@ static inline bool is_pci_p2pdma_page(const struct page *page)
 }
 #endif /* CONFIG_DEV_PAGEMAP_OPS */
 
+unsigned long dev_pagemap_mapping_shift(unsigned long address,
+					struct mm_struct *mm);
+
 static inline void get_page(struct page *page)
 {
 	page = compound_head(page);
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 0cd3de3550f0..c3f2c6a8607e 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -265,40 +265,6 @@ void shake_page(struct page *p, int access)
 }
 EXPORT_SYMBOL_GPL(shake_page);
 
-static unsigned long dev_pagemap_mapping_shift(struct page *page,
-		struct vm_area_struct *vma)
-{
-	unsigned long address = vma_address(page, vma);
-	pgd_t *pgd;
-	p4d_t *p4d;
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *pte;
-
-	pgd = pgd_offset(vma->vm_mm, address);
-	if (!pgd_present(*pgd))
-		return 0;
-	p4d = p4d_offset(pgd, address);
-	if (!p4d_present(*p4d))
-		return 0;
-	pud = pud_offset(p4d, address);
-	if (!pud_present(*pud))
-		return 0;
-	if (pud_devmap(*pud))
-		return PUD_SHIFT;
-	pmd = pmd_offset(pud, address);
-	if (!pmd_present(*pmd))
-		return 0;
-	if (pmd_devmap(*pmd))
-		return PMD_SHIFT;
-	pte = pte_offset_map(pmd, address);
-	if (!pte_present(*pte))
-		return 0;
-	if (pte_devmap(*pte))
-		return PAGE_SHIFT;
-	return 0;
-}
-
 /*
  * Failure handling: if we can't find or can't kill a process there's
  * not much we can do.	We just print a message and ignore otherwise.
@@ -329,7 +295,9 @@ static void add_to_kill(struct task_struct *tsk, struct page *p,
 	tk->addr = page_address_in_vma(p, vma);
 	tk->addr_valid = 1;
 	if (is_zone_device_page(p))
-		tk->size_shift = dev_pagemap_mapping_shift(p, vma);
+		tk->size_shift =
+			dev_pagemap_mapping_shift(vma_address(page, vma),
+						  vma->vm_mm);
 	else
 		tk->size_shift = compound_order(compound_head(p)) + PAGE_SHIFT;
 
diff --git a/mm/util.c b/mm/util.c
index 8bf08b5b5760..61bc9bab931d 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -780,3 +780,37 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
 out:
 	return res;
 }
+
+unsigned long dev_pagemap_mapping_shift(unsigned long address,
+					struct mm_struct *mm)
+{
+	pgd_t *pgd;
+	p4d_t *p4d;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		return 0;
+	p4d = p4d_offset(pgd, address);
+	if (!p4d_present(*p4d))
+		return 0;
+	pud = pud_offset(p4d, address);
+	if (!pud_present(*pud))
+		return 0;
+	if (pud_devmap(*pud))
+		return PUD_SHIFT;
+	pmd = pmd_offset(pud, address);
+	if (!pmd_present(*pmd))
+		return 0;
+	if (pmd_devmap(*pmd))
+		return PMD_SHIFT;
+	pte = pte_offset_map(pmd, address);
+	if (!pte_present(*pte))
+		return 0;
+	if (pte_devmap(*pte))
+		return PAGE_SHIFT;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(dev_pagemap_mapping_shift);
-- 
2.19.1.1215.g8438c0b245-goog
