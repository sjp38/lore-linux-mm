Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id F2B446B0011
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 04:04:01 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id m7so581119wrb.16
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 01:04:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g12si792163edm.553.2018.04.11.01.04.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Apr 2018 01:04:00 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3B83oEH003764
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 04:03:59 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2h9drx1yeg-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 04:03:58 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 11 Apr 2018 09:03:55 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v3 2/2] mm: remove odd HAVE_PTE_SPECIAL
Date: Wed, 11 Apr 2018 10:03:36 +0200
In-Reply-To: <1523433816-14460-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1523433816-14460-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1523433816-14460-3-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>, mhocko@kernel.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Vineet Gupta <vgupta@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, David Rientjes <rientjes@google.com>, Robin Murphy <robin.murphy@arm.com>

Remove the additional define HAVE_PTE_SPECIAL and rely directly on
CONFIG_ARCH_HAS_PTE_SPECIAL.

There is no functional change introduced by this patch

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/memory.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 96910c625daa..7f7dc7b2a341 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -817,17 +817,12 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
  * PFNMAP mappings in order to support COWable mappings.
  *
  */
-#ifdef CONFIG_ARCH_HAS_PTE_SPECIAL
-# define HAVE_PTE_SPECIAL 1
-#else
-# define HAVE_PTE_SPECIAL 0
-#endif
 struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 			     pte_t pte, bool with_public_device)
 {
 	unsigned long pfn = pte_pfn(pte);
 
-	if (HAVE_PTE_SPECIAL) {
+	if (IS_ENABLED(CONFIG_ARCH_HAS_PTE_SPECIAL)) {
 		if (likely(!pte_special(pte)))
 			goto check_pfn;
 		if (vma->vm_ops && vma->vm_ops->find_special_page)
@@ -862,7 +857,7 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 		return NULL;
 	}
 
-	/* !HAVE_PTE_SPECIAL case follows: */
+	/* !CONFIG_ARCH_HAS_PTE_SPECIAL case follows: */
 
 	if (unlikely(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP))) {
 		if (vma->vm_flags & VM_MIXEDMAP) {
@@ -881,7 +876,8 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 
 	if (is_zero_pfn(pfn))
 		return NULL;
-check_pfn:
+
+check_pfn: __maybe_unused
 	if (unlikely(pfn > highest_memmap_pfn)) {
 		print_bad_pte(vma, addr, pte, NULL);
 		return NULL;
@@ -891,7 +887,7 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 	 * NOTE! We still have PageReserved() pages in the page tables.
 	 * eg. VDSO mappings can cause them to exist.
 	 */
-out:
+out: __maybe_unused
 	return pfn_to_page(pfn);
 }
 
@@ -904,7 +900,7 @@ struct page *vm_normal_page_pmd(struct vm_area_struct *vma, unsigned long addr,
 	/*
 	 * There is no pmd_special() but there may be special pmds, e.g.
 	 * in a direct-access (dax) mapping, so let's just replicate the
-	 * !HAVE_PTE_SPECIAL case from vm_normal_page() here.
+	 * !CONFIG_ARCH_HAS_PTE_SPECIAL case from vm_normal_page() here.
 	 */
 	if (unlikely(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP))) {
 		if (vma->vm_flags & VM_MIXEDMAP) {
@@ -1933,7 +1929,8 @@ static int __vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 	 * than insert_pfn).  If a zero_pfn were inserted into a VM_MIXEDMAP
 	 * without pte special, it would there be refcounted as a normal page.
 	 */
-	if (!HAVE_PTE_SPECIAL && !pfn_t_devmap(pfn) && pfn_t_valid(pfn)) {
+	if (!IS_ENABLED(CONFIG_ARCH_HAS_PTE_SPECIAL) &&
+	    !pfn_t_devmap(pfn) && pfn_t_valid(pfn)) {
 		struct page *page;
 
 		/*
-- 
2.7.4
