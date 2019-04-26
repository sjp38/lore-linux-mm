Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DATE_IN_PAST_06_12,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 159CAC43219
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:44:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4E0A20C01
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:44:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="K41kvx1t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4E0A20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68A766B0276; Sat, 27 Apr 2019 02:43:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5EE546B0277; Sat, 27 Apr 2019 02:43:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 466966B0278; Sat, 27 Apr 2019 02:43:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D9176B0276
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:36 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id n5so3492539pgk.9
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=PMP2Cxb893S0prGS0vCi085zHCDPTtmjtSNHdboWACs=;
        b=evbup2rdZ+yf94IViUC4SK7UboQfysAbBoqSewJzDhobG6A4otS3M2pun/Y7lXK7Jk
         H2gOH+bg+0XEwuanRjqHjtmIXRqHTT7w5kSPmQyOCbD1BunhoV3gQl4gMca4XjqcctMM
         oPd3nt0c2wo5tVfN1laAr0ZNVaK1QPqcFotPyIqX8r2FyXFlmtALozrfhBMNN4mnJb2l
         HDXR2jTuhS9rMZrqdToglwRezZgwKiZl+ikAiVeLAiTbtSxXHVUqaSHjn+Xgzg8aiehk
         hGmk9CJf+Z3IdlstOdpLf8AUwLDG6wNno15m3Uh1uShvI4bRrqvSGXT8/ohNPVHuvOKS
         q/ug==
X-Gm-Message-State: APjAAAWQDypGWe7iMteFEiaEjbBuuDt3tpnwbGCFeXPuuMfMYE2hatvf
	nSxRv3j+4T7q5XbgKJaWQv50CBFkrAIYlUaegze6w7WegdUVfHTnrkjaeG/+lpeKlZOmJLU4X6s
	DJg0A//+E4FTDuGhX83TLRbtzquM7qcXgxah/mPKgheDp6iIzdmnr4gDhtXZxLka+fw==
X-Received: by 2002:a17:902:2e83:: with SMTP id r3mr50238539plb.153.1556347415746;
        Fri, 26 Apr 2019 23:43:35 -0700 (PDT)
X-Received: by 2002:a17:902:2e83:: with SMTP id r3mr50238499plb.153.1556347414772;
        Fri, 26 Apr 2019 23:43:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347414; cv=none;
        d=google.com; s=arc-20160816;
        b=dU3vPkLMQE78N0Pxo/acyTzHpIgXtBgKuoQBdgsvqS1GEDRuGffE/pyK8a62dZQGCZ
         3iJe+1C7W25ftZfIyoAHqpkcMJAeTzUNXLbYEssFC+kGNaIV1oZ8TfMw7roY61kM6Doi
         WWXjnLw77qGSfrTkTeCW5F2YPoFNpj2zMoXKwGR+j+UveHZ7sHgdiB1o/w1FrcW0jX7W
         vaUenmou/r/96kBiZbg0JOSqShCVQGUEt5Qv8+HJzQ5cjdJU9n27gOjkMcuGAWoo0E96
         W9oxrljjE47mM2mMlcWdVg8x/Fdlcvk9TD5PyUd10qe3eKp41poSF3BsweHsP3aitY+4
         NksA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=PMP2Cxb893S0prGS0vCi085zHCDPTtmjtSNHdboWACs=;
        b=qCKm8+k9X+54X47a7xoe3p4tHkkrsa/eq5dZsyGss+CwwkZtg57lUgketz32QWkTZN
         fTqwdOuyA1DuXy6Ojk9W9E1bUthjYhTzJ+7xBwYgzdgH7oHt56JcmnBBuamPhWbaIrma
         8eI6GivRos1eZ+MhWzSta8jc/xjx0QA8hAWEWKDSU194cR/Ib3QnKDbz8LaSHAzLsYvP
         BX92S8j0UsT9/wRRaAI7cdDYmxaruHre1NohLb6RuBL8b7taj2K8bwIy3eu4BSUedSXU
         aRorIF3sMXlZWYn3RCyQ6Gy/34rt6jHXSI2NErJR8v0IyePXXHJQHGIY0AGhYcsdypXw
         5CFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=K41kvx1t;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j6sor26814458pll.42.2019.04.26.23.43.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=K41kvx1t;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=PMP2Cxb893S0prGS0vCi085zHCDPTtmjtSNHdboWACs=;
        b=K41kvx1t6SFhhfzncmYY1HeK2Igm+/jVQYVM/IJLmHXShsg5nGe8rTKsYo4rZoZPC/
         6zju36lQj+i8uBKtds/aE0HT690JXiZHzsJ4iG2ZVbGtv1+m8Rexp2qGC4WzKGij4mJY
         pS0wLymSfhipDrS8/jIS0cMHQRk/GDuPBjL2K/M1OnR2vxv4YrIebnQ2xexSNHS3XdIV
         svsj4+MI3xf9ZC2zePDJQy6e/n2bUI0eeL3ftgtEvNDNqK6/0DUPSoZt2Ss6m6/VX3rn
         2cMMuSy1cr6XBfOuPS4wxZ/91yZ1FLcgw2kClZNZEQvPCdnBiT4UNc5YyXetyq58UhjO
         W5iw==
X-Google-Smtp-Source: APXvYqzt81NaHzE4N6lgOn1CEEv66yygls114EGZnoMMrIlsI1R4+4jwMYRUYyyw4vMJxMCD0c6n8g==
X-Received: by 2002:a17:902:f094:: with SMTP id go20mr50490988plb.159.1556347414288;
        Fri, 26 Apr 2019 23:43:34 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:33 -0700 (PDT)
From: nadav.amit@gmail.com
To: Peter Zijlstra <peterz@infradead.org>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
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
Subject: [PATCH v6 21/24] x86/kprobes: Use vmalloc special flag
Date: Fri, 26 Apr 2019 16:23:00 -0700
Message-Id: <20190426232303.28381-22-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
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

