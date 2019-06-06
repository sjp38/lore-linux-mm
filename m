Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28781C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDAF9208C3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDAF9208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C94AC6B0297; Thu,  6 Jun 2019 16:15:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1B756B0298; Thu,  6 Jun 2019 16:15:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABDB16B0299; Thu,  6 Jun 2019 16:15:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 64C616B0297
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:24 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i26so2582857pfo.22
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=w6pPmJ2scNd1pZ4+36igKzH9zbFt1KQ9ZeEfcsQz6UY=;
        b=Y/p1xSTYOstv7xOsZnDQAgZe1RIdaY2bezmkCceGvtc64rwciX6j9wFkXfj62U9+sX
         OycUC3yTHkyVjmfZVAQspY+R2aPld4wJcskapseT0j08AAFSNyHQvyUrvInkdCDh4qe3
         QKIJb8PW0hBMzJpylsgGOAMlSo66kIn4XYQpdqGGr6euKLiWMN96jQGOoGHgUG0txd1Y
         Buau7NdggyATPCDoX82t2E5PlbAlIKn647dRg753yWeXlZfaQYyp93+y3hWFKKV5y8jj
         tBvmwp2rRNyrC+z8GOZj47bPbxSa68wsm5txAbQP6NyNRx86n5gooMC0cLP4Too/M0X1
         tvFw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUDxWbCLqgM6BvxwI+WfzAzfc1SVeHtrAf4xE2ZSA7u5mx1wPG5
	yuFJ4vqUvRIadnA0PpaG4OtWtK8VndbxxAuqFtsI83h/oOPmTniAgAx7g892gJwii3TuhR7kYcl
	SW37ySeMfMxo9OFS9h5si+6ogka1UukHk+VeDu2ZZmb5UFdZDZ6180PepNgD41ktjuQ==
X-Received: by 2002:a17:902:76c6:: with SMTP id j6mr27173546plt.263.1559852124077;
        Thu, 06 Jun 2019 13:15:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzxZMLPAP1KS6VbQ5+B3i/r1Oo/iMgZUMOVDj7PaoJ9f7z1KXAaXa6caVRox8rku8CZyEV
X-Received: by 2002:a17:902:76c6:: with SMTP id j6mr27173452plt.263.1559852122894;
        Thu, 06 Jun 2019 13:15:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852122; cv=none;
        d=google.com; s=arc-20160816;
        b=YNkXZ2HC2MJrXPl/j4lL9KNUV3Hvh811ya51eHXTfEZq2msMQyYTc5ff76rwDmVEQW
         sP5mO1tsHv/nFF0eUSjjfzYXAFhoSlQIZiitcELf1vonhNNcILDUKlpVrtPsx4Y5Hx4a
         LLF0haWW6xJwE1mBNFSE9b3TdiajI9gCFMd5tVnzLO2f9ITizP3PPgUKuuuoXp2HhePN
         3GPhKRLcOQ6qpgKwDtPYG4dzo3S4vwihm2iPv4js9StWQa5PvrqhhfGa3Ws49+I3Dpw2
         F8f+y5FHB6fOlORhT4qL1+PRTk9mhZipIkob/Y25B82kzpw0roLnDpVixD0Vj5cvsVUe
         QHwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=w6pPmJ2scNd1pZ4+36igKzH9zbFt1KQ9ZeEfcsQz6UY=;
        b=FllU/7RffiQSzVntKb+c5fe3Y97oSk0bLVo/d5Xk6entl1F6hOYijs7N8MqDXdJDaG
         NCu7PtMu+L/IluR9zVzdzyS3trRGP+6u2PwVwdb13ynanrHMwaEMK2iCmnsz+Dvj3iue
         X8KOdA0MGtOiFS3ngCBIYuH2N7kR8bUwyUirYbUmBTqxNJ5J6D+k9c+zIWggbiA5Is5j
         LqUWryB5W52+IoGBj/aMr/i0YNkwLyTMAEoCTPJUbQFkssSYAx3pkWdzdSC8h1LJJ7kz
         dYJC5dlk4CAR25w6ZjDOc6QwLgNe+IeaivDBSwufiZ7hFYqP+nBDi9dX3SuTtktm4sm6
         glaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id r142si2785300pfc.219.2019.06.06.13.15.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:21 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:20 -0700
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
Subject: [PATCH v7 10/27] x86/mm: Change _PAGE_DIRTY to _PAGE_DIRTY_HW
Date: Thu,  6 Jun 2019 13:06:29 -0700
Message-Id: <20190606200646.3951-11-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Before introducing _PAGE_DIRTY_SW for non-hardware, memory management
purposes in the next patch, rename _PAGE_DIRTY to _PAGE_DIRTY_HW and
_PAGE_BIT_DIRTY to _PAGE_BIT_DIRTY_HW to make these PTE dirty bits
more clear.  There are no functional changes in this patch.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/pgtable.h       |  6 +++---
 arch/x86/include/asm/pgtable_types.h | 17 +++++++++--------
 arch/x86/kernel/relocate_kernel_64.S |  2 +-
 arch/x86/kvm/vmx/vmx.c               |  2 +-
 4 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 5e0509b41986..5008dd2817e2 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -332,7 +332,7 @@ static inline pte_t pte_mkexec(pte_t pte)
 
 static inline pte_t pte_mkdirty(pte_t pte)
 {
-	return pte_set_flags(pte, _PAGE_DIRTY | _PAGE_SOFT_DIRTY);
+	return pte_set_flags(pte, _PAGE_DIRTY_HW | _PAGE_SOFT_DIRTY);
 }
 
 static inline pte_t pte_mkyoung(pte_t pte)
@@ -406,7 +406,7 @@ static inline pmd_t pmd_wrprotect(pmd_t pmd)
 
 static inline pmd_t pmd_mkdirty(pmd_t pmd)
 {
-	return pmd_set_flags(pmd, _PAGE_DIRTY | _PAGE_SOFT_DIRTY);
+	return pmd_set_flags(pmd, _PAGE_DIRTY_HW | _PAGE_SOFT_DIRTY);
 }
 
 static inline pmd_t pmd_mkdevmap(pmd_t pmd)
@@ -460,7 +460,7 @@ static inline pud_t pud_wrprotect(pud_t pud)
 
 static inline pud_t pud_mkdirty(pud_t pud)
 {
-	return pud_set_flags(pud, _PAGE_DIRTY | _PAGE_SOFT_DIRTY);
+	return pud_set_flags(pud, _PAGE_DIRTY_HW | _PAGE_SOFT_DIRTY);
 }
 
 static inline pud_t pud_mkdevmap(pud_t pud)
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index d6ff0bbdb394..cebee656a250 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -15,7 +15,7 @@
 #define _PAGE_BIT_PWT		3	/* page write through */
 #define _PAGE_BIT_PCD		4	/* page cache disabled */
 #define _PAGE_BIT_ACCESSED	5	/* was accessed (raised by CPU) */
-#define _PAGE_BIT_DIRTY		6	/* was written to (raised by CPU) */
+#define _PAGE_BIT_DIRTY_HW	6	/* was written to (raised by CPU) */
 #define _PAGE_BIT_PSE		7	/* 4 MB (or 2MB) page */
 #define _PAGE_BIT_PAT		7	/* on 4KB pages */
 #define _PAGE_BIT_GLOBAL	8	/* Global TLB entry PPro+ */
@@ -45,7 +45,7 @@
 #define _PAGE_PWT	(_AT(pteval_t, 1) << _PAGE_BIT_PWT)
 #define _PAGE_PCD	(_AT(pteval_t, 1) << _PAGE_BIT_PCD)
 #define _PAGE_ACCESSED	(_AT(pteval_t, 1) << _PAGE_BIT_ACCESSED)
-#define _PAGE_DIRTY	(_AT(pteval_t, 1) << _PAGE_BIT_DIRTY)
+#define _PAGE_DIRTY_HW	(_AT(pteval_t, 1) << _PAGE_BIT_DIRTY_HW)
 #define _PAGE_PSE	(_AT(pteval_t, 1) << _PAGE_BIT_PSE)
 #define _PAGE_GLOBAL	(_AT(pteval_t, 1) << _PAGE_BIT_GLOBAL)
 #define _PAGE_SOFTW1	(_AT(pteval_t, 1) << _PAGE_BIT_SOFTW1)
@@ -73,7 +73,7 @@
 			 _PAGE_PKEY_BIT3)
 
 #if defined(CONFIG_X86_64) || defined(CONFIG_X86_PAE)
-#define _PAGE_KNL_ERRATUM_MASK (_PAGE_DIRTY | _PAGE_ACCESSED)
+#define _PAGE_KNL_ERRATUM_MASK (_PAGE_DIRTY_HW | _PAGE_ACCESSED)
 #else
 #define _PAGE_KNL_ERRATUM_MASK 0
 #endif
@@ -112,9 +112,9 @@
 #define _PAGE_PROTNONE	(_AT(pteval_t, 1) << _PAGE_BIT_PROTNONE)
 
 #define _PAGE_TABLE_NOENC	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |\
-				 _PAGE_ACCESSED | _PAGE_DIRTY)
+				 _PAGE_ACCESSED | _PAGE_DIRTY_HW)
 #define _KERNPG_TABLE_NOENC	(_PAGE_PRESENT | _PAGE_RW |		\
-				 _PAGE_ACCESSED | _PAGE_DIRTY)
+				 _PAGE_ACCESSED | _PAGE_DIRTY_HW)
 
 /*
  * Set of bits not changed in pte_modify.  The pte's
@@ -123,7 +123,7 @@
  * pte_modify() does modify it.
  */
 #define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
-			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
+			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY_HW |	\
 			 _PAGE_SOFT_DIRTY | _PAGE_DEVMAP)
 #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)
 
@@ -168,7 +168,8 @@ enum page_cache_mode {
 					 _PAGE_ACCESSED)
 
 #define __PAGE_KERNEL_EXEC						\
-	(_PAGE_PRESENT | _PAGE_RW | _PAGE_DIRTY | _PAGE_ACCESSED | _PAGE_GLOBAL)
+	(_PAGE_PRESENT | _PAGE_RW | _PAGE_DIRTY_HW | _PAGE_ACCESSED | \
+	 _PAGE_GLOBAL)
 #define __PAGE_KERNEL		(__PAGE_KERNEL_EXEC | _PAGE_NX)
 
 #define __PAGE_KERNEL_RO		(__PAGE_KERNEL & ~_PAGE_RW)
@@ -187,7 +188,7 @@ enum page_cache_mode {
 #define _PAGE_ENC	(_AT(pteval_t, sme_me_mask))
 
 #define _KERNPG_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED |	\
-			 _PAGE_DIRTY | _PAGE_ENC)
+			 _PAGE_DIRTY_HW | _PAGE_ENC)
 #define _PAGE_TABLE	(_KERNPG_TABLE | _PAGE_USER)
 
 #define __PAGE_KERNEL_ENC	(__PAGE_KERNEL | _PAGE_ENC)
diff --git a/arch/x86/kernel/relocate_kernel_64.S b/arch/x86/kernel/relocate_kernel_64.S
index 11eda21eb697..e7665a4767b3 100644
--- a/arch/x86/kernel/relocate_kernel_64.S
+++ b/arch/x86/kernel/relocate_kernel_64.S
@@ -17,7 +17,7 @@
  */
 
 #define PTR(x) (x << 3)
-#define PAGE_ATTR (_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED | _PAGE_DIRTY)
+#define PAGE_ATTR (_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED | _PAGE_DIRTY_HW)
 
 /*
  * control_page + KEXEC_CONTROL_CODE_MAX_SIZE
diff --git a/arch/x86/kvm/vmx/vmx.c b/arch/x86/kvm/vmx/vmx.c
index b93e36ddee5e..9b3b229b5ef0 100644
--- a/arch/x86/kvm/vmx/vmx.c
+++ b/arch/x86/kvm/vmx/vmx.c
@@ -3364,7 +3364,7 @@ static int init_rmode_identity_map(struct kvm *kvm)
 	/* Set up identity-mapping pagetable for EPT in real mode */
 	for (i = 0; i < PT32_ENT_PER_PAGE; i++) {
 		tmp = (i << 22) + (_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |
-			_PAGE_ACCESSED | _PAGE_DIRTY | _PAGE_PSE);
+			_PAGE_ACCESSED | _PAGE_DIRTY_HW | _PAGE_PSE);
 		r = kvm_write_guest_page(kvm, identity_map_pfn,
 				&tmp, i * sizeof(tmp), sizeof(tmp));
 		if (r < 0)
-- 
2.17.1

