Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D99DC4740C
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 17:08:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62D0B222C1
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 17:08:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UuVcZXvR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62D0B222C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 034BF6B000A; Mon,  9 Sep 2019 13:08:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F265A6B000C; Mon,  9 Sep 2019 13:08:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E15546B000D; Mon,  9 Sep 2019 13:08:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0031.hostedemail.com [216.40.44.31])
	by kanga.kvack.org (Postfix) with ESMTP id C24A96B000A
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 13:08:14 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 71B108408
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 17:08:14 +0000 (UTC)
X-FDA: 75916015308.19.bell51_8213b9765ca06
X-HE-Tag: bell51_8213b9765ca06
X-Filterd-Recvd-Size: 5358
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com [209.85.215.195])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 17:08:13 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id m3so8138252pgv.13
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 10:08:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=IAG1VLKBZpRTEI8L4+2XUQIRSxmDIwmG8l7u8lqUj7s=;
        b=UuVcZXvRYiGsCOXoX7QtHfrnf25gH30tm3Jr+MLFXtA0xo/UN3oUbJHtk5i1n0Ilb3
         IZL9SiXjwDj+bm3AtV9wLg3n6Jswk30v2yH6HpLhfbrVl6pTWflcxilGtD/kV1H0aJ36
         dB8Pr7vF+PX/NrDC4T6C40H5DtyEHkOJNskSEX+bN2SScynCsurEyZj2XeCPs2wRUr4g
         HXNJk6SrR5OgR+WzJaTTuH0fMzZgKMpJr1BmKVQg6/zn1jE7cWhxg4MlOklK1NkWr0Wn
         b8OpbRs1OD0DzyZNmS10ql7vR4FEOEGP+a/u8M9idhR2f52v15FWTrlXEQyJC8TprYCl
         IaNA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=IAG1VLKBZpRTEI8L4+2XUQIRSxmDIwmG8l7u8lqUj7s=;
        b=Z2R1eyQq8gwrg9kDzlrxkUYJf3DxuUZoxIVtgMISybIN9Wd2tiwylCLau4ZOvwW6G+
         twbRnBoc8z5V46JT5danWitZgv/3kKT8Z9kX7COCIaSzx2lyYlMap7wCjtz/pt4Mw3Lj
         J/I7iU0hCc1TOfZwoFnV974PRhUVGf725c2Cwx/EKnEYkex33ho9T970O+EyzBgiZCvi
         un4TxF1ST4nmJ/VgT1l7QmZQMk9JKZ9NFzVrbIp30Qfa1xkZ9dSgqqLkXZwmQXlq57yD
         gwnYhLjSQ2kJ0JTT67LJ4j765Ob4Q59W5K9vw6k0JUObdfICLiOad++/C8hse4+MyUqO
         5HjA==
X-Gm-Message-State: APjAAAXk9aHMZ7hE4id+rYCTCUlqW3eYY8bTdqOdrsw4vrOBKPz2YzeN
	iuVeIOTaaiiTK2OaJHQ5cBU=
X-Google-Smtp-Source: APXvYqwibHgZWR+jw1Ah4yMCwZtMRhATUb+KbugeO1jo6o8Yxx06YncsTn+5H5M9UI4Gh/rYQvApxA==
X-Received: by 2002:a63:5823:: with SMTP id m35mr23177084pgb.329.1568048892858;
        Mon, 09 Sep 2019 10:08:12 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id b18sm107015pju.16.2019.09.09.10.08.03
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 10:08:12 -0700 (PDT)
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
Subject: [PATCH v2 2/4] mm, slab: Remove unused kmalloc_size()
Date: Tue, 10 Sep 2019 01:07:13 +0800
Message-Id: <20190909170715.32545-3-lpf.vector@gmail.com>
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

The size of kmalloc can be obtained from kmalloc_info[],
so remove kmalloc_size() that will not be used anymore.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/slab.h | 20 --------------------
 mm/slab.c            |  5 +++--
 mm/slab_common.c     |  5 ++---
 3 files changed, 5 insertions(+), 25 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 56c9c7eed34e..e773e5764b7b 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -557,26 +557,6 @@ static __always_inline void *kmalloc(size_t size, gf=
p_t flags)
 	return __kmalloc(size, flags);
 }
=20
-/*
- * Determine size used for the nth kmalloc cache.
- * return size or 0 if a kmalloc cache for that
- * size does not exist
- */
-static __always_inline unsigned int kmalloc_size(unsigned int n)
-{
-#ifndef CONFIG_SLOB
-	if (n > 2)
-		return 1U << n;
-
-	if (n =3D=3D 1 && KMALLOC_MIN_SIZE <=3D 32)
-		return 96;
-
-	if (n =3D=3D 2 && KMALLOC_MIN_SIZE <=3D 64)
-		return 192;
-#endif
-	return 0;
-}
-
 static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int =
node)
 {
 #ifndef CONFIG_SLOB
diff --git a/mm/slab.c b/mm/slab.c
index c42b6211f42e..7bc4e90e1147 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1248,8 +1248,9 @@ void __init kmem_cache_init(void)
 	 */
 	kmalloc_caches[KMALLOC_NORMAL][INDEX_NODE] =3D create_kmalloc_cache(
 				kmalloc_info[INDEX_NODE].name[KMALLOC_NORMAL],
-				kmalloc_size(INDEX_NODE), ARCH_KMALLOC_FLAGS,
-				0, kmalloc_size(INDEX_NODE));
+				kmalloc_info[INDEX_NODE].size,
+				ARCH_KMALLOC_FLAGS, 0,
+				kmalloc_info[INDEX_NODE].size);
 	slab_state =3D PARTIAL_NODE;
 	setup_kmalloc_cache_index_table();
=20
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 61c1e2e54263..cae27210e4c3 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1239,11 +1239,10 @@ void __init create_kmalloc_caches(slab_flags_t fl=
ags)
 		struct kmem_cache *s =3D kmalloc_caches[KMALLOC_NORMAL][i];
=20
 		if (s) {
-			unsigned int size =3D kmalloc_size(i);
-
 			kmalloc_caches[KMALLOC_DMA][i] =3D create_kmalloc_cache(
 				kmalloc_info[i].name[KMALLOC_DMA],
-				size, SLAB_CACHE_DMA | flags, 0, 0);
+				kmalloc_info[i].size,
+				SLAB_CACHE_DMA | flags, 0, 0);
 		}
 	}
 #endif
--=20
2.21.0


