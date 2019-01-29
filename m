Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55631C282CF
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CB29217F5
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CB29217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42FBD8E000B; Mon, 28 Jan 2019 19:39:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1887C8E000C; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1EF38E000C; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E1768E000F
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:39:15 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id p15so15383154pfk.7
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:39:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=RlvGVO5EXL5pU3ciPdRuGoj9s4OpHijn3MolXrSDLC0=;
        b=jGRFN9A6fnlKZJDpuWS/euEr83US6Zv3ThvepVthXqY6lg1PgLmsNHHGELfPZrEMh/
         +ezbtrXVpXGBOtfqtXiq/TkjFbX+vf1tQLE1I9Fklg6vqIPAOJ6TLBC88LwoBQSWfPlN
         HK+h1h8at+ERBkfM9tEvAzR0fxJyA8rrIyehcHTqYbsVz4kxXqmV1IclV7QqO6s3hZ2u
         WLNNOlGkivDRbQICfCSpb//iyGybgNCmpIKS+N7cUAN/FPhtnxjHgmSPAadNpyQxZiOv
         twVOz/Yi3W6yo3KvAGEpd9Ld2z5Gs887+5/dDByIxr9Wfw95IU2EftjfxV0gOivK6scI
         TPQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukely0L598Nq6WvXbzriruWq86/lSzp6LLIKwBPffZu4okOSJiPj
	iwgVXb4xP1qbbxge8Sp/CVtgog/KHUIRAxkMXc3zHr4eP2s840KMVPgQHkihIyWWjxhPhJoy6nJ
	5lfm9WBD2KROLVo9EfAW46fHnMb1qZuaxTMRy/Uo5gu8gPfIBib2ciEqdUaOu4uW0Pw==
X-Received: by 2002:a17:902:1005:: with SMTP id b5mr24022662pla.310.1548722354786;
        Mon, 28 Jan 2019 16:39:14 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4Y252LgC9cm2BhBxHTi6arM9vVyvvF17+8bXcE2bwJI3HNRkcO8xkQFWloU++hDvkkpoqP
X-Received: by 2002:a17:902:1005:: with SMTP id b5mr24022617pla.310.1548722353875;
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548722353; cv=none;
        d=google.com; s=arc-20160816;
        b=r+8uPHtci6Lsr5JyCpXsUuj6Jj65uCTQ/A+7zW077b10bzJGu+Opmgts3Tptv6bErM
         IVnIUwh3EvuTTt+vsERc4iM6G462zkmL0TBejtl0ukouHX9EvGljQT3nfXO9HF4mZztG
         GmscEV9AVrzU5+noj9spJwemPyfF2pqlQAd0of83vGdUg1KwGeVtWK6fCscbiZcn2248
         wCkAvzk6/O8QyqFIr1hmtUqkKl7TjUjJIxdiAIe+7KJgn3ThxOGWjs+s8w/zLv0GnJYr
         76CuQNqjSIUxZd8K2vNolLsCGJcitUk35rATLwduPDL+dSWALlJBDg+1OMufCpDYWDFI
         Q0oQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=RlvGVO5EXL5pU3ciPdRuGoj9s4OpHijn3MolXrSDLC0=;
        b=xtze8N9Oqnb5ySjn0lzaPMJz1L2RGFHPHxbfFc63hUaGjqlHFEiZctw02ZKUg7moeN
         FtoIkj3TkqCJQMA2oUQ2VjyM/+b+qjOUNqcYG+E09+X8PvFLhk6LstnUTveFDVFdaLee
         y/O/wHchCC57aGShzWrnYTi6aFgvwnOQlU5Wi1AHTcy7eCv+JqaW+1fsAFdPKLE/LGq5
         bwLJIefojI+yQZ1g64Me8lUC5f9mkXmlLJCN+Mz3Etu9Z/5OsymJt+O8Hv7ywqMMoAbp
         9nEHAQ7jxZ4lmhNyj9+2E48yR1lD1fSmB4sxA1Ai0qCufLEcD3BVCiK5CATitRbwB478
         R7bA==
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
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jan 2019 16:39:12 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,535,1539673200"; 
   d="scan'208";a="133921913"
Received: from rpedgeco-desk5.jf.intel.com ([10.54.75.79])
  by orsmga001.jf.intel.com with ESMTP; 28 Jan 2019 16:39:12 -0800
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
Subject: [PATCH v2 10/20] x86: avoid W^X being broken during modules loading
Date: Mon, 28 Jan 2019 16:34:12 -0800
Message-Id: <20190129003422.9328-11-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

When modules and BPF filters are loaded, there is a time window in
which some memory is both writable and executable. An attacker that has
already found another vulnerability (e.g., a dangling pointer) might be
able to exploit this behavior to overwrite kernel code.

Prevent having writable executable PTEs in this stage. In addition,
avoiding having W+X mappings can also slightly simplify the patching of
modules code on initialization (e.g., by alternatives and static-key),
as would be done in the next patch.

To avoid having W+X mappings, set them initially as RW (NX) and after
they are set as RO set them as X as well. Setting them as executable is
done as a separate step to avoid one core in which the old PTE is cached
(hence writable), and another which sees the updated PTE (executable),
which would break the W^X protection.

Cc: Kees Cook <keescook@chromium.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Masami Hiramatsu <mhiramat@kernel.org>
Suggested-by: Thomas Gleixner <tglx@linutronix.de>
Suggested-by: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/alternative.c | 28 +++++++++++++++++++++-------
 arch/x86/kernel/module.c      |  2 +-
 include/linux/filter.h        |  2 +-
 kernel/module.c               |  5 +++++
 4 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alternative.c
index 76d482a2b716..69f3e650ada8 100644
--- a/arch/x86/kernel/alternative.c
+++ b/arch/x86/kernel/alternative.c
@@ -667,15 +667,29 @@ void __init alternative_instructions(void)
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
+	if (static_cpu_has(X86_FEATURE_NX) &&
+	    is_module_text_address((unsigned long)addr)) {
+		/*
+		 * Modules text is marked initially as non-executable, so the
+		 * code cannot be running and speculative code-fetches are
+		 * prevented. We can just change the code.
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
index d531d4250bff..9cdfab7f383c 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -681,7 +681,6 @@ bpf_ctx_narrow_access_ok(u32 off, u32 size, u32 size_default)
 
 static inline void bpf_prog_lock_ro(struct bpf_prog *fp)
 {
-	fp->undo_set_mem = 1;
 	set_memory_ro((unsigned long)fp, fp->pages);
 }
 
@@ -694,6 +693,7 @@ static inline void bpf_prog_unlock_ro(struct bpf_prog *fp)
 static inline void bpf_jit_binary_lock_ro(struct bpf_binary_header *hdr)
 {
 	set_memory_ro((unsigned long)hdr, hdr->pages);
+	set_memory_x((unsigned long)hdr, hdr->pages);
 }
 
 static inline void bpf_jit_binary_unlock_ro(struct bpf_binary_header *hdr)
diff --git a/kernel/module.c b/kernel/module.c
index 2ad1b5239910..ae1b77da6a20 100644
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

