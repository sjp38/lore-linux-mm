Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8754FC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40FDE21473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="avKv6xwb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40FDE21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBE096B026C; Thu, 13 Jun 2019 05:44:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B48456B026D; Thu, 13 Jun 2019 05:44:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C15A6B026E; Thu, 13 Jun 2019 05:44:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5EA0F6B026C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:44:10 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x9so14099547pfm.16
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:44:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wPaWdCIL9H03r8HySQVqow//0jNnHtt/N2MgQJISZ8s=;
        b=hUY7l1Ez0GPLYc1FJ4M3QLOLDvGueReGdPDq9qbZu20m+olwHTTEtz5E+y0ylm+/nd
         m0uEueFbOFMFppXdGke2LNYyI9uD8rb6oar6AqeZtl2CAfqrRCutsjH7lah20paYrFed
         gtyvkktggkqu8ULbeVcl5fvJDwZ5a58VW+chZK1yPHGYhgIXIwaDrgCgXwAw3bETR1Q2
         9iUip8bVnBVJVsFktoF6LOh6kfNZbStMu5UTBVoyWWr/EU5BsVsD1aD69BPHgQF9fr0O
         Zoab0e4u4yTBsFdwLi7zB35p+m2KOf2e1Bmt94HkernlaXXlzSONjI4BvT7fIDhk22m+
         +tHg==
X-Gm-Message-State: APjAAAXxImFk2XNG8sM2mavCqTHdQ8EwlCiarM/r2NhCiY2u4ZsgKqbp
	20frSz6BmmjZ7QpkXwYN+u0RAWO2iqDIjFT6DhOAK0YGW3Sz1nNhnCtVaxPTF/PMp6q9bhbY1+F
	3sy4esbm22WluVhTJTaFeluRD4KYkA8qUVgNOdCJnVSRIFFD4mmvC49j9IukJkHc=
X-Received: by 2002:a17:902:2bc5:: with SMTP id l63mr86762936plb.221.1560419050048;
        Thu, 13 Jun 2019 02:44:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFvD6rufV2CfIrA1IRttKsjbRzMac3GjVSH2voefy+brMu6tTlBhl+Dm/RhBWgOkMhZqQF
X-Received: by 2002:a17:902:2bc5:: with SMTP id l63mr86762843plb.221.1560419049243;
        Thu, 13 Jun 2019 02:44:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419049; cv=none;
        d=google.com; s=arc-20160816;
        b=jK57diFBAZO+zKqbHDAGrxENXMs/p0y4XSSZdQ/rORVicLlE/+5OnvmFckSFclNl+s
         QovPCnDiMLZnifT9RmxKrvcoHw/9YZGeiinZ8dhWOhwsmuZ2b3iNgWbnicfLNBmIl2df
         IXAdBUpS9+FeKxu1ioKiET2w1QSI9TjDxa3Da2yB5Hu657RF8MfCkIPrtXdvqYHK/RPw
         2M146RaKjdfMarPDNBgecTILM38csKHcY2OwBe/42GnBFzcaWY1zP1+Q4phdqoFBv3yC
         4q6jlR+mbZO6sPlgYR24O79r0F1aghf0NH0Dlvf0XhAljQ+JnqGsSLG5Kk3RG3P883TI
         ZLBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=wPaWdCIL9H03r8HySQVqow//0jNnHtt/N2MgQJISZ8s=;
        b=lbh6RhG5xxDql/qkmBApWW6BpAKNWZIok5//rOmomN1nAbshQcrNUzk68Y53cF2kuW
         bPsjoTFLWO4JEvxfScWkzAi+46ZOI1EdVhgyua5MxbV6RRQL+F05WS3YqxfGBq5dFR16
         2KooHPOXVirqAtTEkIC83aYydN5P50MlVQ9mWzD03A/CGp3nzPjLKuabXBFI0Hp9fhwk
         lnCxrcIPKiO3yHMTjaydpCoJzgNNrDkXziJTWYko2NAxtgEizRqSq+B6miv6ED6A5LR7
         mDVFSWu+oEc5Y5TeLtYavKW8BVtOl/s78eAE0+M9x8pB4jBBRdLxG1bhGSTVbkKaod0n
         lqJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=avKv6xwb;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n11si2948640pgi.27.2019.06.13.02.44.09
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:44:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=avKv6xwb;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=wPaWdCIL9H03r8HySQVqow//0jNnHtt/N2MgQJISZ8s=; b=avKv6xwbjUwP5JnIfmut07FD4E
	gJPJZ8ZQmWlKJYjAzKHwT0cqU9A36XKIAMssk8gQpq3IhjxldclzNcvSF1zNcI9FEe5J4DrlwynxU
	BOkf4ZqVPr5yBB+WsSzI5BaGpY9hBxi7Qh2og5bCGOdVDDRSHg1MVKNLMpKkG5YCrQBvTdqcEqdjK
	BIBwnNK0AKvH4MNtye6T+KQS+ymNK5QfOcLa6VAmU5b2i3i5m5oX14CGYl5bXnH+Ld0nP0t5HEDau
	tkrt/zZv4j5UrYFMV46EwV5BMV6zPYhoYxnhEc4quUvclTo0SfZwBQ7d4I6wYboawBdk9qACJlW6E
	gRpSlcmw==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMH8-0001rw-At; Thu, 13 Jun 2019 09:44:06 +0000
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
	linux-kernel@vger.kernel.org
Subject: [PATCH 13/22] device-dax: use the dev_pagemap internal refcount
Date: Thu, 13 Jun 2019 11:43:16 +0200
Message-Id: <20190613094326.24093-14-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190613094326.24093-1-hch@lst.de>
References: <20190613094326.24093-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The functionality is identical to the one currently open coded in
device-dax.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/dax/dax-private.h |  4 ---
 drivers/dax/device.c      | 52 +--------------------------------------
 2 files changed, 1 insertion(+), 55 deletions(-)

diff --git a/drivers/dax/dax-private.h b/drivers/dax/dax-private.h
index a45612148ca0..ed04a18a35be 100644
--- a/drivers/dax/dax-private.h
+++ b/drivers/dax/dax-private.h
@@ -51,8 +51,6 @@ struct dax_region {
  * @target_node: effective numa node if dev_dax memory range is onlined
  * @dev - device core
  * @pgmap - pgmap for memmap setup / lifetime (driver owned)
- * @ref: pgmap reference count (driver owned)
- * @cmp: @ref final put completion (driver owned)
  */
 struct dev_dax {
 	struct dax_region *region;
@@ -60,8 +58,6 @@ struct dev_dax {
 	int target_node;
 	struct device dev;
 	struct dev_pagemap pgmap;
-	struct percpu_ref ref;
-	struct completion cmp;
 };
 
 static inline struct dev_dax *to_dev_dax(struct device *dev)
diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index e23fa1bd8c97..a9d7c90ecf1e 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -14,37 +14,6 @@
 #include "dax-private.h"
 #include "bus.h"
 
-static struct dev_dax *ref_to_dev_dax(struct percpu_ref *ref)
-{
-	return container_of(ref, struct dev_dax, ref);
-}
-
-static void dev_dax_percpu_release(struct percpu_ref *ref)
-{
-	struct dev_dax *dev_dax = ref_to_dev_dax(ref);
-
-	dev_dbg(&dev_dax->dev, "%s\n", __func__);
-	complete(&dev_dax->cmp);
-}
-
-static void dev_dax_percpu_exit(void *data)
-{
-	struct percpu_ref *ref = data;
-	struct dev_dax *dev_dax = ref_to_dev_dax(ref);
-
-	dev_dbg(&dev_dax->dev, "%s\n", __func__);
-	wait_for_completion(&dev_dax->cmp);
-	percpu_ref_exit(ref);
-}
-
-static void dev_dax_percpu_kill(struct dev_pagemap *pgmap)
-{
-	struct dev_dax *dev_dax = container_of(pgmap, struct dev_dax, pgmap);
-
-	dev_dbg(&dev_dax->dev, "%s\n", __func__);
-	percpu_ref_kill(pgmap->ref);
-}
-
 static int check_vma(struct dev_dax *dev_dax, struct vm_area_struct *vma,
 		const char *func)
 {
@@ -442,10 +411,6 @@ static void dev_dax_kill(void *dev_dax)
 	kill_dev_dax(dev_dax);
 }
 
-static const struct dev_pagemap_ops dev_dax_pagemap_ops = {
-	.kill		= dev_dax_percpu_kill,
-};
-
 int dev_dax_probe(struct device *dev)
 {
 	struct dev_dax *dev_dax = to_dev_dax(dev);
@@ -463,24 +428,9 @@ int dev_dax_probe(struct device *dev)
 		return -EBUSY;
 	}
 
-	init_completion(&dev_dax->cmp);
-	rc = percpu_ref_init(&dev_dax->ref, dev_dax_percpu_release, 0,
-			GFP_KERNEL);
-	if (rc)
-		return rc;
-
-	rc = devm_add_action_or_reset(dev, dev_dax_percpu_exit, &dev_dax->ref);
-	if (rc)
-		return rc;
-
-	dev_dax->pgmap.ref = &dev_dax->ref;
-	dev_dax->pgmap.ops = &dev_dax_pagemap_ops;
 	addr = devm_memremap_pages(dev, &dev_dax->pgmap);
-	if (IS_ERR(addr)) {
-		devm_remove_action(dev, dev_dax_percpu_exit, &dev_dax->ref);
-		percpu_ref_exit(&dev_dax->ref);
+	if (IS_ERR(addr))
 		return PTR_ERR(addr);
-	}
 
 	inode = dax_inode(dax_dev);
 	cdev = inode->i_cdev;
-- 
2.20.1

