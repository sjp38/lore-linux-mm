Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2014DC28EB7
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA52D208C3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA52D208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A955F6B0293; Thu,  6 Jun 2019 16:15:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A45A46B0294; Thu,  6 Jun 2019 16:15:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 848B06B0295; Thu,  6 Jun 2019 16:15:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6BE6B0294
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:19 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id k23so2304055pgh.10
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=cYY5bIPKktAYkfjxzWANjKvdbOk+wrI8+3g36JZ+4qg=;
        b=WMwgqmrrEuDweb3afoR1/w/ndV4PJYgTEhgkfhknapwhJvEbDAYm5zE3TlHsAmf66f
         M6Do4eEUJhvm/7vKSCZCwB4L3Xtae+K/fDdzetZSIt/ghng4Bj6QzOLmXWBvNqsEIBqM
         e3kE4ZLPo6ek6SsGZr82FKf0Cug64OoGc+Pr6VCnr3sFCy2zYcSETqXRVh5qYeMPpsXs
         mhwFfXw3+0rxl7Eo1aLBUdIIufc7mPuyj9T+M4IN0QfhS0LJJpmi5uYZumhViZIt6fC9
         qNOsZHdXSL5R4CFrL4X0khabg+EnOzdLastltFKLz8JiHy0UhBADbQnCbOEGI7Oo7EmA
         vITg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXIW9legGAANOJgVaIsMcq/brHi0Gh8aVqxDbypMTLnTFSOphXA
	zih8w9+g8UI6gODAwU/Hs1OYZvbBZY+m1IbMzH9ze+WxYUzYOBnjj1ZJuE0aFne4zmlirqXjXIq
	tcusyX47PUqVITZyfJHofNbUO6W3ulWRLBFVYwNo+3ylsyZQ+jjcUE1wYioPpK9i1/Q==
X-Received: by 2002:a17:902:2d:: with SMTP id 42mr52128747pla.34.1559852118879;
        Thu, 06 Jun 2019 13:15:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLFuL/U3j9wKvX+cK2AzMVI/wcM7cVF2CIoEZPPjr17/pGzklrvUUXNMaWxObo34nCiUyl
X-Received: by 2002:a17:902:2d:: with SMTP id 42mr52128685pla.34.1559852118005;
        Thu, 06 Jun 2019 13:15:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852118; cv=none;
        d=google.com; s=arc-20160816;
        b=FireMYU9wXa3KyNDa36uLa7TbUcQB03LxKzP11AHoapxJHDqbHXISsgsXpl66+w6Ty
         ZIBmslfstlMac4plTZYlSgw8oMa/h8bEvrmeMOeb60DO121gXWgwHQEHSRT/tGjETUmN
         /cNNrurxZ1MMf/AOroITZTZa8GoZULQgQ2Y693IOh7s7d3GKy/osYVqBZ3Jxsvd277PR
         fed9o5RGrhqRExgvIHW3w4UCicuOIeDEn5SrPqf1iLNv65KAs/AFj8lSnBoGWVmxebQo
         4qi3GUGAVhRHQlD1mNDdu1VhMTeiRx6jb8VBOF2Qlz1ibAax1MFuG5TAGYTxgoci9W7M
         4MCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=cYY5bIPKktAYkfjxzWANjKvdbOk+wrI8+3g36JZ+4qg=;
        b=ioX8A1rKg3OMYaf914swmvxflFJ5rZbCZEApX15Flh1+lMJDeMCK5LwsTrltRp+oYt
         VHTIve/3rNHVnwYXK1pN2TCfEVCuxJtKGaDI+gu7WUU9lSB4jeyYPAn+seAgz1Fr9MP8
         zd9hjJ9f8KARugDGaY8hk3i2OhYAk2tV4jtzMyj65Z1AN7GMAv/LjnDTWychzKglpDXy
         vGrUdwRD7td+wKF7ZTDGA3vYpuYLmMUR12seZK7ULeE0h1uDYABvvRavYOngqxgluYx+
         KIfWlBmblwnf1u9tIqwESzRTivuIpFP5AL4uWoC8ClzKs3nMroyijFsl8v1YjPgqaQ4o
         DwGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 91si31377plh.398.2019.06.06.13.15.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:17 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:16 -0700
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
Subject: [PATCH v7 07/27] x86/cet/shstk: Add Kconfig option for user-mode shadow stack
Date: Thu,  6 Jun 2019 13:06:26 -0700
Message-Id: <20190606200646.3951-8-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Introduce Kconfig option X86_INTEL_SHADOW_STACK_USER.

An application has shadow stack protection when all the following are
true:

  (1) The kernel has X86_INTEL_SHADOW_STACK_USER enabled,
  (2) The running processor supports the shadow stack,
  (3) The application is built with shadow stack enabled tools & libs
      and, and at runtime, all dependent shared libs can support
      shadow stack.

If this kernel config option is enabled, but (2) or (3) above is not
true, the application runs without the shadow stack protection.
Existing legacy applications will continue to work without the shadow
stack protection.

The user-mode shadow stack protection is only implemented for the
64-bit kernel.  Thirty-two bit applications are supported under the
compatibility mode.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/Kconfig  | 25 +++++++++++++++++++++++++
 arch/x86/Makefile |  7 +++++++
 2 files changed, 32 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 2bbbd4d1ba31..1664918c2c1c 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1915,6 +1915,31 @@ config X86_INTEL_MEMORY_PROTECTION_KEYS
 
 	  If unsure, say y.
 
+config X86_INTEL_CET
+	def_bool n
+
+config ARCH_HAS_SHSTK
+	def_bool n
+
+config X86_INTEL_SHADOW_STACK_USER
+	prompt "Intel Shadow Stack for user-mode"
+	def_bool n
+	depends on CPU_SUP_INTEL && X86_64
+	select ARCH_USES_HIGH_VMA_FLAGS
+	select X86_INTEL_CET
+	select ARCH_HAS_SHSTK
+	---help---
+	  Shadow stack provides hardware protection against program stack
+	  corruption.  Only when all the following are true will an application
+	  have the shadow stack protection: the kernel supports it (i.e. this
+	  feature is enabled), the application is compiled and linked with
+	  shadow stack enabled, and the processor supports this feature.
+	  When the kernel has this configuration enabled, existing non shadow
+	  stack applications will continue to work, but without shadow stack
+	  protection.
+
+	  If unsure, say y.
+
 config EFI
 	bool "EFI runtime service support"
 	depends on ACPI
diff --git a/arch/x86/Makefile b/arch/x86/Makefile
index 56e748a7679f..0b2e9df48907 100644
--- a/arch/x86/Makefile
+++ b/arch/x86/Makefile
@@ -148,6 +148,13 @@ ifdef CONFIG_X86_X32
 endif
 export CONFIG_X86_X32_ABI
 
+# Check assembler shadow stack suppot
+ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
+  ifeq ($(call as-instr, saveprevssp, y),)
+      $(error CONFIG_X86_INTEL_SHADOW_STACK_USER not supported by the assembler)
+  endif
+endif
+
 #
 # If the function graph tracer is used with mcount instead of fentry,
 # '-maccumulate-outgoing-args' is needed to prevent a GCC bug
-- 
2.17.1

