Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70CFBC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 296F0208CA
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 296F0208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 342326B02A3; Thu,  6 Jun 2019 16:15:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A3186B02A6; Thu,  6 Jun 2019 16:15:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0818A6B02A7; Thu,  6 Jun 2019 16:15:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B7E2D6B02A3
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:28 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id w31so2274149pgk.23
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=mJv/WQK1WOmy8hTCtd8EzUl4KsxUY16rQBl3AY6S500=;
        b=J4bc4wuRN9ilGgJ8TnUtNTzLTBEVj6ksbCsvDOHojDiCin5k+cJLeYhlPT8lspTluh
         AfrcYm2mIHF+z8m9NsSfLykx6vXCRP+RN6s0u19IjCL6mTGJqb5uBtrslEPME4Jhnjch
         gDR8N4iy2RWSFqvfnT3PupRgcsrrtoeJe1lKo4uBsE8JV5JmaniUXkK+IU84j/AdGClE
         qB4Bh65Yr32L+qO30AXhKT45id977ZUuER4+c3Hz79uwrTLonq8+SKOAQymGEsvnfp0x
         bbBMXv/XttigfT0Ki5Y3nagVneZCken/7ommoUFOGw/6zYOQO2yWEE00sF+f4qrfXfxH
         /0yg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXX5ixZnDec0lfTD1V2kyt0WEn4Mxe6AdFj8lUKmO54+b3Yq0M0
	14c72rj0iG8F82uRpGC6qzOYPeKOxpNGwa3e8wgB8WL8G/jfIzvXc6Y9lk7f3p6gUE2aZ1mQHW8
	QekYTNPbRW7NP4HcDNo+xkdnJiH1Hp0lVA/A2x5x8Kn7dfwf0pQLqWNwjfJXmm8IDvQ==
X-Received: by 2002:a17:902:e105:: with SMTP id cc5mr31380500plb.320.1559852128421;
        Thu, 06 Jun 2019 13:15:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGexB0SFKiRWdSEg+M1Vzwi0g7gV/EblNgCuefSXpg+UGDyQZfDIt78VzlVXxqPnkKNkpc
X-Received: by 2002:a17:902:e105:: with SMTP id cc5mr31380427plb.320.1559852127343;
        Thu, 06 Jun 2019 13:15:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852127; cv=none;
        d=google.com; s=arc-20160816;
        b=iVAC1WEWRkSLedJbLWPXc/rfe0NzkOCrHFx9ch7SGe3EbBGUG9ffoeXBFVNzHdYFcv
         kfCdYOsE14kAuTXx6Ct6C2oGg/vNL9V62ayMRi6B2L0yY5ldSDRk6bJucvimDgNbIkOt
         Vlby3xeOF61+oWJ6rw6RalPkRqrlb7hrAT7RgAf1Lsh856/LBwnSOR7Rf7Cz9bh3TxGo
         UYMrXDkM0CCq4jOTtmsa0YA2fAa9gC4SoHfX/Qu3ya+fsX/9zuMuADpGNgaj50sDXkO3
         3CoPj048kaea7LmxhpZf7JUdzmEiVPvKULXAKZaOZrGBRgP8JCW0K6joTAyzzIpgA0XY
         nzNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=mJv/WQK1WOmy8hTCtd8EzUl4KsxUY16rQBl3AY6S500=;
        b=IA09WHrf+pSev3kVDpPIkIcrdArXlutmvxzXAQnWHhgNSL6/s03PySRH5hvvbdSoOT
         pfLABIfOzYVbYnOmOO0ZKkwRL+xeJNycJH1vFvW7MMrhk2qNc6i7IvO6jxW4HhyxhkQs
         BD/rKHttUCiyrYrZ3l0VE1WsrZevLPjWiabcNyvr8/f6PgRCCAx13dBdOji9WIctjrpr
         9G39DipKZK1LqZxTK1v5tGMBPg9onCTdaEbE2tdhvyvKBu6dwT64RfiTZYKH/7Fr4gA+
         6cT537lS1vMQu45PGxDZ8n6+d3fsCoOWwDfZsswmGpkxYO/Sg3LO6o0qH4vWhdAwkbYb
         Lnew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id r142si2785300pfc.219.2019.06.06.13.15.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:26 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:25 -0700
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
Subject: [PATCH v7 14/27] x86/mm: Shadow stack page fault error checking
Date: Thu,  6 Jun 2019 13:06:33 -0700
Message-Id: <20190606200646.3951-15-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If a page fault is triggered by a shadow stack access (e.g. call/ret)
or shadow stack management instructions (e.g. wrussq), then bit[6] of
the page fault error code is set.

In access_error(), verify a shadow stack page fault is within a
shadow stack memory area.  It is always an error otherwise.

For a valid shadow stack access, set FAULT_FLAG_WRITE to effect
copy-on-write.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/traps.h |  2 ++
 arch/x86/mm/fault.c          | 18 ++++++++++++++++++
 2 files changed, 20 insertions(+)

diff --git a/arch/x86/include/asm/traps.h b/arch/x86/include/asm/traps.h
index 5906a22796b6..292fb3a1b340 100644
--- a/arch/x86/include/asm/traps.h
+++ b/arch/x86/include/asm/traps.h
@@ -166,6 +166,7 @@ enum {
  *   bit 3 ==				1: use of reserved bit detected
  *   bit 4 ==				1: fault was an instruction fetch
  *   bit 5 ==				1: protection keys block access
+ *   bit 6 ==				1: shadow stack access fault
  */
 enum x86_pf_error_code {
 	X86_PF_PROT	=		1 << 0,
@@ -174,5 +175,6 @@ enum x86_pf_error_code {
 	X86_PF_RSVD	=		1 << 3,
 	X86_PF_INSTR	=		1 << 4,
 	X86_PF_PK	=		1 << 5,
+	X86_PF_SHSTK	=		1 << 6,
 };
 #endif /* _ASM_X86_TRAPS_H */
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 46df4c6aae46..59f4f66e4f2e 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1205,6 +1205,17 @@ access_error(unsigned long error_code, struct vm_area_struct *vma)
 				       (error_code & X86_PF_INSTR), foreign))
 		return 1;
 
+	/*
+	 * Verify X86_PF_SHSTK is within a shadow stack VMA.
+	 * It is always an error if there is a shadow stack
+	 * fault outside a shadow stack VMA.
+	 */
+	if (error_code & X86_PF_SHSTK) {
+		if (!(vma->vm_flags & VM_SHSTK))
+			return 1;
+		return 0;
+	}
+
 	if (error_code & X86_PF_WRITE) {
 		/* write, present and write, not present: */
 		if (unlikely(!(vma->vm_flags & VM_WRITE)))
@@ -1362,6 +1373,13 @@ void do_user_addr_fault(struct pt_regs *regs,
 
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
 
+	/*
+	 * If the fault is caused by a shadow stack access,
+	 * i.e. CALL/RET/SAVEPREVSSP/RSTORSSP, then set
+	 * FAULT_FLAG_WRITE to effect copy-on-write.
+	 */
+	if (hw_error_code & X86_PF_SHSTK)
+		flags |= FAULT_FLAG_WRITE;
 	if (hw_error_code & X86_PF_WRITE)
 		flags |= FAULT_FLAG_WRITE;
 	if (hw_error_code & X86_PF_INSTR)
-- 
2.17.1

