Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00E05C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:08:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FF42217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:08:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FF42217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B4276B0003; Tue, 19 Mar 2019 22:08:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 463196B0010; Tue, 19 Mar 2019 22:08:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32B5C6B0266; Tue, 19 Mar 2019 22:08:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 04AB26B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:08:02 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id l187so7088245qkd.7
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:08:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=m+XjRxjDS73O4zAA/HG5rtRYNcWXsl8r1Sf9nvtsBIE=;
        b=LQyiTlOO8HFiOI8zvFS+5xLTRv/FI7anCzMJSNMMhFe0seRMfnHXtNDxziLw/1slga
         Y/xpBrGkfNNExoKZBBDuL9F1FjZQ9mo9pcs1DuYIM09WgGdQWdY8x94f64FMQDtL0Kyg
         JXNjJZIdqBQFPNJFdvoicwYpBBWd1XWk7YLA1gjX1K985Ow7ARJ7orkbKJQEHEayQD0B
         lHIPZyx2znQmSbrtPBAx1glVhgZBrXex+CLBNdLc2yojMKKMs6kKh8HftEbQ59UjyQ/P
         I4Xu5iY817f9nGqcp4lUPV40U3hx0vAn9UXYKSBhpCWsCYuk/BmI596ffKJ6epJjb7Ij
         KhLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVP5gL5Nf54VhRa+ZkeO/cdV9m6FlZGzsXmg+fQ0/KFc4R58K3w
	9RcO8kUfiAfTF+pKWS7oBybW83tnZ5BpEe5otrVHyPGl5aOWptTlIC88J2fzL6OxaAt9eDvcu/6
	8nazyHJdvgZ7sWmybbHTCnO81YCBz7yaYqhzCRIKJZBMV8YYtNaigwMm97/Iw66G5ww==
X-Received: by 2002:a0c:c68f:: with SMTP id d15mr4486882qvj.72.1553047681771;
        Tue, 19 Mar 2019 19:08:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSxnV2J+wW7T21LlKhv9e2VrPChQfel3mqMJsm2p5nNtP8tMqMQf7K9oqzgxbUBDc6NcqS
X-Received: by 2002:a0c:c68f:: with SMTP id d15mr4486841qvj.72.1553047680697;
        Tue, 19 Mar 2019 19:08:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047680; cv=none;
        d=google.com; s=arc-20160816;
        b=lOZvWfZPiZt41OPirkvt6qmlcjkt7Pl4dygjfN6O/fLsHpKS+KNRdnwbOIeI6yd2AW
         9yHGT8xl0e8fYpfllWq4jKMaN4a5mmpWxKQOqoAY6uGl9s1TgBMvUb31sddYlKVpTLuh
         VsS6hgn9R8nHHjr07On6BICHW+iEcru4PLGMjjPQwth1VTDHCCzEHC0RgPhnb7XJSFCt
         KPXU9//G3OJCmcfUmbZoZrXodVmaFECuKtuldnXchTq1z5KQ08OuGKRfNoX42FQXwl/1
         CIN0v6e08YE0tdPp1vDOK72EuXq0CeZSowXtPZ2isdCIcxDMu0cLCZ8LwxzcTbZd/R49
         lneA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=m+XjRxjDS73O4zAA/HG5rtRYNcWXsl8r1Sf9nvtsBIE=;
        b=zy6/EKSmjU9CJbaMUZcFHVLYvs7UyHoCmtr4b/CiVs2WH1vwirsrlbRjs/xog4aGKx
         knOigbHe7XtI/MrSlnphYUZxlciE+qhSmyb2Vy0SeYzLSsfiyhAlrPouwy2PqZT3oXAH
         Q63mY+eHvnpbstZuUpH0dwyRD8zTpBcsdZ3x6uQ8cGkdes7votSB1FrtvkICdwjBczOy
         CM47NyAczKbK1Np0Z9LIgkOr+Mxwm5NfQrBw0gHu520mcSQ9L0mc8y/eszMvJe9jBIae
         KfFux+YkFBIngtCI6OOUMmge2CaG+ZsaGvL91YlSp96UvW2XAP8B++vz/ja2spKIuvWI
         e+Hg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x5si298225qkc.121.2019.03.19.19.08.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:08:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CC63583F40;
	Wed, 20 Mar 2019 02:07:59 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E98A96014C;
	Wed, 20 Mar 2019 02:07:51 +0000 (UTC)
From: Peter Xu <peterx@redhat.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	peterx@redhat.com,
	Martin Cracauer <cracauer@cons.org>,
	Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v3 08/28] userfaultfd: wp: add WP pagetable tracking to x86
Date: Wed, 20 Mar 2019 10:06:22 +0800
Message-Id: <20190320020642.4000-9-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 20 Mar 2019 02:07:59 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Accurate userfaultfd WP tracking is possible by tracking exactly which
virtual memory ranges were writeprotected by userland. We can't relay
only on the RW bit of the mapped pagetable because that information is
destroyed by fork() or KSM or swap. If we were to relay on that, we'd
need to stay on the safe side and generate false positive wp faults
for every swapped out page.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
[peterx: append _PAGE_UFD_WP to _PAGE_CHG_MASK]
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 arch/x86/Kconfig                     |  1 +
 arch/x86/include/asm/pgtable.h       | 52 ++++++++++++++++++++++++++++
 arch/x86/include/asm/pgtable_64.h    |  8 ++++-
 arch/x86/include/asm/pgtable_types.h | 11 +++++-
 include/asm-generic/pgtable.h        |  1 +
 include/asm-generic/pgtable_uffd.h   | 51 +++++++++++++++++++++++++++
 init/Kconfig                         |  5 +++
 7 files changed, 127 insertions(+), 2 deletions(-)
 create mode 100644 include/asm-generic/pgtable_uffd.h

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 5a02dd608f74..d2947525907f 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -209,6 +209,7 @@ config X86
 	select USER_STACKTRACE_SUPPORT
 	select VIRT_TO_BUS
 	select X86_FEATURE_NAMES		if PROC_FS
+	select HAVE_ARCH_USERFAULTFD_WP		if USERFAULTFD
 
 config INSTRUCTION_DECODER
 	def_bool y
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 2779ace16d23..6863236e8484 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -23,6 +23,7 @@
 
 #ifndef __ASSEMBLY__
 #include <asm/x86_init.h>
+#include <asm-generic/pgtable_uffd.h>
 
 extern pgd_t early_top_pgt[PTRS_PER_PGD];
 int __init __early_make_pgtable(unsigned long address, pmdval_t pmd);
@@ -293,6 +294,23 @@ static inline pte_t pte_clear_flags(pte_t pte, pteval_t clear)
 	return native_make_pte(v & ~clear);
 }
 
+#ifdef CONFIG_HAVE_ARCH_USERFAULTFD_WP
+static inline int pte_uffd_wp(pte_t pte)
+{
+	return pte_flags(pte) & _PAGE_UFFD_WP;
+}
+
+static inline pte_t pte_mkuffd_wp(pte_t pte)
+{
+	return pte_set_flags(pte, _PAGE_UFFD_WP);
+}
+
+static inline pte_t pte_clear_uffd_wp(pte_t pte)
+{
+	return pte_clear_flags(pte, _PAGE_UFFD_WP);
+}
+#endif /* CONFIG_HAVE_ARCH_USERFAULTFD_WP */
+
 static inline pte_t pte_mkclean(pte_t pte)
 {
 	return pte_clear_flags(pte, _PAGE_DIRTY);
@@ -372,6 +390,23 @@ static inline pmd_t pmd_clear_flags(pmd_t pmd, pmdval_t clear)
 	return native_make_pmd(v & ~clear);
 }
 
+#ifdef CONFIG_HAVE_ARCH_USERFAULTFD_WP
+static inline int pmd_uffd_wp(pmd_t pmd)
+{
+	return pmd_flags(pmd) & _PAGE_UFFD_WP;
+}
+
+static inline pmd_t pmd_mkuffd_wp(pmd_t pmd)
+{
+	return pmd_set_flags(pmd, _PAGE_UFFD_WP);
+}
+
+static inline pmd_t pmd_clear_uffd_wp(pmd_t pmd)
+{
+	return pmd_clear_flags(pmd, _PAGE_UFFD_WP);
+}
+#endif /* CONFIG_HAVE_ARCH_USERFAULTFD_WP */
+
 static inline pmd_t pmd_mkold(pmd_t pmd)
 {
 	return pmd_clear_flags(pmd, _PAGE_ACCESSED);
@@ -1351,6 +1386,23 @@ static inline pmd_t pmd_swp_clear_soft_dirty(pmd_t pmd)
 #endif
 #endif
 
+#ifdef CONFIG_HAVE_ARCH_USERFAULTFD_WP
+static inline pte_t pte_swp_mkuffd_wp(pte_t pte)
+{
+	return pte_set_flags(pte, _PAGE_SWP_UFFD_WP);
+}
+
+static inline int pte_swp_uffd_wp(pte_t pte)
+{
+	return pte_flags(pte) & _PAGE_SWP_UFFD_WP;
+}
+
+static inline pte_t pte_swp_clear_uffd_wp(pte_t pte)
+{
+	return pte_clear_flags(pte, _PAGE_SWP_UFFD_WP);
+}
+#endif /* CONFIG_HAVE_ARCH_USERFAULTFD_WP */
+
 #define PKRU_AD_BIT 0x1
 #define PKRU_WD_BIT 0x2
 #define PKRU_BITS_PER_PKEY 2
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 9c85b54bf03c..e0c5d29b8685 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -189,7 +189,7 @@ extern void sync_global_pgds(unsigned long start, unsigned long end);
  *
  * |     ...            | 11| 10|  9|8|7|6|5| 4| 3|2| 1|0| <- bit number
  * |     ...            |SW3|SW2|SW1|G|L|D|A|CD|WT|U| W|P| <- bit names
- * | TYPE (59-63) | ~OFFSET (9-58)  |0|0|X|X| X| X|X|SD|0| <- swp entry
+ * | TYPE (59-63) | ~OFFSET (9-58)  |0|0|X|X| X| X|F|SD|0| <- swp entry
  *
  * G (8) is aliased and used as a PROT_NONE indicator for
  * !present ptes.  We need to start storing swap entries above
@@ -197,9 +197,15 @@ extern void sync_global_pgds(unsigned long start, unsigned long end);
  * erratum where they can be incorrectly set by hardware on
  * non-present PTEs.
  *
+ * SD Bits 1-4 are not used in non-present format and available for
+ * special use described below:
+ *
  * SD (1) in swp entry is used to store soft dirty bit, which helps us
  * remember soft dirty over page migration
  *
+ * F (2) in swp entry is used to record when a pagetable is
+ * writeprotected by userfaultfd WP support.
+ *
  * Bit 7 in swp entry should be 0 because pmd_present checks not only P,
  * but also L and G.
  *
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index d6ff0bbdb394..dd9c6295d610 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -32,6 +32,7 @@
 
 #define _PAGE_BIT_SPECIAL	_PAGE_BIT_SOFTW1
 #define _PAGE_BIT_CPA_TEST	_PAGE_BIT_SOFTW1
+#define _PAGE_BIT_UFFD_WP	_PAGE_BIT_SOFTW2 /* userfaultfd wrprotected */
 #define _PAGE_BIT_SOFT_DIRTY	_PAGE_BIT_SOFTW3 /* software dirty tracking */
 #define _PAGE_BIT_DEVMAP	_PAGE_BIT_SOFTW4
 
@@ -100,6 +101,14 @@
 #define _PAGE_SWP_SOFT_DIRTY	(_AT(pteval_t, 0))
 #endif
 
+#ifdef CONFIG_HAVE_ARCH_USERFAULTFD_WP
+#define _PAGE_UFFD_WP		(_AT(pteval_t, 1) << _PAGE_BIT_UFFD_WP)
+#define _PAGE_SWP_UFFD_WP	_PAGE_USER
+#else
+#define _PAGE_UFFD_WP		(_AT(pteval_t, 0))
+#define _PAGE_SWP_UFFD_WP	(_AT(pteval_t, 0))
+#endif
+
 #if defined(CONFIG_X86_64) || defined(CONFIG_X86_PAE)
 #define _PAGE_NX	(_AT(pteval_t, 1) << _PAGE_BIT_NX)
 #define _PAGE_DEVMAP	(_AT(u64, 1) << _PAGE_BIT_DEVMAP)
@@ -124,7 +133,7 @@
  */
 #define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
 			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
-			 _PAGE_SOFT_DIRTY | _PAGE_DEVMAP)
+			 _PAGE_SOFT_DIRTY | _PAGE_DEVMAP | _PAGE_UFFD_WP)
 #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)
 
 /*
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 05e61e6c843f..f49afe951711 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -10,6 +10,7 @@
 #include <linux/mm_types.h>
 #include <linux/bug.h>
 #include <linux/errno.h>
+#include <asm-generic/pgtable_uffd.h>
 
 #if 5 - defined(__PAGETABLE_P4D_FOLDED) - defined(__PAGETABLE_PUD_FOLDED) - \
 	defined(__PAGETABLE_PMD_FOLDED) != CONFIG_PGTABLE_LEVELS
diff --git a/include/asm-generic/pgtable_uffd.h b/include/asm-generic/pgtable_uffd.h
new file mode 100644
index 000000000000..643d1bf559c2
--- /dev/null
+++ b/include/asm-generic/pgtable_uffd.h
@@ -0,0 +1,51 @@
+#ifndef _ASM_GENERIC_PGTABLE_UFFD_H
+#define _ASM_GENERIC_PGTABLE_UFFD_H
+
+#ifndef CONFIG_HAVE_ARCH_USERFAULTFD_WP
+static __always_inline int pte_uffd_wp(pte_t pte)
+{
+	return 0;
+}
+
+static __always_inline int pmd_uffd_wp(pmd_t pmd)
+{
+	return 0;
+}
+
+static __always_inline pte_t pte_mkuffd_wp(pte_t pte)
+{
+	return pte;
+}
+
+static __always_inline pmd_t pmd_mkuffd_wp(pmd_t pmd)
+{
+	return pmd;
+}
+
+static __always_inline pte_t pte_clear_uffd_wp(pte_t pte)
+{
+	return pte;
+}
+
+static __always_inline pmd_t pmd_clear_uffd_wp(pmd_t pmd)
+{
+	return pmd;
+}
+
+static __always_inline pte_t pte_swp_mkuffd_wp(pte_t pte)
+{
+	return pte;
+}
+
+static __always_inline int pte_swp_uffd_wp(pte_t pte)
+{
+	return 0;
+}
+
+static __always_inline pte_t pte_swp_clear_uffd_wp(pte_t pte)
+{
+	return pte;
+}
+#endif /* CONFIG_HAVE_ARCH_USERFAULTFD_WP */
+
+#endif /* _ASM_GENERIC_PGTABLE_UFFD_H */
diff --git a/init/Kconfig b/init/Kconfig
index c9386a365eea..892d61ddf2eb 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1424,6 +1424,11 @@ config ADVISE_SYSCALLS
 	  applications use these syscalls, you can disable this option to save
 	  space.
 
+config HAVE_ARCH_USERFAULTFD_WP
+	bool
+	help
+	  Arch has userfaultfd write protection support
+
 config MEMBARRIER
 	bool "Enable membarrier() system call" if EXPERT
 	default y
-- 
2.17.1

