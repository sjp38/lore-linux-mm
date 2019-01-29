Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE713C3E8A4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:41:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7FE32177E
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:41:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7FE32177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02BEF8E0001; Mon, 28 Jan 2019 19:41:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECAA58E0008; Mon, 28 Jan 2019 19:41:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCBD28E0012; Mon, 28 Jan 2019 19:41:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 88E308E0008
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:41:01 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id v11so13049944ply.4
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:41:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=H4uqmF5HLlBo9r9rzOTTevq+cJIiPJBHTeYeqiaw1PU=;
        b=PDutqypkMKekHFhUwPse1zt4sP9bINqKsmFkrZaYpwv0GlAUJ8JGKV5hw4pRhB0zZU
         e+kcVr+J0+6yF1y1sqqO6qZ8iUzeyxoDK775e4TustumcZVKgPidU0ovcXwwLnnZuVvO
         q0pKEtZvkHuLrnTmOVUOG4Zdml8nqal33QOVgGAuJGT2qylz7gBMFRTdyTZLf6jboAk5
         XSOv8N5raUWyQOaDMBEOg1Ks5GVIRCKWohn/lzK8bXbCmattRQNaX3UrmpqFknWk6chk
         aL6V5/DZOTUOIsHN6yNk66DTG9+bguaCIftCnIGNqRuAe1nFsSCrYU2Jq8cYz5NrMN/u
         97OQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukfM0zY+ntu/94PuTVCbZVjm1W0WS1XgGSovnm88uph9ktEaQ5LB
	P5t0gvT5dLr2/7CTRcWf70oaiHFrmbbQ+mnYOvGYjSRW+tRXTPbgYYLfoGxySu+FhyE9OAfcDs9
	F7FME4hPfLvETa+7HbwTiHyorqsZWutpeTfJMqaFXHgjVU5wjeXVtgf9lat2edYuyhg==
X-Received: by 2002:a62:670f:: with SMTP id b15mr23853617pfc.212.1548722461218;
        Mon, 28 Jan 2019 16:41:01 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5BOnTv4W/+n3CwgomL+oUr+6PCwswleo4+aAFSXsDXZW7jLo0YBwjs6Sbo5/vIII5G0LDA
X-Received: by 2002:a62:670f:: with SMTP id b15mr23848064pfc.212.1548722353576;
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548722353; cv=none;
        d=google.com; s=arc-20160816;
        b=wBtHy558MKBl8yi448b8Ad37AzsVZAAyowEitWiQdSgoFbNs9a2D6ldXWEN6Qbnqqq
         Bx6EuDXdSB2jtkWkxrOlAbQH720pOcQek3/2H+/vQkWXLrmCZLaERYOMn6o0kb3iL30g
         TdM4ARLRUwGhJSuztBBLINHWmuQ5l/ylDTPAsJNMsF6n8mpxsZi08Q7AGUGRUCg19faO
         ICxEr7Icft6hrAqCXO7s2aIHalQOspjgEJ/9isgp0wSYrck3Sk5R2esuuDYcUNRZLSmu
         pkf92HIPL4JDxeFu29CQSIZoIy1P4cwzhKIr/COABXJezhOmcBJYJkbiLk2EM++uJzJW
         WFTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=H4uqmF5HLlBo9r9rzOTTevq+cJIiPJBHTeYeqiaw1PU=;
        b=vGE1jyCMgkDrMG1g6wN2fH35ysdVD55lOcaL18ApnSHDanB3Gqdd5gUX+4Wadag+i0
         zDrn0g7Spo6P4tZRzopEGd/09NQn5d28pVU1W3fxTbwU8mXaAUBTQG1XYiLdMb/diZHP
         dB66qjUvivjLaQDHnvW7wUFcJrC54MXJg9BizuBbNceCmmI/SgOqxbW7uDp9UFw01AkN
         42wAgus0J0ejysZFOA465bEFk8N6ZppxP18Ewq3zdyz3n3lIQVk2GHo4MYeqO644OIC3
         nJq8KbQ7E0sLE/AMp70h71IqYV4b4/BKBcBQ6QAFN5mmxhcN6M5NKUN5Bo0jQzD0YRKw
         4d4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id l7si33052569pfg.245.2019.01.28.16.39.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jan 2019 16:39:12 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,535,1539673200"; 
   d="scan'208";a="133921904"
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
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v2 07/20] x86/kgdb: avoid redundant comparison of patched code
Date: Mon, 28 Jan 2019 16:34:09 -0800
Message-Id: <20190129003422.9328-8-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

text_poke() already ensures that the written value is the correct one
and fails if that is not the case. There is no need for an additional
comparison. Remove it.

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/kgdb.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/arch/x86/kernel/kgdb.c b/arch/x86/kernel/kgdb.c
index 1461544cba8b..057af9187a04 100644
--- a/arch/x86/kernel/kgdb.c
+++ b/arch/x86/kernel/kgdb.c
@@ -746,7 +746,6 @@ void kgdb_arch_set_pc(struct pt_regs *regs, unsigned long ip)
 int kgdb_arch_set_breakpoint(struct kgdb_bkpt *bpt)
 {
 	int err;
-	char opc[BREAK_INSTR_SIZE];
 
 	bpt->type = BP_BREAKPOINT;
 	err = probe_kernel_read(bpt->saved_instr, (char *)bpt->bpt_addr,
@@ -765,11 +764,6 @@ int kgdb_arch_set_breakpoint(struct kgdb_bkpt *bpt)
 		return -EBUSY;
 	text_poke_kgdb((void *)bpt->bpt_addr, arch_kgdb_ops.gdb_bpt_instr,
 		       BREAK_INSTR_SIZE);
-	err = probe_kernel_read(opc, (char *)bpt->bpt_addr, BREAK_INSTR_SIZE);
-	if (err)
-		return err;
-	if (memcmp(opc, arch_kgdb_ops.gdb_bpt_instr, BREAK_INSTR_SIZE))
-		return -EINVAL;
 	bpt->type = BP_POKE_BREAKPOINT;
 
 	return err;
@@ -777,9 +771,6 @@ int kgdb_arch_set_breakpoint(struct kgdb_bkpt *bpt)
 
 int kgdb_arch_remove_breakpoint(struct kgdb_bkpt *bpt)
 {
-	int err;
-	char opc[BREAK_INSTR_SIZE];
-
 	if (bpt->type != BP_POKE_BREAKPOINT)
 		goto knl_write;
 	/*
@@ -790,10 +781,7 @@ int kgdb_arch_remove_breakpoint(struct kgdb_bkpt *bpt)
 		goto knl_write;
 	text_poke_kgdb((void *)bpt->bpt_addr, bpt->saved_instr,
 		       BREAK_INSTR_SIZE);
-	err = probe_kernel_read(opc, (char *)bpt->bpt_addr, BREAK_INSTR_SIZE);
-	if (err || memcmp(opc, bpt->saved_instr, BREAK_INSTR_SIZE))
-		goto knl_write;
-	return err;
+	return 0;
 
 knl_write:
 	return probe_kernel_write((char *)bpt->bpt_addr,
-- 
2.17.1

