Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD8A0C31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:27:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A59042089E
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:27:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Bpx0/+YD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A59042089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 733B78E0007; Mon, 17 Jun 2019 08:27:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E46B8E0001; Mon, 17 Jun 2019 08:27:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F9758E0007; Mon, 17 Jun 2019 08:27:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 28F588E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:27:50 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b127so6958291pfb.8
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:27:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=K9g0rbDWkkxSMGlYVgcFvd5xNggbvRNJSx9Dd0Ro7/M=;
        b=ArshkJxIgZLOSxO3xzPM0xjT+VaR6BH0tp+71lU+z6tGMHF/oT2W0SpJ26/CWXFE8H
         A34BOYaPFx6GDIJx0fCDcGJtsJVGIISr70N+ZC5LxvZ9GNVFz3Q/+1escgyh7bytoTvf
         Bk/6u3ezThI83OgERDFgGH9kNO4CCOFWuz8MrE0gdqtln+bcNFZ4DUwf2rJfQD7gLdai
         zuiq0NKM0KUZFvhYGeCOj/X4kar3jkz/YKappFog+tlq0dWoEVsvO1INmeSugIzefrvW
         2/6ZmJxKW1RC8TUJ8Emq1qqxtKrzAE6UQ//TY8JjEwnpgy5jQ7SynhQwDbWYwK3P4F3r
         WCWQ==
X-Gm-Message-State: APjAAAVjmFfWs4Fh1/ygk4UIgLnCTr0ukb4GlFKDqJeMdnDXyQpt75gD
	YyE58TL+lSPQZv8sIclQZ9lwkTRNVILYUSUZXZXqJIWNRDqi03AP5CzEdwl+DngF2jMLAO8nqP4
	D5zY8KMU9ojIGjdowvX6sVKJvGA0AWhg3PJAOD0iWjyOtG79eWkYiu30W0Fd8bS8=
X-Received: by 2002:a65:4209:: with SMTP id c9mr50135414pgq.111.1560774469756;
        Mon, 17 Jun 2019 05:27:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXcI5VjnktuAuVxp2f465/1pXQUydBxvT3bpOhTjFq4gCaJ8/bYLOMBjriGGwB37s3FZNH
X-Received: by 2002:a65:4209:: with SMTP id c9mr50135383pgq.111.1560774469102;
        Mon, 17 Jun 2019 05:27:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774469; cv=none;
        d=google.com; s=arc-20160816;
        b=o+H6Ph0dTiQp0v5Zt/kYh4NTNUUxYYvTSbZHVuOvbonf0W0sUzyk8oQz9xCRCvEp+6
         nZTdlX5OmH9ObATIfSjeraXC2Tm3ilYNpUM41RWTzd8kjXBU4SSYnJ/q/oNBe+V6vXr/
         gQph8uS5T78ocvuMOhqKHmlEwUCy42oWE07spKtpDk6ylEF9PyApNZ0PSCtgnaBbRX2t
         jrSjt6aBDAnOr5wI0IFtRXqJnBHdfxxo3SS4tlNDueUAFK+2VRSbR4t8B6H9vaG/ehV7
         l87+r79l/3XckHKoQpbwZCS1ljr3QF5rYLCnzM7DujYB1GZl3svtdaOBJfYOAXTExRTC
         e9VA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=K9g0rbDWkkxSMGlYVgcFvd5xNggbvRNJSx9Dd0Ro7/M=;
        b=dde3ciQXGSg41i5n/oDXZDq2z5P6eBIpN5n68j6EUxvLDCB37g8hDzCDH1UBkNpUKP
         dh+yNdI6TH1wO67QHeEw+8f4XL69bvL6BH7ntzSlK/2EwCJLsBcWMq5SkvjUpoWnz/iv
         kyz9Cp03/pQ55b95WWYh45mUba8OzmKa6xQLvCyuEe/LxNYlz6nq2q1p7vbA4VRxNHKa
         4UAcZM1kPkJJFbVLSLk3F+XwOPZP4wYUJgWFH94sPwdVk29eTqHZVqu+Ss8fdNtIlbjH
         uGaNPzMK4Sq3ozNQ47YUPaWbrQQ4FD8cElcjQJI4UCAsqbOlhTVo9opx8Eqy1tujNx54
         6Qjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Bpx0/+YD";
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l1si11265778pgj.504.2019.06.17.05.27.49
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:27:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Bpx0/+YD";
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=K9g0rbDWkkxSMGlYVgcFvd5xNggbvRNJSx9Dd0Ro7/M=; b=Bpx0/+YDXKRBCn8UCT2IVcE71B
	X2OqFR2P6cQnqBb88ElPZ9QzRIcJuB6fh/pwFQhL10fCq/BTxAcobe/zVEp/r2n7V0pP7sSWfY3vI
	grf6B5YyGDCZtvbTmqOmLHV4oQdCc5CWcHzwXul0Xks3Jy5S8OX2HaJLSwsERvlhqYUhbplZj+Hbe
	nGltq+FfZLW+kAOtOqlrJUw+V8Bf9yuRaWt+YX/y8HdJGvUzLzWUpFih1p8MBWWbxiSlX6mIpF/9f
	YI8qf3+O29zr6OMxqhKepaX1ADDNERghmpgXvc2+qF1AVzDFKhLXEhxF4xHhfGx1sWibYKtViGFl+
	Wp33jgyA==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqji-0008Q6-8H; Mon, 17 Jun 2019 12:27:46 +0000
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
Subject: [PATCH 04/25] mm: don't clear ->mapping in hmm_devmem_free
Date: Mon, 17 Jun 2019 14:27:12 +0200
Message-Id: <20190617122733.22432-5-hch@lst.de>
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

->mapping isn't even used by HMM users, and the field at the same offset
in the zone_device part of the union is declared as pad.  (Which btw is
rather confusing, as DAX uses ->pgmap and ->mapping from two different
sides of the union, but DAX doesn't use hmm_devmem_free).

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/hmm.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index dc251c51803a..64e788bb1211 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1380,8 +1380,6 @@ static void hmm_devmem_free(struct page *page, void *data)
 {
 	struct hmm_devmem *devmem = data;
 
-	page->mapping = NULL;
-
 	devmem->ops->free(devmem, page);
 }
 
-- 
2.20.1

