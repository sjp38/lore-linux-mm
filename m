Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7C35C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 09:15:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90CE9214AF
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 09:15:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90CE9214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26C056B0005; Thu,  4 Apr 2019 05:15:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21B976B0007; Thu,  4 Apr 2019 05:15:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E3466B0008; Thu,  4 Apr 2019 05:15:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id AF71F6B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 05:15:45 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f2so1043261edv.15
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 02:15:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=klHFaZb/PmM3tzZdGJEsXoGjeT4WytdPJzzCxt2gpy8=;
        b=WEO6YHDgEcdhkQVLmvtWH+w34r1NrN5MkGrkG5gXdhLF6t2Mz3yCwYSiCakL5Jgsl8
         uFte9YWgyWGbOssZnRfooWa7Z7qZGiUeuPWNh3nrihW2KNaj+EqKYXLBsTrehp3+5rmM
         7fz+XCeyT0KZNdzZlRLk/+RYLR2Jkc7aYCt/SO9b/RJr42FU9aeb/rgbg0p642f9CDpd
         lzhd33b+CUvjGBnS7GE+0w5DsbcrdHBhulOtapJoA/6fqGaceOdvsXmyxFpXr/IUaMP8
         vSTk2qu2WAB7TcyXkrdchLmw3JI6CVhsqMBIEQH/SywxM6M3qOCxzCN/Tz3oBJJ6I9d0
         h9hQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAVTafQFrsYPyjM1bggemqW3WI7AG82FKwfphBmJ1hm1n8QgsIwc
	F0VU8fPDY3ay+HzE/+wu/cf7qupo67WUs/d+J1Dgaunza8PBZPJCyYc0cQA0JL5vD3tdvvPk9x6
	ZZfwvGw8TL+CQgQHM3rraHztZ24pHrx976AysCXmuVZN5PflvQQfV+l9NI8P1k5EqFw==
X-Received: by 2002:a17:906:a2c6:: with SMTP id by6mr2885843ejb.134.1554369345220;
        Thu, 04 Apr 2019 02:15:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6k3ylYCqU9r2GETqaZ99J/kxDb/5fVAkad4CiUqpo/DIHqp/ZyVy14cmCKSCYLvxXcwbB
X-Received: by 2002:a17:906:a2c6:: with SMTP id by6mr2885791ejb.134.1554369344126;
        Thu, 04 Apr 2019 02:15:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554369344; cv=none;
        d=google.com; s=arc-20160816;
        b=fYlt+Y8o7uq5mWJU0/5wDLj5IcYaUNJ1s03W207Bn9aaQ6wmCWdQm4tVtG6of9W7YX
         DHe5l5E0iIc6ufaZxur6e+fr8zuux9ejSbF92vghrv3XSlKidP+P6UTKG0EyKs+kLxCz
         k4TbXYtxYSOUKWI4bl/joRD/CtDKqbJmVKBfuUNHAzT2jnZMjJ66xtIulsMoyURKkcZ2
         K1Imbn93Ran0eCZp+ImW2qK3J50W8/rafPamQAwbB5HEeM1i1d2LcC7b1HLF0x/GOVKx
         cT4yT92nXvG+Q9ILVWkiwpuDUqFbvHZwlP5NRvF6Dgj9kDItAUOnhgz0pp3fCebISZHa
         Hv/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=klHFaZb/PmM3tzZdGJEsXoGjeT4WytdPJzzCxt2gpy8=;
        b=PB67XTNJd7FW+krJFf/3+PI9twVA9J9lG60fX0sKJk8oTKgQIMk9OtMvAtjRY7XlrT
         xnIMhQL6+OVE52kbay387cfC21cj9WIeCkyWP49Yk3Wxix4nVdSMxPYSzgN/yKEzyf71
         wpe8bM9tciZBPNDFaijbGjWE2cqjRFKqljpDVTspKo9BnWmJWF683X45SSdWiaexWCfB
         zXjWXbvpicgnvwpsVU44u/Y+PhiN1xHUBT3vpgcxrImC47vct3BlIKTFc53lbANfVDG9
         84CKyKL3pRRiwXcGHo0W4O/BM3PWNEWgiMPpDXT/h7h0Xnup47QekomSJPJSlctnsRz6
         vfMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i45si1148859eda.141.2019.04.04.02.15.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 02:15:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 49E73ACFA;
	Thu,  4 Apr 2019 09:15:43 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	linux-kernel@vger.kernel.org,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 2/2] mm, slub: add missing kmem_cache_debug() checks
Date: Thu,  4 Apr 2019 11:15:31 +0200
Message-Id: <20190404091531.9815-3-vbabka@suse.cz>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190404091531.9815-1-vbabka@suse.cz>
References: <20190404091531.9815-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Some debugging checks in SLUB are not hidden behind kmem_cache_debug() check.
Add the check so that those places can also benefit from reduced overhead
thanks to the the static key added by the previous patch.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/slub.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 398e53e16e2e..9d1b0e5e8593 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1086,6 +1086,13 @@ static inline void dec_slabs_node(struct kmem_cache *s, int node, int objects)
 static void setup_object_debug(struct kmem_cache *s, struct page *page,
 								void *object)
 {
+	/*
+	 * __OBJECT_POISON implies SLAB_POISON which is covered by
+	 * kmem_cache_debug()
+	 */
+	if (!kmem_cache_debug(s))
+		return;
+
 	if (!(s->flags & (SLAB_STORE_USER|SLAB_RED_ZONE|__OBJECT_POISON)))
 		return;
 
@@ -1095,6 +1102,9 @@ static void setup_object_debug(struct kmem_cache *s, struct page *page,
 
 static void setup_page_debug(struct kmem_cache *s, void *addr, int order)
 {
+	if (!kmem_cache_debug(s))
+		return;
+
 	if (!(s->flags & SLAB_POISON))
 		return;
 
@@ -1734,7 +1744,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 	int order = compound_order(page);
 	int pages = 1 << order;
 
-	if (s->flags & SLAB_CONSISTENCY_CHECKS) {
+	if (kmem_cache_debug(s) && s->flags & SLAB_CONSISTENCY_CHECKS) {
 		void *p;
 
 		slab_pad_check(s, page);
-- 
2.21.0

