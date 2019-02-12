Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB33FC282CA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:49:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 896742083B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:49:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 896742083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D6EC8E0004; Tue, 12 Feb 2019 09:49:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2866E8E0001; Tue, 12 Feb 2019 09:49:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19C888E0004; Tue, 12 Feb 2019 09:49:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E2F238E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:49:14 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id s65so15873765qke.16
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 06:49:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=xWUNDSgRU80m19aFrocMMhwrjGCARtWhKL6OErSaSMc=;
        b=h5eP61EplTVZt6orNbkb9AgNH7gi0HjFPk0iXzmFgyCrbrs/ICsdzuEtxF8SVQ+lho
         0U6BvdIv2ue7MvWP5dTN8YRI1GXUDY7/54FrBiTULq+SRo0/KFQ1KE03qWyQyoDB+yAo
         M0Q42TWohQgWJLy+lRvkul+lUtjUkKy0hJco6IYm+GIkKh1eqxX4sMNdB+I0NuueN5xZ
         FhKAY+oXc+PedT9oYSXYu9JOXYbQbV7mBhONspupHsS6pS5g6oGPi9HvZZWrgejRWiMl
         Jsp9a5wsgXw/n0CIa4JnPkadl7azBhDMuwXaSPVoppyxUmqGjSVcvDYMhY2OtDkAyZGb
         8AuQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuakNvGtsEPT5807BopISLC4JJ4+dxb6LkKDBM5kwwTaTAX5kyPa
	KeW+eebGbEDKUTNLyvXmOO2Znw3870te8C8Kn6D48S5tb8t7ofwt6aTmmBYIBI7+kyQdSkofmvu
	68pJUrtUezZGw+b/VquiM1qrVkLkNUTcQA0EaIeu1VrU7u+mA3V4wIoEdT/Kn8x4Szw==
X-Received: by 2002:a37:4289:: with SMTP id p131mr2899167qka.3.1549982954704;
        Tue, 12 Feb 2019 06:49:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ1YpKA645uZ5q/2zSlVm5xSid2WyCGblfXmc8T34yx3JGuwN9lZDiSCCs4h1ji8Fu7F+6W
X-Received: by 2002:a37:4289:: with SMTP id p131mr2899134qka.3.1549982954091;
        Tue, 12 Feb 2019 06:49:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549982954; cv=none;
        d=google.com; s=arc-20160816;
        b=vrRx7uDvy0Oec8gvCZGgDo/1M4LIyDshl30rPpYKEE4u985Qnj+SzgEB3oLgFiUEIR
         E+V4sHuycmpsmSOyp5zX8IZqYu45l+R65gDyfMKWS2zGjHYz0Yfgcdn2/iNHobOKp0ut
         J9AG97tIOr59m5l6WB8wrvulVNzWTocuNavkScWwKc4G3GxsyLNq3pS8I8YGhXkX/z/Q
         OylSONRpxYqsIIqjkI2LiOUtsSRa3ex1TYXv4XkuFI4imxbg0egy7FozsBycQhejOckO
         pr0dYaUUAgUSH34Q3uM8DbO7pPr7/NiwmrfNlz5SzbBc2stf7wEiZSSxeRR5v2w914mY
         zqqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=xWUNDSgRU80m19aFrocMMhwrjGCARtWhKL6OErSaSMc=;
        b=vULg10VFUKCcxA33ULRrabFkcCCQHvNGKoYN+ocl8AZjh+FReDdGIhA4arQhP+LPM9
         wdhLhLwq+VvZmPInmQLtKwih7VdkqpNrGz+7MzBC7GvNyUcFwmAIutKFcORF/hA4cBHh
         yuode/XvfLCZUMMXMR+h1F4TbV/kLCH9XwWMY8ZRthU+7UpoJBvWlTWe6AsDt48/z215
         9KFFFyCFA8SzrqXmC08RvYUT7We3Zx4b6Sjai+2PtnNW7n4IhwC8lzdTzyX1hiwqo1Jb
         itR05iXo1xbS+BduK6wOxzUchO58lSWliYZR+Z8q3m4KSSO2UxXpsb7v1jM14maM019P
         jmMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q71si183038qkl.255.2019.02.12.06.49.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 06:49:14 -0800 (PST)
Received-SPF: pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 09C6515F26;
	Tue, 12 Feb 2019 14:49:13 +0000 (UTC)
Received: from firesoul.localdomain (ovpn-200-20.brq.redhat.com [10.40.200.20])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2EBC85C240;
	Tue, 12 Feb 2019 14:49:09 +0000 (UTC)
Received: from [10.1.2.1] (localhost [IPv6:::1])
	by firesoul.localdomain (Postfix) with ESMTP id 5AAB2306665E6;
	Tue, 12 Feb 2019 15:49:08 +0100 (CET)
Subject: [net-next PATCH V2 2/3] net: page_pool: don't use page->private to
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
Date: Tue, 12 Feb 2019 15:49:08 +0100
Message-ID: <154998294830.8783.13100889845783259630.stgit@firesoul>
In-Reply-To: <154998290571.8783.11827147914798438839.stgit@firesoul>
References: <154998290571.8783.11827147914798438839.stgit@firesoul>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Tue, 12 Feb 2019 14:49:13 +0000 (UTC)
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

