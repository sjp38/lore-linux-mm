Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AA8AC4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 17:08:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3622921A4A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 17:08:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NOlHweTi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3622921A4A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7ADD6B000C; Mon,  9 Sep 2019 13:08:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2B536B000D; Mon,  9 Sep 2019 13:08:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1AAE6B000E; Mon,  9 Sep 2019 13:08:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0250.hostedemail.com [216.40.44.250])
	by kanga.kvack.org (Postfix) with ESMTP id A39846B000C
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 13:08:25 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 54AEBABE0
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 17:08:25 +0000 (UTC)
X-FDA: 75916015770.02.box24_83b0aaf65ed39
X-HE-Tag: box24_83b0aaf65ed39
X-Filterd-Recvd-Size: 4146
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 17:08:24 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id q21so9528501pfn.11
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 10:08:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=wPMbztDIbzkySjY7Sl5hBHJMX3nYrvhvNzUn5XH0t6c=;
        b=NOlHweTixtLZiLFTKY9rlqejzOTb0XI8x5pPvctE3BJcznEJZ3FxNZlQvAh9lC04jO
         K3R1lSqr2rke+fzifIDoT8r4nDuQV5WTHALeNkJBbCf30U9jzww5EIpkVeDJne9reP+e
         ytupaklu8rOWUlzxcy57xMGgVmjDdVQGJeHuRF7B2d9bgZ2desXOQmN95ADiddHL16gu
         Wcrt7FCsjzPDQf0KTj1xU3iAOZwxrDqBsuvPH65zCxEGjST19J2yxSJKQ1m2WkTw7AZT
         t4+gwRNvigjGmTxG/AwO01QqLlLKLzBJ9kSLli6ywBM2t1fYDfCJcKp3UStwBhaDQUO5
         mCMA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=wPMbztDIbzkySjY7Sl5hBHJMX3nYrvhvNzUn5XH0t6c=;
        b=j5EQygpKFO2Q2WyzLqM15sTE9p7Trofb49+LzjUR+BYFxpgXYrwDKd5zFbqW0lt6de
         y7aS/PgBeaVjLoTq8blcK0e+Nk48oeKitlKN8m9NCI6m1eHPXA7Clb2cJDUyCE4VliDA
         PGdlzrPebUyYbGNBvmvXoviIvVQUStE9I+PWxMJIl1Xm9pHo96+2OpQ/yH2Ch+ceOtDS
         nwLGu2Lxkg8JyIOmK3MpPziDRlOz/6Zr/ObwE/ZxYBuPpruk+TsAWkZwqBXfyCp2Op2l
         P0aiYMkHT39ZVpNUGxqEi117oU5fWPAcWxVYcSpGknWpY9nU7rTlU2RTqCjLAD3UeRpv
         5h6A==
X-Gm-Message-State: APjAAAUCA5mAb76uIiUGY7rZgHHi8DAmcHkNTSRp4KbFfQ+HbzJLncws
	DZX5kA1zdBdJj98PwoLuB+taPHr0zAk=
X-Google-Smtp-Source: APXvYqwjmYInaZx6SDG6wgi8tWtl2/JRBWAdYJG7Ff3sw8EYfzoCAJTs5qn6+Q/ejGCcW1UStRozAQ==
X-Received: by 2002:a63:f907:: with SMTP id h7mr22785468pgi.418.1568048903964;
        Mon, 09 Sep 2019 10:08:23 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id b18sm107015pju.16.2019.09.09.10.08.13
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 10:08:23 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz,
	cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH v2 3/4] mm, slab_common: Make 'type' is enum kmalloc_cache_type
Date: Tue, 10 Sep 2019 01:07:14 +0800
Message-Id: <20190909170715.32545-4-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190909170715.32545-1-lpf.vector@gmail.com>
References: <20190909170715.32545-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The 'type' of the function new_kmalloc_cache should be
enum kmalloc_cache_type instead of int, so correct it.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/slab_common.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index cae27210e4c3..d64a64660f86 100644
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


