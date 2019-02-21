Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74C7AC00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35E9620818
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35E9620818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 086CD8E00CE; Thu, 21 Feb 2019 18:51:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00F698E00CD; Thu, 21 Feb 2019 18:51:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1C9F8E00CE; Thu, 21 Feb 2019 18:51:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 986438E00CD
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:51:04 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id f5so325065pgh.14
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:51:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=PGQf8pkpnNe3t3IPgvET7mlJMbEiHMZ/T85JdFzL/O4=;
        b=pTS8J/oZ1jAsZ+pLc02hYzEHwg0dinEv5c2K/518NigOsrT5YycEkQrJ4mqZlWPAhV
         q5VrqHnOSNW5YGlWFrPVT+7X0KtdvjVxEuMGneUDtidrOEKUacV+yJMAXhTK6XZGFtd8
         guUykyLMEQZS8g/utKE7DealomAFEmg2pbBpVbgF5K23luk6U8d7fOp/PhxNrhzT9Cgp
         uJpzLC3e602t8ACQgBC5IoKD++MzJWoCGUjN03rJRiUW2q7vbQJczA+VTZUv/fYTxibE
         XBpxTAvdCm+lRxy/GAOUA/nBbcyfvqTj2lFcHEm6syKMHqar2ddhNPIirzW1VHQyx8vA
         qP6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAub7cMpHZJkqidyKsFF2/klklwKtn3qPVUQrRhtCJ1/lejvhR8So
	hrFWfi24kHratfKsUxdrB0dvVq8BeXA1RgKv7V3tQsatR/OiQYzyD2UXxi9p6iwohIn3gRBltji
	NVwnmYq8XIKxm4PAbAhG5LcTpHtfpKsaizkmX/tG6cCTHdBfRko8/fSwnI2CR5Lpvrg==
X-Received: by 2002:a17:902:9307:: with SMTP id bc7mr1176530plb.234.1550793064269;
        Thu, 21 Feb 2019 15:51:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYP74AcN7Op67i66gEMSRRXSZkZoE36A/ZgIIIIW1uMdNx+Do2/FZevRvVmFc0QRc7o2srl
X-Received: by 2002:a17:902:9307:: with SMTP id bc7mr1176484plb.234.1550793063357;
        Thu, 21 Feb 2019 15:51:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793063; cv=none;
        d=google.com; s=arc-20160816;
        b=TVDPNJD5tN58OVutl2htWP1QYamRXkYufzC5yimsVn09GKaGBDbleRXIyuiwHPLtSl
         aBs8lp2Nvm3i87P6w8meRvbgR+UHtwG5qOO4lea9UzyNrJcP1eHyhHJCLevybXDYmCbY
         ptU09V7IKcfLFMZKkg5Egn5H0i0rPTTCBidlMNYkwOdkcNG8vbD7osfFXRVk9pCCnOIg
         oeg7Ph2DZFZLe1a301gveYkzTWKJWk32hcLL8NaBsBes7lmVmtN5mTdbLRmQ/RlUHzfR
         g+W38F0PBkMZdmODV/7ZGEQGQWAdWtgJ3VgVBJv0qIN+ZE9K1FO8/TTV4Ho8KZfeDrl1
         J9Ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=PGQf8pkpnNe3t3IPgvET7mlJMbEiHMZ/T85JdFzL/O4=;
        b=uyEfw7pDGh/wEW336zMVxeg13ZFfQ0fn21L7ShGFo741OIaSHkUPwkFLzd0q8bd47y
         TrbRzMgw1GkiKfPubS3OzN4aJbzK0Q/vZsi0wzrNNOicp/GA+OiKLjtbFWkqNW1AJ5d4
         UUg08YIenkmSlCwQJWKcXrY5Usu5AHNGsSU9ppBRzrEAVx81Hl4rf/I+8Fgsg7kh5bpv
         LC3tASfnXRQdYzkCXBiq05eEuvTCRD8gjgXJD8h693aeTYY+HPVAH4FC1egdIEuotPsy
         vpop33Lrr8y7Qolu72GDisOrP2IEcgVsTVvKNuxzuhGffJ1KgG4Z/JnkqYfm9FvrRgP2
         jlCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c4si238494pfn.83.2019.02.21.15.51.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:51:03 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:51:02 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="322394912"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga005.fm.intel.com with ESMTP; 21 Feb 2019 15:51:01 -0800
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
	Jessica Yu <jeyu@kernel.org>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v3 10/20] x86/module: Avoid breaking W^X while loading modules
Date: Thu, 21 Feb 2019 15:44:41 -0800
Message-Id: <20190221234451.17632-11-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

When modules and BPF filters are loaded, there is a time window in
which some memory is both writable and executable. An attacker that has
already found another vulnerability (e.g., a dangling pointer) might be
able to exploit this behavior to overwrite kernel code. This patch
prevents having writable executable PTEs in this stage.

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
index cfe5bfe06f9d..b75bfeda021e 100644
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
index d531d4250bff..b9f93e62db96 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -694,6 +694,7 @@ static inline void bpf_prog_unlock_ro(struct bpf_prog *fp)
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

