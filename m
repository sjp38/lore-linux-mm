Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAF44C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A428E21473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TEMANqis"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A428E21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 889516B0269; Thu, 13 Jun 2019 05:43:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 812C96B026A; Thu, 13 Jun 2019 05:43:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68DFD6B026B; Thu, 13 Jun 2019 05:43:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0146B0269
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:43:59 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id s22so7617604plp.5
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:43:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1BqK80fO4qP585H34EdwQbL6ViSgwKQddKyugyKso9Y=;
        b=XqEdEH0IYqFQhRwN4PgWSi1yEG0dE9iOOFcVkMt+BfFbEE7ONXuwdlkF3HOVyk0wxY
         M2ILJMvWGRemm561UOS3+CD0LgmUWtH/f6gCetTcncpOWw9UsC6ZLbkUjlkyAoSJURj6
         QQzVBEjuXDN60YVEWiuZWCYIe0SxLDN8nyI6x4YPWq/9MlAXf/vEkQo0vW7JmM4oE5nA
         0mMfQ3MVr5ofEx97GCpGFfzK55MlQgu3/bmSZO1LCysNCEo4EvhFbMyIHMXOtZKN245F
         p/D1YnzA62/GUbuKCCje/6bLl78JlwS12RW23+GpBLh5aDIDZmVmZh5UCH1AKYxaxFhL
         UicQ==
X-Gm-Message-State: APjAAAWKzez1yqG7jLS1Lq+tqu8B57D6CaSBt1TDPaM+11O2Bw3ngoQ5
	RAfyt7tIWyKPAT0JucYhrIihHIuSkqitmmiTw4cRatBv/RBomJIZjMx2EOmPqNhq6px52UK+ps/
	/sw/FerhxK1lu0g8n7mk5YeLyvD3nVJVPH9PV6e64c1GH7c+llmdsn+TPBuw+V68=
X-Received: by 2002:a17:902:148:: with SMTP id 66mr81301463plb.143.1560419038789;
        Thu, 13 Jun 2019 02:43:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxd4RQBQ1CthvU9Le6010MeJ2eYitSnP8ytcZZp2mTwrceAfS6wOZBT1U1ABDblf20RZ6w2
X-Received: by 2002:a17:902:148:: with SMTP id 66mr81301355plb.143.1560419037913;
        Thu, 13 Jun 2019 02:43:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419037; cv=none;
        d=google.com; s=arc-20160816;
        b=Oh/b+zO8Qkvedssg8eb4u+/gAapNmV2w92WY2+AANEQr69akFP7GOG0p0vme0dyvPm
         89W8hhYfbigtaTMxz8ygZMATnAMdJWsNIwwt6WG69N2cCi1EJAsTChZc09G6rUDQkJuA
         ScfGUL/mBjY7Na5KrIMUyTLNhYAhT9V5ZLNz83dL/iCvlN8+SanmwlvN++N2rfELIRpd
         t9ZcBesyNDbQ8d3F27JteKHec41ZDJLTSIAiUBd7WCzTBfIjCKVWjVnXSDg4zRIW49fI
         tSg9aWebv6FTTwblhCcNDVYUghPOnnOKL62Y64hjGbnqzEafuKDDqyxKpjKt0eltqOlh
         1hOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=1BqK80fO4qP585H34EdwQbL6ViSgwKQddKyugyKso9Y=;
        b=GhPATw0zMM4hjUcuuFzrg5RNPlql3YzLRuOvfBMQluNI/9ewM6earOe/0NlnrcgH5l
         c6QgWO7NoMSvcKUQoKlVFRwBHnPPUvPiHYtb005PUGQ1NM7NMqXY+IpXGQpwqxf/zsCA
         T7zlqumhsORYREx64QG/eR+gvS5tFoVVtPodiK027HxCPRLvZiVFfQtrT2MckVsiNHhp
         izm/Qet3arJirWZ/AFW060aIL6fqeuDXm7cG8KXCWVBnBvIZOyfEGrAoiUu3mRPjPa80
         U0r9WmCTrMfw0wQ5cGxrQ54gk34KpInQrz381BODdmKCkLc/O09UpCJmyoqfSfsXgGPX
         pDNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TEMANqis;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 206si2711665pga.414.2019.06.13.02.43.57
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:43:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TEMANqis;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=1BqK80fO4qP585H34EdwQbL6ViSgwKQddKyugyKso9Y=; b=TEMANqisnK+/nbUc3UXMfUjlI6
	Buayg3mmtOYuYeLGF0JU6+u1jMgokjY3LfM+Kk8hDa7h7fnT1VyFEP0nPB1RNUZWOVQuN3ovu93rh
	jsl9IqdSDGLWp38ra6Me2Ka5kg8BmNg4Hm/aJRiVyXtzEZPdEGsc+oaWriNBq2Pgyc+yY6y+JVwz9
	hiWaWe9czGHjymFZztKABfoCjLkCdLjhKUHvyX+YjY5iFnm8H2PyqDyfQKfS4QNRaaBGWJ6kpu+eC
	B8kr6+ivmbMx2Ql/Nf6Ttz9lfxd/+jK9BugmMtX7lveZKR7VOZd55VwgHmrGIg3nIz2pCIVHSQPaS
	k+QbBHsQ==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMGx-0001p4-2R; Thu, 13 Jun 2019 09:43:55 +0000
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
Subject: [PATCH 09/22] memremap: lift the devmap_enable manipulation into devm_memremap_pages
Date: Thu, 13 Jun 2019 11:43:12 +0200
Message-Id: <20190613094326.24093-10-hch@lst.de>
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

Just check if there is a ->page_free operation set and take care of the
static key enable, as well as the put using device managed resources.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/nvdimm/pmem.c | 23 +++--------------
 include/linux/mm.h    | 10 --------
 kernel/memremap.c     | 59 +++++++++++++++++++++++++++----------------
 mm/hmm.c              |  2 --
 4 files changed, 41 insertions(+), 53 deletions(-)

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index b9638c6553a1..66837eed6375 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -334,11 +334,6 @@ static void pmem_release_disk(void *__pmem)
 	put_disk(pmem->disk);
 }
 
-static void pmem_release_pgmap_ops(void *__pgmap)
-{
-	dev_pagemap_put_ops();
-}
-
 static void pmem_fsdax_page_free(struct page *page, void *data)
 {
 	wake_up_var(&page->_refcount);
@@ -353,16 +348,6 @@ static const struct dev_pagemap_ops pmem_legacy_pagemap_ops = {
 	.kill			= pmem_kill,
 };
 
-static int setup_pagemap_fsdax(struct device *dev, struct dev_pagemap *pgmap)
-{
-	dev_pagemap_get_ops();
-	if (devm_add_action_or_reset(dev, pmem_release_pgmap_ops, pgmap))
-		return -ENOMEM;
-	pgmap->type = MEMORY_DEVICE_FS_DAX;
-	pgmap->ops = &fsdax_pagemap_ops;
-	return 0;
-}
-
 static int pmem_attach_disk(struct device *dev,
 		struct nd_namespace_common *ndns)
 {
@@ -421,8 +406,8 @@ static int pmem_attach_disk(struct device *dev,
 	pmem->pfn_flags = PFN_DEV;
 	pmem->pgmap.ref = &q->q_usage_counter;
 	if (is_nd_pfn(dev)) {
-		if (setup_pagemap_fsdax(dev, &pmem->pgmap))
-			return -ENOMEM;
+		pmem->pgmap.type = MEMORY_DEVICE_FS_DAX;
+		pmem->pgmap.ops = &fsdax_pagemap_ops;
 		addr = devm_memremap_pages(dev, &pmem->pgmap);
 		pfn_sb = nd_pfn->pfn_sb;
 		pmem->data_offset = le64_to_cpu(pfn_sb->dataoff);
@@ -434,8 +419,8 @@ static int pmem_attach_disk(struct device *dev,
 	} else if (pmem_should_map_pages(dev)) {
 		memcpy(&pmem->pgmap.res, &nsio->res, sizeof(pmem->pgmap.res));
 		pmem->pgmap.altmap_valid = false;
-		if (setup_pagemap_fsdax(dev, &pmem->pgmap))
-			return -ENOMEM;
+		pmem->pgmap.type = MEMORY_DEVICE_FS_DAX;
+		pmem->pgmap.ops = &fsdax_pagemap_ops;
 		addr = devm_memremap_pages(dev, &pmem->pgmap);
 		pmem->pfn_flags |= PFN_MAP;
 		memcpy(&bb_res, &pmem->pgmap.res, sizeof(bb_res));
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834ac32b7..edcf2b821647 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -921,8 +921,6 @@ static inline bool is_zone_device_page(const struct page *page)
 #endif
 
 #ifdef CONFIG_DEV_PAGEMAP_OPS
-void dev_pagemap_get_ops(void);
-void dev_pagemap_put_ops(void);
 void __put_devmap_managed_page(struct page *page);
 DECLARE_STATIC_KEY_FALSE(devmap_managed_key);
 static inline bool put_devmap_managed_page(struct page *page)
@@ -969,14 +967,6 @@ static inline bool is_pci_p2pdma_page(const struct page *page)
 #endif /* CONFIG_PCI_P2PDMA */
 
 #else /* CONFIG_DEV_PAGEMAP_OPS */
-static inline void dev_pagemap_get_ops(void)
-{
-}
-
-static inline void dev_pagemap_put_ops(void)
-{
-}
-
 static inline bool put_devmap_managed_page(struct page *page)
 {
 	return false;
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 94b830b6eca5..6a3183cac764 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -17,6 +17,37 @@ static DEFINE_XARRAY(pgmap_array);
 #define SECTION_MASK ~((1UL << PA_SECTION_SHIFT) - 1)
 #define SECTION_SIZE (1UL << PA_SECTION_SHIFT)
 
+#ifdef CONFIG_DEV_PAGEMAP_OPS
+DEFINE_STATIC_KEY_FALSE(devmap_managed_key);
+EXPORT_SYMBOL(devmap_managed_key);
+static atomic_t devmap_enable;
+
+static void dev_pagemap_put_ops(void *data)
+{
+	if (atomic_dec_and_test(&devmap_enable))
+		static_branch_disable(&devmap_managed_key);
+}
+
+/*
+ * Toggle the static key for ->page_free() callbacks when dev_pagemap
+ * pages go idle.
+ */
+static int dev_pagemap_enable(struct device *dev)
+{
+	if (atomic_inc_return(&devmap_enable) == 1)
+		static_branch_enable(&devmap_managed_key);
+
+	if (devm_add_action_or_reset(dev, dev_pagemap_put_ops, NULL))
+		return -ENOMEM;
+	return 0;
+}
+#else
+static inline int dev_pagemap_enable(struct device *dev)
+{
+	return 0;
+}
+#endif /* CONFIG_DEV_PAGEMAP_OPS */
+
 #if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
 vm_fault_t device_private_entry_fault(struct vm_area_struct *vma,
 		       unsigned long addr,
@@ -159,6 +190,12 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	if (!pgmap->ref || !pgmap->ops || !pgmap->ops->kill)
 		return ERR_PTR(-EINVAL);
 
+	if (pgmap->ops->page_free) {
+		error = dev_pagemap_enable(dev);
+		if (error)
+			return ERR_PTR(error);
+	}
+
 	align_start = res->start & ~(SECTION_SIZE - 1);
 	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
 		- align_start;
@@ -316,28 +353,6 @@ struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 EXPORT_SYMBOL_GPL(get_dev_pagemap);
 
 #ifdef CONFIG_DEV_PAGEMAP_OPS
-DEFINE_STATIC_KEY_FALSE(devmap_managed_key);
-EXPORT_SYMBOL(devmap_managed_key);
-static atomic_t devmap_enable;
-
-/*
- * Toggle the static key for ->page_free() callbacks when dev_pagemap
- * pages go idle.
- */
-void dev_pagemap_get_ops(void)
-{
-	if (atomic_inc_return(&devmap_enable) == 1)
-		static_branch_enable(&devmap_managed_key);
-}
-EXPORT_SYMBOL_GPL(dev_pagemap_get_ops);
-
-void dev_pagemap_put_ops(void)
-{
-	if (atomic_dec_and_test(&devmap_enable))
-		static_branch_disable(&devmap_managed_key);
-}
-EXPORT_SYMBOL_GPL(dev_pagemap_put_ops);
-
 void __put_devmap_managed_page(struct page *page)
 {
 	int count = page_ref_dec_return(page);
diff --git a/mm/hmm.c b/mm/hmm.c
index c76a1b5defda..6dc769feb2e1 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1378,8 +1378,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 	void *result;
 	int ret;
 
-	dev_pagemap_get_ops();
-
 	devmem = devm_kzalloc(device, sizeof(*devmem), GFP_KERNEL);
 	if (!devmem)
 		return ERR_PTR(-ENOMEM);
-- 
2.20.1

