Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CD13C48BD8
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:27:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 221E0204EC
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:27:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="jk74jAEb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 221E0204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73A718E000D; Wed, 26 Jun 2019 08:27:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6752C8E0002; Wed, 26 Jun 2019 08:27:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CAC88E000D; Wed, 26 Jun 2019 08:27:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 046E38E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:27:49 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x3so1531915pgp.8
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:27:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BPkZHHIHMHfLZtQnho6ADB3HOg0fG+ODbmu+2ZG5xyw=;
        b=Ahhg8m0kApok6BZ68ZTuy201l5wM+fQSmQ0kE0CCnvU9sTbWkmqiVLZQORRVFqHxGi
         JtUAhxCNWACr4JI4tWusveOIvCfkGKiSiJAskA6yf1v2IOjPxKNujKN0FoXzXNvsROd/
         qEV077gFGnvwHEdQrc3S8H/b1qjqF13O2lZrr8nMOgNISLhoE55qXrNRkfciHRLCrs7v
         pXRFy/47p/5WjaLa7DMkHY5P43XPAwGBhDtDRiEfsbKjIZVsD77w9CrVCFDT0Sq74sMg
         io5KXuYKQJcrlQx4rqJA0mktHMAAVG+2djG0FlX4rTJ5P2nabnb7yahL5t7+M2OZwBhe
         MkVA==
X-Gm-Message-State: APjAAAWvbGKTuG9SKDYbL9SoBtSJqOaH0hZEOEC3DoU+ZyqT797ii22l
	9qEqUKzJDFZbfcxdZ2hzu9qULWWTxbWzSkGMDa5A38/ZrKEuoy3NxUe9QHRQvBtGZm7pClL+BMQ
	pcBSpo58aQ8W3205MqoWyAJkOboPFENsPeLgeM1YlLQWWr4+UtuYWIm2AaMPkJDE=
X-Received: by 2002:a63:2985:: with SMTP id p127mr2576625pgp.400.1561552068438;
        Wed, 26 Jun 2019 05:27:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4BSPCH/hi/FHhS9eckS1c81f1aaMsOXnlOCtFEKBZsvrRgzTeN+qt0j907lxSuAKYAGac
X-Received: by 2002:a63:2985:: with SMTP id p127mr2576581pgp.400.1561552067712;
        Wed, 26 Jun 2019 05:27:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552067; cv=none;
        d=google.com; s=arc-20160816;
        b=TNGc5JtfbgN0vj1Jgx0FvQDQ+DcuFl/shBIAl6sWCTlX5B62dDiUd359inWJ6kxYru
         2NMvqXgiPiAnHyKPWOoEwJybBDivB8CiVpVNGle6NhWsDMpHPJpvcKZW7H8eX4na5Hq3
         TpxES6Z4/9G9Chmxaqj3Xs86WVe2zrmtftF+/qhWCFYFSsfOj2+6IqmJgMABWQD/dUZ2
         xRITEZX3HRjRtN/W5VdNJeLeyxkHzDqIiUph7Bgp3QbodJgoDpOPjy7HQ+eFs8u6JfNA
         twfsr56/Zxvr7iM0Yr6gqQNOw3NRgY1qCmw4Wtu8bkKlA5QJDiolGIvKBz0qL7s5a43F
         5c8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=BPkZHHIHMHfLZtQnho6ADB3HOg0fG+ODbmu+2ZG5xyw=;
        b=u/8HmlaUAY5zzyPBECO5m9YRqbImZCtRZ7FrR2xgUxGqTyznL+4lIHQ6oqM2YmqOXL
         jEY6IHObY9BvXf6C++f5rbOvJ7XvumV3cpqLy5Oye6iNZ3blBH8qW/JHGwTqecMyNGSv
         D1JhK/pBsZoZ0BP62awCucF30WBe3shZnMWHEflpD2OduIRtMb9hMH1n5Ufzp5h2v4rT
         C7hKzuGk7Lu27R864pAWtWa50JC2ipHJflEQ15bm++J7N3eWYq7JBnPjucG1mBcjVzDc
         W/duaW1y+oUHY6Oqkjx1XuA5/GgAIKeH9bz3fYLoeLWlFmmQgSPKsgKlvUt3YW5iIpQn
         gLJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jk74jAEb;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s24si12006684pfh.227.2019.06.26.05.27.47
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:27:47 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jk74jAEb;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=BPkZHHIHMHfLZtQnho6ADB3HOg0fG+ODbmu+2ZG5xyw=; b=jk74jAEbOrotcGBG5yTuu12mN9
	C7kyksJxP1KCYqUPKHazaYWg5kM7S7/Y93S1Dfun5FvBnkOn75aymSxIlC+REhc60+4tcuXRgTbBS
	H5faXnHQq7hSL832z10DovznO408+wuzv7SZabppvcvXXiPJG5+EAKioh0Sqov/x3VderuyLZ/f3J
	vJBmHaWcyJS9+qeWoVMZdkaOKi1XqR2KxkM7w9FwTgKp7Pu5xlHdH30hk8T+St23PY28xR1/Pkz4r
	au6n9mzTWdfrklWEZECBO0+bqRU2RIMg379zl8o++5ajUzWzEVtuOnrvMCrwHG3Us4QU4vqDgbMkG
	UbjgkTBg==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg71b-0001M0-MI; Wed, 26 Jun 2019 12:27:44 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 06/25] mm: export alloc_pages_vma
Date: Wed, 26 Jun 2019 14:27:05 +0200
Message-Id: <20190626122724.13313-7-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190626122724.13313-1-hch@lst.de>
References: <20190626122724.13313-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

nouveau is currently using this through an odd hmm wrapper, and I plan
to switch it to the real thing later in this series.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/mempolicy.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 01600d80ae01..f48569aa1863 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2098,6 +2098,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 out:
 	return page;
 }
+EXPORT_SYMBOL(alloc_pages_vma);
 
 /**
  * 	alloc_pages_current - Allocate pages.
-- 
2.20.1

