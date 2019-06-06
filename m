Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEFDBC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:18:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 769362083E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:18:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 769362083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED74C6B02CE; Thu,  6 Jun 2019 16:17:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A93446B02D3; Thu,  6 Jun 2019 16:17:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20BB66B02D0; Thu,  6 Jun 2019 16:17:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C9E36B02C7
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:17:34 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 5so2605586pff.11
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:17:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=4ZtYRpnqNhDo6MmNFKhTgiJMhZHkWCIMCZl+C3rG6/A=;
        b=POLpfxrZofcrSNutoJwuKb9XW662Vpm4IiwuXt60zW1DiZjijyrdIWH86LqaChc4n5
         EUdaVRCbTe7Tg1P9hCh0d/2KZ/2369XkP5mGWeXdEDR3+L07HHG6vhnixxpaxorRiWQW
         Sl3XJ+lBgalryHeOmYUsW9JgmOduYa3tBsHrXuKZw/WywYfRiyCQni4AJ26Nl/sMrxJb
         pq/U7dkWaTL3Bk7DbWOnWETuepPK5UtCOBd8CGjMBoOoW4Bj5Rg6gRKcD0w7QsfDb2Un
         wmI/4FDbgMJ1jk+e7yXhgbibtGC1/IKynwm0C02lNRqve4XKMZcrXDcnjr9qByz+tE5X
         T6rg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWf6xIhiSu4R8qsTNCwhY3Pjvj/FcjZrEqU8dbx1zxTbfR7qM8D
	YHxT4tPGMO51FmyMFAIQaVElChhDJepx7A8FUg08/RrqhYlLR15gZf8G7pNYAMwW8ch0Jv+OlUs
	9XcvM607MyoLdLTo94hUKZ6Do5adw3fUyUFaQDFarkDJIaM9ijrNeHIyML13vCuCcNw==
X-Received: by 2002:a17:90a:2430:: with SMTP id h45mr1749540pje.14.1559852254285;
        Thu, 06 Jun 2019 13:17:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSyK9qrNM4mbWLjeJSeKQ8ZwgW9CWtsbeQZsw/hj+DgEZVcQgtAKW727pHvkrNDmzuh91l
X-Received: by 2002:a17:90a:2430:: with SMTP id h45mr1749464pje.14.1559852253262;
        Thu, 06 Jun 2019 13:17:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852253; cv=none;
        d=google.com; s=arc-20160816;
        b=fmja2xFjELa3kSq4NtoY4gUGaOzYEDx6SQUB7v92ZcG3z9FgaVCM3f/lTaLgyfT8bp
         fw5Q/OP1Nc72F1yMaZn4szg/M1O69wAUQPc/aTw6LCiv2zYXbdqmQ/nubGdpAZWeJti7
         zQvHE2H3FqjQIMi9UvHhxnedJfIM/aDprCPEmvB4TnRMqVmTrJ01fulERxWDqBPFcI94
         sbY9kpBvgQInswjSnT/vAsrXuP2J4X4V2cveK3IuFt1Q72tVWPfXN+E0QRmWZLLYjVoO
         KQ1c6BhwKTvaGI5GkHXASGZweitO6JQoKnUPmT+FPzOvUN6bOhpRyeGkZyiiJx+lCCKH
         jZSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=4ZtYRpnqNhDo6MmNFKhTgiJMhZHkWCIMCZl+C3rG6/A=;
        b=0Eztzi2JylmWsDKz1QA0lMs0EqPRgZMx5jiM3DfpAm0A2NbK1X5l/sh5gJSKbG7JKd
         IzmfcTdSaVTJFNAzChJRj45tHjkAv+NEDImmBR6vF/izkX/5bpuBS7CQW3AZtAZpSHCL
         6U7vyHQDx+SKw48USCpCMX0C+8gyG9GPBisGtVkGz4FktxDFQMfk8DaoDtHjsQsNptFs
         BvCTnfuzOUddbHogUuQlH/FK4mAzBnrKSPJ+z3u1NMOzwVNRqB6rsa67Ez3sJvKyMCQT
         qyh+utinXtXB4EJb0Iigqt1ZEqr4e8UhRe7F96YCuj1EUbQ+NRg6zIRCP6E2fAP20VWt
         KeoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id j18si33385pgm.561.2019.06.06.13.17.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:17:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:17:32 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by fmsmga001.fm.intel.com with ESMTP; 06 Jun 2019 13:17:32 -0700
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
Subject: [PATCH v7 12/14] x86/vsyscall/64: Fixup shadow stack and branch tracking for vsyscall
Date: Thu,  6 Jun 2019 13:09:24 -0700
Message-Id: <20190606200926.4029-13-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200926.4029-1-yu-cheng.yu@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When emulating a RET, also unwind the task's shadow stack and cancel
the current branch tracking status.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/entry/vsyscall/vsyscall_64.c | 28 +++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/arch/x86/entry/vsyscall/vsyscall_64.c b/arch/x86/entry/vsyscall/vsyscall_64.c
index d9d81ad7a400..6869ef9d1e8b 100644
--- a/arch/x86/entry/vsyscall/vsyscall_64.c
+++ b/arch/x86/entry/vsyscall/vsyscall_64.c
@@ -38,6 +38,8 @@
 #include <asm/fixmap.h>
 #include <asm/traps.h>
 #include <asm/paravirt.h>
+#include <asm/fpu/xstate.h>
+#include <asm/fpu/types.h>
 
 #define CREATE_TRACE_POINTS
 #include "vsyscall_trace.h"
@@ -92,6 +94,30 @@ static int addr_to_vsyscall_nr(unsigned long addr)
 	return nr;
 }
 
+void fixup_shstk(void)
+{
+#ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
+	u64 r;
+
+	if (current->thread.cet.shstk_enabled) {
+		rdmsrl(MSR_IA32_PL3_SSP, r);
+		wrmsrl(MSR_IA32_PL3_SSP, r + 8);
+	}
+#endif
+}
+
+void fixup_ibt(void)
+{
+#ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+	u64 r;
+
+	if (current->thread.cet.ibt_enabled) {
+		rdmsrl(MSR_IA32_U_CET, r);
+		wrmsrl(MSR_IA32_U_CET, r & ~MSR_IA32_CET_WAIT_ENDBR);
+	}
+#endif
+}
+
 static bool write_ok_or_segv(unsigned long ptr, size_t size)
 {
 	/*
@@ -265,6 +291,8 @@ bool emulate_vsyscall(struct pt_regs *regs, unsigned long address)
 	/* Emulate a ret instruction. */
 	regs->ip = caller;
 	regs->sp += 8;
+	fixup_shstk();
+	fixup_ibt();
 	return true;
 
 sigsegv:
-- 
2.17.1

