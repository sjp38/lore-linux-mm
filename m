Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D292C32756
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4ACFB2171F
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4ACFB2171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 773446B02B4; Fri,  9 Aug 2019 12:01:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D5056B02B8; Fri,  9 Aug 2019 12:01:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FE906B02B7; Fri,  9 Aug 2019 12:01:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 033816B02B4
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:47 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id t9so47062594wrx.9
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LVuRx0Nc4HKRTd+zezhe5UyDEYQSxcD/Lrw8+WPQ8ac=;
        b=GVn10vQivfvSHVnVujZzMuhS0pJK7nP7Lpm0Cv/Dci1uTRnmV+2NKRC96nmQgOGqPY
         Q/Pjas87Q01iPwV3qWzeiEsCgh1ftBK0nQOyA0vqKwsaxf7KItjX+oPN9lJ7sziKGeML
         y5bX8ki5DL9imP7hWUnRTGuJzeinteH1P6Rw0nvwt4aJt1CUDNtqhJsGB130pWhrMW/6
         7HghXSrBCePlVV7fNsLwuv151sVqwElDdVmBpAnVjtZBoSofM/WZRwaqUPpdtUcdZQmu
         dwjDVjAOQVOZZ6+WLHkzLswJstS1pqNoypKkq2eQkKyzC56QohG0ypcYRY0pzaN59RhH
         uKwg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAXOLhy+edxVHIhzfs7L2asWrJ5n0BWM4LQctSIYdGBFFsEvP+bS
	fY8qL47SHA7SIfyXOr3/R6r7W2Y8bntpllXbH3Ps7WXM8SOKJE9c6Ga9YCno9zJYRR8gFCVCIQI
	7364TckakbVWp52BZua3Hg/bCRjDU3dHfVTim5R8iEa6Q1TrjxTNoLzao6PqZVo/0jg==
X-Received: by 2002:a1c:be19:: with SMTP id o25mr11247980wmf.54.1565366506615;
        Fri, 09 Aug 2019 09:01:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLNBjrrn45zfnbSmgOvU1c1UwDGIF4wGMHkCCWKY0MEhlD1fs4sfJg7TuJHF/xaXzY5TJv
X-Received: by 2002:a1c:be19:: with SMTP id o25mr11247674wmf.54.1565366503273;
        Fri, 09 Aug 2019 09:01:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366503; cv=none;
        d=google.com; s=arc-20160816;
        b=y5V/I+6ClurtniH+0yzUrAWScziiG7q/G7Vem6awFbP/SWlxBN0z7AgRH1DfpSPaio
         JfPJ8XV7UoHNlQmWYwQwjU32/Sj5ZTpY/ZOJGZ+/b1k8IPOBJp/LoRPzgpDysif7ghX4
         ulbvr9N/99BbieDa0304z2HBf/cmaq5xo4oXcJbNz/xZ/ZFotBGTUswUw4/P92+YuYnh
         NOQ6gAzsQTD6CeW4CQRsFF0+gFZnqD4vtrsqy64B2RXxiV1FVQm16iv0IOT4fGnhb+Od
         xspd9k+Da7BHJ450bJW2luwBE1/5/D2ZG0+X036nQ5x78FbHZID09doCy4F+ZCj8uMHb
         Zetg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=LVuRx0Nc4HKRTd+zezhe5UyDEYQSxcD/Lrw8+WPQ8ac=;
        b=h1WPH8MULKL+aHqeMBiRGu/p1BWb9mWG6wgL+KUVvxG4GZSyYMNd30C/y/xJRT7+2T
         H4MjhL4EKtKD1xqH8ig7OFpQRUKdazdKWcuhc42G0WrPQLgCzmntlKO6rwVEC6nhdrPR
         YmutRfXz7m5wMWbfAhp/yOfa0RRuvrM3GEOgtDU51qJQ6M1Bg2yIEtOccpNUATY1PieY
         uckFv3r8NL6D3SUVHggCIO92/xGtvxyLT73TKTr3C4RLhL36L2ZgJw1AGQW3qA2rH+WO
         FM3Ou97cOOrO6Oxj7aBQIJXjOeBnOFE76cBEl2hTQmYakIeNkL19Imb96eAM+8RPtv89
         EEJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id e17si3381013wrs.340.2019.08.09.09.01.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id AF514305D365;
	Fri,  9 Aug 2019 19:01:42 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id A83CA305B7A3;
	Fri,  9 Aug 2019 19:01:41 +0300 (EEST)
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
Subject: [RFC PATCH v6 86/92] kvm: x86: emulate xorpd xmm2/m128, xmm1
Date: Fri,  9 Aug 2019 19:00:41 +0300
Message-Id: <20190809160047.8319-87-alazar@bitdefender.com>
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

This adds support for xorpd xmm2/m128, xmm1.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/emulate.c | 19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kvm/emulate.c b/arch/x86/kvm/emulate.c
index 287d3751675d..28aac552b34b 100644
--- a/arch/x86/kvm/emulate.c
+++ b/arch/x86/kvm/emulate.c
@@ -1178,6 +1178,22 @@ static int em_fnstsw(struct x86_emulate_ctxt *ctxt)
 	return X86EMUL_CONTINUE;
 }
 
+static int em_xorpd(struct x86_emulate_ctxt *ctxt)
+{
+	const sse128_t *src = &ctxt->src.vec_val;
+	sse128_t *dst = &ctxt->dst.vec_val;
+	sse128_t xmm0;
+
+	asm volatile("movdqu %%xmm0, %0\n"
+		     "movdqu %1, %%xmm0\n"
+		     "xorpd %2, %%xmm0\n"
+		     "movdqu %%xmm0, %1\n"
+		     "movdqu %0, %%xmm0"
+		     : "+m"(xmm0), "+m"(*dst) : "m"(*src));
+
+	return X86EMUL_CONTINUE;
+}
+
 static u8 simd_prefix_to_bytes(const struct x86_emulate_ctxt *ctxt,
 			       int simd_prefix)
 {
@@ -4831,7 +4847,8 @@ static const struct opcode twobyte_table[256] = {
 	/* 0x40 - 0x4F */
 	X16(D(DstReg | SrcMem | ModRM)),
 	/* 0x50 - 0x5F */
-	N, N, N, N, N, N, N, N, N, N, N, N, N, N, N, N,
+	N, N, N, N, N, N, N, I(SrcMem | DstReg | ModRM | Unaligned | Sse, em_xorpd),
+	N, N, N, N, N, N, N, N,
 	/* 0x60 - 0x6F */
 	N, N, N, N,
 	N, N, N, N,

