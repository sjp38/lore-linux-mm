Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9062C4740C
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 01:27:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75BCF21726
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 01:27:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CwKvZC/r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75BCF21726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 290036B0266; Mon,  9 Sep 2019 21:27:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23FFB6B0269; Mon,  9 Sep 2019 21:27:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 107AA6B026A; Mon,  9 Sep 2019 21:27:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0048.hostedemail.com [216.40.44.48])
	by kanga.kvack.org (Postfix) with ESMTP id DCC026B0266
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 21:27:46 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 824D78243763
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 01:27:46 +0000 (UTC)
X-FDA: 75917274132.25.tree95_7e0a24e77125a
X-HE-Tag: tree95_7e0a24e77125a
X-Filterd-Recvd-Size: 3926
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 01:27:45 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id i1so1667816pfa.6
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 18:27:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=z0ivIH0CLLNNjAWBlrwIKDFI2cokRF0sKteG5gWpNc4=;
        b=CwKvZC/r+gmvybd4uHXDOj6GImjAwuSp/3ZG529ovEbvTmzdB+ugI3QMZykaj8Vj0b
         +3cW7ORGPP38mahjYemQIFY/ZLI2B20X3aL2SSMn+G/+VM3m9Wznt4MwsSZo/MUw5A7t
         IZdcmAk2HpK4IVD0MQ8IOVzv+gqHN7182CP9plZhTaT5FkAUrHLHoz0f7ntiZR3FwipF
         U9Dkjds7cDIfUDgvErgcoSjEJ3wGlvku1xZeq5aARNTJTDSg6LEm0wrNzk55E62e8ifk
         UmdOds+v5ABGh2/f14kh4MZqCAZDFiSIDQBaFJtIbz14tCnH8GMbflVYQSqmpZp1dlyw
         pevg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=z0ivIH0CLLNNjAWBlrwIKDFI2cokRF0sKteG5gWpNc4=;
        b=HiD2fnCi6A5chcjYFKVTME+TIsFTYlWN/DPIt0fIxAXCGl3tcPUOGFSVcCEZrslB8+
         9WxXJPR71kHRQ1BSBti0fbjBUDTImRHURmTybXfcPP7cVBapZnybrsrm2btqoKNH7kXk
         4LNwKnYh8mI2c12hwxJThZ8akKJZUwnNefO2cI4Ar21vvv0Ss6d8kDWxbiyQNzq2JWfO
         owhoz/XoYQHJAuJ2LHueUkKF3/BhE8Y8VCaQRofgyh8ezU2+eoAnoNJk9HVFTu46QcYp
         qZ9zSvq9XT/NIx3xVZ2X30DdwzPQR1on1fRkodg0yuVXyc//pYA034DJauz0RthIH5Tw
         FaPA==
X-Gm-Message-State: APjAAAVXj7zRhfCdEMS3NhDkw0cd7+ju0sx1NMWB41Z2V2NvS0wEkJ6D
	qR4NxZkEEE90OivuwhBBTBQ=
X-Google-Smtp-Source: APXvYqzzsQDdtbXZUkzusTKy4WxRxPWuZxQNE+lSoOl5lbcBkgjJohKXfZw/PYBmP5eYuUnatXVOUg==
X-Received: by 2002:a62:3893:: with SMTP id f141mr15612910pfa.221.1568078864996;
        Mon, 09 Sep 2019 18:27:44 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id b20sm19558629pff.158.2019.09.09.18.27.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 18:27:44 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz,
	cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	guro@fb.com,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH v3 4/4] mm, slab_common: Make the loop for initializing KMALLOC_DMA start from 1
Date: Tue, 10 Sep 2019 09:26:52 +0800
Message-Id: <20190910012652.3723-5-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190910012652.3723-1-lpf.vector@gmail.com>
References: <20190910012652.3723-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

KMALLOC_DMA will be initialized only if KMALLOC_NORMAL with
the same index exists.

And kmalloc_caches[KMALLOC_NORMAL][0] is always NULL.

Therefore, the loop that initializes KMALLOC_DMA should start
at 1 instead of 0, which will reduce 1 meaningless attempt.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 mm/slab_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index af45b5278fdc..c81fc7dc2946 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1236,7 +1236,7 @@ void __init create_kmalloc_caches(slab_flags_t flag=
s)
 	slab_state =3D UP;
=20
 #ifdef CONFIG_ZONE_DMA
-	for (i =3D 0; i <=3D KMALLOC_SHIFT_HIGH; i++) {
+	for (i =3D 1; i <=3D KMALLOC_SHIFT_HIGH; i++) {
 		struct kmem_cache *s =3D kmalloc_caches[KMALLOC_NORMAL][i];
=20
 		if (s) {
--=20
2.21.0


