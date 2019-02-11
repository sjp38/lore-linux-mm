Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 028ADC282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:07:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE45421A80
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:06:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE45421A80
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48F0B8E00E9; Mon, 11 Feb 2019 11:06:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43C798E00F6; Mon, 11 Feb 2019 11:06:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 312CF8E00E9; Mon, 11 Feb 2019 11:06:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0206A8E00E9
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:06:59 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id f24so4646064qte.4
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 08:06:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=CBkJKA+YMVyNw45r/sFZzOZnj6jCaab8O3cbgYdAWq8=;
        b=ZQNLGdBciRE9gIJ8OQcMLR71Q++gXVJTMlJooroi6jGvBgSVYlNk1UskSsX5/3/58n
         6Iq514rIkBp5zxm5qbhb4pIwOtXQ66IH34merCJO+pFTTW5WXV8Rs8otfVd7xTIg2dax
         ob9b7hKV2K089G/Q2v/rG8sFD50hgQpUczcZXYcjzWledYEIovXBp0vZPbdRqkIIHvnj
         hVzBP+fzypLGH7TrazCaWUJxAR2t5BeKHpXV3MyvXsDpOP9Am7atvtdt4Qh9fwKbQ/2v
         IGfjepGRpqy7LJlr0zdImPUuVFsz9Z2/J6YQhs41CmNkW6EA8D9LPbuKq1R1unUCfj9S
         9EBg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubeoZqW2tLd83+Et6xTE88yi90W5jSg+Gwud/uVw1EGmAuHsJIz
	pIa6Wk1Zu2E3XkgYn/QIXD0I54X4cL2WrDxcyVkQydRFQ4a9E3QSWjihHnH4aB0ZlD30ONUoAoP
	yCoB4Tpj/dQmzqK2mnWkOXC4r1jvUtJbkNZzljo1Kcc/rS+cRN77cy8WQi+3f9wSbcw==
X-Received: by 2002:ac8:694e:: with SMTP id n14mr28299448qtr.62.1549901218763;
        Mon, 11 Feb 2019 08:06:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbHT29heCS/1YuT9HdO3R5WbruCH5+Z/WPTCLr9WlPx4T9MQVaIkkISPinfaUE0oQOgaWpa
X-Received: by 2002:ac8:694e:: with SMTP id n14mr28299389qtr.62.1549901218032;
        Mon, 11 Feb 2019 08:06:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549901218; cv=none;
        d=google.com; s=arc-20160816;
        b=ahCvVDBQFnMQmDOY8O86JZrU7LKg51NkT9l2RoXB31tf6A4Ya1MzfChmnH8J6/vrz7
         Z4CeSo2YxM03N22Vw58+CoygoRIoNNTSw6U82g+L8hvETbaJw0FPkOfmTDrcOrWPO6D3
         dtBdrjXit/1VUdjA8jC25tzb3NulkZhOiqUUKJZc09oK8vkqeVJSXpwdmYkf8jLwGd2z
         RgMLzosk8JbZBWf7QIWo8Uucr4jmXh9iJMSpSsrQNLMVt3OL6p0PUo8A3A2mbLDyz4RU
         jHepbKRVpPGvvklGwBFF49E2vklCLlmxQmIWhUDwjGcqX67BmsKP7TNJmu5Qc+etoZ0B
         MLtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=CBkJKA+YMVyNw45r/sFZzOZnj6jCaab8O3cbgYdAWq8=;
        b=aWj0vzr72liDGPjwuPHZC4uFX+WsgQdiLOucG/huczF6RJiDgAmBuS5M0cIyTDi8Vv
         SF3wJBC6TOiLaAvgyFPcDzzIyhsQlQ4TndKpDUKokpYVa9me+zDtE1iBzOkJ7zoWNP3m
         PP10bQiUJzoauw+VgxTXoSuu9nN7i9g2HGS1GcpGhTZKPmn5v6+gu2P+HNX3r1g4mHlu
         4+SmbUTBQRVy7nsVKAjVOdSaTMXkw1Vtw1hFkty9qTeaSH0dums6GrKbprUlZ88iwufk
         zHUWK017FYJCrUWFTcanrxAyG7gAIW0lX7H9/5Tip9+fCp+1JptFjAMXDwsKIYCdHRZz
         oV1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k1si2370123qtc.181.2019.02.11.08.06.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:06:58 -0800 (PST)
Received-SPF: pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D0B2587648;
	Mon, 11 Feb 2019 16:06:56 +0000 (UTC)
Received: from firesoul.localdomain (ovpn-200-20.brq.redhat.com [10.40.200.20])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CB8DD6013E;
	Mon, 11 Feb 2019 16:06:47 +0000 (UTC)
Received: from [10.1.2.1] (localhost [IPv6:::1])
	by firesoul.localdomain (Postfix) with ESMTP id DEAE931256FC7;
	Mon, 11 Feb 2019 17:06:46 +0100 (CET)
Subject: [net-next PATCH 1/2] mm: add dma_addr_t to struct page
From: Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: Toke =?utf-8?q?H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>,
 Ilias Apalodimas <ilias.apalodimas@linaro.org>, willy@infradead.org,
 Saeed Mahameed <saeedm@mellanox.com>,
 Jesper Dangaard Brouer <brouer@redhat.com>,
 Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net,
 "David S. Miller" <davem@davemloft.net>, Tariq Toukan <tariqt@mellanox.com>
Date: Mon, 11 Feb 2019 17:06:46 +0100
Message-ID: <154990120685.24530.15350136329514629029.stgit@firesoul>
In-Reply-To: <154990116432.24530.10541030990995303432.stgit@firesoul>
References: <154990116432.24530.10541030990995303432.stgit@firesoul>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Mon, 11 Feb 2019 16:06:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The page_pool API is using page->private to store DMA addresses.
As pointed out by David Miller we can't use that on 32-bit architectures
with 64-bit DMA

This patch adds a new dma_addr_t struct to allow storing DMA addresses

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Ilias Apalodimas <ilias.apalodimas@linaro.org>
---
 include/linux/mm_types.h |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2c471a2c43fa..3060700752cc 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -95,6 +95,14 @@ struct page {
 			 */
 			unsigned long private;
 		};
+		struct {	/* page_pool used by netstack */
+			/**
+			 * @dma_addr: Page_pool need to store DMA-addr, and
+			 * cannot use @private, as DMA-mappings can be 64-bit
+			 * even on 32-bit Architectures.
+			 */
+			dma_addr_t dma_addr; /* Shares area with @lru */
+		};
 		struct {	/* slab, slob and slub */
 			union {
 				struct list_head slab_list;	/* uses lru */

