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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67CFAC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 16:06:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E02622CF8
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 16:06:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="e3t1McXM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E02622CF8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6DD16B0010; Tue,  3 Sep 2019 12:06:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C44C06B0269; Tue,  3 Sep 2019 12:06:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B59F06B026A; Tue,  3 Sep 2019 12:06:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0144.hostedemail.com [216.40.44.144])
	by kanga.kvack.org (Postfix) with ESMTP id 92FD56B0010
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 12:06:41 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 376491EFD
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 16:06:41 +0000 (UTC)
X-FDA: 75894087402.15.crook52_748577d51cf4f
X-HE-Tag: crook52_748577d51cf4f
X-Filterd-Recvd-Size: 3713
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 16:06:40 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id y9so11069661pfl.4
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 09:06:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=tqiMeM8TceesmPz2bTRikxBBQDBEs3u6ayncNAD+gSk=;
        b=e3t1McXM+B7+qPx+6xlw63jz2BIyLqfLkwAuPUpZ/KBlMqhABGIuIsh/P2+qg4fL3G
         e68oPxPeHi8vjpPuXdOVgYVl7iyc9re3mqNsfOKETT5TLTMCJariudPc5aEYUvdJIMIr
         8GsII5RUZLQEHyo9d62A4LFpgd69nti5zrZ7Fp+W993mrs8mrA6NQAypayAo89Qeh692
         oYxKPcTw6O0k6WJPPZjWHpbXrBkjaz6giJxa+GF34nICobYKGyS0s0tAEw8F6vxQbAFt
         t6J97R9xlt3Cwo1btDvuXlruov3D0WO6G2ERLjOiOc9McIhcixZ4rT8uvKQxri0cBUNW
         EbcQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=tqiMeM8TceesmPz2bTRikxBBQDBEs3u6ayncNAD+gSk=;
        b=ttudkTzcSNutQhj8Il0QavRUSCrnZD2ysDzeGmU+Ay1oFsLJg5hwnj2h+tK3A5x3z0
         qzvOL9O+4apg+Bjh08WuVTnnt7HOm1O4o0lUiLMvmUNwc5r48j9xJgB4MX0/RU5A5SY1
         RZZdODnDPCjRQvnkz8N9nZj4PfMSYY2yf0YfNkemc/KgHpkF5P8YiCP3/KO2sj5rlPyC
         tDVzkuoP9db+u6FDAtdDauOasC7loRB4JNPXXpAYrZ43YAm7jGDqqR5kqgpp+EvVhCVD
         3CRsOIUSOqf7JF1vo9saamYJUA0Bz4EhxpzmlawTiNavOdNINVq2oIOelRybFm0vDZWg
         1lqA==
X-Gm-Message-State: APjAAAVQBXJfRRt94VYmsCTCCJLWJwj1tjdHcYYZMfqfENfE8b/dHfpi
	iLOVRlEpUhif1luE6UFKjOE=
X-Google-Smtp-Source: APXvYqylZr4jbswujqwYAo39xphsMw3eAgJhDESJUjXAsNJEvXeRyMT0McdB5r6QPlWEFyI3l5Gd5g==
X-Received: by 2002:a63:2903:: with SMTP id p3mr16265577pgp.306.1567526799745;
        Tue, 03 Sep 2019 09:06:39 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id t11sm18501567pgb.33.2019.09.03.09.06.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Sep 2019 09:06:39 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH 5/5] mm, slab_common: Make initializing KMALLOC_DMA start from 1
Date: Wed,  4 Sep 2019 00:04:30 +0800
Message-Id: <20190903160430.1368-6-lpf.vector@gmail.com>
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

kmalloc_caches[KMALLOC_NORMAL][0] will never be initialized,
so the loop should start at 1 instead of 0

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 mm/slab_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index af45b5278fdc..c81fc7dc2946 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1236,7 +1236,7 @@ void __init create_kmalloc_caches(slab_flags_t flag=
s)
 	slab_state =3D UP;
=20
 #ifdef CONFIG_ZONE_DMA
-	for (i =3D 0; i <=3D KMALLOC_SHIFT_HIGH; i++) {
+	for (i =3D 1; i <=3D KMALLOC_SHIFT_HIGH; i++) {
 		struct kmem_cache *s =3D kmalloc_caches[KMALLOC_NORMAL][i];
=20
 		if (s) {
--=20
2.21.0


