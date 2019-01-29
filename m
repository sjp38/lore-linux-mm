Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CD3FC282CD
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:41:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 358752177E
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:41:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 358752177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5ABC8E0010; Mon, 28 Jan 2019 19:41:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C303F8E0001; Mon, 28 Jan 2019 19:41:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF7EA8E0010; Mon, 28 Jan 2019 19:41:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E6618E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:41:01 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id o17so12695835pgi.14
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:41:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=f3R2YUO4FGOPRke7XU/+0tFiGuW/e9uBw+X2/zRPj2A=;
        b=m0zTJmHx8y3OsXpJbDZF9s9gz7g0+AtOJyTvui5sad5uHdEn4qOFZijLJPVgPqvtf3
         JQPXtXpsilxjxXnO97pf9k8cHWy1vKfTAIPl0s8Rj4gUMyJEGJBhGBSbm3MvvwFMxGQ6
         GhXznCRFHsHZljDraJHO1xPNBHiuYh420mGHNTstPPT7dnj0WBJOefJUdMDHE0JMq4h+
         KkZf54LIXOiZMskWdsY5s57E0a+i/bhPK8x0+b0Lwq36FHU1Lfg7n1WI6souGFwyGrCf
         zj6tV26iq1GLy+8W4zQDc9Wchn5yB5VD/Bsw0I6e86ehXB2GHzl2nNb2RZRoZsmzH6TH
         miiw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukchaLCYnUPaNgGgJe+TcCF6rb/nmWGH68gikcGhtXkfE4d6uU1a
	rIegVuCZnbqPovu3I352SEMYiMvhgpyy+gxm9/+8HhLxATHlhww0w12VQZo3OOj6E0lvv5u8eF5
	pnp/AI+z20O1iSs9G0BFZI092qMLMW21p7S57WPtAXwN3nGkjsQouLJYM96d8emfsxw==
X-Received: by 2002:a17:902:9692:: with SMTP id n18mr24332659plp.333.1548722461110;
        Mon, 28 Jan 2019 16:41:01 -0800 (PST)
X-Google-Smtp-Source: ALg8bN42Tcnf6ywYNI2ugd7jiRTiSfMM9B6W2pAuXX4Gy/KBe/Ihyog53B0R/NQbWI6qlmElxjxb
X-Received: by 2002:a17:902:9692:: with SMTP id n18mr24327214plp.333.1548722354058;
        Mon, 28 Jan 2019 16:39:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548722354; cv=none;
        d=google.com; s=arc-20160816;
        b=rzSRxtyoOFDH8rLlP1Nkxf+z2A4cyN/rEcfrui/jGIwJGKt/LDO4d50xSZEShr2DAf
         YAa7PJibY+vS/SjWDCAAzZ4Ipo55ORTkjNa/RQZvvNF6FVwCiK0lOM/1j9G3CnqR11R2
         P2Ze2ydlMHulK53pZdNoVPeP8ImxBnGgYMis3lLUfX4o59ezY9kSeumFXhgHr8t/a3iy
         TkF6jYvrl1ECQS4TUKv2OY79+wqAIca85F6eTzeKRUmMhQzzhvAYtCdmHrYjH2EGVAKd
         /7sQI5skc2nuZZL3B+gv4zER55i/Mjbie/FHCcLwEoHksTTeOLIBwaDVVBxUVfkqWwX5
         lRpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=f3R2YUO4FGOPRke7XU/+0tFiGuW/e9uBw+X2/zRPj2A=;
        b=j54U/20tT8eDMMI2jDCZCB/C3UGGG8ia/dZmQpyDfj/2iLaf/kJ2Cxet1PJnsLkh0U
         WmG/UOtoV3NgM72deL585j1UcA2JL6+kjIWW7MX06AiatOtRXRduyLSIxBPFeb3MIEZl
         QOTtwPUkhLArKfhxMSKSpRbbrs70lyOJXhDRxFvAwahQ64gIQkHdsZD25WjVa0uwSNeM
         7hWjRToIVMfpQCL7uaakiGQr1GmB8QYaHHP2Lg+2XhOpeTmntygvfjHajqNQQJNKFesA
         c7Sf6yyOIdY7grDD6KvkmMVjGF3j36j5SoE5Vsl2z6gN5lclKrMMcQLXNvZOw8Uq/Gko
         3AqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 33si8810596plt.228.2019.01.28.16.39.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 16:39:14 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jan 2019 16:39:12 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,535,1539673200"; 
   d="scan'208";a="133921937"
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
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@kernel.org>
Subject: [PATCH v2 17/20] bpf: Use vmalloc special flag
Date: Mon, 28 Jan 2019 16:34:19 -0800
Message-Id: <20190129003422.9328-18-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Use new flag VM_HAS_SPECIAL_PERMS for handling freeing of special
permissioned memory in vmalloc and remove places where memory was set RW
before freeing which is no longer needed. Also we no longer need a bit to
track if the memory is RO because it is tracked in vmalloc.

Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 include/linux/filter.h | 16 +++-------------
 kernel/bpf/core.c      |  1 -
 2 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 9cdfab7f383c..cc9581dd9c58 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -20,6 +20,7 @@
 #include <linux/set_memory.h>
 #include <linux/kallsyms.h>
 #include <linux/if_vlan.h>
+#include <linux/vmalloc.h>
 
 #include <net/sch_generic.h>
 
@@ -483,7 +484,6 @@ struct bpf_prog {
 	u16			pages;		/* Number of allocated pages */
 	u16			jited:1,	/* Is our filter JIT'ed? */
 				jit_requested:1,/* archs need to JIT the prog */
-				undo_set_mem:1,	/* Passed set_memory_ro() checkpoint */
 				gpl_compatible:1, /* Is filter GPL compatible? */
 				cb_access:1,	/* Is control block accessed? */
 				dst_needed:1,	/* Do we need dst entry? */
@@ -681,26 +681,17 @@ bpf_ctx_narrow_access_ok(u32 off, u32 size, u32 size_default)
 
 static inline void bpf_prog_lock_ro(struct bpf_prog *fp)
 {
+	set_vm_special(fp);
 	set_memory_ro((unsigned long)fp, fp->pages);
 }
 
-static inline void bpf_prog_unlock_ro(struct bpf_prog *fp)
-{
-	if (fp->undo_set_mem)
-		set_memory_rw((unsigned long)fp, fp->pages);
-}
-
 static inline void bpf_jit_binary_lock_ro(struct bpf_binary_header *hdr)
 {
+	set_vm_special(hdr);
 	set_memory_ro((unsigned long)hdr, hdr->pages);
 	set_memory_x((unsigned long)hdr, hdr->pages);
 }
 
-static inline void bpf_jit_binary_unlock_ro(struct bpf_binary_header *hdr)
-{
-	set_memory_rw((unsigned long)hdr, hdr->pages);
-}
-
 static inline struct bpf_binary_header *
 bpf_jit_binary_hdr(const struct bpf_prog *fp)
 {
@@ -735,7 +726,6 @@ void __bpf_prog_free(struct bpf_prog *fp);
 
 static inline void bpf_prog_unlock_free(struct bpf_prog *fp)
 {
-	bpf_prog_unlock_ro(fp);
 	__bpf_prog_free(fp);
 }
 
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 19c49313c709..465c1c3623e8 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -804,7 +804,6 @@ void __weak bpf_jit_free(struct bpf_prog *fp)
 	if (fp->jited) {
 		struct bpf_binary_header *hdr = bpf_jit_binary_hdr(fp);
 
-		bpf_jit_binary_unlock_ro(hdr);
 		bpf_jit_binary_free(hdr);
 
 		WARN_ON_ONCE(!bpf_prog_kallsyms_verify_off(fp));
-- 
2.17.1

