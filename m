Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACE11C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:59:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66D36218B0
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:59:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66D36218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2B976B0010; Mon, 22 Apr 2019 14:58:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 756796B000E; Mon, 22 Apr 2019 14:58:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B86C6B0008; Mon, 22 Apr 2019 14:58:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D737D6B000E
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s19so8829718plp.6
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=g3nO4xFM3yb0X+OIqTEtEp6LbffMj61RqStKCNeSSiM=;
        b=HcoQJ0mc7iK73K1XktxPfMTMGnlNQhja5Dc0xRvYH/L4CjWHXU1yTylFS7jkcJylmi
         L7cWW48NND8MuW8JMA1zvbfnCzMBQ/quYf4KE14ZWh6AaHPBC/g0P4Z9D6++fSm3HLwt
         b/f4tFzTGPYqqyzI8MuVhJrhxAsHc08XGGfTIgWpnWditG8QMHlh4XqjBhjrSXlusfGC
         vstpAgShNZPODEmQs7FsRShN6BzLP85f+msZ2VfobS1MMNjPSRrbA2titrPMFsvvjWNz
         l7EoEqigqOCG2cwN5CUljU7/gv+g4TD5mKSK03nrN4KWAXF1k3sAXM7qK6GbL4QgoX8d
         4ZjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXoTgzEfiI1ZWOGFdW4xhQUKC589xd5qmgYicxqHmmJdeTE4/f6
	ocLHHIRo8KjNOogXrmziRGVlQ+vBQsHD/TBCnwprLhoSIJMNsrLlUkkhlT5uDYrL/HhqHW5LSsQ
	dhdzZjFWb9sy/ddMq0jMVRiC9M0BWfUs1TDjd1RdyBKrr/koPStWPFYqDiry1Q1wrNw==
X-Received: by 2002:a17:902:70c8:: with SMTP id l8mr22150509plt.177.1555959524529;
        Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweBJHlpFdyv6pmg3+0kLdzjylHl9yi+W4MfJcHSKm2iPxhPz6OKqoJfwB0HEDBtPNElzlh
X-Received: by 2002:a17:902:70c8:: with SMTP id l8mr22150454plt.177.1555959523666;
        Mon, 22 Apr 2019 11:58:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959523; cv=none;
        d=google.com; s=arc-20160816;
        b=luKyJ+uYhdSl+YmonvGd/wADQiCVckVJS2N3Jz75Xy1We7EiMWxkObZLpQTOa+JTvq
         fU96pKXj0nELGLYE7Uh+nFs21wWIIxO/QIpfAqkNb+tlybzXufRXA6hWcGU4ETgho7D5
         qT33bDMo520IzPH6Ym6vBsOm0LwwckMYkZAVkbI1feOlVIjNqwzDpC1QkEQbQeNrutE2
         AyJoZIFLM71m9RsoETwNbfVjoKNhJEUqpnDBPqqZus88SFb1cmxJCEqu5/CsIzC8gdOZ
         mjcDWxqykvzn3YeWf0jWZ3XA3jH86A0VDvGpH+Z9amL6xx2L5zAApOQdxrnD7QSBiZ48
         Ts1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=g3nO4xFM3yb0X+OIqTEtEp6LbffMj61RqStKCNeSSiM=;
        b=mlEkCcGoaHMwWGSYW0Z9EsrgwHEAr9ylzdz8wY4qWcWWR0cCRznayxnf74FkylQCZq
         Hd/tLzAbTE6HYVH05vkIQTTtK8f26famPpOnewlHEU/iJc9/zypWtU5SdNR6Hu1gkTu6
         R2VgQWFrrPulSck9onsVwTEt5tvnjJKqakmMAdSDG551TvPmSVohP45WZAZOjXuUGhWZ
         YIj/KDSl80SaLGOSQeOzvFNM/FhGhXbQY6ccW/tiyW/TXXTKsjISwDLDIBhSgjPo3bfh
         AI3PiJyr32Jr5H0IH9AOFlsAnwFZVXB6nBfuz2tAR/j+is6ao+BCfpeFK2YcLH0XqIqt
         njuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a2si12975117pgn.530.2019.04.22.11.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 11:58:43 -0700 (PDT)
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
   d="scan'208";a="136417152"
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
Subject: [PATCH v4 12/23] x86/jump-label: Remove support for custom poker
Date: Mon, 22 Apr 2019 11:57:54 -0700
Message-Id: <20190422185805.1169-13-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

There are only two types of poking: early and breakpoint based. The use
of a function pointer to perform poking complicates the code and is
probably inefficient due to the use of indirect branches.

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Masami Hiramatsu <mhiramat@kernel.org>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/jump_label.c | 26 ++++++++++----------------
 1 file changed, 10 insertions(+), 16 deletions(-)

diff --git a/arch/x86/kernel/jump_label.c b/arch/x86/kernel/jump_label.c
index e7d8c636b228..e631c358f7f4 100644
--- a/arch/x86/kernel/jump_label.c
+++ b/arch/x86/kernel/jump_label.c
@@ -37,7 +37,6 @@ static void bug_at(unsigned char *ip, int line)
 
 static void __ref __jump_label_transform(struct jump_entry *entry,
 					 enum jump_label_type type,
-					 void *(*poker)(void *, const void *, size_t),
 					 int init)
 {
 	union jump_code_union jmp;
@@ -50,14 +49,6 @@ static void __ref __jump_label_transform(struct jump_entry *entry,
 	jmp.offset = jump_entry_target(entry) -
 		     (jump_entry_code(entry) + JUMP_LABEL_NOP_SIZE);
 
-	/*
-	 * As long as only a single processor is running and the code is still
-	 * not marked as RO, text_poke_early() can be used; Checking that
-	 * system_state is SYSTEM_BOOTING guarantees it.
-	 */
-	if (system_state == SYSTEM_BOOTING)
-		poker = text_poke_early;
-
 	if (type == JUMP_LABEL_JMP) {
 		if (init) {
 			expect = default_nop; line = __LINE__;
@@ -80,16 +71,19 @@ static void __ref __jump_label_transform(struct jump_entry *entry,
 		bug_at((void *)jump_entry_code(entry), line);
 
 	/*
-	 * Make text_poke_bp() a default fallback poker.
+	 * As long as only a single processor is running and the code is still
+	 * not marked as RO, text_poke_early() can be used; Checking that
+	 * system_state is SYSTEM_BOOTING guarantees it. It will be set to
+	 * SYSTEM_SCHEDULING before other cores are awaken and before the
+	 * code is write-protected.
 	 *
 	 * At the time the change is being done, just ignore whether we
 	 * are doing nop -> jump or jump -> nop transition, and assume
 	 * always nop being the 'currently valid' instruction
-	 *
 	 */
-	if (poker) {
-		(*poker)((void *)jump_entry_code(entry), code,
-			 JUMP_LABEL_NOP_SIZE);
+	if (init || system_state == SYSTEM_BOOTING) {
+		text_poke_early((void *)jump_entry_code(entry), code,
+				JUMP_LABEL_NOP_SIZE);
 		return;
 	}
 
@@ -101,7 +95,7 @@ void arch_jump_label_transform(struct jump_entry *entry,
 			       enum jump_label_type type)
 {
 	mutex_lock(&text_mutex);
-	__jump_label_transform(entry, type, NULL, 0);
+	__jump_label_transform(entry, type, 0);
 	mutex_unlock(&text_mutex);
 }
 
@@ -131,5 +125,5 @@ __init_or_module void arch_jump_label_transform_static(struct jump_entry *entry,
 			jlstate = JL_STATE_NO_UPDATE;
 	}
 	if (jlstate == JL_STATE_UPDATE)
-		__jump_label_transform(entry, type, text_poke_early, 1);
+		__jump_label_transform(entry, type, 1);
 }
-- 
2.17.1

