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
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1F92C4CEC7
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 16:52:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6791F216F4
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 16:52:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Wv2SR5sO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6791F216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1CBFB6B0006; Sun, 15 Sep 2019 12:52:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 153C76B000A; Sun, 15 Sep 2019 12:52:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0423B6B000C; Sun, 15 Sep 2019 12:52:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0251.hostedemail.com [216.40.44.251])
	by kanga.kvack.org (Postfix) with ESMTP id D4B9D6B0006
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 12:52:39 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 8B0382C07
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 16:52:39 +0000 (UTC)
X-FDA: 75937748838.11.hole63_3441fb1e10563
X-HE-Tag: hole63_3441fb1e10563
X-Filterd-Recvd-Size: 5098
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com [209.85.215.195])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 16:52:38 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id n190so18048833pgn.0
        for <linux-mm@kvack.org>; Sun, 15 Sep 2019 09:52:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=nii43oMTaFtktKbnijjugyrLFfb5ZKvbiN8kMj3vNPE=;
        b=Wv2SR5sO7CBMS93mcNuzKaC33L131eKLxc2sWGOw4gZsA2mpeA6eOWAaQ/RIHpcvzE
         UYJ4XZ0cp7TvEj4HUH5RXcDkYGpi4w7RgV9JDzthjil/VX+OCBWBLiGeksGPio5nQ4W/
         n+P7xO6d5cPH1Y2J1pefYxNd2a+8t/tYy1U5iv+qth1jnHJ5CU82f/XrNno5sG7w6YdU
         k8CQzOk8cSFIhkYRzTxSKtBvSH2vA3zRKAyWAPB3rtnYqJJ23EwyaBpsmIiHUeFdrX++
         aRpLJJDVoVUYXcJKu5QRRIglkt97eQgVnqG/6gNYv3YgbZY8dd7gDsjlzpAuZyCQ/9hB
         GHpQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=nii43oMTaFtktKbnijjugyrLFfb5ZKvbiN8kMj3vNPE=;
        b=jVbSCbrSZ5yJ+shiHCocJUQ7gsS1egp33wCCc7wrEVmGbKBJdnylMmv9oZIbvJ9iJN
         XejujOKlg/hx0kwd0HNJitDMqvkm+3NS8vgHrdPNJ7GXI0A6tyZ9yGv0UnSm3hm97tAo
         Wvea1Opm+6+6SNqLbg5jfZz3ffzNz0oi8gQkAhI7QyMyTeVq0kQYHa+XvCihRrWnQkCn
         MykRjk0rFJp3iB+NDfmkshsWwZEsdSaO9LjZClGtn7rMfrWW+DWS2+xeZeO7Py0HfiG/
         q0jLr4+V+oQZJa6HbpSYs17qmvFqSHIzqxzBYkBSMWfV6vdrtLbmEMZBYQdTXqIZhWkn
         AV2w==
X-Gm-Message-State: APjAAAUtZ+I+A0DdWAY01G8Aea8T5BHNNz9ytdAfW3x3qtfeZg7ofhzQ
	xC0hKkToIo8JFXXfcmpEeVQ=
X-Google-Smtp-Source: APXvYqxYf54cYNQWLvZP6JklEbGw44XbGka9yQDf7cpKtKvKEjKS+BbJ7rhYqAqRIGCfavv9PckRFQ==
X-Received: by 2002:aa7:8f03:: with SMTP id x3mr66745495pfr.91.1568566358307;
        Sun, 15 Sep 2019 09:52:38 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id a4sm4383259pgq.6.2019.09.15.09.52.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Sep 2019 09:52:37 -0700 (PDT)
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
Subject: [PATCH v4 4/7] mm, slab: return ZERO_SIZE_ALLOC for zero sized kmalloc requests
Date: Mon, 16 Sep 2019 00:51:14 +0800
Message-Id: <20190915165121.7237-6-lpf.vector@gmail.com>
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

This is a preparation patch, just replace 0 with ZERO_SIZE_ALLOC
as the return value of zero sized requests.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 include/linux/slab.h | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index e773e5764b7b..1f05f68f2c3e 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -121,14 +121,20 @@
 #define SLAB_DEACTIVATED	((slab_flags_t __force)0x10000000U)
=20
 /*
- * ZERO_SIZE_PTR will be returned for zero sized kmalloc requests.
+ * ZERO_SIZE_ALLOC will be returned by kmalloc_index() if it was zero si=
zed
+ * requests.
  *
+ * After that, ZERO_SIZE_PTR will be returned by the function that calle=
d
+ * kmalloc_index().
+
  * Dereferencing ZERO_SIZE_PTR will lead to a distinct access fault.
  *
  * ZERO_SIZE_PTR can be passed to kfree though in the same way that NULL=
 can.
  * Both make kfree a no-op.
  */
-#define ZERO_SIZE_PTR ((void *)16)
+#define ZERO_SIZE_ALLOC		(UINT_MAX)
+
+#define ZERO_SIZE_PTR		((void *)16)
=20
 #define ZERO_OR_NULL_PTR(x) ((unsigned long)(x) <=3D \
 				(unsigned long)ZERO_SIZE_PTR)
@@ -350,7 +356,7 @@ static __always_inline enum kmalloc_cache_type kmallo=
c_type(gfp_t flags)
 static __always_inline unsigned int kmalloc_index(size_t size)
 {
 	if (!size)
-		return 0;
+		return ZERO_SIZE_ALLOC;
=20
 	if (size <=3D KMALLOC_MIN_SIZE)
 		return KMALLOC_SHIFT_LOW;
@@ -546,7 +552,7 @@ static __always_inline void *kmalloc(size_t size, gfp=
_t flags)
 #ifndef CONFIG_SLOB
 		index =3D kmalloc_index(size);
=20
-		if (!index)
+		if (index =3D=3D ZERO_SIZE_ALLOC)
 			return ZERO_SIZE_PTR;
=20
 		return kmem_cache_alloc_trace(
@@ -564,7 +570,7 @@ static __always_inline void *kmalloc_node(size_t size=
, gfp_t flags, int node)
 		size <=3D KMALLOC_MAX_CACHE_SIZE) {
 		unsigned int i =3D kmalloc_index(size);
=20
-		if (!i)
+		if (i =3D=3D ZERO_SIZE_ALLOC)
 			return ZERO_SIZE_PTR;
=20
 		return kmem_cache_alloc_node_trace(
--=20
2.21.0


