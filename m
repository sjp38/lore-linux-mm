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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16EF0C4CEC7
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 16:52:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C482E214D8
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 16:52:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HxyRRhku"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C482E214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 770C56B0006; Sun, 15 Sep 2019 12:52:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F9FE6B0007; Sun, 15 Sep 2019 12:52:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E8576B0008; Sun, 15 Sep 2019 12:52:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0047.hostedemail.com [216.40.44.47])
	by kanga.kvack.org (Postfix) with ESMTP id 380FE6B0006
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 12:52:05 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id D40843AB7
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 16:52:04 +0000 (UTC)
X-FDA: 75937747368.18.fly07_2f30f51d5562f
X-HE-Tag: fly07_2f30f51d5562f
X-Filterd-Recvd-Size: 9003
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com [209.85.214.193])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 16:52:04 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id e5so4487658pls.9
        for <linux-mm@kvack.org>; Sun, 15 Sep 2019 09:52:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=7ScgMFAOOXn7zrz2ktcww61aqak7m9GXt4/M+m23yyA=;
        b=HxyRRhku+r+TWCBAeSOnIQ/EV7x2QfkHNrITn82kiYpKsbeLxWalOoqLcGZiMO2z/6
         6HXZ+bPn45R+gDk3qwX/jsrW3TFWLiqh28peqMPYfQqYt3Y1rL+WGb4dDVFLKRm358yd
         dnm7Wu+6UbpO3K+7d09az1olEAkvVB1KE+beZAfVQ9zfYBxOKgcuV86HrnomhJJydfpG
         0pFUeiFklihtM5JyCa/q8JzMCKUpADTqp6yaZNjdEb88bnnQGPRcv64AQkLE1uVAvJ07
         3fLlMKjJlsIb04/W+G+ZVMFGPPoNHp/waHsijysHPzgd7XGcAvJ8HZmm+BLwup2nVgpd
         l1sA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=7ScgMFAOOXn7zrz2ktcww61aqak7m9GXt4/M+m23yyA=;
        b=RAGU8UMOo5XKloCst5FQrh+5eu2FlUU7LUsaU/ss9xnsEef0o+x2ctYLYrXMfs4Q1b
         Hccr/QuWLQnxnAqwBd0c6qi0Q5Z826WWYdupeoDiwzVhINUaXWYxD51r0aVf8D0cdXgt
         l/Q9IgbtelEdzhVy4jLHitLaGFkEHd8bNBfGXG/4BIg7Sk7eZDsEEziXiJiw0lBHp4x1
         ErzEKfgVEptc0tIQoXDp+oY/u9R3Pnb/eU+uGl6FT5g8DD7QRVE4qAXSWT7s+qRkHMTL
         hf0ZS5BAQatnNJnHc0rSy59O6cM2es9wNJZosoMcpYTzIadT4IgIbhK3xPvtfRcR1e2e
         VBSA==
X-Gm-Message-State: APjAAAVRYGMUb20DZYpjY8YW8PHZRIQhlg1qBC7Ta7JDwlBkVOz9pwoP
	d5klIZcPdgHdzy8lbde6MM0=
X-Google-Smtp-Source: APXvYqwLsuJ8IOV6Qqs3dL5Nh1ny0IcSVM+V3+VVQm14YEenWTXg4JGweX73Nhexh782NmXKFVb8iQ==
X-Received: by 2002:a17:902:780c:: with SMTP id p12mr58796959pll.290.1568566323340;
        Sun, 15 Sep 2019 09:52:03 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id a4sm4383259pgq.6.2019.09.15.09.51.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Sep 2019 09:52:02 -0700 (PDT)
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
Subject: [PATCH v4 1/7] mm, slab: Make kmalloc_info[] contain all types of names
Date: Mon, 16 Sep 2019 00:51:10 +0800
Message-Id: <20190915165121.7237-2-lpf.vector@gmail.com>
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

There are three types of kmalloc, KMALLOC_NORMAL, KMALLOC_RECLAIM
and KMALLOC_DMA.

The name of KMALLOC_NORMAL is contained in kmalloc_info[].name,
but the names of KMALLOC_RECLAIM and KMALLOC_DMA are dynamically
generated by kmalloc_cache_name().

This patch predefines the names of all types of kmalloc to save
the time spent dynamically generating names.

Besides, remove the kmalloc_cache_name() that is no longer used.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Roman Gushchin <guro@fb.com>
---
 mm/slab.c        |  2 +-
 mm/slab.h        |  2 +-
 mm/slab_common.c | 91 ++++++++++++++++++++++++++----------------------
 3 files changed, 51 insertions(+), 44 deletions(-)

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
index 807490fe217a..002e16673581 100644
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
@@ -1161,36 +1191,14 @@ void __init setup_kmalloc_cache_index_table(void)
 	}
 }
=20
-static const char *
-kmalloc_cache_name(const char *prefix, unsigned int size)
-{
-
-	static const char units[3] =3D "\0kM";
-	int idx =3D 0;
-
-	while (size >=3D 1024 && (size % 1024 =3D=3D 0)) {
-		size /=3D 1024;
-		idx++;
-	}
-
-	return kasprintf(GFP_NOWAIT, "%s-%u%c", prefix, size, units[idx]);
-}
-
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
@@ -1232,11 +1240,10 @@ void __init create_kmalloc_caches(slab_flags_t fl=
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


