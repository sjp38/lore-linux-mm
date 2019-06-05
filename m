Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E79DC28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 18:37:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D30320866
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 18:37:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="HzbQMt6u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D30320866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 921DD6B026A; Wed,  5 Jun 2019 14:37:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D27A6B026B; Wed,  5 Jun 2019 14:37:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E9496B026C; Wed,  5 Jun 2019 14:37:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4CBCD6B026A
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 14:37:10 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id z2so19334339pfb.12
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 11:37:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=lX9wuvmvvhsbv7JT6JNhJ0QWl+hp9xHwxNjKJqmN6U8=;
        b=Q35LcJdZrqhpLpDieA+JsrmVuiNlVWtrrlSF4/6QAT0hzx8NeeGVzHkeLhb+RYTRDr
         o+JDFK/pnOtzqo9PwFa2dnzpNkLApsPZiiUxKDnapl1TLZgNhxApkWcdwr8GzApAzAuP
         zVV22N2BYlpNMnKWzgky5c6ZhRRTP6l9lz+d8p0hgE2G8TJ0Jzi+B2lYbQOWINwY6PIs
         QByvE/1rVw+iJY+Z8eaCDXW+lk7yCIzISF06msGOTQT2W6ZwiOuIw4GyeTY06XqaerOF
         9YIwocQWUaVD5EYTdvNOral4/oMEjfbH9T7bAIjvKhzJO53MMFdEe3zKDSHJSKAc1VkZ
         ZFKw==
X-Gm-Message-State: APjAAAWaVpxJBDa8xtEuu0JYiOfNhqhqMhqgFlFNd2Pq8B/7qf5Cp+ah
	ZnpM/cPxHCjo3tfkNgzuLGi7yLHHQlLKscLuq+YS36iyEr+ICAB98AE8Ab7AZvyMQrauClfoMw5
	uwrrWZxU+9uHg1G0XyaGza5aVqXwQXdWGg9owq2JIos/ZM61ta8s1yinmj4DBFcs=
X-Received: by 2002:a65:51c7:: with SMTP id i7mr105841pgq.211.1559759829683;
        Wed, 05 Jun 2019 11:37:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRYDVwdzh4GYof8RnkPr/Gmq0B6Gejd5RNFKgL/HCNFAAPf2P7cGF77JbfbNGg8JaxDU4W
X-Received: by 2002:a65:51c7:: with SMTP id i7mr105734pgq.211.1559759828606;
        Wed, 05 Jun 2019 11:37:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559759828; cv=none;
        d=google.com; s=arc-20160816;
        b=AMitZSdZNhpVrMlCnJ/GXRU0Y3MRfxueh1JhUR9MXGLw/Mp+UhZq5a7X4RMW2hv6M/
         /KZGekMyQghLWemPOOxPx7SXO/5atfqHEssA3oGoG32JeM0j4RRD6ksORKFvslZXHKvq
         UPqE/2l1rHe+VnftBnFi8XHearVpO4iUrz+zW2E1ccJeGcMVC338n8WGZHOEsYKdh9Gw
         ocYFz+bDTFtDG+76V/GtR+Gd45iFylIWozmJK+DC4EXPA1xfqfCeVsZ7FRyR+RcJpRi0
         fLUpfdTeI3gxN+1vAr6Ym9EeE3fx3E4OaMzXIz2/hfgeuj+TV18MfRNCuaO989R7t/yQ
         +sXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=lX9wuvmvvhsbv7JT6JNhJ0QWl+hp9xHwxNjKJqmN6U8=;
        b=vvIgifYgFXB1xfJlEm2YtTQowMWjyMSwjyKUsjazZ2fHgBzd5En4GINc8WIEvD6Kii
         aBwXFzo8V/1ko9fuox98XFlMq7P6LUzMcJCSprm6omGSkNkOkkBTHGRLGrKcUM9Zirld
         pM0bMikWt7HOoY5r9Nc7bk0kngrVhwKHcvKZnSQ0kY4zBnQQzF24Ku5U+lzfBCfwqjf5
         LIGOuNQgG9KE26HNctiGO9Tz6d4en6o3/5zb4G/8N2mMLlpI8JgpeaQtlAxc2w4WL0OF
         NXxUDvbDSTXKHViFDQOTvIYLQQwUW8Yvq6gE7HXX5+LXwl0WcUD1MqYRdpy71kfdYCtE
         4ipA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HzbQMt6u;
       spf=pass (google.com: best guess record for domain of batv+b63b843e11fda23eacb1+5764+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+b63b843e11fda23eacb1+5764+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k19si26682346pgh.143.2019.06.05.11.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Jun 2019 11:37:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+b63b843e11fda23eacb1+5764+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HzbQMt6u;
       spf=pass (google.com: best guess record for domain of batv+b63b843e11fda23eacb1+5764+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+b63b843e11fda23eacb1+5764+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=lX9wuvmvvhsbv7JT6JNhJ0QWl+hp9xHwxNjKJqmN6U8=; b=HzbQMt6u3IGHt8A5V6WGQ6OAl
	2re5rNst4ZCF6GkrbfG1vYAOpRPE0DUodARm6IgqoR3L7r5gwlxQpIxjJqu2RNd/qzz5dJ4uy1rnR
	BhILGbOO2N17VaqJ3lL1UBCrXMZv6SJOITF0aYeQDfEB6rcKg7hAe6gA0Ez92T3RniP8fQlhwakd3
	+XWBIYvBfxeC4jGs+EPd1XvDWL4hqF5OpcYzZIuGIlMpNBNrJNNrAE6HY/Yphscf7R8RVsEInxcVV
	DTo/AUl6VYJt2Qh8JxPgn2X85wdi+DXsdq6EWmvyEiPrKgmHO+ob0pXJ7BN996WYq2ctC8yjCVal2
	DmmZcgE+A==;
Received: from 089144193064.atnat0002.highway.a1.net ([89.144.193.64] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hYamX-0003ZO-4t; Wed, 05 Jun 2019 18:37:05 +0000
From: Christoph Hellwig <hch@lst.de>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
Subject: [PATCH] mm: remove the account_page_dirtied export
Date: Wed,  5 Jun 2019 20:37:02 +0200
Message-Id: <20190605183702.30572-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

account_page_dirtied is only used by our set_page_dirty helpers
and should not be used anywhere else.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/page-writeback.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index bdbe8b6b1225..1804f64ff43c 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2429,7 +2429,6 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 		this_cpu_inc(bdp_ratelimits);
 	}
 }
-EXPORT_SYMBOL(account_page_dirtied);
 
 /*
  * Helper function for deaccounting dirty page without writeback.
-- 
2.20.1

