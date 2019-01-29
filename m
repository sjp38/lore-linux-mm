Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A1E2C282CD
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:41:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CC7A2177E
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:41:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CC7A2177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B47D48E0014; Mon, 28 Jan 2019 19:41:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF8978E0008; Mon, 28 Jan 2019 19:41:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0ED68E0014; Mon, 28 Jan 2019 19:41:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D01A8E0008
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:41:17 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id v72so12685358pgb.10
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:41:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=f0ndo1Xal1a6v/4PjrGdAuv0FcoU8GzPJ1j2wQZwxYY=;
        b=ULQvnqsZ/VE+Lv5cA2/hWFeykoyJAsR+gQydP1Gy19IqVUed9lC0VrRlIMJ4zLQGJ3
         7/g7F4QEocfPeaMH5uFqry3jCwGJ4Ynzg3GzQW6JU+o7CdzWyN306GEhg0go1rOSSu1r
         uIpXLK0UkXkWzZI758W+zPyC/FhJ+kXxhALbfFUc9E+s+jjRmzmt2xAJhsUR1pSQyJuw
         qqN9S9FPeW3OwxDGFCf5xZFgGFdIEc+DQReCWdCNOME6nBaYa8eAwEBt4E3U6wZLClwe
         KMC1WucMQ1wSICRNAnb+31pPaemwvZHLrkUBWEVfSnnlhVEzUjNROORTGDxAsw73TRlf
         wYWA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukfgKQcPpmQtqBX8bdPoFT6VIa5e5F/XpscfNRqFDDaDyqZvMa+d
	QMWGKGtyt+FD4G6DQqsFYhecnd0hjauF9qbG71cJU+Dx7psKBxF5Q7kyXjFAYp5smL5bPykkLRo
	zO2flukhJBs1BVI2deBwRmc/s9gXI0uEgLFPBySv6j4KBt1vGWZPyjFkwhJ+z7g6ipg==
X-Received: by 2002:a62:8dd9:: with SMTP id p86mr23709382pfk.143.1548722477018;
        Mon, 28 Jan 2019 16:41:17 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6m/eC68OJKOYsg+BCOQHBSL4u/pp7zw+nFgBbt0xobQ+qneQIoiIFOkCDj8ozCSDeH+Rf+
X-Received: by 2002:a62:8dd9:: with SMTP id p86mr23703056pfk.143.1548722354158;
        Mon, 28 Jan 2019 16:39:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548722354; cv=none;
        d=google.com; s=arc-20160816;
        b=BHfe1bm2/4/MDhZt6y0bKiP58pZhZM+lfaOzT4ntLfP4Rs036rut2o/FlCo+PEu1XZ
         pgSknASDvPWbrpBLRDQG501StTK0Ovw8sBC4B1EhqwHqpcROCkameTl7fAFfBWRyQFJt
         gt/mpNTFqcib14v/+5Rv6bAXzj4DBF7nXrz9GnV0zXjDzmrR+RSG7JcEGGslyGFG/HBw
         sQPW4VYgUEqNmmHZpoE0/fLkZTBr0GJozxSon3oQMgQqH/GSFISFrkGKeRkfy8r9qU/S
         9TCpV1yMW/G2TGi/lg2NZbKtVPZFzTQEoDjRslHKsEgbW8mjapdC4aTYlAmOiCR2CJ84
         XWjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=f0ndo1Xal1a6v/4PjrGdAuv0FcoU8GzPJ1j2wQZwxYY=;
        b=UspSNeE+oGmgHBl61SDi7HtUFSwfJcMvlSn5nR5/dLUERs6SAegno3FcTxq7KS/l3j
         iYkCKFWcTQ/oG7M/gwVjjV1uTTn9O7owxHTtaNt+rx/CO1cVhTbS3rQ0y8Gx4eIkNYxG
         qaY13IvQbMZzkSxYtFKNfew7kG/lJc2kpWECd90TkTy06NEQmLGIZuM5yE4QpS/MW4bB
         vabIv9oUZst5ak/tf5SUGsKHWWAo25dXib4ofS7p1Z+Nk2OtLpFTq68cD6u4EgUzcz7D
         rxsZIpal2v+896Eoyi4TU6djegG7ANPdCz3dNqhMLNEwuCTkfuva7gGPkbOIOrStvu6/
         95Fw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id i9si7660357plb.35.2019.01.28.16.39.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 16:39:14 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jan 2019 16:39:12 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,535,1539673200"; 
   d="scan'208";a="133921942"
Received: from rpedgeco-desk5.jf.intel.com ([10.54.75.79])
  by orsmga001.jf.intel.com with ESMTP; 28 Jan 2019 16:39:12 -0800
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
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>
Subject: [PATCH v2 19/20] x86/kprobes: Use vmalloc special flag
Date: Mon, 28 Jan 2019 16:34:21 -0800
Message-Id: <20190129003422.9328-20-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Use new flag VM_HAS_SPECIAL_PERMS for handling freeing of special
permissioned memory in vmalloc and remove places where memory was set NX
and RW before freeing which is no longer needed.

Cc: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/kprobes/core.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/arch/x86/kernel/kprobes/core.c b/arch/x86/kernel/kprobes/core.c
index fac692e36833..f2fab35bcb82 100644
--- a/arch/x86/kernel/kprobes/core.c
+++ b/arch/x86/kernel/kprobes/core.c
@@ -434,6 +434,7 @@ void *alloc_insn_page(void)
 	if (page == NULL)
 		return NULL;
 
+	set_vm_special(page);
 	/*
 	 * First make the page read-only, and then only then make it executable
 	 * to prevent it from being W+X in between.
@@ -452,12 +453,6 @@ void *alloc_insn_page(void)
 /* Recover page to RW mode before releasing it */
 void free_insn_page(void *page)
 {
-	/*
-	 * First make the page non-executable, and then only then make it
-	 * writable to prevent it from being W+X in between.
-	 */
-	set_memory_nx((unsigned long)page, 1);
-	set_memory_rw((unsigned long)page, 1);
 	module_memfree(page);
 }
 
-- 
2.17.1

