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
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4C4BC3A5A5
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 16:06:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A96A822CF8
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 16:06:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="P4H3OZmR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A96A822CF8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58F886B000E; Tue,  3 Sep 2019 12:06:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53EC86B0010; Tue,  3 Sep 2019 12:06:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 455D06B0269; Tue,  3 Sep 2019 12:06:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0196.hostedemail.com [216.40.44.196])
	by kanga.kvack.org (Postfix) with ESMTP id 277896B000E
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 12:06:27 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 85538180AD7C3
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 16:06:26 +0000 (UTC)
X-FDA: 75894086772.09.drop90_725a91eeabe30
X-HE-Tag: drop90_725a91eeabe30
X-Filterd-Recvd-Size: 4074
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com [209.85.214.195])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 16:06:25 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id m9so8088357pls.8
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 09:06:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=LViEBVo5/xlaUjZ5GSZNj0pM5S7KZYGyGn2HDxokJJk=;
        b=P4H3OZmR9QVZgWZ2D/glNq5HSvTTrtqxFVkVeg/WZmiL9dTUo7HLjSs+UAauaHV7mt
         OmdGS37DH/UzzuxUriBbekvJtFfsZe4KNE++J97KcSHSY4zyUhWS44PKjvV53bG9d7Ow
         PpUs5C4moOLJL93jkoHpnAfyp4JoJ6d3dTTbCvi5lyfx/clI0zfp2Tpi5Ji7WwXp33Cv
         p7GCekESrk91miSi5xR5uSRp/dx2JHTaBLVp2x+t9peORo7Ett6DiFWSNaqQGa6W9rqY
         gOjY65Jb7D1y+WBAPwK7xtAOF2yavrCA41nuC3aJW27orC+W9Dn78nO5R9CUG9SDFRpL
         U6oQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=LViEBVo5/xlaUjZ5GSZNj0pM5S7KZYGyGn2HDxokJJk=;
        b=rkKE6DSzpAOpdXDTjjC+ZfZxo+TXn+HvgAKCu4jdcKU/t9LpjPP6EnpvSfL2lSa/aj
         C0Jv3THrpiwUha5Ho6bnXabiI+iSd0g1/Abxo7mpC6P8RUfI1Khm7ImI4qO6Kq/23ksJ
         r4iEoQcXUn2g5CnFkRm9N2dAJ4vC1S1iNd2YigZRmP8Jb5n42h0cUNMRYVz7Dc18pB+d
         YyO62WQRII9JGvdmDD0JSpBsoWsnlcLCwI7c/iXw2aE7ajPNq7r3IL7QBaqQ+0aRmDWB
         XQzdXdg/bACH/V3fIjjDS+g4d34NzAh1So9006kRP1N33aP13K46s/oF34DTLVaj4vXi
         fBjw==
X-Gm-Message-State: APjAAAWtqYWuvjDsE71LL/N6dUw/9qKkfiiSycVHdzzgVwtSx/m1w9eR
	fUlR2fd0a3QHSacTqhz2KS0=
X-Google-Smtp-Source: APXvYqyIZTD5K2Wd0BFFfQVmj87nH+2U+ramZbS8wjnzfUW+IK1TUWiksx4/P3FvlglaZ1/zVdGvvQ==
X-Received: by 2002:a17:902:7588:: with SMTP id j8mr18739799pll.280.1567526784988;
        Tue, 03 Sep 2019 09:06:24 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id t11sm18501567pgb.33.2019.09.03.09.06.07
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Sep 2019 09:06:24 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH 4/5] mm, slab_common: Make 'type' is enum kmalloc_cache_type
Date: Wed,  4 Sep 2019 00:04:29 +0800
Message-Id: <20190903160430.1368-5-lpf.vector@gmail.com>
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

The 'type' of the function new_kmalloc_cache should be
enum kmalloc_cache_type instead of int, so correct it.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
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


