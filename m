Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74B1EC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:17:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37E8C206BB
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:17:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37E8C206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C6166B02C7; Thu,  6 Jun 2019 16:17:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8B286B02D3; Thu,  6 Jun 2019 16:17:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 738996B02CD; Thu,  6 Jun 2019 16:17:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B06916B02CC
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:17:33 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a21so2301842pgh.11
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:17:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=MxBdNcGORUI5xTFsMiTtn1+ZbH19PBwmXl2DD0uo2d4=;
        b=Kbtq/BLquKaamxMgpEPmZmd8j8Z4riyy9qX29Ps4TyNHZcBjsno/q1lbbGNfnPsGW6
         lTYGr5pBZuzEWDv+qXNLx2I5buR+UQLRCzZQTncMz+SOiw9WMAqf4YHp0rb3AQJr0byC
         jEL2j7uPY8DQEmCGt97h+sAuEkQT2mZEY+X5+XeYTc++8J9ZEzF450VIL3D6+83j+ddU
         PMpr5jZfxY7BYZwdc6DMwDfP+Wj2tXHbbtFj0nuWGMgj7woKDM6l2O3iJqsMX5x3kdjj
         5OskpzYvkw1XQH+s+bwrX/526/yhoyuUvfU4ib88XFAWzBpT3T74H9gm4Jaz/6XEHsTc
         sZeQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXDnpW5Q12Hkku7TsCu2F4uuOnWq5VDTWZh0fws1oCjVqUAv+pv
	ehekDKNtc4RgWn/lxTfxoHCZQP4K8F8PwvQndqpRvq0oEOvrAo5o4k6N4PcQ7fWVy6u/mpg3wXG
	ih9V+KkMTGqtMriuqYW2qrfjg+qWVeB8Njr0klLBKxSP4C35ygyW4S8NcortyF2aItQ==
X-Received: by 2002:a17:902:d701:: with SMTP id w1mr46105473ply.12.1559852253367;
        Thu, 06 Jun 2019 13:17:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZ6EcRX1NtgPIki70lGLzCVacnrICGr5magmCpGiDkxtvQLWlPcPVeSUOKpGzG34/cVJjl
X-Received: by 2002:a17:902:d701:: with SMTP id w1mr46105368ply.12.1559852251634;
        Thu, 06 Jun 2019 13:17:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852251; cv=none;
        d=google.com; s=arc-20160816;
        b=IhRrq2gTmTZGkEKeXE5gf0u5TrDcoucdxHOwfzHAhxsIyDxQe9C+MGbEZ9+YHsViYB
         5Olq4oQ21+9Q2ap0GB66HJON/G4G57UcEE9/4Y3VxFHZh+PdV52rkwrG02kzrMtEO8ar
         hpz+EW+jLy+Y5aCXOtvucnjPPecNFLYMWYtbULROOKtO0hHJQGbji5q4xG/2dzZTVIHP
         dxZQlU4uzvm01EMyJhO1SYkzgF7fG/aPLZ7SRXSLzZZ8RwqMGxv8BcFrTR41umeT7d5U
         bgN4NyJi6WNAnIQe+FjmLkuIq2TpU1r6wSwoIqDKBA4tEZjJqqwXLY1fuUgR1exCmAyb
         h/Ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=MxBdNcGORUI5xTFsMiTtn1+ZbH19PBwmXl2DD0uo2d4=;
        b=yyvSJS8J68yD6A9Xdyx456EkLPpp8TvunDlMUOlPCCd4SU9mwnu5YKQHhXH7hHwg42
         l5gOoy40KHb5TdRl2FJVSepSQEncPLnWV4zQOikI2DUBFzA7CO2yOO5eGDdKvBaqoiB5
         BSQhtbCHk+WNtzwUgXkZwXVDjzOed+pjy9MIhvAZcMuGl31JUb1pi5OXGDcLqs6v0a6/
         9ZdkKRHakWkzQTfJwnHWYMt9NfOIIO6U6nqIZuzriRJh+TFlJkQKw5lGgwS4hVdE2MdS
         CUGDVkzmyqXt6Su9k7MFNqXJOasD27Of1A47kToR23r3KCREJY6VrYOYucorr4Ui3djk
         UYcQ==
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
Subject: [PATCH v7 02/14] x86/cet/ibt: User-mode indirect branch tracking support
Date: Thu,  6 Jun 2019 13:09:14 -0700
Message-Id: <20190606200926.4029-3-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200926.4029-1-yu-cheng.yu@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add user-mode indirect branch tracking enabling/disabling and
supporting routines.

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/cet.h                    |  7 ++++
 arch/x86/include/asm/disabled-features.h      |  8 ++++-
 arch/x86/kernel/cet.c                         | 36 +++++++++++++++++++
 arch/x86/kernel/cpu/common.c                  | 17 +++++++++
 .../arch/x86/include/asm/disabled-features.h  |  8 ++++-
 5 files changed, 74 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/cet.h b/arch/x86/include/asm/cet.h
index 2df357dffd24..89330e4159a9 100644
--- a/arch/x86/include/asm/cet.h
+++ b/arch/x86/include/asm/cet.h
@@ -14,8 +14,11 @@ struct sc_ext;
 struct cet_status {
 	unsigned long	shstk_base;
 	unsigned long	shstk_size;
+	unsigned long	ibt_bitmap_addr;
+	unsigned long	ibt_bitmap_size;
 	unsigned int	locked:1;
 	unsigned int	shstk_enabled:1;
+	unsigned int	ibt_enabled:1;
 };
 
 #ifdef CONFIG_X86_INTEL_CET
@@ -27,6 +30,8 @@ void cet_disable_shstk(void);
 void cet_disable_free_shstk(struct task_struct *p);
 int cet_restore_signal(bool ia32, struct sc_ext *sc);
 int cet_setup_signal(bool ia32, unsigned long rstor, struct sc_ext *sc);
+int cet_setup_ibt(void);
+void cet_disable_ibt(void);
 #else
 static inline int prctl_cet(int option, unsigned long arg2) { return -EINVAL; }
 static inline int cet_setup_shstk(void) { return -EINVAL; }
@@ -37,6 +42,8 @@ static inline void cet_disable_free_shstk(struct task_struct *p) {}
 static inline int cet_restore_signal(bool ia32, struct sc_ext *sc) { return -EINVAL; }
 static inline int cet_setup_signal(bool ia32, unsigned long rstor,
 				   struct sc_ext *sc) { return -EINVAL; }
+static inline int cet_setup_ibt(void) { return -EINVAL; }
+static inline void cet_disable_ibt(void) {}
 #endif
 
 #define cpu_x86_cet_enabled() \
diff --git a/arch/x86/include/asm/disabled-features.h b/arch/x86/include/asm/disabled-features.h
index 06323ebed643..fc7d3d5a1bf4 100644
--- a/arch/x86/include/asm/disabled-features.h
+++ b/arch/x86/include/asm/disabled-features.h
@@ -68,6 +68,12 @@
 #define DISABLE_SHSTK	(1<<(X86_FEATURE_SHSTK & 31))
 #endif
 
+#ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+#define DISABLE_IBT	0
+#else
+#define DISABLE_IBT	(1<<(X86_FEATURE_IBT & 31))
+#endif
+
 /*
  * Make sure to add features to the correct mask
  */
@@ -89,7 +95,7 @@
 #define DISABLED_MASK15	0
 #define DISABLED_MASK16	(DISABLE_PKU|DISABLE_OSPKE|DISABLE_LA57|DISABLE_UMIP|DISABLE_SHSTK)
 #define DISABLED_MASK17	0
-#define DISABLED_MASK18	0
+#define DISABLED_MASK18	(DISABLE_IBT)
 #define DISABLED_MASK_CHECK BUILD_BUG_ON_ZERO(NCAPINTS != 19)
 
 #endif /* _ASM_X86_DISABLED_FEATURES_H */
diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
index 0004333f8373..14ad25b8ff21 100644
--- a/arch/x86/kernel/cet.c
+++ b/arch/x86/kernel/cet.c
@@ -13,6 +13,8 @@
 #include <linux/uaccess.h>
 #include <linux/sched/signal.h>
 #include <linux/compat.h>
+#include <linux/vmalloc.h>
+#include <linux/bitops.h>
 #include <asm/msr.h>
 #include <asm/user.h>
 #include <asm/fpu/internal.h>
@@ -325,3 +327,37 @@ int cet_setup_signal(bool ia32, unsigned long rstor_addr, struct sc_ext *sc_ext)
 	modify_fpu_regs_end();
 	return 0;
 }
+
+int cet_setup_ibt(void)
+{
+	u64 r;
+
+	if (!cpu_feature_enabled(X86_FEATURE_IBT))
+		return -EOPNOTSUPP;
+
+	modify_fpu_regs_begin();
+	rdmsrl(MSR_IA32_U_CET, r);
+	r |= (MSR_IA32_CET_ENDBR_EN | MSR_IA32_CET_NO_TRACK_EN);
+	wrmsrl(MSR_IA32_U_CET, r);
+	modify_fpu_regs_end();
+
+	current->thread.cet.ibt_enabled = 1;
+	return 0;
+}
+
+void cet_disable_ibt(void)
+{
+	u64 r;
+
+	if (!cpu_feature_enabled(X86_FEATURE_IBT))
+		return;
+
+	modify_fpu_regs_begin();
+	rdmsrl(MSR_IA32_U_CET, r);
+	r &= ~(MSR_IA32_CET_ENDBR_EN | MSR_IA32_CET_LEG_IW_EN |
+	       MSR_IA32_CET_NO_TRACK_EN | MSR_IA32_CET_BITMAP_MASK);
+	wrmsrl(MSR_IA32_U_CET, r);
+	modify_fpu_regs_end();
+
+	current->thread.cet.ibt_enabled = 0;
+}
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index b0780fe8717e..7fa38e4a9e82 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -441,6 +441,23 @@ static __init int setup_disable_shstk(char *s)
 __setup("no_cet_shstk", setup_disable_shstk);
 #endif
 
+#ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+static __init int setup_disable_ibt(char *s)
+{
+	/* require an exact match without trailing characters */
+	if (s[0] != '\0')
+		return 0;
+
+	if (!boot_cpu_has(X86_FEATURE_IBT))
+		return 1;
+
+	setup_clear_cpu_cap(X86_FEATURE_IBT);
+	pr_info("x86: 'no_cet_ibt' specified, disabling Branch Tracking\n");
+	return 1;
+}
+__setup("no_cet_ibt", setup_disable_ibt);
+#endif
+
 /*
  * Some CPU features depend on higher CPUID levels, which may not always
  * be available due to CPUID level capping or broken virtualization
diff --git a/tools/arch/x86/include/asm/disabled-features.h b/tools/arch/x86/include/asm/disabled-features.h
index 06323ebed643..fc7d3d5a1bf4 100644
--- a/tools/arch/x86/include/asm/disabled-features.h
+++ b/tools/arch/x86/include/asm/disabled-features.h
@@ -68,6 +68,12 @@
 #define DISABLE_SHSTK	(1<<(X86_FEATURE_SHSTK & 31))
 #endif
 
+#ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+#define DISABLE_IBT	0
+#else
+#define DISABLE_IBT	(1<<(X86_FEATURE_IBT & 31))
+#endif
+
 /*
  * Make sure to add features to the correct mask
  */
@@ -89,7 +95,7 @@
 #define DISABLED_MASK15	0
 #define DISABLED_MASK16	(DISABLE_PKU|DISABLE_OSPKE|DISABLE_LA57|DISABLE_UMIP|DISABLE_SHSTK)
 #define DISABLED_MASK17	0
-#define DISABLED_MASK18	0
+#define DISABLED_MASK18	(DISABLE_IBT)
 #define DISABLED_MASK_CHECK BUILD_BUG_ON_ZERO(NCAPINTS != 19)
 
 #endif /* _ASM_X86_DISABLED_FEATURES_H */
-- 
2.17.1

