Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23970C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:49:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFE842084E
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:49:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFE842084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 769668E0005; Tue, 12 Feb 2019 09:49:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 719A18E0001; Tue, 12 Feb 2019 09:49:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6306D8E0005; Tue, 12 Feb 2019 09:49:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3841D8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:49:23 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 65so2874956qte.18
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 06:49:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=k6claRKQolSqXhuGN5g6xDtCSZ+CMEStpkNqDx4jpqk=;
        b=XF8xvuvZCpcPY0d4oAYbtsY7Jm2sUj2pug8hMBjmgK20Ot+xCo+Eu+R5ETj6jl6FxQ
         qk3uEmyETx+fIMxdxmZkDUb08BDZUBEHPLHxxFqTc+80pYJy4DeOKRuztgUoY6BwEvg8
         M90DvnllFACHkVaD8t2AqJpVIA9YFMo4MJu6K96422ML3Q9AM7tEFLKVI62l+Mctd6aN
         qLKFW8Tfu05i5vgDzyxklLoBpdLAjNd6TVCUTSwW88HGj5LZ2sSUtUD9ExR6zouXkk/U
         r229TgFB2VurD6itZDYgmmXJK66nP8GCb1npoS4yx4ERWYXyLuZDuQN7dvPJtcb7NHF4
         QQBA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubntarvyvymWRu3RzeiF8YAziuRW8whHb8WNvvVKwniC5F7AAWz
	aEUugEzuF4+trQsYuhPTqDVfjZhWz5wgdg0bK43YPp/l0bnTMEb2sfcEqpJDhQJj1O4BQYScc42
	Ezma1HcgYCb0miLlNwSco4ZWUjWskovR0ZyZXUv6+VVwDlgWUOMhBTTfvsc/Jr4rqFA==
X-Received: by 2002:a0c:966d:: with SMTP id 42mr871732qvy.109.1549982961522;
        Tue, 12 Feb 2019 06:49:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbUlKB+OCYYMPdTJQbaY3LvujNExTvpp2MHk42/tVW+tFTTXkGJOX0LqUcoqoZYt/faz+bS
X-Received: by 2002:a0c:966d:: with SMTP id 42mr871619qvy.109.1549982959259;
        Tue, 12 Feb 2019 06:49:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549982959; cv=none;
        d=google.com; s=arc-20160816;
        b=EmSCnEc6pBCZ5lsDLXhKZDgKf0O6Bx2jI9+HTy4qHy7md2NUiCXCgv3TPz7/H8elpg
         vBbOgnkosl7Oc/UDy2bNatXYnRBjkEmkCNeQUAs/Y40Kqep0RSfJJkeuo84H4mDyuisT
         /SoGLM6KV5wXrnzq6dBGK9oPpRShhjZ651YPDNOlltQ6hycgpS5WOP6KosEjscCsLXRl
         bsaLCnl7pWUjNoST+Ww0enAlmKTirQayjot5mmA78Thh5otBk1mYQBdUbZzywhC8xrOE
         6bKa8fvcur57O32LZLF4elBKgWUagL/VckV0FuaKW5BVNfgt1sZ4cRxxFq12hJyls/V/
         CEfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=k6claRKQolSqXhuGN5g6xDtCSZ+CMEStpkNqDx4jpqk=;
        b=EDJ1h491KwUkOTDAbypOKkZH4yRY6bVaz0lCkwgwgH9dnkTeOMWamFwAqlzEW+irNa
         fgBsWyevU7pN3Y9pwzRqKg6WgmHAYnOka6ba0zyzrbtz4EOwsSt6XgxlWVOUnvIpqDlv
         7bGZ6Xd86QrSh9uhdQDk8RU38W462UlQ7Bcq+6emFWWpeCKknZ/7VG8lYSaStgzVpGXc
         3h2OIQiOXR+dwdCfcXg5d4VkOIaFG5mHD4kXa8b5lhzPmYEy5bwjNf4B45kqL6cSg1b1
         xGZcFpQLN3bzgQfr8N+7c1f0DdaAzIAuzY+4hnQ7P4AyzR2F7e+CE5zs0n6gK1EF1PTz
         y+dw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z8si2974309qvn.117.2019.02.12.06.49.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 06:49:19 -0800 (PST)
Received-SPF: pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 72A143DBD2;
	Tue, 12 Feb 2019 14:49:18 +0000 (UTC)
Received: from firesoul.localdomain (ovpn-200-20.brq.redhat.com [10.40.200.20])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4214162662;
	Tue, 12 Feb 2019 14:49:14 +0000 (UTC)
Received: from [10.1.2.1] (localhost [IPv6:::1])
	by firesoul.localdomain (Postfix) with ESMTP id 6C204306665E6;
	Tue, 12 Feb 2019 15:49:13 +0100 (CET)
Subject: [net-next PATCH V2 3/3] page_pool: use DMA_ATTR_SKIP_CPU_SYNC for
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
Date: Tue, 12 Feb 2019 15:49:13 +0100
Message-ID: <154998295338.8783.14384429687417240826.stgit@firesoul>
In-Reply-To: <154998290571.8783.11827147914798438839.stgit@firesoul>
References: <154998290571.8783.11827147914798438839.stgit@firesoul>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 12 Feb 2019 14:49:18 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As pointed out by Alexander Duyck, the DMA mapping done in page_pool needs
to use the DMA attribute DMA_ATTR_SKIP_CPU_SYNC.

As the principle behind page_pool keeping the pages mapped is that the
driver takes over the DMA-sync steps.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Ilias Apalodimas <ilias.apalodimas@linaro.org>
---
 net/core/page_pool.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/core/page_pool.c b/net/core/page_pool.c
index 897a69a1477e..7e624c2cd709 100644
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
+	dma_unmap_page_attr(pool->p.dev, dma,
+			    PAGE_SIZE << pool->p.order, pool->p.dma_dir,
+			    DMA_ATTR_SKIP_CPU_SYNC);
 	page->dma_addr = 0;
 }
 

