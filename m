Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DATE_IN_PAST_06_12,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A304FC43218
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D309208C2
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sZ/qLuZJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D309208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26D4C6B026E; Sat, 27 Apr 2019 02:43:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F6336B026F; Sat, 27 Apr 2019 02:43:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C97E6B0270; Sat, 27 Apr 2019 02:43:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BD3BF6B026E
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:26 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id v9so3485392pgg.8
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=RkWBxdSztj8rR+UGwRQ8u46DAnXrPhDoGJsRNKYizGU=;
        b=bmWTaZ90OrJcMeQdhb/axqnoYxiC25pLO+eERU26KvVnwaTmFrPb4CodLmE2KjY09M
         1np2OFnnRUr4kPNUM4WLmh3R1Q9HzRE6GxYFy1T0mHgq9wmbzYDplTTMqGja9VGhyqRS
         Tjva+yZShtggvdeJAM6L4pFoZggUJfFANzeZbV6AgkQVbv4stxLSzY8W5ti40IKmlW2t
         R25uFrl8DX83f86KLwc4LWaqW1W97a1PQ0wmBEsEgX6fw6w2XyVsx/X/afjezrXjuolV
         hqToZQqGvQjh3gGuK841necUs7Idvi5uC8asba/nH+f7e0HAb8DYKEh7EfKq5sryhkDk
         UL+Q==
X-Gm-Message-State: APjAAAVB09xDKnMkvYEJfgqBO6fHULapcdjmekplSBcSI0AAixTOUEpT
	LXz2URvyn1mpKku2xup6zxzOeKQsruoP3PrVimrpfCcGagi2BdbAPKDYh/W+BWoI97yWXexwk6H
	/9Bm83HVzjQ0epapbeDS86HopSM/4Y6Vk6b69oJ2HIs8F67ZzqBqdZShsaTPMXEHM9w==
X-Received: by 2002:a17:902:1024:: with SMTP id b33mr49035262pla.46.1556347406438;
        Fri, 26 Apr 2019 23:43:26 -0700 (PDT)
X-Received: by 2002:a17:902:1024:: with SMTP id b33mr49035210pla.46.1556347405369;
        Fri, 26 Apr 2019 23:43:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347405; cv=none;
        d=google.com; s=arc-20160816;
        b=vHJwbTjoFEepOle0F0Ssxz7nwWzuZFuT2yLHuVbv9TLcpIHs31cqgjbNn9PZHr19+E
         DJFwnQtWnTZkLypbzafONZtV4dFOXTruOW+w/ui3q7/l3RJ3hFsGd9Kaf1/HSG8bBNd4
         UmK5V8BYwkBLE+vCOkdS9qtPvAw9bARnbtASJCT7QRRDd2FrlpeeF8mkQGnXQo2SJFjJ
         uONpKMa2jWLJBMEkaWDMYvWC2LZMUEdr+qHHS2GY5b7ckdXPmjj4jiu+YS1gwfL3kBo9
         SqlqbhlHmp+L43IbdHm1bUzNIR/+FeDF6dIPMavsX3zSBu1kBe6qCm8kMthC+RUvlEIf
         jE6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=RkWBxdSztj8rR+UGwRQ8u46DAnXrPhDoGJsRNKYizGU=;
        b=WkaTzNjnJ2vUoXU/BZ23J7b+ojRWmCJ5RsXbfR/hiVjqYLoBQ/B/i2AkQlccnDLGJS
         bfEYajikSCLm0aMcNtLDQh5/NXnVaO+2kWPQABLIoJTnCoKpzwue3w9CPVuJPNYIhOWB
         kQIjcpS0yvC6dZt8LROn6Fcc0eaFaY5UReKTE4Vjd+lIGJ3muf9p6rf5ZOjuQG5htAQ6
         qIuvJN0GQGt1XBPccB8T10ufemCw4XWSEMVWTmhJwScBoYM1zFkSt3zWMaiEMC2/6AyX
         Mmb0Hjxo3H7s/dxMS6mp0InBjZJXYYSHXdiIZknGl6UB/2yjSi1sr7guPRPlPDqTK7pg
         8pmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="sZ/qLuZJ";
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f24sor30579014pfn.22.2019.04.26.23.43.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="sZ/qLuZJ";
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=RkWBxdSztj8rR+UGwRQ8u46DAnXrPhDoGJsRNKYizGU=;
        b=sZ/qLuZJUAyo8qbKkeTMfaDU5l+q5915X9t7GRxTKJHbpjNKTHl8pciE33HsZyKxMj
         FHDGynPK6j9EMARDmUngJuJvUrJzSdZ856tWm7M07XqPW/SWzM6ZNX5zl88lma+UJQTP
         glz3jYPedES7CBs45n1TgBVlpwj8P8UlUX7TYH4J9CMC1SwMSQqAcgs/6v2TrFDCMTCc
         9+WmCz+Xk4CqkdBn0hJ5YGF1/DTIcg/k9CSmxM2My4drnNNp3ITpwY4FI+yvE/59hq2C
         LbPH5HAGU5SG85yKGAzKgHwuQvpQ2iezoip/gl/Zm0v6Wm0PDoU46D9nD3GQpDAmdtBS
         P0cQ==
X-Google-Smtp-Source: APXvYqymwtMNRBHdVQWTPWr7iZe7bQ6p95NnoQCCbzB15xIf0gFL50JmokfCH/M9gUZzJVqeF2oaxg==
X-Received: by 2002:aa7:81d0:: with SMTP id c16mr50378631pfn.132.1556347404841;
        Fri, 26 Apr 2019 23:43:24 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:24 -0700 (PDT)
From: nadav.amit@gmail.com
To: Peter Zijlstra <peterz@infradead.org>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
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
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Nadav Amit <namit@vmware.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>
Subject: [PATCH v6 14/24] x86/alternative: Remove the return value of text_poke_*()
Date: Fri, 26 Apr 2019 16:22:53 -0700
Message-Id: <20190426232303.28381-15-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
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

