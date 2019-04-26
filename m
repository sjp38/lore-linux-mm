Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 851A1C4321B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:33:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4549F2089E
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:33:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4549F2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC7206B0287; Fri, 26 Apr 2019 03:33:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B14A46B0289; Fri, 26 Apr 2019 03:33:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C7EB6B028A; Fri, 26 Apr 2019 03:33:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A74F6B0289
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:33:23 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id x9so1464936pln.0
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:33:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=DXoaQOfmRoLFd3xwEem3ey63J4Sb1Jdcc0n/TAChKh8=;
        b=YTA96CvEFQPhJEGCIBmYa59yc/G627Az7+q6Ot8zz79HGMRx6d/EkKCobSdHbu0YqD
         FjHccP2JTmLf4pXszqFLmMq3STjtCfOpOjaJ0tk5Vjq1+5IrXpG8wKRN12sgHBTeX9qn
         U0zWJcUxTw4oBiv9iauHbbL94N7fo8JgClQxFn5FsD3T82ClN4mEe6VQa+jWa2d0kf11
         XWFNuHPWhUNeteCa5SY4/vYZhUDUludf/3f7MsIURdVq8fxoK5IGxSN5WrFXKNm8QIAz
         Vaeuf8ttOfuYXA+trBgssHBz81juMRTXAVuoGuVkjj+/n2gggwBnF9vsX+nPmzoSpoKh
         1KtA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAXM8IFRw7S1/rUFx4Z1Q8qbAp1c70YKqFG0PqOmCMoD2Bo2jFvH
	WN9LXlWYqbQTdF8B6Ti6sNxA30XQa2EJnU9aiMEwWgcZxnkQsnNfpAFuqbakvA/wRFmqeFdgoVV
	6ts+3wdlMp2XYHrLqAkNWoai5VE0LhHSEdK/fb9rda5KtCTbmshiD+jt9v3vVbV+KwA==
X-Received: by 2002:a17:902:2a03:: with SMTP id i3mr45985430plb.229.1556264002960;
        Fri, 26 Apr 2019 00:33:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGXzypBw6OltpnQmePY/F5N9S0sarW8Uq9pJwYGJF4jFFzlBdxgAKGtccB5xOrP+oye502
X-Received: by 2002:a17:902:2a03:: with SMTP id i3mr45977889plb.229.1556263907348;
        Fri, 26 Apr 2019 00:31:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556263907; cv=none;
        d=google.com; s=arc-20160816;
        b=1AK0nzzi5hz/aRGlqTvNv+9UtzHGGZqnD57sdIvs128VdwopN69na5aLARZWvoZWKN
         mMOHmKw0kRqVAHG8XYzqWQir6ReGvnaM7+QngPtXXzmPpePz7X6OxMswa299n9IHotwx
         yyzAEAW9PvEBhfHIPmehpAyxtvoC2s2xZFdcggtS0O4s2BLbS05gRZqo4YRHMboTD7W+
         Tk0wmm8KqnqTld0l6R0TY9lKU94RroSJcLVb3aLqnCqlVOxdtBaxXt7dRpzv4qItoV2z
         DI25A+pqKR8qAXFcJpjSWKQPuzF8ezNJMHcQmdLaTwHNynKhqm2PZqLI9KeoDcpF3C5d
         nQTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=DXoaQOfmRoLFd3xwEem3ey63J4Sb1Jdcc0n/TAChKh8=;
        b=C5qxUg88mrN0UGQdohRg0kXe15OBYycjGH+tAyFEIYqlpFlKjol2hHOUdk68W0OsfA
         QIHGM45BqGPVrhpazjWZ28D+LeTJW6w68Ge3t/bKHbm9Jqw/wYgwQP0Htv+BV4BcvsL7
         fkBXBmJBTKCPAMPM69BhSLZhSj+mMFH+HuTib9dehSgAUU8m7D+kxz66RKrE5KQnYNVs
         q/0mwQploDAHajvUBeB40KejB5RWjWnRJqizAhNz81yUqX3fpaoZe64h992iSCoduska
         YkUp0eE+09ILcAoZKyUAcOL1BEA8195XGMfuWbrO6H9A1PNeCbgG2963Qzt6cTgP2ffO
         6f9w==
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
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id A1013412A3;
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
	<rick.p.edgecombe@intel.com>, Nadav Amit <namit@vmware.com>
Subject: [PATCH v5 08/23] x86/kgdb: Avoid redundant comparison of patched code
Date: Thu, 25 Apr 2019 17:11:28 -0700
Message-ID: <20190426001143.4983-9-namit@vmware.com>
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
index 2b203ee5b879..13b13311b792 100644
--- a/arch/x86/kernel/kgdb.c
+++ b/arch/x86/kernel/kgdb.c
@@ -747,7 +747,6 @@ void kgdb_arch_set_pc(struct pt_regs *regs, unsigned long ip)
 int kgdb_arch_set_breakpoint(struct kgdb_bkpt *bpt)
 {
 	int err;
-	char opc[BREAK_INSTR_SIZE];
 
 	bpt->type = BP_BREAKPOINT;
 	err = probe_kernel_read(bpt->saved_instr, (char *)bpt->bpt_addr,
@@ -766,11 +765,6 @@ int kgdb_arch_set_breakpoint(struct kgdb_bkpt *bpt)
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
@@ -778,9 +772,6 @@ int kgdb_arch_set_breakpoint(struct kgdb_bkpt *bpt)
 
 int kgdb_arch_remove_breakpoint(struct kgdb_bkpt *bpt)
 {
-	int err;
-	char opc[BREAK_INSTR_SIZE];
-
 	if (bpt->type != BP_POKE_BREAKPOINT)
 		goto knl_write;
 	/*
@@ -791,10 +782,7 @@ int kgdb_arch_remove_breakpoint(struct kgdb_bkpt *bpt)
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

