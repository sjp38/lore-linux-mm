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
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0D58C4CEC7
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 16:52:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B6C7214D8
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 16:52:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UVlqUskF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B6C7214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EDDA6B0003; Sun, 15 Sep 2019 12:52:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39DC56B000A; Sun, 15 Sep 2019 12:52:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 240BE6B000C; Sun, 15 Sep 2019 12:52:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0208.hostedemail.com [216.40.44.208])
	by kanga.kvack.org (Postfix) with ESMTP id 048106B0003
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 12:52:30 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 745F34833
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 16:52:30 +0000 (UTC)
X-FDA: 75937748460.14.story48_32ee16a52af20
X-HE-Tag: story48_32ee16a52af20
X-Filterd-Recvd-Size: 4222
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com [209.85.215.196])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 16:52:29 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id 4so18002613pgm.12
        for <linux-mm@kvack.org>; Sun, 15 Sep 2019 09:52:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=X86RdWoaDKqJbFDIoXti2bda7+kkyeUkiLhSN5JzlKU=;
        b=UVlqUskFF6lnSRhNIDONapUfjNYD1Nk3plqN/bZfrOxvI8jXvH2brUc3nFqa8l6/m2
         bzJoXmb99FvFIz8wmkMhFV8OrapnQW+3rgFRcQi84Q0rv0sEXDlzjG35LkxFo4BzBimx
         E/DEAi8w4LF2wNQ9W3KGhbSNq5T9370tn/2S3iEdZ31+bKcaRwRryklJJW1LxakGJwP2
         hmryWpIP5WkJwKDqp2xJL8DpIbGmxZLsRXNr1cJQReJNW2y3Wzy84f0UJnpanyBiaQKz
         HkHjvIcUU5OcKS+Dn6CCbRB2JjmXiiti8WZT7vWc8yYfL/iWgQMPtA78P41UWqUpkpGY
         eHqg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=X86RdWoaDKqJbFDIoXti2bda7+kkyeUkiLhSN5JzlKU=;
        b=in/KgOHszm5psS2ZIqAVe4YXlz7v/lPNwBd46JwTLW0IEFP2+X7mGnLa/DMBRyfans
         7mLbGaUXyOJjOh6JrFpZry2F8tVneANWGGuARuC+62FBuQj7jHDQe+MzqreDmsA6ngWO
         NZHsA5s1Nl928S7bwnJ8YJgJsxl9d712U/oZHU4B+qwbCsD3E8M1c+JLuv5CFCMLVRCd
         xTCG6IQGt4GQddu2zxf0DGgtXXdsYq51Q4Eh7RqFkDJWStiUk2HzzBadpjaAvOX8Opfw
         kDASn6tDE/oZL0NpBqX/e5BXaxevkdXG5reiwuUcxGx/TKMyYGIozvPQWTj7owiRVVMG
         C27Q==
X-Gm-Message-State: APjAAAVlmYRolPfJexOmiHk7V4EM1cKHDXCgNtInFLV8pYRlapOKEhku
	pJWWCCTFRyc8lEm9G1X4zTU=
X-Google-Smtp-Source: APXvYqyQaiQnRW16hsy9jw0my3XuKFz+xcp5uJlbcjwUKSbH+CeKDB0TSECOfjFQc1MEbcv3mxb3aw==
X-Received: by 2002:a62:5f83:: with SMTP id t125mr67798974pfb.125.1568566349157;
        Sun, 15 Sep 2019 09:52:29 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id a4sm4383259pgq.6.2019.09.15.09.52.20
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Sep 2019 09:52:28 -0700 (PDT)
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
Subject: [PATCH v4 3/7] mm, slab_common: Use enum kmalloc_cache_type to iterate over kmalloc caches
Date: Mon, 16 Sep 2019 00:51:13 +0800
Message-Id: <20190915165121.7237-5-lpf.vector@gmail.com>
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

The type of local variable *type* of new_kmalloc_cache() should
be enum kmalloc_cache_type instead of int, so correct it.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Roman Gushchin <guro@fb.com>
---
 mm/slab_common.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 8b542cfcc4f2..af45b5278fdc 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1192,7 +1192,7 @@ void __init setup_kmalloc_cache_index_table(void)
 }
=20
 static void __init
-new_kmalloc_cache(int idx, int type, slab_flags_t flags)
+new_kmalloc_cache(int idx, enum kmalloc_cache_type type, slab_flags_t fl=
ags)
 {
 	if (type =3D=3D KMALLOC_RECLAIM)
 		flags |=3D SLAB_RECLAIM_ACCOUNT;
@@ -1210,7 +1210,8 @@ new_kmalloc_cache(int idx, int type, slab_flags_t f=
lags)
  */
 void __init create_kmalloc_caches(slab_flags_t flags)
 {
-	int i, type;
+	int i;
+	enum kmalloc_cache_type type;
=20
 	for (type =3D KMALLOC_NORMAL; type <=3D KMALLOC_RECLAIM; type++) {
 		for (i =3D KMALLOC_SHIFT_LOW; i <=3D KMALLOC_SHIFT_HIGH; i++) {
--=20
2.21.0


