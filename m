Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8BF9C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94000214C6
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94000214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BC4F6B02F1; Fri,  9 Aug 2019 12:03:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 770DE6B02F3; Fri,  9 Aug 2019 12:03:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 685736B02F4; Fri,  9 Aug 2019 12:03:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1D2C86B02F1
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:03:30 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id r4so47053112wrt.13
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:03:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=HO44UFHxKlBoiYBrbotP/lUY1FQi770to4wdeUgIqQM=;
        b=dVzMrnsr0CE1mLITJLTkXiA5VN+wjTOZRWJMcyslbmqHQ0icgEtRiG0JQYzL+0NRPx
         1gIevv+lREpNwSh3YFLU/Meuzu/OyX+Rd/ldJpr1IgS8dssnQ56FY/OHiSeg3l7sHLao
         Zyzoj4GajROoNoCadvvXB2vrKJiLDEThUQCWQA3ZnqWVRvzzpnzL/hpHU23MmJQEYdJz
         YWjrfmCY5O5pcAOw9RVkEJp2u1fE5d98W1GZKOr9p1jqM9qqNmYoJbMBDDJgnGqkJlNl
         sr1YpMeaT8JeHgNJdIR+9C4XECERrZY3nU/tcr7gpBAAr01XaZAsm6Sv8n3/RpjgWkXk
         iC5Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAU3qZqlop/Gy0JLAVNQwZUxA3npMet88fhgmVSLMFkPdILUgJhz
	tRZWhkRa4B2UNwuyD3zmnfW/sJEQd7cAXEfOAtYmeax04qm/1JJPf2q+Gs+rYuwYaUZ03WzYvB5
	QVNdpVdSbtSgBnCZ2LkKrWzjHXf7uGZalUeRoV/LE8Sm2UNbRb8xhxbkbRB2C3VREqw==
X-Received: by 2002:a1c:9d53:: with SMTP id g80mr11857118wme.103.1565366609610;
        Fri, 09 Aug 2019 09:03:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHgOsyOIUPPItSOg5dpkgdlkhW3TOxos3wMRSgWw+vYtkTMjJ7ZtK3LdbcgRm8ZaDOY5yH
X-Received: by 2002:a1c:9d53:: with SMTP id g80mr11846390wme.103.1565366500797;
        Fri, 09 Aug 2019 09:01:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366500; cv=none;
        d=google.com; s=arc-20160816;
        b=y0uPYdUp9+i9Jr0McIqrr5yHP3AolpTWT97sAaUBYLM0O5GoOqx1CEuAElod5C4gB1
         4QGNVvSNWqjM5uDbAh350MMQAqp01zyZ0iiMR1hTVQfr2kxp7zqOx2x5KgLs2ZcOI2xB
         LgpSFyMFDdx566APy6N109Kgqhgq72Bt/8xl+XAInD1KXiPY4Xv/GRzVhurcEfG1z+eQ
         lGZdKb8idIbtWCpvdKCuomGlsY5PI/SbiO8uv4QNWPl+Udt0mRluqawByO2DbhTjtOPA
         USeNaKnMIuxrtLJl31OM01lHYeb1WHLge8xtHto3HH+/NEESQ1BE57SdFGxGuzWE6CgJ
         dVSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=HO44UFHxKlBoiYBrbotP/lUY1FQi770to4wdeUgIqQM=;
        b=NpJAUd5SmyjxJlcjRu5BIvBAEIyBVxIRGpkZPCcaO+Yu7X5vRycj4Gt1jzTvAOnqaR
         a3zSg50BqYIOhudk4jWRInrZxoF+5cWl29ZbQS+UDukBiZDYQYmHXmJubxs0iIgrKkda
         Sshq6FC7BamphztspYlDcZOSOSAoFch9NoQGBJ4fm8WRBahTq/aRemFIj3OBMv3IBWdT
         gZZiWiFj+LrWQbRSrEt1HdiOfodcroY6dOuL2jrsrOayRx7chPBG9xXVBXG+HLHIQpfd
         X5GKI0dhUEh2ZbVJ5WvNJFVlnEAMwftFE6kn366NJ6FWE8DJ4jj+wBCsJ5vWiU2DWFKC
         rUxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id t4si4057746wmt.14.2019.08.09.09.01.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 3B133305D362;
	Fri,  9 Aug 2019 19:01:40 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id D678C305B7A0;
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
Subject: [RFC PATCH v6 80/92] kvm: x86: emulate movss xmm, m32
Date: Fri,  9 Aug 2019 19:00:35 +0300
Message-Id: <20190809160047.8319-81-alazar@bitdefender.com>
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

This is needed in order to be able to support guest code that uses movss to
write into pages that are marked for write tracking.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/emulate.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kvm/emulate.c b/arch/x86/kvm/emulate.c
index 9d38f892beea..b8a412b8b087 100644
--- a/arch/x86/kvm/emulate.c
+++ b/arch/x86/kvm/emulate.c
@@ -1184,9 +1184,13 @@ static u8 simd_prefix_to_bytes(const struct x86_emulate_ctxt *ctxt,
 
 	switch (ctxt->b) {
 	case 0x11:
+		/* movss xmm, m32 */
 		/* movsd xmm, m64 */
 		/* movups xmm, m128 */
-		if (simd_prefix == 0xf2) {
+		if (simd_prefix == 0xf3) {
+			bytes = 4;
+			break;
+		} else if (simd_prefix == 0xf2) {
 			bytes = 8;
 			break;
 		}
@@ -4550,7 +4554,7 @@ static const struct gprefix pfx_0f_2b = {
 };
 
 static const struct gprefix pfx_0f_10_0f_11 = {
-	I(Unaligned, em_mov), I(Unaligned, em_mov), I(Unaligned, em_mov), N,
+	I(Unaligned, em_mov), I(Unaligned, em_mov), I(Unaligned, em_mov), I(Unaligned, em_mov),
 };
 
 static const struct gprefix pfx_0f_28_0f_29 = {

