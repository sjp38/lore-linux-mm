Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 921D9C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 606F12084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 606F12084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70A5E6B026E; Fri, 26 Apr 2019 03:31:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2139E6B026F; Fri, 26 Apr 2019 03:31:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D5D766B0270; Fri, 26 Apr 2019 03:31:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 593596B0007
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:31:49 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id s19so1452523plp.6
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:31:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=a0R0Xf8x/FEfdOPmfJkRWPwDaNy7YthB2Sa0kPsS6+I=;
        b=LH9SIQfE1XyNGHJd6az+wlgJMgxULNTRAywS/mqRJPdw9ff4tRzTmh4jZdASm0ubE9
         0njHGKlfwRvJz1gt5y/Uzihrqeq7+y3cp8UEZHQS1rgMm6rUsYZEmtF0diTi0hQjDIMB
         rn/bbeQfLf6RCIMh7VurSrQf0OTWyv2CNPoM9FxyfPVfIR9m3KXPFVEkBoJa8Q4U5Kus
         omDys61dKzl952EpgTC96CLKSeUqUXFKaa6DBc60KoP8esaX86+K38RBzYh8KohkMP/L
         +V9lymc/SbkARqDBV7fakfAJZXX9wLI6QfEit9ZrlmZwgAxqJxJyZjEreLFlY0RRo0GQ
         xzKg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAXzxdfSuPF1ps820PAGn976zTXdYZUVlXYvli+slz0+bZsKwlEM
	IZ9Sm1evus4WsBk+Oc3hcQxV5eByam34VVgpLa+5BLR61ENmyouH1t4UpFtAh0Yc0sqSAnnADr4
	itZ2EHqyuIZvY+sHFzwkNUfJtxRAcjPLDxEItrTllcDl3vxnnY5NBFkrBGVMfGoVUrg==
X-Received: by 2002:aa7:83ce:: with SMTP id j14mr45833842pfn.57.1556263909004;
        Fri, 26 Apr 2019 00:31:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxi0C/sdqEsCN+lcuy5Aac/o2B4843kAO2oEFdxaNHFiibUr3d1Z90pVdSZnc8rHeqRp74N
X-Received: by 2002:aa7:83ce:: with SMTP id j14mr45833742pfn.57.1556263907760;
        Fri, 26 Apr 2019 00:31:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556263907; cv=none;
        d=google.com; s=arc-20160816;
        b=EPlxyqScbwYqGhPHJQ8dqy7qjm9q43tk9JZnGihCmaXjEC4hrMj87YRSiC+VzYM+os
         /5Za1XeAW6CU/gpIJhHe8lziRc7wrS9zEOHuRRGjuGOUKoQ8H+JmkCYDX+DbCEPwqdqC
         ju1nrwzMxNHlx3EIV5q73Knza3F+DBA4HhIQLR4njVzIHNZGHppspfq26MfJGfP3/BwA
         Fz1erXAhMw1d4kSdW02di2gaD5YapfN6flxLeT064PrvBOHEuwVfac6yprGC8x4vVAIl
         2VCvdoB4uE+9yfl0nfLpk0GShqfdKEIx7CI4oyi+5UEvCMJ/EDqBeKd7//E1KdM6JsrT
         nWKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=a0R0Xf8x/FEfdOPmfJkRWPwDaNy7YthB2Sa0kPsS6+I=;
        b=wtv3bcqcFPxPWBT0I/qnJu068Ea5kVVmnlx8fchkNa/B3T+VpUpTMHihrT7DL6Yxuw
         doEm9vSdrwzKv+SUDBhHgUE4Clh59e3C8kOX+i7cyr16G4Yq06+a0rRrwN+hJ2Y6hjT3
         dzqfkczF5soe99BCNBQBSLn++DnL/dRTfAFES8nyAhbgk+xe/45KNJlNHcuE4pNFUFsm
         804a+mlecr83+SVByH+rrdMH7Dh5VCzL4kiJFST0GEBWWnFr0cApafX7Qwfmbt6rIPxi
         e+J6rhhJk2jltitblRj5dRV0UCDRnSg1FKpIZn6j5g+uzXx3sODshGSlcqap4F5o3iwC
         r/lQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id f9si22844507pgq.347.2019.04.26.00.31.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Apr 2019 00:31:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Fri, 26 Apr 2019 00:31:44 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id C60F7412A6;
	Fri, 26 Apr 2019 00:31:45 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
To: Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>
CC: <linux-kernel@vger.kernel.org>, <x86@kernel.org>, <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen
	<dave.hansen@linux.intel.com>, <linux_dti@icloud.com>,
	<linux-integrity@vger.kernel.org>, <linux-security-module@vger.kernel.org>,
	<akpm@linux-foundation.org>, <kernel-hardening@lists.openwall.com>,
	<linux-mm@kvack.org>, <will.deacon@arm.com>, <ard.biesheuvel@linaro.org>,
	<kristen@linux.intel.com>, <deneen.t.dock@intel.com>, Rick Edgecombe
	<rick.p.edgecombe@intel.com>, Nadav Amit <namit@vmware.com>, Kees Cook
	<keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>, Masami
 Hiramatsu <mhiramat@kernel.org>
Subject: [PATCH v5 12/23] x86/jump-label: Remove support for custom poker
Date: Thu, 25 Apr 2019 17:11:32 -0700
Message-ID: <20190426001143.4983-13-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426001143.4983-1-namit@vmware.com>
References: <20190426001143.4983-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-002.vmware.com: namit@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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

