Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60F33C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 01:55:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E5E6222C1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 01:55:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E5E6222C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DE9E8E0004; Tue, 12 Feb 2019 20:55:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 465488E0001; Tue, 12 Feb 2019 20:55:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 308188E0004; Tue, 12 Feb 2019 20:55:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 028668E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 20:55:48 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id e9so727170qka.11
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 17:55:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=xWUNDSgRU80m19aFrocMMhwrjGCARtWhKL6OErSaSMc=;
        b=k78qXw5eEv8fbjtd0jG29XlDXNLwtYk8i3PFxI43nAxeg0e6RUCDpxJZsRblj12yG5
         OOVS1iYz2hli0DxVzhtc/jWv0WEV7PVq0KDovxqoXtzXc/Ad+ghXvNtrUSAH+PZTIF20
         cwdrIaUYYWBK+w4aNF7neSFKUEEuMnvsKX6ZD3XVvI4dYy/ZY75B+gPFVGWrbIit6Rfu
         LdVDvEni5rYWbXXUVSZz9qADc6w6641j81KF9RuSud+hZTPaztKl/4LvTCsoztxi/lU7
         DEcxk3xbX4m1wCW4U85iOXKF6UZMwWff72aa1lG0I46Q18BvEsPtT/iZxCkx/uzgUOSQ
         3NbA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaqyOTZsy79ZO/puknb87vCrXORMVuiwcxf+WU7EuODYfhi+NpS
	SgsUc1MEM7O80GTKIsLlE/YnQHgF3ctvGbMtQ3P1uNDpobefsIhcgG2b+YLbmrfDj4u8AVeOol8
	+3+a0gx4WofeiXDTdIiGezgBtW3cf7jhRKdJFU2XxwnMn/3IOMMS5GVqdZ4GvjsvV8A==
X-Received: by 2002:a0c:c103:: with SMTP id f3mr5008482qvh.194.1550022947756;
        Tue, 12 Feb 2019 17:55:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYRb009MGUqLQG0lTF9zS/BP4Cyyt2f4v8pMlQVrNzzgb399M1oEHie1fucTHiArLfy+Hwo
X-Received: by 2002:a0c:c103:: with SMTP id f3mr5008463qvh.194.1550022947282;
        Tue, 12 Feb 2019 17:55:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550022947; cv=none;
        d=google.com; s=arc-20160816;
        b=IY3I0dbLQDs+PsouwOHpSXtmMYe48QtE9fhIHLT0p5U/PzYSGeSlAnb4qa+u+ZyBdK
         NDN+ErqxdDEoyv2EE9fcE+Lf1VMpFFovkfwBbEHspTRIqOTH+VeTd+le+luXuEwsYMk1
         XvATNoN/LEAMRswq/RcjdF380CB36Yz03KqERqBJvKwhOED0zh4MqTuz0/UBbU4X4us8
         d3FMgOmzGiBcs3B+ONw5ilU8wQIXxna7NgZrC3pfMkXpNpyd9/SuYx1B4PgbJyXDa7Xu
         WrYHbnrEKUsCrCvD9ajhf7Xy7+c6EC6wpczgEx/goMXIjGeyKJu46qfl8jeRY1TZvfvw
         0LHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=xWUNDSgRU80m19aFrocMMhwrjGCARtWhKL6OErSaSMc=;
        b=j8hutfr3RbC5xrKm1HyiYdAuRaYFe8t+UHXiNguCItPjyg12vrfHgKo/zqAA03ue3E
         Q0aCNfX3BXojr3R+c2GiC3iM5vK+Ol/mlhctpwm67HxO7aQ+nPy9FPsATF3xOBtd9Zkk
         WMVht0L6r7OtCVbWesEl82SX7SGpzHx4EY/SPJPg5/pbwxCtQFCEwRfsmTpw8/b/PFJh
         ZIe8CTtvLcJWT8SMfNMgi1CIqqtpVg4DHE1plVAtRe1bQrU39CUWs9wj5lZewucbQOzM
         MxVhQSZTKQvuN2N8/fOhpANaI/0KANZ4QG71lia28UEfa+0WSmfPjuUg+1yNn+s43LeW
         VjVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n34si1890947qtn.318.2019.02.12.17.55.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 17:55:47 -0800 (PST)
Received-SPF: pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 620E77F406;
	Wed, 13 Feb 2019 01:55:46 +0000 (UTC)
Received: from firesoul.localdomain (ovpn-200-20.brq.redhat.com [10.40.200.20])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0BB785C635;
	Wed, 13 Feb 2019 01:55:46 +0000 (UTC)
Received: from [10.1.2.1] (localhost [IPv6:::1])
	by firesoul.localdomain (Postfix) with ESMTP id 32FE5306665E6;
	Wed, 13 Feb 2019 02:55:45 +0100 (CET)
Subject: [net-next PATCH V3 2/3] net: page_pool: don't use page->private to
 store dma_addr_t
From: Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: Toke =?utf-8?q?H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>,
 Ilias Apalodimas <ilias.apalodimas@linaro.org>, willy@infradead.org,
 Saeed Mahameed <saeedm@mellanox.com>,
 Alexander Duyck <alexander.duyck@gmail.com>,
 Jesper Dangaard Brouer <brouer@redhat.com>,
 Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net,
 "David S. Miller" <davem@davemloft.net>, Tariq Toukan <tariqt@mellanox.com>
Date: Wed, 13 Feb 2019 02:55:45 +0100
Message-ID: <155002294514.5597.2532233956628457927.stgit@firesoul>
In-Reply-To: <155002290134.5597.6544755780651689517.stgit@firesoul>
References: <155002290134.5597.6544755780651689517.stgit@firesoul>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 13 Feb 2019 01:55:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ilias Apalodimas <ilias.apalodimas@linaro.org>

As pointed out by David Miller the current page_pool implementation
stores dma_addr_t in page->private.
This won't work on 32-bit platforms with 64-bit DMA addresses since the
page->private is an unsigned long and the dma_addr_t a u64.

A previous patch is adding dma_addr_t on struct page to accommodate this.
This patch adapts the page_pool related functions to use the newly added
struct for storing and retrieving DMA addresses from network drivers.

Signed-off-by: Ilias Apalodimas <ilias.apalodimas@linaro.org>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 net/core/page_pool.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/core/page_pool.c b/net/core/page_pool.c
index 43a932cb609b..897a69a1477e 100644
--- a/net/core/page_pool.c
+++ b/net/core/page_pool.c
@@ -136,7 +136,9 @@ static struct page *__page_pool_alloc_pages_slow(struct page_pool *pool,
 	if (!(pool->p.flags & PP_FLAG_DMA_MAP))
 		goto skip_dma_map;
 
-	/* Setup DMA mapping: use page->private for DMA-addr
+	/* Setup DMA mapping: use 'struct page' area for storing DMA-addr
+	 * since dma_addr_t can be either 32 or 64 bits and does not always fit
+	 * into page private data (i.e 32bit cpu with 64bit DMA caps)
 	 * This mapping is kept for lifetime of page, until leaving pool.
 	 */
 	dma = dma_map_page(pool->p.dev, page, 0,
@@ -146,7 +148,7 @@ static struct page *__page_pool_alloc_pages_slow(struct page_pool *pool,
 		put_page(page);
 		return NULL;
 	}
-	set_page_private(page, dma); /* page->private = dma; */
+	page->dma_addr = dma;
 
 skip_dma_map:
 	/* When page just alloc'ed is should/must have refcnt 1. */
@@ -175,13 +177,16 @@ EXPORT_SYMBOL(page_pool_alloc_pages);
 static void __page_pool_clean_page(struct page_pool *pool,
 				   struct page *page)
 {
+	dma_addr_t dma;
+
 	if (!(pool->p.flags & PP_FLAG_DMA_MAP))
 		return;
 
+	dma = page->dma_addr;
 	/* DMA unmap */
-	dma_unmap_page(pool->p.dev, page_private(page),
+	dma_unmap_page(pool->p.dev, dma,
 		       PAGE_SIZE << pool->p.order, pool->p.dma_dir);
-	set_page_private(page, 0);
+	page->dma_addr = 0;
 }
 
 /* Return a page to the page allocator, cleaning up our state */

