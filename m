Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id CCE796B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 02:09:44 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so51462251pac.2
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 23:09:44 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id mn5si836915pbc.105.2015.08.27.23.09.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 23:09:43 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [PATCH 04/11] ARCv2: mm: THP support
Date: Fri, 28 Aug 2015 06:09:37 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075CFB86BEE@IN01WEMBXB.internal.synopsys.com>
References: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
 <1440666194-21478-5-git-send-email-vgupta@synopsys.com>
 <20150827153254.GA21103@node.dhcp.inet.fi>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew
 Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "arc-linux-dev@synopsys.com" <arc-linux-dev@synopsys.com>

On Thursday 27 August 2015 09:03 PM, Kirill A. Shutemov wrote:=0A=
> On Thu, Aug 27, 2015 at 02:33:07PM +0530, Vineet Gupta wrote:=0A=
>> +pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp=
)=0A=
>> +{=0A=
>> +	struct list_head *lh;=0A=
>> +	pgtable_t pgtable;=0A=
>> +	pte_t *ptep;=0A=
>> +=0A=
>> +	assert_spin_locked(&mm->page_table_lock);=0A=
>> +=0A=
>> +	pgtable =3D pmd_huge_pte(mm, pmdp);=0A=
>> +	lh =3D (struct list_head *) pgtable;=0A=
>> +	if (list_empty(lh))=0A=
>> +		pmd_huge_pte(mm, pmdp) =3D (pgtable_t) NULL;=0A=
>> +	else {=0A=
>> +		pmd_huge_pte(mm, pmdp) =3D (pgtable_t) lh->next;=0A=
>> +		list_del(lh);=0A=
>> +	}=0A=
> Side question: why pgtable_t is unsigned long on ARC and not struct page =
*=0A=
> or pte_t *, like on other archs? We could avoid these casts.=0A=
=0A=
Well we avoid some and add some, but I agree that it is better as pte_t *=
=0A=
=0A=
-------------->=0A=
>From 7170a998bd4d5014ade94f4e5ba979c929d1ee18 Mon Sep 17 00:00:00 2001=0A=
From: Vineet Gupta <vgupta@synopsys.com>=0A=
Date: Fri, 28 Aug 2015 08:39:57 +0530=0A=
Subject: [PATCH] ARC: mm: switch pgtable_to to pte_t *=0A=
=0A=
ARC is the only arch with unsigned long type (vs. struct page *).=0A=
Historically this was done to avoid the page_address() calls in various=0A=
arch hooks which need to get the virtual/logical address of the table.=0A=
=0A=
Some arches alternately define it as pte_t *, and is as efficient as=0A=
unsigned long (generated code doesn't change)=0A=
=0A=
Suggested-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>=0A=
Signed-off-by: Vineet Gupta <vgupta@synopsys.com>=0A=
---=0A=
 arch/arc/include/asm/page.h    | 4 ++--=0A=
 arch/arc/include/asm/pgalloc.h | 6 +++---=0A=
 2 files changed, 5 insertions(+), 5 deletions(-)=0A=
=0A=
diff --git a/arch/arc/include/asm/page.h b/arch/arc/include/asm/page.h=0A=
index 9c8aa41e45c2..2994cac1069e 100644=0A=
--- a/arch/arc/include/asm/page.h=0A=
+++ b/arch/arc/include/asm/page.h=0A=
@@ -43,7 +43,6 @@ typedef struct {=0A=
 typedef struct {=0A=
     unsigned long pgprot;=0A=
 } pgprot_t;=0A=
-typedef unsigned long pgtable_t;=0A=
 =0A=
 #define pte_val(x)      ((x).pte)=0A=
 #define pgd_val(x)      ((x).pgd)=0A=
@@ -60,7 +59,6 @@ typedef unsigned long pgtable_t;=0A=
 typedef unsigned long pte_t;=0A=
 typedef unsigned long pgd_t;=0A=
 typedef unsigned long pgprot_t;=0A=
-typedef unsigned long pgtable_t;=0A=
 =0A=
 #define pte_val(x)    (x)=0A=
 #define pgd_val(x)    (x)=0A=
@@ -71,6 +69,8 @@ typedef unsigned long pgtable_t;=0A=
 =0A=
 #endif=0A=
 =0A=
+typedef pte_t * pgtable_t;=0A=
+=0A=
 #define ARCH_PFN_OFFSET     (CONFIG_LINUX_LINK_BASE >> PAGE_SHIFT)=0A=
 =0A=
 #define pfn_valid(pfn)      (((pfn) - ARCH_PFN_OFFSET) < max_mapnr)=0A=
diff --git a/arch/arc/include/asm/pgalloc.h b/arch/arc/include/asm/pgalloc.=
h=0A=
index 81208bfd9dcb..9149b5ca26d7 100644=0A=
--- a/arch/arc/include/asm/pgalloc.h=0A=
+++ b/arch/arc/include/asm/pgalloc.h=0A=
@@ -107,7 +107,7 @@ pte_alloc_one(struct mm_struct *mm, unsigned long addre=
ss)=0A=
     pgtable_t pte_pg;=0A=
     struct page *page;=0A=
 =0A=
-    pte_pg =3D __get_free_pages(GFP_KERNEL | __GFP_REPEAT, __get_order_pte=
());=0A=
+    pte_pg =3D (pgtable_t)__get_free_pages(GFP_KERNEL | __GFP_REPEAT,=0A=
__get_order_pte());=0A=
     if (!pte_pg)=0A=
         return 0;=0A=
     memzero((void *)pte_pg, PTRS_PER_PTE * 4);=0A=
@@ -128,12 +128,12 @@ static inline void pte_free_kernel(struct mm_struct *=
mm,=0A=
pte_t *pte)=0A=
 static inline void pte_free(struct mm_struct *mm, pgtable_t ptep)=0A=
 {=0A=
     pgtable_page_dtor(virt_to_page(ptep));=0A=
-    free_pages(ptep, __get_order_pte());=0A=
+    free_pages((unsigned long)ptep, __get_order_pte());=0A=
 }=0A=
 =0A=
 #define __pte_free_tlb(tlb, pte, addr)  pte_free((tlb)->mm, pte)=0A=
 =0A=
 #define check_pgt_cache()   do { } while (0)=0A=
-#define pmd_pgtable(pmd) pmd_page_vaddr(pmd)=0A=
+#define pmd_pgtable(pmd)    ((pgtable_t) pmd_page_vaddr(pmd))=0A=
 =0A=
 #endif /* _ASM_ARC_PGALLOC_H */=0A=
-- =0A=
1.9.1=0A=
=0A=
=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
