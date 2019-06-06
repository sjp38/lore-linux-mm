Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A2D3C28EB4
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E67AF21479
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E67AF21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B1436B029F; Thu,  6 Jun 2019 16:15:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 230FD6B02A1; Thu,  6 Jun 2019 16:15:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05BA66B02A2; Thu,  6 Jun 2019 16:15:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B0B086B029F
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:25 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id u1so2324578pgh.3
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Y9Zc4N6NG2Z4vNfKi0LlVFvk0a5eJ1nr33xkyZozgsQ=;
        b=RG3iJQFlTDvm9fOHerEDatPdb53See+7IYz7KcUZKKDbGTHEWbXLfkZmrkOtVW8A5x
         bBOErfktxBi1LzXP98wCniXPXZF5HaRz5QjmMu8a6rCDb+Y5d51L+CL8atI1+KDhjhcD
         uuJXJC3Zy8V/hdySUjcsx4CdObhF8nDxz+al6bxG5/2zhIC6wUpHJ5zqCKsh1X/wll6n
         alka5xG9xFmeNuROGrxT3f6uE4OdRdHW/FkYicVaDKgIoflOfimSRoM6wUkQ+aWNrkQs
         g2g6Qf/f//ZWm1zlgFexQfM6nAPCY60lFFcbV4CG44v8l5vpyvQoNl995Z3MiY2szSUF
         7m2Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVsdClPjw535PcA3zaFrA+Tus+fzZF7RwcD7k6ulaWbTi1hbUZK
	fLs2NSX5T7OZ+UOrv3LpPmBJlnw096XUQdU1Q4HhKx+jhOmVo2LkeMXRB2oR1JdvfVpZLyRdFzt
	oIM7sMtMdybBApg/EfSuEIWYcM9MqeO097MH18A+/6o+m8GunjLAlKHvNoF89knFPYQ==
X-Received: by 2002:a17:902:9a42:: with SMTP id x2mr35309714plv.106.1559852125339;
        Thu, 06 Jun 2019 13:15:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYTDYdf+Pua8kO2qOkAS5y13zUAUtc53hSqivrapO70oj5hKbisGuJ117SkrGHOMiPnj8u
X-Received: by 2002:a17:902:9a42:: with SMTP id x2mr35309596plv.106.1559852123741;
        Thu, 06 Jun 2019 13:15:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852123; cv=none;
        d=google.com; s=arc-20160816;
        b=nODq81is8oEXPDURsgD5vpPqHNxdgGQYNMKFP12Htp1vVeEvdwBub5AUegjuZqgQ6Q
         Q3bxjNcrxFRObOSqjrbAjRyWDgH0+UCgr+Giv/OfLqgz5LPWOln7In7kjsXci1wivldb
         lsdgIkeGY/+aPYsbVoBtO5v/HVyk+U4nZHfUbmFns/Q9C/nrFMwD0JBvbQ4ndCb3ZCje
         SR/454IapE+5xcMRdlojKSbiEiLkVbRcbOeZTofxclpPGCcQvoCeJ0GOTiDRyIhyOgRI
         XmZM9cz/DhSHpg1m6+Or+eM6cv2B1trELD1SJgRNeXbKsdyUjypy1CrPdPBpvOVuqbc6
         7sng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Y9Zc4N6NG2Z4vNfKi0LlVFvk0a5eJ1nr33xkyZozgsQ=;
        b=hM13pm1aRiBVVK80iYYHsUwdo1XUn3I7m3VkpQDeZ3l3YBr5iwo5sgCSquWiO6WO4/
         P1tUUOEpdrW/UNLMXNnWHOBGiBaIPnM3MtdEO2FOY8tv8r0GdyJ5vcTz9R9+NNR5Mw58
         SyhsvPWPrZxCLlZy44gTKR3CCGN8CGwZr6PRniABErIYCBgfjNZulKXvn4bJE6wQ0461
         dhfwxewUTxNuQD/uVeyEc4bKYi44v5jpIoEcDBzcworAuWpYvXlQcbxpQQqAb/ajTl6n
         TAyV/nBlsxDoNb9mE7D/KlRT0liwkqtV+B0t4LiIiTWz2C5YhRFlp+O/+MLq7Croefy0
         pWwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id r142si2785300pfc.219.2019.06.06.13.15.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:22 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:21 -0700
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
Subject: [PATCH v7 11/27] x86/mm: Introduce _PAGE_DIRTY_SW
Date: Thu,  6 Jun 2019 13:06:30 -0700
Message-Id: <20190606200646.3951-12-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A RO and dirty PTE exists in the following cases:

(a) A page is modified and then shared with a fork()'ed child;
(b) A R/O page that has been COW'ed;
(c) A SHSTK page.

The processor does not read the dirty bit for (a) and (b), but
checks the dirty bit for (c).  To prevent the use of non-SHSTK
memory as SHSTK, we introduce a spare bit of the 64-bit PTE as
_PAGE_BIT_DIRTY_SW and use that for (a) and (b).  This results
to the following possible PTE settings:

Modified PTE:             (R/W + DIRTY_HW)
Modified and shared PTE:  (R/O + DIRTY_SW)
R/O PTE COW'ed:           (R/O + DIRTY_SW)
SHSTK PTE:                (R/O + DIRTY_HW)
SHSTK PTE COW'ed:         (R/O + DIRTY_HW)
SHSTK PTE shared:         (R/O + DIRTY_SW)

Note that _PAGE_BIT_DRITY_SW is only used in R/O PTEs but
not R/W PTEs.

When this patch is applied, there are six free bits left in
the 64-bit PTE.  There is no more free bit in the 32-bit
PTE (except for PAE) and shadow stack is not implemented
for the 32-bit kernel.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/pgtable.h       | 129 ++++++++++++++++++++++-----
 arch/x86/include/asm/pgtable_types.h |  21 ++++-
 2 files changed, 128 insertions(+), 22 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 5008dd2817e2..0a3ce0a94d73 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -120,9 +120,9 @@ extern pmdval_t early_pmd_flags;
  * The following only work if pte_present() is true.
  * Undefined behaviour if not..
  */
-static inline int pte_dirty(pte_t pte)
+static inline bool pte_dirty(pte_t pte)
 {
-	return pte_flags(pte) & _PAGE_DIRTY;
+	return pte_flags(pte) & _PAGE_DIRTY_BITS;
 }
 
 
@@ -159,9 +159,9 @@ static inline int pte_young(pte_t pte)
 	return pte_flags(pte) & _PAGE_ACCESSED;
 }
 
-static inline int pmd_dirty(pmd_t pmd)
+static inline bool pmd_dirty(pmd_t pmd)
 {
-	return pmd_flags(pmd) & _PAGE_DIRTY;
+	return pmd_flags(pmd) & _PAGE_DIRTY_BITS;
 }
 
 static inline int pmd_young(pmd_t pmd)
@@ -169,9 +169,9 @@ static inline int pmd_young(pmd_t pmd)
 	return pmd_flags(pmd) & _PAGE_ACCESSED;
 }
 
-static inline int pud_dirty(pud_t pud)
+static inline bool pud_dirty(pud_t pud)
 {
-	return pud_flags(pud) & _PAGE_DIRTY;
+	return pud_flags(pud) & _PAGE_DIRTY_BITS;
 }
 
 static inline int pud_young(pud_t pud)
@@ -310,9 +310,23 @@ static inline pte_t pte_clear_flags(pte_t pte, pteval_t clear)
 	return native_make_pte(v & ~clear);
 }
 
+#if defined(CONFIG_X86_INTEL_SHADOW_STACK_USER)
+static inline pte_t pte_move_flags(pte_t pte, pteval_t from, pteval_t to)
+{
+	if (pte_flags(pte) & from)
+		pte = pte_set_flags(pte_clear_flags(pte, from), to);
+	return pte;
+}
+#else
+static inline pte_t pte_move_flags(pte_t pte, pteval_t from, pteval_t to)
+{
+	return pte;
+}
+#endif
+
 static inline pte_t pte_mkclean(pte_t pte)
 {
-	return pte_clear_flags(pte, _PAGE_DIRTY);
+	return pte_clear_flags(pte, _PAGE_DIRTY_BITS);
 }
 
 static inline pte_t pte_mkold(pte_t pte)
@@ -322,6 +336,7 @@ static inline pte_t pte_mkold(pte_t pte)
 
 static inline pte_t pte_wrprotect(pte_t pte)
 {
+	pte = pte_move_flags(pte, _PAGE_DIRTY_HW, _PAGE_DIRTY_SW);
 	return pte_clear_flags(pte, _PAGE_RW);
 }
 
@@ -332,9 +347,24 @@ static inline pte_t pte_mkexec(pte_t pte)
 
 static inline pte_t pte_mkdirty(pte_t pte)
 {
+	pteval_t dirty = (!IS_ENABLED(CONFIG_X86_INTEL_SHADOW_STACK_USER) ||
+			   pte_write(pte)) ? _PAGE_DIRTY_HW:_PAGE_DIRTY_SW;
+	return pte_set_flags(pte, dirty | _PAGE_SOFT_DIRTY);
+}
+
+#ifdef CONFIG_ARCH_HAS_SHSTK
+static inline pte_t pte_mkdirty_shstk(pte_t pte)
+{
+	pte = pte_clear_flags(pte, _PAGE_DIRTY_SW);
 	return pte_set_flags(pte, _PAGE_DIRTY_HW | _PAGE_SOFT_DIRTY);
 }
 
+static inline bool pte_dirty_hw(pte_t pte)
+{
+	return pte_flags(pte) & _PAGE_DIRTY_HW;
+}
+#endif
+
 static inline pte_t pte_mkyoung(pte_t pte)
 {
 	return pte_set_flags(pte, _PAGE_ACCESSED);
@@ -342,6 +372,7 @@ static inline pte_t pte_mkyoung(pte_t pte)
 
 static inline pte_t pte_mkwrite(pte_t pte)
 {
+	pte = pte_move_flags(pte, _PAGE_DIRTY_SW, _PAGE_DIRTY_HW);
 	return pte_set_flags(pte, _PAGE_RW);
 }
 
@@ -389,6 +420,20 @@ static inline pmd_t pmd_clear_flags(pmd_t pmd, pmdval_t clear)
 	return native_make_pmd(v & ~clear);
 }
 
+#if defined(CONFIG_X86_INTEL_SHADOW_STACK_USER)
+static inline pmd_t pmd_move_flags(pmd_t pmd, pmdval_t from, pmdval_t to)
+{
+	if (pmd_flags(pmd) & from)
+		pmd = pmd_set_flags(pmd_clear_flags(pmd, from), to);
+	return pmd;
+}
+#else
+static inline pmd_t pmd_move_flags(pmd_t pmd, pmdval_t from, pmdval_t to)
+{
+	return pmd;
+}
+#endif
+
 static inline pmd_t pmd_mkold(pmd_t pmd)
 {
 	return pmd_clear_flags(pmd, _PAGE_ACCESSED);
@@ -396,19 +441,36 @@ static inline pmd_t pmd_mkold(pmd_t pmd)
 
 static inline pmd_t pmd_mkclean(pmd_t pmd)
 {
-	return pmd_clear_flags(pmd, _PAGE_DIRTY);
+	return pmd_clear_flags(pmd, _PAGE_DIRTY_BITS);
 }
 
 static inline pmd_t pmd_wrprotect(pmd_t pmd)
 {
+	pmd = pmd_move_flags(pmd, _PAGE_DIRTY_HW, _PAGE_DIRTY_SW);
 	return pmd_clear_flags(pmd, _PAGE_RW);
 }
 
 static inline pmd_t pmd_mkdirty(pmd_t pmd)
 {
+	pmdval_t dirty = (!IS_ENABLED(CONFIG_X86_INTEL_SHADOW_STACK_USER) ||
+			  (pmd_flags(pmd) & _PAGE_RW)) ?
+			  _PAGE_DIRTY_HW:_PAGE_DIRTY_SW;
+	return pmd_set_flags(pmd, dirty | _PAGE_SOFT_DIRTY);
+}
+
+#ifdef CONFIG_ARCH_HAS_SHSTK
+static inline pmd_t pmd_mkdirty_shstk(pmd_t pmd)
+{
+	pmd = pmd_clear_flags(pmd, _PAGE_DIRTY_SW);
 	return pmd_set_flags(pmd, _PAGE_DIRTY_HW | _PAGE_SOFT_DIRTY);
 }
 
+static inline bool pmd_dirty_hw(pmd_t pmd)
+{
+	return  pmd_flags(pmd) & _PAGE_DIRTY_HW;
+}
+#endif
+
 static inline pmd_t pmd_mkdevmap(pmd_t pmd)
 {
 	return pmd_set_flags(pmd, _PAGE_DEVMAP);
@@ -426,6 +488,7 @@ static inline pmd_t pmd_mkyoung(pmd_t pmd)
 
 static inline pmd_t pmd_mkwrite(pmd_t pmd)
 {
+	pmd = pmd_move_flags(pmd, _PAGE_DIRTY_SW, _PAGE_DIRTY_HW);
 	return pmd_set_flags(pmd, _PAGE_RW);
 }
 
@@ -443,6 +506,20 @@ static inline pud_t pud_clear_flags(pud_t pud, pudval_t clear)
 	return native_make_pud(v & ~clear);
 }
 
+#if defined(CONFIG_X86_INTEL_SHADOW_STACK_USER)
+static inline pud_t pud_move_flags(pud_t pud, pudval_t from, pudval_t to)
+{
+	if (pud_flags(pud) & from)
+		pud = pud_set_flags(pud_clear_flags(pud, from), to);
+	return pud;
+}
+#else
+static inline pud_t pud_move_flags(pud_t pud, pudval_t from, pudval_t to)
+{
+	return pud;
+}
+#endif
+
 static inline pud_t pud_mkold(pud_t pud)
 {
 	return pud_clear_flags(pud, _PAGE_ACCESSED);
@@ -450,17 +527,22 @@ static inline pud_t pud_mkold(pud_t pud)
 
 static inline pud_t pud_mkclean(pud_t pud)
 {
-	return pud_clear_flags(pud, _PAGE_DIRTY);
+	return pud_clear_flags(pud, _PAGE_DIRTY_BITS);
 }
 
 static inline pud_t pud_wrprotect(pud_t pud)
 {
+	pud = pud_move_flags(pud, _PAGE_DIRTY_HW, _PAGE_DIRTY_SW);
 	return pud_clear_flags(pud, _PAGE_RW);
 }
 
 static inline pud_t pud_mkdirty(pud_t pud)
 {
-	return pud_set_flags(pud, _PAGE_DIRTY_HW | _PAGE_SOFT_DIRTY);
+	pudval_t dirty = (!IS_ENABLED(CONFIG_X86_INTEL_SHADOW_STACK_USER) ||
+			  (pud_flags(pud) & _PAGE_RW)) ?
+			  _PAGE_DIRTY_HW:_PAGE_DIRTY_SW;
+
+	return pud_set_flags(pud, dirty | _PAGE_SOFT_DIRTY);
 }
 
 static inline pud_t pud_mkdevmap(pud_t pud)
@@ -480,6 +562,7 @@ static inline pud_t pud_mkyoung(pud_t pud)
 
 static inline pud_t pud_mkwrite(pud_t pud)
 {
+	pud = pud_move_flags(pud, _PAGE_DIRTY_SW, _PAGE_DIRTY_HW);
 	return pud_set_flags(pud, _PAGE_RW);
 }
 
@@ -611,19 +694,12 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 	val &= _PAGE_CHG_MASK;
 	val |= check_pgprot(newprot) & ~_PAGE_CHG_MASK;
 	val = flip_protnone_guard(oldval, val, PTE_PFN_MASK);
+	if ((pte_write(pte) && !(pgprot_val(newprot) & _PAGE_RW)))
+		return pte_move_flags(__pte(val), _PAGE_DIRTY_HW,
+				      _PAGE_DIRTY_SW);
 	return __pte(val);
 }
 
-static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
-{
-	pmdval_t val = pmd_val(pmd), oldval = val;
-
-	val &= _HPAGE_CHG_MASK;
-	val |= check_pgprot(newprot) & ~_HPAGE_CHG_MASK;
-	val = flip_protnone_guard(oldval, val, PHYSICAL_PMD_PAGE_MASK);
-	return __pmd(val);
-}
-
 /* mprotect needs to preserve PAT bits when updating vm_page_prot */
 #define pgprot_modify pgprot_modify
 static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
@@ -1178,6 +1254,19 @@ static inline int pmd_write(pmd_t pmd)
 	return pmd_flags(pmd) & _PAGE_RW;
 }
 
+static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
+{
+	pmdval_t val = pmd_val(pmd), oldval = val;
+
+	val &= _HPAGE_CHG_MASK;
+	val |= check_pgprot(newprot) & ~_HPAGE_CHG_MASK;
+	val = flip_protnone_guard(oldval, val, PHYSICAL_PMD_PAGE_MASK);
+	if ((pmd_write(pmd) && !(pgprot_val(newprot) & _PAGE_RW)))
+		return pmd_move_flags(__pmd(val), _PAGE_DIRTY_HW,
+				      _PAGE_DIRTY_SW);
+	return __pmd(val);
+}
+
 #define __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR
 static inline pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm, unsigned long addr,
 				       pmd_t *pmdp)
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index cebee656a250..1f04551c55f6 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -23,6 +23,7 @@
 #define _PAGE_BIT_SOFTW2	10	/* " */
 #define _PAGE_BIT_SOFTW3	11	/* " */
 #define _PAGE_BIT_PAT_LARGE	12	/* On 2MB or 1GB pages */
+#define _PAGE_BIT_SOFTW5	57	/* available for programmer */
 #define _PAGE_BIT_SOFTW4	58	/* available for programmer */
 #define _PAGE_BIT_PKEY_BIT0	59	/* Protection Keys, bit 1/4 */
 #define _PAGE_BIT_PKEY_BIT1	60	/* Protection Keys, bit 2/4 */
@@ -34,6 +35,7 @@
 #define _PAGE_BIT_CPA_TEST	_PAGE_BIT_SOFTW1
 #define _PAGE_BIT_SOFT_DIRTY	_PAGE_BIT_SOFTW3 /* software dirty tracking */
 #define _PAGE_BIT_DEVMAP	_PAGE_BIT_SOFTW4
+#define _PAGE_BIT_DIRTY_SW	_PAGE_BIT_SOFTW5 /* was written to */
 
 /* If _PAGE_BIT_PRESENT is clear, we use these: */
 /* - if the user mapped it with PROT_NONE; pte_present gives true */
@@ -109,6 +111,21 @@
 #define _PAGE_DEVMAP	(_AT(pteval_t, 0))
 #endif
 
+/*
+ * _PAGE_DIRTY_HW: set by the processor when a page is written.
+ * _PAGE_DIRTY_SW: a spare bit tracking a written, but now R/O page.
+ *   [R/W + _PAGE_DIRTY_HW] <-> [R/O + _PAGE_DIRTY_SW].
+ * _PAGE_SOFT_DIRTY: a spare bit used to track written pages since a time point
+ * set by the system admin; see Documentation/admin-guide/mm/soft-dirty.rst.
+ */
+#if defined(CONFIG_X86_INTEL_SHADOW_STACK_USER)
+#define _PAGE_DIRTY_SW	(_AT(pteval_t, 1) << _PAGE_BIT_DIRTY_SW)
+#else
+#define _PAGE_DIRTY_SW	(_AT(pteval_t, 0))
+#endif
+
+#define _PAGE_DIRTY_BITS (_PAGE_DIRTY_HW | _PAGE_DIRTY_SW)
+
 #define _PAGE_PROTNONE	(_AT(pteval_t, 1) << _PAGE_BIT_PROTNONE)
 
 #define _PAGE_TABLE_NOENC	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |\
@@ -122,9 +139,9 @@
  * instance, and is *not* included in this mask since
  * pte_modify() does modify it.
  */
-#define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
+#define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |			\
 			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY_HW |	\
-			 _PAGE_SOFT_DIRTY | _PAGE_DEVMAP)
+			 _PAGE_DIRTY_SW | _PAGE_SOFT_DIRTY | _PAGE_DEVMAP)
 #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)
 
 /*
-- 
2.17.1

