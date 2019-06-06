Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92A62C28EB3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 590B4214C6
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 590B4214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DA0E6B02A6; Thu,  6 Jun 2019 16:15:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58ACD6B02A8; Thu,  6 Jun 2019 16:15:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 409516B02A9; Thu,  6 Jun 2019 16:15:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED9326B02A6
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:29 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 30so2292985pgk.16
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=kOQHRtvRp7Krjq9aXSeGB8Dyu2+i8rD/nMOsAT9UzjM=;
        b=ZYFSVgVA1D0C1yG242aoElI9zhCvpzYxEtyKbUmr7E3sI1+AzUCvXP4LIP6NW7Di8e
         7eMp89KZhJaqUwX3mgJ6iQah5SKnQvGzpBT/1GT1grK/hWng0pukd4SzRKlsJHhOvYhl
         P1oobPBllZel9d3QpSAaYIwGn3WHwnC/UYn8sg2P0JyxnSMHgmSWzCvEa2mTTn7zaTcj
         ldSL/6t3alCdD2x1oqZi+ojJpnqE/q4btq1pW2dE0+SDvcTD/O7O62W3szM/tcGUamgg
         muYXOGAUFFmext4c6KH/odxQja+p/nbjC3BsJNszEv2WMYYuQ6y27ilGnUc1q5eCL9c1
         Qi5w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU63hLsijliF1XMHPHvdQNdJTX1E/WzYKMxhHQQtrEkpsQGd++O
	LlMwyv8XzXiLC98insjmlwZ7qSxQfbKCzDOX6Hx909vIz+8Rl+SkaQe6U1SGvwE1jHHlCZ9i509
	eWPAvgRPaa69TZQa/9TTRNEvPlzczBvKxLUZWoVnSkWI+jK56tqaWEWAA4F7+RWb3MA==
X-Received: by 2002:a63:c5:: with SMTP id 188mr328991pga.108.1559852129530;
        Thu, 06 Jun 2019 13:15:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzn6wdatoq9PlympjMiikedR1JRfe7OPuEOUR2TdIBblSclMa1aeN92znOPllW2uLZp076S
X-Received: by 2002:a63:c5:: with SMTP id 188mr328944pga.108.1559852128707;
        Thu, 06 Jun 2019 13:15:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852128; cv=none;
        d=google.com; s=arc-20160816;
        b=0MNsDImkkdaKM4LNs5JYm3uiZDoYaLk77FCwaoeKFZOW+xFj5rGfa4tVG+B862yVXf
         QROVocazay8xmJal7MqbrIhYnuTJQbpkBmiHROQDAhVolieUsRkbucEUDWB7KAMgi/YX
         eR/SNLa6zn+oWTbmp8TiCj8rzMJMSW1oWD4ERsgkIKHi+uxsInOw4rHl3fbvY2Qaa5rk
         W2etnCn9MyvX55vSpDy9UWODFinoZsPCcQm4VY6c6dNPiApNsZi1IeBizOUPEnNTEwx+
         92lDekz0qrTFQ+/jtNG5J2ALgn2cGAhpQIRykojvjoZz1Yne9B2/aDduADQSZfcrH6zF
         OEiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=kOQHRtvRp7Krjq9aXSeGB8Dyu2+i8rD/nMOsAT9UzjM=;
        b=j4pbYfpeKuWMB8LvGaqfWgHw9GqQqSD4Vdbkiz6bBxTEMeOEJrC4rGHVdcUJypgyou
         7Pkdrot0Kqsyb2pgCkSS7gXVv9x8dl5w2rD76gIKhW/Kq3QFwug02lpx6JRW718Y5E7W
         b5TZJ6NzNpn7CQZ7kDuZzpDAR5qkLCrfG6vgkiVNL4tBtdxAAxZ7x+hnuwt69260d56o
         9/fNHPhdYsm9S9mOAZajKedSymMA6wyhFoEh1xnpCgMJYVrHHmCevMxMhg/6grOGKO8H
         nd8wPRSX7tCyZpSi9tx37mu5WEl+NS4nW8au+06Ce2SrSpq7MTG67zm7UfaKfsP3zNf0
         VQ+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id r142si2785300pfc.219.2019.06.06.13.15.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:28 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:27 -0700
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
Subject: [PATCH v7 15/27] mm: Handle shadow stack page fault
Date: Thu,  6 Jun 2019 13:06:34 -0700
Message-Id: <20190606200646.3951-16-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When a task does fork(), its shadow stack (SHSTK) must be duplicated
for the child.  This patch implements a flow similar to copy-on-write
of an anonymous page, but for SHSTK.

A SHSTK PTE must be RO and dirty.  This dirty bit requirement is used
to effect the copying.  In copy_one_pte(), clear the dirty bit from a
SHSTK PTE to cause a page fault upon the next SHSTK access.  At that
time, fix the PTE and copy/re-use the page.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/mm/pgtable.c         | 15 +++++++++++++++
 include/asm-generic/pgtable.h |  8 ++++++++
 mm/memory.c                   |  7 ++++++-
 3 files changed, 29 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 1f67b1e15bf6..c2d754a780b3 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -891,3 +891,18 @@ int pmd_free_pte_page(pmd_t *pmd, unsigned long addr)
 
 #endif /* CONFIG_X86_64 */
 #endif	/* CONFIG_HAVE_ARCH_HUGE_VMAP */
+
+#ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
+inline pte_t pte_set_vma_features(pte_t pte, struct vm_area_struct *vma)
+{
+	if (vma->vm_flags & VM_SHSTK)
+		return pte_mkdirty_shstk(pte);
+	else
+		return pte;
+}
+
+inline bool arch_copy_pte_mapping(vm_flags_t vm_flags)
+{
+	return (vm_flags & VM_SHSTK);
+}
+#endif /* CONFIG_X86_INTEL_SHADOW_STACK_USER */
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 75d9d68a6de7..ffcc0be7cadc 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1188,4 +1188,12 @@ static inline bool arch_has_pfn_modify_check(void)
 #define mm_pmd_folded(mm)	__is_defined(__PAGETABLE_PMD_FOLDED)
 #endif
 
+#ifndef CONFIG_ARCH_HAS_SHSTK
+#define pte_set_vma_features(pte, vma) pte
+#define arch_copy_pte_mapping(vma_flags) false
+#else
+pte_t pte_set_vma_features(pte_t pte, struct vm_area_struct *vma);
+bool arch_copy_pte_mapping(vm_flags_t vm_flags);
+#endif
+
 #endif /* _ASM_GENERIC_PGTABLE_H */
diff --git a/mm/memory.c b/mm/memory.c
index ddf20bd0c317..51c97294f00f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -777,7 +777,8 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	 * If it's a COW mapping, write protect it both
 	 * in the parent and the child
 	 */
-	if (is_cow_mapping(vm_flags) && pte_write(pte)) {
+	if ((is_cow_mapping(vm_flags) && pte_write(pte)) ||
+	    arch_copy_pte_mapping(vm_flags)) {
 		ptep_set_wrprotect(src_mm, addr, src_pte);
 		pte = pte_wrprotect(pte);
 	}
@@ -2312,6 +2313,7 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
 	flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
 	entry = pte_mkyoung(vmf->orig_pte);
 	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	entry = pte_set_vma_features(entry, vma);
 	if (ptep_set_access_flags(vma, vmf->address, vmf->pte, entry, 1))
 		update_mmu_cache(vma, vmf->address, vmf->pte);
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
@@ -2387,6 +2389,7 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		entry = pte_set_vma_features(entry, vma);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
 		 * pte with the new entry. This will avoid a race condition
@@ -2910,6 +2913,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 	pte = mk_pte(page, vma->vm_page_prot);
 	if ((vmf->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
+		pte = pte_set_vma_features(pte, vma);
 		vmf->flags &= ~FAULT_FLAG_WRITE;
 		ret |= VM_FAULT_WRITE;
 		exclusive = RMAP_EXCLUSIVE;
@@ -3052,6 +3056,7 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 	entry = mk_pte(page, vma->vm_page_prot);
 	if (vma->vm_flags & VM_WRITE)
 		entry = pte_mkwrite(pte_mkdirty(entry));
+	entry = pte_set_vma_features(entry, vma);
 
 	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
 			&vmf->ptl);
-- 
2.17.1

