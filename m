Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73C90C4740C
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 01:27:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EB9A21A4C
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 01:27:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KQtd53NR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EB9A21A4C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C53156B0010; Mon,  9 Sep 2019 21:27:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDCBE6B0266; Mon,  9 Sep 2019 21:27:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA3C76B0269; Mon,  9 Sep 2019 21:27:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0138.hostedemail.com [216.40.44.138])
	by kanga.kvack.org (Postfix) with ESMTP id 81C8A6B0010
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 21:27:39 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 405EA87DE
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 01:27:39 +0000 (UTC)
X-FDA: 75917273838.12.act76_7cf980095691f
X-HE-Tag: act76_7cf980095691f
X-Filterd-Recvd-Size: 4227
Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com [209.85.214.194])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 01:27:38 +0000 (UTC)
Received: by mail-pl1-f194.google.com with SMTP id t1so7630719plq.13
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 18:27:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=X86RdWoaDKqJbFDIoXti2bda7+kkyeUkiLhSN5JzlKU=;
        b=KQtd53NR/T/J/9VekePalACKtC/HOwwkO8bNSV8tk6Dyyj31Kp1PrOu9o88nuHcY/9
         3xRu8xKtgvF63f+93emrR9zYCdNo4OdcB3HZVeczwKML+KIWPN76tISq5lziBwla/bAQ
         12Hq/pLyCY307g2j24oYtaTpPyIj7f6I32O8OiTGxngpTqjq/fqlyq2vFSg28kUl8tqL
         vJ77wfOgKd0crD+8e2kwoTCP1e09W460Su2O8pfXRIQ/5krP0C8WV0kygi6qtS1pyzDS
         8oLossfX3RBTQ3MnlzwWLSkQ8D3dXLJzO6Q7oRH90wXXrKMIb7R8nL/J6rwZRCdVMZdl
         0mMg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=X86RdWoaDKqJbFDIoXti2bda7+kkyeUkiLhSN5JzlKU=;
        b=iYKLHYQU8ajF00g7lEiZDWrES9+N66HOeruDwBlWGwAH6gJWkAJPCXgpUVq+qFsPCQ
         nSUaDfTMjltBZBQXrB9JG3JLTMAAYRdgqJqaFZ8ySTaV+k0b4gI3hQQL4z0XyQs5NXrk
         3uSvb1NAfXeLtUGk7P1Vym7s0m9whBRtAjYozgA3ydghs6Bx8ECWPaxTa5nrTyybzJan
         BfgeBekS2+HHyMH0SZHiAn2nn71Sxwi/lQxmSp2QHFRKAk+hZsP6ovAuKsO1B3GSQ68d
         Su6QOejyB9CNtKwF90yBB+flXJwtCS4B2yKh3gbUOcpoAZXzacwdgq7qCNZ9YvPlh/l0
         H8Vw==
X-Gm-Message-State: APjAAAWMqWWwzTx6R3x/HG7E16veq6OTFfx3jYpSY6638jDan6G6Kzu8
	kkrHPTIXtxWuOrkgnjGHrP4=
X-Google-Smtp-Source: APXvYqzMsPmTfBEy4WB28iw7U/+S+kHHAnWKRQ3msjHdY/9xK0yZsfYeo8VDoWYGdBvtPYt+3nsvOw==
X-Received: by 2002:a17:902:426:: with SMTP id 35mr28367384ple.192.1568078857630;
        Mon, 09 Sep 2019 18:27:37 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id b20sm19558629pff.158.2019.09.09.18.27.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 18:27:37 -0700 (PDT)
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
Subject: [PATCH v3 3/4] mm, slab_common: use enum kmalloc_cache_type to iterate over kmalloc caches
Date: Tue, 10 Sep 2019 09:26:51 +0800
Message-Id: <20190910012652.3723-4-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190910012652.3723-1-lpf.vector@gmail.com>
References: <20190910012652.3723-1-lpf.vector@gmail.com>
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


