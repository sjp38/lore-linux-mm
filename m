Return-Path: <SRS0=C2dt=WH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75FC5C0650F
	for <linux-mm@archiver.kernel.org>; Sun, 11 Aug 2019 08:13:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E899208C2
	for <linux-mm@archiver.kernel.org>; Sun, 11 Aug 2019 08:13:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="OT/H51hc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E899208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2AEAD6B0266; Sun, 11 Aug 2019 04:13:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 238FC6B026A; Sun, 11 Aug 2019 04:13:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 128016B026B; Sun, 11 Aug 2019 04:13:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D12876B0266
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 04:13:06 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h3so62637168pgc.19
        for <linux-mm@kvack.org>; Sun, 11 Aug 2019 01:13:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TXKQMsTJr5Yb/xGnPDJso0zoFmR2NNu+af3KSZelyms=;
        b=r6cpYUkZsAOIXBMCe39BE1pCAKEqZhoObhDZ8sHQk9GXY3DKLL3UcYbHxzW40nWOOm
         /tT9fw92cqYO06KW7uueiuGIfb5RvMObEG1NKkiOeEt9/fKk8/6a4HcylcInLdN772mu
         jKLGhN2Ko8Btb4KVeTnNdbTRPTcHBDANTHTd/X4ocNI5tyLU1rxQ/uKVn7hGCkrFyZKp
         PBASiwdPRZ2r2s+kdrIyUbdVOrnaHtgjUpEtjGZO6lKD2AVuKl9y2K2ydmrVQR41izYX
         eAHTD3dRf+XBER/WX7VAqrd55U07//rNa0TaGF+xneI1Q4AKatCi6sS/Uznv1sh6rpQh
         aGKQ==
X-Gm-Message-State: APjAAAWe40Accx82yOz3XNguQiCXjPNdL956P3DbyrOzEylnOXJzFWg4
	hbNY9AzIvBh516TIcC2Gw1mpR1zF8oGmwjY7OKCEzpllrGVhKxg/7kPFrURG42dC5ocLOP/68Sf
	hHIv6ie2Skx+TUIIMezF8aROIpZnGHC98CuoZ5cl1+cJO9kEJqVRD2jIzbtqh364=
X-Received: by 2002:a17:902:bc49:: with SMTP id t9mr5693026plz.277.1565511186537;
        Sun, 11 Aug 2019 01:13:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzM0yooOIkt/1hhqeAm1ah9io7tlhPD73XG4cthpate1Uvc0ZDu4SfKG8nt9r7sn0ts/PMC
X-Received: by 2002:a17:902:bc49:: with SMTP id t9mr5692986plz.277.1565511185755;
        Sun, 11 Aug 2019 01:13:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565511185; cv=none;
        d=google.com; s=arc-20160816;
        b=G9MkJQv/ZJu/ksOW+QBKWwdwduA5Y5F5mq4S17FyBX4HNzbjpv+ThsAHMH9WpJLpVN
         y44PLrdFFswDA67som0mjo8ch8iD+gyXfMADmUiQbvGZMt/At2vChzU+xZBoPFwcFENT
         bOzYYrE2hB0HTw/HLwBLAwCaoBTLHWC3rwt3rDCX+vebm4tUQ/fGkCvQdXBgXFnas0+a
         eYBtBae8M5Z/7Xpf2ikLiVzLkG7JbAW5ZUhGEmxWqqn6BGzYSosi+r3YMwxOn+YSXuvZ
         5qIJymhaC+oxlNCcV6XbvpkgHXAOjO0NlWPCwBj0dmh0wKebnOLHi30gFKd9qsxFaOcn
         I2lQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=TXKQMsTJr5Yb/xGnPDJso0zoFmR2NNu+af3KSZelyms=;
        b=nwfvHuX3JrDtrWOiH8CUBAhhsVJPUO5TJalVmTMXPCC52sN/FdaD9QEPyuqQA28bHs
         L0qKzBOzLnLTGEDQPjW+tZefVS3HcKB2rgaDOXkbIXJfnYVG7E1li9NXpGTjYqOLXjmf
         R18ttJi2IIrVF0nDnJ//grfaIa/7YC09zSut4NoH9jMuCSuUz5nGcxvQjvPlyXKWyin6
         +qh82rHZFsuSF6dQ4c1N0AFlX4qWKs8Mn19GVYRixdiU4o3wR/iQzOMB5SQe82A+r9Z4
         7FcJBZ/yiuEcZGuvwAtj4yFSzIgvpJ90Jae9E2tXmkNYeE7NZ1oAyM6Y9UARR4VZmEXt
         ZBAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="OT/H51hc";
       spf=pass (google.com: best guess record for domain of batv+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b30si9037287pla.368.2019.08.11.01.13.05
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 11 Aug 2019 01:13:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="OT/H51hc";
       spf=pass (google.com: best guess record for domain of batv+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=TXKQMsTJr5Yb/xGnPDJso0zoFmR2NNu+af3KSZelyms=; b=OT/H51hco7qujYUkADA2Kr5mhh
	La/9S6mZhRfd30JMlgS+OPlMD0V2O/v5SVj0WHyUTF4kFCvqyJm5ajai5E9VzuYMltQUul3d5rtvf
	3qSIsd3OuTQ8PTPSX3iYv+ugzF+FH2Z0pB/CQq/1QRCoZDIaMnPC/pH+UIWfGNnKhXzBbfaQISjhb
	p5G3MqgF2M4oI6MGB12BdIos2aTnkgu+bCbLGvE7cgHwESqNYGO//IY/kxd5BUeeyZY0sYtpj6JW7
	J+bQBlcIdbSN/10waUCh3YT/wwfSWgLkNijIhRuLr0GATRJolYh7AflkfVIwakA+J/5nRY6FT52KY
	j4CHcP2Q==;
Received: from [2001:4bb8:180:1ec3:c70:4a89:bc61:2] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hwiyN-0005EN-Np; Sun, 11 Aug 2019 08:13:04 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Cc: Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org
Subject: [PATCH 5/5] memremap: provide a not device managed memremap_pages
Date: Sun, 11 Aug 2019 10:12:47 +0200
Message-Id: <20190811081247.22111-6-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190811081247.22111-1-hch@lst.de>
References: <20190811081247.22111-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The kvmppc ultravisor code wants a device private memory pool that is
system wide and not attached to a device.  Instead of faking up one
provide a low-level memremap_pages for it.  Note that this function is
not exported, and doesn't have a cleanup routine associated with it to
discourage use from more driver like users.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/memremap.h |  1 +
 mm/memremap.c            | 74 ++++++++++++++++++++++++----------------
 2 files changed, 45 insertions(+), 30 deletions(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 8f0013e18e14..eac23e88a94a 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -123,6 +123,7 @@ static inline struct vmem_altmap *pgmap_altmap(struct dev_pagemap *pgmap)
 }
 
 #ifdef CONFIG_ZONE_DEVICE
+void *memremap_pages(struct dev_pagemap *pgmap, int nid);
 void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap);
 void devm_memunmap_pages(struct device *dev, struct dev_pagemap *pgmap);
 struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
diff --git a/mm/memremap.c b/mm/memremap.c
index 09a087ca30ff..7b7575330db4 100644
--- a/mm/memremap.c
+++ b/mm/memremap.c
@@ -137,27 +137,12 @@ static void dev_pagemap_percpu_release(struct percpu_ref *ref)
 	complete(&pgmap->done);
 }
 
-/**
- * devm_memremap_pages - remap and provide memmap backing for the given resource
- * @dev: hosting device for @res
- * @pgmap: pointer to a struct dev_pagemap
- *
- * Notes:
- * 1/ At a minimum the res and type members of @pgmap must be initialized
- *    by the caller before passing it to this function
- *
- * 2/ The altmap field may optionally be initialized, in which case
- *    PGMAP_ALTMAP_VALID must be set in pgmap->flags.
- *
- * 3/ The ref field may optionally be provided, in which pgmap->ref must be
- *    'live' on entry and will be killed and reaped at
- *    devm_memremap_pages_release() time, or if this routine fails.
- *
- * 4/ res is expected to be a host memory range that could feasibly be
- *    treated as a "System RAM" range, i.e. not a device mmio range, but
- *    this is not enforced.
+/*
+ * This version is not intended for system resources only, and there is no
+ * way to clean up the resource acquisitions.  If you need to clean up you
+ * probably want dev_memremap_pages below.
  */
-void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
+void *memremap_pages(struct dev_pagemap *pgmap, int nid)
 {
 	struct resource *res = &pgmap->res;
 	struct dev_pagemap *conflict_pgmap;
@@ -168,7 +153,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 		.altmap = pgmap_altmap(pgmap),
 	};
 	pgprot_t pgprot = PAGE_KERNEL;
-	int error, nid, is_ram;
+	int error, is_ram;
 	bool need_devmap_managed = true;
 
 	switch (pgmap->type) {
@@ -223,7 +208,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 
 	conflict_pgmap = get_dev_pagemap(PHYS_PFN(res->start), NULL);
 	if (conflict_pgmap) {
-		dev_WARN(dev, "Conflicting mapping in same section\n");
+		WARN(1, "Conflicting mapping in same section\n");
 		put_dev_pagemap(conflict_pgmap);
 		error = -ENOMEM;
 		goto err_array;
@@ -231,7 +216,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 
 	conflict_pgmap = get_dev_pagemap(PHYS_PFN(res->end), NULL);
 	if (conflict_pgmap) {
-		dev_WARN(dev, "Conflicting mapping in same section\n");
+		WARN(1, "Conflicting mapping in same section\n");
 		put_dev_pagemap(conflict_pgmap);
 		error = -ENOMEM;
 		goto err_array;
@@ -252,7 +237,6 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	if (error)
 		goto err_array;
 
-	nid = dev_to_node(dev);
 	if (nid < 0)
 		nid = numa_mem_id();
 
@@ -308,12 +292,6 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 				PHYS_PFN(res->start),
 				PHYS_PFN(resource_size(res)), pgmap);
 	percpu_ref_get_many(pgmap->ref, pfn_end(pgmap) - pfn_first(pgmap));
-
-	error = devm_add_action_or_reset(dev, devm_memremap_pages_release,
-			pgmap);
-	if (error)
-		return ERR_PTR(error);
-
 	return __va(res->start);
 
  err_add_memory:
@@ -328,6 +306,42 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	devmap_managed_enable_put();
 	return ERR_PTR(error);
 }
+
+/**
+ * devm_memremap_pages - remap and provide memmap backing for the given resource
+ * @dev: hosting device for @res
+ * @pgmap: pointer to a struct dev_pagemap
+ *
+ * Notes:
+ * 1/ At a minimum the res and type members of @pgmap must be initialized
+ *    by the caller before passing it to this function
+ *
+ * 2/ The altmap field may optionally be initialized, in which case
+ *    PGMAP_ALTMAP_VALID must be set in pgmap->flags.
+ *
+ * 3/ The ref field may optionally be provided, in which pgmap->ref must be
+ *    'live' on entry and will be killed and reaped at
+ *    devm_memremap_pages_release() time, or if this routine fails.
+ *
+ * 4/ res is expected to be a host memory range that could feasibly be
+ *    treated as a "System RAM" range, i.e. not a device mmio range, but
+ *    this is not enforced.
+ */
+void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
+{
+	int error;
+	void *ret;
+
+	ret = memremap_pages(pgmap, dev_to_node(dev));
+	if (IS_ERR(ret))
+		return ret;
+
+	error = devm_add_action_or_reset(dev, devm_memremap_pages_release,
+			pgmap);
+	if (error)
+		return ERR_PTR(error);
+	return ret;
+}
 EXPORT_SYMBOL_GPL(devm_memremap_pages);
 
 void devm_memunmap_pages(struct device *dev, struct dev_pagemap *pgmap)
-- 
2.20.1

