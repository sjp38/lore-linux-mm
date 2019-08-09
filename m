Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E193C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7D482086A
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7D482086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE2EC6B02B1; Fri,  9 Aug 2019 12:01:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B42056B02B4; Fri,  9 Aug 2019 12:01:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E0E66B02B3; Fri,  9 Aug 2019 12:01:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4B3816B02B1
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:45 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id d64so600577wmc.7
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9N7Mja8uDexYvI5YrbFWn+IpXGfOWoBTjKWijqUbG90=;
        b=fI2bajWaAGiWwfFFxbqDAujdQOESuhU1Rv8trEDpOPRt5YLsSEY5w5ObxtP2DZ3i0u
         RFYqqFPs9yKpJgzlzBCIEsBJOBFgzB9rBdzu1h/MqwpRKOpyQgoggALHUzdAN8l3umXR
         1VX1seL8VGKRkCgTWa85jcwmbE6TsoPt61I9VpIPMYB4TURe0gLCSdPI44PJbai6E1vj
         odxbXp8IPNPaX8IVZxBRy4bZ+8TahSZybXvlIRuVwP8LlytAn2CY+YY+EmVjaUNhA0nd
         SRNMh51zhJO+EUFeReXU6JVF5WOegcbB3BWLk+5av7FELhWhJYDB88lZNs156Y+pgh9c
         3Vtw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAUh/QUWws8GxqBciPmyuBYjK6NKWx6UL3aFTalGA4nHMrrPVOto
	7qCf2xGFNfVuV0WZkSXMx5apWRfO6vFrle8NreFeKIQ7wpxWQYLEJ7Pkxcx0QWnNaGBNJgFC5cL
	/SrQXaCFpErZ0bejCFst0ReizAS+kAlYGkqaOj35dlVqwQIYwBN+JYMbXlI3NE1RjxQ==
X-Received: by 2002:a1c:6c0d:: with SMTP id h13mr10814766wmc.74.1565366504904;
        Fri, 09 Aug 2019 09:01:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyHeG+BcjmMeZelkltH29Ul/M1iBA24f4z1WFCDUdt8bQDJAqgl+JroA1CfhcMRJ/oFUPM
X-Received: by 2002:a1c:6c0d:: with SMTP id h13mr10814683wmc.74.1565366503961;
        Fri, 09 Aug 2019 09:01:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366503; cv=none;
        d=google.com; s=arc-20160816;
        b=DQAZHWHk0JMH9ePGW5XdW+rFQfSOh0gpp41+mckuD/8YH6Qw4FwPmGLL5G6kz7+Mmp
         orhy62FyyjCxVqfDMrEtX3UJAHGB8nV235BnEXjTcrGdFct6zKWMl29I9QdrnEVJtt50
         L57p4bJ+iTpw7/ntW6ZtJxz1+nz3hw8npUgnfyWNgISUtHriDFhBv/5QzeeQrZKCNClC
         rRp3QLCCZCY+9F1cgq5ypA2Egev88icWJq2wSRmItxvhImw+2QEY7nlW3do0RJl2UXyL
         gN/BGd9rNqu4gMBzjFnZqc3B/xrksa65OinWzGnApxfLeWM1TqS5J5/xVq8QBK7b5qnm
         l/+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=9N7Mja8uDexYvI5YrbFWn+IpXGfOWoBTjKWijqUbG90=;
        b=QGNN4pMdVJX9snPBMreI6x1nyewduLRCLBtFpxvJ1WkX2j+cNFgpTHeVIwYvcKHzsk
         1LC26IRWMdmLQSgnM8myntkUydfZq+I51t+2aaVFXTOCnFBYn+fw5HagBtMhy5i7pwdU
         h1eaQYaTfoIl8z1tmoMQgIapFZJbk6s0jpKnaAZpeSjn+krGip7q+1a/uij3JnzKHytC
         txojW6O6tXXAfhJLwIZ8Bg6+h4V9DjkGzH5ZOAd56QE0b0oXgueQUCMX7F7+kCz8NFRu
         7Q2iiu48KcQ/UzVZvdBxKt9JXbG7u4wj0muzua4epX9fNkp5ILIZX4WkXG7oCLIhihGD
         mvrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id x21si4114906wmk.149.2019.08.09.09.01.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 3CAC9305D366;
	Fri,  9 Aug 2019 19:01:43 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id A9FD4305B7A4;
	Fri,  9 Aug 2019 19:01:42 +0300 (EEST)
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
Subject: [RFC PATCH v6 87/92] kvm: x86: emulate xorps xmm/m128, xmm
Date: Fri,  9 Aug 2019 19:00:42 +0300
Message-Id: <20190809160047.8319-88-alazar@bitdefender.com>
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

This extends the previous xorpd by creating a dedicated group, something
I should have done since the very beginning.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/emulate.c | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kvm/emulate.c b/arch/x86/kvm/emulate.c
index 28aac552b34b..14895c043edc 100644
--- a/arch/x86/kvm/emulate.c
+++ b/arch/x86/kvm/emulate.c
@@ -1178,6 +1178,22 @@ static int em_fnstsw(struct x86_emulate_ctxt *ctxt)
 	return X86EMUL_CONTINUE;
 }
 
+static int em_xorps(struct x86_emulate_ctxt *ctxt)
+{
+	const sse128_t *src = &ctxt->src.vec_val;
+	sse128_t *dst = &ctxt->dst.vec_val;
+	sse128_t xmm0;
+
+	asm volatile("movdqu %%xmm0, %0\n"
+		     "movdqu %1, %%xmm0\n"
+		     "xorps %2, %%xmm0\n"
+		     "movdqu %%xmm0, %1\n"
+		     "movdqu %0, %%xmm0"
+		     : "+m"(xmm0), "+m"(*dst) : "m"(*src));
+
+	return X86EMUL_CONTINUE;
+}
+
 static int em_xorpd(struct x86_emulate_ctxt *ctxt)
 {
 	const sse128_t *src = &ctxt->src.vec_val;
@@ -4615,6 +4631,10 @@ static const struct gprefix pfx_0f_e7 = {
 	N, I(Sse, em_mov), N, N,
 };
 
+static const struct gprefix pfx_0f_57 = {
+	I(Unaligned, em_xorps), I(Unaligned, em_xorpd), N, N
+};
+
 static const struct escape escape_d9 = { {
 	N, N, N, N, N, N, N, I(DstMem16 | Mov, em_fnstcw),
 }, {
@@ -4847,7 +4867,7 @@ static const struct opcode twobyte_table[256] = {
 	/* 0x40 - 0x4F */
 	X16(D(DstReg | SrcMem | ModRM)),
 	/* 0x50 - 0x5F */
-	N, N, N, N, N, N, N, I(SrcMem | DstReg | ModRM | Unaligned | Sse, em_xorpd),
+	N, N, N, N, N, N, N, GP(SrcMem | DstReg | ModRM | Sse, &pfx_0f_57),
 	N, N, N, N, N, N, N, N,
 	/* 0x60 - 0x6F */
 	N, N, N, N,

