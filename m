Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F21C4C4740A
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 01:27:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B26F32171F
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 01:27:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="i+2JgqiH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B26F32171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65FAB6B000D; Mon,  9 Sep 2019 21:27:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E8D66B000E; Mon,  9 Sep 2019 21:27:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B13E6B0010; Mon,  9 Sep 2019 21:27:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0023.hostedemail.com [216.40.44.23])
	by kanga.kvack.org (Postfix) with ESMTP id 275746B000D
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 21:27:32 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id BBD01180AD7C3
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 01:27:31 +0000 (UTC)
X-FDA: 75917273502.16.table43_7be12c01c2c22
X-HE-Tag: table43_7be12c01c2c22
X-Filterd-Recvd-Size: 5412
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com [209.85.215.196])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 01:27:31 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id n4so8907450pgv.2
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 18:27:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=zr0c07NjDmSH5Cw3kJRhGheNFiNUbd4oIPE+u9OeCKU=;
        b=i+2JgqiHkfJqcmzDqkcs4qfcvNvhNPQ3REVa3oPc44GAf/7bIImiNi23ef48RY0uXG
         uKU+2tPJ52bKlMa7MrKaA0tnzTftXyCCwmfi5EBQIRusrsDX/fPM75jVUx7X1X3+4ouG
         /c4cPU+TGRKtyKS23awFLVBrWcU/RoWn3iKWtkUo7eSzgrM6pKnmxzMPXlbfO2Wk+pXV
         7tAamR30FgWwmyX5Rva5xni34jf1N+kq2QJstiyGbb6zdH4GDPlxuh+co+QD3A5mvhTD
         HBQFUNGbiWjKCRLU0n98d6+RnJ/n025w3S5UPUNOEstnpJzxEoyGoha9fLmkJ4YEpz/+
         G4qw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=zr0c07NjDmSH5Cw3kJRhGheNFiNUbd4oIPE+u9OeCKU=;
        b=eIOIS3KN3dal96gQ1dWIijRuHW/EsR/Fa0fiu+dob6zv3Oc4c95xyRXt1WjgLeAJz3
         rfw3mpCIFoYh/okGmocZ4ofmUuUv2Lx/6tjqLvgh9KqiCh5Vhv4ifa1BhARy7SASOVwM
         ObJMsf4J02FKcweRAjsf8wxb5m0XbTkdTcwN9bK4KL9QYB6mB6bwuWQlwCfc4E9x06CY
         /HeXw91Iuic21nxWL62nBpTLvb1B+6bCffRd+/wJ9/PdsJl7IuEQqriskH7fQr7QZ2WS
         XZxMWhpSjA3sGAHlYyjC+/OXqAw+6InEZV8jbRBQEbPqhrzdonk9+6szOB+QXxLoHOoZ
         VsKA==
X-Gm-Message-State: APjAAAUniKNplGZZC29ra4YPQ2i4iAV/fnk9UP1P7yu2sQDXxn7vHK8B
	7oGcdEf/02p7a1iVYMtTPhI=
X-Google-Smtp-Source: APXvYqzf04YdXqiSmGL21oobu5CZLUls6gvxBAfgeGtrP48LXGtZBgSeIhrPeSKpa770i5E7JSZSog==
X-Received: by 2002:a63:c118:: with SMTP id w24mr25202712pgf.347.1568078850216;
        Mon, 09 Sep 2019 18:27:30 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id b20sm19558629pff.158.2019.09.09.18.27.23
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 18:27:29 -0700 (PDT)
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
Subject: [PATCH v3 2/4] mm, slab: Remove unused kmalloc_size()
Date: Tue, 10 Sep 2019 09:26:50 +0800
Message-Id: <20190910012652.3723-3-lpf.vector@gmail.com>
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


