Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A037CC0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A5A3212F5
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="PSbfEnpL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A5A3212F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16D926B0008; Mon,  1 Jul 2019 02:21:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EE488E000E; Mon,  1 Jul 2019 02:21:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0EE08E000D; Mon,  1 Jul 2019 02:21:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f205.google.com (mail-pf1-f205.google.com [209.85.210.205])
	by kanga.kvack.org (Postfix) with ESMTP id A22616B0008
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:21:01 -0400 (EDT)
Received: by mail-pf1-f205.google.com with SMTP id x10so8207689pfa.23
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:21:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=K+5Y7Ez4pfTMCmPiyIGRChGh4O04+aapHsZzDHBkVJo=;
        b=Fmr/jWQeQ0/sWPa+R2J2tSmybi1SdJqzz4kQ8oqvms5uEfaP95jXkng9Q+Ok2LHbPQ
         JPRzw/VhLdPLyNPr7O0UPoN6QvdJNpLsWAgFSTnPtWLQov8/d7r6yI9xAzh5UEwGHqZR
         7XX7hfozmmOM7nuNVKCDE57PHzuTZytaVu1D0EWxF/7a5W636TJoA7n1W2rXhE/dDgpJ
         xSJ5AAheRWZauFSMACPGtdvl18gtIr06ZrWUHFZeY3vRH8knAnv6pCzHolxtAtwDCJRH
         4dfvLJMLSddjj06njZ6UsvVNg7gtFeu4og2sAUS4RWIkzGZfoqDyqXjiM4MwmSrQLS2P
         gVMA==
X-Gm-Message-State: APjAAAWJn81X6jLgPJehyn/ibpxwSq3Td0KTmpseDXsZTIiezDVBQrdR
	nZxEmXmHe3gvXhd0qDsh6lCsEIhb3kgXOC4aklEJCHJvCMUzEU0VO9mG+A1y5QN2notj1GXvF1H
	s7QCSfsIGtNFuoWmmQ/XilBYYjwXwf/oF6mukhWpSN+pzU6tFUYrJmiIhmR3yjOY=
X-Received: by 2002:a65:41c5:: with SMTP id b5mr23638728pgq.128.1561962061250;
        Sun, 30 Jun 2019 23:21:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHP95O/rnBry3YUP5e9NvWcg5epvDp5OEf7vpR8kqvVig10c1souAHRZwUMqgEKZ6QTRBr
X-Received: by 2002:a65:41c5:: with SMTP id b5mr23638688pgq.128.1561962060488;
        Sun, 30 Jun 2019 23:21:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962060; cv=none;
        d=google.com; s=arc-20160816;
        b=zj3IrrLFHd40IMDuDP+Dig0NNIZGuxJVjlRX0zLeRJvqqv4jGS5nsb8w8ltPq+lvP6
         D+OecISkH7meBxvdobOk+TKbVm965GnTL+ZirV3w93bT3vS26BcXFbkXXkqzSrBianF1
         cogPrBthrxxDZ++4cffFaE0UOWbv8Nay4oA/RJgOgr63x+m+EKO1vsOQaUn+FcMKL4Sw
         2U9N4GP5Mzqcn/rBduK0+L63mQhVVjPecu8A+JHfbadKwGVTL0V4dTKKn3evEChvTyF0
         P40MXKyqbWIMUB5OQWmQqls0eaQdxiaQR0+74vCFrqXJv25QJiFeSuEw4nGaXPWfztZj
         USLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=K+5Y7Ez4pfTMCmPiyIGRChGh4O04+aapHsZzDHBkVJo=;
        b=Q8rlH5rvxKTyOnPgsFaCtN9DI/0IMdFOB6bkHaPpGKNsuhLunRJZ1MS1zyil8F1Frc
         Ra5HES97rGCZcGLaJ1Zo99nzID3TqG8EM0g+74nbiK6dnjAifOLWKlhmWFZinYbggxqy
         mkp2wdBqSnpy4Ie5MGDpHMgyrrsE9Mvsj01iObaBYzx652o+V5uJJXIiHJ1PRy5C2XC7
         Z8TWpnDEtYqbZa2U0OMIMl8lkLvvUPlt2HNPoojyFIyA6iYVIb9H9RwFjP15ksIS6xmE
         fh1LUgnJeCNUpcepkvl4kuqYvrTiu1yBpD+womc53yGb+IglCFvlxnbYuzSC5vINeckQ
         P1xg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PSbfEnpL;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p97si9685310pjp.34.2019.06.30.23.21.00
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:21:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PSbfEnpL;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:
	To:From:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=K+5Y7Ez4pfTMCmPiyIGRChGh4O04+aapHsZzDHBkVJo=; b=PSbfEnpLRE8SG9bLML+fRlhf0
	HtVXUwpI1yGra8E8q+rwV6qJm4ONJSDzOZ753xm3ERQHmxUjdhHbZaiUebewXGu/ryXEdIqi7spGD
	Nlr6XlnU/i9TC0WMqh3qrx9cT7ITHZkOAeu54JXvWWQ2MaeC+xjlwX/7+GOXnST0/kVvSEpc1HmW/
	hO3augHviB0cDdLARWF6uP/j90BGjEpU45QJHn+ssAOFsyOrVWV8bsQFxpmwUu7D3kHoTQPtfD/+9
	h1Gpz4y5W71lm5fa5MIvKeZct6x0kCAYyPKLWFw3cLp1onhIVhjCvfTwvaeENThWQJ0FWVoyh0659
	oBUZxg5rA==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpgO-00034k-I0; Mon, 01 Jul 2019 06:20:57 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Philip Yang <Philip.Yang@amd.com>
Subject: [PATCH 15/22] mm/hmm: Poison hmm_range during unregister
Date: Mon,  1 Jul 2019 08:20:13 +0200
Message-Id: <20190701062020.19239-16-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190701062020.19239-1-hch@lst.de>
References: <20190701062020.19239-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

Trying to misuse a range outside its lifetime is a kernel bug. Use poison
bytes to help detect this condition. Double unregister will reliably crash.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Acked-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
 mm/hmm.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 2ef14b2b5505..c30aa9403dbe 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -925,19 +925,21 @@ void hmm_range_unregister(struct hmm_range *range)
 {
 	struct hmm *hmm = range->hmm;
 
-	/* Sanity check this really should not happen. */
-	if (hmm == NULL || range->end <= range->start)
-		return;
-
 	mutex_lock(&hmm->lock);
 	list_del_init(&range->list);
 	mutex_unlock(&hmm->lock);
 
 	/* Drop reference taken by hmm_range_register() */
-	range->valid = false;
 	mmput(hmm->mm);
 	hmm_put(hmm);
-	range->hmm = NULL;
+
+	/*
+	 * The range is now invalid and the ref on the hmm is dropped, so
+	 * poison the pointer.  Leave other fields in place, for the caller's
+	 * use.
+	 */
+	range->valid = false;
+	memset(&range->hmm, POISON_INUSE, sizeof(range->hmm));
 }
 EXPORT_SYMBOL(hmm_range_unregister);
 
-- 
2.20.1

