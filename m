Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91934C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E6FB21473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Pg029Ia8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E6FB21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E4156B026A; Thu, 13 Jun 2019 05:44:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26EFD6B026B; Thu, 13 Jun 2019 05:44:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C45E6B026C; Thu, 13 Jun 2019 05:44:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BDDE66B026A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:44:04 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i26so14082209pfo.22
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:44:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kSl39t9D+nytN/xDZfA4PvUR9mE53ZbXgno/pdognno=;
        b=p4xfiTRyvca5A3K6FJ05sQeUYv9CBYN/JQSX1gWOTfNZUQDBhFosxyXeD7jyXsg2Z+
         EWGsTE+mQjh6LBW5Up4O6zODkCwYD22GZsoCYeWQ6irY1im5kITSOxIbaFIplNuiRtcB
         qTkgffZyHhJjT1R9v71KoBMEsVTD4E6g9m/xvU+/fCZcORWmWXAvA1E+PhhYoziGh+rE
         KSuSC/rKt1abxlTIAoKovWKwOz0aihVezvnjecVHsV8iQ12eaSW/iNNJopJuDK0gXHoz
         g/N6qeWvC+fdNv8IMNX0eQ2B6ydzXth5JVj6hkHARDGSSPoeeaDOsy7fAOKcux82QwpI
         n/KQ==
X-Gm-Message-State: APjAAAVDPzm5iVdvC5C/uTkNT5yjdQl3OuzMZvhMNK9+Zurf7Kj3pzaH
	9xeIbDedFaVmZU8Hv1odk3V6uvW/A2Nkys0mBdRy7h3G2OGdh9wDFy2MBWCwxGBMEbnpzcm937l
	7UbGkpHlvlofZwjfZvaZrVllXONqm0ehYz/SUjt+g97tWDzC9FqXsvYCz1rjkpbw=
X-Received: by 2002:a62:5306:: with SMTP id h6mr93020222pfb.29.1560419044436;
        Thu, 13 Jun 2019 02:44:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwIOdrwa4R8ZZVFNPnv7KH6zJRXMBW6ilAQJKAtoAv3ym0hoYPTptKIQLWuGl0nAokvZ/TO
X-Received: by 2002:a62:5306:: with SMTP id h6mr93020122pfb.29.1560419043577;
        Thu, 13 Jun 2019 02:44:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419043; cv=none;
        d=google.com; s=arc-20160816;
        b=Cn3thRoeUkcqOWZB1SzJ8KwaC+16FWy+NQoVva8VTDcgl6vZA+ABmrsjLcNh8en+92
         JQcQmtAEYg+tYJ7Oa0qJplDy20ybVKnF8OxU4gUrnXBifcmje8tC+o+/GG7oFA0Kx9Lh
         oah+I0ADGlP08oitSE3ntgOAPpiSp6D1cBMSzryy00PCJPhk/ilf+QU1VClEMwjkwQlP
         hTD+9S/SUuqNmJwonij4fZ/fiPTWZEwWePUMMXKoCnuKl93zJI/xR+RZ0j1XBTuLzKFg
         kdC6N+tzvZea6WgbbO+Uo9IhcmbjvDijCgX664WUEh4MwAgr0qbepyMCH6Bj4oW89Eh0
         aBjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=kSl39t9D+nytN/xDZfA4PvUR9mE53ZbXgno/pdognno=;
        b=EPQeJgYusCjUOU6L/ymPUrn4ABAiLHLaPPFYZmjpdinpm6/L/cb14ZHneS125L6J/7
         E5m+s4oEDKtMwnqAi3qGq0V3glb1lr+MlBCNQxFycsaOhXE5rlXigrCcWtCaM/0LAD9O
         YiFsmKlmbYdgqUE12yGeIxsXEpgSyy52BpXDxIek2JV6ECKVICSKlcWGoUBzdDNo73x/
         0OzYsQ2FcQPubMY1ZSPRzpO4kgy1LaCkr1plSumpEygjfwqXnwkiunRGYFevccE0oSY6
         H2yhUTwh2Pljq/TzcMHHF00ek4khIS2mdG30gR/NjIMgpCDEhvmHKHpwFexQA8pNjstl
         sbDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Pg029Ia8;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n19si2540414pjo.31.2019.06.13.02.44.03
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:44:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Pg029Ia8;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=kSl39t9D+nytN/xDZfA4PvUR9mE53ZbXgno/pdognno=; b=Pg029Ia8KJtlrfMQ0yw+zwPSDw
	FMI7A9BfUV19MJTx+3Zf9j3PpkbtUVH9VY8m9xQkHd3RwgbOrDoNCA19Qp091FCrZDRM/0CXcP8nf
	UcjsnWTrsgwuevTVg669Fa8aDofnaMryH2Hun/OYAXB9MiliZSYfJRgooDoNYrLm/pkZ1I6Fkmta8
	3k+SKma8EAtOLhmdRAsqEWdWPxuuBzFF8QR3KYnP39oIhc6LMbc7bhLeOsJpfxTdpo1T+14Y3k7Xb
	SVfxoSvQlltcSayigSX10q/5lD2qbaTFtAlIIb698SdZR9apu5ZPGiQU0jf01KymXFfF+uBXgtK0n
	kTCNmUFQ==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMH2-0001qR-Mm; Thu, 13 Jun 2019 09:44:01 +0000
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
Subject: [PATCH 11/22] memremap: remove the data field in struct dev_pagemap
Date: Thu, 13 Jun 2019 11:43:14 +0200
Message-Id: <20190613094326.24093-12-hch@lst.de>
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

struct dev_pagemap is always embedded into a containing structure, so
there is no need to an additional private data field.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/nvdimm/pmem.c    | 2 +-
 include/linux/memremap.h | 3 +--
 kernel/memremap.c        | 2 +-
 mm/hmm.c                 | 9 +++++----
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 66837eed6375..847d1b2bc10e 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -334,7 +334,7 @@ static void pmem_release_disk(void *__pmem)
 	put_disk(pmem->disk);
 }
 
-static void pmem_fsdax_page_free(struct page *page, void *data)
+static void pmem_fsdax_page_free(struct page *page)
 {
 	wake_up_var(&page->_refcount);
 }
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 03a4099be701..75b80de6394a 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -69,7 +69,7 @@ struct dev_pagemap_ops {
 	 * reach 0 refcount unless there is a refcount bug. This allows the
 	 * device driver to implement its own memory management.)
 	 */
-	void (*page_free)(struct page *page, void *data);
+	void (*page_free)(struct page *page);
 
 	/*
 	 * Transition the percpu_ref in struct dev_pagemap to the dead state.
@@ -99,7 +99,6 @@ struct dev_pagemap {
 	struct resource res;
 	struct percpu_ref *ref;
 	struct device *dev;
-	void *data;
 	enum memory_type type;
 	u64 pci_p2pdma_bus_offset;
 	const struct dev_pagemap_ops *ops;
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 7167e717647d..5c94ad4f5783 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -337,7 +337,7 @@ void __put_devmap_managed_page(struct page *page)
 
 		mem_cgroup_uncharge(page);
 
-		page->pgmap->ops->page_free(page, page->pgmap->data);
+		page->pgmap->ops->page_free(page);
 	} else if (!count)
 		__put_page(page);
 }
diff --git a/mm/hmm.c b/mm/hmm.c
index aab799677c7d..ff0f9568922b 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1332,15 +1332,17 @@ static void hmm_devmem_ref_kill(struct dev_pagemap *pgmap)
 
 static vm_fault_t hmm_devmem_migrate(struct vm_fault *vmf)
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
@@ -1409,7 +1411,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 	devmem->pagemap.ops = &hmm_pagemap_ops;
 	devmem->pagemap.altmap_valid = false;
 	devmem->pagemap.ref = &devmem->ref;
-	devmem->pagemap.data = devmem;
 
 	result = devm_memremap_pages(devmem->device, &devmem->pagemap);
 	if (IS_ERR(result))
-- 
2.20.1

