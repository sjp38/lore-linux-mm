Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C2ADC48BE0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:22:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6E142084B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:22:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6E142084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D8886B0006; Wed, 19 Jun 2019 22:22:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 688AA8E0002; Wed, 19 Jun 2019 22:22:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 577208E0001; Wed, 19 Jun 2019 22:22:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 348266B0006
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:22:09 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id q26so1709571qtr.3
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:22:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=z/BRkRpjiewCe6SWegViWL6WkQmfER7TzQ/dvMV3mmw=;
        b=eIQzwt6cIuaIq/glJitRhngBbkS/vrav2sFUtsjAamcQEDiLV9xVEKW3X/l2zhFEOi
         aPtZ8eCbJ+h0LnFxSv7IXqt0RNRbb/QZ2g3tIVhxIpSM7HD/AMNh0zQsC2ygC0coi4Ki
         rofjzTfqTS3n7nk2W5h4H9+BxTj6pMfUfPbCjsbBn+6HPmub3ck76dPg0vM5+raGuapO
         2Ni7atVILGxH/tQhVpMLAETf7eR1gcv4T9XLyl75XtUt8cUL+oli1Xh8DLhaBm8O4Psp
         ooYK5qM9lJyp/H3lSHWQSO6Tkoz3czu8U4yS1XC4/+P+8OPn9nVY83HEekVWdg3efJgZ
         4ttg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVp9bSNseTsmzwzBTQzRRcbtKpDRKMmYFsyWxGBwKnn/O7V9k8e
	9FZ3Ig516E4IvNU7aQLgoebxAhpA5qE4fVjsxv1ZWgitWOzCWef+bImomsc6aunUkjpdSNunKdi
	DqMQlsKreWa9RxybQ3DPDx9jyT9vNwVq1/FbJ9J8QL5yogkvfME0gBDv86tzou0wL6Q==
X-Received: by 2002:a0c:99d5:: with SMTP id y21mr36664814qve.106.1560997328950;
        Wed, 19 Jun 2019 19:22:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiNpDyS1lC9DiUrZ2EALiDVt3AzqbnQb7HaK31jXELPi2oNUXF1Yz0Waky6YhR/O6dH8OI
X-Received: by 2002:a0c:99d5:: with SMTP id y21mr36664761qve.106.1560997327757;
        Wed, 19 Jun 2019 19:22:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997327; cv=none;
        d=google.com; s=arc-20160816;
        b=AeHq8HNXOI2xlPR+1LNKXPQpk+qT8wue8prutyavGz3NoyhFr8HT6eq/YYBHFTqp04
         A0toNxKJvvT6i+JrZDb3VyJ1e6SMBLGqhGH2ZRk+qyhEDbh1kCIfIsJuhy8y9PdqnG6H
         01Q7GbO8KsDwCnn8XF6CSW2kuzrbM2rGbpEzswOEWow6O7rbVsNXzwZEbKpfTfTpJIsD
         jiYZVfstmlY92nrURgOd3URHKs6DpvQm/MOQDR5/L3fyqaWYEuPtk782LygI43lIEIRG
         WFfuacm2KFPYNMBpsu9Y3tHPgiEFQc7NYBKMRHchNplwN5p/22cN5BVrtX26HDi+EeAG
         Pg4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=z/BRkRpjiewCe6SWegViWL6WkQmfER7TzQ/dvMV3mmw=;
        b=ftHepfXJv050IdxYKisbXlz24ZSPoeRa1y30Ga83Y+hg9Loh0JHRV9velmsr/SBmKP
         SPIjpCE/m01fdIoXGp4rqss1AUcT6MA3ygccXAIvIuvZVhiXqF/k3xUhrXIFBFs/KJCT
         7mWYvDNGJpZffchT81Tpx3CCT2kLVzcSWpl8cOtPK/5LDwkPim8CRG8o2TBuocRXcvK5
         bs2KhPzJrdssxpmlQzTCoZDNyLlnJKuxCbRFvTerSGUS4942jSh3YOFbikmZbhPvhI/E
         L25MnPG+s6ExhJ6+b9hgeETDIqkeO8vR1fN2C8IlBC5lpFgyGxxI3QkvUVcsTPO2mLSB
         XGNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q1si12346426qva.26.2019.06.19.19.22.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:22:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CC35A81F0E;
	Thu, 20 Jun 2019 02:22:06 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 860E31001E69;
	Thu, 20 Jun 2019 02:21:53 +0000 (UTC)
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
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v5 08/25] userfaultfd: wp: add WP pagetable tracking to x86
Date: Thu, 20 Jun 2019 10:19:51 +0800
Message-Id: <20190620022008.19172-9-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 20 Jun 2019 02:22:06 +0000 (UTC)
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
index 2bbbd4d1ba31..3e06f679126d 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -217,6 +217,7 @@ config X86
 	select USER_STACKTRACE_SUPPORT
 	select VIRT_TO_BUS
 	select X86_FEATURE_NAMES		if PROC_FS
+	select HAVE_ARCH_USERFAULTFD_WP		if USERFAULTFD
 
 config INSTRUCTION_DECODER
 	def_bool y
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 5e0509b41986..5b254b851082 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -25,6 +25,7 @@
 #include <asm/x86_init.h>
 #include <asm/fpu/xstate.h>
 #include <asm/fpu/api.h>
+#include <asm-generic/pgtable_uffd.h>
 
 extern pgd_t early_top_pgt[PTRS_PER_PGD];
 int __init __early_make_pgtable(unsigned long address, pmdval_t pmd);
@@ -310,6 +311,23 @@ static inline pte_t pte_clear_flags(pte_t pte, pteval_t clear)
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
@@ -389,6 +407,23 @@ static inline pmd_t pmd_clear_flags(pmd_t pmd, pmdval_t clear)
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
@@ -1371,6 +1406,23 @@ static inline pmd_t pmd_swp_clear_soft_dirty(pmd_t pmd)
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
index 0bb566315621..627666b1c3c0 100644
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
index 75d9d68a6de7..1e979845e1cb 100644
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
index 0e2344389501..763dc7fcf361 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1453,6 +1453,11 @@ config ADVISE_SYSCALLS
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
2.21.0

