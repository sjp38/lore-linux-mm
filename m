Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5315C46470
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:18:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96E132083E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:18:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96E132083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E81B6B02D3; Thu,  6 Jun 2019 16:17:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7B0B6B02DB; Thu,  6 Jun 2019 16:17:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BCB06B02CE; Thu,  6 Jun 2019 16:17:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7094D6B02D4
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:17:34 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 14so2295838pgo.14
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:17:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id:in-reply-to:references;
        bh=7GnSNHKy6rHzD6GKuLujsef/M80H1Rf5lfqmK/S0wEQ=;
        b=Swc2J7jVzA80AUt4kLi5PNeTxbE2NgB4LAxCpx1tgbYGZhjyEit6BlszB9d3FFsJHA
         UaEodFYkJqiT8phT6venULve4HX64CK1gowAGpntFmA3oaBeN0z9I1XcQ9CX0yHkJxuJ
         ULoZCb/7tN0xJLOEVGgNuSmT0zactfld56Fdrhm4sHau5K91D2bCw6L9F1cl6LT4SfKY
         gUKbC0bz5Jx5PW+d6mFoq+5ZHw+VPbYlzzbK+bFasEJ1gCWT+pEEG+h+LZ1vPEfL9FyU
         UWCe23y8alVGp57FRpQiLFXUrHMMBn7w+bBTXTpBIUHlFSsfAungy0+PmsPs8Ixe0fil
         HvyQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVYQy6DDga9INZm5/rgAvSQXpWii+dotZdN8cG8+YXZ8qyPO7F9
	RiSoyTAwaIYszugmwAWBZ6DUpvvuYj8GNQi+HASg1XTZ3/3O5TTLPFWJxqvxXF8ewaLAugWiAdS
	fmsJSF3Nu5iYivQD3PmMERgkdLv2EQnGeikGmR52OdrGlsEyl8DK8TlBSyd+4U4mDeQ==
X-Received: by 2002:a17:902:ba82:: with SMTP id k2mr43333762pls.323.1559852254129;
        Thu, 06 Jun 2019 13:17:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQS3qd97pO8QZkZeqhEUX/JFUK6bqZI3SIrPHmOpj0yaXVzifFPTDfUODufkKgMG5sqWh5
X-Received: by 2002:a17:902:ba82:: with SMTP id k2mr43333694pls.323.1559852253042;
        Thu, 06 Jun 2019 13:17:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852253; cv=none;
        d=google.com; s=arc-20160816;
        b=sj+0WQAK/zjc8MFFC2HEDKdGw5aVJXeI6nTHP9L/zRkgEGDurCR0NyRtBVbulQxk1i
         C4xfyqq5UMnefI9mfLF6g68OdLObWdljNUeUAQtKUACpkDIv5fvXF1EIm0XZ7x6CyaM3
         qvsWEC9u8UfRxPxsspV4Hj8Kh3ujHJl7gXNKwPcC76/+dBF/rxoxQLNpOdxi20xqhhCu
         gfPgyEb6nztAQjXA5JCwWiE0Zv6KFek+W9cPyDMpn7QvE8q6b3DRERWYmvhqpsiqU0Kb
         N4lupWxaDoy047fqlU/q9We1qgF7clYN31z5r3MPIlVUNrdxK81o4yDuiYYrB230UL8E
         CfHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:to:from;
        bh=7GnSNHKy6rHzD6GKuLujsef/M80H1Rf5lfqmK/S0wEQ=;
        b=CaeeGqoDgn7QI31RpKptB6cFiWmnm46+Hpj16KAAZy/pWwhP/GbSAVK4XkCnLSSbct
         2OlUo1pLJxILPSXyxE9aAeD/XOjONwqEm8HhT34Lr/ZcducpiTBO3nYUcKtzKK4v5x+l
         hsc/hBB3SxkuLKeVweQ4SU2b9C8pS7Ca7kdflcFsmUR+aMkM7KCHYVwFjn94yzJhAhnQ
         /xFIWqHUP4MXRl3HeVFZlxGi0KdhR6+WRTCNBsVAOsK+rf4mbx8aEdf7D6r/Zv/0L30j
         9Nvvgsspf2n1PJyvWfQQ6ncBd9SE5W4Eg4jUzKHlLiNMXoFw4SCSDmUfjgIo6t77h/In
         Y46w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id a3si59797plc.132.2019.06.06.13.17.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:17:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:17:32 -0700
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
Subject: [PATCH v7 11/14] x86/vsyscall/64: Add ENDBR64 to vsyscall entry points
Date: Thu,  6 Jun 2019 13:09:23 -0700
Message-Id: <20190606200926.4029-12-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200926.4029-1-yu-cheng.yu@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "H.J. Lu" <hjl.tools@gmail.com>

Add ENDBR64 to vsyscall entry points.

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
Acked-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/entry/vsyscall/vsyscall_emu_64.S | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/arch/x86/entry/vsyscall/vsyscall_emu_64.S b/arch/x86/entry/vsyscall/vsyscall_emu_64.S
index 2e203f3a25a7..040696333457 100644
--- a/arch/x86/entry/vsyscall/vsyscall_emu_64.S
+++ b/arch/x86/entry/vsyscall/vsyscall_emu_64.S
@@ -17,16 +17,25 @@ __PAGE_ALIGNED_DATA
 	.type __vsyscall_page, @object
 __vsyscall_page:
 
+#ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+	endbr64
+#endif
 	mov $__NR_gettimeofday, %rax
 	syscall
 	ret
 
 	.balign 1024, 0xcc
+#ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+	endbr64
+#endif
 	mov $__NR_time, %rax
 	syscall
 	ret
 
 	.balign 1024, 0xcc
+#ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+	endbr64
+#endif
 	mov $__NR_getcpu, %rax
 	syscall
 	ret
-- 
2.17.1

