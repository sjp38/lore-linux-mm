Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAA8AC31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5A2920657
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="cfjnQSuk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5A2920657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E17A8E0012; Mon, 17 Jun 2019 08:28:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86A778E000B; Mon, 17 Jun 2019 08:28:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7583F8E0012; Mon, 17 Jun 2019 08:28:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3DF2A8E000B
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:28:14 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x9so6951129pfm.16
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:28:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WoytrCxG5kt017Mi4r+qftdCcpzSPco9CT8jAnxV7AA=;
        b=KKO/pjSav8HJWv8JfaRuPM4EsyB6gQj9VH6me8vGxUXeFlUECtl+kb/eBTth6N7GVV
         o1vQy6eqZTB/coFKP2JiJioBTZzpdIci5lzOkR49Ukud+dQDW6xkwHdwblXsmKiBkfVq
         WNlmSSjl+Nd5VH/iG+JCz68itFzo5GSyVosJrdJHTYWibCUT35hC5xdtXQV2k5jdfSUK
         r1VYsaNBGG7rQipN0/c2ShUyXgnhrZkkupG3U3T6UpaY6eTDK6EkZjoHHFdpAs63gop3
         QLqInXzHSHn7aB2iOnKSql8SDDbc0SONUNpSAv6nW68BzCBA8MGsSFgGhlzZc+j1dUFZ
         /skg==
X-Gm-Message-State: APjAAAWVWbJzTqGjxnNkoSqWX0+O5+H4rJ4uQ9pjHbBLXtP5KCPPrjnV
	2kh/8Rw747s/O/16o0JvUNVp4nfV0HQi+KpZhjpVN926R2cS+8ugdCMT2oo8iiK+2gXIuJLkZRE
	pSPqtepEe5ueeFgiXsUDGcDmd5TypcdqX7Er6y1UuHjHab6ArUWb8PjmoYFdMGY0=
X-Received: by 2002:a17:90a:9905:: with SMTP id b5mr3185141pjp.70.1560774493906;
        Mon, 17 Jun 2019 05:28:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiDG+EBFcP59oC/dXbSIcveXAcv5VNxY4iUfg8uplE4Kf3Vk+wPuso4gTJzSvhI7eHtPfe
X-Received: by 2002:a17:90a:9905:: with SMTP id b5mr3185111pjp.70.1560774493264;
        Mon, 17 Jun 2019 05:28:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774493; cv=none;
        d=google.com; s=arc-20160816;
        b=ZZSFH3gJ74m9dvIrxyVxsgEadVUhQsqaQgNqHeaWHbsedfufZ0gYw6GL0xeXY7ZDZq
         VHkd/VtkdnyvWfhg4QfQZyG8bszRcS+MlALlb2/UIWb4aleTu1rvz/3Ko9Ar8YOe2Vec
         3oHKHkab6vj73AtIMPT7Sc1Iphk07y7iN42/yFtBUm2KpMXNKz5FVBWCxGbtBhc7A3u7
         tz+bGOJzAFXUyE7tpOWWrN74AiGpwTrdCkcmAcGyhBlmA/kh5uNqpFf88M/RtdMDtsMV
         j7NHLkccbPlYNvNJEyt7iess/OolFrYGVE+a8ysguTGX95cl+SSgsHYq7tHdKsN3scqn
         fdfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=WoytrCxG5kt017Mi4r+qftdCcpzSPco9CT8jAnxV7AA=;
        b=meeIsSeeRuHFb76jzGt1LdgkTZqsMBCTcMfFgGeMTtZcrZNzMlJ1sDqZ2ZNVuEXu1U
         i+aIfV7iQXC37iC0jX/pQHMuBkzpVFPe6aTYOiZz7H/ou+MjyuPkAQI6i4vIzQoDMdMF
         R5bS/PopErz0JCX6eovJldxc2zwhq6EEdMLWdw5gaSH7cYiSQF75MUHmPBg+ZOcMTAAO
         KJiRkcNabUyL7IRa/S+V+GU0jGwPI4o//pqERmGzIUatX4zHojKEPRQdlYWYoRaJx40G
         yR1JTVAszzn7SfSThMp7hRc4TpSTFQtuPGD/Pi3+/oGbpyj/8tqbutvdTu7uQmkVhRVv
         i7IQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cfjnQSuk;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y7si10419609pfm.262.2019.06.17.05.28.13
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:28:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cfjnQSuk;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=WoytrCxG5kt017Mi4r+qftdCcpzSPco9CT8jAnxV7AA=; b=cfjnQSuk0OePqkBqt1Zoo6BJSv
	YWzVaKyyvXJvGwKvelhIJkGt4h1MS45yu0wtaVOrOQWYQW9eQdRpwlluWo02xjodmYnwZgSZZt8+1
	jzywQKVxgLg1An5u3r79qC0eTU+LiFdbrO0B+smIqOb9mh1Yv64a7TiGQAYJn6+yuTiEu6beGOzX4
	PblogVq3IxXTL4MGO1JlQa7eryDUGRdrwy+ePIEKe0/njOwiXsi5TDAP2I6bETcHeOvI5IfFmsXAV
	It0kb/wuRPja6yBoYSJjboYG1k7cI0Koq9jvoZvICMYV+7UkSgs7yAO310r+FQswO/ZeVYTphiBrn
	eZrWu20w==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqk6-0000Fs-Fr; Mon, 17 Jun 2019 12:28:10 +0000
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
Subject: [PATCH 15/25] device-dax: use the dev_pagemap internal refcount
Date: Mon, 17 Jun 2019 14:27:23 +0200
Message-Id: <20190617122733.22432-16-hch@lst.de>
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

The functionality is identical to the one currently open coded in
device-dax.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/dax/dax-private.h |  4 ----
 drivers/dax/device.c      | 43 ---------------------------------------
 2 files changed, 47 deletions(-)

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
index 17b46c1a76b4..a9d7c90ecf1e 100644
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
@@ -463,14 +428,6 @@ int dev_dax_probe(struct device *dev)
 		return -EBUSY;
 	}
 
-	init_completion(&dev_dax->cmp);
-	rc = percpu_ref_init(&dev_dax->ref, dev_dax_percpu_release, 0,
-			GFP_KERNEL);
-	if (rc)
-		return rc;
-
-	dev_dax->pgmap.ref = &dev_dax->ref;
-	dev_dax->pgmap.ops = &dev_dax_pagemap_ops;
 	addr = devm_memremap_pages(dev, &dev_dax->pgmap);
 	if (IS_ERR(addr))
 		return PTR_ERR(addr);
-- 
2.20.1

