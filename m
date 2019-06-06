Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1AC1C28EB4
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:17:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77423208C3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:17:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77423208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEDF66B02C1; Thu,  6 Jun 2019 16:17:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D75E96B02C3; Thu,  6 Jun 2019 16:17:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF03A6B02C5; Thu,  6 Jun 2019 16:17:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8604B6B02C3
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:17:32 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id r12so2615707pfl.2
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:17:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Jhf9gR8u8yuAfzOUIytJh5IAaaOTGX4VHhD1DAfLt28=;
        b=aBtjH0q7PmGOJQLE2u035mqVh0RDd3aWUUnpavFFM+72XjxbKRJXp/gZyZM1kNnJFK
         XNapASgMqPZoZ5cwqwmnmLTRtfE3HxthbE194njFzRbsse53MB7rd2xF36gG2ufX1+oS
         cUANN8QFa1M6+MSOsvgUN45TSKDy/pleF/f/nLXAeWUbbpadzbA0eakMmk1accN9ie25
         MooCP8MqmtOWc0KVCva2Y1kvWY+etlc51LIXm4ZmByv78h+ODcB51TEx8kRacjNqyskH
         mugoqCd59fTUjGQtZjE9g2HAHVSsAscx0krt3VTmweNvQ96rspCQFt09lDiN7ExHSPSl
         GPcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU3PFhx76Vw2qEgjL0Ry2Ihx1d9hHzNXObPk4A9cqUruERyFn8I
	aQwVDwJMUBXOMW9gNhvoa+OxHuphPWM4C2wwgfcVMF3EESDSvO1C0Z8gdWh9ATDanXZHQDilo8B
	m/WmnemgaAFkAWudPMlOn9VFWbfs/C9CTOu7IoaGRh7fMP5a+/F8FAZg/2dT99hE0Gw==
X-Received: by 2002:a63:1d53:: with SMTP id d19mr332481pgm.152.1559852252078;
        Thu, 06 Jun 2019 13:17:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfSMsQ89ydmrangJMK39dreHgbcyO/8b+51yRAsnmhxo4Cde8TBVnFkOOvnVurijiGoceO
X-Received: by 2002:a63:1d53:: with SMTP id d19mr332433pgm.152.1559852251306;
        Thu, 06 Jun 2019 13:17:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852251; cv=none;
        d=google.com; s=arc-20160816;
        b=Tz0nlrDAiFLk8evi4st+IAMjtDE55dZjuJ+sj1UcJ+sY44yrUpu1QJa0SZ5D+4LPFx
         mliPTuA2dvb8ZEmMQEMb7dSE6/Y91ejXAnPox5deulEu3U7H1KZrVfgZVrL30lJ1Vyfl
         qSQBkIhV+xFUhkm+RusyS4fy5mYPO7+oocmE8DIq3e8lkJ+t1IWQQetR37OqlqFY2MRu
         /5JeSsZBWg6+8a3PUytj1w9Epf4T9kUwzLYscRl28YiITtbypZuTJMFBIrBW5da/PcIx
         da2AFlKPFrgxwLQVG7ogZ2ftgiGO0M2iW7tCa0Oam3B9IgmE+CA7REF+LOU0m6jGYbRa
         PjpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Jhf9gR8u8yuAfzOUIytJh5IAaaOTGX4VHhD1DAfLt28=;
        b=H7bLoxfQyNiry2dt2Rwn+2hrtVwq5y6FvrWlL6tE6NAL0V923u0aZanKTP6AAlABfU
         UCmM7554zKciGlyIX4qjMzeuo/A1bryAI798hr+Kw1CRW5B40wUVyUsdbcUO8Lr0zOP/
         /YNF2THqSF8FI1SlSgPlc9585JMPwvkKD7D5zBt6vieEcz2i/XQ4X40t50h6TaPQ2k3Q
         Sl1MS12AALUd1C7a046mTt/HkAsZFO+DiCEVgPmSWLyHCP6VXVh20wdFhIT/ZPCC4tkk
         gchotSkkKoEQY265EhKBNZb42GUUcu0Nkq8JYjkn5b2c+gP2u20lxwXdMW8SIuBNI76M
         G/ug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id t11si66755plr.23.2019.06.06.13.17.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:17:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:17:30 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by fmsmga001.fm.intel.com with ESMTP; 06 Jun 2019 13:17:30 -0700
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
Subject: [PATCH v7 01/14] x86/cet/ibt: Add Kconfig option for user-mode Indirect Branch Tracking
Date: Thu,  6 Jun 2019 13:09:13 -0700
Message-Id: <20190606200926.4029-2-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200926.4029-1-yu-cheng.yu@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The user-mode indirect branch tracking support is done mostly by GCC
to insert ENDBR64/ENDBR32 instructions at branch targets.  The kernel
provides CPUID enumeration and feature setup.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/Kconfig  | 16 ++++++++++++++++
 arch/x86/Makefile |  7 +++++++
 2 files changed, 23 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index df8b57de75b2..47afe47c01eb 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1921,6 +1921,9 @@ config X86_INTEL_CET
 config ARCH_HAS_SHSTK
 	def_bool n
 
+config ARCH_HAS_AS_LIMIT
+	def_bool n
+
 config X86_INTEL_SHADOW_STACK_USER
 	prompt "Intel Shadow Stack for user-mode"
 	def_bool n
@@ -1941,6 +1944,19 @@ config X86_INTEL_SHADOW_STACK_USER
 
 	  If unsure, say y.
 
+config X86_INTEL_BRANCH_TRACKING_USER
+	prompt "Intel Indirect Branch Tracking for user-mode"
+	def_bool n
+	depends on CPU_SUP_INTEL && X86_64
+	select X86_INTEL_CET
+	select ARCH_HAS_AS_LIMIT
+	select ARCH_USE_GNU_PROPERTY
+	---help---
+	  Indirect Branch Tracking provides hardware protection against return-/jmp-
+	  oriented programming attacks.
+
+	  If unsure, say y
+
 config EFI
 	bool "EFI runtime service support"
 	depends on ACPI
diff --git a/arch/x86/Makefile b/arch/x86/Makefile
index 0b2e9df48907..25372cc4a303 100644
--- a/arch/x86/Makefile
+++ b/arch/x86/Makefile
@@ -155,6 +155,13 @@ ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
   endif
 endif
 
+# Check compiler ibt support
+ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+  ifeq ($(call cc-option-yn, -fcf-protection=branch), n)
+      $(error CONFIG_X86_INTEL_BRANCH_TRACKING_USER not supported by compiler)
+  endif
+endif
+
 #
 # If the function graph tracer is used with mcount instead of fentry,
 # '-maccumulate-outgoing-args' is needed to prevent a GCC bug
-- 
2.17.1

