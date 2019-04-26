Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DATE_IN_PAST_06_12,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A507C4321A
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E531208C2
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="c8S+0Eig"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E531208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94E256B026B; Sat, 27 Apr 2019 02:43:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D4306B026C; Sat, 27 Apr 2019 02:43:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7065C6B026D; Sat, 27 Apr 2019 02:43:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9D26B026B
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:24 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id s26so3555564pfm.18
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=0/++kCIdz9NinK/+MFp07AkuSYwP6lr30tD8Xi+P1Ns=;
        b=qhyygjg4RJM24OYfFTjZaupfDJ+o1dMgUGdKMjMGKQr689R0n0L+WfVpqhRmdMlGLv
         cPZzYkeJVW7fs92kZT75crDHq4YAiC+CUW3WGUr9Dpx4NibZcCk4K3oK6G/jc1qSwQAT
         GO6C5e3n8HII/YlPX1OMAcB9ARgGNcCLPjrEe2CK9nObtWz1ZGoQ+FY4R+fP9BfaHRBt
         oTpaOjze1QXROVyetRLzDFMcGX4jamLzoxmL1+GzbhuR/tgQIPIwWd3Cy9nLH6OSkJo6
         FBJjqKmgJFT8/0Z6ZT1LrPN5QwOZ6l7pAdHPmzklRwY+NF7BVrvwy6b513uWAgVJRaTv
         6Tcw==
X-Gm-Message-State: APjAAAUhnrNZ1iH0UtWnWdM6PZfXGSjnhtuBfOVy7K/KW+3k0jzcPXsy
	wgefLRNzeKRQZj0fFry3PBlJJlKmDfSkx0pFBUzj41L0w75bRwt/qbWDVNIHsDh41r2ZGCvMLUn
	3KjE1grjrahbGOBrY9b199dbNFWDBMa9h1VqIcSLYyaMzdlg/vEvqbcrkupkh9pJ+mg==
X-Received: by 2002:a63:161d:: with SMTP id w29mr25050122pgl.395.1556347403860;
        Fri, 26 Apr 2019 23:43:23 -0700 (PDT)
X-Received: by 2002:a63:161d:: with SMTP id w29mr25050068pgl.395.1556347402553;
        Fri, 26 Apr 2019 23:43:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347402; cv=none;
        d=google.com; s=arc-20160816;
        b=tqLYQojMRIuwoE5/MfWjzprmB1YaYNB6D9wxdw7snuM/Q9FTOC2cumw5yrw6mDt0l8
         BqT0EL9KcJK/gM7Tm7OSpGKSixkv+zxVCfEUlh7YZSrXFyla5ngFo6eC/1Nxxt9OHLv5
         6Q2qPUQXuiLWnKQzNILot+pc9UhUt6sxvFydUJQLx0p38+H3W0l7Zi6FCofTXNLyhO7d
         OlCFsD3Z4gKO31IS5YJFro3hDYbryN62CE0wj7qMcYKa9XUdfk3GfIVkcb0+sqImYjGe
         293wODY3mZZkloMSXNhbjRmNer03ie6hwkkXKVBh1N9NC6L80s9v9PRqk62dzZwPtM+g
         GwLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=0/++kCIdz9NinK/+MFp07AkuSYwP6lr30tD8Xi+P1Ns=;
        b=lpOcdu/Sao0aRCKoqpZwt8PsiwuubAHW/311VYK/ovflClcxI0dm7ySEjP1mX3D3/Q
         Zh31jMM3OEvs2Icj4jUni5O2nzi4GGJ4YryQKqrYNF5yX1PeVQ7F+YvvHmj/0M1OZNqw
         rBHjiUS3vBaWCDZg1LglPUaIkpivycF3bjXMxhWP/dDA9Sai89DxMqx3BOwWZPFcD22m
         ZczMzUxtijG5xwfUCc6kc8IXsDHGSRWtNaGg0ew50fgGagCkGvG9JzDvQYUCADS1uYWX
         uCuNplc6BjSiMrhZpEv1NAlkTBsDYLQTfBrjX08cweOH4i2jRBc9Uu0jhGsVM1dchOCF
         JVkw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=c8S+0Eig;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g95sor26343843plb.5.2019.04.26.23.43.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=c8S+0Eig;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=0/++kCIdz9NinK/+MFp07AkuSYwP6lr30tD8Xi+P1Ns=;
        b=c8S+0EigCS6E8XvKa358lLe6LCVfzSFVuNJOVAHrtcVTOWv87dH8gGM88UuaQDW1Ql
         IEkRJXiL08aosg7wFKjOifGHvdFqqFOyIVAPTy32+RTxwh4obVo1hvSc3VrfhbIWeRKu
         ZJA1hj0UwfXTRnrJeU5WqlBmd3LvGogakdG6r5O5HCHdIZ01YxMYWq3GzL7qFIqoHj+M
         ImxYzSZVWsC/5XsbT15MbduZoaGGNML2WLcc4snNS8OhI4V0R2fmhxvtsFVBQg8hBw68
         V9bB/2b3yhVaonMZdGNuWp1CujPDm/DoQRIcyXEO1I8gk21/7x6PmT++18rtH9HSkyQc
         PS4g==
X-Google-Smtp-Source: APXvYqwD3aMW9+fxSDptS7zjHtrUL6axD8ahdhvdTbAECEHQ3uOfUvnD7wIP6ssynsnm5EaQ/VhgYw==
X-Received: by 2002:a17:902:20c6:: with SMTP id v6mr48012719plg.276.1556347402023;
        Fri, 26 Apr 2019 23:43:22 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:21 -0700 (PDT)
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
	Masami Hiramatsu <mhiramat@kernel.org>,
	Jessica Yu <jeyu@kernel.org>
Subject: [PATCH v6 12/24] x86/module: Avoid breaking W^X while loading modules
Date: Fri, 26 Apr 2019 16:22:51 -0700
Message-Id: <20190426232303.28381-13-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

When modules and BPF filters are loaded, there is a time window in
which some memory is both writable and executable. An attacker that has
already found another vulnerability (e.g., a dangling pointer) might be
able to exploit this behavior to overwrite kernel code. Prevent having
writable executable PTEs in this stage.

In addition, avoiding having W+X mappings can also slightly simplify the
patching of modules code on initialization (e.g., by alternatives and
static-key), as would be done in the next patch. This was actually the
main motivation for this patch.

To avoid having W+X mappings, set them initially as RW (NX) and after
they are set as RO set them as X as well. Setting them as executable is
done as a separate step to avoid one core in which the old PTE is cached
(hence writable), and another which sees the updated PTE (executable),
which would break the W^X protection.

Cc: Kees Cook <keescook@chromium.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Jessica Yu <jeyu@kernel.org>
Suggested-by: Thomas Gleixner <tglx@linutronix.de>
Suggested-by: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/alternative.c | 28 +++++++++++++++++++++-------
 arch/x86/kernel/module.c      |  2 +-
 include/linux/filter.h        |  1 +
 kernel/module.c               |  5 +++++
 4 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alternative.c
index 599203876c32..3d2b6b6fb20c 100644
--- a/arch/x86/kernel/alternative.c
+++ b/arch/x86/kernel/alternative.c
@@ -668,15 +668,29 @@ void __init alternative_instructions(void)
  * handlers seeing an inconsistent instruction while you patch.
  */
 void *__init_or_module text_poke_early(void *addr, const void *opcode,
-					      size_t len)
+				       size_t len)
 {
 	unsigned long flags;
-	local_irq_save(flags);
-	memcpy(addr, opcode, len);
-	local_irq_restore(flags);
-	sync_core();
-	/* Could also do a CLFLUSH here to speed up CPU recovery; but
-	   that causes hangs on some VIA CPUs. */
+
+	if (boot_cpu_has(X86_FEATURE_NX) &&
+	    is_module_text_address((unsigned long)addr)) {
+		/*
+		 * Modules text is marked initially as non-executable, so the
+		 * code cannot be running and speculative code-fetches are
+		 * prevented. Just change the code.
+		 */
+		memcpy(addr, opcode, len);
+	} else {
+		local_irq_save(flags);
+		memcpy(addr, opcode, len);
+		local_irq_restore(flags);
+		sync_core();
+
+		/*
+		 * Could also do a CLFLUSH here to speed up CPU recovery; but
+		 * that causes hangs on some VIA CPUs.
+		 */
+	}
 	return addr;
 }
 
diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
index b052e883dd8c..cfa3106faee4 100644
--- a/arch/x86/kernel/module.c
+++ b/arch/x86/kernel/module.c
@@ -87,7 +87,7 @@ void *module_alloc(unsigned long size)
 	p = __vmalloc_node_range(size, MODULE_ALIGN,
 				    MODULES_VADDR + get_module_load_offset(),
 				    MODULES_END, GFP_KERNEL,
-				    PAGE_KERNEL_EXEC, 0, NUMA_NO_NODE,
+				    PAGE_KERNEL, 0, NUMA_NO_NODE,
 				    __builtin_return_address(0));
 	if (p && (kasan_module_alloc(p, size) < 0)) {
 		vfree(p);
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 6074aa064b54..14ec3bdad9a9 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -746,6 +746,7 @@ static inline void bpf_prog_unlock_ro(struct bpf_prog *fp)
 static inline void bpf_jit_binary_lock_ro(struct bpf_binary_header *hdr)
 {
 	set_memory_ro((unsigned long)hdr, hdr->pages);
+	set_memory_x((unsigned long)hdr, hdr->pages);
 }
 
 static inline void bpf_jit_binary_unlock_ro(struct bpf_binary_header *hdr)
diff --git a/kernel/module.c b/kernel/module.c
index 0b9aa8ab89f0..2b2845ae983e 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -1950,8 +1950,13 @@ void module_enable_ro(const struct module *mod, bool after_init)
 		return;
 
 	frob_text(&mod->core_layout, set_memory_ro);
+	frob_text(&mod->core_layout, set_memory_x);
+
 	frob_rodata(&mod->core_layout, set_memory_ro);
+
 	frob_text(&mod->init_layout, set_memory_ro);
+	frob_text(&mod->init_layout, set_memory_x);
+
 	frob_rodata(&mod->init_layout, set_memory_ro);
 
 	if (after_init)
-- 
2.17.1

