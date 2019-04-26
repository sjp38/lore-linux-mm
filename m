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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26285C43218
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:44:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D12C720B7C
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:44:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZcHDpG5o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D12C720B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B22CA6B0277; Sat, 27 Apr 2019 02:43:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA9CC6B0278; Sat, 27 Apr 2019 02:43:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 948786B0279; Sat, 27 Apr 2019 02:43:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 537DF6B0277
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:37 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b7so3226347plb.17
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=Mq726et3FUsm8L5SG93p+KUhd7ShOgthVM8qUN29ytY=;
        b=m3ukOiXvW4man29I9owjO1iSQ36kmb2yNDXYurZ8SsWOr0Aaqu/pMaVNTj/Kpm41DU
         9oYujswiv+Sy//rt34oqVKRahQzGRtK0zwJ3xj4m5YjfH0t2GkF75Y4gI8vXQIrv27gt
         uk2XEafXe4cvaNW2y1gxmNJj071lVaIFfEDcMtuMmDS9wSz2ptUFyHS69DntH12eZKff
         bQ4jUuskp1BnWUx+4ZDO2a9u80YO3LAdr09fRlN7tc29OxvaKwXgxLZRfMWtJxef+rn1
         KTd1Qx/WhL6YWGHsHKFutGgy5N0XT8TJp0Xq7CbGWJx5HatJAROlsfUMOQAq/7aiyYJg
         GBNw==
X-Gm-Message-State: APjAAAWBL9GitW51NqtAriftBULOvHuQIrUcsSPdvWiFJ7yHVekIdAj+
	rYQQvdnIvFzyL16E+OaDnjuA0gPSwr3DkbLN0gFqd2Fozf5f4RcyyWl5K0PuCoDRc3XmSU0rcPE
	FY4MiJN7pdZ+peiFxcwcsN7EEnjRT0wooKsgLaPCTyl/MQYFdwo8wvQlMXqcSzyCNvQ==
X-Received: by 2002:a63:5041:: with SMTP id q1mr24951430pgl.386.1556347417027;
        Fri, 26 Apr 2019 23:43:37 -0700 (PDT)
X-Received: by 2002:a63:5041:: with SMTP id q1mr24951391pgl.386.1556347416101;
        Fri, 26 Apr 2019 23:43:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347416; cv=none;
        d=google.com; s=arc-20160816;
        b=0ihllf0orVZUtxx/bIPAhjmW4iD0H/qXjOo4NgdHZsWscV+19PX4y9r6jDkR2xQ62l
         AaSo4n+Pnc/E3Isrn4dA/upoZY2xgUpIVl2g6yvuejE4Q25PZHpve3PDvfWs5ys5vjN4
         O3tfKMEmisWLbz5JR3uP5kuaswAZnik+2sKbJ9XtayigIfvv26vON0VmCaiX1jyrQ4MT
         uJvsZ9J08BCPekKJWCTSxp6jmpZthvpxSXrSSI27jj6JTu+GCnVzX2JaNuTqyuDCFHlS
         MIUBnubDmrLxCzFuPB8i7uYVtR1fdV8MBLPCrY9faglBYWapqlpskjn7Py2C34w1zWy9
         VnXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=Mq726et3FUsm8L5SG93p+KUhd7ShOgthVM8qUN29ytY=;
        b=pSM/sLdOozy2nMpcytew7z5BhteeEr5sCPol1GOWcKfi3JloaefMMHaCPksnRaZmSD
         HLWyivLcn2KGXBkFUEz3OFfzATxpACtuT9vpEVHH3k/4MgTVL501KYw9Kdc7siInhYnf
         oZRrSFjQiCindC1eW1HAWyd0UQrQfYnLvuHOLhR5s7ldTWD5wASQ4zuyEWz7aEzxgquW
         hXb4rvl9JsNwarpS39DdiZB3foJY7XQZUCG8L12HMIigqH52y/wea4RNBLpbgEVbtuyS
         Ce7yNt19qrTWFFC840s6ehR+Z4ojQ4y2Ap7gbrWbLnC+n6srT1yJXcrvyBYbJvojNkD3
         lWUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZcHDpG5o;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d63sor28993657pgc.2.2019.04.26.23.43.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZcHDpG5o;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=Mq726et3FUsm8L5SG93p+KUhd7ShOgthVM8qUN29ytY=;
        b=ZcHDpG5oI881U7Ra0/L2O5huO2cwDn2YrdsQ5hiAWkm6WdBzN67nlkJvfLDLJC5q+X
         UOCeP+9RydbCT4dO6iGp4lZQdm3+sXHNSQC0G0grGB6NOlnyKbwZn5NdDqZwDHIXRDud
         3mNZu1J6RFiZozyuuSJ7f0wBAoiYQFhmUfj5tGkTm8jduQKjEFGn6AF04k5qQYjIWsXY
         4YzLX+ZgfiYxaYFVUDUXXbJdfkkMMJKkcbeIB+VGTLlKKEI2dS4TTD29m/lBt3TdxyYa
         a4fp8LYLp6QEbTAIinVcBUAwlwg+TwtnzyGC3pPfhsUXM3/E24y9pQ9Ah5nWVdchzhK2
         LMJw==
X-Google-Smtp-Source: APXvYqz6QdLKu0nIIJYQFhptNQ/c9BRHYqidvmm2brorovTM3Ggu9E591UYxGE1lKlV0dGgfmeOtWg==
X-Received: by 2002:a63:e051:: with SMTP id n17mr5092049pgj.19.1556347415619;
        Fri, 26 Apr 2019 23:43:35 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:35 -0700 (PDT)
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
	Nadav Amit <namit@vmware.com>,
	Masami Hiramatsu <mhiramat@kernel.org>
Subject: [PATCH v6 22/24] x86/alternative: Comment about module removal races
Date: Fri, 26 Apr 2019 16:23:01 -0700
Message-Id: <20190426232303.28381-23-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

Add a comment to clarify that users of text_poke() must ensure that
no races with module removal take place.

Cc: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/alternative.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alternative.c
index 18f959975ea0..7b9b49dfc05a 100644
--- a/arch/x86/kernel/alternative.c
+++ b/arch/x86/kernel/alternative.c
@@ -810,6 +810,11 @@ static void *__text_poke(void *addr, const void *opcode, size_t len)
  * It means the size must be writable atomically and the address must be aligned
  * in a way that permits an atomic write. It also makes sure we fit on a single
  * page.
+ *
+ * Note that the caller must ensure that if the modified code is part of a
+ * module, the module would not be removed during poking. This can be achieved
+ * by registering a module notifier, and ordering module removal and patching
+ * trough a mutex.
  */
 void *text_poke(void *addr, const void *opcode, size_t len)
 {
-- 
2.17.1

