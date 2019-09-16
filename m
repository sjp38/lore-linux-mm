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
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3D51C4CECE
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:47:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 620E0206C2
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:47:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IOlY8Iiy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 620E0206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 125186B0010; Mon, 16 Sep 2019 10:47:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D6756B0266; Mon, 16 Sep 2019 10:47:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2EA56B0269; Mon, 16 Sep 2019 10:47:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0116.hostedemail.com [216.40.44.116])
	by kanga.kvack.org (Postfix) with ESMTP id D4E986B0010
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 10:47:28 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 8C18862D0
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:47:28 +0000 (UTC)
X-FDA: 75941062176.15.taste29_24181e529e613
X-HE-Tag: taste29_24181e529e613
X-Filterd-Recvd-Size: 6149
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com [209.85.215.194])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:47:27 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id m29so143575pgc.3
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 07:47:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=MNNib8gt8D5ASBLKcMdRsaxiVFvW1NuIs5T2u607D5s=;
        b=IOlY8IiyhiINdaw4WXA78dm8UGXZyyZz9UFC2pIgNRNJVM280Qj8ycGPH7YGw7kH0r
         RvACjnRmqdnV5s2daW6y8GbvWAg0zD1AcgoChTbMBrCnKcXEimaQ7tn9UmoqsG9Nd0Lf
         aVNwYp6T5hkad6RQ5nyqEdr3M4r334LD2JBL2rniFr3EerOPXGBsrulMerGkXtovTSeT
         Du6uCtTZYHq1XivTzOJy+SNJVqklRUzF7kdgJLWGhkN+vXKGXY77/2UEHr/6iPyw5515
         ApZMAh/hFptfbH5UZQI21J+Ps1NU6EzlidLP8IY0dZNvP/atFQtEJEJpG7a7pMr7RMIn
         ViHQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=MNNib8gt8D5ASBLKcMdRsaxiVFvW1NuIs5T2u607D5s=;
        b=bJKtl04eF4GKHQWkn7MDhHdDKuxXQNO3+wnqXLNF2tvetZnA6+4fxvnSzJcckt3rpU
         z2apx7a2PivGMNl6ADclDBmJYo7LuIy4pG+zPjZRb0p+ZeeLSkCk7x8COqKWRE1jGYsM
         ykEziQbdqHFJgVc5/EOVbe6g/ZyQvPs4EQ3DiiCB/qZtDGLGsgE+Vvi5GAxZiQYxmetS
         JvUDKjOrBQMh0ac96928fsd09jibpn65WQZseYY9GBtZJfVCq3jADxiQhE065tRwZzk8
         Pg0U4h1XfJAHwDsaCmA7ydAdOKAIFsNGGKMFZ40T3MWsIsj4O731yBU1stn8OsMS9NTb
         AfHA==
X-Gm-Message-State: APjAAAVZy/jgzF2xIB1BzEczzvzz52NNanm82xew5YIwigqU8IYgljq0
	8oJVuGxLTeDwXDHr89WOqNc=
X-Google-Smtp-Source: APXvYqwe0QaroPtORfVgYBuaV2agHHnU6wFwMZPYA4cBOqnuAGgRLiJYZymup0lCl846co8IdyPR1g==
X-Received: by 2002:a17:90a:b286:: with SMTP id c6mr84290pjr.1.1568645247003;
        Mon, 16 Sep 2019 07:47:27 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id d190sm15036004pgc.25.2019.09.16.07.47.18
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 16 Sep 2019 07:47:26 -0700 (PDT)
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
Subject: [PATCH v5 6/7] mm, slab_common: Initialize the same size of kmalloc_caches[]
Date: Mon, 16 Sep 2019 22:45:57 +0800
Message-Id: <20190916144558.27282-7-lpf.vector@gmail.com>
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

In the current implementation, KMALLOC_RECLAIM is not initialized
until all the KMALLOC_NORMAL sizes have been initialized.

But for a particular size, create_kmalloc_caches() can be executed
faster by initializing different types of kmalloc in order.

$ ./scripts/bloat-o-meter vmlinux.patch_1-5 vmlinux.patch_1-6
add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-11 (-11)
Function                                     old     new   delta
create_kmalloc_caches                        214     203     -11
Total: Before=3D14788968, After=3D14788957, chg -0.00%

Although the benefits are small (more judgment is made for
robustness), create_kmalloc_caches() is much simpler.

Besides, KMALLOC_DMA will be initialized after "slab_state =3D UP",
this does not seem to be necessary.

Commit f97d5f634d3b ("slab: Common function to create the kmalloc
array") introduces create_kmalloc_caches().

And I found that for SLAB, KMALLOC_DMA is initialized before
"slab_state =3D UP". But for SLUB, KMALLOC_DMA is initialized after
"slab_state =3D UP".

Based on this fact, I think it is okay to initialize KMALLOC_DMA
before "slab_state =3D UP".

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 mm/slab_common.c | 35 +++++++++++++----------------------
 1 file changed, 13 insertions(+), 22 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index eeef5ac8d04d..00f2cfc66dbd 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1168,11 +1168,11 @@ void __init setup_kmalloc_cache_index_table(void)
 		size_index[size_index_elem(i)] =3D 0;
 }
=20
-static void __init
+static __always_inline void __init
 new_kmalloc_cache(int idx, enum kmalloc_cache_type type, slab_flags_t fl=
ags)
 {
-	if (type =3D=3D KMALLOC_RECLAIM)
-		flags |=3D SLAB_RECLAIM_ACCOUNT;
+	if (kmalloc_caches[type][idx])
+		return;
=20
 	kmalloc_caches[type][idx] =3D create_kmalloc_cache(
 					kmalloc_info[idx].name[type],
@@ -1188,30 +1188,21 @@ new_kmalloc_cache(int idx, enum kmalloc_cache_typ=
e type, slab_flags_t flags)
 void __init create_kmalloc_caches(slab_flags_t flags)
 {
 	int i;
-	enum kmalloc_cache_type type;
=20
-	for (type =3D KMALLOC_NORMAL; type <=3D KMALLOC_RECLAIM; type++) {
-		for (i =3D 0; i < KMALLOC_CACHE_NUM; i++) {
-			if (!kmalloc_caches[type][i])
-				new_kmalloc_cache(i, type, flags);
-		}
-	}
+	for (i =3D 0; i < KMALLOC_CACHE_NUM; i++) {
+		new_kmalloc_cache(i, KMALLOC_NORMAL, flags);
=20
-	/* Kmalloc array is now usable */
-	slab_state =3D UP;
+		new_kmalloc_cache(i, KMALLOC_RECLAIM,
+					flags | SLAB_RECLAIM_ACCOUNT);
=20
 #ifdef CONFIG_ZONE_DMA
-	for (i =3D 0; i < KMALLOC_CACHE_NUM; i++) {
-		struct kmem_cache *s =3D kmalloc_caches[KMALLOC_NORMAL][i];
-
-		if (s) {
-			kmalloc_caches[KMALLOC_DMA][i] =3D create_kmalloc_cache(
-				kmalloc_info[i].name[KMALLOC_DMA],
-				kmalloc_info[i].size,
-				SLAB_CACHE_DMA | flags, 0, 0);
-		}
-	}
+		new_kmalloc_cache(i, KMALLOC_DMA,
+					flags | SLAB_CACHE_DMA);
 #endif
+	}
+
+	/* Kmalloc array is now usable */
+	slab_state =3D UP;
 }
 #endif /* !CONFIG_SLOB */
=20
--=20
2.21.0


