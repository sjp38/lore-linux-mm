Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DD3EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:50:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 350CD20836
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:50:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 350CD20836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE13E8E00C3; Thu, 21 Feb 2019 18:50:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9FC08E00C4; Thu, 21 Feb 2019 18:50:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B811A8E00C3; Thu, 21 Feb 2019 18:50:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 74C078E00B5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:50:55 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id z1so347023pfz.8
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:50:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Y4ax2hOd4Buhijx/oNSuXPhWpslJbmlh2LJYha9eHFk=;
        b=NRpWBYWj+7fzbNd/Li1Ky8OQzPc/PoZeF/Gq+FVGb3Yk3ICDSqYjvsmtX8UdR6SUVY
         hQx8vewlhFZdQ+xXAPQwQeNVxnpkpJt3pC/HqU7msNqWJhN0J8oqELIvYGU/p8MvB2/e
         nhnVYVxNo3W5iNqtOT5qskcdCz/MoSDXcWGrs3+3Os00fDnz2Xx5O4Oyl+wK91Amk2Mk
         CtVFH9EPgpou2q59IcFPawFzEOK4/GirMWwwPRJwiHAoGYGhjp/kKMfaXrR4Rj6QGGZ2
         ANBXQDPXlenbNmjsUTWuObYjF7Le1bwWpkjfM+yunTsnBDJ5wu3eX7umlvWgSonLXHEC
         jgdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZaKGXl8ITvGd9XryiHSGm9GAlLKtXSJ8NmgR/l6TW0ICquvp6V
	RSoCLa8rcVoq/smGMF3jVevtOGotO7/Zo32LI9jsnjIdAkihEih6vsFQ0xYAYEi7m5yhrnkMfON
	D5TQwl4S5UdlwuiuoeoXRohm06PhyyC4qs7CaCRKOfUsDzoyBzzykFV1xtGAKvy+6sA==
X-Received: by 2002:a63:ce41:: with SMTP id r1mr1061771pgi.119.1550793055147;
        Thu, 21 Feb 2019 15:50:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYuYDyh+NP9Bf8ZO3K/Ukso1rbVRZDJ2lznF8zglhIWm+WymnwNLDb7TDsTXcvyuWWmUtas
X-Received: by 2002:a63:ce41:: with SMTP id r1mr1061738pgi.119.1550793054416;
        Thu, 21 Feb 2019 15:50:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793054; cv=none;
        d=google.com; s=arc-20160816;
        b=XuwSxpfh10LDlQ0j5z/cvyLmi0StsjlU9jhRem+NhBxGL/nA33aK5/lqZS7Q9RSvn6
         Du57HSlYB/+YN8xqZ8LIUHPidM95kXKZ8kON7SjzSfznDquWuL0Rr1GY4AimAUQ+jvn/
         uqUfir4EdZ1iam2Psxzj7GCdgpTv621vpzYmPXGMMaeLAjh3QUNaOeDCws/TgVQ0pG/3
         72BVGfKtGvTG2ita2okqoy6HG+F8qpxeySbw77GUlpGEjQBA/Y5P7WhjGMk74wqzbC7q
         CFUIrgkHtL6UtOXoxb3rvuFHQkO38Pl44+c3ffMZe52idW2tvTuWivm9uKxn7Y6MmKAE
         HhCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Y4ax2hOd4Buhijx/oNSuXPhWpslJbmlh2LJYha9eHFk=;
        b=AuAdcbRhaLkAzgkcahIbwkixq+ltV9F2Ps9Wgzu1ROx5EErjjt1pxlzjljEg3xBK8U
         6lBMLVUSVQXxavDu4kbexO8sGisobVW8kdjZGvj6j22yMGM6VqVMKQnO3kg+4zIMd89n
         2fjWupuyf2frJLPx0VQw365V4uhb2yyac54RPr/73xalsUvsskZY6bsQ6rkDJxfxrlV7
         WxP+vXla04FQtsy3maGWeduUYKN+6dYlWxtoiuAr82kKzCuN800sD8jB8zUQyxEBtRx2
         sxnojrWUU3i7p9Ut4BscxIohYdWedu1fEjatt9NibhVTW25q0SR43fdC8reuYqSBA+fQ
         XkhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c4si238494pfn.83.2019.02.21.15.50.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:50:54 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:50:54 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="322394801"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga005.fm.intel.com with ESMTP; 21 Feb 2019 15:50:52 -0800
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
Subject: [PATCH v3 01/20] x86/jump_label: Use text_poke_early() during early init
Date: Thu, 21 Feb 2019 15:44:32 -0800
Message-Id: <20190221234451.17632-2-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
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

