Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68E81C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 11:35:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BECE20B7C
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 11:35:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BECE20B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=glider.be
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6332B6B0271; Fri,  7 Jun 2019 07:35:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E4C66B0272; Fri,  7 Jun 2019 07:35:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AC656B0273; Fri,  7 Jun 2019 07:35:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id F2F436B0271
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 07:35:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y22so2725748eds.14
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 04:35:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=ktxrr/3uDiebbKfbShFddZYpvDd5VR0Kds7WmJcATZ4=;
        b=JUZCkoCButphmyYQDPS0gxtuepAqB7eIpDmbfvnxDtz7EXgj0vWlIUP+J0/HxculOP
         5c2a439ETo/Ht1UYXxH2gT8cekiwsRakwOmDj3Obq2jGY+00LxP6a3azAZXs/ANIFSRu
         nnPRLc/RIbopI54JC9H1LFh4f/JAvdtYfVHyMJ8s1GN52o0j6U7ZBrKpw7KzVmdM62oe
         tcVRbNZ3fxhvdySHpa+zJI7pPG4CNyh/S7ODzNhR44iJjOwGPzBrMtxrEL+Cwn6hGKVz
         bY/R7eqirKahdAYSKTwEEtc81lGpmI2Lmexi+CZScvLOPFSJzsNzqZrlLvpREMsa0YEl
         mJoQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2a02:1800:120:4::f00:13 is neither permitted nor denied by best guess record for domain of geert@linux-m68k.org) smtp.mailfrom=geert@linux-m68k.org
X-Gm-Message-State: APjAAAUQ9a6lWyK8XgO7IBztBtcAohsbfyaXfpEYS8UL53MdLeE36t1E
	PZZo4rOcDeO4T7QdUV9/LfnJHoujV6/nd0Znyg4Nq24F5ZGFCX8P2wg2zxb51AFq7/rcLPFDeLd
	QojQ7CV1ZKPR+Z051PhwO4gFOvNfnFFzNDAU5rZReNhu1YX2MaqGOez3KHcrWtBM=
X-Received: by 2002:a50:90fa:: with SMTP id d55mr8660664eda.210.1559907314377;
        Fri, 07 Jun 2019 04:35:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx51zg4MO0iaez1SOr2zHLfrRntdTYMWM3XoGmfwlnGxjobqcHzf8xIdIkr1yrBzbQoQAFE
X-Received: by 2002:a50:90fa:: with SMTP id d55mr8660594eda.210.1559907313527;
        Fri, 07 Jun 2019 04:35:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559907313; cv=none;
        d=google.com; s=arc-20160816;
        b=Zssh+NSjEMeoCXThSecj8y0Mzx24v4NMd1p9xtXNKwHMgGBk5aZ++2pGN1J9sr06qz
         44waE1GZ5lMqBxFwin1xR1uIgEanAZRJck+t15a2acWI0kR/cdt2AzeWBd8KM2D0mN7Q
         J47FAg0AT/r823ZN+iiA8Ej3ntVjVmVHyYRzuhnz+W8U9tFHC/fCWnmcQYhHz+66dO31
         447N5S8YvKSrrUTvPzepA3iBGLihGKiW7mkCkuPha+8ocle+SFsKvm44pwKe3AT/WuXZ
         YXRxtY8829AZTWIWhbUEOm0LNy1O7rUFgrn9pSHkE9t8wzzc531XbRGUBoQqPRjwQSJ+
         MMJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=ktxrr/3uDiebbKfbShFddZYpvDd5VR0Kds7WmJcATZ4=;
        b=y+1p+xGacWKYRoLIuVXOChCAeQ1td889hSM0YUD9XBYV30IZoopHgsk1yc7jGuDM+C
         gEbx2EJRKD2s7KdQ43bD4l26nfEq93j1dyooJbj4lU9y/6meV/zR2hm4bG4h9T+3VLN3
         HePs/BnMq4pyxBQo7Yydt8ODvkvhNfAe5jhT/h2z6qLv/F9ZCHWDRrmgVNmYDVFIOcLs
         alegcPDULrr6Gxd6gbPDtBccQGTmJqre/jlwQE3UaTOUi2Ez5cAO0sJrgaNhYEWcKupj
         VP26JJLbp/y8koK1eJNLSY11Sv/jtJzEpHEMjF6zGqTNH8WDfqgc/xo7tCjA3fcf1tcz
         eEjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2a02:1800:120:4::f00:13 is neither permitted nor denied by best guess record for domain of geert@linux-m68k.org) smtp.mailfrom=geert@linux-m68k.org
Received: from baptiste.telenet-ops.be (baptiste.telenet-ops.be. [2a02:1800:120:4::f00:13])
        by mx.google.com with ESMTPS id z9si1127202edz.403.2019.06.07.04.35.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 04:35:13 -0700 (PDT)
Received-SPF: neutral (google.com: 2a02:1800:120:4::f00:13 is neither permitted nor denied by best guess record for domain of geert@linux-m68k.org) client-ip=2a02:1800:120:4::f00:13;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2a02:1800:120:4::f00:13 is neither permitted nor denied by best guess record for domain of geert@linux-m68k.org) smtp.mailfrom=geert@linux-m68k.org
Received: from ramsan ([84.194.111.163])
	by baptiste.telenet-ops.be with bizsmtp
	id MnbC2000V3XaVaC01nbC0d; Fri, 07 Jun 2019 13:35:13 +0200
Received: from rox.of.borg ([192.168.97.57])
	by ramsan with esmtp (Exim 4.90_1)
	(envelope-from <geert@linux-m68k.org>)
	id 1hZD9M-0004Fw-SF; Fri, 07 Jun 2019 13:35:12 +0200
Received: from geert by rox.of.borg with local (Exim 4.90_1)
	(envelope-from <geert@linux-m68k.org>)
	id 1hZD9M-0003vC-Py; Fri, 07 Jun 2019 13:35:12 +0200
From: Geert Uytterhoeven <geert+renesas@glider.be>
To: Jiri Kosina <trivial@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH trivial] mm/vmalloc: Spelling s/configuraion/configuration/
Date: Fri,  7 Jun 2019 13:35:09 +0200
Message-Id: <20190607113509.15032-1-geert+renesas@glider.be>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 mm/vmalloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 7350a124524bb4b2..08b8b5a117576561 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2783,7 +2783,7 @@ static int aligned_vwrite(char *buf, char *addr, unsigned long count)
  * Note: In usual ops, vread() is never necessary because the caller
  * should know vmalloc() area is valid and can use memcpy().
  * This is for routines which have to access vmalloc area without
- * any informaion, as /dev/kmem.
+ * any information, as /dev/kmem.
  *
  * Return: number of bytes for which addr and buf should be increased
  * (same number as @count) or %0 if [addr...addr+count) doesn't
@@ -2862,7 +2862,7 @@ long vread(char *buf, char *addr, unsigned long count)
  * Note: In usual ops, vwrite() is never necessary because the caller
  * should know vmalloc() area is valid and can use memcpy().
  * This is for routines which have to access vmalloc area without
- * any informaion, as /dev/kmem.
+ * any information, as /dev/kmem.
  *
  * Return: number of bytes for which addr and buf should be
  * increased (same number as @count) or %0 if [addr...addr+count)
-- 
2.17.1

