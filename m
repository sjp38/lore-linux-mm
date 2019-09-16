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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D8B0C49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:46:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D53621670
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:46:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BmJ5hx5b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D53621670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD0946B000A; Mon, 16 Sep 2019 10:46:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA71F6B000C; Mon, 16 Sep 2019 10:46:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBC946B000D; Mon, 16 Sep 2019 10:46:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0101.hostedemail.com [216.40.44.101])
	by kanga.kvack.org (Postfix) with ESMTP id AB3116B000A
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 10:46:45 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 5412F181AC9AE
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:46:45 +0000 (UTC)
X-FDA: 75941060370.12.art13_1dca717ae2c2d
X-HE-Tag: art13_1dca717ae2c2d
X-Filterd-Recvd-Size: 5462
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:46:44 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id 205so44520pfw.2
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 07:46:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=d7Q0z2EasZ8/1ldA12KLzNbebPjqFp3ShlnBdaO1amY=;
        b=BmJ5hx5bZeYzBaMASNSBw7TKgI8T7IVDzo+AXUN2oSUIlaTP7YJxGtSd0pJWV1Vs9r
         6ZAn7Ja08Yrd3PP4tJ/j03GSLhLfjub1yp/1hMNM4ZACT89L7mS3gWZFe5Y4AS6WuCxv
         Uq1eECAtwGOmRZoCKIImWTnydyaGZJxL77AvGPnUo2bJKH3h9uZZVN9OJ69WldsdCLVb
         BzX/FLRAMZL75nm5ozBNb1RWKrf15wKqnqlVPi60uhPqI5xLdNwDf2yy9htLeVZ5wiNz
         4PqAS9SV/5Huxe9n45jQMKxeLK4Bi9thYUvQiw+3v22lZevqW7D78kaCUJVhKh7bHfsc
         /c6g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=d7Q0z2EasZ8/1ldA12KLzNbebPjqFp3ShlnBdaO1amY=;
        b=QQZ/YDZErXxJlZNFUMOH3LV3IMGurQFeHiaUuKtCWXwlBvT1gh+xteqO8tIUJYU9+b
         9pgbUaAZR11Gq+LHm92WFhzI5SzzQ1gt0KiHtliAif8SBGF6RZjO7TE6txFQCcTi1PBT
         /tyCZtGfUKmL4/rcxTUt0UgWRZ4vMFhshs5CbnxabzQixdhJxSYc2FeXNppq3dgtW8um
         x+EdKHrCAzQJOXX62nddmGCKKGEKtg2AG1/CY3VAyNg0XHmmtvaqShoEZtzmEgX2pypw
         vDnRgZugtAdM+aqFcTX72wLx3y6HjLSKAMxbsAqJmtdbsr5uMq/zZy8nMFkAVJu+OEP1
         LeTA==
X-Gm-Message-State: APjAAAWMzJTwmjKWWU7hE3qg7erFrUtD/41Njl2Zfm/5z64ooIeRt7Sg
	KL9RiyvKBilwwwlX3mJ0SeA=
X-Google-Smtp-Source: APXvYqyZZupA7waxaBg53lTnH6e5LUJ+eqZAgQ/hO1ZOP8yq6SUAJruqY8t8GbSlhBFk9FUwd8J4Vw==
X-Received: by 2002:a62:75d2:: with SMTP id q201mr71101005pfc.43.1568645203635;
        Mon, 16 Sep 2019 07:46:43 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id d190sm15036004pgc.25.2019.09.16.07.46.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 16 Sep 2019 07:46:42 -0700 (PDT)
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
Subject: [PATCH v5 2/7] mm, slab: Remove unused kmalloc_size()
Date: Mon, 16 Sep 2019 22:45:53 +0800
Message-Id: <20190916144558.27282-3-lpf.vector@gmail.com>
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

The size of kmalloc can be obtained from kmalloc_info[],
so remove kmalloc_size() that will not be used anymore.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Roman Gushchin <guro@fb.com>
Acked-by: David Rientjes <rientjes@google.com>
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
index 4e78490292df..df030cf9f44f 100644
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


