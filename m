Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 140FFC28EB3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:17:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C7A4208C3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:17:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C7A4208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 879066B02C5; Thu,  6 Jun 2019 16:17:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D21F6B02D3; Thu,  6 Jun 2019 16:17:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45CEF6B02C7; Thu,  6 Jun 2019 16:17:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A74E36B02CB
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:17:33 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y5so2588557pfb.20
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:17:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id:in-reply-to:references;
        bh=YoQ681ZYTFjY/zFx9PzM0qShZAunOVr0m8G9KhtOrxQ=;
        b=TcZXIDWPAWd+8T78WkdwmNc3Mye9pheiJ75Ze6LYBjfgO48L1vl1QBvvFDL5AFXrHJ
         1kpWsSA1Vo/cmMYd10+YcPDXvw/s+UGnSX4gfMATsovOhxx6+LAWHA2kTYx0gkfbp4oZ
         8m2xuR46nMcdzARpUB91oldMJQKOZjCxZT2mCqiS+IZ46iFUaURV5GdS1N3CckRJDd8x
         07T1AwGkmssZRyL6TrLge9psDy5Yj84oRgdJPDvlrfyGtEAN7zpatDxzY0sAFXgi437d
         Xb4+MBY0NU+Gqc0xivbBUcN45VrUZmu3FfO2NayMMOsorprVSdYaEsEDTN7i9SHn9jR1
         QueQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWxsVZDYrpokhvHLSExqwmm4K+5rmzBCf3MlmfDfi4H1SM1sL5B
	JTKUbhNEIyzMOZbisVyPIMWMWR5YPP3toQxx8mUAoCEwz+uyGPN59mGNVMqkp2yDccjM8blgCZV
	BLtt/zJvuwYJ42cuP+X9jvjvDZAoE53bsU7aBKtUnv73XWdI5P8X7xadMVmiB8UVmHQ==
X-Received: by 2002:a63:1b1e:: with SMTP id b30mr322738pgb.180.1559852253372;
        Thu, 06 Jun 2019 13:17:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzeLrUmCAZzsc0GucJ3gnpLvrSmpiBpZFbJ9YumiuK8WWGzuWJhiOPNGnf7rmFYRoiPzrvz
X-Received: by 2002:a63:1b1e:: with SMTP id b30mr322708pgb.180.1559852252825;
        Thu, 06 Jun 2019 13:17:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852252; cv=none;
        d=google.com; s=arc-20160816;
        b=Nia3Ugy+4YQLuLHsUYycjb0ktU0xMjJdLhHfDD/k+kcI5ZxxzAnSLEKHRVsMFqFiHn
         pIReH9HDhlsyaFTNkwgzU4JzPySmpPJRH9HQIMxty77XgXaEZMIP78++D6ToEiQ4aHEW
         xBLFukj9Hw1jGH+W5MPzBVYnkSagkK8osHlzLijsacKg73levK+mBfWQ88OfdhoO3caY
         U28larMHI7P9tvO5RNsXMbPodH8fj6McoZ7ksXu7ubgiet7PBUHME7ptkMwQgQ/AQLFq
         AobQuyoUWfxii4LkIiyusmwhm508ZVraJWOfJUTDeW3bV/5YbuZErJ/jlZT2bDI+BUpR
         Vj6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:to:from;
        bh=YoQ681ZYTFjY/zFx9PzM0qShZAunOVr0m8G9KhtOrxQ=;
        b=sItiUf939d6hoMigABqgfI4w6xADL3yhmdffQ6u9xihSkWetz5OgcvkgWFM1N0CqHn
         +mPV2x/zlcPXjZzDisrIQCiI4sRYNzFDyw7eYa9SkAAeW8HsZI78gqOu8CG6T+gSowWj
         3xNUc0ryC8EI4tJw7bgsyrTt8iIr9EoXAd9dBftm5LXnFWtGBjdGNs2rVnnp98fkumZ8
         zqHusfqmHWDx91ZWlVYPixe4pZFwC+82xZF5dLKAwJjy5xiQzsSJMaWZ0P3HAC9nzus1
         ALtX9Y6tnGnaub+Whbd9evng1EJhRli+ZhufCARvqSFZ2999Yxc1KwKMIkEvduU4ZCGg
         S7Rg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id e29si45752pgb.428.2019.06.06.13.17.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:17:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:17:32 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by fmsmga001.fm.intel.com with ESMTP; 06 Jun 2019 13:17:32 -0700
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
Subject: [PATCH v7 10/14] x86/vdso/32: Add ENDBR32 to __kernel_vsyscall entry point
Date: Thu,  6 Jun 2019 13:09:22 -0700
Message-Id: <20190606200926.4029-11-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200926.4029-1-yu-cheng.yu@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "H.J. Lu" <hjl.tools@gmail.com>

Add ENDBR32 to __kernel_vsyscall entry point.

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
---
 arch/x86/entry/vdso/vdso32/system_call.S | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/x86/entry/vdso/vdso32/system_call.S b/arch/x86/entry/vdso/vdso32/system_call.S
index 263d7433dea8..2fc8141fff4e 100644
--- a/arch/x86/entry/vdso/vdso32/system_call.S
+++ b/arch/x86/entry/vdso/vdso32/system_call.S
@@ -14,6 +14,9 @@
 	ALIGN
 __kernel_vsyscall:
 	CFI_STARTPROC
+#ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+	endbr32
+#endif
 	/*
 	 * Reshuffle regs so that all of any of the entry instructions
 	 * will preserve enough state.
-- 
2.17.1

