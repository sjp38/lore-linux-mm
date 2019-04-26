Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1454FC4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:33:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA6962084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:33:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA6962084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7692C6B000C; Fri, 26 Apr 2019 03:33:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 740516B0285; Fri, 26 Apr 2019 03:33:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6562A6B0286; Fri, 26 Apr 2019 03:33:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2EFE46B000C
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:33:08 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id b7so1431987plb.17
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:33:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=kjKVRKltof8mlgZuDLjB7nrEkQ/mRzwiPTIy69QpyZ8=;
        b=QhhpdRCvnqW8KzqfXnnXaRFCqLheWTghKmfESS5Oi9WY4EM8IJqXW2tol2sZ2Z4fZn
         s7YvXTxsLu+j5OOKpOzBn282bSDoSkjpd0yLfowfs1wOEGawZl9o+C48hoI/9uUHFVGT
         Z/E4/RUpxDX1uM2VBBRgNEj3nCsrE70rzetz7dU29RcQ/FP5K8aDLg+Dq4FtS7UKleES
         qLZELg2TQmVO9eu7maf/4edxWL+UDQWrXC24YFBqQlDSD6N58msHngp40kIyboLhSm/b
         WWadevf8IWtBgT8q3ulBjiT5j9gQqg9nUVRP+0Go336oOT6wsrtfkDWiPp0UeYaKc6Ir
         kWww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAVXkTQk6mGSG52CGxdxHrbXVCVDjYuKHAq2J29IJ/lPvXsZHRMB
	jd36SYZmCpz0/ZtZKUNAFeZPCzFBqFd/4x0pPCKlrl0UV9AdDkRqmfSpPEe45/tqa5UYzNqJgGg
	6EukBBWpSYukoH0cDxaYn9t3/RvjtKaJ3wo2sIHqNl2u0PG8yXbCe8RujYXeRUfcLJQ==
X-Received: by 2002:a17:902:2a6a:: with SMTP id i97mr44508949plb.273.1556263987848;
        Fri, 26 Apr 2019 00:33:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx6bJE/C7x3IiovG2PnRtewK1o1Z5Zz1uIH2NDiNK6PrTRU5/PIVPbPuAj8dduMOoGV4IT6
X-Received: by 2002:a17:902:2a6a:: with SMTP id i97mr44502760plb.273.1556263908144;
        Fri, 26 Apr 2019 00:31:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556263908; cv=none;
        d=google.com; s=arc-20160816;
        b=nLcPIKbslzSHeybX6xpoONIpVczYWcNWh+pdECe0j92s+tMCKD7D6+ePni3jHG5r6b
         PGOhei21PTtKnqBFRykydrGTKRtm3nCJhOQD7jMqbWCHoVm5qIstBIlaQ0iwTGtDqmeU
         p75buFXA8t1AdvuvpcgSth1H0p9YEAIdpGCDECdYqlABdkAGBphnF4iMqM4S8c8AK68y
         9nzMn/7AiiiQJjYtXri9MjSQewCPBj9eHe/lBHd80fxuFgyycIzfw+74YUW8xidAsglc
         cWV+cTmzRp/rAZO28mPp5kIHMEmYYJwuzLZg5fzKda9Hs4pMmjxEKBAfloi5QS9Jd05G
         56Fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=kjKVRKltof8mlgZuDLjB7nrEkQ/mRzwiPTIy69QpyZ8=;
        b=AsvICAMhn9XReM5X11jnBa2Vw4Cu4s6yciGPxDcGGVBXjsTLxCEhyZaYu2OND0uf3I
         oP7mlKCH/AipRbffvl00U87OIEj6BjJt2Xo9axQ3he12JQ3UCtj5Zn8lIjMBuPydWaax
         YWxsh/RKONHrN/cxDTkAbkoYDUMzA7HsLpTWTmjFTDxhMn1FnqEGMJ6++8AiCRSmI1lj
         StzhHGMgZ1v73r3FozovYW76OmEYAQxTicz9tM24KAs44O2qtIrNDV1+6hNtiXEn8LzG
         40XN/RN6Of6IECLyaMf4bXtjjdhZPCqCIY1pO1aY2F/jOYhdNLmCX92dgMa8A5imfUoB
         T21w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id f9si22844507pgq.347.2019.04.26.00.31.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Apr 2019 00:31:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Fri, 26 Apr 2019 00:31:44 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id CF76F41298;
	Fri, 26 Apr 2019 00:31:45 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
To: Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>
CC: <linux-kernel@vger.kernel.org>, <x86@kernel.org>, <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen
	<dave.hansen@linux.intel.com>, <linux_dti@icloud.com>,
	<linux-integrity@vger.kernel.org>, <linux-security-module@vger.kernel.org>,
	<akpm@linux-foundation.org>, <kernel-hardening@lists.openwall.com>,
	<linux-mm@kvack.org>, <will.deacon@arm.com>, <ard.biesheuvel@linaro.org>,
	<kristen@linux.intel.com>, <deneen.t.dock@intel.com>, Rick Edgecombe
	<rick.p.edgecombe@intel.com>, Nadav Amit <namit@vmware.com>, Kees Cook
	<keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>, Masami
 Hiramatsu <mhiramat@kernel.org>
Subject: [PATCH v5 13/23] x86/alternative: Remove the return value of text_poke_*()
Date: Thu, 25 Apr 2019 17:11:33 -0700
Message-ID: <20190426001143.4983-14-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426001143.4983-1-namit@vmware.com>
References: <20190426001143.4983-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-002.vmware.com: namit@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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
index 3d2b6b6fb20c..18f959975ea0 100644
--- a/arch/x86/kernel/alternative.c
+++ b/arch/x86/kernel/alternative.c
@@ -265,7 +265,7 @@ static void __init_or_module add_nops(void *insns, unsigned int len)
 
 extern struct alt_instr __alt_instructions[], __alt_instructions_end[];
 extern s32 __smp_locks[], __smp_locks_end[];
-void *text_poke_early(void *addr, const void *opcode, size_t len);
+void text_poke_early(void *addr, const void *opcode, size_t len);
 
 /*
  * Are we looking at a near JMP with a 1 or 4-byte displacement.
@@ -667,8 +667,8 @@ void __init alternative_instructions(void)
  * instructions. And on the local CPU you need to be protected again NMI or MCE
  * handlers seeing an inconsistent instruction while you patch.
  */
-void *__init_or_module text_poke_early(void *addr, const void *opcode,
-				       size_t len)
+void __init_or_module text_poke_early(void *addr, const void *opcode,
+				      size_t len)
 {
 	unsigned long flags;
 
@@ -691,7 +691,6 @@ void *__init_or_module text_poke_early(void *addr, const void *opcode,
 		 * that causes hangs on some VIA CPUs.
 		 */
 	}
-	return addr;
 }
 
 __ro_after_init struct mm_struct *poking_mm;
@@ -893,7 +892,7 @@ NOKPROBE_SYMBOL(poke_int3_handler);
  *	  replacing opcode
  *	- sync cores
  */
-void *text_poke_bp(void *addr, const void *opcode, size_t len, void *handler)
+void text_poke_bp(void *addr, const void *opcode, size_t len, void *handler)
 {
 	unsigned char int3 = 0xcc;
 
@@ -935,7 +934,5 @@ void *text_poke_bp(void *addr, const void *opcode, size_t len, void *handler)
 	 * the writing of the new instruction.
 	 */
 	bp_patching_in_progress = false;
-
-	return addr;
 }
 
-- 
2.17.1

