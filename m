Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62612C282C4
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 01:55:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20F89222C1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 01:55:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20F89222C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDF7D8E0001; Tue, 12 Feb 2019 20:55:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8FF08E0005; Tue, 12 Feb 2019 20:55:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A7E4C8E0001; Tue, 12 Feb 2019 20:55:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7FF208E0005
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 20:55:55 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id q33so743757qte.23
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 17:55:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=WEnDHOBP3T8BxDS3/7DSel/5EvpqQ57qB7+fl55woOI=;
        b=S622pZIWKo9/+l3ONVeUlXbqcODFgwnBVBlUh0OYdNYLVqLhaL/Y0cKnN3ifRdmK8q
         bqUVAfRqD5Gau8afwKvgys6jYdiijqX8p74t74OJUFMdKH43xcLJRHJiDxQ8aTQ3Yl1i
         I1eDNtpt71hNxVqlQN6jmGVYyntc8YT0eaj8uZuZQo4AFYOerK7Wu3qyrOnHWGcsMoIZ
         BULEMWNfWK24HdRE67kawxasmyw6jVL1gysb9VT0iwPWlZeikxbq2TWLt1gfgX6R6tEU
         N/OnLyrMVq+d6ZtEWIPXLRJFUGw3uUlJGEqqMhrwjhnWPvaWz/0NBkCspyum2G4etxoK
         M3yA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuY48XT2AeeUJwrnccq1v4c1VBWlMBW2DLD++nlb2v3Xtxud2pkj
	RKu/OJ4AvBfJm/OJEgBo/j3Pilh1/nML6IdXOggrzTdC2PkLGYxKI0ONgGkNhrXrC7HAqzvoNUj
	T37Vy07mdCC7M033OpDV1opmzL3Ek90TQRkyPMOj3uwm82kjN+PgMOeATt71tKnX1xw==
X-Received: by 2002:a37:b8c1:: with SMTP id i184mr4592039qkf.51.1550022955278;
        Tue, 12 Feb 2019 17:55:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYLNHn8A/CKQYsvOD6oK7xx2owvXBlxcysGnbRuIqyr7Bo8bGh8HKcJ8sLhd9UWlp1xJ6Xn
X-Received: by 2002:a37:b8c1:: with SMTP id i184mr4592025qkf.51.1550022954775;
        Tue, 12 Feb 2019 17:55:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550022954; cv=none;
        d=google.com; s=arc-20160816;
        b=nr9u4g2Uy17p+6pG0f26baypYC8nLqCvlPhOGeT6W9sShII9eaAkuxXXxqgO6153CJ
         gWZC1qkw487H5D1RsAmio55sZ3VhzmwecMXh9EfDVTih4y/dZDYiKmKYylKK94iS5pgh
         chmdksbrkJxu5kJsHbNm5COePVDRO0in2Q5iWYRAHdFoWgDF+wbJeYcpNUb4Wyu8wCHL
         eYAf4ztyvnGuNjj0NsJ0tjpUrmT6c9zpC3pZv4mEAKZUE1ke1oElW/obvin1Iopx9lpb
         5TfWercUkmSyM/Fv5tGYwkUbYwjKpRB/KvUhjt1QOvzoCA1jhuR+VtmvaemAjMlqDViT
         9SqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=WEnDHOBP3T8BxDS3/7DSel/5EvpqQ57qB7+fl55woOI=;
        b=OLyoAP3Ya9MK1LYvhK7+fQ41Uo1tObEQ60QFiMVnYBtpDA5YV+taVcz4REbIg+cVar
         b3cYzjemKLw8W4cA9M20PhWskDdg+uum+iAQeocIgNvn1RSk/WG/oLs/LcJyjWrrJOVC
         J8K50LHogioG7uYr8oudAhk2KGBzahJv0bXGjw3Iq4cRUGQU+4NSTO7HMhNLPnxLqWzP
         U+Uazpt3VCVn6FM7xOtYQp1PmoPXe4ZATN/1Tb0G9x+gTrXr3Pg8JhpxQV5RxFqM9/Tc
         63mO3VIYd6yqsD4SjMt7NdsedbGbC4MGv8I2eKWoyVWLhVBSKeatCQkYizYAXO9w/dmR
         8qJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y4si505646qve.86.2019.02.12.17.55.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 17:55:54 -0800 (PST)
Received-SPF: pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E6F703DE0F;
	Wed, 13 Feb 2019 01:55:53 +0000 (UTC)
Received: from firesoul.localdomain (ovpn-200-20.brq.redhat.com [10.40.200.20])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1946862667;
	Wed, 13 Feb 2019 01:55:51 +0000 (UTC)
Received: from [10.1.2.1] (localhost [IPv6:::1])
	by firesoul.localdomain (Postfix) with ESMTP id 4336E306665E6;
	Wed, 13 Feb 2019 02:55:50 +0100 (CET)
Subject: [net-next PATCH V3 3/3] page_pool: use DMA_ATTR_SKIP_CPU_SYNC for
 DMA mappings
From: Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: Toke =?utf-8?q?H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>,
 Ilias Apalodimas <ilias.apalodimas@linaro.org>, willy@infradead.org,
 Saeed Mahameed <saeedm@mellanox.com>,
 Alexander Duyck <alexander.duyck@gmail.com>,
 Jesper Dangaard Brouer <brouer@redhat.com>,
 Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net,
 "David S. Miller" <davem@davemloft.net>, Tariq Toukan <tariqt@mellanox.com>
Date: Wed, 13 Feb 2019 02:55:50 +0100
Message-ID: <155002295022.5597.14139756432375272348.stgit@firesoul>
In-Reply-To: <155002290134.5597.6544755780651689517.stgit@firesoul>
References: <155002290134.5597.6544755780651689517.stgit@firesoul>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 13 Feb 2019 01:55:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As pointed out by Alexander Duyck, the DMA mapping done in page_pool needs
to use the DMA attribute DMA_ATTR_SKIP_CPU_SYNC.

As the principle behind page_pool keeping the pages mapped is that the
driver takes over the DMA-sync steps.

Reported-by: Alexander Duyck <alexander.duyck@gmail.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Ilias Apalodimas <ilias.apalodimas@linaro.org>
---
 net/core/page_pool.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/core/page_pool.c b/net/core/page_pool.c
index 897a69a1477e..5b2252c6d49b 100644
--- a/net/core/page_pool.c
+++ b/net/core/page_pool.c
@@ -141,9 +141,9 @@ static struct page *__page_pool_alloc_pages_slow(struct page_pool *pool,
 	 * into page private data (i.e 32bit cpu with 64bit DMA caps)
 	 * This mapping is kept for lifetime of page, until leaving pool.
 	 */
-	dma = dma_map_page(pool->p.dev, page, 0,
-			   (PAGE_SIZE << pool->p.order),
-			   pool->p.dma_dir);
+	dma = dma_map_page_attrs(pool->p.dev, page, 0,
+				 (PAGE_SIZE << pool->p.order),
+				 pool->p.dma_dir, DMA_ATTR_SKIP_CPU_SYNC);
 	if (dma_mapping_error(pool->p.dev, dma)) {
 		put_page(page);
 		return NULL;
@@ -184,8 +184,9 @@ static void __page_pool_clean_page(struct page_pool *pool,
 
 	dma = page->dma_addr;
 	/* DMA unmap */
-	dma_unmap_page(pool->p.dev, dma,
-		       PAGE_SIZE << pool->p.order, pool->p.dma_dir);
+	dma_unmap_page_attrs(pool->p.dev, dma,
+			     PAGE_SIZE << pool->p.order, pool->p.dma_dir,
+			     DMA_ATTR_SKIP_CPU_SYNC);
 	page->dma_addr = 0;
 }
 

