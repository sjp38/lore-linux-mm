Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74376C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D4922084F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D4922084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D56E98E00C6; Thu, 21 Feb 2019 18:50:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2D7B8E00B5; Thu, 21 Feb 2019 18:50:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF8EA8E00C6; Thu, 21 Feb 2019 18:50:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6FF638E00B5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:50:57 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 23so332865pgr.11
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:50:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=ai+qJljkOSM+BNa8+5qAy5ubO6YA1LWKpTMBiUyjPN0=;
        b=nnBPVKcpup5Dmq+AEQ3FF7U22p+kSnntprT1fjSETVki7zv9P4B5pf6qrD5f13N8wf
         5fh2hBIGERlTIJxpi5SaML8OYFYvbNOV1c6IeXRDXjGvBeNIBo0nSFCIpqhRxgEFxfaD
         InpLqPiFaGAc4IjqfmYrSbiz5kf+m605yizp9KYaciEWKJiJZTfecfSt0NrQa3pvv7FU
         gcOGYkCBrV8b06OhRRKiFlSk0tLUqlg8kmbVFOJZ1vdDyL5g+Xq5jZREHPLg3q/Qf243
         +gdW3YQ8/V8KwNmiR7I/sq0h+TsBXUU0WhGvTl2OhQu3l9Z2kedxYkNJdXAnyXijahxB
         nV1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuY8vlE2VipS0y6bcc2oO9C14Dv3lBAHwnblr5vK+hnxxh5KQnoq
	etkyaA0oVQBJesLyPdIlU07FxCxWM1Xl90Wb2CoQnqEKP4GwII90GN+2PNirCz1BW8xu/mDpZrv
	UnJJD2Iou7QVSrrz2nsINob3geu31Wdn7Oix7uyEH5FA66pKqT1/RSAwMLApLoJ2szw==
X-Received: by 2002:a63:6f09:: with SMTP id k9mr1085943pgc.326.1550793057068;
        Thu, 21 Feb 2019 15:50:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaY0DzRqnxCzPxf3K+FhRY7NGJ4uzZ3CmBnKqS144T0ZmdpCxyvonxN4hpRpnO6OrB4+CJO
X-Received: by 2002:a63:6f09:: with SMTP id k9mr1085901pgc.326.1550793056272;
        Thu, 21 Feb 2019 15:50:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793056; cv=none;
        d=google.com; s=arc-20160816;
        b=s7H+5iC0H60rLhoyfVmOW2Zl+dI6udaKfMhDbr3dajFoGKUHCigk/LdA2NRTqvHOxP
         cVe0aC6ioZR3ePGrxhBYwJFYpfX9bpUtNBmJcP1sGei1MxFA0CHnboS62RqzUeYY2kPT
         W7HJt4D7372fYVfRk7us9sHCldglRZV3xN74pPsV3pK8cYl6esf99butV4db3diM0ClC
         YXZmQH+s8OEK/8fYd+Wl0/SiZGn7NCzpjwV2btLXpce5zRYrxz5a03iHhN334S1ljn7Z
         cBjJILw21SwBoqu4U9OZl3oEx2y3960vYKk4jSdDETk+AA/t8LLP2ni9IX/8nJlJlcXw
         31gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=ai+qJljkOSM+BNa8+5qAy5ubO6YA1LWKpTMBiUyjPN0=;
        b=nLBqaB14XduiRlxAw58Y4wfiIsnSQSRfGnFx4eM0+13cnneal9vwdcI9FVzKnBDA7w
         407a37MimoFuL9au8Eeb+D7TBK8vbhlmCoMBLVqz/VpgaLt0s+8Zezk7A7PrQWf5HWtD
         8QPvxZpzHW9++PKd+Pf2HT+9zKX7E/0o8BvnfYLPX0I7GTlqoSavZmVgcFrqf0B/Ipkj
         obs7NpXIrBLHaTD/4ZsyHFiD8V7RX75GMn11HFUoVVVYC+UqEy8UDHONsOqI+2sIq1BE
         acpFpWJXQuHFJvSm1E9y416NONHOAF+cTE3fKHyHQhOUbVu6uByOwddJgkCrv81pHisn
         yB2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c4si238494pfn.83.2019.02.21.15.50.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:50:56 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:50:55 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="322394815"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga005.fm.intel.com with ESMTP; 21 Feb 2019 15:50:54 -0800
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Borislav Petkov <bp@alien8.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Nadav Amit <namit@vmware.com>
Subject: [PATCH v3 03/20] x86/mm: Save DRs when loading a temporary mm
Date: Thu, 21 Feb 2019 15:44:34 -0800
Message-Id: <20190221234451.17632-4-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

Prevent user watchpoints from mistakenly firing while the temporary mm
is being used. As the addresses that of the temporary mm might overlap
those of the user-process, this is necessary to prevent wrong signals
or worse things from happening.

Cc: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
---
 arch/x86/include/asm/mmu_context.h | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index d684b954f3c0..0d6c72ece750 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -13,6 +13,7 @@
 #include <asm/tlbflush.h>
 #include <asm/paravirt.h>
 #include <asm/mpx.h>
+#include <asm/debugreg.h>
 
 extern atomic64_t last_mm_ctx_id;
 
@@ -358,6 +359,7 @@ static inline unsigned long __get_current_cr3_fast(void)
 
 typedef struct {
 	struct mm_struct *prev;
+	unsigned short bp_enabled : 1;
 } temp_mm_state_t;
 
 /*
@@ -380,6 +382,22 @@ static inline temp_mm_state_t use_temporary_mm(struct mm_struct *mm)
 	lockdep_assert_irqs_disabled();
 	state.prev = this_cpu_read(cpu_tlbstate.loaded_mm);
 	switch_mm_irqs_off(NULL, mm, current);
+
+	/*
+	 * If breakpoints are enabled, disable them while the temporary mm is
+	 * used. Userspace might set up watchpoints on addresses that are used
+	 * in the temporary mm, which would lead to wrong signals being sent or
+	 * crashes.
+	 *
+	 * Note that breakpoints are not disabled selectively, which also causes
+	 * kernel breakpoints (e.g., perf's) to be disabled. This might be
+	 * undesirable, but still seems reasonable as the code that runs in the
+	 * temporary mm should be short.
+	 */
+	state.bp_enabled = hw_breakpoint_active();
+	if (state.bp_enabled)
+		hw_breakpoint_disable();
+
 	return state;
 }
 
@@ -387,6 +405,13 @@ static inline void unuse_temporary_mm(temp_mm_state_t prev)
 {
 	lockdep_assert_irqs_disabled();
 	switch_mm_irqs_off(NULL, prev.prev, current);
+
+	/*
+	 * Restore the breakpoints if they were disabled before the temporary mm
+	 * was loaded.
+	 */
+	if (prev.bp_enabled)
+		hw_breakpoint_restore();
 }
 
 #endif /* _ASM_X86_MMU_CONTEXT_H */
-- 
2.17.1

