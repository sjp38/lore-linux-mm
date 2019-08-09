Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 947B9C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 216D72086A
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 216D72086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 558326B02A9; Fri,  9 Aug 2019 12:01:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 355326B02AF; Fri,  9 Aug 2019 12:01:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 106AD6B02AC; Fri,  9 Aug 2019 12:01:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id B45766B02AA
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:42 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id i6so46680311wre.1
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=z8ovcsAlXVdT6OIMczphTWF/Lfgm3hyIOp51cnmenDo=;
        b=N0roR+IEj8f6jpmxItc7opNVR1AXPXa7IAYtM94j3a/iOWAyQ/9poj6FC4sYgJerpb
         gjk7KOnWw2n31VitETtLb5wWsoPUYS4IkeJcKsvYoHK8c+KY4lR7t0QrQWk9LOMNFuYX
         x7ifKS3ti0OdS1GnRvDkHHJWtmxvDSjAxo+zH6rVAt5Y47/IboyGsRQIj8T/lB6Pwz/F
         08JF4iAi5iqfXeW3Yhbasxrc3wfesOm6DEMPMjAQgcIhN/wxl3LfhP9PV8gILlD211KD
         rYUHY+xNR/y8REffh21fE7I6jdL4kOfB4AhCWhI49NTWhG08vDRckV7YKoFSr/Ceen0g
         mwyw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAWv4AeN6h4uk61Juz+1V08w+sCV9BQyFarnutQFiAYZFlqIjeSA
	fTrIM5cfCM40+b3QiMmgymT7I/YWML5DNSHr7QCaQJcZH1WKKEf4Qr0x4HCMYjZDr6RgV6MgwDD
	jXgfDw8FFij2r4EMwZAebE9GinPqoM+odiZPV0MFlqc6q5Ntz6wMFmSr+0/F76Vj5/g==
X-Received: by 2002:adf:fc0c:: with SMTP id i12mr23002217wrr.86.1565366502332;
        Fri, 09 Aug 2019 09:01:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRj01vTzB0jmulELnVdmpwip1M/o3YQjsWv22vC/AeuklvUg6/qtUwEP57NemkqTQR3vDD
X-Received: by 2002:adf:fc0c:: with SMTP id i12mr23002136wrr.86.1565366501501;
        Fri, 09 Aug 2019 09:01:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366501; cv=none;
        d=google.com; s=arc-20160816;
        b=WNM7uWB0ekN3HN/uKegTVX3h+hkyhGGbAwIrpPOXtsIHU4cDAeR/tNcvJX5M4a5pWM
         sZFUp+P3Gniqeih9XuQigqUPNzX01MGLjapPXrnPNI5nfF0QvMVIoPUtYgtc1lDbbrT9
         DDOPzfKR0uTfJq2+c7lggKSiL5yL6LCaC15dM8/QsmpqNxtVl2zkDqU0H0KdcMY32Zvk
         XdtlJ6rdyBDvlWUb5+7ZgkIpv1I1rh7601BlC4n4JxnjzwUMrd388LPYBJ7Z2F0l/vd7
         bgZyvteYipo/nhqJ9b/5rSWfyXEu4ng5bT83tFJHITvNNgKFcpnfVRyX6oqZx/Zg1lIo
         362w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=z8ovcsAlXVdT6OIMczphTWF/Lfgm3hyIOp51cnmenDo=;
        b=wtCFfrD8v1ljmB9TUNHR1CESUcyRedQxq+OpbnyjRGXvu5vqcQ8xg9AKJCYYY3BzKs
         5tQSNvxHZ19UggYiQ0STbrqjX8MASk5wAnp5HLIMIdWd3O0oi+xXXxtcV7C5rCIdY0VF
         ZfifyAMIU27t0HddigGIJQhd6eP2zkkSxiygSLjgp+5gvukV7oy3ES+zKhin5rn/I7lP
         GdyfOCFrspRssd6WawmilLh/IOx4yfmWpSI4L2IH+b0k93QVgMGwd0+fAPR90wRxSS3y
         ZgwvYpOSOcLfVH8S7XpYZJnghDm+tB5gxv+0yVe7ZHt2zqatebazp3+/25aaluxgViBn
         yK9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id w8si1988950wmm.53.2019.08.09.09.01.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id E7B5A3031EC8;
	Fri,  9 Aug 2019 19:01:40 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 80AB8305B7A0;
	Fri,  9 Aug 2019 19:01:40 +0300 (EEST)
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
Subject: [RFC PATCH v6 82/92] kvm: x86: emulate movq r, xmm
Date: Fri,  9 Aug 2019 19:00:37 +0300
Message-Id: <20190809160047.8319-83-alazar@bitdefender.com>
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

This adds support for movq r, xmm. It introduces a new flag (GPRModRM)
to indicate decode_modrm() that the encoded register is a general purpose
one.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/emulate.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kvm/emulate.c b/arch/x86/kvm/emulate.c
index 2297955d0934..7c79504e58cd 100644
--- a/arch/x86/kvm/emulate.c
+++ b/arch/x86/kvm/emulate.c
@@ -172,6 +172,7 @@
 #define NoMod	    ((u64)1 << 47)  /* Mod field is ignored */
 #define Intercept   ((u64)1 << 48)  /* Has valid intercept field */
 #define CheckPerm   ((u64)1 << 49)  /* Has valid check_perm field */
+#define GPRModRM    ((u64)1 << 50)  /* The ModRM encoded register is a GP one */
 #define PrivUD      ((u64)1 << 51)  /* #UD instead of #GP on CPL > 0 */
 #define NearBranch  ((u64)1 << 52)  /* Near branches */
 #define No16	    ((u64)1 << 53)  /* No 16 bit operand */
@@ -1197,6 +1198,11 @@ static u8 simd_prefix_to_bytes(const struct x86_emulate_ctxt *ctxt,
 		if (simd_prefix == 0x66)
 			bytes = 8;
 		break;
+	case 0x6e:
+		/* movq r/m64, xmm */
+		if (simd_prefix == 0x66)
+			bytes = 8;
+		break;
 	default:
 		break;
 	}
@@ -1262,7 +1268,7 @@ static int decode_modrm(struct x86_emulate_ctxt *ctxt,
 		op->bytes = (ctxt->d & ByteOp) ? 1 : ctxt->op_bytes;
 		op->addr.reg = decode_register(ctxt, ctxt->modrm_rm,
 				ctxt->d & ByteOp);
-		if (ctxt->d & Sse) {
+		if ((ctxt->d & Sse) && !(ctxt->d & GPRModRM)) {
 			op->type = OP_XMM;
 			op->bytes = ctxt->op_bytes;
 			op->addr.xmm = ctxt->modrm_rm;
@@ -4546,6 +4552,10 @@ static const struct gprefix pfx_0f_6f_0f_7f = {
 	I(Mmx, em_mov), I(Sse | Aligned, em_mov), N, I(Sse | Unaligned, em_mov),
 };
 
+static const struct gprefix pfx_0f_6e_0f_7e = {
+	N, I(Sse, em_mov), N, N
+};
+
 static const struct instr_dual instr_dual_0f_2b = {
 	I(0, em_mov), N
 };
@@ -4807,7 +4817,8 @@ static const struct opcode twobyte_table[256] = {
 	N, N, N, N,
 	N, N, N, N,
 	N, N, N, N,
-	N, N, N, GP(SrcMem | DstReg | ModRM | Mov, &pfx_0f_6f_0f_7f),
+	N, N, GP(SrcMem | DstReg | ModRM | GPRModRM | Mov, &pfx_0f_6e_0f_7e),
+	GP(SrcMem | DstReg | ModRM | Mov, &pfx_0f_6f_0f_7f),
 	/* 0x70 - 0x7F */
 	N, N, N, N,
 	N, N, N, N,

