Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84FB6C4321B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:31:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53164208C3
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:31:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53164208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80DC56B000D; Fri, 26 Apr 2019 03:31:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A4496B0269; Fri, 26 Apr 2019 03:31:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 433536B0008; Fri, 26 Apr 2019 03:31:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id DDEF46B0006
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:31:47 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r13so1507213pga.13
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:31:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=3lkOJ0gCMIK7S6QGj/0XRCLT0Jm5tS9Iw+h22EmfaMM=;
        b=RF+gTEAB+VRQrtl62tefIOH1flInYvfpTx4d1HY+Uzac4jpLer4NNmFkC1o2CqkXja
         bCwuhGs4TDi6pa01vyw3viQtS2VCsdWwMI26ahk5JqoM0BIC1tYbum5yrEGq/QDeHM/U
         8nwZRAbYLNS9Qjg+bmLTV7MPe5Vk6aklojh4js9bg2goIJR2W376FPChTlMQd+BJrFwl
         vTp+5ezKyeP4w3a3TkF3fgUeg+jPphZ1k/PV0s+3h+MjDYbCWRiK1CIItbL2xNS3oCAx
         dadSNx17Oah1IFRrDstX1hfAbZJ1AEiGgPd1JoVIXSV5t7MsJcR/ozPdArKillHrhknb
         o9Qw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAVTtDneTQtXQ+Ut+MW34MSbxdSestzHLeMrUSErKwhp/JgknK/8
	RDjrRT9UZ2usnP/E8v3zcWXxIgEwvncPuehAm/+dB3eMvOAPh8uvIH2ywkiT9F0nw6pfMclFBDl
	2r/Ca9TqUD7BKhCko5Ct2j1BTy0SxP4r83dmqIe4CGg7PDphio+5ajY47ZCV4cSnizA==
X-Received: by 2002:a17:902:2aa8:: with SMTP id j37mr44990346plb.164.1556263907360;
        Fri, 26 Apr 2019 00:31:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMInv5r8YuhBW2bD5e/U0+U/Seo7x7gk+MQnLZSqhTkRnJ2lGyqXs1T3q5HOZbQI5OmETD
X-Received: by 2002:a17:902:2aa8:: with SMTP id j37mr44990254plb.164.1556263906140;
        Fri, 26 Apr 2019 00:31:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556263906; cv=none;
        d=google.com; s=arc-20160816;
        b=nquQRDvgApec/o6cad48B5FNBFzamJVZW9KHcz09Si7FZkDbEzSAMz+t2MQA7+quvC
         3TlgtF5MldUMMcyRaWjOhLgH63JRpwqMb0gVWdmOrVtq/Mz1aAXw6E3c6ZS2AOZsCOEu
         q8GRlrZKXpbXtuPHDLODtmGXkne04DV/yZi9JPHncw1XFSbZPYtcR/e38KKxh1KQrU/L
         OlOgPjgNIFlPVSqqxGBrEJOBuQdrRFRZrwix5rAG9CfH3jESFtfjZ+PQcbUSU7fENtgV
         Kx5ffyp0qe7sO7gRLX1q1GbbobpmBaAu/61tILdi3q4+A2nXoA64Y430409EXeYFjBzN
         O1fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=3lkOJ0gCMIK7S6QGj/0XRCLT0Jm5tS9Iw+h22EmfaMM=;
        b=zA6lEtmLom2z4FBlLSKr7YACFm1IPGIZBz4qSo0GyLRpcaftvhaDvof2wCGmADeVfq
         oW/zBR/9WI3JvcklHt3LvF85Uq++8Ydj6Gkc2zosyVa1bC0SoKFfSIjmXvExfDqAmhPx
         YgC/ICuQvupdRzdTys/F+esVV3Pf8Cacwe2pp7gZXhpnuGSICBy8PE0zA7hpDO/n2Tmt
         0ytvKQxKTsq1A7GStxkm5ftpqyxvIQ4b+jPtfmQc1PPqwWn/xP+IfwNQmu+lshd+c22r
         YzAPiVt8bfVc8QWbXM+CtUNiMaywEABcQXOxE+8caiuhsG7PO49E5zNJ17BC9CwbxEHy
         Zguw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id f9si22844507pgq.347.2019.04.26.00.31.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Apr 2019 00:31:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Fri, 26 Apr 2019 00:31:44 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 6F14E41225;
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
Subject: [PATCH v5 02/23] x86/jump_label: Use text_poke_early() during early init
Date: Thu, 25 Apr 2019 17:11:22 -0700
Message-ID: <20190426001143.4983-3-namit@vmware.com>
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

