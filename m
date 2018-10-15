Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id B2ED36B000C
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 12:43:00 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id f8-v6so10913521ybn.22
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 09:43:00 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t136-v6si4154912ywe.315.2018.10.15.09.42.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 09:42:59 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9FGeS6h176440
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 12:42:59 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2n4vr2wywd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 12:42:59 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Mon, 15 Oct 2018 17:42:57 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH 2/3] mm: add mm_pxd_folded checks to pgtable_bytes accounting functions
Date: Mon, 15 Oct 2018 18:42:38 +0200
In-Reply-To: <1539621759-5967-1-git-send-email-schwidefsky@de.ibm.com>
References: <1539621759-5967-1-git-send-email-schwidefsky@de.ibm.com>
Message-Id: <1539621759-5967-3-git-send-email-schwidefsky@de.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@redhat.com>, Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>

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

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 include/linux/mm.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index d1029972541c..67f55c71e59a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1764,11 +1764,15 @@ int __pud_alloc(struct mm_struct *mm, p4d_t *p4d, unsigned long address);
 
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
@@ -1788,11 +1792,15 @@ int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address);
 
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
2.16.4
