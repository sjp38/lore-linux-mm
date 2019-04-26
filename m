Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BAED0C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84E6A2084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84E6A2084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46D346B0007; Fri, 26 Apr 2019 03:31:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F09726B0273; Fri, 26 Apr 2019 03:31:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C248D6B026D; Fri, 26 Apr 2019 03:31:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 513B86B026D
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:31:50 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id v9so1509195pgg.8
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:31:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=PMP2Cxb893S0prGS0vCi085zHCDPTtmjtSNHdboWACs=;
        b=KRFhzxyQbxI5f2oe6IxhsiGnJsbNlagc7Z364tzeGWIoTulKEt1Iu4DRSzMje9ytUh
         nwVEl1y9P11/FYwndQtwMmUXvyC5bcKy7hB8yPZ8ydA8sGdvJ+1O69IGbR76APNDrDFW
         cxCzUt2oDJ1CbcgzvZ7PEx+LmVXIp6Lx1vHK2pnKnrPfF29Rn1Ih594Ajg1LHaOwMIuX
         aRhsZFPBnf/wd8NAvWG7RytrfvWNXZNn3yASXdCp6SXbVeoLnjtR6D60vuayDHcC5bYv
         wFBN8EmpxahZehNpL6AXHlkovhUdDGqyI5ZG8Y94vPi2fwCsXF2cQhScLulRsGZMHKfc
         jUMQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAVVEfXUgSwDV4Xyrp/TrLeHuhSlF2Gvk02umkjunfcZtxnMt++X
	omssGOlJ+JcqXiFwfIX7SvX2S/0zFOKPvwtEBrVJglMQCf7//Nn5z+PW4NGapDzFBYbtsZtqdhY
	nEHrcTZTCpiurKx++zfwxmuD0Rw6jo/aOw/pFFch3RdAjwYRnDPHKZ+qbx2vtZK2aLA==
X-Received: by 2002:a63:165f:: with SMTP id 31mr42513628pgw.321.1556263909992;
        Fri, 26 Apr 2019 00:31:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLJwkwhUGtfYO8PZHsAPxLQq916eGTtamDVeP2MnVhICTfBPlba9rHEANFOrWIRdMR0Wq3
X-Received: by 2002:a63:165f:: with SMTP id 31mr42513560pgw.321.1556263908999;
        Fri, 26 Apr 2019 00:31:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556263908; cv=none;
        d=google.com; s=arc-20160816;
        b=ggb0xoJh3MsZ5zH902CeQY5bLhBgUfwxaydev5M3he/sQA7lNIKYeRUqVj2gbjBN5s
         kb83V6g5jHhXnUfJE+ekOnPYGmDskLTW84heWdcXMSMBQDxqeZ56ZV0LAYz+RXblvdI1
         znrb70EHA0jpAt8OyluTBlMJxdCsAKbS8ZO4oxXEyuLlwnhe/h54e/7P4lM9ErLYJT2y
         jPxY5EIxh2MJUrA8RJaYoqkNsjd7cTMue2+LClrt8cICEO/jtyN0GS/jvEMFhqAa/UV4
         cUYp8ZaTxGgAAkelCDBYTSVpXd0nTJG3rXaYgmIFGwmZEbNqwklndM4SFWhSGVl6isVx
         pARw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=PMP2Cxb893S0prGS0vCi085zHCDPTtmjtSNHdboWACs=;
        b=kEdGFvkvGBs7uCjIQCDI7n51gju2ys9f7K+a9wpsF4ioa/zNRga0bygBKUme0U+I6a
         AvZ8SvZr3OFPcVZkPw+BA840QRGFhSqYzlXFp0wHaAqXQbyvmK5iQG7XFIPGu0FCGRVF
         qTrEI5hOly7/8cVVvULpR1g1pSSC4ob2QNR8h4RHGak2J1g4Dv5PDN+RkB//e7IE84zi
         FYnxcGcgUnEinUJ7RWNgN5XaDakd6U0KHWZs+3dBqYOxSrdydvkQAmCYa10/DjG2p6Tc
         DsEelB8BglPeVSZQw0Uv1ANh6jGfmX1rm+H0Igz5ZcUPTWrbcIljTSV9kKwBDZQxiKC8
         e4Kw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id f9si22844507pgq.347.2019.04.26.00.31.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Apr 2019 00:31:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Fri, 26 Apr 2019 00:31:45 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 186974129C;
	Fri, 26 Apr 2019 00:31:46 -0700 (PDT)
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
	<rick.p.edgecombe@intel.com>, Masami Hiramatsu <mhiramat@kernel.org>
Subject: [PATCH v5 20/23] x86/kprobes: Use vmalloc special flag
Date: Thu, 25 Apr 2019 17:11:40 -0700
Message-ID: <20190426001143.4983-21-namit@vmware.com>
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

From: Rick Edgecombe <rick.p.edgecombe@intel.com>

Use new flag VM_FLUSH_RESET_PERMS for handling freeing of special
permissioned memory in vmalloc and remove places where memory was set NX
and RW before freeing which is no longer needed.

Cc: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/kprobes/core.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/arch/x86/kernel/kprobes/core.c b/arch/x86/kernel/kprobes/core.c
index 1591852d3ac4..136695e4434a 100644
--- a/arch/x86/kernel/kprobes/core.c
+++ b/arch/x86/kernel/kprobes/core.c
@@ -434,6 +434,7 @@ void *alloc_insn_page(void)
 	if (!page)
 		return NULL;
 
+	set_vm_flush_reset_perms(page);
 	/*
 	 * First make the page read-only, and only then make it executable to
 	 * prevent it from being W+X in between.
@@ -452,12 +453,6 @@ void *alloc_insn_page(void)
 /* Recover page to RW mode before releasing it */
 void free_insn_page(void *page)
 {
-	/*
-	 * First make the page non-executable, and only then make it writable to
-	 * prevent it from being W+X in between.
-	 */
-	set_memory_nx((unsigned long)page, 1);
-	set_memory_rw((unsigned long)page, 1);
 	module_memfree(page);
 }
 
-- 
2.17.1

