Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56221C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F27A52086A
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F27A52086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54D026B02AF; Fri,  9 Aug 2019 12:01:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FEA66B02B3; Fri,  9 Aug 2019 12:01:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C56F6B02B2; Fri,  9 Aug 2019 12:01:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id D88BA6B02AF
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:44 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id i6so46680351wre.1
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0y5T/KtFvjha8EpytqyLOmVKWB5iST0JVaO4kJcgwzI=;
        b=YdI4eRgo22kbFBT0ywfwV5g5UCv3Drm0Zssvs6gOK6dAMTQ0Sc4I9laGSRqQN5yUJg
         alqm7flqv3C1WBpunr6k8sLadanGUrLHjWqH4gwCTGfpMd60Satb8zI9+Ko3p86Jp3Ec
         UIPS42F1k5BqFMOOkm1kPUj99HmtOiyONU5GpcRaX/EtNxud0fEfpEDR6+gO+TosPMOi
         Ui2CcHvIyE8SG7lEUixk1mhHnA05VPcaMsjcHUm3R5oDy+Ry2B4GbxRP/5K8KC2e9QSh
         SeDknwlWlOOQ2ZMOYq9uRqdwHiRdxm+eBoxg/tkvj/fu65rke/IhDAWyED1Sh1twF9Cm
         jnzA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAXPweXXnkUs5tYb+AQcYLSk6bwfUcKgwWPcAbws95EwkRhgJUGs
	UjA0tPUng1tLkseA7uvOsPblN5DuFz3g0H3ccQzySBEoz0PIWeIALbFx7n70eEfzKK3ZWQKiCkZ
	LlisUK1+6aDuv2MuWmLxEeDORpBCRT3qyjXNrlx1959WGsY3DsMLevb1ufpaTOTPeQQ==
X-Received: by 2002:a5d:62c1:: with SMTP id o1mr24730804wrv.293.1565366504478;
        Fri, 09 Aug 2019 09:01:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkG1p7wueWsYVf3x2azWq5seYnefu86tPYGuJg3eyRPA9VdNbyWZu1F+YfF7SLvmzttCTR
X-Received: by 2002:a5d:62c1:: with SMTP id o1mr24730410wrv.293.1565366500491;
        Fri, 09 Aug 2019 09:01:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366500; cv=none;
        d=google.com; s=arc-20160816;
        b=LGBv5aeyhKP25IM+GRjsDAD272/qaWwjJakmy2LADrzfLvVKmPED+u3+1KXILlqvA6
         EwRhGXxQ5QpIMwzaqGlo0h+c98Jtqx3AX4fBGDhFDqYswzxY/YKdFs+vJYAhgEEf1e3K
         AtkLeN/jvWQgfmc8LJSR5+4aL7sU6DrWbPyWtbOvvvVrEwB2u6y/k4RkmNKu/DMZjkNc
         w89FtCcZ0K1Or1ZHW+y7Jr3WodWDm9/KrLr/mtvvzzlw6lwpYTmVtXmqm2KbM21d6n6l
         RYEUM3P/VsPH+y5gomw+AIwY+x5b3CLM193XAjy97ulloxURs+JrbZNEPiqdf/xwUTMz
         P09Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=0y5T/KtFvjha8EpytqyLOmVKWB5iST0JVaO4kJcgwzI=;
        b=fs9YqTUXBbxoTRxmyZuJRFkf32tOjB5o8ay/58vKqgSn4DXVsKwSUzzhljhcU3WF06
         ++vVPgjwZ+ji0RfzFk0haZ6pXc81hUUFCkPGESgDbVDzKt6g6EGwJpTIqEc52SyFohNb
         QyNOB2aq9DCJ3j+074G6p5IB3Yly2iTKv03GzjbzC7rsMzzmJ0EdL80gbivwgjEzbEDb
         gBfMzT23l6KPjhM89iktXwyxQBcNMu66btch2eDPj7GYSE+JrZZT1OZ9luJ8odQ1F92z
         x3suosqoZko03mINMWVYRA8+QWGsw6UYkuTEhgjug1zJb5WyL5CJgbfgG8hdkJrwOu+q
         +lVA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id g6si1520316wmk.121.2019.08.09.09.01.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id DABFE305D361;
	Fri,  9 Aug 2019 19:01:39 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 8EF59305B7A3;
	Fri,  9 Aug 2019 19:01:39 +0300 (EEST)
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
Subject: [RFC PATCH v6 79/92] kvm: x86: emulate movsd xmm, m64
Date: Fri,  9 Aug 2019 19:00:34 +0300
Message-Id: <20190809160047.8319-80-alazar@bitdefender.com>
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

This is needed in order to be able to support guest code that uses movsd to
write into pages that are marked for write tracking.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/emulate.c | 32 +++++++++++++++++++++++++++-----
 1 file changed, 27 insertions(+), 5 deletions(-)

diff --git a/arch/x86/kvm/emulate.c b/arch/x86/kvm/emulate.c
index 34431cf31f74..9d38f892beea 100644
--- a/arch/x86/kvm/emulate.c
+++ b/arch/x86/kvm/emulate.c
@@ -1177,6 +1177,27 @@ static int em_fnstsw(struct x86_emulate_ctxt *ctxt)
 	return X86EMUL_CONTINUE;
 }
 
+static u8 simd_prefix_to_bytes(const struct x86_emulate_ctxt *ctxt,
+			       int simd_prefix)
+{
+	u8 bytes;
+
+	switch (ctxt->b) {
+	case 0x11:
+		/* movsd xmm, m64 */
+		/* movups xmm, m128 */
+		if (simd_prefix == 0xf2) {
+			bytes = 8;
+			break;
+		}
+		/* fallthrough */
+	default:
+		bytes = 16;
+		break;
+	}
+	return bytes;
+}
+
 static void decode_register_operand(struct x86_emulate_ctxt *ctxt,
 				    struct operand *op)
 {
@@ -1187,7 +1208,7 @@ static void decode_register_operand(struct x86_emulate_ctxt *ctxt,
 
 	if (ctxt->d & Sse) {
 		op->type = OP_XMM;
-		op->bytes = 16;
+		op->bytes = ctxt->op_bytes;
 		op->addr.xmm = reg;
 		read_sse_reg(ctxt, &op->vec_val, reg);
 		return;
@@ -1238,7 +1259,7 @@ static int decode_modrm(struct x86_emulate_ctxt *ctxt,
 				ctxt->d & ByteOp);
 		if (ctxt->d & Sse) {
 			op->type = OP_XMM;
-			op->bytes = 16;
+			op->bytes = ctxt->op_bytes;
 			op->addr.xmm = ctxt->modrm_rm;
 			read_sse_reg(ctxt, &op->vec_val, ctxt->modrm_rm);
 			return rc;
@@ -4529,7 +4550,7 @@ static const struct gprefix pfx_0f_2b = {
 };
 
 static const struct gprefix pfx_0f_10_0f_11 = {
-	I(Unaligned, em_mov), I(Unaligned, em_mov), N, N,
+	I(Unaligned, em_mov), I(Unaligned, em_mov), I(Unaligned, em_mov), N,
 };
 
 static const struct gprefix pfx_0f_28_0f_29 = {
@@ -5097,7 +5118,7 @@ int x86_decode_insn(struct x86_emulate_ctxt *ctxt, void *insn, int insn_len)
 {
 	int rc = X86EMUL_CONTINUE;
 	int mode = ctxt->mode;
-	int def_op_bytes, def_ad_bytes, goffset, simd_prefix;
+	int def_op_bytes, def_ad_bytes, goffset, simd_prefix = 0;
 	bool op_prefix = false;
 	bool has_seg_override = false;
 	struct opcode opcode;
@@ -5320,7 +5341,8 @@ int x86_decode_insn(struct x86_emulate_ctxt *ctxt, void *insn, int insn_len)
 			ctxt->op_bytes = 4;
 
 		if (ctxt->d & Sse)
-			ctxt->op_bytes = 16;
+			ctxt->op_bytes = simd_prefix_to_bytes(ctxt,
+							      simd_prefix);
 		else if (ctxt->d & Mmx)
 			ctxt->op_bytes = 8;
 	}

