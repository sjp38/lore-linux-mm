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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16082C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 16:05:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C43CC22CF8
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 16:05:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eyiGd1Fn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C43CC22CF8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CACD6B0008; Tue,  3 Sep 2019 12:05:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69F406B000C; Tue,  3 Sep 2019 12:05:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B5386B000D; Tue,  3 Sep 2019 12:05:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0079.hostedemail.com [216.40.44.79])
	by kanga.kvack.org (Postfix) with ESMTP id 3850E6B0008
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 12:05:40 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 59C7B180AD802
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 16:05:39 +0000 (UTC)
X-FDA: 75894084798.11.toes11_6b766ee120520
X-HE-Tag: toes11_6b766ee120520
X-Filterd-Recvd-Size: 8500
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com [209.85.215.196])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 16:05:37 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id 4so5843605pgm.12
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 09:05:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=3R6GNQTCXgbRrWxJjxATxmqs/IqC5x2/MNJljUE6Ja0=;
        b=eyiGd1FnhuKFyvbOO6BoNVfiXcD4NdBKXsJ498SGEjZtnAiwBGPVRuPrU/84gSjRPU
         n/4iGhuTTI7Vv2EVUI2RqCCfy+agbFBHgVPpCQJwNsxXguQxZl3062cKMnaw88bzpBh7
         lEh4tuA5YnUhbgZrwSjRftcxoykuDDx8EM0YNpssc/WWGKU3LX2YlxqDG741IaV7BKh5
         qt1t64ckrcjrYM7iVAdt7awrVCUG7i5zCW1+tbM2wsqiQWl2oUoXZCsS48gkBpwH+bFV
         3ocp/+PA81nIXkreCYiLe56l9AstYLE5nm4nhG8VRts+MBSrlNf6Y6seFKPlX4IIBTrC
         TTiQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=3R6GNQTCXgbRrWxJjxATxmqs/IqC5x2/MNJljUE6Ja0=;
        b=LPBKRZ6vcLgaF+wDAaOOX+cXQ3kSI3szhk4ITBTONffki5fyuk/NXsNVIpmFmapEnC
         eX3Bp4zQmif69rtr6AV3pYhxDGjUk1LE6nzF1O3mo1kmhPXx/gddZ/iUE2lDSinggsLE
         1KXkMRhDeyItv0BdOTu6y/9ZTKJPBSa8gWKE63DO1pMf1hbVf7dle0mzHIjIa8DObbeN
         2iz3f4jnDEIQc5q2fqmFO3UT0qn5GI6bQMt+sZeRlk37R3uj8BNwtkE9XHltL41T20MC
         vBix7CxKMWvgzRa+5boCE0PBUbpG/SUO3uIYEIzhjj/xbTwQ4SNHXOlIiC8Hh433f2Ee
         r16g==
X-Gm-Message-State: APjAAAVgFqmRiHtKE2f1MVM9jSeximBdO07P4wtFfiWIkXrUgSYkrM2D
	7aVS81hwOyKIMl9noUuZEMU=
X-Google-Smtp-Source: APXvYqw7NXxIGPON+s2yb/sK0y+666y8zIxbQ5qMX9j49XhjvvY3OVT8qKJPrXo8/tUrFVETOpVaXQ==
X-Received: by 2002:a17:90a:33a9:: with SMTP id n38mr58186pjb.18.1567526736536;
        Tue, 03 Sep 2019 09:05:36 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id t11sm18501567pgb.33.2019.09.03.09.05.27
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Sep 2019 09:05:36 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH 1/5] mm, slab: Make kmalloc_info[] contain all types of names
Date: Wed,  4 Sep 2019 00:04:26 +0800
Message-Id: <20190903160430.1368-2-lpf.vector@gmail.com>
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

There are three types of kmalloc, KMALLOC_NORMAL, KMALLOC_RECLAIM
and KMALLOC_DMA.

The name of KMALLOC_NORMAL is contained in kmalloc_info[].name,
but the names of KMALLOC_RECLAIM and KMALLOC_DMA are dynamically
generated by kmalloc_cache_name().

This patch predefines the names of all types of kmalloc to save
the time spent dynamically generating names.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 mm/slab.c        |  2 +-
 mm/slab.h        |  2 +-
 mm/slab_common.c | 76 +++++++++++++++++++++++++++++++-----------------
 3 files changed, 51 insertions(+), 29 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 9df370558e5d..c42b6211f42e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1247,7 +1247,7 @@ void __init kmem_cache_init(void)
 	 * structures first.  Without this, further allocations will bug.
 	 */
 	kmalloc_caches[KMALLOC_NORMAL][INDEX_NODE] =3D create_kmalloc_cache(
-				kmalloc_info[INDEX_NODE].name,
+				kmalloc_info[INDEX_NODE].name[KMALLOC_NORMAL],
 				kmalloc_size(INDEX_NODE), ARCH_KMALLOC_FLAGS,
 				0, kmalloc_size(INDEX_NODE));
 	slab_state =3D PARTIAL_NODE;
diff --git a/mm/slab.h b/mm/slab.h
index 9057b8056b07..2fc8f956906a 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -76,7 +76,7 @@ extern struct kmem_cache *kmem_cache;
=20
 /* A table of kmalloc cache names and sizes */
 extern const struct kmalloc_info_struct {
-	const char *name;
+	const char *name[NR_KMALLOC_TYPES];
 	unsigned int size;
 } kmalloc_info[];
=20
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 807490fe217a..7bd88cc09987 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1092,26 +1092,56 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_=
t flags)
 	return kmalloc_caches[kmalloc_type(flags)][index];
 }
=20
+#ifdef CONFIG_ZONE_DMA
+#define SET_KMALLOC_SIZE(__size, __short_size)			\
+{								\
+	.name[KMALLOC_NORMAL]  =3D "kmalloc-" #__short_size,	\
+	.name[KMALLOC_RECLAIM] =3D "kmalloc-rcl-" #__short_size,	\
+	.name[KMALLOC_DMA]     =3D "dma-kmalloc-" #__short_size,	\
+	.size =3D __size,						\
+}
+#else
+#define SET_KMALLOC_SIZE(__size, __short_size)			\
+{								\
+	.name[KMALLOC_NORMAL]  =3D "kmalloc-" #__short_size,	\
+	.name[KMALLOC_RECLAIM] =3D "kmalloc-rcl-" #__short_size,	\
+	.size =3D __size,						\
+}
+#endif
+
 /*
  * kmalloc_info[] is to make slub_debug=3D,kmalloc-xx option work at boo=
t time.
  * kmalloc_index() supports up to 2^26=3D64MB, so the final entry of the=
 table is
  * kmalloc-67108864.
  */
 const struct kmalloc_info_struct kmalloc_info[] __initconst =3D {
-	{NULL,                      0},		{"kmalloc-96",             96},
-	{"kmalloc-192",           192},		{"kmalloc-8",               8},
-	{"kmalloc-16",             16},		{"kmalloc-32",             32},
-	{"kmalloc-64",             64},		{"kmalloc-128",           128},
-	{"kmalloc-256",           256},		{"kmalloc-512",           512},
-	{"kmalloc-1k",           1024},		{"kmalloc-2k",           2048},
-	{"kmalloc-4k",           4096},		{"kmalloc-8k",           8192},
-	{"kmalloc-16k",         16384},		{"kmalloc-32k",         32768},
-	{"kmalloc-64k",         65536},		{"kmalloc-128k",       131072},
-	{"kmalloc-256k",       262144},		{"kmalloc-512k",       524288},
-	{"kmalloc-1M",        1048576},		{"kmalloc-2M",        2097152},
-	{"kmalloc-4M",        4194304},		{"kmalloc-8M",        8388608},
-	{"kmalloc-16M",      16777216},		{"kmalloc-32M",      33554432},
-	{"kmalloc-64M",      67108864}
+	SET_KMALLOC_SIZE(0, 0),
+	SET_KMALLOC_SIZE(96, 96),
+	SET_KMALLOC_SIZE(192, 192),
+	SET_KMALLOC_SIZE(8, 8),
+	SET_KMALLOC_SIZE(16, 16),
+	SET_KMALLOC_SIZE(32, 32),
+	SET_KMALLOC_SIZE(64, 64),
+	SET_KMALLOC_SIZE(128, 128),
+	SET_KMALLOC_SIZE(256, 256),
+	SET_KMALLOC_SIZE(512, 512),
+	SET_KMALLOC_SIZE(1024, 1k),
+	SET_KMALLOC_SIZE(2048, 2k),
+	SET_KMALLOC_SIZE(4096, 4k),
+	SET_KMALLOC_SIZE(8192, 8k),
+	SET_KMALLOC_SIZE(16384, 16k),
+	SET_KMALLOC_SIZE(32768, 32k),
+	SET_KMALLOC_SIZE(65536, 64k),
+	SET_KMALLOC_SIZE(131072, 128k),
+	SET_KMALLOC_SIZE(262144, 256k),
+	SET_KMALLOC_SIZE(524288, 512k),
+	SET_KMALLOC_SIZE(1048576, 1M),
+	SET_KMALLOC_SIZE(2097152, 2M),
+	SET_KMALLOC_SIZE(4194304, 4M),
+	SET_KMALLOC_SIZE(8388608, 8M),
+	SET_KMALLOC_SIZE(16777216, 16M),
+	SET_KMALLOC_SIZE(33554432, 32M),
+	SET_KMALLOC_SIZE(67108864, 64M)
 };
=20
 /*
@@ -1179,18 +1209,11 @@ kmalloc_cache_name(const char *prefix, unsigned i=
nt size)
 static void __init
 new_kmalloc_cache(int idx, int type, slab_flags_t flags)
 {
-	const char *name;
-
-	if (type =3D=3D KMALLOC_RECLAIM) {
+	if (type =3D=3D KMALLOC_RECLAIM)
 		flags |=3D SLAB_RECLAIM_ACCOUNT;
-		name =3D kmalloc_cache_name("kmalloc-rcl",
-						kmalloc_info[idx].size);
-		BUG_ON(!name);
-	} else {
-		name =3D kmalloc_info[idx].name;
-	}
=20
-	kmalloc_caches[type][idx] =3D create_kmalloc_cache(name,
+	kmalloc_caches[type][idx] =3D create_kmalloc_cache(
+					kmalloc_info[idx].name[type],
 					kmalloc_info[idx].size, flags, 0,
 					kmalloc_info[idx].size);
 }
@@ -1232,11 +1255,10 @@ void __init create_kmalloc_caches(slab_flags_t fl=
ags)
=20
 		if (s) {
 			unsigned int size =3D kmalloc_size(i);
-			const char *n =3D kmalloc_cache_name("dma-kmalloc", size);
=20
-			BUG_ON(!n);
 			kmalloc_caches[KMALLOC_DMA][i] =3D create_kmalloc_cache(
-				n, size, SLAB_CACHE_DMA | flags, 0, 0);
+				kmalloc_info[i].name[KMALLOC_DMA],
+				size, SLAB_CACHE_DMA | flags, 0, 0);
 		}
 	}
 #endif
--=20
2.21.0


