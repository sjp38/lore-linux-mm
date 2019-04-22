Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9937FC10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:58:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 683B8217D4
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:58:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 683B8217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 117256B0006; Mon, 22 Apr 2019 14:58:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 002CF6B026B; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5F1A6B0006; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3C36B0006
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e14so8196988pgg.12
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Y4ax2hOd4Buhijx/oNSuXPhWpslJbmlh2LJYha9eHFk=;
        b=cOHSf8SDOjOCCn0xUf5xre6sOmrV2u06McI6rxqRJQT4/Kv1jwX4TK+AX2tbEIYgNq
         AEA2bYA+7TurL2d42jzIdOobsrmsEFDS5p/DGT3TOBpMqZ7kRdrzGn36e3DcbS3qUUWC
         aDQ/M28n7S5/K//uKmUKC5zAvQ35d+HrdqfBalSa8Dh200bRcYJ8DcNS6T+FIrdH3sRP
         SrMgsVa1I3n2FY4EoKLfpH3Mf/bpkGxCwB5ydb+Ll3hxmko7ZORPlum3dmSDV7kNfPZQ
         eg8N/XoNp3xpdnMGd23omCRSh3SGb+ZU9Z01vuO9Pz0Y8XCjbVipZCDQGoABmmB6v07B
         /oLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX9HeyiyZp1hk+wkbo6QMHjgwdWW7rs/MD+PtxRTGD2WAgKFh+d
	pt/MYhE7ZPXMGmhdQQdAjlrAuh04M//peCIm17dzXsGyS1EY4TdJECa0uqmB9cDHf1sG+yA6OXf
	+iCGpEJYczR0wqSKFdxJ8AUxuhjtFzyDfEeD569NpYYAsds8dSOuAcMxsl/O5/a7mYw==
X-Received: by 2002:a63:fd49:: with SMTP id m9mr20238026pgj.16.1555959523481;
        Mon, 22 Apr 2019 11:58:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhbjsUZ6D5GgJQ14xg07i4WhP6ruHS3XoNeDnaVh/2kiHf4l36uWcfoQG27DtuKsnjr3Jn
X-Received: by 2002:a63:fd49:: with SMTP id m9mr20237976pgj.16.1555959522571;
        Mon, 22 Apr 2019 11:58:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959522; cv=none;
        d=google.com; s=arc-20160816;
        b=FxQxErtYL1nhWG3UATS5FB7BKyYyYpoSqTQ+cjfFaxeU1hIyJZsl3UkZopT4j7Q7zG
         nQlmAwAm6qBq0QywqOwhe+UAuBVzSJ7S+p7zMKjLAQFL2N2gr0Gc+F29/nsNQYBP2Den
         M3kR4IBbXM04C8Nipz0gh/59QLSbhlCmhrvDxyZG4WKV/kwObwtsP6rNJDJbjhTdj10N
         e6glP93c+8O7KWN7qjdzTRATJE7DuzFuzjEgiiLFe+VeWp3DBtEhSklo838hclM8DodR
         xRwl9ZLr0IsJ1dCfws2kCG5unDR5bILNxlhHwevFFRF+SSyGkoJzZD8uXYgvSM4rOegy
         s9lQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Y4ax2hOd4Buhijx/oNSuXPhWpslJbmlh2LJYha9eHFk=;
        b=N+QAZKYaQlM86OogavV30KiFsEd5hSfD3AJ8vd2zU0yHHD3gI1AxlYlp1XVzN8XY/Q
         svYz1N6WJMDB6WmD6jwxHV38RAYa5ZxAhbf9xERfMRw8OMNuC0OlAQ1b6NfKtKpmCa24
         Pnw0g51+AFLUQvnTBlUn8WNjxFDzoQHWu45q4qMOYJc3YVauYiMQ7xLCwk3+b9px4ILY
         NTbXytQ1oTeX5NGZiL4v75ZRMsfAFe3ll+FkLcpeOjmhqlgJ5rO8OAsmSXGwHx3o64j3
         Y3cBF5uakPgmYuZ2Xb8Fh5amOc7n4BtAwEzQLgtu9Vi4Hv8lc4WOmvCg+tI/mjbzCUsE
         Hy8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a2si12975117pgn.530.2019.04.22.11.58.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 11:58:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Apr 2019 11:58:41 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,382,1549958400"; 
   d="scan'208";a="136417122"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by orsmga008.jf.intel.com with ESMTP; 22 Apr 2019 11:58:41 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
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
Subject: [PATCH v4 02/23] x86/jump_label: Use text_poke_early() during early init
Date: Mon, 22 Apr 2019 11:57:44 -0700
Message-Id: <20190422185805.1169-3-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

There is no apparent reason not to use text_poke_early() during
early-init, since no patching of code that might be on the stack is done
and only a single core is running.

This is required for the next patches that would set a temporary mm for
text poking, and this mm is only initialized after some static-keys are
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
index f99bd26bd3f1..e7d8c636b228 100644
--- a/arch/x86/kernel/jump_label.c
+++ b/arch/x86/kernel/jump_label.c
@@ -50,7 +50,12 @@ static void __ref __jump_label_transform(struct jump_entry *entry,
 	jmp.offset = jump_entry_target(entry) -
 		     (jump_entry_code(entry) + JUMP_LABEL_NOP_SIZE);
 
-	if (early_boot_irqs_disabled)
+	/*
+	 * As long as only a single processor is running and the code is still
+	 * not marked as RO, text_poke_early() can be used; Checking that
+	 * system_state is SYSTEM_BOOTING guarantees it.
+	 */
+	if (system_state == SYSTEM_BOOTING)
 		poker = text_poke_early;
 
 	if (type == JUMP_LABEL_JMP) {
-- 
2.17.1

