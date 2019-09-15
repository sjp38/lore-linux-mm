Return-Path: <SRS0=FJsX=XK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1EFBC4CEC7
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 16:52:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81966214D8
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 16:52:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mddTC6Sg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81966214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 378F66B0007; Sun, 15 Sep 2019 12:52:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 302406B0008; Sun, 15 Sep 2019 12:52:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F0E76B000A; Sun, 15 Sep 2019 12:52:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0148.hostedemail.com [216.40.44.148])
	by kanga.kvack.org (Postfix) with ESMTP id EFC2E6B0007
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 12:52:12 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 98962824CA2E
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 16:52:12 +0000 (UTC)
X-FDA: 75937747704.08.bun79_30563d1227812
X-HE-Tag: bun79_30563d1227812
X-Filterd-Recvd-Size: 5410
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com [209.85.215.193])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 16:52:12 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id n190so18048418pgn.0
        for <linux-mm@kvack.org>; Sun, 15 Sep 2019 09:52:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=zr0c07NjDmSH5Cw3kJRhGheNFiNUbd4oIPE+u9OeCKU=;
        b=mddTC6SgYO2Ab78FK7UUhuQd1kwETldDpr5BXxpYb+fc8mge2xlIGeYMxpVaUY7nvR
         uOTQyCbJmz0EEvUKAWI/cQrJjSTlpzkpPRdJKMKc7X1W7v2JE4nGXDqTFvy/O/ovzm97
         lXhRGG1iv1ixHyBj1NEDWSxrw+enMNU4S8QHT60tz59ACuf4xK2fN9cwytHTUk9m9Trc
         A9N9+gwU962IUT+ELhMevHDxVxIR6Fwy8cEdahUQyI1PY8mFjHUEEp2gnuqyC/RkuiCQ
         z5PuGS651NaGM7xzH6WRd5AYpNubAX4kYNWeYgqGN7SAVL1BR0L1gDaUq+6gmu3kwFN4
         1qfQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=zr0c07NjDmSH5Cw3kJRhGheNFiNUbd4oIPE+u9OeCKU=;
        b=BRglEYTcAp+CF6kQq63CKrix/jdwDXLkOf7gdNZZAsPhsIZaEQtm1HF7Wivr5SpS9W
         7tg8ENfAeOXpVG+fa/p+m/ZTG8qRbJtCloWpeAs/QydIOkAY5FdDyHBt2LWpnBFxdRot
         QhsiaZdW8d3VcP9VamlVvwWsn2YrR2xlns6lbDUmlUKZdFkLRtZ0CD/J+s7sDS+YSaWc
         A4Ztgn0a9hRzH1SaqN3ledel0sELbvbfLGOKEXXABp2vq4xRnb4M2RVC5eoh1MQM0d0z
         1YLgZPxPbGG4aRHC+ZGNFv1z8KJ93QMhiLZhdS6sbShgRwmLV5Vj7xQh0/880wtE+a7y
         p3Pw==
X-Gm-Message-State: APjAAAXi51NkKuRa79fDPXGYx96C6Asgup6IPjfdDek3pMSoDLkVuLr+
	UrZk1x9QWxgnilsj2wQeLKQ=
X-Google-Smtp-Source: APXvYqxRn4ewzSZQkn/FFbl0qa7yiPu7uWCtjRCH+R5ndNnAWNrY7LsBcmNmfGEgVnhOaGKimOoOLg==
X-Received: by 2002:a62:2d3:: with SMTP id 202mr69461597pfc.141.1568566331261;
        Sun, 15 Sep 2019 09:52:11 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id a4sm4383259pgq.6.2019.09.15.09.52.03
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Sep 2019 09:52:10 -0700 (PDT)
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
Subject: [PATCH v4 2/7] mm, slab: Remove unused kmalloc_size()
Date: Mon, 16 Sep 2019 00:51:11 +0800
Message-Id: <20190915165121.7237-3-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190915165121.7237-1-lpf.vector@gmail.com>
References: <20190915165121.7237-1-lpf.vector@gmail.com>
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
Acked-by: Roman Gushchin <guro@fb.com>
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
index 002e16673581..8b542cfcc4f2 100644
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


