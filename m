Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.3 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F54AC49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:46:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F14F12171F
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:46:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lxp0jGsW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F14F12171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 915F06B0008; Mon, 16 Sep 2019 10:46:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8ED1A6B000A; Mon, 16 Sep 2019 10:46:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80E0A6B000C; Mon, 16 Sep 2019 10:46:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0154.hostedemail.com [216.40.44.154])
	by kanga.kvack.org (Postfix) with ESMTP id 613F66B0008
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 10:46:35 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 041EB52D8
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:46:35 +0000 (UTC)
X-FDA: 75941059950.08.kiss36_1c4e4a44a901e
X-HE-Tag: kiss36_1c4e4a44a901e
X-Filterd-Recvd-Size: 9086
Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com [209.85.214.194])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:46:34 +0000 (UTC)
Received: by mail-pl1-f194.google.com with SMTP id x3so17000036plr.12
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 07:46:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=dZvPUhHT8+0/JcqR3/I68iZikorHw/l25qBcUtuCr9U=;
        b=lxp0jGsW5SKgtGeD68P/E+1P1Z1JXtgMeabFqU7FkL/ETQnxsbVwwCLgEXexmLnkRH
         iMxuitWshQqwoFx1ADGIlpCMnVO2qwzbSYWeFvnCbyeJft+ha2ZXy1rJ94ZfandF/PlX
         K+lUHKabM+lE6sWb+nvz4kRYjETieJk/rRMKwgHxRucGCmsPSkLpFby0dVRaDPJQIafa
         L+X/vFeLPxj2Xl1/zCgQOFt3JEGknlKdZYBm1jUTfWqa77ef7OEMXNi6FYzG9KHbosv0
         O0OQokmUSsksjgMWUI/vpkfNj/XHxNxp54vPeNUB6o1JhQdtCZ850WNvnVyv4Y7qo6+3
         fzjw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=dZvPUhHT8+0/JcqR3/I68iZikorHw/l25qBcUtuCr9U=;
        b=SFyH6Zm75D0mWnMIDHlIe6dWkF98OLm0w1BsQEI0PXY0ByFSxWXgYpGRYA9J2bmn2i
         hl7krfz+hXSg1s1VZy+49HuYUUur7zBROQ8tUd0LI6o5lPgzzDdHlkUmGa3URoMuQdJG
         Jbf5g9KUAQ3M1fdT8rFxf7pPsjv3C9UBF9kQBm3qFb04aXVbti+1A8EnwKrl1hg50b4T
         pPAqkhPvXl329Lwq83KgU3t4EfEMADqSWkIRxRl1b9rnvOYSqaZRragJdirTl0PwkdBS
         tOVDTEtw2YM/AFHV5x0p1yItxIpFds6XwpP24XoC94rWhS/LW4eSCf5RMtQnVgO5bTXh
         ryFA==
X-Gm-Message-State: APjAAAXOQMVb2f7i+NIvjiE8Lqk7GhVAoOU+KlyznLmCpX6RNUKHUB8i
	/IZa4veudAcPTBuSLKJkiFY=
X-Google-Smtp-Source: APXvYqw5GgPczEn9LOIYLaCdLz+m++WYbNMNkyqhk4eD3gdEPa40dsAcO+vIL7GTieCB76CZxxJxvA==
X-Received: by 2002:a17:902:6b06:: with SMTP id o6mr141532plk.129.1568645193523;
        Mon, 16 Sep 2019 07:46:33 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id d190sm15036004pgc.25.2019.09.16.07.46.23
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 16 Sep 2019 07:46:32 -0700 (PDT)
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
Subject: [PATCH v5 1/7] mm, slab: Make kmalloc_info[] contain all types of names
Date: Mon, 16 Sep 2019 22:45:52 +0800
Message-Id: <20190916144558.27282-2-lpf.vector@gmail.com>
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
Acked-by: David Rientjes <rientjes@google.com>
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
index 807490fe217a..4e78490292df 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1092,26 +1092,56 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_=
t flags)
 	return kmalloc_caches[kmalloc_type(flags)][index];
 }
=20
+#ifdef CONFIG_ZONE_DMA
+#define INIT_KMALLOC_INFO(__size, __short_size)			\
+{								\
+	.name[KMALLOC_NORMAL]  =3D "kmalloc-" #__short_size,	\
+	.name[KMALLOC_RECLAIM] =3D "kmalloc-rcl-" #__short_size,	\
+	.name[KMALLOC_DMA]     =3D "dma-kmalloc-" #__short_size,	\
+	.size =3D __size,						\
+}
+#else
+#define INIT_KMALLOC_INFO(__size, __short_size)			\
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
+	INIT_KMALLOC_INFO(0, 0),
+	INIT_KMALLOC_INFO(96, 96),
+	INIT_KMALLOC_INFO(192, 192),
+	INIT_KMALLOC_INFO(8, 8),
+	INIT_KMALLOC_INFO(16, 16),
+	INIT_KMALLOC_INFO(32, 32),
+	INIT_KMALLOC_INFO(64, 64),
+	INIT_KMALLOC_INFO(128, 128),
+	INIT_KMALLOC_INFO(256, 256),
+	INIT_KMALLOC_INFO(512, 512),
+	INIT_KMALLOC_INFO(1024, 1k),
+	INIT_KMALLOC_INFO(2048, 2k),
+	INIT_KMALLOC_INFO(4096, 4k),
+	INIT_KMALLOC_INFO(8192, 8k),
+	INIT_KMALLOC_INFO(16384, 16k),
+	INIT_KMALLOC_INFO(32768, 32k),
+	INIT_KMALLOC_INFO(65536, 64k),
+	INIT_KMALLOC_INFO(131072, 128k),
+	INIT_KMALLOC_INFO(262144, 256k),
+	INIT_KMALLOC_INFO(524288, 512k),
+	INIT_KMALLOC_INFO(1048576, 1M),
+	INIT_KMALLOC_INFO(2097152, 2M),
+	INIT_KMALLOC_INFO(4194304, 4M),
+	INIT_KMALLOC_INFO(8388608, 8M),
+	INIT_KMALLOC_INFO(16777216, 16M),
+	INIT_KMALLOC_INFO(33554432, 32M),
+	INIT_KMALLOC_INFO(67108864, 64M)
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


