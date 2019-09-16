Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.3 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0C6AC4CECD
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:46:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89E8021848
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:46:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l0IZ2qlW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89E8021848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 370026B000C; Mon, 16 Sep 2019 10:46:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 347DD6B000D; Mon, 16 Sep 2019 10:46:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 283FC6B000E; Mon, 16 Sep 2019 10:46:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0103.hostedemail.com [216.40.44.103])
	by kanga.kvack.org (Postfix) with ESMTP id 072286B000C
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 10:46:55 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id B3FCE4425
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:46:55 +0000 (UTC)
X-FDA: 75941060790.23.bait11_1f56322c87255
X-HE-Tag: bait11_1f56322c87255
X-Filterd-Recvd-Size: 4276
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:46:55 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id x127so27479pfb.7
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 07:46:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=jCVsoiANbO0A0rAsPONqC8CmNnKvwITi8BzVSSbb6XQ=;
        b=l0IZ2qlWNiFhcK1qlGvKwC1wuMV95H42NFba70/jxZptHT9Rbemzw5VlpIuap1kS+d
         BX18/2l1ApbcJoKmv7zOkvQWoHljxRBunQDUfccRw5l0+ZqMcxOpjERJlc9byEy5VUuq
         MWOBQ0M7hMpOYmGcR2h8EG7yBUrQq0nQg6fHWj+QbiUV5M0fE6m3/t+dKCJuaMg/9k2r
         bqJTJSajXVA6+5QTIUssK8713gmQXTyFyEr7269syveyZwN1RGjO9pj6xW/eYT+/OpxV
         hGVhx+/ZSgzb+S+Qm6Gvj8RJ/X5TPS6XSU4KeA2bI8MZOvJw62IsUUx1+lSiKCDVfpTG
         5F8A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=jCVsoiANbO0A0rAsPONqC8CmNnKvwITi8BzVSSbb6XQ=;
        b=ihtrwgTQBf3HlqQwSoTV2geZzFiLchQQj7ewyq0yPKdqAbIPv/EaD3nR46h8QNYC4Y
         bxBcCz6tAFxTN/+TzTgLWtlzXCFOqc3KjRXUpJE6+yth9QEDkOAsOTTypjPpbkR7D8MJ
         Y9F4xDRL/Y5h3JrHMQSJiqhjuLIDT8VDcHRzYnjG32yFaLcE7FHyhvGq9jdqijaB4DsH
         xkXOoQNI81brX47/Q2HcLClButLYFFw2ADTWzCELJyqd0+UegWUwp81yCA7vqizgHLiz
         B5riK7ENsxnaLvyYOTaQAWkdMruVmcZrPn6TXV8iFJzNjYp53JZ0G/muFh9NVg6EtOod
         34cA==
X-Gm-Message-State: APjAAAVKUnY03Uxvmv6dToT0bo2/oCa+phxoZx9eh36vOtiqtl1rIona
	GXVYoDyQ95AUDUgLERUfjBU=
X-Google-Smtp-Source: APXvYqyyA+wz35DCND9zfqzqpU24YpmTLwayeIV3v5e/r0L7Cl3JOR/qARquRdKD/5+zmkGiT5juiw==
X-Received: by 2002:a17:90a:ca0e:: with SMTP id x14mr108909pjt.70.1568645214399;
        Mon, 16 Sep 2019 07:46:54 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id d190sm15036004pgc.25.2019.09.16.07.46.44
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 16 Sep 2019 07:46:53 -0700 (PDT)
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
Subject: [PATCH v5 3/7] mm, slab_common: Use enum kmalloc_cache_type to iterate over kmalloc caches
Date: Mon, 16 Sep 2019 22:45:54 +0800
Message-Id: <20190916144558.27282-4-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190916144558.27282-1-lpf.vector@gmail.com>
References: <20190916144558.27282-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The type of local variable *type* of new_kmalloc_cache() should
be enum kmalloc_cache_type instead of int, so correct it.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Roman Gushchin <guro@fb.com>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/slab_common.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index df030cf9f44f..23054b8b75b6 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1192,7 +1192,7 @@ void __init setup_kmalloc_cache_index_table(void)
 }
=20
 static void __init
-new_kmalloc_cache(int idx, int type, slab_flags_t flags)
+new_kmalloc_cache(int idx, enum kmalloc_cache_type type, slab_flags_t fl=
ags)
 {
 	if (type =3D=3D KMALLOC_RECLAIM)
 		flags |=3D SLAB_RECLAIM_ACCOUNT;
@@ -1210,7 +1210,8 @@ new_kmalloc_cache(int idx, int type, slab_flags_t f=
lags)
  */
 void __init create_kmalloc_caches(slab_flags_t flags)
 {
-	int i, type;
+	int i;
+	enum kmalloc_cache_type type;
=20
 	for (type =3D KMALLOC_NORMAL; type <=3D KMALLOC_RECLAIM; type++) {
 		for (i =3D KMALLOC_SHIFT_LOW; i <=3D KMALLOC_SHIFT_HIGH; i++) {
--=20
2.21.0


