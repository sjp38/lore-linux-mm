Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D0ED86B000A
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 09:57:34 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id 20so6112730qkd.2
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 06:57:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o18si480480qtk.140.2018.04.09.06.57.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 06:57:34 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w39DuXw9048550
	for <linux-mm@kvack.org>; Mon, 9 Apr 2018 09:57:33 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h88dubgd4-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Apr 2018 09:57:31 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 9 Apr 2018 14:57:27 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH 2/3] mm: replace __HAVE_ARCH_PTE_SPECIAL
Date: Mon,  9 Apr 2018 15:57:08 +0200
In-Reply-To: <1523282229-20731-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1523282229-20731-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1523282229-20731-3-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>, mhocko@kernel.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Vineet Gupta <vgupta@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

Replace __HAVE_ARCH_PTE_SPECIAL by the new configuration variable
CONFIG_ARCH_HAS_PTE_SPECIAL.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 Documentation/features/vm/pte_special/arch-support.txt | 2 +-
 include/linux/pfn_t.h                                  | 4 ++--
 mm/gup.c                                               | 4 ++--
 mm/memory.c                                            | 2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/Documentation/features/vm/pte_special/arch-support.txt b/Documentation/features/vm/pte_special/arch-support.txt
index 055004f467d2..cd05924ea875 100644
--- a/Documentation/features/vm/pte_special/arch-support.txt
+++ b/Documentation/features/vm/pte_special/arch-support.txt
@@ -1,6 +1,6 @@
 #
 # Feature name:          pte_special
-#         Kconfig:       __HAVE_ARCH_PTE_SPECIAL
+#         Kconfig:       ARCH_HAS_PTE_SPECIAL
 #         description:   arch supports the pte_special()/pte_mkspecial() VM APIs
 #
     -----------------------
diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
index a03c2642a87c..21713dc14ce2 100644
--- a/include/linux/pfn_t.h
+++ b/include/linux/pfn_t.h
@@ -122,7 +122,7 @@ pud_t pud_mkdevmap(pud_t pud);
 #endif
 #endif /* __HAVE_ARCH_PTE_DEVMAP */
 
-#ifdef __HAVE_ARCH_PTE_SPECIAL
+#ifdef CONFIG_ARCH_HAS_PTE_SPECIAL
 static inline bool pfn_t_special(pfn_t pfn)
 {
 	return (pfn.val & PFN_SPECIAL) == PFN_SPECIAL;
@@ -132,5 +132,5 @@ static inline bool pfn_t_special(pfn_t pfn)
 {
 	return false;
 }
-#endif /* __HAVE_ARCH_PTE_SPECIAL */
+#endif /* CONFIG_ARCH_HAS_PTE_SPECIAL */
 #endif /* _LINUX_PFN_T_H_ */
diff --git a/mm/gup.c b/mm/gup.c
index 2e2df7f3e92d..9e6a4f70deab 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1354,7 +1354,7 @@ static void undo_dev_pagemap(int *nr, int nr_start, struct page **pages)
 	}
 }
 
-#ifdef __HAVE_ARCH_PTE_SPECIAL
+#ifdef CONFIG_ARCH_HAS_PTE_SPECIAL
 static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 			 int write, struct page **pages, int *nr)
 {
@@ -1430,7 +1430,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 {
 	return 0;
 }
-#endif /* __HAVE_ARCH_PTE_SPECIAL */
+#endif /* CONFIG_ARCH_HAS_PTE_SPECIAL */
 
 #if defined(__HAVE_ARCH_PTE_DEVMAP) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
 static int __gup_device_huge(unsigned long pfn, unsigned long addr,
diff --git a/mm/memory.c b/mm/memory.c
index 1bb725631ded..6fc7b9edc18f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -817,7 +817,7 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
  * PFNMAP mappings in order to support COWable mappings.
  *
  */
-#ifdef __HAVE_ARCH_PTE_SPECIAL
+#ifdef CONFIG_ARCH_HAS_PTE_SPECIAL
 # define HAVE_PTE_SPECIAL 1
 #else
 # define HAVE_PTE_SPECIAL 0
-- 
2.7.4
