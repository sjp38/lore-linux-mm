Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1759AC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:03:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C76C72070D
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:03:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C76C72070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A8626B0270; Tue, 13 Aug 2019 17:03:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 931B76B0271; Tue, 13 Aug 2019 17:03:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AF756B0272; Tue, 13 Aug 2019 17:03:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0118.hostedemail.com [216.40.44.118])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE666B0270
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:03:00 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id E26B58248AA3
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:02:59 +0000 (UTC)
X-FDA: 75818629278.27.air85_1a1a19e02d101
X-HE-Tag: air85_1a1a19e02d101
X-Filterd-Recvd-Size: 6122
Received: from mga12.intel.com (mga12.intel.com [192.55.52.136])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:02:59 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Aug 2019 14:02:50 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,382,1559545200"; 
   d="scan'208";a="187901416"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by orsmga002.jf.intel.com with ESMTP; 13 Aug 2019 14:02:49 -0700
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
Subject: [PATCH v8 13/27] x86/mm: Modify ptep_set_wrprotect and pmdp_set_wrprotect for _PAGE_DIRTY_SW
Date: Tue, 13 Aug 2019 13:52:11 -0700
Message-Id: <20190813205225.12032-14-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190813205225.12032-1-yu-cheng.yu@intel.com>
References: <20190813205225.12032-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When Shadow Stack is enabled, the [R/O + PAGE_DIRTY_HW] setting is
reserved only for the Shadow Stack.  Non-Shadow Stack R/O PTEs use
[R/O + PAGE_DIRTY_SW].

When a PTE goes from [R/W + PAGE_DIRTY_HW] to [R/O + PAGE_DIRTY_SW],
it could become a transient Shadow Stack PTE in two cases.

The first case is that some processors can start a write but end up
seeing a read-only PTE by the time they get to the Dirty bit,
creating a transient Shadow Stack PTE.  However, this will not occur
on processors supporting Shadow Stack therefore we don't need a TLB
flush here.

The second case is that when the software, without atomic, tests &
replaces PAGE_DIRTY_HW with PAGE_DIRTY_SW, a transient Shadow Stack
PTE can exist.  This is prevented with cmpxchg.

Dave Hansen, Jann Horn, Andy Lutomirski, and Peter Zijlstra provided
many insights to the issue.  Jann Horn provided the cmpxchg solution.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/pgtable.h | 58 ++++++++++++++++++++++++++++++++++
 1 file changed, 58 insertions(+)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 1448fb38f248..81c8c5ec221e 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1222,7 +1222,36 @@ static inline pte_t ptep_get_and_clear_full(struct mm_struct *mm,
 static inline void ptep_set_wrprotect(struct mm_struct *mm,
 				      unsigned long addr, pte_t *ptep)
 {
+#ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
+	pte_t new_pte, pte = READ_ONCE(*ptep);
+
+	/*
+	 * Some processors can start a write, but end up
+	 * seeing a read-only PTE by the time they get
+	 * to the Dirty bit.  In this case, they will
+	 * set the Dirty bit, leaving a read-only, Dirty
+	 * PTE which looks like a Shadow Stack PTE.
+	 *
+	 * However, this behavior has been improved and
+	 * will not occur on processors supporting
+	 * Shadow Stacks.  Without this guarantee, a
+	 * transition to a non-present PTE and flush the
+	 * TLB would be needed.
+	 *
+	 * When changing a writable PTE to read-only and
+	 * if the PTE has _PAGE_DIRTY_HW set, we move
+	 * that bit to _PAGE_DIRTY_SW so that the PTE is
+	 * not a valid Shadow Stack PTE.
+	 */
+	do {
+		new_pte = pte_wrprotect(pte);
+		new_pte.pte |= (new_pte.pte & _PAGE_DIRTY_HW) >>
+				_PAGE_BIT_DIRTY_HW << _PAGE_BIT_DIRTY_SW;
+		new_pte.pte &= ~_PAGE_DIRTY_HW;
+	} while (!try_cmpxchg(ptep, &pte, new_pte));
+#else
 	clear_bit(_PAGE_BIT_RW, (unsigned long *)&ptep->pte);
+#endif
 }
 
 #define flush_tlb_fix_spurious_fault(vma, address) do { } while (0)
@@ -1285,7 +1314,36 @@ static inline pud_t pudp_huge_get_and_clear(struct mm_struct *mm,
 static inline void pmdp_set_wrprotect(struct mm_struct *mm,
 				      unsigned long addr, pmd_t *pmdp)
 {
+#ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
+	pmd_t new_pmd, pmd = READ_ONCE(*pmdp);
+
+	/*
+	 * Some processors can start a write, but end up
+	 * seeing a read-only PMD by the time they get
+	 * to the Dirty bit.  In this case, they will
+	 * set the Dirty bit, leaving a read-only, Dirty
+	 * PMD which looks like a Shadow Stack PMD.
+	 *
+	 * However, this behavior has been improved and
+	 * will not occur on processors supporting
+	 * Shadow Stacks.  Without this guarantee, a
+	 * transition to a non-present PMD and flush the
+	 * TLB would be needed.
+	 *
+	 * When changing a writable PMD to read-only and
+	 * if the PMD has _PAGE_DIRTY_HW set, we move
+	 * that bit to _PAGE_DIRTY_SW so that the PMD is
+	 * not a valid Shadow Stack PMD.
+	 */
+	do {
+		new_pmd = pmd_wrprotect(pmd);
+		new_pmd.pmd |= (new_pmd.pmd & _PAGE_DIRTY_HW) >>
+				_PAGE_BIT_DIRTY_HW << _PAGE_BIT_DIRTY_SW;
+		new_pmd.pmd &= ~_PAGE_DIRTY_HW;
+	} while (!try_cmpxchg(pmdp, &pmd, new_pmd));
+#else
 	clear_bit(_PAGE_BIT_RW, (unsigned long *)pmdp);
+#endif
 }
 
 #define pud_write pud_write
-- 
2.17.1


