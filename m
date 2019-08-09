Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE422C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 521FA2086A
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 521FA2086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D481B6B02B3; Fri,  9 Aug 2019 12:01:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C783C6B02B6; Fri,  9 Aug 2019 12:01:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF2686B02B3; Fri,  9 Aug 2019 12:01:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 40D456B02B5
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:46 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id i6so46680375wre.1
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UpTwNjkf87zYKSmkI/YNR0I3zzE4Ff096n9+NM+blYo=;
        b=PiAjxr0dYbUzWmGl0AUj0KoiY2zCDQJ1oz65RlCYtIoomS8OwPSQCnTk+2IC9Y1R+g
         6TWM/FEItpBwSwMkYbiuFQ6EURrywHeVKtPBbSF6AqcDnz+nI0W6+jk6CKiuOf4k1K4I
         6T3l3J0hIhU4l5rIQ+hgTRAM3kgXuA3Td4q2dxhs3G3KjYNloeo9Gw+8BsqxSC3c9m1z
         tu+IX6kywH9Vo5Hi43YqLVBdvUiRYw+x8HUj2DG7Tu5d70B+Q17sEwc4wpfOTWVktXfU
         MB0lVGWKQIwj/hSAyo+VztYx7H0m0HLtCtdp4JJ1nwq33t8qD4kSrcHCQ+wEs1Vf1ZWF
         n/pQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAXX97wEs/Swjxd1n/H0GIfLalzer/wYYT2xOOwte9ohsasnE8JU
	W6pA3hKmxeu4N7IlTjdNSkyCVXzdlCImwzomK83IJKHEFbFh/Rlre99lab5pHoJDX6bsACjvAu0
	9ZOMGWvWP7a0QhClImi2UKYYcfI4gzoIzvNJ6Fqhp1vI7sm/ieMqEIr1klWhSNIo64A==
X-Received: by 2002:a5d:56c7:: with SMTP id m7mr25093475wrw.64.1565366505858;
        Fri, 09 Aug 2019 09:01:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxFR4S56PtbBoiUpH2dKa8xxcTmTAX4sc5sINjLErwjIsnUJGbPXVxA5mcamY5AX5YY3NbZ
X-Received: by 2002:a5d:56c7:: with SMTP id m7mr25093368wrw.64.1565366504913;
        Fri, 09 Aug 2019 09:01:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366504; cv=none;
        d=google.com; s=arc-20160816;
        b=Qi+YyVV4NefZ406beCvjZdttMTXL9qhBWBoBgn/eOz79l+UnKZKh0O4pT0S/6ZannQ
         AkTQigmhP6crGvT35Gx/ZUyz7lTdrG0w3MKgcwQv5CpesyhwGuJjlRRV5P/Ni+4YUJpY
         Ld4A4tMwDzwUGQbYq4cupkZ7Us+4jIr5rGmAN9v6eedQX4MyFNqVitvqxIaSyfq3xRDi
         lqEZsRKqjHlhDPnhZ+jGulv4vZOxVpm70ztirOtpORWyeSStBYBCvlbncXfCTDV6WxL7
         UWn1jGcT6MOt3R1Eit8DZUE6CFS1FsOWpUNQyPglwXwQsz3jreizrhQ7PhZgMgn8Qp/o
         m7Lw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=UpTwNjkf87zYKSmkI/YNR0I3zzE4Ff096n9+NM+blYo=;
        b=ShJZfluzuOOdISHhTX1ZFIoSHcQRZF1O8/uh4QiA1ovOh40Mh0ggyW3Jtw2MTOItcg
         lm9njnlrojMYR/KgR5gj45ZJecctNnMJLKCZuCuq8cF1mgBaGks9ccDVKBNCCmxvJA7U
         kZxgT76qon5oSP++1lrZlhQLlNzyzECEifanllu0H9FnRtr4rc/c3336JEKecPIcYcWe
         WCcgdlYROUX/3PmxhFHD0RVXNoiOLlnrcyjYEkKSrwG1BStmW0/2kmVBiUabJ4GdsF/n
         uM0BxprGNAefSpr8foDwpVIMre3DHMHqcY1RiPhVv109n9vh14h8TIEcA76NHsSEnhiE
         xWKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id q14si91715809wrf.249.2019.08.09.09.01.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 59BC2305D369;
	Fri,  9 Aug 2019 19:01:44 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id C8C39305B7A1;
	Fri,  9 Aug 2019 19:01:43 +0300 (EEST)
From: =?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	=?UTF-8?q?Samuel=20Laur=C3=A9n?= <samuel.lauren@iki.fi>,
	Patrick Colp <patrick.colp@oracle.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>, Zhang@kvack.org,
	Yu C <yu.c.zhang@intel.com>,
	=?UTF-8?q?Mihai=20Don=C8=9Bu?= <mdontu@bitdefender.com>,
	=?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v6 90/92] kvm: x86: emulate lock cmpxchg8b atomically
Date: Fri,  9 Aug 2019 19:00:45 +0300
Message-Id: <20190809160047.8319-91-alazar@bitdefender.com>
In-Reply-To: <20190809160047.8319-1-alazar@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Mihai Donțu <mdontu@bitdefender.com>

As it was the case for lock cmpxchg, lock cmpxchg8b was emulated in two
steps the first one setting/clearing the zero flag and the last one
making the actual atomic operation.

This patch fixes that by combining the two, ie. the writeback step is
no longer necessary as the first step made the changes directly in
memory.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/emulate.c | 42 +++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 41 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kvm/emulate.c b/arch/x86/kvm/emulate.c
index dac4c0ca1ee3..2038e42c1eae 100644
--- a/arch/x86/kvm/emulate.c
+++ b/arch/x86/kvm/emulate.c
@@ -2320,7 +2320,47 @@ static int em_call_near_abs(struct x86_emulate_ctxt *ctxt)
 
 static int em_cmpxchg8b(struct x86_emulate_ctxt *ctxt)
 {
-	u64 old = ctxt->dst.orig_val64;
+	u64 old;
+
+	if (ctxt->lock_prefix) {
+		int rc;
+		ulong linear;
+		u64 new = (reg_read(ctxt, VCPU_REGS_RBX) & (u32)-1) |
+			((reg_read(ctxt, VCPU_REGS_RCX) & (u32)-1) << 32);
+
+		old = (reg_read(ctxt, VCPU_REGS_RAX) & (u32)-1) |
+			((reg_read(ctxt, VCPU_REGS_RDX) & (u32)-1) << 32);
+
+		/* disable writeback altogether */
+		ctxt->d &= ~SrcWrite;
+		ctxt->d |= NoWrite;
+
+		rc = linearize(ctxt, ctxt->dst.addr.mem, 8, true, &linear);
+		if (rc != X86EMUL_CONTINUE)
+			return rc;
+
+		rc = ctxt->ops->cmpxchg_emulated(ctxt, linear, &old, &new,
+						 ctxt->dst.bytes,
+						 &ctxt->exception);
+
+		switch (rc) {
+		case X86EMUL_CONTINUE:
+			ctxt->eflags |= X86_EFLAGS_ZF;
+			break;
+		case X86EMUL_CMPXCHG_FAILED:
+			*reg_write(ctxt, VCPU_REGS_RAX) = old & (u32)-1;
+			*reg_write(ctxt, VCPU_REGS_RDX) = (old >> 32) & (u32)-1;
+
+			ctxt->eflags &= ~X86_EFLAGS_ZF;
+
+			rc = X86EMUL_CONTINUE;
+			break;
+		}
+
+		return rc;
+	}
+
+	old = ctxt->dst.orig_val64;
 
 	if (ctxt->dst.bytes == 16)
 		return X86EMUL_UNHANDLEABLE;

