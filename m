Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 45F966B02B7
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:00:14 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id x9so6105187otg.19
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 06:00:14 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n32si3582442otb.32.2018.10.31.06.00.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 06:00:13 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9VCx5mq110152
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:00:12 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2nfbgy46a3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:00:12 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Wed, 31 Oct 2018 13:00:09 -0000
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH 3/4] mm: add mm_pxd_folded checks to pgtable_bytes accounting functions
Date: Wed, 31 Oct 2018 14:00:00 +0100
In-Reply-To: <1540990801-4261-1-git-send-email-schwidefsky@de.ibm.com>
References: <1540990801-4261-1-git-send-email-schwidefsky@de.ibm.com>
Message-Id: <1540990801-4261-4-git-send-email-schwidefsky@de.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@redhat.com>, Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>

The common mm code calls mm_dec_nr_pmds() and mm_dec_nr_puds()
in free_pgtables() if the address range spans a full pud or pmd.
If mm_dec_nr_puds/mm_dec_nr_pmds are non-empty due to configuration
settings they blindly subtract the size of the pmd or pud table from
pgtable_bytes even if the pud or pmd page table layer is folded.

Add explicit mm_[pmd|pud]_folded checks to the four pgtable_bytes
accounting functions mm_inc_nr_puds, mm_inc_nr_pmds, mm_dec_nr_puds
and mm_dec_nr_pmds. As the check for folded page tables can be
overwritten by the architecture, this allows to keep a correct
pgtable_bytes value for platforms that use a dynamic number of
page table levels.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 include/linux/mm.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1e52b8f..844a853 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1744,11 +1744,15 @@ int __pud_alloc(struct mm_struct *mm, p4d_t *p4d, unsigned long address);
 
 static inline void mm_inc_nr_puds(struct mm_struct *mm)
 {
+	if (mm_pud_folded(mm))
+		return;
 	atomic_long_add(PTRS_PER_PUD * sizeof(pud_t), &mm->pgtables_bytes);
 }
 
 static inline void mm_dec_nr_puds(struct mm_struct *mm)
 {
+	if (mm_pud_folded(mm))
+		return;
 	atomic_long_sub(PTRS_PER_PUD * sizeof(pud_t), &mm->pgtables_bytes);
 }
 #endif
@@ -1768,11 +1772,15 @@ int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address);
 
 static inline void mm_inc_nr_pmds(struct mm_struct *mm)
 {
+	if (mm_pmd_folded(mm))
+		return;
 	atomic_long_add(PTRS_PER_PMD * sizeof(pmd_t), &mm->pgtables_bytes);
 }
 
 static inline void mm_dec_nr_pmds(struct mm_struct *mm)
 {
+	if (mm_pmd_folded(mm))
+		return;
 	atomic_long_sub(PTRS_PER_PMD * sizeof(pmd_t), &mm->pgtables_bytes);
 }
 #endif
-- 
2.7.4
