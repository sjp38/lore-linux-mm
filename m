Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D0FDC282CF
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 889F42184D
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 889F42184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 137A48E000D; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C0D98E0003; Mon, 28 Jan 2019 19:39:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D00308E000C; Mon, 28 Jan 2019 19:39:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 62D2D8E0006
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:39:14 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id s27so12711592pgm.4
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:39:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=6v9W4vLv93QaEUNRE1Az/Zy+/uNslS9lkuxp7pzJKCg=;
        b=ovnIdDrjo6+K0mIlqU2mcJYyI+7KqpbcgoXGDZxFWKPQHSXIYPi5gileADA9gLrZ0f
         7dKownvHtxk5k/t5x9uf6leWi73CyF0pEUX8JG6fWj4npdk2ElzbVHF+q7+TLmUJbI0R
         18CRATEPMwDHbwMWBShkYSzAzKOKTzRZ9Pwqdl4+JQUwYx3OndK0GQ6PyuTOBXki9UiR
         mE5gmTPSvwP1yyEcUVBB9Vptm2w3EYnSm1j4xgbJ3VfuMZs592FqQrs5OBVL80F2M2Ht
         QMgjJIxKh4KoXoK34NUyU9u9LlAgsOysfUMV4xTD3bcut36fkeeTZycNPAi8PXIP9OlP
         U7ug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukegwAbj6xb2ZjcVsBiBDnsDEK45EgamzhmfFKLGukGKrTZsLiqH
	94o1Pyzo9FOmiviKnyMJeQ8Bez3+rSNwZjPQ8PpOGZ2I92NCJPBUWUxMcIWnlFAYUbyvyRby85X
	Jl2IjH8cDvSfbvJI9dSya22E5tdtaALkAw+upKK2LLTIlX6xy6gUTjd0xoGiA+pv9Tg==
X-Received: by 2002:a63:c0f:: with SMTP id b15mr21950916pgl.314.1548722354007;
        Mon, 28 Jan 2019 16:39:14 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4apOgYjfWYHgbpvnUEFbBtpaR8Rkk56rzDPgIFRZwExYHPg9fXDQnIv8QlHUwsDVDCz5L1
X-Received: by 2002:a63:c0f:: with SMTP id b15mr21950879pgl.314.1548722353032;
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548722352; cv=none;
        d=google.com; s=arc-20160816;
        b=SRv4fC24zhofdOT5VFmehIGILdIR+Oax8SdyxhS8SSPknA7FgogQAQLsVWZXbQV8e6
         pQlQi3NldT7gIN/lEUzZuEv9TUQvfjkYfjBc35kKYkqnbij90YEQHiXLvmipXLg9WgEC
         WJ4SgDF5pjZk69WgQ4/uAP5NUVaBMzZ9aBPTNkYpItzJ4X9YOdU4ZTO7mkLyC6fsthNv
         orl6G5sxbbI69iefzGjWwoW1soOHIAopv/cfkD68esja0dnFTCB36JXSOcJRbm01XVrl
         UTUmtIseL2IE67N+Y7aXjFX2FQGBaQRVjwITvmiXoqKEU0h/U82Uxh7TK8MKcRTCFLLv
         8PjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=6v9W4vLv93QaEUNRE1Az/Zy+/uNslS9lkuxp7pzJKCg=;
        b=v0oLH6N1acbC5hpZXA2IQi1BwciC6YVBlYubrKF9jeFZUPnZqkg9dn06sGtP+QTcsL
         PcHXSSPDXKl3Ex9lcLV60qGqbJ77EF+dYZhmNZNC9Ahl7RInlcFvOZLN7cBag9H0rjQv
         1+mxljm4BbLu9QiY6R2Ho28Ic+4hSvz82MCIGRs8R5nsJyCtj8oKUM9g+2/s7NG/SvvM
         jSXNRK+xsGJOs1obT9Owsab+ZgsyUB5Rvqy1qEqbT2EGa/UKIEFcb61KHTKKt9tqFJjR
         NosbMlcv63JrPA+EgnohvUdWtz4Endz2Uw/pZsMYXlpouoFo8IPoET3P1En7jxlqiiUe
         1alg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id l7si33052569pfg.245.2019.01.28.16.39.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 16:39:12 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jan 2019 16:39:11 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,535,1539673200"; 
   d="scan'208";a="133921891"
Received: from rpedgeco-desk5.jf.intel.com ([10.54.75.79])
  by orsmga001.jf.intel.com with ESMTP; 28 Jan 2019 16:39:11 -0800
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
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Nadav Amit <namit@vmware.com>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v2 03/20] x86/mm: temporary mm struct
Date: Mon, 28 Jan 2019 16:34:05 -0800
Message-Id: <20190129003422.9328-4-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andy Lutomirski <luto@kernel.org>

Sometimes we want to set a temporary page-table entries (PTEs) in one of
the cores, without allowing other cores to use - even speculatively -
these mappings. There are two benefits for doing so:

(1) Security: if sensitive PTEs are set, temporary mm prevents their use
in other cores. This hardens the security as it prevents exploding a
dangling pointer to overwrite sensitive data using the sensitive PTE.

(2) Avoiding TLB shootdowns: the PTEs do not need to be flushed in
remote page-tables.

To do so a temporary mm_struct can be used. Mappings which are private
for this mm can be set in the userspace part of the address-space.
During the whole time in which the temporary mm is loaded, interrupts
must be disabled.

The first use-case for temporary PTEs, which will follow, is for poking
the kernel text.

[ Commit message was written by Nadav ]

Cc: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Reviewed-by: Masami Hiramatsu <mhiramat@kernel.org>
Tested-by: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/include/asm/mmu_context.h | 32 ++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 19d18fae6ec6..cd0c29e494a6 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -356,4 +356,36 @@ static inline unsigned long __get_current_cr3_fast(void)
 	return cr3;
 }
 
+typedef struct {
+	struct mm_struct *prev;
+} temporary_mm_state_t;
+
+/*
+ * Using a temporary mm allows to set temporary mappings that are not accessible
+ * by other cores. Such mappings are needed to perform sensitive memory writes
+ * that override the kernel memory protections (e.g., W^X), without exposing the
+ * temporary page-table mappings that are required for these write operations to
+ * other cores.
+ *
+ * Context: The temporary mm needs to be used exclusively by a single core. To
+ *          harden security IRQs must be disabled while the temporary mm is
+ *          loaded, thereby preventing interrupt handler bugs from override the
+ *          kernel memory protection.
+ */
+static inline temporary_mm_state_t use_temporary_mm(struct mm_struct *mm)
+{
+	temporary_mm_state_t state;
+
+	lockdep_assert_irqs_disabled();
+	state.prev = this_cpu_read(cpu_tlbstate.loaded_mm);
+	switch_mm_irqs_off(NULL, mm, current);
+	return state;
+}
+
+static inline void unuse_temporary_mm(temporary_mm_state_t prev)
+{
+	lockdep_assert_irqs_disabled();
+	switch_mm_irqs_off(NULL, prev.prev, current);
+}
+
 #endif /* _ASM_X86_MMU_CONTEXT_H */
-- 
2.17.1

