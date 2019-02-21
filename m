Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12201C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CED1920818
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CED1920818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F0508E00D8; Thu, 21 Feb 2019 18:51:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69FB18E00D4; Thu, 21 Feb 2019 18:51:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F08D8E00D8; Thu, 21 Feb 2019 18:51:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B5708E00D4
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:51:14 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id i5so365869pfi.1
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:51:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=5kZP+xlzcd2ctLk3fWzs8E8qpboYLOQ3hu5nUlPFhXg=;
        b=Rk7mzY5dhDixxuVJtJ3okppgsAEBClKUd/WCzUaumRgb9NjSb1Nq/BgMc+1zecyLps
         LqyCu8+abQhqOjCQ5z+NmPeTLDWdo4Uihxt0xUQxYvJ0H8pbWCCgl84Crr9WjoAMXXac
         jVYsK2LFA40AdySwx9uUE0rhlCc2a/GuKtn7iPQPSFOPdmvF81gSH1Cix0t4rQVwkO8j
         AsBL01rB79GdQogCw2YE8ilzTm+LmKZjYVWBwwoiqePryNQpHaPIzQruSbPToCmEvrBm
         tnUepfczgkh+ynqqP0OWaiDoBFIyc47vkEFC9JFNMkdAuOfZgeyR8eOiAtxXm3nRD1wx
         i9Uw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubmSLACWh4GBfaYDjaG1VDu5Mfitquqv2BtOf7xCc5vQ2Zb57qP
	23UUgSIZCeW1yyTbJ8CTHXt65LxLs+lAB60KmrEyABrWZjd5SgFrBWrcsYQNqDK6od2sKcXYgi7
	X2JyeZ/8ev6gKdD7SlvK1nDuBK+xpyRfloTuYYKseoEqY5uRMx6CfI/lFjxpQ/9vYYw==
X-Received: by 2002:a62:1706:: with SMTP id 6mr1160085pfx.28.1550793073726;
        Thu, 21 Feb 2019 15:51:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaDRrRRuMDaYgrQdoghqF6ZHULz6c7YiyQOLIBpti3E2m02F8V5+UWbvEIvLQhyjSwMPCzR
X-Received: by 2002:a62:1706:: with SMTP id 6mr1160046pfx.28.1550793073025;
        Thu, 21 Feb 2019 15:51:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793073; cv=none;
        d=google.com; s=arc-20160816;
        b=jUV+lHtqcPJERQnxMZOmd/5zqQEE9Gw9TWcGA/ZzB0Hl90bKrQqDzjZy+PFjvZSoAS
         08KlCdy5Fsh7mqqShYmhbq4u9e1pHWVcUnC2uRPDhcPIi65OtDzZ6923PdpiwpttIbv6
         SOhQQ5n4g3deYhWrk58TLkPGJB5tah+APXnWG4cmd4CPDmoyHTflOnVG6MTuQ8kSaFYP
         kN6udCwwRO/JW39G4V5IHVKBTQUFGzlm08XJoKPEPUtZotuu9TdniRLu6gjm+mXLEOGC
         dmSv8/ijKElcvbLJTUIH03V53cASuUjlXC2bYFNrItf1tyQzJqbVe4veu1IjmL8ukg3k
         E0GQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=5kZP+xlzcd2ctLk3fWzs8E8qpboYLOQ3hu5nUlPFhXg=;
        b=ikywDyiYXw/4KpVp2vgn7sYblVRfoS9guQ0jGPJy1xL6R2DrNxKoOMq7Yzq0fPoWro
         TZXjEOwsESyg3oNuCxZLen6ngPPC74Y86XamEYan0W8L5YU4/98RCPGi2afLSZSDbSsl
         jAIMjx+0A0al+s/vCcXNbWYAgqOdXe+tIWrsyEHS95ykWKUhwL/laS7YxiVFqkSwQh3P
         7sgUfeprQmWwiLy39Vlo6BnmsEsbqbk1DR3GU9tgK9S3PZjCnaqd+Fbj5Txi5E+v/t2o
         vOoqd085dFFLqNwq5ROVFAjy+kfdRDgHuDwMk5/7eRhJK+Y8921YIaY6xBTXN2eECiTJ
         kUvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c4si238494pfn.83.2019.02.21.15.51.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:51:13 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:51:12 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="322394969"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga005.fm.intel.com with ESMTP; 21 Feb 2019 15:51:11 -0800
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Borislav Petkov <bp@alien8.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Nadav Amit <namit@vmware.com>,
	Masami Hiramatsu <mhiramat@kernel.org>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v3 20/20] x86/alternative: Comment about module removal races
Date: Thu, 21 Feb 2019 15:44:51 -0800
Message-Id: <20190221234451.17632-21-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

Add a comment to clarify that users of text_poke() must ensure that
no races with module removal take place.

Cc: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/alternative.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alternative.c
index c63707e7ed3d..a1335b9486bf 100644
--- a/arch/x86/kernel/alternative.c
+++ b/arch/x86/kernel/alternative.c
@@ -809,6 +809,11 @@ static void *__text_poke(void *addr, const void *opcode, size_t len)
  * It means the size must be writable atomically and the address must be aligned
  * in a way that permits an atomic write. It also makes sure we fit on a single
  * page.
+ *
+ * Note that the caller must ensure that if the modified code is part of a
+ * module, the module would not be removed during poking. This can be achieved
+ * by registering a module notifier, and ordering module removal and patching
+ * trough a mutex.
  */
 void *text_poke(void *addr, const void *opcode, size_t len)
 {
-- 
2.17.1

