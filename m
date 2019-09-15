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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A30FC4CECC
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 16:52:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 186C5214D8
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 16:52:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="G+yzSSKX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 186C5214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C039D6B0008; Sun, 15 Sep 2019 12:52:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8DB16B000A; Sun, 15 Sep 2019 12:52:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A546C6B000C; Sun, 15 Sep 2019 12:52:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0011.hostedemail.com [216.40.44.11])
	by kanga.kvack.org (Postfix) with ESMTP id 81A0B6B0008
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 12:52:21 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 3436A180AD7C3
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 16:52:21 +0000 (UTC)
X-FDA: 75937748082.27.run57_31985446d4040
X-HE-Tag: run57_31985446d4040
X-Filterd-Recvd-Size: 4227
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com [209.85.215.194])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 16:52:20 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id u17so18021143pgi.6
        for <linux-mm@kvack.org>; Sun, 15 Sep 2019 09:52:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=X86RdWoaDKqJbFDIoXti2bda7+kkyeUkiLhSN5JzlKU=;
        b=G+yzSSKXmJhEM++iRzQ5m03oqsOK0gURMOljXVO2EqysSm4iIuA8NRRNAzOgjgp9o0
         sO+oIkPpkU/Sp5z9Xvvt05SjxNgybmP59Iqv0pMgpE1rryezPSIjCAWwBApg9FKuh12a
         A9zRNleYomC430D/DcAJPZTKpZ0d7KXzbh05CtiInyVKSAKWWQbzoJcl+X4HS9XCKvz5
         CZ5W8hKFIdkXo1bHos/qh8RTXnc2JyknMtLKzFSt9JPwYMVbCx62Mlx5XfstNU8ZtmvB
         GNQbyJOz56HKKnNBUbzNEybDic3axGq12Qi4DRLAQBWgVdNA84WHfhVpry3M1Yo33xLu
         idjQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=X86RdWoaDKqJbFDIoXti2bda7+kkyeUkiLhSN5JzlKU=;
        b=HWTuIfC8+VtjifGM3buV1Vhzy/xv1+/coimBPtm4vVEl6sXcMty2m/P+hzyRArVS2a
         LbvF81YZVPNnoyCKIzOdX7I4iJYSf1ikFtootmvcg8iAdIfq42DYfnbqkKTdLEeVm2st
         /Wee9mXkA/fL2JbkMRkmvzFFu17Bglattff4YcmNMFiybaOcHnfLJoan3OaeLAWLNzE/
         /Yi3n38sIusJsIIsMnDIFe7IFGG1i6wya5YNK6QNzMjRZJ1zClYc4MFmuRqpxHO6wvvU
         7DCsUec2bZnG/x3Jef7TVORzpgotTRclLWQH+nssA4ZXXBWdqaVRrWaI90j3Ey96+BXU
         eK9g==
X-Gm-Message-State: APjAAAXo7fyyHn06YIJm4UEUerJ3RkiwYfphV7Y/ScQr2ioeuYct+JAC
	RirXZQfLAKR2Sbs4rGGDytzjVkmLo2E=
X-Google-Smtp-Source: APXvYqyipnT98ResURsw038tfVzIDoxKbCXlrtw3kuy4NXyjm2pDCAcW6gupvqKfpody7f93AEDgXg==
X-Received: by 2002:aa7:9307:: with SMTP id 7mr8117547pfj.224.1568566340018;
        Sun, 15 Sep 2019 09:52:20 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id a4sm4383259pgq.6.2019.09.15.09.52.11
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Sep 2019 09:52:19 -0700 (PDT)
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
Subject: [PATCH v4 3/7] mm, slab_common: use enum kmalloc_cache_type to iterate over kmalloc caches
Date: Mon, 16 Sep 2019 00:51:12 +0800
Message-Id: <20190915165121.7237-4-lpf.vector@gmail.com>
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


