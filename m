Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B495C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 06:54:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFF192133F
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 06:54:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="q/BjrqiW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFF192133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54D0E6B0005; Fri, 16 Aug 2019 02:54:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D4BA6B0006; Fri, 16 Aug 2019 02:54:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39B7A6B0007; Fri, 16 Aug 2019 02:54:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0226.hostedemail.com [216.40.44.226])
	by kanga.kvack.org (Postfix) with ESMTP id 1157E6B0005
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 02:54:48 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id B327555F96
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 06:54:47 +0000 (UTC)
X-FDA: 75827378214.21.teeth74_46dc9de5b8837
X-HE-Tag: teeth74_46dc9de5b8837
X-Filterd-Recvd-Size: 5592
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 06:54:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=b+a4pr26YNInd7/QhhzGzYpG1NEGvVch+LojSapMZZc=; b=q/BjrqiWxleujKZgKtvVwFD29i
	R1mYmGsd81RuGdIsBX2zKNbj6gTbsMekpGNZO1BfZY1yUTlE4y+R82pgKreWjAdZ3TPCN0qBPGpoz
	Tfmt3anDfnQQARogPDVC7yBNqwsk2KI2E6ryzuthV8Uriij1gwSy78oFMuRXMYNlF7GsE+Q5ukray
	IHZ7+1jsYG5AzIQHb2CC9qNjXfK14t4IHXUtVAF4KQueFuZChZjNoT86j3hyi5fntsJ9Nzoa7Xitb
	UNjeECi/IsqsIsdD7R4uqxzS5cwwXK50ol0ncpX7KdBddMgGniAH6y1yxQlNfkx7YU0T+dCfMDrMc
	qZKHsfBg==;
Received: from [2001:4bb8:18c:28b5:44f9:d544:957f:32cb] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hyW8I-0008HF-Su; Fri, 16 Aug 2019 06:54:43 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Cc: Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org
Subject: [PATCH 1/4] resource: add a not device managed request_free_mem_region variant
Date: Fri, 16 Aug 2019 08:54:31 +0200
Message-Id: <20190816065434.2129-2-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190816065434.2129-1-hch@lst.de>
References: <20190816065434.2129-1-hch@lst.de>
MIME-Version: 1.0
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Just add a simple macro that passes a NULL dev argument to
dev_request_free_mem_region, and call request_mem_region in the
function for that particular case.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/ioport.h |  2 ++
 kernel/resource.c      | 45 +++++++++++++++++++++++++++++-------------
 2 files changed, 33 insertions(+), 14 deletions(-)

diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index 5b6a7121c9f0..7bddddfc76d6 100644
--- a/include/linux/ioport.h
+++ b/include/linux/ioport.h
@@ -297,6 +297,8 @@ static inline bool resource_overlaps(struct resource =
*r1, struct resource *r2)
=20
 struct resource *devm_request_free_mem_region(struct device *dev,
 		struct resource *base, unsigned long size);
+struct resource *request_free_mem_region(struct resource *base,
+		unsigned long size, const char *name);
=20
 #endif /* __ASSEMBLY__ */
 #endif	/* _LINUX_IOPORT_H */
diff --git a/kernel/resource.c b/kernel/resource.c
index 7ea4306503c5..74877e9d90ca 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -1644,19 +1644,8 @@ void resource_list_free(struct list_head *head)
 EXPORT_SYMBOL(resource_list_free);
=20
 #ifdef CONFIG_DEVICE_PRIVATE
-/**
- * devm_request_free_mem_region - find free region for device private me=
mory
- *
- * @dev: device struct to bind the resource to
- * @size: size in bytes of the device memory to add
- * @base: resource tree to look in
- *
- * This function tries to find an empty range of physical address big en=
ough to
- * contain the new resource, so that it can later be hotplugged as ZONE_=
DEVICE
- * memory, which in turn allocates struct pages.
- */
-struct resource *devm_request_free_mem_region(struct device *dev,
-		struct resource *base, unsigned long size)
+static struct resource *__request_free_mem_region(struct device *dev,
+		struct resource *base, unsigned long size, const char *name)
 {
 	resource_size_t end, addr;
 	struct resource *res;
@@ -1670,7 +1659,10 @@ struct resource *devm_request_free_mem_region(stru=
ct device *dev,
 				REGION_DISJOINT)
 			continue;
=20
-		res =3D devm_request_mem_region(dev, addr, size, dev_name(dev));
+		if (dev)
+			res =3D devm_request_mem_region(dev, addr, size, name);
+		else
+			res =3D request_mem_region(addr, size, name);
 		if (!res)
 			return ERR_PTR(-ENOMEM);
 		res->desc =3D IORES_DESC_DEVICE_PRIVATE_MEMORY;
@@ -1679,7 +1671,32 @@ struct resource *devm_request_free_mem_region(stru=
ct device *dev,
=20
 	return ERR_PTR(-ERANGE);
 }
+
+/**
+ * devm_request_free_mem_region - find free region for device private me=
mory
+ *
+ * @dev: device struct to bind the resource to
+ * @size: size in bytes of the device memory to add
+ * @base: resource tree to look in
+ *
+ * This function tries to find an empty range of physical address big en=
ough to
+ * contain the new resource, so that it can later be hotplugged as ZONE_=
DEVICE
+ * memory, which in turn allocates struct pages.
+ */
+struct resource *devm_request_free_mem_region(struct device *dev,
+		struct resource *base, unsigned long size)
+{
+	return __request_free_mem_region(dev, base, size, dev_name(dev));
+}
 EXPORT_SYMBOL_GPL(devm_request_free_mem_region);
+
+struct resource *request_free_mem_region(struct resource *base,
+		unsigned long size, const char *name)
+{
+	return __request_free_mem_region(NULL, base, size, name);
+}
+EXPORT_SYMBOL_GPL(request_free_mem_region);
+
 #endif /* CONFIG_DEVICE_PRIVATE */
=20
 static int __init strict_iomem(char *str)
--=20
2.20.1


