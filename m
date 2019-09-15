Return-Path: <SRS0=FJsX=XK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50813C4CECC
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 17:08:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B95221479
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 17:08:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bMJj+06m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B95221479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B34EE6B026B; Sun, 15 Sep 2019 13:08:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABE126B026C; Sun, 15 Sep 2019 13:08:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9859A6B026D; Sun, 15 Sep 2019 13:08:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0205.hostedemail.com [216.40.44.205])
	by kanga.kvack.org (Postfix) with ESMTP id 74D066B026B
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 13:08:41 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 2060F55FAB
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 17:08:41 +0000 (UTC)
X-FDA: 75937789242.28.watch59_2ea6a40bced3b
X-HE-Tag: watch59_2ea6a40bced3b
X-Filterd-Recvd-Size: 5414
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com [209.85.215.195])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 17:08:40 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id n9so18071002pgc.1
        for <linux-mm@kvack.org>; Sun, 15 Sep 2019 10:08:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=zr0c07NjDmSH5Cw3kJRhGheNFiNUbd4oIPE+u9OeCKU=;
        b=bMJj+06mx2KCeF5+czFUmggdyS3AWD3yVKsqp5d1AtESbFoVxpD9DFLBgg83bhCE6x
         tkPO/CFOhFNGfImROR/tTFyfMzH/rUlECA9rtUz2zx7+g5+L31x6bT867cCKcuqfhOF/
         2YjfDVJz+AwxOCk5Z3eLbnWLPR0fWap4Rl9IcGqeMSxudfRz2mJ1VOUB/uPmSEngbZ7Q
         EE8Cz0OV5ryE9rZgkODMg7jEi7CFTEIkLGUEtu1ls4IPE8VZSGxe/2K5lPCR75mcoUHw
         ZwhQgUJhmCohWLzGfrFY4FsiYEYQLCs+h5bmAljsUtDw5Ny+NiQyc13+tt63/lKIMGi4
         qM3w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=zr0c07NjDmSH5Cw3kJRhGheNFiNUbd4oIPE+u9OeCKU=;
        b=DA6NIxEHVa2KoaOk3XRK44Q3vZPyTPmGdV4NGeLuNxdjk9aBTImTLl8PsR8X6AcQi7
         1mnCPLI8MqAxQqFbc/2RmYu01fsQZkB4hm/La62QJAoQTQ1R7ZbPY52znmSQkNnmoLgE
         zEzCqfnsUe7UDmpFguuME48uUOZA+fw3s2K5Iql4LfjzHvkIOuomOAl9zNpZM91V76C1
         sg9qdhKzgIMZGS89UdbdwjIRXqvLZQuTFbXGXtsUYGYmKFPtBSRVBtuKW/qU1LPEF8YV
         W6eL8EYNL3DsSIvlYTlmGRH8SC2HHThiDwU2Z1iu3jKB4eoNeBNmqLLGOQDcpc6mLaxl
         v04g==
X-Gm-Message-State: APjAAAV1kAbY0Zd/mdaqGSPiaEGIldYCyNJrTNvsaUxsYsYOik9/bv0x
	zgYL8y4eZoMhKs0dgbbR7bY=
X-Google-Smtp-Source: APXvYqxlCLcNUJ4gfIt5Y94i9kDi1PCs2O2NAzHxRSL+j7LpBfj3+Z9B4OG4iTMlK2awRx+JFfBCVQ==
X-Received: by 2002:a65:6709:: with SMTP id u9mr23349139pgf.59.1568567319705;
        Sun, 15 Sep 2019 10:08:39 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id r28sm62279134pfg.62.2019.09.15.10.08.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Sep 2019 10:08:39 -0700 (PDT)
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
Subject: [RESEND v4 2/7] mm, slab: Remove unused kmalloc_size()
Date: Mon, 16 Sep 2019 01:08:04 +0800
Message-Id: <20190915170809.10702-3-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190915170809.10702-1-lpf.vector@gmail.com>
References: <20190915170809.10702-1-lpf.vector@gmail.com>
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


