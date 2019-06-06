Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61E5AC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:16:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2790B208CA
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:16:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2790B208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C42056B02B7; Thu,  6 Jun 2019 16:15:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCF786B02B9; Thu,  6 Jun 2019 16:15:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A930F6B02BA; Thu,  6 Jun 2019 16:15:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA306B02B7
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:40 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j21so2064641pff.12
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=3rc5WSC9lu5I3YPet9/X+BLe3GdVT7Iar3wD/bHVsGQ=;
        b=fq4MS7uaQZuJNPGO4vlBbDVvMjH9EKyCjLxA2VoCC4GmkgaiOgC604orWCoIIhSVn4
         SuMtJcs+/27G6aGb7Se2yGFK9hb9aa8uucmIxuBfgiW4mOSSbUgqWGpVp+aYx+tASgA8
         RXDeCmU5jljo/3rbWBiFGLbLMwYBg7TzHJ0qYdNKAcDI2C8LGE5fwjsuwQwHSW4gVUqm
         VbWaIqQ56bXO38jl1F8K+4FYQdos5MRf4SiNGTuDz2uHwAq/JzRcpAGex5mNG8fgaf57
         kFUf3bQqysOLTlN9mEKMGg2oo9a0XbGFp93DLPcLqnTQyTw9xpfLzSsZRQYvGRXk/Yg5
         UA1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAULCqqvMiWoQTnKNfJCzTqBsxRVYDWypjg5RxInZ9FcsAmx6Abk
	LUkvfwI4wMjQaFoyNV9Td+H5CsQJDOa7ffbe5O0BsinIeYd1O6oB4SVsC2icarWQxe5eOPz4TId
	mO0BsAtW67xdVu43BQBWegXEWvcxHIQV+7bJJ30hOEKazSqcJGThdZWut9wBOQZG88A==
X-Received: by 2002:aa7:8dcd:: with SMTP id j13mr53474952pfr.107.1559852140112;
        Thu, 06 Jun 2019 13:15:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfKyIQKg6elaj5Q+zcn3QyzweClOISOYzY5CgYjtSUBoCmghpk3Vnx1bwur2IQyTkJUEej
X-Received: by 2002:aa7:8dcd:: with SMTP id j13mr53474889pfr.107.1559852139136;
        Thu, 06 Jun 2019 13:15:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852139; cv=none;
        d=google.com; s=arc-20160816;
        b=YE6gbmQ4MgB1r4yzwpb+3T3bJLMxPwUEa9gzFjPzN2D2abXZaeYFCN849LYA95+bdo
         TjJHYeic0/pVr7VT7zf7+Eqr2pqKUFUv9UZg122okvdmjSwiW49Vb10BYMG5QSJGCYA+
         M74NCW2MKPEuP+Or+HMLrkxGvDxzhNZC4VHh04PbqVY8MdeFg9wG08vYE7hQ9vH4lxEI
         hjUNnnq3s63DhNS4IkNHiMRKW3DJLzlbPdH2aFXdMYi85865+amL+kMScDDIKMGO6Qnr
         qm6uR6HrYZ/1sSwaF8A9TncDAwn3LekLPeFkbNzJVr5FMq8mvnq1IWVttinoUwQuDdxu
         UZLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=3rc5WSC9lu5I3YPet9/X+BLe3GdVT7Iar3wD/bHVsGQ=;
        b=PFHZp2oLQoSCZx0x/MeWvt9p3xJzjLXuE8I5eLVPTVwMsBz3LRMfcpzQ66R86Dyvit
         FTOj8FR/Ax3z/TqIdCUrhFGVU9YVEWbEpmWn08w5f0jfJ70tUuD3zwsJ91oQuJFixMYr
         80CtGgubuA75Xov7M5qVg2bP1pe+mSuu1JqnIpC+JinapaCp4Q6oocO+fJPs6pUSGvfH
         Q/AgrU++16nXbwHp/lyP/fSHyfPn9Mr+8GTVykIrFd0YcKovNUAtltS5SNO1vSNST25U
         cYIRofZXeNQgkQRk6NcAGUv/gyPfZLqv5e1irS0q+fTb5d1KxQ83V0QiT0yC2u8tOFYU
         Y8Xw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id r142si2785300pfc.219.2019.06.06.13.15.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:38 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:37 -0700
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
Subject: [PATCH v7 23/27] x86/cet/shstk: ELF header parsing of Shadow Stack
Date: Thu,  6 Jun 2019 13:06:42 -0700
Message-Id: <20190606200646.3951-24-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Look in .note.gnu.property of an ELF file and check if Shadow Stack needs
to be enabled for the task.

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/Kconfig             |  1 +
 arch/x86/kernel/process_64.c | 24 ++++++++++++++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 1664918c2c1c..df8b57de75b2 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1928,6 +1928,7 @@ config X86_INTEL_SHADOW_STACK_USER
 	select ARCH_USES_HIGH_VMA_FLAGS
 	select X86_INTEL_CET
 	select ARCH_HAS_SHSTK
+	select ARCH_USE_GNU_PROPERTY
 	---help---
 	  Shadow stack provides hardware protection against program stack
 	  corruption.  Only when all the following are true will an application
diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index 250e4c4ac6d9..c51df5b4e116 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -828,3 +828,27 @@ unsigned long KSTK_ESP(struct task_struct *task)
 {
 	return task_pt_regs(task)->sp;
 }
+
+#ifdef CONFIG_ARCH_USE_GNU_PROPERTY
+int arch_setup_property(void *ehdr, void *phdr, struct file *f, bool inter)
+{
+	int r;
+	uint32_t property;
+
+	r = get_gnu_property(ehdr, phdr, f, GNU_PROPERTY_X86_FEATURE_1_AND,
+			     &property);
+
+	memset(&current->thread.cet, 0, sizeof(struct cet_status));
+
+	if (r)
+		return r;
+
+	if (cpu_feature_enabled(X86_FEATURE_SHSTK)) {
+		if (property & GNU_PROPERTY_X86_FEATURE_1_SHSTK)
+			r = cet_setup_shstk();
+		if (r < 0)
+			return r;
+	}
+	return r;
+}
+#endif
-- 
2.17.1

