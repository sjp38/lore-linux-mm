Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AE9EC10F18
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAF6B20818
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAF6B20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1B228E00CD; Thu, 21 Feb 2019 18:51:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBE9E8E00D6; Thu, 21 Feb 2019 18:51:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B30EA8E00D4; Thu, 21 Feb 2019 18:51:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6AAA98E00D4
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:51:11 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id s22so318456plq.7
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:51:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=wlyB6G1b+Tm41nLBBmWshnK0KkaA3tTinkVpxpprDWU=;
        b=jiyNeEoLJPbe3ysqJieZtUAoHY8a6NxL+9hiNSGQSo3WbCHAOO4kna3471Pr2afrMN
         h3J+4+7BtulZJ2g8yZBtGkcOdPdeBTVSi2XWnf9iPuRjaGfD6kc/EVnViM154BvEZnHY
         mtXZVuyRcliqBxuCprdKsqX8K1qQWNW3zjdKbcBVxgAE2+KFVPz391X3BlT2B4EqE+5j
         9se8nEkYUcarbz5XLXVZk8SBDrLAKsVgZWzCzyJh9wfkPGAUHA+SzGc9OYZ5kCBsrdyn
         lfc2FGSM+X6/4VAKCO+x3R8tMgJvpLKfHTxVmHR8La6RoDgJg6hJOq598AafjdQ+K/Xd
         ETDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubay3TIpuWEldMoewTpIvLPkHhnMWSePttEtgMyq7c0oBcnQwgF
	Ccw73w87EytK+mKFuV+OGj6UaGYJbXVn1vPdUwMJCW1JfNlWhRCBOjnjEQBfFnRKXGVVeRlM2sI
	gdFIwegfTmSUcCbg/oKCagIVmQHhGuCzNwRmPYbYCSpgP7g/AJD7vqxtgD+94GyGZkA==
X-Received: by 2002:a17:902:6bc7:: with SMTP id m7mr1223989plt.106.1550793071029;
        Thu, 21 Feb 2019 15:51:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYsrEx/PaShl8Jeua71g0BpS+zpIalcy31KXVdoiuPt3WQuxAjE0y9qPkenQwVoP0md63rl
X-Received: by 2002:a17:902:6bc7:: with SMTP id m7mr1223947plt.106.1550793070071;
        Thu, 21 Feb 2019 15:51:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793070; cv=none;
        d=google.com; s=arc-20160816;
        b=e7cLln3MfGDsSKUG3n+yWCUfvHESpRS0kTlEPHkA5670ir3yk6Epm0ZEVGrnrZ5IIl
         AE/kG53cMWBvsh4osw/uvC1edSqYa9wHSxxSuOJUAONNBOVQrxS9awLtpa5xWI3JeQSs
         wc1aHgvdrxCK4lGvuzlBj4lMqjFs2X65apoPScK+0vRfPc5MtcuqHOodXc8IrgE3JtsF
         vzCClpBhYlK5xd/G2Bwp/OEYs2G0iLRuXNz0vLjUvBTttBN81rBxo5Qu7vZaiqkQhW5I
         gbZCJc7/DzlVhlvjSOWqE3u1lbcM/fpWbyspS6dnViaUjHCKo0nbt0TJjiAW6o4itj0V
         x7sQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=wlyB6G1b+Tm41nLBBmWshnK0KkaA3tTinkVpxpprDWU=;
        b=Hi/Ialk4okQ+e+rtnIO/k05+5/LHufen2Ah6cTUvgaek8MyCdLztEZh9ZH5YRTKEkM
         5aYJKLB7gh/7US7bJ+OYe9gKc/ZgrqEAEtj+u5IxUvD5/jfWwY5wjeo41Z6qHbHabVeB
         9nyqSjhFw8qWohkU2XlFqV5O5XDTaoAR2LRIbZJFPc6dSi+FP0BGoeeGZbLF4ASGaR+5
         wOJR/+vCbkXuwlVf3k25cqXeQ7FqBHdELhpSQlLGJKRvP55AZQAQY4ZPvScYgJDZGLls
         jCBPa3dw817fHtZqWKbb1kqAGGOxZ8NuQa135DLPdYpYCwWxVk1RrYSCpBVpTF3JEsDm
         CoGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c4si238494pfn.83.2019.02.21.15.51.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:51:10 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:51:09 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="322394951"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga005.fm.intel.com with ESMTP; 21 Feb 2019 15:51:08 -0800
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
Subject: [PATCH v3 17/20] bpf: Use vmalloc special flag
Date: Thu, 21 Feb 2019 15:44:48 -0800
Message-Id: <20190221234451.17632-18-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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
index b9f93e62db96..f7b6c8a2e591 100644
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
@@ -681,27 +681,17 @@ bpf_ctx_narrow_access_ok(u32 off, u32 size, u32 size_default)
 
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
@@ -736,7 +726,6 @@ void __bpf_prog_free(struct bpf_prog *fp);
 
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

