Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 018F7C282CD
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 030292184D
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 030292184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 373AF8E0003; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30E358E000A; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09F538E0009; Mon, 28 Jan 2019 19:39:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8462F8E0003
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:39:14 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id u17so12647481pgn.17
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:39:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=+wi88hx6YH8dIFlmUwZIgPkFWlSQwDsLhghYbt+YCm0=;
        b=VDYt+W5COjnG3YpCAr9fxT8qkCGcQevCStthLg72NUrgMftyGa+p7jmQRp5jW7nZbQ
         CrbshApQHXRICbzdO6ujMFCk5e+4gxlqt7c1EfA3PXs4d4zrmrXfkl1VXmi4EqU24UUh
         ifVYEVkNJ4XyDyYMj7h7+qoC55u1F4Xpo036hGh/yfl7QiHy1toqFObusotRIJbt5F2d
         2TGqM69VRm61cdqIYBJczsImhxz5EznOb9rgnF6wblXbdPhJj9InOOEyRBdtIdyva8rb
         lH9ZnT1nOUA2TFbMpH+B5bLrbEivxE+gi5jfUi3f/VqA5TSthfSRU+lWtS5//9Kdo02Q
         1YAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukeQAlt2dt4LYmuLgajs6GonLI1eD+XCfKeWG26h7hrtn8HVyDo7
	nz377jkS3SaiIjADKDaL8wCG5UfFaaWk6t2BUrxZSawmWHExuPjQ2grb6C6wh7gN9bYCTEQRQhU
	O2XHntjHBmxSLRwotXoZCPz+naLalWe/eGBQUIKEt6VD/zTQ3lWdoBuJ27DeykKQCGA==
X-Received: by 2002:a17:902:6113:: with SMTP id t19mr23186416plj.248.1548722354190;
        Mon, 28 Jan 2019 16:39:14 -0800 (PST)
X-Google-Smtp-Source: ALg8bN63uyFqWqF/hsM1JhZLnlvXme4b3OvpUuM/rK1fNLZN54IjYvcxYREgQR4j/ua5cN4cmFda
X-Received: by 2002:a17:902:6113:: with SMTP id t19mr23186367plj.248.1548722353303;
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548722353; cv=none;
        d=google.com; s=arc-20160816;
        b=GtJyvAzsrl2FWTQrhpyx+EFYXXsnVhjvEGge8ujp0QANr/OYeO9xFCAGhG9zAqeg7p
         dfDLxWWY7aQgT1WdScp9bAF1LiKz3UWEuF6waM/lArd3oB6L3jox0mbw8ZOP/lFOf4ay
         97Vx21kiN6OeNuRZFXrmVwoZb6chRR9szjTjZ+p6zQ+7jXCsUg1lttlRAedcCW7KjA/P
         7JONj6IuPHKE2b9WlmaZAnBxnsYPS5uFZSyNlb2w5z2JLtDS9lIIMtldqqVBzxS/k3rt
         VfgYFk4S6JuO2F9cETBJscXdDSWFfUI2RFX9yWBO4g1GRpCSkFWs+VHq/QkKKubmE6If
         BtUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=+wi88hx6YH8dIFlmUwZIgPkFWlSQwDsLhghYbt+YCm0=;
        b=IqqQzoQyxTbTE7aRQaig0RJNpioTI63sAhcoS6crO4dUV9W6gEHGmJhvIWcETh83/2
         KZfK3SRvxVjLCF8rCGRA3ZbjyWrDohSpqAE4Xwxq6PpGIFRTO9Z/Uyl/XwFaRevWX8SN
         qU3nC7SHsmJnBgRxQnWSFxTbhlJMgxCn/+oConAW70/aH+ml5/RxWETMtm3JxYFauws8
         yC//PA3DjR3MKVjp0buMzYPVI9pn8Iz/MdYXJDv4rLdmQkZvSYAGlF2TYDxQNlBc6beq
         1XWSkJoD5ZBxrTLG+c7A5fhOxjuboe2n79k+H+uMl+dEIc1ltMJdLwAPRYN0CGBXKVMn
         sglA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id l7si33052569pfg.245.2019.01.28.16.39.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
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
   d="scan'208";a="133921898"
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
	Nadav Amit <namit@vmware.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v2 05/20] x86/alternative: initializing temporary mm for patching
Date: Mon, 28 Jan 2019 16:34:07 -0800
Message-Id: <20190129003422.9328-6-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

To prevent improper use of the PTEs that are used for text patching, we
want to use a temporary mm struct. We initailize it by copying the init
mm.

The address that will be used for patching is taken from the lower area
that is usually used for the task memory. Doing so prevents the need to
frequently synchronize the temporary-mm (e.g., when BPF programs are
installed), since different PGDs are used for the task memory.

Finally, we randomize the address of the PTEs to harden against exploits
that use these PTEs.

Cc: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Reviewed-by: Masami Hiramatsu <mhiramat@kernel.org>
Tested-by: Masami Hiramatsu <mhiramat@kernel.org>
Suggested-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/include/asm/pgtable.h       |  3 +++
 arch/x86/include/asm/text-patching.h |  2 ++
 arch/x86/kernel/alternative.c        |  3 +++
 arch/x86/mm/init_64.c                | 36 ++++++++++++++++++++++++++++
 init/main.c                          |  3 +++
 5 files changed, 47 insertions(+)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 40616e805292..e8f630d9a2ed 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1021,6 +1021,9 @@ static inline void __meminit init_trampoline_default(void)
 	/* Default trampoline pgd value */
 	trampoline_pgd_entry = init_top_pgt[pgd_index(__PAGE_OFFSET)];
 }
+
+void __init poking_init(void);
+
 # ifdef CONFIG_RANDOMIZE_MEMORY
 void __meminit init_trampoline(void);
 # else
diff --git a/arch/x86/include/asm/text-patching.h b/arch/x86/include/asm/text-patching.h
index f8fc8e86cf01..a75eed841eed 100644
--- a/arch/x86/include/asm/text-patching.h
+++ b/arch/x86/include/asm/text-patching.h
@@ -39,5 +39,7 @@ extern void *text_poke_kgdb(void *addr, const void *opcode, size_t len);
 extern int poke_int3_handler(struct pt_regs *regs);
 extern void *text_poke_bp(void *addr, const void *opcode, size_t len, void *handler);
 extern int after_bootmem;
+extern __ro_after_init struct mm_struct *poking_mm;
+extern __ro_after_init unsigned long poking_addr;
 
 #endif /* _ASM_X86_TEXT_PATCHING_H */
diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alternative.c
index 12fddbc8c55b..ae05fbb50171 100644
--- a/arch/x86/kernel/alternative.c
+++ b/arch/x86/kernel/alternative.c
@@ -678,6 +678,9 @@ void *__init_or_module text_poke_early(void *addr, const void *opcode,
 	return addr;
 }
 
+__ro_after_init struct mm_struct *poking_mm;
+__ro_after_init unsigned long poking_addr;
+
 static void *__text_poke(void *addr, const void *opcode, size_t len)
 {
 	unsigned long flags;
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index bccff68e3267..125c8c48aa24 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -53,6 +53,7 @@
 #include <asm/init.h>
 #include <asm/uv/uv.h>
 #include <asm/setup.h>
+#include <asm/text-patching.h>
 
 #include "mm_internal.h"
 
@@ -1383,6 +1384,41 @@ unsigned long memory_block_size_bytes(void)
 	return memory_block_size_probed;
 }
 
+/*
+ * Initialize an mm_struct to be used during poking and a pointer to be used
+ * during patching.
+ */
+void __init poking_init(void)
+{
+	spinlock_t *ptl;
+	pte_t *ptep;
+
+	poking_mm = copy_init_mm();
+	BUG_ON(!poking_mm);
+
+	/*
+	 * Randomize the poking address, but make sure that the following page
+	 * will be mapped at the same PMD. We need 2 pages, so find space for 3,
+	 * and adjust the address if the PMD ends after the first one.
+	 */
+	poking_addr = TASK_UNMAPPED_BASE;
+	if (IS_ENABLED(CONFIG_RANDOMIZE_BASE))
+		poking_addr += (kaslr_get_random_long("Poking") & PAGE_MASK) %
+			(TASK_SIZE - TASK_UNMAPPED_BASE - 3 * PAGE_SIZE);
+
+	if (((poking_addr + PAGE_SIZE) & ~PMD_MASK) == 0)
+		poking_addr += PAGE_SIZE;
+
+	/*
+	 * We need to trigger the allocation of the page-tables that will be
+	 * needed for poking now. Later, poking may be performed in an atomic
+	 * section, which might cause allocation to fail.
+	 */
+	ptep = get_locked_pte(poking_mm, poking_addr, &ptl);
+	BUG_ON(!ptep);
+	pte_unmap_unlock(ptep, ptl);
+}
+
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 /*
  * Initialise the sparsemem vmemmap using huge-pages at the PMD level.
diff --git a/init/main.c b/init/main.c
index e2e80ca3165a..f5947ba53bb4 100644
--- a/init/main.c
+++ b/init/main.c
@@ -496,6 +496,8 @@ void __init __weak thread_stack_cache_init(void)
 
 void __init __weak mem_encrypt_init(void) { }
 
+void __init __weak poking_init(void) { }
+
 bool initcall_debug;
 core_param(initcall_debug, initcall_debug, bool, 0644);
 
@@ -730,6 +732,7 @@ asmlinkage __visible void __init start_kernel(void)
 	taskstats_init_early();
 	delayacct_init();
 
+	poking_init();
 	check_bugs();
 
 	acpi_subsystem_init();
-- 
2.17.1

