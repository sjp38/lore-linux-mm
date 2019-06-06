Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE586C28EB4
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62256208CA
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62256208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D3206B02AB; Thu,  6 Jun 2019 16:15:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00CD96B02AC; Thu,  6 Jun 2019 16:15:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D07CE6B02AE; Thu,  6 Jun 2019 16:15:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0CF6B02AB
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:32 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j21so2064390pff.12
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=wRk/MTtMqNJgo/yn0r5hR9R1CE42aqevhtkVjeiHYFY=;
        b=nEDVgD+UqHKi658Bc6j38ynDf0tHOrRlKu4Z53pjXxxce7XrLqvLkzoGIJnNZij1YB
         T8pcuhKqzQvjztu8PagqN5AgvF+NuWfYo3xgU3EniwtMso8mlQQqAzz8CrGGR5sTjFNY
         fLjS6dR2e4ui/vzqrBud+WNorDCeH/rMtzDMBFcVg/bfIIkMREYSqIfjABHgSHnWZclE
         qmulryEp+5k4fiM+U1/34LbLwEa3RunbcDkqLVAFKKEIZidLjSoHDSeI7iwRd3dFSf7E
         2igmVhQl/6BgYD3Xj4WkG1MDOpayqG8+kCiFtKeUfAhAUPw+QV2hXfm8bLG9B2+X9EoO
         INGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUJHVLEXstcmCbv7LZVQHIK16S4Z1NLSmfH1+S5ywxSh/2xqDJ3
	J0xYGZqQTMT271TtbzwoCxYvgvzMKUR+spDiyqKhuttV1kBhMXY575Xta0au+k1yQZ5qQ96s048
	km6PFoLtSwpqSUOktTyZuZ/Uk0vqTtdUbk9RXskqGmg2ykv6nbm8od8kcS+tnUemOqw==
X-Received: by 2002:a63:285:: with SMTP id 127mr293785pgc.200.1559852132165;
        Thu, 06 Jun 2019 13:15:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxeB4nXCoYpARrozIB9/JO2hPXYtF0mWzN//FpEH5PyCudnXWpBOgWXo6vD0s5zn/mqLLZl
X-Received: by 2002:a63:285:: with SMTP id 127mr293737pgc.200.1559852131302;
        Thu, 06 Jun 2019 13:15:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852131; cv=none;
        d=google.com; s=arc-20160816;
        b=RGivkcJIWKXlOF7uxdny3XaeMx94IpKz92wolzi70rbod6Ezj4pSYj/LYmiPzCLR8U
         b+vicyb9cgjyjupen3wpGcYjoxl30Iz/6a9SQ1ZCu0i9i4Ko6RCzdVd9N5KxXkyMyM3z
         nQFjwbrmDMWUlPm+izwGgNaoQxGYIqZgMvEjEH3pIi0ZT+ZEdktEqtI8AJ1oNv/nl2cE
         W4zuUyDBdzaR2ulPWOTCAppb+Kj7jV3xsZowcYL2iRc3blbSlprSo3ANgQ0d89+ckQTw
         5cjeeIN1Vu1YJ2VtLGsjWobk9yd/WgpCpq3raCdm8PYQ6NyAnuj33GhsxHWGZIfYPPC6
         0QBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=wRk/MTtMqNJgo/yn0r5hR9R1CE42aqevhtkVjeiHYFY=;
        b=aWK9kP/hD0sdMTmTaw+lmi3GoUEnLlOvmv0a3F/lcPQXPrzdM1N2tlS0vvq7q7uAbh
         yWpH7pXJiVs9h3ZbWKl6Vj3FlpwDR+ujYoyT2cS0SEe9mYmwh9waRCeFijncCsK6IW38
         m1H0VpU+Kw+OuE09JOdTV5/nlniZfb/rU7aqu1L7atAR2aQUCT3Mib9Ccjn8ML7suVzz
         DiGuQIcEDyql68EWUBGLJ4k8OS2I5lqSLFf1w+rQzLs4PcN1Cs8khtGUC+VtCG7nig/Y
         En49+6UixhIBwd2gwioAO2amGMekSDB2aP9v8O4bzUwDmsiFWkwlDS013UMGfgB7uNiY
         ChEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id r142si2785300pfc.219.2019.06.06.13.15.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:30 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:29 -0700
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>,
	Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v7 17/27] mm: Update can_follow_write_pte/pmd for shadow stack
Date: Thu,  6 Jun 2019 13:06:36 -0700
Message-Id: <20190606200646.3951-18-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

can_follow_write_pte/pmd look for the (RO & DIRTY) PTE/PMD to
verify an exclusive RO page still exists after a broken COW.

A shadow stack PTE is RO & PAGE_DIRTY_SW when it is shared,
otherwise RO & PAGE_DIRTY_HW.

Introduce pte_exclusive() and pmd_exclusive() to also verify a
shadow stack PTE is exclusive.

Also rename can_follow_write_pte/pmd() to can_follow_write() to
make their meaning clear; i.e. "Can we write to the page?", not
"Is the PTE writable?"

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/mm/pgtable.c         | 18 ++++++++++++++++++
 include/asm-generic/pgtable.h |  4 ++++
 mm/gup.c                      |  8 +++++---
 mm/huge_memory.c              |  8 +++++---
 4 files changed, 32 insertions(+), 6 deletions(-)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 8ff54bd978f3..2a89c168df7b 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -913,4 +913,22 @@ inline bool arch_copy_pte_mapping(vm_flags_t vm_flags)
 {
 	return (vm_flags & VM_SHSTK);
 }
+
+inline bool pte_exclusive(pte_t pte, struct vm_area_struct *vma)
+{
+	if (vma->vm_flags & VM_SHSTK)
+		return pte_dirty_hw(pte);
+	else
+		return pte_dirty(pte);
+}
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+inline bool pmd_exclusive(pmd_t pmd, struct vm_area_struct *vma)
+{
+	if (vma->vm_flags & VM_SHSTK)
+		return pmd_dirty_hw(pmd);
+	else
+		return pmd_dirty(pmd);
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif /* CONFIG_X86_INTEL_SHADOW_STACK_USER */
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 4940411b8e1c..3324e30bb07f 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1192,10 +1192,14 @@ static inline bool arch_has_pfn_modify_check(void)
 #define pte_set_vma_features(pte, vma) pte
 #define pmd_set_vma_features(pmd, vma) pmd
 #define arch_copy_pte_mapping(vma_flags) false
+#define pte_exclusive(pte, vma) pte_dirty(pte)
+#define pmd_exclusive(pmd, vma) pmd_dirty(pmd)
 #else
 pte_t pte_set_vma_features(pte_t pte, struct vm_area_struct *vma);
 pmd_t pmd_set_vma_features(pmd_t pmd, struct vm_area_struct *vma);
 bool arch_copy_pte_mapping(vm_flags_t vm_flags);
+bool pte_exclusive(pte_t pte, struct vm_area_struct *vma);
+bool pmd_exclusive(pmd_t pmd, struct vm_area_struct *vma);
 #endif
 
 #endif /* _ASM_GENERIC_PGTABLE_H */
diff --git a/mm/gup.c b/mm/gup.c
index ddde097cf9e4..7d11fff1e8c3 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -178,10 +178,12 @@ static int follow_pfn_pte(struct vm_area_struct *vma, unsigned long address,
  * FOLL_FORCE can write to even unwritable pte's, but only
  * after we've gone through a COW cycle and they are dirty.
  */
-static inline bool can_follow_write_pte(pte_t pte, unsigned int flags)
+static inline bool can_follow_write(pte_t pte, unsigned int flags,
+				    struct vm_area_struct *vma)
 {
 	return pte_write(pte) ||
-		((flags & FOLL_FORCE) && (flags & FOLL_COW) && pte_dirty(pte));
+		((flags & FOLL_FORCE) && (flags & FOLL_COW) &&
+		 pte_exclusive(pte, vma));
 }
 
 static struct page *follow_page_pte(struct vm_area_struct *vma,
@@ -219,7 +221,7 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 	}
 	if ((flags & FOLL_NUMA) && pte_protnone(pte))
 		goto no_page;
-	if ((flags & FOLL_WRITE) && !can_follow_write_pte(pte, flags)) {
+	if ((flags & FOLL_WRITE) && !can_follow_write(pte, flags, vma)) {
 		pte_unmap_unlock(ptep, ptl);
 		return NULL;
 	}
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index eac1ee2f8985..d65970b9ece6 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1441,10 +1441,12 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
  * FOLL_FORCE can write to even unwritable pmd's, but only
  * after we've gone through a COW cycle and they are dirty.
  */
-static inline bool can_follow_write_pmd(pmd_t pmd, unsigned int flags)
+static inline bool can_follow_write(pmd_t pmd, unsigned int flags,
+				    struct vm_area_struct *vma)
 {
 	return pmd_write(pmd) ||
-	       ((flags & FOLL_FORCE) && (flags & FOLL_COW) && pmd_dirty(pmd));
+	       ((flags & FOLL_FORCE) && (flags & FOLL_COW) &&
+		pmd_exclusive(pmd, vma));
 }
 
 struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
@@ -1457,7 +1459,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 
 	assert_spin_locked(pmd_lockptr(mm, pmd));
 
-	if (flags & FOLL_WRITE && !can_follow_write_pmd(*pmd, flags))
+	if (flags & FOLL_WRITE && !can_follow_write(*pmd, flags, vma))
 		goto out;
 
 	/* Avoid dumping huge zero page */
-- 
2.17.1

