Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 510F1C00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B6FD2083B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B6FD2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0384B8E00D0; Thu, 21 Feb 2019 18:51:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 011968E00CD; Thu, 21 Feb 2019 18:51:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE0CF8E00D0; Thu, 21 Feb 2019 18:51:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8E67C8E00CD
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:51:06 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 134so310674pfx.21
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:51:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=IakGIipbE34Dq5lbcoYo7VqYScdEo+qlyfphRgvUc/Y=;
        b=pgpgf8+Xt0PSvRqWGUHwCjEuWBby3naKUPnUD8DIUs0PK4qC9JDZGHC+5lI23N6JGD
         9/fp4yWTlejC9q0nJAEaUG7DwunLYbG1NcZkA6SPBS1TYWPOpgJxj5QWY9TjRsHvKOBd
         XH/dPY49yOF7Y5jJ5oGRjuU8p6WrJjKYzEOJif2Xurz/nUkeYgnBkMptP7gP8xJhBD2o
         H0V1A+ESbAynHlB0bNH44js9sS+kzpeX1FLELYI24N3UxE4zFU5VSrnBcArvT45mE+aG
         eF/uji8gDotIgWNQxiDSATB4VjTpQxCC890s55JL4NKppLb9QR2qccQ3ZqKvPUB0xowc
         d2EA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaE7mPucmh7mgGxmZQmiAAc+6fqD/3UZGqvPmU+HIMHvhJGDfJC
	HbMXvWb+Ad7GopADSVeTKg2LfSwfFqAKVYEEYLPrHCV0+PFsl54umJibyvzotVn3dOOwhcC4aOM
	Zk0igkvmh5YtCzMFg3XQsPnM8xdZLenqTJo+XhkN1tpl19ul5PaISCiRPtx0LaUxARQ==
X-Received: by 2002:a17:902:bd43:: with SMTP id b3mr1208840plx.186.1550793066127;
        Thu, 21 Feb 2019 15:51:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZQBgw5v+QGB6Wdf3A8wLZeijmmQhZGRmC1nIKcfesKwL97VAFIMBa4zn3wwh4QuPh9tLzO
X-Received: by 2002:a17:902:bd43:: with SMTP id b3mr1208802plx.186.1550793065408;
        Thu, 21 Feb 2019 15:51:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793065; cv=none;
        d=google.com; s=arc-20160816;
        b=EQDYDUWeeytH40O4EyraQQMz4Y21R3Rd/n09Uo77Gha0LBEG6k9vm4EOLEowmtdHHy
         fbA75wHRj8DytczFzBFY9/P7goHpubpN69gHX5eh8qEm9ALKlceyCm6j/fDLpOX19T28
         JglrBluZ4ab9O+7ukbFRG4lVjV/eRdHhGJ5xJDQkIaVaz5cZDJbPgC0fKjYzPMFb9wNZ
         d8Po7xjqzYX9/YBvNBpxgRYxt/lQzjUwIXmNCNr7ieaKNbRux4wr6ubWBKeKZWKhue/o
         aUkPYqEoUiN0mwUG2FVP2jznwJf/t6ZgCYu7U7bGQuVAOoPnpgYnfisV2dY4az/jSjnv
         VQjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=IakGIipbE34Dq5lbcoYo7VqYScdEo+qlyfphRgvUc/Y=;
        b=SEn1cgHHFLy6L8l5OGHwCYhS2aWM7D2cs1XOY4A1bgLQLQIw1h0eQTafcizcdRqbxl
         YIPtJauWVy8+7ZBa0pIGK4VC6xrhel/BO4t+QgP6v0isyb4Jv1LSC9Tiw4QYs4aJiTZu
         Fu8XKyCzVc5FQjo2+S6tABRUlUdVw+0TKDV9WM+hZpLxxLr2dk1LYKZ7sqq6tuCnHPxJ
         yijIR+FSeo94iC49Y3mUXx2xI2SIw68yI9FMokiOPzTyD2uw4rlfnZu6YDhhcI56i8Vi
         S7JPgBzQU2uX6gpV15dfsNrhE0bIvQeGvBaJaTKOQuRySLO7m9vxzxYraIFgdAvfP8DO
         18gQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c4si238494pfn.83.2019.02.21.15.51.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:51:05 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:51:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="322394921"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga005.fm.intel.com with ESMTP; 21 Feb 2019 15:51:03 -0800
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
	Nadav Amit <namit@vmware.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v3 12/20] x86/alternative: Remove the return value of text_poke_*()
Date: Thu, 21 Feb 2019 15:44:43 -0800
Message-Id: <20190221234451.17632-13-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

The return value of text_poke_early() and text_poke_bp() is useless.
Remove it.

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Masami Hiramatsu <mhiramat@kernel.org>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/include/asm/text-patching.h |  4 ++--
 arch/x86/kernel/alternative.c        | 11 ++++-------
 2 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/arch/x86/include/asm/text-patching.h b/arch/x86/include/asm/text-patching.h
index a75eed841eed..c90678fd391a 100644
--- a/arch/x86/include/asm/text-patching.h
+++ b/arch/x86/include/asm/text-patching.h
@@ -18,7 +18,7 @@ static inline void apply_paravirt(struct paravirt_patch_site *start,
 #define __parainstructions_end	NULL
 #endif
 
-extern void *text_poke_early(void *addr, const void *opcode, size_t len);
+extern void text_poke_early(void *addr, const void *opcode, size_t len);
 
 /*
  * Clear and restore the kernel write-protection flag on the local CPU.
@@ -37,7 +37,7 @@ extern void *text_poke_early(void *addr, const void *opcode, size_t len);
 extern void *text_poke(void *addr, const void *opcode, size_t len);
 extern void *text_poke_kgdb(void *addr, const void *opcode, size_t len);
 extern int poke_int3_handler(struct pt_regs *regs);
-extern void *text_poke_bp(void *addr, const void *opcode, size_t len, void *handler);
+extern void text_poke_bp(void *addr, const void *opcode, size_t len, void *handler);
 extern int after_bootmem;
 extern __ro_after_init struct mm_struct *poking_mm;
 extern __ro_after_init unsigned long poking_addr;
diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alternative.c
index b75bfeda021e..c63707e7ed3d 100644
--- a/arch/x86/kernel/alternative.c
+++ b/arch/x86/kernel/alternative.c
@@ -264,7 +264,7 @@ static void __init_or_module add_nops(void *insns, unsigned int len)
 
 extern struct alt_instr __alt_instructions[], __alt_instructions_end[];
 extern s32 __smp_locks[], __smp_locks_end[];
-void *text_poke_early(void *addr, const void *opcode, size_t len);
+void text_poke_early(void *addr, const void *opcode, size_t len);
 
 /*
  * Are we looking at a near JMP with a 1 or 4-byte displacement.
@@ -666,8 +666,8 @@ void __init alternative_instructions(void)
  * instructions. And on the local CPU you need to be protected again NMI or MCE
  * handlers seeing an inconsistent instruction while you patch.
  */
-void *__init_or_module text_poke_early(void *addr, const void *opcode,
-				       size_t len)
+void __init_or_module text_poke_early(void *addr, const void *opcode,
+				      size_t len)
 {
 	unsigned long flags;
 
@@ -690,7 +690,6 @@ void *__init_or_module text_poke_early(void *addr, const void *opcode,
 		 * that causes hangs on some VIA CPUs.
 		 */
 	}
-	return addr;
 }
 
 __ro_after_init struct mm_struct *poking_mm;
@@ -892,7 +891,7 @@ int poke_int3_handler(struct pt_regs *regs)
  *	  replacing opcode
  *	- sync cores
  */
-void *text_poke_bp(void *addr, const void *opcode, size_t len, void *handler)
+void text_poke_bp(void *addr, const void *opcode, size_t len, void *handler)
 {
 	unsigned char int3 = 0xcc;
 
@@ -934,7 +933,5 @@ void *text_poke_bp(void *addr, const void *opcode, size_t len, void *handler)
 	 * the writing of the new instruction.
 	 */
 	bp_patching_in_progress = false;
-
-	return addr;
 }
 
-- 
2.17.1

