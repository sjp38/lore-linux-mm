Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E56EAC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:04:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8EC320840
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:04:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8EC320840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B8406B0299; Tue, 13 Aug 2019 17:03:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62FCB6B029B; Tue, 13 Aug 2019 17:03:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38D566B029E; Tue, 13 Aug 2019 17:03:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0095.hostedemail.com [216.40.44.95])
	by kanga.kvack.org (Postfix) with ESMTP id EA4036B0299
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:03:42 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 8B1B1180AD7C1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:03:42 +0000 (UTC)
X-FDA: 75818631084.02.screw42_205168e7e4020
X-HE-Tag: screw42_205168e7e4020
X-Filterd-Recvd-Size: 3496
Received: from mga06.intel.com (mga06.intel.com [134.134.136.31])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:03:41 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Aug 2019 14:03:39 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,382,1559545200"; 
   d="scan'208";a="194275968"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by fmsmga001.fm.intel.com with ESMTP; 13 Aug 2019 14:03:39 -0700
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
Subject: [PATCH v8 03/14] x86/cet/ibt: Handle signals for end branch
Date: Tue, 13 Aug 2019 13:53:48 -0700
Message-Id: <20190813205359.12196-4-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190813205359.12196-1-yu-cheng.yu@intel.com>
References: <20190813205359.12196-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Restore end branch tracking setting from thread header.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/kernel/cet.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
index 505a69f476e1..db542bd423cc 100644
--- a/arch/x86/kernel/cet.c
+++ b/arch/x86/kernel/cet.c
@@ -281,6 +281,15 @@ int cet_restore_signal(bool ia32, struct sc_ext *sc_ext)
 		msr_ia32_u_cet |= MSR_IA32_CET_SHSTK_EN;
 	}
 
+	if (current->thread.cet.ibt_enabled) {
+		if (current->thread.cet.ibt_bitmap_used)
+			msr_ia32_u_cet |= (IBT_BITMAP_ADDR |
+					   MSR_IA32_CET_LEG_IW_EN);
+
+		msr_ia32_u_cet |= (MSR_IA32_CET_ENDBR_EN |
+				   MSR_IA32_CET_NO_TRACK_EN);
+	}
+
 	wrmsrl(MSR_IA32_PL3_SSP, new_ssp);
 	wrmsrl(MSR_IA32_U_CET, msr_ia32_u_cet);
 	return 0;
@@ -321,6 +330,15 @@ int cet_setup_signal(bool ia32, unsigned long rstor_addr, struct sc_ext *sc_ext)
 		sc_ext->ssp = new_ssp;
 	}
 
+	if (current->thread.cet.ibt_enabled) {
+		if (current->thread.cet.ibt_bitmap_used)
+			msr_ia32_u_cet |= (IBT_BITMAP_ADDR |
+					   MSR_IA32_CET_LEG_IW_EN);
+
+		msr_ia32_u_cet |= (MSR_IA32_CET_ENDBR_EN |
+				   MSR_IA32_CET_NO_TRACK_EN);
+	}
+
 	modify_fpu_regs_begin();
 	wrmsrl(MSR_IA32_PL3_SSP, ssp);
 	wrmsrl(MSR_IA32_U_CET, msr_ia32_u_cet);
-- 
2.17.1


