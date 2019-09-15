Return-Path: <SRS0=FJsX=XK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65930C4CEC7
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 17:08:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AC5C214DE
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 17:08:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SJ4lQn8Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AC5C214DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C467A6B026C; Sun, 15 Sep 2019 13:08:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCF5B6B026D; Sun, 15 Sep 2019 13:08:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A986F6B026E; Sun, 15 Sep 2019 13:08:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0011.hostedemail.com [216.40.44.11])
	by kanga.kvack.org (Postfix) with ESMTP id 89CF86B026C
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 13:08:49 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 392A3180AD801
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 17:08:49 +0000 (UTC)
X-FDA: 75937789578.18.lake00_2fd5c6143a34d
X-HE-Tag: lake00_2fd5c6143a34d
X-Filterd-Recvd-Size: 4231
Received: from mail-pf1-f179.google.com (mail-pf1-f179.google.com [209.85.210.179])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 17:08:48 +0000 (UTC)
Received: by mail-pf1-f179.google.com with SMTP id h195so21137989pfe.5
        for <linux-mm@kvack.org>; Sun, 15 Sep 2019 10:08:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=X86RdWoaDKqJbFDIoXti2bda7+kkyeUkiLhSN5JzlKU=;
        b=SJ4lQn8Y/Rod0i0hqNjNSitEVvQrs8es0QonZHsDCnKam7BbbzVEPHy9+oxknfPvN8
         etneVvl++kTLOnVbyVL3J27f0y0RDkparH82n0CA0OHumA+LjRYK2Xd4Pn/Cwf6pUd9U
         pWOGQXYTwqx9bx6SmhPsjzugvSCmqq5EyYXooQeib3Gteu+s8MoQwXuXqJ5dapDppK4E
         ZEexxMNhYSAcJb5SZhCeLI6aUGaioUwvuSx4bHo6vu8Coi81LXYgcIR+bUAQhjmReZFM
         XxJsBsaBFvMm90tPLA7Yp3Vfz2paaHQs3L/5VMESJcuchf5AGuhYYtmwx7Up5u5AH4CE
         dikg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=X86RdWoaDKqJbFDIoXti2bda7+kkyeUkiLhSN5JzlKU=;
        b=lAC9NoJVZbSSeBkImPP9IAidQLxrmNUMGNEYQxbmsdg9+negtbkyiIEup5j8uQbRfg
         kumCmPx5BQna0fTj9JVhvwjm41CnNTRLV+FDsOJBzM8AzPEW2QSZTMDBIIVrEHWc1ZE9
         hfC6EgWr+xXY8m6LQxuoGdMiQIw56oOscWkmlgtmHFptewAAZC0pE10A+tsuxZOxPTsP
         0Xf3wyTUH0XJey+9U4RuTaxah42iG6tRCRpqpky0iWl9EGVr1p4g72U5WmTnkIU1PeiI
         k0K/5q4zA4UHn1FwK3BS6A0L8INJDL+RJ+TEm76gI3Q8aOKfAmi15EQmWWdtTOSqEeU+
         42ew==
X-Gm-Message-State: APjAAAXeF0s6ADKKoto1DoWD/O+qj+1XLLstoiF0/9s86clIbgNs/uoC
	+OextZF2cYCycVIRlxaMl20=
X-Google-Smtp-Source: APXvYqz/PCrVfpnnFdh4p8qjLJANWYL2j9hhouM6ji0IbmKL3O+gmShY1YQqZx7BSLb0nk4Zw7a4Fg==
X-Received: by 2002:a17:90a:8901:: with SMTP id u1mr2904510pjn.70.1568567327646;
        Sun, 15 Sep 2019 10:08:47 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id r28sm62279134pfg.62.2019.09.15.10.08.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Sep 2019 10:08:47 -0700 (PDT)
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
Subject: [RESEND v4 3/7] mm, slab_common: Use enum kmalloc_cache_type to iterate over kmalloc caches
Date: Mon, 16 Sep 2019 01:08:05 +0800
Message-Id: <20190915170809.10702-4-lpf.vector@gmail.com>
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


