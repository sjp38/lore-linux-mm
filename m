Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 658B3C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:53:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1ED492077B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:53:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1ED492077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3CE06B0007; Fri, 26 Apr 2019 00:53:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AECFF6B026E; Fri, 26 Apr 2019 00:53:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BEB86B0007; Fri, 26 Apr 2019 00:53:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 797D86B0007
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:53:18 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 207so1857227qkn.5
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:53:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=6LEoQf2iQS+qIvCfeSdroHAv9oHURBm5B7WiNRfkEUw=;
        b=rbkxvkFR0HTB1agpNxqzlwd4ZQabi5MbGP5bt813nAGyAa/suy55sgf1YHlF+dCqPw
         6FG7hCHIWFlIOV6mGre8YBwSZllL9jrrfYXw1IWkpHhXb+45NqQA4oyST1xLJhYonSYi
         Zoe7Ov3MUpqXPhngDLKd0RGq8IKCurRPylbfXR00nEt6Z1z187I2MJ3NVlzHsvwsjLsm
         r/IAvgVu4JaYGelENP6JapXgj9hZWdhwneabgX2xl01BouYIF6IAtIEa1DofuXaNdTF3
         OQHRz00fo5zDo7Hbw6wFcOphzAF3dV5abmca8d+2LowP6RfnC9v7BHZ356txkCxNVxa4
         8CWw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVw0RwdpynzsmiJ7OrH656GbgmP1UQX+RTy4ard2+SZ2An1CG0T
	8qIZqAs7bum9i+Y4ibu2P4kuGYaPEJWSvLmIqrw4OlRJgq6N6qrvHtt6/3YgirQlTOAoehAqHk+
	ltCXl7oq2fGzmcC1Ap6WcQVcLLAGKRvR5cwYHuhmSil+B7JElHC3TULVauzNlcThlhA==
X-Received: by 2002:a37:4896:: with SMTP id v144mr32076057qka.194.1556254398248;
        Thu, 25 Apr 2019 21:53:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzetQOrbCxH8kfUNJutePulymHVcJtITmcngu9//GpFbMurOsfWz7fo2O9Qb31fpbDUhxvL
X-Received: by 2002:a37:4896:: with SMTP id v144mr32076029qka.194.1556254397360;
        Thu, 25 Apr 2019 21:53:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254397; cv=none;
        d=google.com; s=arc-20160816;
        b=zGTab0rQWA/Bek9/Ph9Bymh2XlWLN5phz6/Hn4OM5WIGMtiAKBNBBid3fRmdfeQclD
         GAtESsv7l1OQ4/Gbon7EZEX4VOuVMbpj70LvHK+Z1RBgFlXvtCN5oBbuLf3cudxDaGIO
         x/gbdd958lmFhVp+5TbtcUz2Sq+DsEXWLOZMNo3YwwXAOShh11aFoKyKeDFbglzhZKeQ
         O49MozgWvldbJg9VQhLI0p5XCeIY47YGDWMmKzesYAQYDWzdXXbK83EHPhYSZtenUJCr
         /T7Q/hcVB/h9uE2tVHRKU95ygkdOu5wh19/r5Sj+PAB2bEPFSPHuO+whs5CWVqWaXe2w
         q88w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=6LEoQf2iQS+qIvCfeSdroHAv9oHURBm5B7WiNRfkEUw=;
        b=a/MlwTbWLbDgbw4GmHm+FpdXuue5AcqUAaNcsajsUwh9QTEh8wksk4h+gvly0JYhfF
         eXHTPRml8VQCKMxIPikWpKWIRIHcQsJQj+BmQmrjIi6VKRgRW1zJ3aaxQ/1YbeLQNooR
         AfQowtY6so+EHbo3VwOeVMF+YIk+e5iUC+zMrsW2p2DgUftQmghrR+M94uPydP3lB1RQ
         X/tXvnPTJ+E1YCwLtbdKm63OVYNmvHXRs0mx+10Ra/rdh5wLzudHEbPGP8ntduOr1eNi
         tQK4Q1z8N+vKXRBkFes1AwHYl7m8p67yecgTi47vY8BNiAz6NZ/u72MIN4twsG6yVd4X
         mjwA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t46si455467qta.282.2019.04.25.21.53.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:53:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 719ED2DA988;
	Fri, 26 Apr 2019 04:53:16 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D38D717B21;
	Fri, 26 Apr 2019 04:53:10 +0000 (UTC)
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
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v4 08/27] userfaultfd: wp: add WP pagetable tracking to x86
Date: Fri, 26 Apr 2019 12:51:32 +0800
Message-Id: <20190426045151.19556-9-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Fri, 26 Apr 2019 04:53:16 +0000 (UTC)
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
index 5ad92419be19..70d369fe08d7 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -208,6 +208,7 @@ config X86
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
index fa782fba51ee..39e4122b667b 100644
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
index 4592bf7997c0..76550307948a 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1451,6 +1451,11 @@ config ADVISE_SYSCALLS
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

