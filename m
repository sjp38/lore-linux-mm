Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7DE0C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8188020663
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="AoPkQ1Ya"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8188020663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 983288E0010; Wed, 26 Jun 2019 08:27:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90E9D8E000E; Wed, 26 Jun 2019 08:27:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D6E08E0010; Wed, 26 Jun 2019 08:27:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1978E000E
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:27:53 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a20so1656913pfn.19
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:27:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jJLN4PQyh+NiJMk0GjPmnktfOIwnazdB1WyLd+EwQBI=;
        b=cHRsNTG95wuUbFTesJeRIsbztTLVdL9Zo2p0fkyuDZ7XTWTxggROiigTRo1XE0Ogdq
         4TglNGoRhMSxzgMYN+3jdTOOA8qShsmbarIBBfNvOWgA3b8xxMuK2Td6hq+PTgEib9W9
         HbOVVzMyemwDEbOg0WcJIF9M1+/VnZE7oTYSFBmnyZ44b30UJAm++Po3UwO9zyYnr34n
         fxLUwUFIg10fMO9VvjHrZ8gruwXXOeydUxuuA6C3KmR9fAO8xNyZAKWC69C/i1yQd8Jf
         3tk+E472/Mjdd/6KErZvo9aqSNUdubGc5om+3pVBLxrJb2xF2TyDrBkKzMACoIXMUk31
         DT8A==
X-Gm-Message-State: APjAAAVREEtDKYjo+ncy6hkF7c+sQglrZFto5GiUgCV532pXDXTQpohd
	++J+yXPJ9eeo2iOit+41Xsp+jUEpg7EFC3KOpEZ6xq8E3e3ihLU2ZqEvJ51Dv7WoqPdgXdDCYr9
	40rgWz84NO279YaxZSc/3E3yjfyVHHLqqkzsaVqZocfz9o7KTKbm+X3nW6AfVV9o=
X-Received: by 2002:a17:902:704a:: with SMTP id h10mr5047083plt.337.1561552072883;
        Wed, 26 Jun 2019 05:27:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9cK5hq9DKp512ZBJ7IQqo5aRu4j+vvgLzVOWNmNow9t969gdD1ieXW0dWj6kob0xZvc9v
X-Received: by 2002:a17:902:704a:: with SMTP id h10mr5047029plt.337.1561552072037;
        Wed, 26 Jun 2019 05:27:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552072; cv=none;
        d=google.com; s=arc-20160816;
        b=lQfE/fkVT/Q1WMyX6yrujrwbZWC6ctB3T7E9zGbBlozeN5SXuGL1Bo3JqwpLTmJ+6P
         tRUn8hzGxNXjeVVVWRcXQuzevNT7pgSI+5hV0aLT2K1x1vPsfwnd2C6AQ8tRXnz5esrc
         KqOyLY3Lizywa5U/GxbRNAWLnNMFSY3D3bGmocbKGW/aB70sTylIdKisE6CkcouXaQkT
         vrP3E3JhqRi0+bxfRwhNQxu3mj31nbez+aaDVFpDO8j9uyA8lH5Yd578/Rqps1pZdvn8
         Egi7HXxBLp0sHkBE7jtVTT8j26hIZjuHsvt0iZCx6vMET/4XwDDjdMMJDeiz+j/2NSt6
         bKJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=jJLN4PQyh+NiJMk0GjPmnktfOIwnazdB1WyLd+EwQBI=;
        b=UMP/jdAV2TV1kdHYXKenMMLJB6LzvxMWVgvf5zOXXE63bCO80AU9kZ3VOkWWZWKJB+
         7whIx+I/sKzy9i8O1qZRh4b8FlQTILWbKuo4ElBP4OLU9uNwFaWdgKMuy05nFtlYgz4a
         mErN2hkdg7k4ZKgg1BJ6MkRWHB3Hx+Glt5gTN040AvPzl01fQCFE7E5wB64uj9lGgTsO
         R/JK/QBtLB3XZkpaQCzrl00BsOVmgyg/3texmY3B1dCPh1Sa6+O25EUkeTw7tkDemzXb
         9OzEm0MyI7eZ6EbgoEot1qlMHWe2J6UqgdphPkqisCqP837dTMIMrk0s2X4xWWnGjBUJ
         1R3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=AoPkQ1Ya;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r204si9720826pgr.243.2019.06.26.05.27.51
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:27:52 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=AoPkQ1Ya;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=jJLN4PQyh+NiJMk0GjPmnktfOIwnazdB1WyLd+EwQBI=; b=AoPkQ1Ya+GVeIiAkwNrcOY3WXy
	sAhllTHY9EgHAAks54i/wuled6yq4/SYKn1NbwYo04wuJLkW52WmxaNmHyzJwOIaCd1GOvXiEtOFh
	ThHQsj3EyWPwSyeHernbRDYWFXPuc50UnHzB/Ux1T9z32tWTuakN3Zxrkm+83YlNJ6VlyDhXoVpV0
	swGfUgPd+voS9n+3QCOoIUtQgxulHB6VDtuaVG04iQieR5ANlKAx/Sb/w9GgYjty+E8OOcprpShvj
	UdtX/dRdsOG235kDLoTkXHXo33rFg+7/1zOnF3ap3zxhTo4sRT+LAOqrSL+ve8dTmWYfKoZdPNkJ2
	oG9lwaoA==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg71g-0001O4-Pe; Wed, 26 Jun 2019 12:27:49 +0000
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
Subject: [PATCH 08/25] memremap: validate the pagemap type passed to devm_memremap_pages
Date: Wed, 26 Jun 2019 14:27:07 +0200
Message-Id: <20190626122724.13313-9-hch@lst.de>
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

Most pgmap types are only supported when certain config options are
enabled.  Check for a type that is valid for the current configuration
before setting up the pagemap.  For this the usage of the 0 type for
device dax gets replaced with an explicit MEMORY_DEVICE_DEVDAX type.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/dax/device.c     |  1 +
 include/linux/memremap.h |  8 ++++++++
 kernel/memremap.c        | 22 ++++++++++++++++++++++
 3 files changed, 31 insertions(+)

diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index 8465d12fecba..79014baa782d 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -468,6 +468,7 @@ int dev_dax_probe(struct device *dev)
 	dev_dax->pgmap.ref = &dev_dax->ref;
 	dev_dax->pgmap.kill = dev_dax_percpu_kill;
 	dev_dax->pgmap.cleanup = dev_dax_percpu_exit;
+	dev_dax->pgmap.type = MEMORY_DEVICE_DEVDAX;
 	addr = devm_memremap_pages(dev, &dev_dax->pgmap);
 	if (IS_ERR(addr))
 		return PTR_ERR(addr);
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 995c62c5a48b..0c86f2c5ac9c 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -45,13 +45,21 @@ struct vmem_altmap {
  * wakeup is used to coordinate physical address space management (ex:
  * fs truncate/hole punch) vs pinned pages (ex: device dma).
  *
+ * MEMORY_DEVICE_DEVDAX:
+ * Host memory that has similar access semantics as System RAM i.e. DMA
+ * coherent and supports page pinning. In contrast to
+ * MEMORY_DEVICE_FS_DAX, this memory is access via a device-dax
+ * character device.
+ *
  * MEMORY_DEVICE_PCI_P2PDMA:
  * Device memory residing in a PCI BAR intended for use with Peer-to-Peer
  * transactions.
  */
 enum memory_type {
+	/* 0 is reserved to catch uninitialized type fields */
 	MEMORY_DEVICE_PRIVATE = 1,
 	MEMORY_DEVICE_FS_DAX,
+	MEMORY_DEVICE_DEVDAX,
 	MEMORY_DEVICE_PCI_P2PDMA,
 };
 
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 6e1970719dc2..abda62d1e5a3 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -157,6 +157,28 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	pgprot_t pgprot = PAGE_KERNEL;
 	int error, nid, is_ram;
 
+	switch (pgmap->type) {
+	case MEMORY_DEVICE_PRIVATE:
+		if (!IS_ENABLED(CONFIG_DEVICE_PRIVATE)) {
+			WARN(1, "Device private memory not supported\n");
+			return ERR_PTR(-EINVAL);
+		}
+		break;
+	case MEMORY_DEVICE_FS_DAX:
+		if (!IS_ENABLED(CONFIG_ZONE_DEVICE) ||
+		    IS_ENABLED(CONFIG_FS_DAX_LIMITED)) {
+			WARN(1, "File system DAX not supported\n");
+			return ERR_PTR(-EINVAL);
+		}
+		break;
+	case MEMORY_DEVICE_DEVDAX:
+	case MEMORY_DEVICE_PCI_P2PDMA:
+		break;
+	default:
+		WARN(1, "Invalid pgmap type %d\n", pgmap->type);
+		break;
+	}
+
 	if (!pgmap->ref || !pgmap->kill || !pgmap->cleanup) {
 		WARN(1, "Missing reference count teardown definition\n");
 		return ERR_PTR(-EINVAL);
-- 
2.20.1

