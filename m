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
	by smtp.lore.kernel.org (Postfix) with ESMTP id F199DC4CEC7
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 17:09:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA49621479
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 17:09:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ANNQcHBe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA49621479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B66A6B026B; Sun, 15 Sep 2019 13:09:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5406D6B026D; Sun, 15 Sep 2019 13:09:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 407416B026E; Sun, 15 Sep 2019 13:09:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0084.hostedemail.com [216.40.44.84])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3A06B026D
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 13:09:13 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 95921824CA36
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 17:09:12 +0000 (UTC)
X-FDA: 75937790544.21.metal04_333e344c76726
X-HE-Tag: metal04_333e344c76726
X-Filterd-Recvd-Size: 6321
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com [209.85.215.196])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 17:09:11 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id 4so18023036pgm.12
        for <linux-mm@kvack.org>; Sun, 15 Sep 2019 10:09:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=3ghBrDy6wMKk43GDL/rFQB3qO4WlHynWL3G2LPomcOY=;
        b=ANNQcHBepw6eqK2TUsOonsPcZHpQ31HyjAqQ5GpjC1GXjc3vkSr7FVAF2g9z64OmzM
         tiaOv4HLHT9eMX+otd9hySdwzsxt240NNfBB270xdh909hG73HSDUXCCeGjTlqc7+zgM
         tCUb7tdc9gFK45+zYxujcpquqA3QxzQ9S4EKUaMRgF4sW8TCEO94WmhLzSGclFJBNBfI
         ODnsAc2L2tEcBUfEOpB62gH6lGfg3MgEy9057ZKX312vC21jG3llCUE87k2hbinoMEB8
         jF5U3kFsZobrVujxFynsCiHBvRN38bJF/HKTCmjWrJdYpZSDMW8gmMl6McQrVxK0DttK
         7Bnw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=3ghBrDy6wMKk43GDL/rFQB3qO4WlHynWL3G2LPomcOY=;
        b=LJ0/jrmTEkqI5qgBh66m079plcwS8yY80KZvUVL8ncBIfEe16aeCMHQT6yA6apGjPI
         mndqpws2SUM7I4I026FCGdxNBh74/fh+t+UqYNakGWqER9g9bUufTsP5XUZmtdutOY+C
         G00ayvfV8bOJzeYbPReeT0/RjB1HJNGzfqz9FYJ9MwjNHjJ616nnk5DD38ohhIn+5Tjs
         FBZAhLbC04MHiiv56OfglAso89j7Jijyw285L1nGV50KA+sid0YV+4/e7500ISJ5HNEA
         +q4Zg+1e19t2MnRkbjv0Z8fnUyTei/TZXPBymfmm1f62aJUUUR28grYTu7YLq5Z9ImzA
         +o7w==
X-Gm-Message-State: APjAAAVsbWkXRoFAIaXchbLuINL8siXdrw+SBVFfIvwMZmO3hr8VZFFR
	nGgBc/KxdBxJdkwxnTm8L18=
X-Google-Smtp-Source: APXvYqwd1Gu7Oj+hAUr55jham6Nk02gWInO/JZ+/9i9r2KKbdnRq111MTKjlBkJUa2qkqz6p+hpyRA==
X-Received: by 2002:a65:5082:: with SMTP id r2mr51718854pgp.170.1568567351236;
        Sun, 15 Sep 2019 10:09:11 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id r28sm62279134pfg.62.2019.09.15.10.09.04
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Sep 2019 10:09:10 -0700 (PDT)
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
Subject: [RESEND v4 6/7] mm, slab_common: Initialize the same size of kmalloc_caches[]
Date: Mon, 16 Sep 2019 01:08:08 +0800
Message-Id: <20190915170809.10702-7-lpf.vector@gmail.com>
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

In the current implementation, KMALLOC_RECLAIM is not initialized
until all the KMALLOC_NORMAL sizes have been initialized.

But for a particular size, create_kmalloc_caches() can be executed
faster by initializing different types of kmalloc in order.

$ ./scripts/bloat-o-meter vmlinux.old vmlinux.patch_1-5
add/remove: 1/2 grow/shrink: 6/64 up/down: 872/-1113 (-241)
Function                                     old     new   delta
create_kmalloc_caches                        270     214     -56

$ ./scripts/bloat-o-meter vmlinux.old vmlinux.patch_1-6
add/remove: 1/2 grow/shrink: 6/64 up/down: 872/-1172 (-300)
Function                                     old     new   delta
create_kmalloc_caches                        270     155    -115

We can see that it really gets the benefits.

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
 mm/slab_common.c | 35 ++++++++++++-----------------------
 1 file changed, 12 insertions(+), 23 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 2aed30deb071..e7903bd28b1f 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1165,12 +1165,9 @@ void __init setup_kmalloc_cache_index_table(void)
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
-
 	kmalloc_caches[type][idx] =3D create_kmalloc_cache(
 					kmalloc_info[idx].name[type],
 					kmalloc_info[idx].size, flags, 0,
@@ -1185,30 +1182,22 @@ new_kmalloc_cache(int idx, enum kmalloc_cache_typ=
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
+		if (!kmalloc_caches[KMALLOC_NORMAL][i])
+			new_kmalloc_cache(i, KMALLOC_NORMAL, flags);
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


