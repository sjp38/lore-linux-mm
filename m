Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E697C282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 17:47:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF3AA214DA
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 17:47:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF3AA214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 897DE8E0007; Tue, 29 Jan 2019 12:47:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 846428E0001; Tue, 29 Jan 2019 12:47:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 712DC8E0007; Tue, 29 Jan 2019 12:47:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 43A898E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:47:55 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id n45so25666155qta.5
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 09:47:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YRbAZ+lp+j59t1y/XLZmXGP23A29YFgjirRM+nR5vIY=;
        b=lx+i5esDbB0SwHsaRZK2b8cpGHmiZYEAA/DGR2Mct/oNla+oZ/2rTOXEQIFgGI6mHt
         5IcQ0UhWKVo1bZ5B0wxrlkoGmM2RfWKb4/wCPdQvEJNvVnyJwk2YGR+LSpF020BskhNV
         q+Wedvza0XDh7qUdJcOGJoOp5aq5mtSl758bKLPs9L3q7P4mj8GHivj6zFnqpD8HvZcJ
         x4H6vWDL1iEgtULmU6Yr7c8Ig9fmCrcMGwsO1y9tpPJ7WpY7/w8U15OWRBhFetIhNCgU
         X2dISLiNWQUDjJit4pQ8y9RmAG6Cp8au4nr2hHI+20PG6A/iDD2y7bmmzBvIYOiMpe1T
         gGPA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukfDF+UJpACjcsmtDk/5Db6LWY4ra0MV6Skvkz80iI6cUeZ9mGXj
	JH/wjZ+O031IyzbkqletDR/MvsUbiaxEVrPISLbWE5gdy2Mo8rF5o1FtJqNin/knpdBMFwAEjQ2
	4vK27wG+ichVCnNSnrfhzLHzYopA6o0F5/EFm8wAk0n2Awxv3At8RoOJxOdGUeIx2/Q==
X-Received: by 2002:a37:ac05:: with SMTP id e5mr25044863qkm.102.1548784075038;
        Tue, 29 Jan 2019 09:47:55 -0800 (PST)
X-Google-Smtp-Source: ALg8bN687GOkaVOFM5ky3mQj/xiW7WzaLlx58xLQIGlURP9dHYxytcRoyHjzhMLmXO0z7REIS+oZ
X-Received: by 2002:a37:ac05:: with SMTP id e5mr25044834qkm.102.1548784074441;
        Tue, 29 Jan 2019 09:47:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548784074; cv=none;
        d=google.com; s=arc-20160816;
        b=FI+q8wxjib7RA2AHUNIwVXvnTTlTocqFpQlsz5fRMKDLgmcQYQqmcJN3UPdj8SXdlw
         0T3A8WR3Mv4hS9YitA9JI7EwaFdqeNgaqiumjJURakv7h+TOVgXuMZb0p1H1TXpNQEvs
         sbbDb/uzkks0qn2ArrMU6AA3eAAIBCheyg3qmCAvw8mETmgqcpr9vuaV+1Y3EHObGHHV
         jbXGdIJ4duw2GZXm08acB6kKaaCrKaJjoSsGVEPnQk8vpFa48jll7d3LGAPeMDyqSIlR
         bx7nXIxrIT0buGhzzgzdfH+h6lFrbvOipoyyU8fOVGd+45fj1ic61XEuWjV2LJC0QkAx
         QB7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=YRbAZ+lp+j59t1y/XLZmXGP23A29YFgjirRM+nR5vIY=;
        b=BH06sDtbZz7Hh3XL+e5MVXfQ7Od7OMqbcHKVjnr/Pl/Q7jKB/R1zCjQWJwjRJn+8me
         9jCAk2IQYXMd0UrGPJfHp5oD6338r+cpo7Rz7BT6g8ExzR1jaMD93IEk/tN1kEu9Sp+5
         iZjYYG2ot+k1lN7UPwGOVQFWSpiVtkrkDxCBqY94CM86Dj8E1i/hTwMaYuD6glsQddlM
         l90C/1e06wifnlZERrYQDUQDBcZ3puPe3lqZ4PRQdig73m2WJ3rxD3W8aXMirxEIAIkh
         5ILK/xsX44E3i0uBDUAhoiEcv9xRk3rnlKzGIznkx71LHQvSdMaWdiy89zQ8Ip6a/Aca
         HxKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r29si1918305qtr.290.2019.01.29.09.47.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 09:47:54 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C7A34C079C49;
	Tue, 29 Jan 2019 17:47:47 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B23F35D97A;
	Tue, 29 Jan 2019 17:47:45 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	linux-pci@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Joerg Roedel <jroedel@suse.de>,
	iommu@lists.linux-foundation.org
Subject: [RFC PATCH 4/5] mm/hmm: add support for peer to peer to HMM device memory
Date: Tue, 29 Jan 2019 12:47:27 -0500
Message-Id: <20190129174728.6430-5-jglisse@redhat.com>
In-Reply-To: <20190129174728.6430-1-jglisse@redhat.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 29 Jan 2019 17:47:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Rafael J. Wysocki <rafael@kernel.org>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Christian Koenig <christian.koenig@amd.com>
Cc: Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: linux-pci@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org
Cc: Christoph Hellwig <hch@lst.de>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Robin Murphy <robin.murphy@arm.com>
Cc: Joerg Roedel <jroedel@suse.de>
Cc: iommu@lists.linux-foundation.org
---
 include/linux/hmm.h | 47 +++++++++++++++++++++++++++++++++
 mm/hmm.c            | 63 +++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 105 insertions(+), 5 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 4a1454e3efba..7a3ac182cc48 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -710,6 +710,53 @@ struct hmm_devmem_ops {
 		     const struct page *page,
 		     unsigned int flags,
 		     pmd_t *pmdp);
+
+	/*
+	 * p2p_map() - map page for peer to peer between device
+	 * @devmem: device memory structure (see struct hmm_devmem)
+	 * @range: range of virtual address that is being mapped
+	 * @device: device the range is being map to
+	 * @addr: first virtual address in the range to consider
+	 * @pa: device address (where actual mapping is store)
+	 * Returns: number of page successfuly mapped, 0 otherwise
+	 *
+	 * Map page belonging to devmem to another device for peer to peer
+	 * access. Device can decide not to map in which case memory will
+	 * be migrated to main memory.
+	 *
+	 * Also there is no garantee that all the pages in the range does
+	 * belongs to the devmem so it is up to the function to check that
+	 * every single page does belong to devmem.
+	 *
+	 * Note for now we do not care about error exect error, so on failure
+	 * function should just return 0.
+	 */
+	long (*p2p_map)(struct hmm_devmem *devmem,
+			struct hmm_range *range,
+			struct device *device,
+			unsigned long addr,
+			dma_addr_t *pas);
+
+	/*
+	 * p2p_unmap() - unmap page from peer to peer between device
+	 * @devmem: device memory structure (see struct hmm_devmem)
+	 * @range: range of virtual address that is being mapped
+	 * @device: device the range is being map to
+	 * @addr: first virtual address in the range to consider
+	 * @pa: device address (where actual mapping is store)
+	 * Returns: number of page successfuly unmapped, 0 otherwise
+	 *
+	 * Unmap page belonging to devmem previously map with p2p_map().
+	 *
+	 * Note there is no garantee that all the pages in the range does
+	 * belongs to the devmem so it is up to the function to check that
+	 * every single page does belong to devmem.
+	 */
+	unsigned long (*p2p_unmap)(struct hmm_devmem *devmem,
+				   struct hmm_range *range,
+				   struct device *device,
+				   unsigned long addr,
+				   dma_addr_t *pas);
 };
 
 /*
diff --git a/mm/hmm.c b/mm/hmm.c
index 1a444885404e..fd49b1e116d0 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1193,16 +1193,19 @@ long hmm_range_dma_map(struct hmm_range *range,
 		       dma_addr_t *daddrs,
 		       bool block)
 {
-	unsigned long i, npages, mapped, page_size;
+	unsigned long i, npages, mapped, page_size, addr;
 	long ret;
 
+again:
 	ret = hmm_range_fault(range, block);
 	if (ret <= 0)
 		return ret ? ret : -EBUSY;
 
+	mapped = 0;
+	addr = range->start;
 	page_size = hmm_range_page_size(range);
 	npages = (range->end - range->start) >> range->page_shift;
-	for (i = 0, mapped = 0; i < npages; ++i) {
+	for (i = 0; i < npages; ++i, addr += page_size) {
 		enum dma_data_direction dir = DMA_FROM_DEVICE;
 		struct page *page;
 
@@ -1226,6 +1229,29 @@ long hmm_range_dma_map(struct hmm_range *range,
 			goto unmap;
 		}
 
+		if (is_device_private_page(page)) {
+			struct hmm_devmem *devmem = page->pgmap->data;
+
+			if (!devmem->ops->p2p_map || !devmem->ops->p2p_unmap) {
+				/* Fall-back to main memory. */
+				range->default_flags |=
+					range->flags[HMM_PFN_DEVICE_PRIVATE];
+				goto again;
+			}
+
+			ret = devmem->ops->p2p_map(devmem, range, device,
+						   addr, daddrs);
+			if (ret <= 0) {
+				/* Fall-back to main memory. */
+				range->default_flags |=
+					range->flags[HMM_PFN_DEVICE_PRIVATE];
+				goto again;
+			}
+			mapped += ret;
+			i += ret;
+			continue;
+		}
+
 		/* If it is read and write than map bi-directional. */
 		if (range->pfns[i] & range->values[HMM_PFN_WRITE])
 			dir = DMA_BIDIRECTIONAL;
@@ -1242,7 +1268,9 @@ long hmm_range_dma_map(struct hmm_range *range,
 	return mapped;
 
 unmap:
-	for (npages = i, i = 0; (i < npages) && mapped; ++i) {
+	npages = i;
+	addr = range->start;
+	for (i = 0; (i < npages) && mapped; ++i, addr += page_size) {
 		enum dma_data_direction dir = DMA_FROM_DEVICE;
 		struct page *page;
 
@@ -1253,6 +1281,18 @@ long hmm_range_dma_map(struct hmm_range *range,
 		if (dma_mapping_error(device, daddrs[i]))
 			continue;
 
+		if (is_device_private_page(page)) {
+			struct hmm_devmem *devmem = page->pgmap->data;
+			unsigned long inc;
+
+			inc = devmem->ops->p2p_unmap(devmem, range, device,
+						     addr, &daddrs[i]);
+			BUG_ON(inc > npages);
+			mapped += inc;
+			i += inc;
+			continue;
+		}
+
 		/* If it is read and write than map bi-directional. */
 		if (range->pfns[i] & range->values[HMM_PFN_WRITE])
 			dir = DMA_BIDIRECTIONAL;
@@ -1285,7 +1325,7 @@ long hmm_range_dma_unmap(struct hmm_range *range,
 			 dma_addr_t *daddrs,
 			 bool dirty)
 {
-	unsigned long i, npages, page_size;
+	unsigned long i, npages, page_size, addr;
 	long cpages = 0;
 
 	/* Sanity check. */
@@ -1298,7 +1338,7 @@ long hmm_range_dma_unmap(struct hmm_range *range,
 
 	page_size = hmm_range_page_size(range);
 	npages = (range->end - range->start) >> range->page_shift;
-	for (i = 0; i < npages; ++i) {
+	for (i = 0, addr = range->start; i < npages; ++i, addr += page_size) {
 		enum dma_data_direction dir = DMA_FROM_DEVICE;
 		struct page *page;
 
@@ -1318,6 +1358,19 @@ long hmm_range_dma_unmap(struct hmm_range *range,
 				set_page_dirty(page);
 		}
 
+		if (is_device_private_page(page)) {
+			struct hmm_devmem *devmem = page->pgmap->data;
+			unsigned long ret;
+
+			BUG_ON(!devmem->ops->p2p_unmap);
+
+			ret = devmem->ops->p2p_unmap(devmem, range, device,
+						     addr, &daddrs[i]);
+			BUG_ON(ret > npages);
+			i += ret;
+			continue;
+		}
+
 		/* Unmap and clear pfns/dma address */
 		dma_unmap_page(device, daddrs[i], page_size, dir);
 		range->pfns[i] = range->values[HMM_PFN_NONE];
-- 
2.17.2

