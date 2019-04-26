Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D692C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E21121744
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E21121744
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 069B06B0266; Fri, 26 Apr 2019 03:31:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B18916B0274; Fri, 26 Apr 2019 03:31:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A9626B0272; Fri, 26 Apr 2019 03:31:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1CCFF6B0007
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:31:50 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f7so1491694pgi.20
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:31:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=03x8MyH4ONo6RL8TDAuJcYQYBUTk8Xfu5EMEl5vv8zs=;
        b=KwQvd75x1sDx1bT4KwvVFnZGiftKeP7Ao+LoyDmfuYl/2OySHRzRyto9t7frjzLBGi
         t3sK1JjMrbsOn1xnEKBirDN9FQDfq7e7/crlbqvCt5pRw5sdwtAW51JBzzvIb7I2H+oE
         wd1RklG1YA1H7NZQXnt4m8eDyQ27+Ogk1ULDeQVEC11GVrpZtEk4wUslO//f5PGfBEfn
         SPhG613zVgcXaVf7kCRO0xTlVD6iUwDgzQszhCJeSqMww2nbQWp0wvQnE4XE/qc0X3wn
         5QDkQTd3FFPHG6rKrdZ/0Z7v7UGK8VN00ad58st7XGKpdM6phhEWzWySNSAmGw+Be96J
         urGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAV0ziiGBHjdgtMXyp6Wo1s9mLrKIfyh49hfXlRhq+jEioR9C2Ts
	Lhf5S+CVkPCSbz+7cUEUnivpmxF2ajGtE+XaCwJCDZ2uV7V4vwdcB1AQz8RP56AkpS8EMIv6/08
	nfCeXIhwYLkQWKuZPgudnta4qsK1PzwGcwIPgb4YZcvSy8RnDsPcguPOeLz3zojTjMQ==
X-Received: by 2002:a17:902:201:: with SMTP id 1mr44722111plc.89.1556263909728;
        Fri, 26 Apr 2019 00:31:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRhoCC13X4g10o5nZfIWed4q3JdFpqSGvxYAkkG9NVs1PjSuAd5rmnHzL6nFN8rCcLk0oc
X-Received: by 2002:a17:902:201:: with SMTP id 1mr44722009plc.89.1556263908548;
        Fri, 26 Apr 2019 00:31:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556263908; cv=none;
        d=google.com; s=arc-20160816;
        b=EbNHQmCYhkTfFH07IA4U5JIxWnaQPOhjNdxMGBcycWV3SSS1p6NPs+xNYYbn4P8KYB
         oq+wQBIJ1m25UVFeWBneOrm+jUHrueAgJj5x+vrA+gaN+dUF1+VbTeX1S7pD/hZIEs6m
         73a6lx9iVCjzBDk7Iv00gHglWu3oHzStY19ymZzz4sgfEQS0Sj6P6t41We0eLVQBXS8T
         vbLm7FVbJ4loz9/QAI+03OCw+WuCK0Hc4yPiokYzme4W0pumALWaAW52EUFn9BNeR5XB
         tgc5Hwu2BJD/mToghoH3N+OCz1MANpio1CIXdI7CN25zlHEVxqkCUbimZohqu+/wdWyC
         8dDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=03x8MyH4ONo6RL8TDAuJcYQYBUTk8Xfu5EMEl5vv8zs=;
        b=gHi7VE3rO9tcb9Ele1xEdjm6Tsv43Un5rQaUF7mYhoOBTSlbuJ+V+13noSTjQo31y+
         KciDlrtpTGEHrc8x/fxqmBHTOVmclxvz9U1903VmD1+0nvEKcXi88oL3O4WeyqHgE1Qg
         pSj2gir9JG5RcQ8zhZy/nQcpmwNGoDwPQvPE/kYuPEioH001AcbmftAJxNwczrWKm0CO
         9M5uQcQ2j8C1sA3Xb7OABXJG3zPUY9kyM62/c31PbGaytUsQhHMbhGE8wpAyGfItqJYG
         s4oKgMEpVoDXIt+j5am+zC6+0fvVI7rvib1qu2uvbikOwvGlcE0ABKf8JNPidQDEzqo6
         gr7w==
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
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 0758741298;
	Fri, 26 Apr 2019 00:31:46 -0700 (PDT)
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
	<rick.p.edgecombe@intel.com>, Daniel Borkmann <daniel@iogearbox.net>, Alexei
 Starovoitov <ast@kernel.org>
Subject: [PATCH v5 18/23] bpf: Use vmalloc special flag
Date: Thu, 25 Apr 2019 17:11:38 -0700
Message-ID: <20190426001143.4983-19-namit@vmware.com>
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

From: Rick Edgecombe <rick.p.edgecombe@intel.com>

Use new flag VM_FLUSH_RESET_PERMS for handling freeing of special
permissioned memory in vmalloc and remove places where memory was set RW
before freeing which is no longer needed. Don't track if the memory is RO
anymore because it is now tracked in vmalloc.

Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 include/linux/filter.h | 17 +++--------------
 kernel/bpf/core.c      |  1 -
 2 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 14ec3bdad9a9..7d3abde3f183 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -20,6 +20,7 @@
 #include <linux/set_memory.h>
 #include <linux/kallsyms.h>
 #include <linux/if_vlan.h>
+#include <linux/vmalloc.h>
 
 #include <net/sch_generic.h>
 
@@ -503,7 +504,6 @@ struct bpf_prog {
 	u16			pages;		/* Number of allocated pages */
 	u16			jited:1,	/* Is our filter JIT'ed? */
 				jit_requested:1,/* archs need to JIT the prog */
-				undo_set_mem:1,	/* Passed set_memory_ro() checkpoint */
 				gpl_compatible:1, /* Is filter GPL compatible? */
 				cb_access:1,	/* Is control block accessed? */
 				dst_needed:1,	/* Do we need dst entry? */
@@ -733,27 +733,17 @@ bpf_ctx_narrow_access_ok(u32 off, u32 size, u32 size_default)
 
 static inline void bpf_prog_lock_ro(struct bpf_prog *fp)
 {
-	fp->undo_set_mem = 1;
+	set_vm_flush_reset_perms(fp);
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
+	set_vm_flush_reset_perms(hdr);
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
@@ -789,7 +779,6 @@ void __bpf_prog_free(struct bpf_prog *fp);
 
 static inline void bpf_prog_unlock_free(struct bpf_prog *fp)
 {
-	bpf_prog_unlock_ro(fp);
 	__bpf_prog_free(fp);
 }
 
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index ff09d32a8a1b..c605397c79f0 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -848,7 +848,6 @@ void __weak bpf_jit_free(struct bpf_prog *fp)
 	if (fp->jited) {
 		struct bpf_binary_header *hdr = bpf_jit_binary_hdr(fp);
 
-		bpf_jit_binary_unlock_ro(hdr);
 		bpf_jit_binary_free(hdr);
 
 		WARN_ON_ONCE(!bpf_prog_kallsyms_verify_off(fp));
-- 
2.17.1

