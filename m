Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C829BC48BD8
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 836AF2063F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="eqf0zYAq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 836AF2063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89C648E000E; Wed, 26 Jun 2019 08:28:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D7088E0005; Wed, 26 Jun 2019 08:28:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FFA38E000E; Wed, 26 Jun 2019 08:28:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 251008E0005
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:28:14 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id q14so1682276pff.8
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:28:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YDLkJcbbU4N/zfzWVPo9ZgCQKX5AsR9fCDGQSDpCCD0=;
        b=f2nDLqHdAHQ1QiCTWS0J3GV5c9I0weG3Xfhy0guNkwpdfvCtPuNwNNiGZ9yIKNi9yj
         w5Ij5EfPUhM9Pay0htHVPxi8ZIZBi+mr37NE4RCnrsOaYSU1XV5DpyK0hHrqoZfythdg
         3PbSnlMWhgwDAlLB4hmBUsg4xxgWrlfpGacj9qq3z+LDvHGfsJlNTxyzCF64JpgAOyPK
         EvLnJBR+gyvlEcgeJG677pM2dD9/+OsKqrJ3FtQiEKR90sFt8XS875bXcNTltwmTbrQL
         xQLA3ZhqaQKQXjvCIfRMPIdFk57gJlKqrSMY5ahZUL97xukbBSHq/ZsEwBakJXpmETJL
         jLMA==
X-Gm-Message-State: APjAAAWVnh4hAN1hbmQt67CKP+80CVx0g8hjIX1kH7mERouZvkEz+j4Q
	7goU9/Q8VtO4Mrp10k1i2gp1i0X+5UjSwxL343O6oO9/7MCxWkk08XhTC1hHY4dl3/DCUfkw11o
	ZZrir6IbgK2lF/18dQkNue70pSfmKZI31Xl36DIWHLrrnDOqUQSCrUi8yWYhVeSE=
X-Received: by 2002:a63:d0:: with SMTP id 199mr2739226pga.85.1561552093735;
        Wed, 26 Jun 2019 05:28:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQVdU9Wbq1EbMOCvuaicC7KreR+qQ6VRLnpYDwnbIh36ibFv3MP4c/yODuYAQ+F+QT1H3M
X-Received: by 2002:a63:d0:: with SMTP id 199mr2739161pga.85.1561552092880;
        Wed, 26 Jun 2019 05:28:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552092; cv=none;
        d=google.com; s=arc-20160816;
        b=TV5O/mk6uHIu8ZqJ/mZW5PBF5KEa3kbMTrSGg01tZ2iv+Wa824PkKIxNmO6BJy9hlG
         Bnh/2L8/nm+BL5sBjQN7+JK+1gmqhjumPVB5TjJRNJxXHT+cPmTZsn/2LZVjvijnZHRw
         9FcJ9/rW4WK3RPiChH7+dM216Yayn66WYNhf0RJY6IxiKwgcW7rFe9ndCqoDK6S8U6l0
         Ntxn9wxxlDdAxqHHMpHLMYFFo8pgU5FAciPij0vevRL/t5RRLwFvhRiWJFjzNF3Oyls8
         X2v5ZJrU/4GQk7t3mk10sF2QtRcwcsWwNusTJQBeKabCbOSrF3R0dJzlXnI/RXMWGyEK
         Nb7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=YDLkJcbbU4N/zfzWVPo9ZgCQKX5AsR9fCDGQSDpCCD0=;
        b=m9lGvb5u7DZHPQIn8Ga5gTXnAMNcLtVH7rEySJhWqlwih1B7mHblhtZUOxHhSOk/ez
         NxmudoyyQnZ8cxx6swuIn/wS4Yi2MNMBl1fGEhrNzEJYg9cx0tfJENv7ipV47iQWDkfv
         ZBR28AlDGPwxSF9qzdrAkA7U4XDHRi4+qYJdb4M375X4L9UuqIbtRcVwDR0Dpz61PTD7
         xGFD4YSSv2P17P1vr5EVORzRNZBgj7iEHyxsKIaACb0RvBdHSt/GoWnW9AJfooQ0LhdL
         YJR8bmHCq5iNzO0C/+EHLlGA5mRdCaxbNT1rzzb9+09RCWowNM9Ng/BpC0t4sGL2sE4x
         LmsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=eqf0zYAq;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r34si4278906pgl.141.2019.06.26.05.28.12
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:28:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=eqf0zYAq;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=YDLkJcbbU4N/zfzWVPo9ZgCQKX5AsR9fCDGQSDpCCD0=; b=eqf0zYAqZkZeG8aDStJr1BpZ1P
	ESvtZ/x6goy5uCLOi8uh5odrF/jDvEPUaqDs779fgL8qsCyiCG2Ery24ccFf7Y0roHYb5/v+BzjZd
	xvJYhdsaPbrOrKlFB9NzVbHgKqVz953pfvNGqyyv5cMEWoHLfF9YDaBYwCVVotAmsfAouontNfJIt
	pC/KsdDr1ehz4StOtp3FSfKb+O6soSwumbQYEJcyvsfr9PEr8MVPAAeAHs4HYu/6nrrbmT2tdJj4K
	nauKDKfBWnolN5vCPrT8Befr6TTsUp5glW5APuxKXXVhJiU6XtHj2xrRMVBIAKAAazFHBbPh/Dc4n
	j7M/oClg==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg721-0001X8-Jr; Wed, 26 Jun 2019 12:28:10 +0000
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
Subject: [PATCH 16/25] device-dax: use the dev_pagemap internal refcount
Date: Wed, 26 Jun 2019 14:27:15 +0200
Message-Id: <20190626122724.13313-17-hch@lst.de>
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

The functionality is identical to the one currently open coded in
device-dax.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/dax/dax-private.h |  4 ----
 drivers/dax/device.c      | 43 ---------------------------------------
 2 files changed, 47 deletions(-)

diff --git a/drivers/dax/dax-private.h b/drivers/dax/dax-private.h
index b4177aafbbd1..c915889d1769 100644
--- a/drivers/dax/dax-private.h
+++ b/drivers/dax/dax-private.h
@@ -43,8 +43,6 @@ struct dax_region {
  * @target_node: effective numa node if dev_dax memory range is onlined
  * @dev - device core
  * @pgmap - pgmap for memmap setup / lifetime (driver owned)
- * @ref: pgmap reference count (driver owned)
- * @cmp: @ref final put completion (driver owned)
  */
 struct dev_dax {
 	struct dax_region *region;
@@ -52,8 +50,6 @@ struct dev_dax {
 	int target_node;
 	struct device dev;
 	struct dev_pagemap pgmap;
-	struct percpu_ref ref;
-	struct completion cmp;
 };
 
 static inline struct dev_dax *to_dev_dax(struct device *dev)
diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index b5257038c188..1af823b2fe6b 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -14,36 +14,6 @@
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
-static void dev_dax_percpu_exit(struct dev_pagemap *pgmap)
-{
-	struct dev_dax *dev_dax = container_of(pgmap, struct dev_dax, pgmap);
-
-	dev_dbg(&dev_dax->dev, "%s\n", __func__);
-	wait_for_completion(&dev_dax->cmp);
-	percpu_ref_exit(pgmap->ref);
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
@@ -441,11 +411,6 @@ static void dev_dax_kill(void *dev_dax)
 	kill_dev_dax(dev_dax);
 }
 
-static const struct dev_pagemap_ops dev_dax_pagemap_ops = {
-	.kill		= dev_dax_percpu_kill,
-	.cleanup	= dev_dax_percpu_exit,
-};
-
 int dev_dax_probe(struct device *dev)
 {
 	struct dev_dax *dev_dax = to_dev_dax(dev);
@@ -463,15 +428,7 @@ int dev_dax_probe(struct device *dev)
 		return -EBUSY;
 	}
 
-	init_completion(&dev_dax->cmp);
-	rc = percpu_ref_init(&dev_dax->ref, dev_dax_percpu_release, 0,
-			GFP_KERNEL);
-	if (rc)
-		return rc;
-
-	dev_dax->pgmap.ref = &dev_dax->ref;
 	dev_dax->pgmap.type = MEMORY_DEVICE_DEVDAX;
-	dev_dax->pgmap.ops = &dev_dax_pagemap_ops;
 	addr = devm_memremap_pages(dev, &dev_dax->pgmap);
 	if (IS_ERR(addr))
 		return PTR_ERR(addr);
-- 
2.20.1

