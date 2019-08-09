Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91338C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21928214C6
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21928214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D67076B02B6; Fri,  9 Aug 2019 12:01:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA26C6B02B7; Fri,  9 Aug 2019 12:01:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B66E16B02B8; Fri,  9 Aug 2019 12:01:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6948E6B02B6
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:47 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id f16so46657272wrw.5
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SNS5tjHB32VOtUnHjRf+ZxsZb/M/vnGKzuW99EfNbGo=;
        b=Q0U8/9zMs821OfrJc2H1R6Sa70hjZxS97VARx2cuoHC8XnqQX5SpZRq6AhNPNJwOh0
         j/srbdLThdot9fiwG5Y/4m2MW2zIz3FJZNmDrBZWFyroDfnmIJ0h4+Ih/sVsAabwN/kl
         T9/wh8u5Y1RXRGo/jke4dEfXbWJ+OIewdT53grGz6z5iw1fHjIdafV+1PZibH7i0bWZE
         upQnmKdaU00Dsu/F9el1ZHD7r/2ax1MvzK+glzjjPSyi60T1I3cOJpATkpX4ZzMetN0A
         hFky0HA8AL5UGstFZwcZnUbFwQbDqBhJNCEZ+Aj7jl6V9WSKfPaIoY8YDvtU2cVsfLfW
         Zgbg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAVI7Iu4V85rfIufhYW95Vhrq1c4rZMhHBidKH0hWPzUkFHab9l2
	crMMqerKRTcCP50RZ/VhUK5I4a3yWsNDwEalpKhmoLEM5IrBagD5sjWT4kU8RrTdvVUDZNQ0XiG
	abQUaQSFB9t3oThDKZELxncQED4cpsaSS5fSu02H4J+3QgtZxyb95e8i+KFWgu05l/Q==
X-Received: by 2002:a5d:498f:: with SMTP id r15mr23418893wrq.353.1565366507001;
        Fri, 09 Aug 2019 09:01:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhrJun9IhB2e9Dd+mewTkARbP1JjousI3Pg7llBFE38e1CwjggKLllFYTlLX30OFq1RrLV
X-Received: by 2002:a5d:498f:: with SMTP id r15mr23418741wrq.353.1565366505257;
        Fri, 09 Aug 2019 09:01:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366505; cv=none;
        d=google.com; s=arc-20160816;
        b=woRF06WlcelkXb8L7RVh5uveMK56NmPYX0ttQDqxcy92aavPvZJwWHOlColU3xHHuc
         xSV4q/7yVlZf2rt8rt9kgodZ9OZWmbl/kaFzvUwfxuyg4pw98gTqymjZNSNf1yN1bJRy
         bZaw++AlSDHv1BzH/eJlv2JwUApU3fnlRuvaY9NjaQJZV6IZ6Glg0SCnP+PwoPAFHkkT
         y8ESupTpSyZ/pBbPEnGWgw+g4kwSMZro7Tt/Id45sAUKJLSpRwgxXvrytR8TdogTC9X6
         WMMipOm3ad5NxlvTzK3g5CaPUvLFLa6GsC+MZhmQyS0sULsWvditsI7oIiU23fdJqitH
         NDtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=SNS5tjHB32VOtUnHjRf+ZxsZb/M/vnGKzuW99EfNbGo=;
        b=hAuYg3BT/UcEu9jkC1Da0jouy2066egZQ+KzycLsEJSbOm2bcb3OfR+PWHmSiqSA5b
         JpddbmN6JWj6xcrwRt5GO+6L0MlJiWgy1MiVNsxYeoT6RrYyAEYrnjwwn4FsoO80o/8s
         lceurIoYF2xiGbW/CRnCQ+izIBPnyrWxqwHG4pvV3S+SW0P0d6YWWj0Y7wWowJmd6FJ7
         i7PnhowRb/u/Rxnz3tMCqKXQR8PXPjky8DS2cHw7/8SmJEAQgG8ifTZVDTs5jWbyUp41
         XP7YLhzUn4WtBny8frkxRY9XwlRQ5xOKwRH4Duzg+tRFU4GYdqJl4/66jpwpuEAqrw4J
         2E3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id d4si57715118wrx.109.2019.08.09.09.01.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 9C3CC305D36A;
	Fri,  9 Aug 2019 19:01:44 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 56DAA305B7A0;
	Fri,  9 Aug 2019 19:01:44 +0300 (EEST)
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
Subject: [RFC PATCH v6 91/92] kvm: x86: emulate lock cmpxchg16b m128
Date: Fri,  9 Aug 2019 19:00:46 +0300
Message-Id: <20190809160047.8319-92-alazar@bitdefender.com>
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

This patch adds support for lock cmpxchg16b m128 by extending the
existent emulation for lock cmpxchg8b m64.

For implementing the atomic operation, we use an explicit assembler
statement, as cmpxchg_double() does not provide the contents of the
memory on failure. As before, writeback is completely disabled as the
operation is executed directly on guest memory, unless the architecture
does not advertise CMPXCHG16B in CPUID.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/emulate.c | 117 ++++++++++++++++++++++++++++++-----------
 arch/x86/kvm/x86.c     |  37 ++++++++++++-
 2 files changed, 122 insertions(+), 32 deletions(-)

diff --git a/arch/x86/kvm/emulate.c b/arch/x86/kvm/emulate.c
index 2038e42c1eae..a37ad63836ea 100644
--- a/arch/x86/kvm/emulate.c
+++ b/arch/x86/kvm/emulate.c
@@ -2318,46 +2318,103 @@ static int em_call_near_abs(struct x86_emulate_ctxt *ctxt)
 	return rc;
 }
 
-static int em_cmpxchg8b(struct x86_emulate_ctxt *ctxt)
+static int em_cmpxchg8b_locked(struct x86_emulate_ctxt *ctxt)
 {
-	u64 old;
+	int rc;
+	ulong linear;
+	u64 new = (reg_read(ctxt, VCPU_REGS_RBX) & (u32)-1) |
+		((reg_read(ctxt, VCPU_REGS_RCX) & (u32)-1) << 32);
+	u64 old = (reg_read(ctxt, VCPU_REGS_RAX) & (u32)-1) |
+		((reg_read(ctxt, VCPU_REGS_RDX) & (u32)-1) << 32);
 
-	if (ctxt->lock_prefix) {
-		int rc;
-		ulong linear;
-		u64 new = (reg_read(ctxt, VCPU_REGS_RBX) & (u32)-1) |
-			((reg_read(ctxt, VCPU_REGS_RCX) & (u32)-1) << 32);
+	/* disable writeback altogether */
+	ctxt->d |= NoWrite;
 
-		old = (reg_read(ctxt, VCPU_REGS_RAX) & (u32)-1) |
-			((reg_read(ctxt, VCPU_REGS_RDX) & (u32)-1) << 32);
+	rc = linearize(ctxt, ctxt->dst.addr.mem, 8, true, &linear);
+	if (rc != X86EMUL_CONTINUE)
+		return rc;
 
-		/* disable writeback altogether */
-		ctxt->d &= ~SrcWrite;
-		ctxt->d |= NoWrite;
+	rc = ctxt->ops->cmpxchg_emulated(ctxt, linear, &old, &new,
+					 8, &ctxt->exception);
 
-		rc = linearize(ctxt, ctxt->dst.addr.mem, 8, true, &linear);
-		if (rc != X86EMUL_CONTINUE)
-			return rc;
 
-		rc = ctxt->ops->cmpxchg_emulated(ctxt, linear, &old, &new,
-						 ctxt->dst.bytes,
-						 &ctxt->exception);
+	switch (rc) {
+	case X86EMUL_CONTINUE:
+		ctxt->eflags |= X86_EFLAGS_ZF;
+		break;
+	case X86EMUL_CMPXCHG_FAILED:
+		*reg_write(ctxt, VCPU_REGS_RAX) = old & (u32)-1;
+		*reg_write(ctxt, VCPU_REGS_RDX) = (old >> 32) & (u32)-1;
 
-		switch (rc) {
-		case X86EMUL_CONTINUE:
-			ctxt->eflags |= X86_EFLAGS_ZF;
-			break;
-		case X86EMUL_CMPXCHG_FAILED:
-			*reg_write(ctxt, VCPU_REGS_RAX) = old & (u32)-1;
-			*reg_write(ctxt, VCPU_REGS_RDX) = (old >> 32) & (u32)-1;
+		ctxt->eflags &= ~X86_EFLAGS_ZF;
 
-			ctxt->eflags &= ~X86_EFLAGS_ZF;
+		rc = X86EMUL_CONTINUE;
+		break;
+	}
 
-			rc = X86EMUL_CONTINUE;
-			break;
-		}
+	return rc;
+}
+
+#ifdef CONFIG_X86_64
+static int em_cmpxchg16b_locked(struct x86_emulate_ctxt *ctxt)
+{
+	int rc;
+	ulong linear;
+	u64 new[2] = {
+		reg_read(ctxt, VCPU_REGS_RBX),
+		reg_read(ctxt, VCPU_REGS_RCX)
+	};
+	u64 old[2] = {
+		reg_read(ctxt, VCPU_REGS_RAX),
+		reg_read(ctxt, VCPU_REGS_RDX)
+	};
 
+	/* disable writeback altogether */
+	ctxt->d |= NoWrite;
+
+	rc = linearize(ctxt, ctxt->dst.addr.mem, 16, true, &linear);
+	if (rc != X86EMUL_CONTINUE)
 		return rc;
+
+	if (linear % 16)
+		return emulate_gp(ctxt, 0);
+
+	rc = ctxt->ops->cmpxchg_emulated(ctxt, linear, old, new,
+					 16, &ctxt->exception);
+
+	switch (rc) {
+	case X86EMUL_CONTINUE:
+		ctxt->eflags |= X86_EFLAGS_ZF;
+		break;
+	case X86EMUL_CMPXCHG_FAILED:
+		*reg_write(ctxt, VCPU_REGS_RAX) = old[0];
+		*reg_write(ctxt, VCPU_REGS_RDX) = old[1];
+
+		ctxt->eflags &= ~X86_EFLAGS_ZF;
+
+		rc = X86EMUL_CONTINUE;
+		break;
+	}
+
+	return rc;
+}
+#else
+static int em_cmpxchg16b_locked(struct x86_emulate_ctxt *ctxt)
+{
+	return X86EMUL_UNHANDLEABLE;
+}
+#endif
+
+static int em_cmpxchg8_16b(struct x86_emulate_ctxt *ctxt)
+{
+	u64 old;
+
+	if (ctxt->lock_prefix) {
+		if (ctxt->dst.bytes == 8)
+			return em_cmpxchg8b_locked(ctxt);
+		else if (ctxt->dst.bytes == 16)
+			return em_cmpxchg16b_locked(ctxt);
+		return X86EMUL_UNHANDLEABLE;
 	}
 
 	old = ctxt->dst.orig_val64;
@@ -4679,7 +4736,7 @@ static const struct gprefix pfx_0f_c7_7 = {
 
 
 static const struct group_dual group9 = { {
-	N, I(DstMem64 | Lock | PageTable, em_cmpxchg8b), N, N, N, N, N, N,
+	N, I(DstMem64 | Lock | PageTable, em_cmpxchg8_16b), N, N, N, N, N, N,
 }, {
 	N, N, N, N, N, N, N,
 	GP(0, &pfx_0f_c7_7),
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 346ce6c5887b..0e904782d303 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -5665,8 +5665,17 @@ static int emulator_cmpxchg_emulated(struct x86_emulate_ctxt *ctxt,
 	char *kaddr;
 	bool exchanged = false;
 
-	/* guests cmpxchg8b have to be emulated atomically */
-	if (bytes > 8 || (bytes & (bytes - 1)))
+#ifdef CONFIG_X86_64
+#define CMPXCHG_MAX_BYTES 16
+#else
+#define CMPXCHG_MAX_BYTES 8
+#endif
+
+	/* guests cmpxchg{8,16}b have to be emulated atomically */
+	if (bytes > CMPXCHG_MAX_BYTES || (bytes & (bytes - 1)))
+		goto emul_write;
+
+	if (bytes == 16 && !system_has_cmpxchg_double())
 		goto emul_write;
 
 	gpa = kvm_mmu_gva_to_gpa_write(vcpu, addr, NULL);
@@ -5724,6 +5733,30 @@ static int emulator_cmpxchg_emulated(struct x86_emulate_ctxt *ctxt,
 			*((u64 *)old) = val;
 		break;
 	}
+#ifdef CONFIG_X86_64
+	case 16: {
+		u64 *p1 = (u64 *)kaddr;
+		u64 *p2 = p1 + 1;
+		u64 *o1 = old;
+		u64 *o2 = o1 + 1;
+		const u64 *n1 = new;
+		const u64 *n2 = n1 + 1;
+		const u64 __o1 = *o1;
+		const u64 __o2 = *o2;
+
+		/*
+		 * We use an explicit asm statement because cmpxchg_double()
+		 * does not return the previous memory contents on failure
+		 */
+		asm volatile ("lock cmpxchg16b %2\n"
+			      : "+a"(*o1), "+d"(*o2), "+m"(*p1), "+m"(*p2)
+			      : "b"(*n1), "c"(*n2) : "memory");
+
+		if (__o1 == *o1 && __o2 == *o2)
+			exchanged = true;
+		break;
+	}
+#endif
 	default:
 		BUG();
 	}

