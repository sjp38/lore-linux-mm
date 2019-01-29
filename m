Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFBF7C3E8A4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97A7F2184D
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97A7F2184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 282628E0008; Mon, 28 Jan 2019 19:39:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F9318E0007; Mon, 28 Jan 2019 19:39:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 112428E0006; Mon, 28 Jan 2019 19:39:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0CAF8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:39:13 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id p15so15383073pfk.7
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:39:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=MIEM7tFANWCvfO0km255hENS9lmP/VKfFRdymqsmEG4=;
        b=LBHmsfyv/LCx6Jt9Ckok6Im5Lv1xPZ8Y+utaYlbt3nRXBrCIm6lOvYeAas2J+ci5Fo
         JOo+zdw0mAfwl1Pj6xSrM5tVsEsOeTOGL5V5kN0/5yVp0neIDgLUdzLsE8YsPwtTaHCe
         SyCjqKSXmeIXGA71dXnUkCszIg1e1CYxigXfOMqeeGzqTFoJezSzyV1QLrIychvZF2n0
         z64hXnuzAsi/judViyW2A30tTziQDCLQ5LPd5vyf4R8ZJ5DeOOGC4gXG91SeKv6k68zL
         lPkfyaUsSCvkhaUOdmINrMtdAJlVDf4xSrmqKk7p0KQyVvi1xAlTMcPEL+dU0UpSRccQ
         TNJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukflHXBBWw73UDPhr4TA/r1JmHI5wl32r3A10Tu7e+91BUWze3LJ
	OWe8RzO4SVaxJ1tS/M1I1YxddLMoE33n6peyM0PMYnQEVes9dxf7XEKBC2/75+WpmKyP6rXgRUI
	sCkGJuqZVs+DcJ3MHcNv+tz0Z+tQtmUAQBFURXliSYHpOBgHUJMkAnGHQtrauKY0JBQ==
X-Received: by 2002:a17:902:c05:: with SMTP id 5mr24106496pls.155.1548722353450;
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
X-Google-Smtp-Source: ALg8bN51RWJbF4K+0gtIldLEJvGY0Ez67nKfgyHYuP4+WVi6SnGB7nc76EDOzCyKdxFGumAggyl8
X-Received: by 2002:a17:902:c05:: with SMTP id 5mr24106466pls.155.1548722352785;
        Mon, 28 Jan 2019 16:39:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548722352; cv=none;
        d=google.com; s=arc-20160816;
        b=pyzKWu4aOoGqq4iivSy6Xiw42iWnMnY8eaxl6KSIGklR+YprG9uLgKpQp6ZS9dzS7n
         +5cD+3ZZgx29Q+d2TkyDCX3lYj77+YKt2G1tgAAAsSAPA0GowqrHUgwgJbtjPXlBLwVl
         SubsEF1ZGRNuUUxE7iVyrSNmIZzfZnXemECkYWeHheSX34SaEJ15b2mDmMZ1OGpUwODI
         8r51IPAhnbDBm/CKFzkFypFSFC1UGXqsKZVOhQrO4HecnEpU3jmtbrN7t4/aJ7qnpIpz
         LSeQXKMPrQnrG5CMdTtJgae+A+WCdyUwt6++Krjux2c+8bnutSPxCwYAdbFN3lUrrICR
         RVlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=MIEM7tFANWCvfO0km255hENS9lmP/VKfFRdymqsmEG4=;
        b=fEn2iEQ+WRFtV2jwvTfGx4PqL416jrHGfzTlsUMQweAvMgMiy3zo4ctprgwIDbBHSY
         gH8DzkxWsLs82yixPul6UhChBIrPFri8fBamf0v2KLtSB5TJnmssebjG5LF2/ciJDZOd
         4FaAKRvfwu6YrAzwViSXnJl+hWNwNcYR5oItxZhXDiIb6pN/rtW1TmlYqNKnvCHcnFWR
         /Oeu0g6u3YDLs9Dvk0mcgPFMiMXpFZ6FJGxvyYLPMMpWsiI8xRksPwFEMpTuTqmXI1/r
         7573d+fAiX2EHduNkY3faGbqZY7RrHPIiWrUQkEqAyMfiJr1is5zuC86qDokP0V5QJM+
         ddnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id l7si33052569pfg.245.2019.01.28.16.39.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 16:39:12 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jan 2019 16:39:11 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,535,1539673200"; 
   d="scan'208";a="133921888"
Received: from rpedgeco-desk5.jf.intel.com ([10.54.75.79])
  by orsmga001.jf.intel.com with ESMTP; 28 Jan 2019 16:39:11 -0800
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
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v2 02/20] x86/jump_label: Use text_poke_early() during early init
Date: Mon, 28 Jan 2019 16:34:04 -0800
Message-Id: <20190129003422.9328-3-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

There is no apparent reason not to use text_poke_early() while we are
during early-init and we do not patch code that might be on the stack
(i.e., we'll return to the middle of the patched code). This appears to
be the case of jump-labels, so do so.

This is required for the next patches that would set a temporary mm for
patching, which is initialized after some static-keys are
enabled/disabled.

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Masami Hiramatsu <mhiramat@kernel.org>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/jump_label.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kernel/jump_label.c b/arch/x86/kernel/jump_label.c
index f99bd26bd3f1..e36cfec0f35e 100644
--- a/arch/x86/kernel/jump_label.c
+++ b/arch/x86/kernel/jump_label.c
@@ -50,7 +50,12 @@ static void __ref __jump_label_transform(struct jump_entry *entry,
 	jmp.offset = jump_entry_target(entry) -
 		     (jump_entry_code(entry) + JUMP_LABEL_NOP_SIZE);
 
-	if (early_boot_irqs_disabled)
+	/*
+	 * As long as we're UP and not yet marked RO, we can use
+	 * text_poke_early; SYSTEM_BOOTING guarantees both, as we switch to
+	 * SYSTEM_SCHEDULING before going either.
+	 */
+	if (system_state == SYSTEM_BOOTING)
 		poker = text_poke_early;
 
 	if (type == JUMP_LABEL_JMP) {
-- 
2.17.1

