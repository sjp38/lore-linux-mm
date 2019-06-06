Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1B44C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 674E6208CA
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 674E6208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84AE36B02A8; Thu,  6 Jun 2019 16:15:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D6C76B02AB; Thu,  6 Jun 2019 16:15:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6768B6B02A8; Thu,  6 Jun 2019 16:15:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB896B02A8
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:31 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d19so2184353pls.1
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=wTis/tBUSVnfnxqsMN3VsGqgVPF5X8eJdrNigljA9pg=;
        b=AApvlGjcpSK5lEgGaBgUtYIHv2U1zaGY+LvU3suRTb9Tw2KJRpGSeJK7qQEIep/kkk
         oD0Ur6UwWrr0P5zkLzbwDf11XoKDqjT0dmPh3V+GlcbeIrHKnhl2ICH1/GvWbbxc1Yoo
         G0JZu4nQxPASpTpVjV195o8G5DSnWLMlxn5URXj87TVTYB+0SnFqR7ktJWmo4BCdKOzK
         Jfi0Ud5KtHVcsgukSOCrDgYQhxcDvEYyGTAco7/aQac6BWi4grv8GiAmvV/p2VRwGQ+O
         VuH9S8u3oWW0CcCEJstr49WKxNmFIH1IcgX4cOsSHRBKuVkSY3ZbwTZJaCSHGOntDTzD
         6Hfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUVvD7Jj3Gi9IeQvTicKXwVGd+68ooZNzy9v1C2duAjy1Uu9oV9
	lmyoPoONhCt289MjrAgLiyFIn3wMj31ewDLYVr8bUHikdvlmUp0ZwYnL7oTn/gRg9uMfmkGaFNZ
	OsDcyIXdWzVYv8Cu6ArB/9FIqAHlDZ4jGhwFbDeytjGcquJpyBv60+eCar69N7scPUQ==
X-Received: by 2002:a17:90a:a608:: with SMTP id c8mr1569319pjq.37.1559852130730;
        Thu, 06 Jun 2019 13:15:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhMY+wvibVgWXRC6e7tqsqNZQ7xxK4HNEaGIKx+5AFRqJP3Kuu6EdDlLLnMlp0APQ2808T
X-Received: by 2002:a17:90a:a608:: with SMTP id c8mr1569260pjq.37.1559852130000;
        Thu, 06 Jun 2019 13:15:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852129; cv=none;
        d=google.com; s=arc-20160816;
        b=GXoATEyjA7eE0T8Mo9c5kZj1g2DXSmNIG2GT2mKOlvWlFS4ta7PtrFBw91CvyRT9vP
         47DWim1k/x9PG5qr+LMG+DOI7ZxpRztii8FVm1ezPjCzEJD3hfdyqRjYqChEtFK9Vd5V
         oX/Sr0JGrsP2ns3nW/VOSwcRCNcit5ARKYKRvBesqRHPtONyipTKHIomhkwgYNbcFNZM
         eu+JXM626DioFlg7sb3tPrGcK5uznxV5CslwNlwD9gLQlMu6OwC6f4QK3d7HBDTh0seg
         CLBaFrOi6edfyT/5MuNXek731jnvv8S4Y6p4/hLjMRft6cbaNg/mPWaXSgaIZH+QQBRm
         pueg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=wTis/tBUSVnfnxqsMN3VsGqgVPF5X8eJdrNigljA9pg=;
        b=N9jErH1ezpIm63pgkS8GrAqPK8bhJtQtw4YXtXiRax0FuSD3yseruQ53eGQgCT6xMn
         dKNcdDCKt6+7rY6WyU/tkezCXLTJG35RmtgYcUGnh03b447/UFWWp/K8CYI2YiWMuCM2
         AdnG8giojqlBJbfvUXRbfujcQo2NekVCZKe8RyrgKMpKiGEUa5+GkmBTLgWUke6LZzNY
         TgTX+PvDMSyg2RdzKMWLIKXJ7AZggBlGqz0lYDMoo5IFiPKf26RgTsXqR/oL0wyb9oKN
         ZlfjaUKXpcs6FXT1aUu7eIjboxEzIZ0BfM8SU1v3yHThCx0JzQ6xIiapiwpYHMe0lKZr
         v/Kg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id r142si2785300pfc.219.2019.06.06.13.15.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:29 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:28 -0700
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
Subject: [PATCH v7 16/27] mm: Handle THP/HugeTLB shadow stack page fault
Date: Thu,  6 Jun 2019 13:06:35 -0700
Message-Id: <20190606200646.3951-17-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch implements THP shadow stack (SHSTK) copying in the same
way as in the previous patch for regular PTE.

In copy_huge_pmd(), clear the dirty bit from the PMD to cause a page
fault upon the next SHSTK access to the PMD.  At that time, fix the
PMD and copy/re-use the page.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/mm/pgtable.c         | 8 ++++++++
 include/asm-generic/pgtable.h | 2 ++
 mm/huge_memory.c              | 4 ++++
 3 files changed, 14 insertions(+)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index c2d754a780b3..8ff54bd978f3 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -901,6 +901,14 @@ inline pte_t pte_set_vma_features(pte_t pte, struct vm_area_struct *vma)
 		return pte;
 }
 
+inline pmd_t pmd_set_vma_features(pmd_t pmd, struct vm_area_struct *vma)
+{
+	if (vma->vm_flags & VM_SHSTK)
+		return pmd_mkdirty_shstk(pmd);
+	else
+		return pmd;
+}
+
 inline bool arch_copy_pte_mapping(vm_flags_t vm_flags)
 {
 	return (vm_flags & VM_SHSTK);
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index ffcc0be7cadc..4940411b8e1c 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1190,9 +1190,11 @@ static inline bool arch_has_pfn_modify_check(void)
 
 #ifndef CONFIG_ARCH_HAS_SHSTK
 #define pte_set_vma_features(pte, vma) pte
+#define pmd_set_vma_features(pmd, vma) pmd
 #define arch_copy_pte_mapping(vma_flags) false
 #else
 pte_t pte_set_vma_features(pte_t pte, struct vm_area_struct *vma);
+pmd_t pmd_set_vma_features(pmd_t pmd, struct vm_area_struct *vma);
 bool arch_copy_pte_mapping(vm_flags_t vm_flags);
 #endif
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9f8bce9a6b32..eac1ee2f8985 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -608,6 +608,7 @@ static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
 
 		entry = mk_huge_pmd(page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		entry = pmd_set_vma_features(entry, vma);
 		page_add_new_anon_rmap(page, vma, haddr, true);
 		mem_cgroup_commit_charge(page, memcg, false, true);
 		lru_cache_add_active_or_unevictable(page, vma);
@@ -1250,6 +1251,7 @@ static vm_fault_t do_huge_pmd_wp_page_fallback(struct vm_fault *vmf,
 		pte_t entry;
 		entry = mk_pte(pages[i], vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		entry = pte_set_vma_features(entry, vma);
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
 		page_add_new_anon_rmap(pages[i], vmf->vma, haddr, false);
@@ -1332,6 +1334,7 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 		pmd_t entry;
 		entry = pmd_mkyoung(orig_pmd);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		entry = pmd_set_vma_features(entry, vma);
 		if (pmdp_set_access_flags(vma, haddr, vmf->pmd, entry,  1))
 			update_mmu_cache_pmd(vma, vmf->address, vmf->pmd);
 		ret |= VM_FAULT_WRITE;
@@ -1404,6 +1407,7 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 		pmd_t entry;
 		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		entry = pmd_set_vma_features(entry, vma);
 		pmdp_huge_clear_flush_notify(vma, haddr, vmf->pmd);
 		page_add_new_anon_rmap(new_page, vma, haddr, true);
 		mem_cgroup_commit_charge(new_page, memcg, false, true);
-- 
2.17.1

