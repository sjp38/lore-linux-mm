Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E809C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:58:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 103D221738
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:58:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 103D221738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1AEF6B0007; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C07A6B000D; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 813346B0008; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 104AA6B000A
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id u2so8459535pgi.10
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=TDi+ZaxaGFwMJnbi/KBZqpgNpblOvtV7DEanhYCdmjY=;
        b=K640UsPHOTzMPTlgl4a/1Kl4kuLc9ZamKZ9feGQZWGT/p6gwLFKrfcRlN43SwtIYyu
         taLqt4zsuCWDbDKjc3Au4Jn6RUf3V3ld/qwBFSe3VHnk4jduSli1xETTgEudx+9Vv9N/
         6oa+Nhwg573CBHBHjyrdR1hADucpAf1R6/NT74XpQvgbH6MtxZdiCMahPtMRVKh/qRoO
         jUzNRk/TyD5IYjCEYw97m9qWpFjBl2G6oSsyYByQmAEU/QG3uirDHune/Mf2nc9Tg97y
         zY2Gz+ksc1Bmqygwu6kROTrJ1RcbpkZ8OOwrDxsI+Tb2fe9iEyLzQyKxkvgp0tRghrci
         FGJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWK7ntJeANDSMbR9lR2y3ElVD0c4brmsnxSn0OV4FTG/bf6W4tC
	d46afvWnxaYPFmjmLlpKuk+HCqrq9q8LNvV7YO4rTTEBgB40eIt9CVxa4ViLxu93bDPV9Te3fSA
	xpgRtfxqatPawqlO4RV63WvqvW7jq7tB94EVau4YduUqclfHmQ9lYlu7xkoDoGgTHMA==
X-Received: by 2002:a17:902:28ab:: with SMTP id f40mr4435678plb.297.1555959523544;
        Mon, 22 Apr 2019 11:58:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxArDSB4Jn30qhacmD7H5ZmFtydVFqmQG/MM8BhjT2Am0swLevXMahgeTHiZApSAeKmnsI/
X-Received: by 2002:a17:902:28ab:: with SMTP id f40mr4435590plb.297.1555959521973;
        Mon, 22 Apr 2019 11:58:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959521; cv=none;
        d=google.com; s=arc-20160816;
        b=SpRZD1EmgK3HNv/+Tvo8l6+/K10tPuWTj3i4CtYWK/zaTkVDqTr4zIy9U4iFN+Uexd
         mWecqBuMvEIyBoAsjR5gFy24zkZHN+YJav0wV77iUaYbhvLSEalw6WSkaku74gtIh6T9
         djoOAy4ZbmQx9bbe8U4/DaysZu49BZw3GBydsRqAPUpf0zH41M9pS9hmK+L4zsJ6fqh5
         6b5UHnS6/a9d+ZsgsS8u8NbLk+ASRgyQAL5D8e5jsmiHyFIPC8dWg7H4tAk1sElun3qh
         kHslVoLGoQpuu4/VtzKHsmfBQYPu7Q4qybaMYbJ/7vA+yV+XJk0sHZ/u/s+ZOuysiqHV
         4e3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=TDi+ZaxaGFwMJnbi/KBZqpgNpblOvtV7DEanhYCdmjY=;
        b=D+pp+pCitZ4BSWq3nPuc48fNRIoLnQUl0Ln+YifLo0yo6bkiyzJcvScic3jBIDs2HX
         Ls1gWq5QCbUxvxaHC1+C/IdQO5sEER9ZXIvST9bIY3OWtK4BsK9b59rnFecM+hL6hIhW
         vAzZvRa+YpcP1+E3LW2cdvpCVAblO6vYoZOOg88ATF7bnfT9thmNZUbsWdAtepIZ+tDe
         4Wy+/hloHSx4puPFObRZb6bGcb7uocIiQXZlpb9G1VOURjji2r7ZZwdEB2sVld6Pncaz
         GF6AREu3Qa8feFyPcSirjF2ghEj4o+Uz7tlywy97rX9xrFcneLPT1OSqKDF8XBo1oYVd
         rwKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a2si12975117pgn.530.2019.04.22.11.58.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 11:58:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Apr 2019 11:58:41 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,382,1549958400"; 
   d="scan'208";a="136417125"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by orsmga008.jf.intel.com with ESMTP; 22 Apr 2019 11:58:41 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
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
Subject: [PATCH v4 03/23] x86/mm: Introduce temporary mm structs
Date: Mon, 22 Apr 2019 11:57:45 -0700
Message-Id: <20190422185805.1169-4-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andy Lutomirski <luto@kernel.org>

Using a dedicated page-table for temporary PTEs prevents other cores
from using - even speculatively - these PTEs, thereby providing two
benefits:

(1) Security hardening: an attacker that gains kernel memory writing
abilities cannot easily overwrite sensitive data.

(2) Avoiding TLB shootdowns: the PTEs do not need to be flushed in
remote page-tables.

To do so a temporary mm_struct can be used. Mappings which are private
for this mm can be set in the userspace part of the address-space.
During the whole time in which the temporary mm is loaded, interrupts
must be disabled.

The first use-case for temporary mm struct, which will follow, is for
poking the kernel text.

[ Commit message was written by Nadav Amit ]

Cc: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Reviewed-by: Masami Hiramatsu <mhiramat@kernel.org>
Tested-by: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/include/asm/mmu_context.h | 33 ++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 19d18fae6ec6..d684b954f3c0 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -356,4 +356,37 @@ static inline unsigned long __get_current_cr3_fast(void)
 	return cr3;
 }
 
+typedef struct {
+	struct mm_struct *prev;
+} temp_mm_state_t;
+
+/*
+ * Using a temporary mm allows to set temporary mappings that are not accessible
+ * by other cores. Such mappings are needed to perform sensitive memory writes
+ * that override the kernel memory protections (e.g., W^X), without exposing the
+ * temporary page-table mappings that are required for these write operations to
+ * other cores. Using temporary mm also allows to avoid TLB shootdowns when the
+ * mapping is torn down.
+ *
+ * Context: The temporary mm needs to be used exclusively by a single core. To
+ *          harden security IRQs must be disabled while the temporary mm is
+ *          loaded, thereby preventing interrupt handler bugs from overriding
+ *          the kernel memory protection.
+ */
+static inline temp_mm_state_t use_temporary_mm(struct mm_struct *mm)
+{
+	temp_mm_state_t state;
+
+	lockdep_assert_irqs_disabled();
+	state.prev = this_cpu_read(cpu_tlbstate.loaded_mm);
+	switch_mm_irqs_off(NULL, mm, current);
+	return state;
+}
+
+static inline void unuse_temporary_mm(temp_mm_state_t prev)
+{
+	lockdep_assert_irqs_disabled();
+	switch_mm_irqs_off(NULL, prev.prev, current);
+}
+
 #endif /* _ASM_X86_MMU_CONTEXT_H */
-- 
2.17.1

