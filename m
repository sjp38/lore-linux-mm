Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5021DC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:17:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1210C208C3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:17:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1210C208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EED66B02C3; Thu,  6 Jun 2019 16:17:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FE3B6B02C5; Thu,  6 Jun 2019 16:17:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C53E6B02C7; Thu,  6 Jun 2019 16:17:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id EED706B02C5
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:17:32 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s195so2301394pgs.13
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:17:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=JTPqqzl61LcXZknOh3vX8Y4ZIjcvIm2PCMu/cmAquKI=;
        b=JObXQSnJQEXJ+LCkkmT4zLxxVXf28Dcgpe7PkwzM2xLV3iFf8dgNBBfEMZKylAN7zr
         V4wSdo0qSmWSyhFR+/owvv7bi+UuSqK5vySdcVWqBrW7fRkppY440Zec+Y4zi9YoZb+J
         GeOkIkfpltc03dNtzFDonueAFxwLeajOuR6/grHL/6woFfdiNophKIuocmFSWKYe5Gr1
         cq92Ctjej88Zsgm8sOLayHEUShvx+JOpYFDqm4nFcJEvEoK1ITJOBcL1oxP8RyiCtV6F
         pBF84R0pNrsQb4Rd6iCB2EfvAz4JLxCfhHgQKodh1LvbbyYXHi8SvciOOmMepcf9da9/
         zD/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWb39LIzTAmyFCz9Co6PNRaC6MP7TE1zuL9/E0d3N1MMhuI7H7c
	UeRWii7CAoLGOPXYr2zFifrE98DdPEQqoCItipUPz3TSE8XibfcArBh3MBSb12rtmDxpte+GsPL
	LS9h9RmQ0cecayqDnv79q8GuQ9A44YTMKkVrSdtBgH1o3l6mB5tjBtJ+nBlX3fCejVw==
X-Received: by 2002:a17:90a:8985:: with SMTP id v5mr1627207pjn.136.1559852252631;
        Thu, 06 Jun 2019 13:17:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxk3jRXGFd/l+4rH06hT5Ff+WCpWQp0y19bdpDqSPc6tQ3O1G9Id06WKiAvlp5RExu5MmXz
X-Received: by 2002:a17:90a:8985:: with SMTP id v5mr1627167pjn.136.1559852251844;
        Thu, 06 Jun 2019 13:17:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852251; cv=none;
        d=google.com; s=arc-20160816;
        b=vaS7vOPSz2p4LeA8QoO6n2eXbtPH38MTn/hzO7DN57AFxQNUOEyEIMgytOvkXiQLj0
         1fMd8mhS3X/g7s82+HABL++r9Fo+IkTdEVQixyjy04+t8VW+qhWdtP7AiPpsTJiX9hjJ
         LC2HCQLfh2ARGeVqZWoxqg5QSaGAoG3dDzMSk236ie1R5Lj7nhcLFvInbe3XlD+UxFTg
         tQY0zz+6gN0HGQVo3evxLjtF9XqKzQN/Df4jvAPlzik/Z/3ISnuYGK6BKWe9MdoCUgl2
         HICekpPPG66M1eQxBRrUQXJ84zTqjrVjQB4oQbtt2I91YGxbD4QGMPO082tqFSgmZbmA
         sGVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=JTPqqzl61LcXZknOh3vX8Y4ZIjcvIm2PCMu/cmAquKI=;
        b=z0Mg4DmwTu9HRLDaaAR489cHZ6TumfiG4WEHKd8fmMl7Y+X4vXIQ3W39nsZJNGOxln
         kwk4Md+JCbiqK3ZqNTLbvSTeKU9SDszhoz/bj/rAOEz7X5C5sLAme8ZTCKNzAfbrEMRQ
         0uxVpQNLSDI+YGirVdAK3f3v3RRQOE0Rj/z66x62+quPByA9jCVQCvVGMqlF6+R+d/Nr
         J1ETQRKrjFQ10uqQ1Zvd/pQ9Gbwk70ukphcyduckpgFA6lpP0yZZYZhH7yLpkExtKxsY
         MhXk0EXz/6YQIbZzd13ArlWmHdJyYFGKq3/FxStQ2ckVIfwgJuUVvPXB39mS9GJdeeFB
         kQPA==
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
Subject: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup function
Date: Thu,  6 Jun 2019 13:09:15 -0700
Message-Id: <20190606200926.4029-4-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200926.4029-1-yu-cheng.yu@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Indirect Branch Tracking (IBT) provides an optional legacy code bitmap
that allows execution of legacy, non-IBT compatible library by an
IBT-enabled application.  When set, each bit in the bitmap indicates
one page of legacy code.

The bitmap is allocated and setup from the application.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/cet.h |  1 +
 arch/x86/kernel/cet.c      | 26 ++++++++++++++++++++++++++
 2 files changed, 27 insertions(+)

diff --git a/arch/x86/include/asm/cet.h b/arch/x86/include/asm/cet.h
index 89330e4159a9..9e613a6598c9 100644
--- a/arch/x86/include/asm/cet.h
+++ b/arch/x86/include/asm/cet.h
@@ -31,6 +31,7 @@ void cet_disable_free_shstk(struct task_struct *p);
 int cet_restore_signal(bool ia32, struct sc_ext *sc);
 int cet_setup_signal(bool ia32, unsigned long rstor, struct sc_ext *sc);
 int cet_setup_ibt(void);
+int cet_setup_ibt_bitmap(unsigned long bitmap, unsigned long size);
 void cet_disable_ibt(void);
 #else
 static inline int prctl_cet(int option, unsigned long arg2) { return -EINVAL; }
diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
index 14ad25b8ff21..e0ef996d3148 100644
--- a/arch/x86/kernel/cet.c
+++ b/arch/x86/kernel/cet.c
@@ -22,6 +22,7 @@
 #include <asm/fpu/types.h>
 #include <asm/cet.h>
 #include <asm/special_insns.h>
+#include <asm/elf.h>
 #include <uapi/asm/sigcontext.h>
 
 static int set_shstk_ptr(unsigned long addr)
@@ -361,3 +362,28 @@ void cet_disable_ibt(void)
 
 	current->thread.cet.ibt_enabled = 0;
 }
+
+int cet_setup_ibt_bitmap(unsigned long bitmap, unsigned long size)
+{
+	u64 r;
+
+	if (!current->thread.cet.ibt_enabled)
+		return -EINVAL;
+
+	if (!PAGE_ALIGNED(bitmap) || (size > TASK_SIZE_MAX))
+		return -EINVAL;
+
+	current->thread.cet.ibt_bitmap_addr = bitmap;
+	current->thread.cet.ibt_bitmap_size = size;
+
+	/*
+	 * Turn on IBT legacy bitmap.
+	 */
+	modify_fpu_regs_begin();
+	rdmsrl(MSR_IA32_U_CET, r);
+	r |= (MSR_IA32_CET_LEG_IW_EN | bitmap);
+	wrmsrl(MSR_IA32_U_CET, r);
+	modify_fpu_regs_end();
+
+	return 0;
+}
-- 
2.17.1

