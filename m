Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B97ABC28EB3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:17:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7EC472083E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:17:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7EC472083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA4056B02D0; Thu,  6 Jun 2019 16:17:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69F5B6B02D4; Thu,  6 Jun 2019 16:17:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E19A06B02D5; Thu,  6 Jun 2019 16:17:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C34D6B02CE
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:17:34 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d2so2148394pla.18
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:17:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=1pN9qEhFf50g9hJLFmQdzbSjuiGnrmTKcgtVo7is/wk=;
        b=oHCIz3XHDiE455+z3xYGCamWETS036tJfCEH+t2OgNT8THNzyPI+qelJpmySINuxrR
         d6bVnE4k6YKWVF9CcmBfXCzESKJq9/g2ockd7c3684FCJadbKyujBY/7qBc4CbSI7bXj
         vWwLmbdMrSWZyFPP8uxqdqIhloBRphCT/3Nu0JyWlfRpKXDyiPpRSBRhn55MF8Zmt1BM
         /vOKlffKNcJCKRrOCwJeh7WHIIapSbwzzY2b57RJ+3ErC9sgt4bDXL7THbJk3yrc3MSu
         h8FbsUH+X7UVSn6DqTyepBPgaEt/MGZb+WfXfKXdlDhgwyz1aKMLsu2MRek5VQT1K1w5
         Es5Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWkYGdpOC2URfIqYZdGQuxDt05wL6FTfoY9z0kws0XOCyl3U5XM
	LuEliODXnGc4uYOXl08WiZie8MyqNi6KS6zLL8NBifvzVkK1EzjGdxlCXOP9m2Yyvz1/lO35dOD
	Us915IYUfkA97TrjVECdZgpxZfV6dU+IriFzYdq9vMve+fI79ayFHIxa17j7uVOCKUg==
X-Received: by 2002:a17:90a:2e89:: with SMTP id r9mr1625819pjd.117.1559852254052;
        Thu, 06 Jun 2019 13:17:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYKxSM2IuCF99xWZICAbejvJqkybNa1pNjITR1szS16yNCcS4UioT1Xa7N8dw4VuKs3Ngg
X-Received: by 2002:a17:90a:2e89:: with SMTP id r9mr1625696pjd.117.1559852252308;
        Thu, 06 Jun 2019 13:17:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852252; cv=none;
        d=google.com; s=arc-20160816;
        b=MqTgHT4WOrJ9KMZubXCxl0cSjRcX3JgcmTlGxY4GglGxJkBzXHZBtTbynP7Z/h4sgV
         xZhn+vi51/Vu+NjOx+oaQVGXlEq7MfLuIDlKvlYKb05wrJIhqz3fVtbXObJ0w4O9oi4f
         7z6QOp1PL0H8dSxASoWYuUEkmfeNtA9qrjolUd9BiISxVLhpZrXf9BvH3Z1H1wSQFr1n
         UMgM/6GPrsHpgnWZIDUyM1Q9onTTKvshsYoB/ks/OevOwLSV1nVTlb6jOn2Bd9jaziD5
         lj/+0TzbyfTEFDgUdBQC5Y3Q/C07TO/3vwh44QvgrsbdgnB5z8NHdEfo4/dZN68039tX
         MYmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=1pN9qEhFf50g9hJLFmQdzbSjuiGnrmTKcgtVo7is/wk=;
        b=GtPjReetS/fB+UCtKC7+suTTJ0PpiL907oHT4m5Xlt3vmMb/OW/FCkQfVXFP86lFjC
         49xgNZYzy2BUx79CQD3gVvbBz7V3dnOf23/2fGl2umwc7uAHF/z9R7mXA0Y+EPvz2RIU
         s65YcsGCBdN45gaEZxrvUn359/Kf7kabRlDVf/u85ykXo3LCiOmLPiFOLVLXkFpvFcq/
         6AR1b4sgJgW3DQGQUaj+bkppctgZhb40HV3y2DNB6hGOKwXWeRovb+o2MIWOR1SvBJMn
         RlsUS0lvYpYsNUc6IZ08m9PKSKDZmT8cW4E9reqgW7zAYbv/hAVUqcvcL7514Diphzo0
         ihlw==
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
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:17:31 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by fmsmga001.fm.intel.com with ESMTP; 06 Jun 2019 13:17:31 -0700
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
Subject: [PATCH v7 07/14] x86/cet/ibt: Add arch_prctl functions for IBT
Date: Thu,  6 Jun 2019 13:09:19 -0700
Message-Id: <20190606200926.4029-8-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200926.4029-1-yu-cheng.yu@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Update ARCH_X86_CET_STATUS and ARCH_X86_CET_DISABLE to include
Indirect Branch Tracking features.

Introduce:

arch_prctl(ARCH_X86_CET_SET_LEGACY_BITMAP, unsigned long *addr)
    Enable the Indirect Branch Tracking legacy code bitmap.

    The parameter 'addr' is a pointer to a user buffer that has:

    *addr = IBT bitmap base address
    *(addr + 1) = IBT bitmap size

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/uapi/asm/prctl.h |  2 ++
 arch/x86/kernel/cet_prctl.c       | 21 +++++++++++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/arch/x86/include/uapi/asm/prctl.h b/arch/x86/include/uapi/asm/prctl.h
index d962f0ec9ccf..5eb9aeb5c662 100644
--- a/arch/x86/include/uapi/asm/prctl.h
+++ b/arch/x86/include/uapi/asm/prctl.h
@@ -18,5 +18,7 @@
 #define ARCH_X86_CET_DISABLE		0x3002
 #define ARCH_X86_CET_LOCK		0x3003
 #define ARCH_X86_CET_ALLOC_SHSTK	0x3004
+#define ARCH_X86_CET_GET_LEGACY_BITMAP	0x3005 /* deprecated */
+#define ARCH_X86_CET_SET_LEGACY_BITMAP	0x3006
 
 #endif /* _ASM_X86_PRCTL_H */
diff --git a/arch/x86/kernel/cet_prctl.c b/arch/x86/kernel/cet_prctl.c
index 9c9d4262b07e..b7f37bbc0dd3 100644
--- a/arch/x86/kernel/cet_prctl.c
+++ b/arch/x86/kernel/cet_prctl.c
@@ -20,6 +20,8 @@ static int handle_get_status(unsigned long arg2)
 
 	if (current->thread.cet.shstk_enabled)
 		features |= GNU_PROPERTY_X86_FEATURE_1_SHSTK;
+	if (current->thread.cet.ibt_enabled)
+		features |= GNU_PROPERTY_X86_FEATURE_1_IBT;
 
 	shstk_base = current->thread.cet.shstk_base;
 	shstk_size = current->thread.cet.shstk_size;
@@ -55,6 +57,17 @@ static int handle_alloc_shstk(unsigned long arg2)
 	return 0;
 }
 
+static int handle_bitmap(unsigned long arg2)
+{
+	unsigned long addr, size;
+
+	if (get_user(addr, (unsigned long __user *)arg2) ||
+	    get_user(size, (unsigned long __user *)arg2 + 1))
+		return -EFAULT;
+
+	return cet_setup_ibt_bitmap(addr, size);
+}
+
 int prctl_cet(int option, unsigned long arg2)
 {
 	if (!cpu_x86_cet_enabled())
@@ -69,6 +82,8 @@ int prctl_cet(int option, unsigned long arg2)
 			return -EPERM;
 		if (arg2 & GNU_PROPERTY_X86_FEATURE_1_SHSTK)
 			cet_disable_free_shstk(current);
+		if (arg2 & GNU_PROPERTY_X86_FEATURE_1_IBT)
+			cet_disable_ibt();
 
 		return 0;
 
@@ -79,6 +94,12 @@ int prctl_cet(int option, unsigned long arg2)
 	case ARCH_X86_CET_ALLOC_SHSTK:
 		return handle_alloc_shstk(arg2);
 
+	/*
+	 * Allocate legacy bitmap and return address & size to user.
+	 */
+	case ARCH_X86_CET_SET_LEGACY_BITMAP:
+		return handle_bitmap(arg2);
+
 	default:
 		return -EINVAL;
 	}
-- 
2.17.1

