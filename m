Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89230C32757
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:02:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AD5F2085A
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:02:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AD5F2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AE0A6B0006; Tue, 13 Aug 2019 17:02:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 737406B000A; Tue, 13 Aug 2019 17:02:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FFAD6B000C; Tue, 13 Aug 2019 17:02:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0227.hostedemail.com [216.40.44.227])
	by kanga.kvack.org (Postfix) with ESMTP id 357FB6B0006
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:02:36 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id BDA4F181AC9AE
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:02:35 +0000 (UTC)
X-FDA: 75818628270.21.match57_1694e6448dd0a
X-HE-Tag: match57_1694e6448dd0a
X-Filterd-Recvd-Size: 4474
Received: from mga12.intel.com (mga12.intel.com [192.55.52.136])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:02:34 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Aug 2019 14:02:34 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,382,1559545200"; 
   d="scan'208";a="187901319"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by orsmga002.jf.intel.com with ESMTP; 13 Aug 2019 14:02:33 -0700
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
Subject: [PATCH v8 02/27] x86/cpufeatures: Add CET CPU feature flags for Control-flow Enforcement Technology (CET)
Date: Tue, 13 Aug 2019 13:52:00 -0700
Message-Id: <20190813205225.12032-3-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190813205225.12032-1-yu-cheng.yu@intel.com>
References: <20190813205225.12032-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add CPU feature flags for Control-flow Enforcement Technology (CET).

CPUID.(EAX=7,ECX=0):ECX[bit 7] Shadow stack
CPUID.(EAX=7,ECX=0):EDX[bit 20] Indirect branch tracking

Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/cpufeatures.h | 2 ++
 arch/x86/kernel/cpu/cpuid-deps.c   | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/arch/x86/include/asm/cpufeatures.h b/arch/x86/include/asm/cpufeatures.h
index e880f2408e29..122265ab46c1 100644
--- a/arch/x86/include/asm/cpufeatures.h
+++ b/arch/x86/include/asm/cpufeatures.h
@@ -334,6 +334,7 @@
 #define X86_FEATURE_OSPKE		(16*32+ 4) /* OS Protection Keys Enable */
 #define X86_FEATURE_WAITPKG		(16*32+ 5) /* UMONITOR/UMWAIT/TPAUSE Instructions */
 #define X86_FEATURE_AVX512_VBMI2	(16*32+ 6) /* Additional AVX512 Vector Bit Manipulation Instructions */
+#define X86_FEATURE_SHSTK		(16*32+ 7) /* Shadow Stack */
 #define X86_FEATURE_GFNI		(16*32+ 8) /* Galois Field New Instructions */
 #define X86_FEATURE_VAES		(16*32+ 9) /* Vector AES */
 #define X86_FEATURE_VPCLMULQDQ		(16*32+10) /* Carry-Less Multiplication Double Quadword */
@@ -358,6 +359,7 @@
 #define X86_FEATURE_MD_CLEAR		(18*32+10) /* VERW clears CPU buffers */
 #define X86_FEATURE_TSX_FORCE_ABORT	(18*32+13) /* "" TSX_FORCE_ABORT */
 #define X86_FEATURE_PCONFIG		(18*32+18) /* Intel PCONFIG */
+#define X86_FEATURE_IBT			(18*32+20) /* Indirect Branch Tracking */
 #define X86_FEATURE_SPEC_CTRL		(18*32+26) /* "" Speculation Control (IBRS + IBPB) */
 #define X86_FEATURE_INTEL_STIBP		(18*32+27) /* "" Single Thread Indirect Branch Predictors */
 #define X86_FEATURE_FLUSH_L1D		(18*32+28) /* Flush L1D cache */
diff --git a/arch/x86/kernel/cpu/cpuid-deps.c b/arch/x86/kernel/cpu/cpuid-deps.c
index b5353244749b..9bf35f081080 100644
--- a/arch/x86/kernel/cpu/cpuid-deps.c
+++ b/arch/x86/kernel/cpu/cpuid-deps.c
@@ -68,6 +68,8 @@ static const struct cpuid_dep cpuid_deps[] = {
 	{ X86_FEATURE_CQM_MBM_TOTAL,	X86_FEATURE_CQM_LLC   },
 	{ X86_FEATURE_CQM_MBM_LOCAL,	X86_FEATURE_CQM_LLC   },
 	{ X86_FEATURE_AVX512_BF16,	X86_FEATURE_AVX512VL  },
+	{ X86_FEATURE_SHSTK,		X86_FEATURE_XSAVES    },
+	{ X86_FEATURE_IBT,		X86_FEATURE_XSAVES    },
 	{}
 };
 
-- 
2.17.1


