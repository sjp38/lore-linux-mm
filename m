Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4E56C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A94E20818
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="tn2lwfTf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A94E20818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEFD16B000C; Tue,  6 Aug 2019 12:06:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B602F6B000D; Tue,  6 Aug 2019 12:06:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B5A16B000E; Tue,  6 Aug 2019 12:06:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5C83B6B000C
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:06:13 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id p15so11582050pgl.18
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:06:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=HrWzyj8Xwb8+ibZdNfy7jRFBuLt7LJC7W3wGhE3v6+k=;
        b=B2VAID+Y39bJpfJM8hq1GUkfm51/CH/QXzoo37TCE6q+1+Egwvl2NkU9csHQyifh5l
         msyY8MJDb/3dXKVOMNFmotJDryTFF1JPBqWpzOg0nXp/wa9xftjCGSJpGJbvZ6bBfpwB
         TOJ5S+1q7rz6GFwmoy8v12AQTg4dCZyStfJT1S4A7ZzpH25MxbY0aGMh8bhBCv3uW6BA
         lZZtg0iTaLS/94APQuxB4bQyw5ZrX9enz31yUoZl5uuy6zDB+a1O2tKSx/0Ulshdu28y
         g3xK7YQMCURgJZvEWUq4wV6pKJbUButzgnmlBPyKhI3KidyiUpr0Qw3RB/YOcnAYujpE
         cLQw==
X-Gm-Message-State: APjAAAVCZudsyLE3e7F1r2imTTe9qUbqPhxJmeBorAcl+1itJx/AVJww
	pgDzk6tA+plcMqnA+8KvNNNy9+/efM4CgwKdQ0+Ca+fZGYpecL+G2LC8YHlaE5o+FBkTyiD6ivE
	tg7EcIl9JmY7W85wHhg/w0/Kfv2rzNlwPE4/XAAD6UngkI+tE0t4pqMnnzws79Hg=
X-Received: by 2002:a17:90a:8688:: with SMTP id p8mr4023875pjn.57.1565107573019;
        Tue, 06 Aug 2019 09:06:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJEZeLxChStwpG/ROIpuvmTbospirawcwlX12XMK0FWcYORO4fb64zuqtz1c+DEb903Lje
X-Received: by 2002:a17:90a:8688:: with SMTP id p8mr4023797pjn.57.1565107572049;
        Tue, 06 Aug 2019 09:06:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565107572; cv=none;
        d=google.com; s=arc-20160816;
        b=fPDGz1UOssCCrJThfxvqxJgmM0ExIVWk/svuBX4rPg/BYyUfFlCoN9eyL2WdxC4vef
         NR6KVxCG4cB0EmVCtGZWigyVGtM4+xfeZCGUSOotg7Fy2RHVvAGWIwthAm/Fj0XkNLtk
         3HdIDDPegCdLK6j7+Ys47D7ukKmfhAenqdb7LHseoM7Y0hXmWIDqhOhbig7pGCL0vgBm
         yOoXP9w07tyQrRQwbTZIKZi3DY4pYvGxxsuhY4NorbPEF7e5g5IyC9ag2g+OR+pHJ2JX
         EB++zgs77g2ZTb9TF4i8r8qWBzhPAzRfZpzigKAdfHALTYQ7EIOGcQg4vuWq2y1Y2lQB
         u6lw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=HrWzyj8Xwb8+ibZdNfy7jRFBuLt7LJC7W3wGhE3v6+k=;
        b=sEzIJ9Rh6bc5F80/PPTJF174C+culcCHu8o3que+j4PB81P/v/HWWfB1sGtmSX2QwG
         kDbJ9ranCPwty7fO7Epz683tS/3L/spR+OF0jICDV/T0HSEnzNClMHdCv1G+D7s76NFX
         VFufsn8afH7rzV0qb9o2JJ308ujZsVEejtYolMA06jD8htoxaNZAwQDnkQQUbToQ85oh
         Is3JObrxFhnn1FbL6UR51oV6sf77cFYlw5ai1x0HRsZjhLO57g2KyQokPvzjgT3SPY0T
         QHQn1xutVHiITo1sKKfAFPJFfJhGn0IKQIf/h0sMK+KyNAmjvZz7S540ac2RaFii+gg1
         LPig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tn2lwfTf;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 66si44969309pld.6.2019.08.06.09.06.11
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 09:06:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tn2lwfTf;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=HrWzyj8Xwb8+ibZdNfy7jRFBuLt7LJC7W3wGhE3v6+k=; b=tn2lwfTfokh2Oc5zgMto3Ypnv3
	6iPGcbfNQjgmkUu5mqIUEy9RxUmoQoXg0P7FxJsxuV2BqHEUOHG1ZqrGSY77Pd6zjtOG6Kfvy56LL
	m3DeHaj1r7hN8MK2Z91bk1YSOGvBk4kWiIC+TWAZpScFP1nDvvHRZt0EY0fVphGycnOn6kL6BeVrB
	1ZEVzB+PTNmO7XUSZqoPkpb0bHShNHZF8PKoFc0MtKMY3kUn01xaKVO1LGg6/Iiv1krfGhdfpgyoI
	fiwRrtGmUw7YQTJ+jHCBUcPckkdw/G7pPSJPaJuqBBDwA0N34uvyfuMud/oaFaEHpUJsbW+AcXaEM
	neN8+r1A==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hv1yT-0000Xl-31; Tue, 06 Aug 2019 16:06:09 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 05/15] mm: remove the unused vma argument to hmm_range_dma_unmap
Date: Tue,  6 Aug 2019 19:05:43 +0300
Message-Id: <20190806160554.14046-6-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190806160554.14046-1-hch@lst.de>
References: <20190806160554.14046-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
---
 include/linux/hmm.h | 1 -
 mm/hmm.c            | 2 --
 2 files changed, 3 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 82265118d94a..59be0aa2476d 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -422,7 +422,6 @@ long hmm_range_dma_map(struct hmm_range *range,
 		       dma_addr_t *daddrs,
 		       unsigned int flags);
 long hmm_range_dma_unmap(struct hmm_range *range,
-			 struct vm_area_struct *vma,
 			 struct device *device,
 			 dma_addr_t *daddrs,
 			 bool dirty);
diff --git a/mm/hmm.c b/mm/hmm.c
index d66fa29b42e0..3a3852660757 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1121,7 +1121,6 @@ EXPORT_SYMBOL(hmm_range_dma_map);
 /**
  * hmm_range_dma_unmap() - unmap range of that was map with hmm_range_dma_map()
  * @range: range being unmapped
- * @vma: the vma against which the range (optional)
  * @device: device against which dma map was done
  * @daddrs: dma address of mapped pages
  * @dirty: dirty page if it had the write flag set
@@ -1133,7 +1132,6 @@ EXPORT_SYMBOL(hmm_range_dma_map);
  * concurrent mmu notifier or sync_cpu_device_pagetables() to make progress.
  */
 long hmm_range_dma_unmap(struct hmm_range *range,
-			 struct vm_area_struct *vma,
 			 struct device *device,
 			 dma_addr_t *daddrs,
 			 bool dirty)
-- 
2.20.1

