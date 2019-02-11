Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11AA1C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:07:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD23421B18
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:07:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD23421B18
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7EAEB8E00F7; Mon, 11 Feb 2019 11:07:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 798218E00F6; Mon, 11 Feb 2019 11:07:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 612A08E00F7; Mon, 11 Feb 2019 11:07:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 35EAC8E00F6
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:07:01 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id e31so7363068qtb.22
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 08:07:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=xWUNDSgRU80m19aFrocMMhwrjGCARtWhKL6OErSaSMc=;
        b=rzG7L3qDRbFsotjX9EHzEiLy764yfn55EXTqBewHkaIGFd4XrB0nmMdsVoCEb+8umW
         Z0C2MFwF1yxW4cBfl6z4hoc2sjV7jQCVDBapDB/K7HrIBy9+FkLi0LJ6QBlYGRSuDaDG
         J/Hgfo6PE7e+j3JAbg9p0v2nBRlDFN3PBP9EqwKCybBWTyFxRVKIbPk8oVBm9U/L9Zfa
         4BuTKEa8+tGdW6Klld5+ceKqRW72wMnlx+toLT70Ryq2pwAh1ZvJR1L6qwUqQ81fUe0O
         HXEv2U3MIh+Pke/s9JSJMkDvl1JOjVh4pLXMX4LfiJ3S8VFXi3MWa5BOMmBD1GNpxXoa
         2pOQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaGP5BgZ/6AhKjoYUEkfjr5mO8uXqVo+vJ5biIpGtHKw8xRGrPt
	FeaLDNZa5KIZ4WZKw+bfBoazrPqbxC6NwFuXo7gNTY2pSV4Xx+T+Ba0wCrPRGtgKP1yrr2mX/jl
	HOEOPp+Ruuq3Dn7VYQhh+w2msLKdnXYlQmowIVJqizJIpa7b+u/lu1eCOberoaZUhgA==
X-Received: by 2002:aed:3eac:: with SMTP id n41mr4263257qtf.362.1549901220928;
        Mon, 11 Feb 2019 08:07:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZQ6aYuhK1zohp0B2d593AWJl1FPGjzSYe8Tj5uuXSj06KXr76RW4Yq77McdBWjpGs8gmSb
X-Received: by 2002:aed:3eac:: with SMTP id n41mr4263212qtf.362.1549901220328;
        Mon, 11 Feb 2019 08:07:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549901220; cv=none;
        d=google.com; s=arc-20160816;
        b=cGVj6wdsE7LXenNWk7y1MsXWFo7GIifM5Wt3XtaKHRI6kVamPIQYMvIarHTjLYaWHu
         J4jri4Mfe2WG6h8/Z6xNIPrZY27evDuSp9ftFQqqP4IJt8R2/k8nhuoSqfaEaUlp8zer
         MTcF2aQCcKtLwVrnicGI2AeyadNt138bZQZuOKnIPU3RXRqcTyJuNFG40rmfuQWWQQRB
         AhNdiE0Zt32LBhE+ytVbbj5Fz2KLHjw5rz7lEUrn8oEwxuQAHPq7IoFG8duHsbwNocRJ
         94OMi5ACMCeNa6XkpnmIK6PJ9bSjh5yzsZIqZYOXRon10pxBjwsGRxw3+oEtgFx8ZQKZ
         AcPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=xWUNDSgRU80m19aFrocMMhwrjGCARtWhKL6OErSaSMc=;
        b=wR1oXcgb8gDOMW1GLCa2ZDZ9XDtedL7Rsk3H1+ED1tx/4jwNV2s6XNHsqoxHTl2YiJ
         uPYrOcfRR4A2KUFVHYWrXAMN33pI1sNTPNUA/+QkesfUts/XacHesgrkU1hVZ2T9agMF
         rPd3t3PcbT42FaitkatsA54KVi2ADKUhnjltB/y3rQash4hA5uVUDuJ0cT7RdZaKhLSK
         B/bpDCcOPTmuR8PSMsDxHAgImMGwu06gF7s83Fznp9qXh78zwh6iMiNOPfuTY3MJ0A+G
         63BlB9tfXKDcwT0S8ib6xT+rzlvgZA1ABQ1I5XKNdcJZkOC8DXspGcuzC4VxKxEy8L+2
         5DWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g67si69752qkc.228.2019.02.11.08.07.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:07:00 -0800 (PST)
Received-SPF: pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6BAF9804E0;
	Mon, 11 Feb 2019 16:06:58 +0000 (UTC)
Received: from firesoul.localdomain (ovpn-200-20.brq.redhat.com [10.40.200.20])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C7869608C2;
	Mon, 11 Feb 2019 16:06:52 +0000 (UTC)
Received: from [10.1.2.1] (localhost [IPv6:::1])
	by firesoul.localdomain (Postfix) with ESMTP id F007730C2C6B3;
	Mon, 11 Feb 2019 17:06:51 +0100 (CET)
Subject: [net-next PATCH 2/2] net: page_pool: don't use page->private to
 store dma_addr_t
From: Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: Toke =?utf-8?q?H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>,
 Ilias Apalodimas <ilias.apalodimas@linaro.org>, willy@infradead.org,
 Saeed Mahameed <saeedm@mellanox.com>,
 Jesper Dangaard Brouer <brouer@redhat.com>,
 Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net,
 "David S. Miller" <davem@davemloft.net>, Tariq Toukan <tariqt@mellanox.com>
Date: Mon, 11 Feb 2019 17:06:51 +0100
Message-ID: <154990121192.24530.11128024662816211563.stgit@firesoul>
In-Reply-To: <154990116432.24530.10541030990995303432.stgit@firesoul>
References: <154990116432.24530.10541030990995303432.stgit@firesoul>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Mon, 11 Feb 2019 16:06:59 +0000 (UTC)
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

