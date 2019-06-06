Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4C20C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:17:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96F5D208C3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:17:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96F5D208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C19396B02CA; Thu,  6 Jun 2019 16:17:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 674616B02D2; Thu,  6 Jun 2019 16:17:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F27416B02CE; Thu,  6 Jun 2019 16:17:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9CA7B6B02CA
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:17:33 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id w14so2174722plp.4
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:17:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=3VJ0WWv3LaOzz+xD3ap/pxIbfCqqdWTv36ugzPj6SpU=;
        b=QHSwOFGCGwD9E1Z2bA+brKaItilAWCpftoR7ov8dUmS7KE/E9u914SlkQoKYzZe3wk
         jLhEo4R9Htoa1mTQQAuu/DVh5uvLtGyYVU1lXYe3CodQusbT0FvsXIuM9n9NnAtZVuvE
         76whPqjexaqHfQjHLskt1zeFKppLmYltHc0k2JZvj3hYA3xTZmUjy7l/t1PiNoWZFWX4
         IjykjyMKOtlxP4bpLR8lwFyv5tdLfys1msgjauVDO6oewQxVE6ptHFQ0kkIrV6SggD2A
         tIzUHxpjcCSY4bcSEfzG/yyB1c+t6BZx80R1WUiizKvDJkKhbcB/xyms1w/1INKnl4om
         9L8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWgtlL0sj/MLItQLTAGIRbh/lrTrtHkp8wHKrYvOBS/HOUAF/UQ
	wf+yeSHXWLALZGumY4D1wfy4909re5kQydeafacgoARZowxjqf6CKovBVX1wGjcqqbkHQwrVxhd
	K1fErJakIUq/L/aO/op7+UCgJrehabLLs5XP5iXw9kte0C91O3Wt7Rgf38fOIVbvxvw==
X-Received: by 2002:a17:90a:8e86:: with SMTP id f6mr1648130pjo.66.1559852253327;
        Thu, 06 Jun 2019 13:17:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSBvy2Nca85GdVDT+tucIrI3z8+6kRBIo8NtXwEqsQ9WbtbS2AredsYHVZ8i+X2Dp9FKHA
X-Received: by 2002:a17:90a:8e86:: with SMTP id f6mr1648031pjo.66.1559852252067;
        Thu, 06 Jun 2019 13:17:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852252; cv=none;
        d=google.com; s=arc-20160816;
        b=jiN/tNNBrwpR1buBtLYB8LR6KYq/dIcvIVfoYyMWPlqwG9giLRUygU2z8JRCsAJAS3
         XB7EAX/+xpGqqGQ+c2L5zRh1Fv8MmjuAAuEdQbEFD6cLIayv4oreEDy6ydxpnLVjToV4
         OFrIsgFbw+XyunzyRLZwyS+Jhud/IzBtPK56POK3n+jVBxk3dgntjAV0phTk6nD40WGX
         fePFKRKWpbQhK3zHtxkTazM1LseZGnUcEoWbudu4h3JHSGhDOQBSvc5D2ZCv+lhm+6sK
         IuQkQilO96grrVzhP1Dgn7VoCAU3I57BdULhqPVEBX5lUO6jmVnQoIEexUCSw/Hwhwza
         Uv8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=3VJ0WWv3LaOzz+xD3ap/pxIbfCqqdWTv36ugzPj6SpU=;
        b=kHtzGVkCOSrhGSUD+FZCc/yWyARaFg+I2pozP3ycoE4ckObnT3qZGn94dhnacM7/Nm
         4h5Nxq/eJ+ci0a+h3amBVOhm0qT1etzuRKX5iFwMHPsS4dgQsndXSJF1a2D8hGL8BWNw
         PGcU9iWhtsKT1+yGmHIUkUX4ZrNptvHlioDnkBf+PyBEKnCEWhtl0F5wqgCmOmknf2Qe
         fxih67aV8+dANuXraqHMtWIMveC90yD6OaGUPL3covdvOZzixfW7h6gmZZAEnKPOM86N
         Oy06nypH/X+z0e2WkGIafaMZEbuhQbr/WN20lTxV3QizofwmUF2IRYnsGxp3jC6poc8U
         pW/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id t11si66755plr.23.2019.06.06.13.17.31
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
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:17:31 -0700
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
Subject: [PATCH v7 04/14] x86/cet/ibt: Handle signals for IBT
Date: Thu,  6 Jun 2019 13:09:16 -0700
Message-Id: <20190606200926.4029-5-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200926.4029-1-yu-cheng.yu@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Setup/Restore Indirect Branch Tracking for signals.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/kernel/cet.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
index e0ef996d3148..e1ab7e722637 100644
--- a/arch/x86/kernel/cet.c
+++ b/arch/x86/kernel/cet.c
@@ -282,6 +282,15 @@ int cet_restore_signal(bool ia32, struct sc_ext *sc_ext)
 		msr_ia32_u_cet |= MSR_IA32_CET_SHSTK_EN;
 	}
 
+	if (current->thread.cet.ibt_enabled) {
+		if (current->thread.cet.ibt_bitmap_addr != 0)
+			msr_ia32_u_cet |= (current->thread.cet.ibt_bitmap_addr |
+					   MSR_IA32_CET_LEG_IW_EN);
+
+		msr_ia32_u_cet |= (MSR_IA32_CET_ENDBR_EN |
+				   MSR_IA32_CET_NO_TRACK_EN);
+	}
+
 	wrmsrl(MSR_IA32_PL3_SSP, new_ssp);
 	wrmsrl(MSR_IA32_U_CET, msr_ia32_u_cet);
 	return 0;
@@ -322,6 +331,15 @@ int cet_setup_signal(bool ia32, unsigned long rstor_addr, struct sc_ext *sc_ext)
 		sc_ext->ssp = new_ssp;
 	}
 
+	if (current->thread.cet.ibt_enabled) {
+		if (current->thread.cet.ibt_bitmap_addr != 0)
+			msr_ia32_u_cet |= (current->thread.cet.ibt_bitmap_addr |
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

