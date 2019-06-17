Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A523C31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:27:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 189AB2087F
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:27:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gQAEn4aB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 189AB2087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F1B78E0008; Mon, 17 Jun 2019 08:27:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A47F8E0001; Mon, 17 Jun 2019 08:27:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5E7B8E0008; Mon, 17 Jun 2019 08:27:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B20008E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:27:52 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id z10so7646165pgf.15
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:27:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0rpTHljYB087yEOOsZI9c9yqKYmTPhfVemezVGqcscg=;
        b=j2xGdKAgIHTMiD9lJB8yKFjikdZsbWaFf0BUJPAXCy1yJfXpi/OrhQq8j2zDjS7B8f
         frGeoM/80NZOO5tYF27qdi0t6pJN7cR9bDDPcI/IJvlOHlgy65AAxLRTwrrwu7DbB4UX
         nYivIfCV0zClhUpXyCJsKnMtsrMiBZeQQnQ6FknwRdWkVK6/eXKW9ipahK4uYXHCYqGm
         Kyg0jXwsh+NTt8S5kiTJZRBdMxjrZc5lwWi/Ka6MDj/rGqGTMK9TcIon9pe1T7gZum51
         BTVABcCio077B1+Y4HR18OwRDoIBxDZ7S80e8xOVrwtO7QmErSHtIYe5AtFVH39x6sZk
         O9Iw==
X-Gm-Message-State: APjAAAXfpDzXJjDoXSDdV6QQWOqU/WzxQP1Exae6GVaFp6Wv8OfPMVvw
	ciaOXayLLDPO64j4vwoGiwkHORs5T9Zt3f+JD+jvME+LOfOU9r1vXQYrgYZbhrwFNmEfYvFdGhS
	iY3fQ00wrOGQo3lx/wQxmfxnTk/EieVQkO2kAYhgNpoOO3TyRspuhzNbcNsZeNcY=
X-Received: by 2002:a63:80c8:: with SMTP id j191mr21007446pgd.442.1560774472287;
        Mon, 17 Jun 2019 05:27:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznQn6USDLJ/2iDZ84aSk604KWShXiAYM5ZJoWMhDeXBnD/hammYFm5xqSYtbpt8iDrMTma
X-Received: by 2002:a63:80c8:: with SMTP id j191mr21007390pgd.442.1560774471454;
        Mon, 17 Jun 2019 05:27:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774471; cv=none;
        d=google.com; s=arc-20160816;
        b=RNaItn6bx6SiWlOqjGf7nttLzBv/LDut+B5K9dagD2Ftt/bjwTs7x7i9ZWvJGGui2u
         HjSHR88ZTmqK2skq8hEZoGPmWQYxI9X0JHm99ul3/Bupf5BdjaYQ+Hzmjf8U/xhcsjW4
         KOdPSPE8DXIXxBCYOJHGRfpt/aJjXTzKyE4qYeBSNZy9rXZCMSb8Yxu4XF0KcrqB5Q4r
         cvrNpOgYxViqxDi7jeNbTam8vy1fGvoPLx/O6vACfgO3Sw8K/KkyMhUzZdbb/zZTRVgJ
         soM5DiG0NyxndVezfYGoaPuOzCIyuYmdN235GP4UxmPfrDt1BFtcQwGVgd5BnXx/FcZr
         ouSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=0rpTHljYB087yEOOsZI9c9yqKYmTPhfVemezVGqcscg=;
        b=XYpCC/b2beI2hNVbov1uzzVt/e/xJtp8T4nbqj/MnEXHGZM+eIYudv4Q1ziciQnxlR
         TIAbDlNVCg5Ir2IGMlK2XGcbXRM1oCOGOiUaT6FrTPt+c5jYHUQgLYXkHre7ExgdSwb9
         oqsvZDq3NWdJH34BjjESy66s5rhGZOhw5O7JxY5cSddMa7bcj9EwobdMSEhKINSs3F9F
         RmbUrwUA+ccEN+3eAbacWqSFXpNzY7TX9uJy+vCJlhsL6itNzQOfvuTe1kA7v61ME7i8
         DpHv5kooYPFYzqDT62KHL+aJlnBYe7HsLWFYF79L+wEwKvjyFn9RlWmOZc/BX9rb5pRB
         8iIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gQAEn4aB;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s6si9942649pjq.108.2019.06.17.05.27.51
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:27:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gQAEn4aB;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=0rpTHljYB087yEOOsZI9c9yqKYmTPhfVemezVGqcscg=; b=gQAEn4aBEmQ132Z0wP5I7jCauB
	LBw2hOlfvCDQ7d5fQKNPO6djGCxEKQh4CVo9EuYbFLF4QJhOgBejZ8OlWo206WldjRYOfhT4AFXLE
	9L9qHayf35ChGEv7g6MIcpHnXhCiExQ4fiDCZ31LF2RdPao4FFTC2z3uorshZP+Aw61Hgacx5tekH
	AsvC3ssCa68V+0zIIoesTfI1zxzVEaOuvsIAMGhuXyHQ3tSMzjWx14WKmPXgm3FDPe3h/HDsavVrv
	jUYfnpdHPmfR+1OXsOoS+idioOXrQhBTR8rrL0J5g0GVZnduKQ9EwD/JKCrznGMn1BshcDxe2+90o
	qyyv31zA==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqjk-0008W5-FE; Mon, 17 Jun 2019 12:27:48 +0000
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
Subject: [PATCH 05/25] mm: export alloc_pages_vma
Date: Mon, 17 Jun 2019 14:27:13 +0200
Message-Id: <20190617122733.22432-6-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190617122733.22432-1-hch@lst.de>
References: <20190617122733.22432-1-hch@lst.de>
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
index 01600d80ae01..f9023b5fba37 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2098,6 +2098,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 out:
 	return page;
 }
+EXPORT_SYMBOL_GPL(alloc_pages_vma);
 
 /**
  * 	alloc_pages_current - Allocate pages.
-- 
2.20.1

