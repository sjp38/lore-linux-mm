Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A396BC31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A83C2089E
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="UAicujz/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A83C2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B79AA8E000F; Mon, 17 Jun 2019 08:28:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B50748E000B; Mon, 17 Jun 2019 08:28:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A19258E000F; Mon, 17 Jun 2019 08:28:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 67FB38E000B
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:28:09 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id j36so7642235pgb.20
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:28:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CCDpYq0cfPU5A/VTH+xsLw5c5i/G2uDb/EZi5JVjZA8=;
        b=SDB7gbLrcWarI05wPntjs8X1rHurqaGdgOnG7/06eIGdICyHyJaAR3Xoe5+bt50139
         oYN32NyJrpQf2SW4cocpf0fhe6yF5IuFmLZRVKpheU/6ce85ERj+UsLyF8+BkrMQ9h0W
         BHX8Ef0vzNBsfRO1w2i4nzfItt7CpTACADDRypdHhzT44PZf0iq2XDRAVQZ24NioptE9
         +jQ5YT9RVckJ/IjOPZU6FXd+sI35FHd4aD4lUSncR4GLG8sb5/GfZL3Xarpn0Zjzobue
         s8wZcaPY8nJw/1Cdw/F6MaBCqCz3xX3+hYN/ZfdPeL5E6qNBsDIJWTUlZcclH3cJH+U9
         jl3w==
X-Gm-Message-State: APjAAAW4V2D5CIJNo3K/EcssYwEiGvN/6XFgQC0Od8RlFEKgMe52Fvif
	0zPtK4aFdG6JARFmrW2PDzZW8OAcyfu566sR+8KZql53pxHs4G6EsTSmK2s4iCagl8XHDJKUhIn
	YEU/Tqq4awr9ASEs0VB+Ho2lUpzirwzDNrhmSevhRsn+oZZpH8/z6npjIeCYED2U=
X-Received: by 2002:a17:902:54f:: with SMTP id 73mr105801100plf.246.1560774489090;
        Mon, 17 Jun 2019 05:28:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCW7YQlzz+Ar2eL8+d9QNnVFLMwYfMkA/JRnxkvvtbNH3NBQth4QYq9MBXBs13t0AI5Pz8
X-Received: by 2002:a17:902:54f:: with SMTP id 73mr105801061plf.246.1560774488335;
        Mon, 17 Jun 2019 05:28:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774488; cv=none;
        d=google.com; s=arc-20160816;
        b=ZO0y6eoJexROF10HnZpq6A8k/WbK6R0CZ+oGqhLkgFq2opi5Bjl5MxW3KotnizoPt4
         ZLCkDdtAGvOe42hMNFb6XhC8s9+hHeKb8Zk7nxaRLaLpsKE/EHmYvXrlDKT+jMCPvgDh
         u1bR8c67txotuOfZCdRGArYFlyOINd714xC28T+qlgA4/82O1xDeLv5udQ2ZUXEBUkEY
         IxoBVBNakJiH0uA7Fuvqh4YOOwg3JWy9SziJyTItioZoxXo8KpyukcMW/Pjur1sm76Bm
         rxqbLoTSnacf3KvTpJ9slr3eBnyizOc/JqVdz4b3YKkqLpiuAMAx8l/fX1+M6VBCNCZD
         BsUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=CCDpYq0cfPU5A/VTH+xsLw5c5i/G2uDb/EZi5JVjZA8=;
        b=WgPuvT+Q8XAlrIh12aBACgtCTUXY99nTd8N0iqY9zQcGUTQ61NJiHthwK8nd/XWdOB
         fT3NB1fLpS1g/F1zlhSMqxCg5uTNLpq9vo0d5oknf7Uawg5SZnwZnsp7QFQdzG6g9UYd
         o9szultfy0AoxilH56TTAOF+ZRMDvsoZXQFMbnfnL9y97fkbj57v52YVoRK5cmI3I+4R
         /f6kTfFutESjKztF32YvrsN2ZDifVWwWnhnInC1DjuZ122Wdc+/ITn6t5VghINn5mWfw
         tVDTO0RooDpGzlzHXH2J+2L6Cd1IjUNfuGpdDmt0Cq/Cm3a4xLh87EAf4sYI7SB2PqXl
         WFww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="UAicujz/";
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v38si10004190plg.277.2019.06.17.05.28.08
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:28:08 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="UAicujz/";
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=CCDpYq0cfPU5A/VTH+xsLw5c5i/G2uDb/EZi5JVjZA8=; b=UAicujz/YVlKK+WKFtiONSPd4O
	BJKs+xmHpssspGq3McquTV8vbga/nq3/q1eYBDV/EH8jgE9LbrEuhITcWWrtX4KP6gedHj21lXM7L
	fzIbsm/SnlwB5scY8jKHVKMRjExJvc6f+ggr7aJhlVwN6hXtbnw63NYAfc9m0pXlk8SqqOqvuwn91
	oYdNf/bAVgS250D/KEXwGQLD+OIK8ngJNhKbAwHIwdznpPM3aCF9/hjhYag8FTwDYhgM5z8nMN0Hi
	BlsdruuEUAfUs3Ea4mKWmZ+OnZ3IAaE4JeL3zAlMq/tZkvynJuq+HxmOnhFK3av+Yv/7+kxYzEjYc
	bP3Y7R/w==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqjz-0000Cf-UU; Mon, 17 Jun 2019 12:28:04 +0000
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
Subject: [PATCH 12/25] memremap: remove the data field in struct dev_pagemap
Date: Mon, 17 Jun 2019 14:27:20 +0200
Message-Id: <20190617122733.22432-13-hch@lst.de>
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

struct dev_pagemap is always embedded into a containing structure, so
there is no need to an additional private data field.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
---
 drivers/nvdimm/pmem.c    | 2 +-
 include/linux/memremap.h | 3 +--
 kernel/memremap.c        | 2 +-
 mm/hmm.c                 | 9 +++++----
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 85364c59c607..1ff4b1c4c7c3 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -342,7 +342,7 @@ static void pmem_release_disk(void *__pmem)
 	put_disk(pmem->disk);
 }
 
-static void pmem_pagemap_page_free(struct page *page, void *data)
+static void pmem_pagemap_page_free(struct page *page)
 {
 	wake_up_var(&page->_refcount);
 }
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 72a8a1a9303b..036c637f0150 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -69,7 +69,7 @@ struct dev_pagemap_ops {
 	 * reach 0 refcount unless there is a refcount bug. This allows the
 	 * device driver to implement its own memory management.)
 	 */
-	void (*page_free)(struct page *page, void *data);
+	void (*page_free)(struct page *page);
 
 	/*
 	 * Transition the refcount in struct dev_pagemap to the dead state.
@@ -104,7 +104,6 @@ struct dev_pagemap {
 	struct resource res;
 	struct percpu_ref *ref;
 	struct device *dev;
-	void *data;
 	enum memory_type type;
 	u64 pci_p2pdma_bus_offset;
 	const struct dev_pagemap_ops *ops;
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 5245c25b10e3..9dd5ccdb1adb 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -379,7 +379,7 @@ void __put_devmap_managed_page(struct page *page)
 
 		mem_cgroup_uncharge(page);
 
-		page->pgmap->ops->page_free(page, page->pgmap->data);
+		page->pgmap->ops->page_free(page);
 	} else if (!count)
 		__put_page(page);
 }
diff --git a/mm/hmm.c b/mm/hmm.c
index 2e5642dc6b04..8a0e04bbeee6 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1365,15 +1365,17 @@ static void hmm_devmem_ref_kill(struct dev_pagemap *pgmap)
 
 static vm_fault_t hmm_devmem_migrate_to_ram(struct vm_fault *vmf)
 {
-	struct hmm_devmem *devmem = vmf->page->pgmap->data;
+	struct hmm_devmem *devmem =
+		container_of(vmf->page->pgmap, struct hmm_devmem, pagemap);
 
 	return devmem->ops->fault(devmem, vmf->vma, vmf->address, vmf->page,
 			vmf->flags, vmf->pmd);
 }
 
-static void hmm_devmem_free(struct page *page, void *data)
+static void hmm_devmem_free(struct page *page)
 {
-	struct hmm_devmem *devmem = data;
+	struct hmm_devmem *devmem =
+		container_of(page->pgmap, struct hmm_devmem, pagemap);
 
 	devmem->ops->free(devmem, page);
 }
@@ -1439,7 +1441,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 	devmem->pagemap.ops = &hmm_pagemap_ops;
 	devmem->pagemap.altmap_valid = false;
 	devmem->pagemap.ref = &devmem->ref;
-	devmem->pagemap.data = devmem;
 
 	result = devm_memremap_pages(devmem->device, &devmem->pagemap);
 	if (IS_ERR(result))
-- 
2.20.1

