Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EECE6C282CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 01:55:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADE52222C1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 01:55:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADE52222C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 047C68E0002; Tue, 12 Feb 2019 20:55:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F11298E0001; Tue, 12 Feb 2019 20:55:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD93F8E0002; Tue, 12 Feb 2019 20:55:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id A6B428E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 20:55:45 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id i18so756935qtm.21
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 17:55:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=Q5J1u+AnvDflsWVjNFYr7WMWX5vJAPsWaN49d9KLIhQ=;
        b=hFBTu1bXuMGclAInikPZo0uGVxY1ITsy1kvj5OYNbeAyzeOYRrHm6mlpxXscQr8soz
         xmqcSTMQTHepe+6wGvCi5kCAd0LE4C7bWVU3b5lAcVqGWtSB0WQ1GY5fK5+i1Uhg5eBk
         T6EQUep0xXBerCcIg4FbLgec22KzD2Al++g8IvrLoSEApvp5Wcam+yHDZZS2tlPE6AmC
         1zFM5KlC7abV1LGDkUWEnEJ43oVL5WyA9rAISdHpf5czqVcyqr6Rh83H/jo0cMF70JEw
         DYv/iAM96hFADj9Xdts4etlxzS0kr3mIyNpUTbIcdKbEe+J1z6bPhr/ArM/cYUaX19zv
         Og+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubVHx7ddVkX0V0P4nsiQqLEfpT3aenwhRK2MWivnTtP2HoYRlrH
	MKTy8iXseszK1RPNOiAVAfDKuMR6eqhX+rbK8aGiJllrmPuaRKgKLYHWe/FvGqUw7tSVVZkmdL6
	SS7umErhrXsJgO5yOo36E3H7P4PgJDqKhzGszloKa6teZWgTihiYZ7dNLuK31yHeBRQ==
X-Received: by 2002:ae9:f101:: with SMTP id k1mr4979279qkg.111.1550022945415;
        Tue, 12 Feb 2019 17:55:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYPRDAieuXEKmdf2puAsvXyMLl9g4X9sdqdNIw9TbYtEzvrhQ6qKXK93Jx3iM9iIaxNugld
X-Received: by 2002:ae9:f101:: with SMTP id k1mr4979257qkg.111.1550022944938;
        Tue, 12 Feb 2019 17:55:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550022944; cv=none;
        d=google.com; s=arc-20160816;
        b=fv9gvi2g98gm2rGoQW6fq+J+rZ5bbfpGiXCg85X3iJevH0lq1hn4BABKbLddbSNk0u
         eaR3638U/HsJy9TpUk5o1XrJPE3oDCZqblSbCcBby9pYKdgSBDaeu+kX6p3fIUObUVw5
         meRjFRG4C0pKFUe2AsmHp4QVGYY+TRAZcOlzX7YP4vokNEDti7cPNXDxorLbBEIM7U3I
         7yqqlclw6wZgw+GYYh4Z4wCBGQOhwrrNAvK2EwTIQAWTKmjbZSPS2Ut7W5NIBr5lvklI
         2JdrCGPvBH4em0KUtTk/2fGue6FHv2/cizp51ojmGLYZb+DagBhQ02KmOTRGUMV/qD5g
         Lyqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=Q5J1u+AnvDflsWVjNFYr7WMWX5vJAPsWaN49d9KLIhQ=;
        b=yylaZaAFPpbdETBvnr+MbPZoQotaT69rzMrjr/lCrY0jXb0/Jleo106kha4o7jmsLX
         YvXUwoYUnnoTqQUG2tCglh7CFXprEoHJfMPfpILnZ+5alvc/WFNkcDy/MD4cPZR5qzaz
         TsRlt8I2JS5UEL9NZWw2nso2RoXSv6sQVOdHhIKEx2HxH/R5lOR09Pu3o0WAKDRap4Pq
         q8zpDJ0+e0mr8iy1yFrlbqUHH2874Ojo+zs2KMsiF5goZyJsom1kS7ingxLUnJpzP5K9
         KcxwEbfYXHj9RAC4bBsE/CjKw8QV/1Jpb8thFkyiViY7n69nBdY+g37qlT6atGgdyt4h
         WXEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r4si4871320qtb.2.2019.02.12.17.55.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 17:55:44 -0800 (PST)
Received-SPF: pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1B548C01DDE9;
	Wed, 13 Feb 2019 01:55:44 +0000 (UTC)
Received: from firesoul.localdomain (ovpn-200-20.brq.redhat.com [10.40.200.20])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EF59719747;
	Wed, 13 Feb 2019 01:55:40 +0000 (UTC)
Received: from [10.1.2.1] (localhost [IPv6:::1])
	by firesoul.localdomain (Postfix) with ESMTP id 22A2731256FC7;
	Wed, 13 Feb 2019 02:55:40 +0100 (CET)
Subject: [net-next PATCH V3 1/3] mm: add dma_addr_t to struct page
From: Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: Toke =?utf-8?q?H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>,
 Ilias Apalodimas <ilias.apalodimas@linaro.org>, willy@infradead.org,
 Saeed Mahameed <saeedm@mellanox.com>,
 Alexander Duyck <alexander.duyck@gmail.com>,
 Jesper Dangaard Brouer <brouer@redhat.com>,
 Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net,
 "David S. Miller" <davem@davemloft.net>, Tariq Toukan <tariqt@mellanox.com>
Date: Wed, 13 Feb 2019 02:55:40 +0100
Message-ID: <155002294008.5597.13759027075590385810.stgit@firesoul>
In-Reply-To: <155002290134.5597.6544755780651689517.stgit@firesoul>
References: <155002290134.5597.6544755780651689517.stgit@firesoul>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 13 Feb 2019 01:55:44 +0000 (UTC)
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
Acked-by: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/mm_types.h |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 2c471a2c43fa..0a36a22228e7 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -95,6 +95,13 @@ struct page {
 			 */
 			unsigned long private;
 		};
+		struct {	/* page_pool used by netstack */
+			/**
+			 * @dma_addr: might require a 64-bit value even on
+			 * 32-bit architectures.
+			 */
+			dma_addr_t dma_addr;
+		};
 		struct {	/* slab, slob and slub */
 			union {
 				struct list_head slab_list;	/* uses lru */

