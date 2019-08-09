Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB67AC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B76B2089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B76B2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2B1F6B02A7; Fri,  9 Aug 2019 12:01:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB52B6B02AC; Fri,  9 Aug 2019 12:01:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E07B6B02AB; Fri,  9 Aug 2019 12:01:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 51BB36B02A7
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:42 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id i6so46680302wre.1
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+vAIKAMAq+6SS401u5BQ0BNmWDb1K1DgfRNHu9JZ7UM=;
        b=MC6rd5tOc8nZhSadtrq3XqLopGzBrJKsJjFsdOQM93ThCVSmHOINiACtN67Ew/YaNI
         kZJGmPamy+dAYLKVujSSeN6XpUgAxiiJw/8xx2y091UICBJCNbzr1yIT5FZRHZ2gJOfq
         Pl0JYpmeLREoKL3wmo36trw4ODfZJ+zm+8HW7k5Sa2iai9QU5dZaa258AGtXoiquuHen
         fHQDylI+qMqJzrg67fYZqWd8Gc9LgcpRZbybMYgJ+yb7Xb6T5+cV4zszwlJE90S2ZEWO
         sAJZOngAwU6i5/tsHSFbHZp4smIJpU3W9jaBrekPUY4ZKuotokOEX0fnLgYZjKdiI+Z7
         Dv0A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAUn4EckqWBfLXkTQmIptAdaWqnOvAB/WDKj3rhHkKVM8zMHsaob
	40Q6AJfleHD0QpDYjthMf9mmFrzBSPwERRVunLlg4r9sFcEKABbohQmWfyuYmtx9BNohElSxIUx
	JkH26EX27NBdewCJ/HSS/Y4xRC/zCOhQe8mrIiDnCUG1xEpWqlUC0ohL+3eDgSD/3hw==
X-Received: by 2002:a05:6000:10c9:: with SMTP id b9mr11898270wrx.11.1565366501893;
        Fri, 09 Aug 2019 09:01:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBsyX0cgRTpP6db6dL2vyPRbvRg07djWErQ1OZnt48e9y6aG23UcIfPrx5mrzlhefQEg+7
X-Received: by 2002:a05:6000:10c9:: with SMTP id b9mr11898186wrx.11.1565366501100;
        Fri, 09 Aug 2019 09:01:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366501; cv=none;
        d=google.com; s=arc-20160816;
        b=V5xnrAEDkXSYhnbX0bi+LzyetXOjfDdIysDf3Si0pqoP+gjmScJoy2tHyeuBroPDPT
         u6oDuNv+RX0pt28GHalMl6/0ZCmv/I6V1D2TLYtTDFi2udmznMtLOc0DmTjgPFQSKa+5
         F4q5uz9SXodOFlq4bDwkr0clsQspwdRrBWnOHdNsnvBOS+MBmTxR/GS6sZsku2Q4KtFp
         bPfjVomGlGuMk4SwmdfE7uUwbqPV5Bmt0GineL8o4aKppsjUqfXsx5GvfJArHFVjTAni
         LvBvyAIZL9cGHnZ9nUL5/BMehY/mm3lrmqXiWmNsBz7dyDDYYNDrYiyB78f/WAYCOtr+
         NNnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=+vAIKAMAq+6SS401u5BQ0BNmWDb1K1DgfRNHu9JZ7UM=;
        b=PTpMe7sSn6iy+BJ5O9GztDRJgm0wdPnWNP0P1XgQWo7CMOYxvElq4s4kZuVtmDSUG5
         tkMG1dQCYsPtbEIvnoyWizN1S8vayx1w3J45JDeiqx6XHITjxbWnhxME6TdQwoVgQhmT
         YIhhrD144I3FNmjyXpfjMB/OvBxM3jWCVgGJEZFqzn8tGJATKQrcnUTJN0p9NFHhv2o/
         lxWPkbebyJ6ok+VP7QcijYKpnKYKZbvNtctt5yWpUPZr3TFdQ0tbWzHoxyD3Dnu4W/kp
         R9MnP0Z96oerRfdcMfBqDMLBQoAyA2MzBucTSAPKEwji3msEz/rH+Lf0mF00wd+UlrR8
         7/5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id w11si87248346wrm.129.2019.08.09.09.01.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 86D35305D363;
	Fri,  9 Aug 2019 19:01:40 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 2FE9E305B7A1;
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
Subject: [RFC PATCH v6 81/92] kvm: x86: emulate movq xmm, m64
Date: Fri,  9 Aug 2019 19:00:36 +0300
Message-Id: <20190809160047.8319-82-alazar@bitdefender.com>
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

This is needed in order to be able to support guest code that uses movq to
write into pages that are marked for write tracking.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/emulate.c | 24 +++++++++++++++---------
 1 file changed, 15 insertions(+), 9 deletions(-)

diff --git a/arch/x86/kvm/emulate.c b/arch/x86/kvm/emulate.c
index b8a412b8b087..2297955d0934 100644
--- a/arch/x86/kvm/emulate.c
+++ b/arch/x86/kvm/emulate.c
@@ -1180,23 +1180,24 @@ static int em_fnstsw(struct x86_emulate_ctxt *ctxt)
 static u8 simd_prefix_to_bytes(const struct x86_emulate_ctxt *ctxt,
 			       int simd_prefix)
 {
-	u8 bytes;
+	u8 bytes = 16;
 
 	switch (ctxt->b) {
 	case 0x11:
 		/* movss xmm, m32 */
 		/* movsd xmm, m64 */
 		/* movups xmm, m128 */
-		if (simd_prefix == 0xf3) {
+		if (simd_prefix == 0xf3)
 			bytes = 4;
-			break;
-		} else if (simd_prefix == 0xf2) {
+		else if (simd_prefix == 0xf2)
 			bytes = 8;
-			break;
-		}
-		/* fallthrough */
+		break;
+	case 0xd6:
+		/* movq xmm, m64 */
+		if (simd_prefix == 0x66)
+			bytes = 8;
+		break;
 	default:
-		bytes = 16;
 		break;
 	}
 	return bytes;
@@ -4549,6 +4550,10 @@ static const struct instr_dual instr_dual_0f_2b = {
 	I(0, em_mov), N
 };
 
+static const struct gprefix pfx_0f_d6 = {
+	N, I(0, em_mov), N, N,
+};
+
 static const struct gprefix pfx_0f_2b = {
 	ID(0, &instr_dual_0f_2b), ID(0, &instr_dual_0f_2b), N, N,
 };
@@ -4846,7 +4851,8 @@ static const struct opcode twobyte_table[256] = {
 	/* 0xC8 - 0xCF */
 	X8(I(DstReg, em_bswap)),
 	/* 0xD0 - 0xDF */
-	N, N, N, N, N, N, N, N, N, N, N, N, N, N, N, N,
+	N, N, N, N, N, N, GP(ModRM | SrcReg | DstMem | Mov | Sse, &pfx_0f_d6),
+	N, N, N, N, N, N, N, N, N,
 	/* 0xE0 - 0xEF */
 	N, N, N, N, N, N, N, GP(SrcReg | DstMem | ModRM | Mov, &pfx_0f_e7),
 	N, N, N, N, N, N, N, N,

