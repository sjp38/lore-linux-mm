Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 061B9C3A5A7
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 16:06:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6C44238C6
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 16:06:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="V3J24BLz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6C44238C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A05A6B000D; Tue,  3 Sep 2019 12:06:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 677DE6B000E; Tue,  3 Sep 2019 12:06:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58E246B0010; Tue,  3 Sep 2019 12:06:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0122.hostedemail.com [216.40.44.122])
	by kanga.kvack.org (Postfix) with ESMTP id 393A66B000D
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 12:06:07 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id CE1F5181AC9B6
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 16:06:06 +0000 (UTC)
X-FDA: 75894085932.09.bat90_6f772ddd8c12c
X-HE-Tag: bat90_6f772ddd8c12c
X-Filterd-Recvd-Size: 5291
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 16:06:05 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id y22so5429079pfr.3
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 09:06:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=sCfAZ6FcWE/Ra7JeZeEWDGvzMRc1z2NIPSNI/z4SnG4=;
        b=V3J24BLzylgKwKh6YH7jauZXbnITYVEVj7ZDmCfsKzdE98Rym6ITHptLSyHLk9j+qQ
         Eh7DX/9mRvIH1jMR4AsNEk7Hcu/EdM5OdA9NLcejVpEc22i+WxGtJt1klI+26KfPi8m6
         vXpfw859zeEADTFrb7idJrVIX/n2Ib4Ds6uN0V9355TG55imO0lHfGIFAqh3SVJN8l7P
         DGaT3/zSOaeD4Hbih9tFpj19xrtTvONbee0eKHoyVIG+Ckfq8DywENu3xMmv9AXNuPId
         KOW0JUkZepbrcrLbJCaq3B/kxIU5hQ7xDkd4fme2mJd70Nk5SOkcLR5uT96cLlZ9J7RU
         aj5Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=sCfAZ6FcWE/Ra7JeZeEWDGvzMRc1z2NIPSNI/z4SnG4=;
        b=n8TIh0UicZPuaER2fp4OgOgW4rMDy6HnJa8vPw1KUxRre7cxnGhKesIV8ZfXLVZ8pj
         K+phXcBtvXTbPiODZV0q+c/rWxpUxhNnqrVGmG04SI5q5g59lgun6stU/UaAf9Mzprtl
         W1mtpl0CRKpDrB+KvTb6e5RFqqh9FvxvIL2/CCqgcctNwuXzLo4WeitBqPF9xpVAaPZ4
         5lGDuayvWta2e3tESO5CeEJ5xbxY+zSmcT3JkvKioLZw3CiAErhpjShZvOU5LSbV6P1B
         OACls6iLq64gu4/MdsEtD9eKwF2z19nB0TiOZoZZCyMvCunOHcfuL1k/JXBs3Me/gXGa
         s6RA==
X-Gm-Message-State: APjAAAWisvqeM5lTfH0y1XC0B2YxEiY1J6i+fnfQVxKqrFgF+EtmH0vx
	L6enz2+H/ssf76e1d8QQJtA=
X-Google-Smtp-Source: APXvYqwgdPLWgf9CQVGxcsYwYCpR2opRVq4DieDZTvtrFChqcqgCZ//VbQIXYX/vaYyIZE3HgbQqNg==
X-Received: by 2002:a65:41c6:: with SMTP id b6mr30842525pgq.269.1567526765171;
        Tue, 03 Sep 2019 09:06:05 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id t11sm18501567pgb.33.2019.09.03.09.05.50
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Sep 2019 09:06:04 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH 3/5] mm, slab: Remove unused kmalloc_size()
Date: Wed,  4 Sep 2019 00:04:28 +0800
Message-Id: <20190903160430.1368-4-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190903160430.1368-1-lpf.vector@gmail.com>
References: <20190903160430.1368-1-lpf.vector@gmail.com>
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


