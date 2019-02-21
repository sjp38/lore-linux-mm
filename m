Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0250AC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B71B120818
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B71B120818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C716B8E00CB; Thu, 21 Feb 2019 18:51:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCCEB8E00B5; Thu, 21 Feb 2019 18:51:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A72A48E00CB; Thu, 21 Feb 2019 18:51:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D36F8E00B5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:51:01 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id r9so334862pfb.13
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:51:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=H4uqmF5HLlBo9r9rzOTTevq+cJIiPJBHTeYeqiaw1PU=;
        b=SmYNvdWr1ypJ0cO/ISo6EIS+s5IDUZY4/jv1M/UOfMlFnZ5mRJ3sxRwT91eicP0b74
         V3wstIJ1JhVfEisQWMMo5xypIe+do11qOrtO8jS4eX3hTAhaZZ8MKzeaoe4cVYls01vC
         2lf+d6SP+a4xZgpj9X8HswJus/x3RkbuEbbbsZdz+XIlIIrIQd8NL7rDe9fnSCb88Gqh
         DsGGaBhSOF0+za4RS1eGofGzipwC93vDLFVXk9EPLtDsqP6MQXoW1hCcMaXD0FbS1SfV
         AiPrm8HEbQU+vNWHJTEYtE0Tcg+wExE97QD/F2zjLPCn/glw6ryylBOD5Pv+1jTV9AQU
         tCJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubznRvXhtud0xIisnVRxCOMP+nXUPuaRk2A4vyX5yHPVFV+4RUL
	cT3GW15T6Eir+sf69FrdlpT7OoFU0TMAsfhFWR9EZa4F4UFZga1fWSw3F1S9i09D6VwlH1mKTlX
	CqPiC+fivz4YpMPPQaHQZ87X/IN1IYTanGG87ASN7YgKobAE7G99ZLKxR159064/oAg==
X-Received: by 2002:a17:902:6a3:: with SMTP id 32mr1144026plh.319.1550793061060;
        Thu, 21 Feb 2019 15:51:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaLeqcjnmLxBn7QOcuM7v5cm93ESGmTR0hauSU+DXTgCmTl4Sw5sg6553rX8+FYxXFV8nVn
X-Received: by 2002:a17:902:6a3:: with SMTP id 32mr1143991plh.319.1550793060269;
        Thu, 21 Feb 2019 15:51:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793060; cv=none;
        d=google.com; s=arc-20160816;
        b=ayb/kVb8u2X1RTjKFdbJ02bjwGYIDahAV0IH19eTUONXJbVhfoCbVESW1BYcVxfujo
         2n8U1vXNtutogRRUHZo5p+EnUiUQNu3mL9wbyptoSCdhAJwACqw2dKj7K8qSDa2Hthbr
         +Nb0NKIsnnO6TkVyzQKH5dsry2RQKtdRiRHmqB5W1e3AhK5NueaQYA4TMpytwMYRztsY
         Mkl9TuoTocP+IBF+0sOkF8rvjrz9EpVsydEUWId3C/Af2APlqTzAtOzQzVZZILpt77is
         cBfJcWyIMikZNJiuoEkd+YiByPB5fXGuugb4ATaQ+XlNMCX+K/WG6CsPT/rzBwGNEWSO
         TYGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=H4uqmF5HLlBo9r9rzOTTevq+cJIiPJBHTeYeqiaw1PU=;
        b=XlHzdbDrM7mHjWh9imRiWN+oyG030aEWxdkX0yP4ehZxVt0bYl6Kzst18jgSpToh6C
         Fu7pw1GmlxnzOvs/yYfjXPIjbfsLnP6sFxllWQFYi4LBpLUWK1gBfjK/SA9YGfEHVd5x
         HMre8kjKGL9aaPPSw7VL7mRngCJlNnV2sRSyuMr6vjZZ2wIYQ3Fl2j8cuB71lfKFDSeQ
         PduYaVGjRnQiQmwQC1RT31jrdyb2e66gXs0cum9oGanSLACqC7DtGIVW8EOfwve9Syh6
         tq9xQluc1LIwQ4vmdrW1tpFHkepBtlXLklSvrinky/InAwumSdRn6KGDfdqWoS62zyn4
         TrBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c4si238494pfn.83.2019.02.21.15.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:51:00 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:50:59 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="322394837"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga005.fm.intel.com with ESMTP; 21 Feb 2019 15:50:58 -0800
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
Subject: [PATCH v3 07/20] x86/kgdb: Avoid redundant comparison of patched code
Date: Thu, 21 Feb 2019 15:44:38 -0800
Message-Id: <20190221234451.17632-8-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
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

