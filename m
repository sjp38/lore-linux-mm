Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76741C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E8CA208CA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E8CA208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 073686B000C; Fri, 26 Apr 2019 03:31:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CEA7E6B000A; Fri, 26 Apr 2019 03:31:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F6726B026A; Fri, 26 Apr 2019 03:31:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 315BF6B000C
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:31:48 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id q18so1432146pll.16
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:31:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=lPFAvintZAuLmImKiSUYUbggO4ykcKqKJ1oG7dcZTxU=;
        b=HHgNfHFhAoLdAr3SKt37HnqB/9lcaHVSzqd8LzwmV/GTkwe5O+ayKnd7///CdeMOJC
         1ryehLSHygFOyORDjzVO1mLe5znAcsKuxqjSMGRoZAtnVbCNL4hxAiWHXHZDQiHViZlT
         GDf0AYphHCga//SQCvctgBqsYvevpJXVL0pK9MagErC1cGCBlACD+O4v3ckNLhr7Gs9T
         VmhfH54kh/rUx7kn35yO4dkVWBqa0pIrgYC1DpWNKCcMBDzFUBpX9J5TGUt5gASpBqB8
         tyBWDU60i+IM6SMjHUC/PMBiXU8e/h8VfFw5lIZkX5PeyjOFv1ycCkrIf5s7iw+5Qc+C
         Cprg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAWjhZoNDcAsfmVQ1+UukvoLzxDAtghtOuAtnkajEVIpDnlRCf3+
	C+G5aKKw722Oa1AzXxBGxYBAZWVkNGTZIIqEaX1y6rnrNhgB8RDOlR3UCUb/rxsA4egGLe36o5k
	G1ZXTrEO+PVgQfymRvMiVxLC7bjwr8fQcCliniu3Jj/klGLBy26+DX8sTtoEnmRTCXQ==
X-Received: by 2002:a17:902:aa5:: with SMTP id 34mr28025510plp.263.1556263907850;
        Fri, 26 Apr 2019 00:31:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztm1mA+e0hrvuPyBCBLNWHEqQ/QxOuHtXlrzVy7LIN1TYhiXRkOaIvmAcKI19HXKDSThy5
X-Received: by 2002:a17:902:aa5:: with SMTP id 34mr28025419plp.263.1556263906517;
        Fri, 26 Apr 2019 00:31:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556263906; cv=none;
        d=google.com; s=arc-20160816;
        b=0jRm64a4fzGvklc8M8uxK9kFW9LGqPotcwx1LIjUKwJCgR2d/rlWZWbTdcNYNj3ZPO
         y+MGjDfuu2KW1MO6bnSaNveFWI+mhWeR17/7Thp9//cUyfMpo3SfhoFFR8K7VOTnM1/7
         BlR+7Mfc3cN0TbBPqZPycN4x3tvXTUwM/jQt5vJV2W5iZMM829eu/KpqHiA+ptX5bGkA
         Naz5d+h1Nf1Rvk4hXxQGoWz+eVZN95YNBWn18kZWIzUYFR/yTworgtsOx/RxAfqs4DTA
         asSH9ZYd9GDauNCNuIt4fjw++lS/d+W07Iv4pG8mQrrOAaSZcemMSQZEU48OBPFJ+zLV
         Ceag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=lPFAvintZAuLmImKiSUYUbggO4ykcKqKJ1oG7dcZTxU=;
        b=Ld/w86recnOmR8GKX/BbuVn65Az4GHfbDwPd05roEBn5cYKzohWXQjccdXaHUcEdUl
         POTGtskxlyrYrlbgJ4wqhz9r6WnYDpoPdZZFPMzT+J9KYE18jwqhwc50aamMpIDXQx1R
         SJL77CdsuvbtH3vEXSt9QajWbYnVcQ82ASScK5V73CR8zNozCBkfPlpubn7DbInIgAm8
         f6bONOE1vk/lN0q6+KdGMcBBUEC15TrmIOSDUryUCIp2ws6bo0aggJEDROKHuD8Pqfbh
         Tg6F1xrX7z/AswAH9XiAOKHlCSML5A20tV5kgTXtP8f6PjynSAmIAgdqHLzukMoMipOg
         jHbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id f9si22844507pgq.347.2019.04.26.00.31.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Apr 2019 00:31:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Fri, 26 Apr 2019 00:31:44 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 8042F412A4;
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
	<rick.p.edgecombe@intel.com>, Nadav Amit <namit@vmware.com>
Subject: [PATCH v5 04/23] x86/mm: Save debug registers when loading a temporary mm
Date: Thu, 25 Apr 2019 17:11:24 -0700
Message-ID: <20190426001143.4983-5-namit@vmware.com>
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

Prevent user watchpoints from mistakenly firing while the temporary mm
is being used. As the addresses of the temporary mm might overlap those
of the user-process, this is necessary to prevent wrong signals or worse
things from happening.

Cc: Andy Lutomirski <luto@kernel.org>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/include/asm/mmu_context.h | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 24dc3b810970..93dff1963337 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -13,6 +13,7 @@
 #include <asm/tlbflush.h>
 #include <asm/paravirt.h>
 #include <asm/mpx.h>
+#include <asm/debugreg.h>
 
 extern atomic64_t last_mm_ctx_id;
 
@@ -380,6 +381,21 @@ static inline temp_mm_state_t use_temporary_mm(struct mm_struct *mm)
 	lockdep_assert_irqs_disabled();
 	temp_state.mm = this_cpu_read(cpu_tlbstate.loaded_mm);
 	switch_mm_irqs_off(NULL, mm, current);
+
+	/*
+	 * If breakpoints are enabled, disable them while the temporary mm is
+	 * used. Userspace might set up watchpoints on addresses that are used
+	 * in the temporary mm, which would lead to wrong signals being sent or
+	 * crashes.
+	 *
+	 * Note that breakpoints are not disabled selectively, which also causes
+	 * kernel breakpoints (e.g., perf's) to be disabled. This might be
+	 * undesirable, but still seems reasonable as the code that runs in the
+	 * temporary mm should be short.
+	 */
+	if (hw_breakpoint_active())
+		hw_breakpoint_disable();
+
 	return temp_state;
 }
 
@@ -387,6 +403,13 @@ static inline void unuse_temporary_mm(temp_mm_state_t prev_state)
 {
 	lockdep_assert_irqs_disabled();
 	switch_mm_irqs_off(NULL, prev_state.mm, current);
+
+	/*
+	 * Restore the breakpoints if they were disabled before the temporary mm
+	 * was loaded.
+	 */
+	if (hw_breakpoint_active())
+		hw_breakpoint_restore();
 }
 
 #endif /* _ASM_X86_MMU_CONTEXT_H */
-- 
2.17.1

