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
	by smtp.lore.kernel.org (Postfix) with ESMTP id A79CCC3A5A5
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 16:05:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B73522CF8
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 16:05:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GsrgTbga"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B73522CF8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E5EC6B000C; Tue,  3 Sep 2019 12:05:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 197176B000D; Tue,  3 Sep 2019 12:05:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0AD0B6B000E; Tue,  3 Sep 2019 12:05:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0055.hostedemail.com [216.40.44.55])
	by kanga.kvack.org (Postfix) with ESMTP id DF5116B000C
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 12:05:51 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 7294A181AC9B6
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 16:05:51 +0000 (UTC)
X-FDA: 75894085302.07.roll41_6d4af0cdc6829
X-HE-Tag: roll41_6d4af0cdc6829
X-Filterd-Recvd-Size: 3917
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 16:05:50 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id w16so11066089pfn.7
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 09:05:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=oDjYh1SsltbOsBEB420dFALj+pbpv/F7VefYy840/EY=;
        b=GsrgTbgaFBhQFrgMq1YXV4RcR8zjQ92lvCgtyccS3iRm7gcJ5k1MEg9O6oXgHMo1uw
         GjDU6QjiPGgWmOnRQawMZ0TDo+gQ4THlJHPVk9GT/RLACj4Q7n+i6nIKI3WTzBlmBorM
         Oaeizkzy5iXh5H/4je9rGcysSeMPbIY76OHNUfmoPxnj8ypctXVBadQ7ZvKK5cb6uFgL
         UBAr3eR8Ub+H5/3P+4O/KzsjzvkQwLTTYI7uocFkQ6ZEUiVLYY00fYEK2pcRNZHkflf6
         cH2mY/iB0eqUuBnGejO+Urv3EfLgYnwLRot8i4xUkb3sG5+yRbVpbDH1W4O+gFwQ0ML/
         GCQw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=oDjYh1SsltbOsBEB420dFALj+pbpv/F7VefYy840/EY=;
        b=SIjRsTZNeNgqHnnnxi+4zCBvMF6tOQDxnLXNnJ2YpuVqJl2e44XgrNQdZR50ADv8Ev
         fmNllmy9XmnTjRyM26C6XISywtsWYNqks1YKRGmsObKFx6DU7djgXocgRcaXl4TAdrDf
         /KdGN7me/ILEsv0X9wfMXzITQOCyYgbl8lYuy034BWtCMxvGFqlqv3E8do+HB80dIp9G
         6UHZ9dp4bIy7ysszelrjEXm4b1yoMPUM/6EH9W4rkVjIt2Xg0jRLSBQLTFC5bT7uDeqA
         S9KZcxJuALRaPs3SsSBfUwyHenxEkIc/qQK2xDfXy0s7+4eY4GrK8RkEyPxxPHN9Tq7z
         tECA==
X-Gm-Message-State: APjAAAXZN0RZpsRjdE9biJOjrGX4oqvf52pn9H7Za5L7kRrKxo1BSgbX
	RNgm8fIJzI0ARFMPZpog1WE7I4catF4oLA==
X-Google-Smtp-Source: APXvYqw+wcwd1Q5ELGsyNrHdLhIs738zYiU66KGwfojkb+IX0BJdf35/4VhaGx1L9wzKEkW3Xtki6A==
X-Received: by 2002:a63:4c5a:: with SMTP id m26mr30382871pgl.270.1567526750106;
        Tue, 03 Sep 2019 09:05:50 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id t11sm18501567pgb.33.2019.09.03.09.05.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Sep 2019 09:05:49 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH 2/5] mm, slab_common: Remove unused kmalloc_cache_name()
Date: Wed,  4 Sep 2019 00:04:27 +0800
Message-Id: <20190903160430.1368-3-lpf.vector@gmail.com>
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

Since the name of kmalloc can be obtained from kmalloc_info[],
remove the kmalloc_cache_name() that is no longer used.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 mm/slab_common.c | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 7bd88cc09987..002e16673581 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1191,21 +1191,6 @@ void __init setup_kmalloc_cache_index_table(void)
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
--=20
2.21.0


