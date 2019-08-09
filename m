Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70F68C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DA5F2086A
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DA5F2086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87E0F6B02AD; Fri,  9 Aug 2019 12:01:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 796226B02AC; Fri,  9 Aug 2019 12:01:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3ECCB6B02AE; Fri,  9 Aug 2019 12:01:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id E481F6B02AD
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:42 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id s18so5313551wrt.21
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Oxz4+BCvX51ppTK6FgQZ5AJIz7jX8ftj9h36pE7LGiQ=;
        b=hz3yZ+oVTvEA9VDb5psz8kav3evtKyxrgbCzkx6oT7n7u3GxHfKy9QRNR8G8dfb91B
         VIQfjO5cP1X/kizI5yhLrzRTElEYWQZ9oWqlYOJCA505s8V3gOl1G6rFhvXtZWm09I2y
         IY7XYSJfZc0o6oblafJjDV9acr9MuxwSZGgqEuvKv54F6K58vDKtIrd0M1X2+llpen3h
         5oMcaKQSsOwNEoH9nqJmncK6qSqluCiua618XYWDN5DakU07+dm/11LOKF7scFEzozij
         CsuYbgLQ8aM9t7kycXTD/C9JMdykrF7VVonlpKm1MyM5dmn5HYzvm78DUIgeYI+iXIkb
         2WUA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAXW0Rf5OnwDu2wg7/VVrLZW4HwYPp+fGtn0AQV8SM/fFsdBasOe
	Z5e2sV6FBOB9G3L8vkWoI0TmoI8Ioe0EQaZ+JbNbRF1DABlwSlKzzLbwW25OSoEJ/9cZocFTaQl
	VLIWRbLVe00DVE9wS6BXPKa+o0j9DKpvR2df/psN6O/1mFlMukM10mDfDjuAGyQYTYQ==
X-Received: by 2002:adf:eb0f:: with SMTP id s15mr24572292wrn.324.1565366502518;
        Fri, 09 Aug 2019 09:01:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYxKju9bGgdaKrJCyNFFqHa9MSvvLSJ6V6SLRsTwFZ3rQZ5z/a2zwiTKknpGMLgfrMyCEw
X-Received: by 2002:adf:eb0f:: with SMTP id s15mr24572220wrn.324.1565366501730;
        Fri, 09 Aug 2019 09:01:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366501; cv=none;
        d=google.com; s=arc-20160816;
        b=0azKFL6Gim9Td+WhG9HEXLVPkBtE9mStwM1p4eG2eDlHleBnGhOkAdA3yjrk1gH3Eo
         ENA++EuwP7CDv1QkUV2/0sTdWQUzNC+C4AxjyCpqjTB6gxXJ2D/xUiSrvE9K6LQFkYK5
         Z43M3yJxNfhOJ8YAlG9cVfiz2erQ5wKg1sJ7XwkNL6/wvr7lMbPox+yPRHnOkPRZhK3/
         cAlRx2YM2e789aEWaEn5Zw/IsojG8e1YrbDhdYW5jeFH+6Wth0c8OCstNT1++WYpHyBi
         1BatNJsbhNBuRjjnQ14DqktwwwfJkoXQi+UATC9HZn+IzFb9bWlKq/QcQePb3bTZ4rry
         WCNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Oxz4+BCvX51ppTK6FgQZ5AJIz7jX8ftj9h36pE7LGiQ=;
        b=cyaha/Cy2iuV70cGvChij835QE7rRM0PDoXGB6cFYYtKsns0Srp6TDYHw+EQ/IWsq9
         Vu6tLXQi8QseA3uKlh7c3z7o7ySkhZaCeS+RH0fFZ3EEdaDHBwQDipC6FcDzkyaEHFNC
         ixBM7F3AKe6fXoxlw8Gn43Hop4HPWFxtNSUNJ+9mYSdFc4R1QT28wSlaG8dbHNuBcFkI
         qyx4kxSmPSmXaKJ0V3VXyGkUHkNbULUIK2KKUs4B9kOZwfEmuajfdJ8gnMJRP5HSg8qi
         FzMHdLomQeNYwjK4Q4FakunYa/eg048FfWA+SG9XkP7J905iPjNS/kSueDICJ38jTOow
         ifPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id k3si92081122wru.450.2019.08.09.09.01.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 2FF813031ED5;
	Fri,  9 Aug 2019 19:01:41 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id DE1A9305B7A4;
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
Subject: [RFC PATCH v6 83/92] kvm: x86: emulate movd xmm, m32
Date: Fri,  9 Aug 2019 19:00:38 +0300
Message-Id: <20190809160047.8319-84-alazar@bitdefender.com>
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

This is needed in order to be able to support guest code that uses movd to
write into pages that are marked for write tracking.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/emulate.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kvm/emulate.c b/arch/x86/kvm/emulate.c
index 7c79504e58cd..b42a71653622 100644
--- a/arch/x86/kvm/emulate.c
+++ b/arch/x86/kvm/emulate.c
@@ -1203,6 +1203,11 @@ static u8 simd_prefix_to_bytes(const struct x86_emulate_ctxt *ctxt,
 		if (simd_prefix == 0x66)
 			bytes = 8;
 		break;
+	case 0x7e:
+		/* movd xmm, m32 */
+		if (simd_prefix == 0x66)
+			bytes = 4;
+		break;
 	default:
 		break;
 	}
@@ -4564,6 +4569,10 @@ static const struct gprefix pfx_0f_d6 = {
 	N, I(0, em_mov), N, N,
 };
 
+static const struct gprefix pfx_0f_7e = {
+	N, I(0, em_mov), N, N,
+};
+
 static const struct gprefix pfx_0f_2b = {
 	ID(0, &instr_dual_0f_2b), ID(0, &instr_dual_0f_2b), N, N,
 };
@@ -4823,7 +4832,8 @@ static const struct opcode twobyte_table[256] = {
 	N, N, N, N,
 	N, N, N, N,
 	N, N, N, N,
-	N, N, N, GP(SrcReg | DstMem | ModRM | Mov, &pfx_0f_6f_0f_7f),
+	N, N, GP(ModRM | SrcReg | DstMem | GPRModRM | Mov | Sse, &pfx_0f_7e),
+	GP(SrcReg | DstMem | ModRM | Mov, &pfx_0f_6f_0f_7f),
 	/* 0x80 - 0x8F */
 	X16(D(SrcImm | NearBranch)),
 	/* 0x90 - 0x9F */

