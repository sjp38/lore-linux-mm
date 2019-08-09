Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 189C5C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B2A642086A
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B2A642086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 044D66B02AB; Fri,  9 Aug 2019 12:01:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0FC66B02AF; Fri,  9 Aug 2019 12:01:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D61996B02B1; Fri,  9 Aug 2019 12:01:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 73A326B02AB
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:43 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id p16so1063290wmi.8
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=snDYrmYOB4D8XrE4Y1GO8LguUzt4kPoj4+nHw7jBNKY=;
        b=HCgYFHZJG9rw8GdUtMNItvFCGvE6l+qcIhLTyLVfJxy3Iw5FpHwbTgwtIxb5otdd4t
         L0xjaj3D4cM2qRU2dsxwHPHVaGGYnpTH46NgemT0gfzFqKAyXCbWb/sB+vmbPxWQmdkW
         Qhh8RS0UiIDOXsmaqFXZRQeFCGCk3OjXwMl4xfo3dse9lyD+ak6LqbEe4YQaZIi50pk7
         s7wrI5/ZTNhM5HdRu2cZRjiy2Ny2znfbBaM1Lx3FxbA7D3dQ6m3fZ1khLcGoXEajExnP
         y21axKQurXZa+leuIN5YItuGADVuITgsjTAhhpxM82omFF3/fwy2L5foH4JoEg5dZf9g
         mhSg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAXVVfcgyhIkfijf0FY5hRBGNpv9y5ssQiCbVN5bURB/sfo12lEa
	jI9Gi8YMfxg25s+10kKkOxCJK/bBzn+OXCCaKBoZcTBsp7xoXzuLnosHvxhUF/+yn/4D67wttpd
	QRWtQsQjL1BMlV7uvSaZ8FNWYfbcFJPFFN6kxbvLwvwCbsKiu2QQ2Fb+rWH3ijnIaSw==
X-Received: by 2002:a7b:c155:: with SMTP id z21mr4376524wmi.137.1565366503069;
        Fri, 09 Aug 2019 09:01:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHpMIcP3K3N4EaXC2IIakUZvPVIXu2oTXTf+UrV7ejwudaMnCYgMn0paGfiKGZmOOivnW8
X-Received: by 2002:a7b:c155:: with SMTP id z21mr4376426wmi.137.1565366502000;
        Fri, 09 Aug 2019 09:01:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366501; cv=none;
        d=google.com; s=arc-20160816;
        b=NAXsTD9u/89iq/EVnBxLoATiNQYkIlAXNKgrixsBbbJTwbklxdKNvJhbCqA//tJbDX
         WeZvrHM1FOwiCYrEEFFJ9Jo8ge+22syAmOie43AhRYWSYXhlFjlJQIdhGUVvc39uoIy+
         D+4qlrGhv9v34jWnT/XqevlJwp6OeLO5X+BiWP62tQzYgjl56Df0/gX+d2INsfClT+zZ
         fC7tER9m3GxhrLDfq9U80t2djV+HkvE17eEoAiFkc2OTAg7DDfu86Y5L3OgAZ52M629b
         1vp4/HJz2ywOuolhGrUwRVBYrZA7ZLIRydUyPwblI3szM/zB4AlCGbZ5G8n5sZx9af9g
         rxug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=snDYrmYOB4D8XrE4Y1GO8LguUzt4kPoj4+nHw7jBNKY=;
        b=DaERWBPfEDkNPn722xegSGutg6CAzMXemTkAbskCrLsZ1I5dA9su6Jw1eGYlraWmLW
         dpFtyV9vXrt+WlgHgQQbcCY52XzHJz3/VY5ERJ5aVI82PA/avZkL5vK9huegVDAdso7K
         /I6NNcmwgtluLcAOjp34wXwtOvn8kVPep6R5xWJXddWTw1byJT2yXijDyxPqgDZMe3fd
         Xi88/QG8BoSxQbvCTnW+N2XckoiANajP4bs+4y03NU1sOkdZ59ngjzg8eyx45t6I6k/J
         cZhuKr9wiaaLEpq61AZv28t4e1J7zOvsj9vWwKTPnSIEr2KkeDN33nm0ZiM0Gt3BG62T
         HPmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id l18si4260147wmg.107.2019.08.09.09.01.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 6E9AD3031EDB;
	Fri,  9 Aug 2019 19:01:41 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 2797E305B7A3;
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
Subject: [RFC PATCH v6 84/92] kvm: x86: enable the half part of movss, movsd, movups
Date: Fri,  9 Aug 2019 19:00:39 +0300
Message-Id: <20190809160047.8319-85-alazar@bitdefender.com>
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

A previous patch added emulation support for these instructions with a
register source and memory destination. This patch adds the variants
with a memory source and a register destination.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/emulate.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/x86/kvm/emulate.c b/arch/x86/kvm/emulate.c
index b42a71653622..a2e5e63bd94a 100644
--- a/arch/x86/kvm/emulate.c
+++ b/arch/x86/kvm/emulate.c
@@ -1184,6 +1184,10 @@ static u8 simd_prefix_to_bytes(const struct x86_emulate_ctxt *ctxt,
 	u8 bytes = 16;
 
 	switch (ctxt->b) {
+	case 0x10:
+		/* movss m32, xmm */
+		/* movsd m64, xmm */
+		/* movups m128, xmm */
 	case 0x11:
 		/* movss xmm, m32 */
 		/* movsd xmm, m64 */

