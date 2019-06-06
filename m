Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DFE3C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:16:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4598C208CA
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:16:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4598C208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D54836B02B1; Thu,  6 Jun 2019 16:15:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDDF26B02B2; Thu,  6 Jun 2019 16:15:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B56036B02B4; Thu,  6 Jun 2019 16:15:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7824F6B02B2
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:36 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id b24so2141696plz.20
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=uWb7t+eKjZRdrxDegnwMc3Dgz6fTxwnmp/IT3TakFdo=;
        b=dymfRaboZnTiHaW7YUEYkUteDOOqmL1ejWaE8N631ixXy3hXiiJqqjjnQwsU4CT2KT
         78t3iXf5bZCmjnPp46aOUzn1YLQtxPfvINU1xKbgEhhx5Lkdc1Eip+0WtvM9Nw0vRGZp
         94kaTzA2EhXr6jIq6GcZcnrfBZKTvxQ1P12cGNJy6/W8SZMOYNITCNvRtyyEJTDD9neD
         LtDfgWw2gxXMoyI1YMSZiuq/Y8yuW/NAuMRj0gXJ/nBEjTi+8wHSrkKz/QnPfKKRNK3T
         WrAPmHypJZZyU0MDfs73LItougslg7RAvp8nwL3LTzRQrqg6Zse0uLeJ7gDZ+GDUCr8x
         m8JA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWDlWI3bja8EvfC56toMrNZ3x4vsTdD25fYQ7tEhDT0sdq+WXJU
	lgT+jfWAzsxMZgtwolfO+/ZkEWLuFTAVO6zvknfrfNgjHrkOAKnTHvvRWQMm1RFb0nZHYJNcn8I
	Cv+OhSoscEKDAGMDUAKWoqIavYVIfRVzeWgS3zSozZ7K/1bTgpC/iTKPtnpNzh4xOmA==
X-Received: by 2002:a17:90a:d582:: with SMTP id v2mr1630352pju.22.1559852136133;
        Thu, 06 Jun 2019 13:15:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxsaXfsbiQEEwhpiYuqSKRwJ5iCbWgbR0A5TIc7QpIDPJig33wZOrbDSIsk1KTC+NQz1M9
X-Received: by 2002:a17:90a:d582:: with SMTP id v2mr1630300pju.22.1559852135227;
        Thu, 06 Jun 2019 13:15:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852135; cv=none;
        d=google.com; s=arc-20160816;
        b=ExjYwi01vm+WGDLWZNriht8zB0Jw7EGbbeYivWpG1PA4MWjSKNhfSGUmV5H/W9FNBX
         Vzhi36pmeAN5AUe96RsYPHInQPytG19ywyScH16nre2N8GgbqJZGfaHMDzha3Mq7V44R
         iSw8G37EklTxaC1Y04HDt/vRUwnkRj+ZvIhJ5TbyAD/AAJFiCDWfmWqt/JCkzwVyhvEk
         5cZkSS7O2MPHT1nex6lSxaEMWxyZpxZGZlkQY2N7GWwOnXLMnpR72sONOuvRNyMenHdR
         T4z4FediQYynsyND8Vgy+VU/8QbX9IqnIike35BiSUGPgEjDecgxVucJ9TRnQcX0JP0k
         BZ7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=uWb7t+eKjZRdrxDegnwMc3Dgz6fTxwnmp/IT3TakFdo=;
        b=j0hnoQhwsRwarfTdOQKpVvNu5hvUzlTRtbUQDh4AYdxBYtTnk35oFXxXWZT70plz8d
         34KDfRJDO1SFeRyg9M4g/lVNdD/lgVrjRyTXIU9gza4ZW4/V3T7fvfMWBGxJQLja9gdf
         zEuN+t3dKFcE1sCk3l4OGQ2N47IY4BcKSVKs6IIZzLGN07RNNMOFn88Oe4yJc5mhP73Y
         NlRMRBsGZ553DKs9BxcZUo+jnwaqG4hb5nwr+4UfccyeO7RYIRdy0Sphaly2HJsRqDq6
         hnEcxBvV6b0knvdx79SXbZtalo1D359EfFk5J3Vr7pCjB/21ZS+9xfYPUqdMCaeMTPit
         ZMfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id r142si2785300pfc.219.2019.06.06.13.15.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:34 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:33 -0700
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>,
	Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v7 20/27] x86/cet/shstk: Introduce WRUSS instruction
Date: Thu,  6 Jun 2019 13:06:39 -0700
Message-Id: <20190606200646.3951-21-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

WRUSS is a new kernel-mode instruction but writes directly to user
shadow stack memory.  This is used to construct a return address on
the shadow stack for the signal handler.

This instruction can fault if the user shadow stack is invalid shadow
stack memory.  In that case, the kernel does a fixup.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/special_insns.h | 32 ++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/arch/x86/include/asm/special_insns.h b/arch/x86/include/asm/special_insns.h
index 0a3c4cab39db..99530ab0a077 100644
--- a/arch/x86/include/asm/special_insns.h
+++ b/arch/x86/include/asm/special_insns.h
@@ -250,6 +250,38 @@ static inline void clwb(volatile void *__p)
 		: [pax] "a" (p));
 }
 
+#ifdef CONFIG_X86_INTEL_CET
+#if defined(CONFIG_IA32_EMULATION) || defined(CONFIG_X86_X32)
+static inline int write_user_shstk_32(unsigned long addr, unsigned int val)
+{
+	asm_volatile_goto("1: wrussd %1, (%0)\n"
+			  _ASM_EXTABLE(1b, %l[fail])
+			  :: "r" (addr), "r" (val)
+			  :: fail);
+	return 0;
+fail:
+	return -EPERM;
+}
+#else
+static inline int write_user_shstk_32(unsigned long addr, unsigned int val)
+{
+	WARN_ONCE(1, "%s used but not supported.\n", __func__);
+	return -EFAULT;
+}
+#endif
+
+static inline int write_user_shstk_64(unsigned long addr, unsigned long val)
+{
+	asm_volatile_goto("1: wrussq %1, (%0)\n"
+			  _ASM_EXTABLE(1b, %l[fail])
+			  :: "r" (addr), "r" (val)
+			  :: fail);
+	return 0;
+fail:
+	return -EPERM;
+}
+#endif /* CONFIG_X86_INTEL_CET */
+
 #define nop() asm volatile ("nop")
 
 
-- 
2.17.1

