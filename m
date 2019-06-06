Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C03FC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20CBA208CA
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20CBA208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D09096B02A1; Thu,  6 Jun 2019 16:15:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C91C76B02A3; Thu,  6 Jun 2019 16:15:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B0C716B02A5; Thu,  6 Jun 2019 16:15:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 718C06B02A1
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:27 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id v62so2324385pgb.0
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=oj8Un5QmH3g727TAPRPmQHhqB9MuswGdM4DJNrA223w=;
        b=ctn1nkWspR6ZFzP2/Rj3p2eEGo9+mwzvpjE0CiRusYf723ormWmDny0Nzd0+1IANS+
         p0ZNV5hZAzOuICkUB3Rpu/xe0OSHd1rCtBGgHSn0I5jMXw+p4T6BMGcGyg8svHMR1dxR
         xmd+vJLsedfu65T4UHCM0K5+N/DseHc+y3AXLmLTEnSAgxbbl3H/c7GwxuFVj1Vn2kVW
         m95hblaGlScLeyEjqHRpVqKDIIc/BEx5/niWc92cM3QI3r7QP7qtqIoS+PI9YGLB1OH8
         jPEjEFcAfvOlhELKNX2rfpFSXZm3f1a7qcNfa+dye6jH6FWt/tBpwp8ZNoQkK7W04R4m
         s2Kw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW2RtfCpd5eO91lwEJX2BIfjLPYp2AfhnQ8DdL7HwK8lriFYfFe
	mrRtS7mnwArAxZRsNo9LnmuWNZntm5CGpqd3SpqKoA34KohaMno661/OOMr4EGVXuKpfJs9XYH6
	0GEbi/Cn42+nmgFWByobJrulj+Wj5q3YAMvjczbPLFf41oZJcoIEdPMuawg9T85FnDA==
X-Received: by 2002:a17:90a:730b:: with SMTP id m11mr1616599pjk.89.1559852127114;
        Thu, 06 Jun 2019 13:15:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzY1Rc9dY5qV2mLtSI6pAdTXlvh/5FIVVPvK6lEuEPYD+5Woa+32najWJMsaBqvEwyggaLv
X-Received: by 2002:a17:90a:730b:: with SMTP id m11mr1616543pjk.89.1559852126218;
        Thu, 06 Jun 2019 13:15:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852126; cv=none;
        d=google.com; s=arc-20160816;
        b=R84NgnYhvLN7A11C3rrVcU3ZTahMw1NFdYJ3ib+RQDRq9Ec65jQTIC9dhkAsBmvYek
         v9Teo9zCINFRa/6OipD9P4r02Fwlsbf3E3Kb2jdRhrmyUcWamrcwfPQaVf+fIZuiP6dT
         HY7S1mAmBGPOPEF3j05Pe12gELVcVcCo37VG1jy241oy6E0e4eOqU1J/wrkOzMXvtsdy
         wdFpzPTP3kh8ueLFILj3EHXR8/+Kc55OUBLwK2G+xyxSvrBR0d/sHR4na2SvaZSoLQhk
         cnUYWKbXafQUn6XDS50jDA4/CZzQbLScJZHnBVHaTZ1DRpLr/qXdsg/n2uPGozVjTYyn
         qomw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=oj8Un5QmH3g727TAPRPmQHhqB9MuswGdM4DJNrA223w=;
        b=d/bC62drPQikpFO5Qn4bs9nyFO+41RRewbt3QJFMMjb2268sbnp37h1ZZj/zKaR+tg
         9gR0q3NBVz3n3LByno71F3J9SZKUNs/7sZpJuf1YwQqAvOWGlupWgRsNkaooqFTgqj5b
         mnGy+pbshtGu0IIpd6y3XuguPONhW8Euye4MJiX7ic50sEqkE/UpJ65Nq4TFXJeJagQa
         CH5IhBqkygyYiIHwDdn5mVileatZsnQlJIAUdOPZUMeWyc20ORUCsBJ5+lRNYTlnJr71
         uA5ViriYjREXP+V9Vix0e2ieUW6g4p2jQJ8e8OdlqRgqh69JK3Z4QRwxfnYv7u58vY4K
         Ioew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id r142si2785300pfc.219.2019.06.06.13.15.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:25 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:24 -0700
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
Subject: [PATCH v7 13/27] x86/mm: Modify ptep_set_wrprotect and pmdp_set_wrprotect for _PAGE_DIRTY_SW
Date: Thu,  6 Jun 2019 13:06:32 -0700
Message-Id: <20190606200646.3951-14-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
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
index 0a3ce0a94d73..2dd079080be2 100644
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

