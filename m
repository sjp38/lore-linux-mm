Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 973F7C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 466992063F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="bL49WJDD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 466992063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95E7B8E001E; Wed, 26 Jun 2019 08:28:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8979A8E0005; Wed, 26 Jun 2019 08:28:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73AEA8E001E; Wed, 26 Jun 2019 08:28:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FEA68E0005
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:28:34 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id u21so1663002pfn.15
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:28:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1EWGF/F6e1vBHfjAA6nX1LYEAAsLgFm61+exsZF7p+E=;
        b=crFYw/HXXrkYdzvkU1AQPD4qS2z1GErWMghZo2+4VHQez/bI7qjTx6dgR2LX6P5kb8
         wJux8acB04Yt1VclLkKI4nvPaxptqGVI3mpQWQQXzJucpiKlolYl+Uy8j/jefMJ3r/O1
         CP4LlvCYmKcj7Q8tZp+bwlvIC849xUEmU6eYiN0eznJLn+v752jym5/h+HNAnxyQiTyI
         oyqeNeNj1k08f1pq9qWrQRT6tAUAbAh3uSTB1pF8n06Adz+S09apKnjboSUqmpkwCDpc
         602RtDfJqenj9Neu4Pb1ULwSfNEUko1bzf0k3fdrdRCBnrTtUQ/CfCxjbfpJVYJOOoig
         ouDw==
X-Gm-Message-State: APjAAAUsk1yRCfZ+ZViYg7Iwrwu+Bh0uoeYWLpuJvyyFUlcJOqXRxFgk
	9NDVS0Srew9wzdTXDX8lUvSg5Ftx/C+T5bik8P4CBpDJR6EJtActQQegIeTPPFFv/486FRYDnXl
	9vYrJpjxm25ELB6GpCKaYmP7jNqgiKO/Vh959HvY6SSAsy+l9Fxj8DMZuYnbqxSk=
X-Received: by 2002:a65:6204:: with SMTP id d4mr2751146pgv.104.1561552113734;
        Wed, 26 Jun 2019 05:28:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwqjGVuQmh+MPUpdaUYdBORVdS2rzTkBGo3XAzASLcOc+E9KsxpmKGAI6OUBu105TckwlFI
X-Received: by 2002:a65:6204:: with SMTP id d4mr2751060pgv.104.1561552112448;
        Wed, 26 Jun 2019 05:28:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552112; cv=none;
        d=google.com; s=arc-20160816;
        b=s3dsDeTBMxnIatyz9k/lxwd8FcX7j4wOe6kpcjTrqtIVONj11XRvZQV0U+jLqHS/iD
         Q2UBuxBAsaaMqfjh1+aioZZC+d1YHVcdoz3xI56+UFv+X+9dcVK1J8voO8fOwGhlKAAI
         CLi1KBhYs9dtg05ITzV3LdBhBd5pHsoT2Q+tzOlsoSipJDXvt7ADDSqcG1m/MfOu+TRX
         vkF+Vl2kATBh5vYe3LbguUjplLU8rVJr8rlUxfk1D8BqfGAQIPwYFmL3ymFAvJ1Fce1s
         J4qQW2p0n2KhKhCfSI9X0mF20CxHeZZc4qQbWdyTU+SJLnAvsLme8/6ZwwlZy35Epb2R
         Tufw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=1EWGF/F6e1vBHfjAA6nX1LYEAAsLgFm61+exsZF7p+E=;
        b=ZT9WkFTB1cNxQHKSmoKeiW2RgfkuQbuVMURJV+8aLBNdHialWUIet9Jf8joZxYG13g
         7sx8eCNzSYxjXzcxEOC8Cf89MEVl9J9schh59Dh0/FpzVOcOm41QUgIBb0/ae9m4tIxO
         32soki3WirzebW50NY9yv+25XCOXxgc2zldjaV6I6zz2B3yCyaUiYU0to2OFEtVoTtKo
         Xppamik+YiDrs8InhxmL6gWsdsBVjIga7ALKBVY5ayHbARsBd6OSudLyB+Hv3EMWwjTE
         p3BrajrGktUIwOQ//OeqT2wZPQ0fZaDtlBl9jWst4K8KN83znwLi5+e54U/P/zGZw/5N
         44aA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=bL49WJDD;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y10si1877630pjr.21.2019.06.26.05.28.32
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:28:32 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=bL49WJDD;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=1EWGF/F6e1vBHfjAA6nX1LYEAAsLgFm61+exsZF7p+E=; b=bL49WJDDJc3uz+E3Tq04Tm5aOh
	6UKiHfGJ4xc1EdjM+wIO+4O7TabN+U+mE4CUE7GVW/6hNT1G25p6zM6t2nVmATDNy70CoTYKvUXYh
	h63gBbqAnP0fS/lvCqryLq3sJaRMn4yQ/kLLVV4MhA9L5yzp96EXF7zgv5NJOti4WMo+m7s82bMJK
	tcjaFPnwpZ0KnnQ9gPRDwYlIZplqIULbGZnpwlX73gmGQjQ6zUyUid/upr/R6McnyA6o8yC/58lCE
	OCyyeu7FUxcUuZa0aNWyNmTN2ebeV0grSQhN82z/PKk4I5ke7M0SV3GzBYODNCZUs6sDgaWMbxtfQ
	or4ndx9w==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg72E-0001cj-Jv; Wed, 26 Jun 2019 12:28:23 +0000
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
Subject: [PATCH 21/25] mm: remove hmm_devmem_add
Date: Wed, 26 Jun 2019 14:27:20 +0200
Message-Id: <20190626122724.13313-22-hch@lst.de>
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

There isn't really much value add in the hmm_devmem_add wrapper and
more, as using devm_memremap_pages directly now is just as simple.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
---
 Documentation/vm/hmm.rst |  26 --------
 include/linux/hmm.h      | 129 ---------------------------------------
 mm/hmm.c                 | 110 ---------------------------------
 3 files changed, 265 deletions(-)

diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
index 7cdf7282e022..50e1380950a9 100644
--- a/Documentation/vm/hmm.rst
+++ b/Documentation/vm/hmm.rst
@@ -329,32 +329,6 @@ directly using struct page for device memory which left most kernel code paths
 unaware of the difference. We only need to make sure that no one ever tries to
 map those pages from the CPU side.
 
-HMM provides a set of helpers to register and hotplug device memory as a new
-region needing a struct page. This is offered through a very simple API::
-
- struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
-                                   struct device *device,
-                                   unsigned long size);
- void hmm_devmem_remove(struct hmm_devmem *devmem);
-
-The hmm_devmem_ops is where most of the important things are::
-
- struct hmm_devmem_ops {
-     void (*free)(struct hmm_devmem *devmem, struct page *page);
-     int (*fault)(struct hmm_devmem *devmem,
-                  struct vm_area_struct *vma,
-                  unsigned long addr,
-                  struct page *page,
-                  unsigned flags,
-                  pmd_t *pmdp);
- };
-
-The first callback (free()) happens when the last reference on a device page is
-dropped. This means the device page is now free and no longer used by anyone.
-The second callback happens whenever the CPU tries to access a device page
-which it cannot do. This second callback must trigger a migration back to
-system memory.
-
 
 Migration to and from device memory
 ===================================
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 1d55b7ea2da6..86aa4ec3404c 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -585,135 +585,6 @@ static inline void hmm_mm_init(struct mm_struct *mm) {}
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
 #if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
-struct hmm_devmem;
-
-/*
- * struct hmm_devmem_ops - callback for ZONE_DEVICE memory events
- *
- * @free: call when refcount on page reach 1 and thus is no longer use
- * @fault: call when there is a page fault to unaddressable memory
- *
- * Both callback happens from page_free() and page_fault() callback of struct
- * dev_pagemap respectively. See include/linux/memremap.h for more details on
- * those.
- *
- * The hmm_devmem_ops callback are just here to provide a coherent and
- * uniq API to device driver and device driver should not register their
- * own page_free() or page_fault() but rely on the hmm_devmem_ops call-
- * back.
- */
-struct hmm_devmem_ops {
-	/*
-	 * free() - free a device page
-	 * @devmem: device memory structure (see struct hmm_devmem)
-	 * @page: pointer to struct page being freed
-	 *
-	 * Call back occurs whenever a device page refcount reach 1 which
-	 * means that no one is holding any reference on the page anymore
-	 * (ZONE_DEVICE page have an elevated refcount of 1 as default so
-	 * that they are not release to the general page allocator).
-	 *
-	 * Note that callback has exclusive ownership of the page (as no
-	 * one is holding any reference).
-	 */
-	void (*free)(struct hmm_devmem *devmem, struct page *page);
-	/*
-	 * fault() - CPU page fault or get user page (GUP)
-	 * @devmem: device memory structure (see struct hmm_devmem)
-	 * @vma: virtual memory area containing the virtual address
-	 * @addr: virtual address that faulted or for which there is a GUP
-	 * @page: pointer to struct page backing virtual address (unreliable)
-	 * @flags: FAULT_FLAG_* (see include/linux/mm.h)
-	 * @pmdp: page middle directory
-	 * Returns: VM_FAULT_MINOR/MAJOR on success or one of VM_FAULT_ERROR
-	 *   on error
-	 *
-	 * The callback occurs whenever there is a CPU page fault or GUP on a
-	 * virtual address. This means that the device driver must migrate the
-	 * page back to regular memory (CPU accessible).
-	 *
-	 * The device driver is free to migrate more than one page from the
-	 * fault() callback as an optimization. However if device decide to
-	 * migrate more than one page it must always priotirize the faulting
-	 * address over the others.
-	 *
-	 * The struct page pointer is only given as an hint to allow quick
-	 * lookup of internal device driver data. A concurrent migration
-	 * might have already free that page and the virtual address might
-	 * not longer be back by it. So it should not be modified by the
-	 * callback.
-	 *
-	 * Note that mmap semaphore is held in read mode at least when this
-	 * callback occurs, hence the vma is valid upon callback entry.
-	 */
-	vm_fault_t (*fault)(struct hmm_devmem *devmem,
-		     struct vm_area_struct *vma,
-		     unsigned long addr,
-		     const struct page *page,
-		     unsigned int flags,
-		     pmd_t *pmdp);
-};
-
-/*
- * struct hmm_devmem - track device memory
- *
- * @completion: completion object for device memory
- * @pfn_first: first pfn for this resource (set by hmm_devmem_add())
- * @pfn_last: last pfn for this resource (set by hmm_devmem_add())
- * @resource: IO resource reserved for this chunk of memory
- * @pagemap: device page map for that chunk
- * @device: device to bind resource to
- * @ops: memory operations callback
- * @ref: per CPU refcount
- * @page_fault: callback when CPU fault on an unaddressable device page
- *
- * This an helper structure for device drivers that do not wish to implement
- * the gory details related to hotplugging new memoy and allocating struct
- * pages.
- *
- * Device drivers can directly use ZONE_DEVICE memory on their own if they
- * wish to do so.
- *
- * The page_fault() callback must migrate page back, from device memory to
- * system memory, so that the CPU can access it. This might fail for various
- * reasons (device issues,  device have been unplugged, ...). When such error
- * conditions happen, the page_fault() callback must return VM_FAULT_SIGBUS and
- * set the CPU page table entry to "poisoned".
- *
- * Note that because memory cgroup charges are transferred to the device memory,
- * this should never fail due to memory restrictions. However, allocation
- * of a regular system page might still fail because we are out of memory. If
- * that happens, the page_fault() callback must return VM_FAULT_OOM.
- *
- * The page_fault() callback can also try to migrate back multiple pages in one
- * chunk, as an optimization. It must, however, prioritize the faulting address
- * over all the others.
- */
-
-struct hmm_devmem {
-	struct completion		completion;
-	unsigned long			pfn_first;
-	unsigned long			pfn_last;
-	struct resource			*resource;
-	struct device			*device;
-	struct dev_pagemap		pagemap;
-	const struct hmm_devmem_ops	*ops;
-	struct percpu_ref		ref;
-};
-
-/*
- * To add (hotplug) device memory, HMM assumes that there is no real resource
- * that reserves a range in the physical address space (this is intended to be
- * use by unaddressable device memory). It will reserve a physical range big
- * enough and allocate struct page for it.
- *
- * The device driver can wrap the hmm_devmem struct inside a private device
- * driver struct.
- */
-struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
-				  struct device *device,
-				  unsigned long size);
-
 /*
  * hmm_devmem_page_set_drvdata - set per-page driver data field
  *
diff --git a/mm/hmm.c b/mm/hmm.c
index fdbd48771292..90ca0cdab9db 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1327,113 +1327,3 @@ long hmm_range_dma_unmap(struct hmm_range *range,
 }
 EXPORT_SYMBOL(hmm_range_dma_unmap);
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
-
-
-#if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
-static void hmm_devmem_ref_release(struct percpu_ref *ref)
-{
-	struct hmm_devmem *devmem;
-
-	devmem = container_of(ref, struct hmm_devmem, ref);
-	complete(&devmem->completion);
-}
-
-static void hmm_devmem_ref_exit(struct dev_pagemap *pgmap)
-{
-	struct hmm_devmem *devmem;
-
-	devmem = container_of(pgmap, struct hmm_devmem, pagemap);
-	wait_for_completion(&devmem->completion);
-	percpu_ref_exit(pgmap->ref);
-}
-
-static void hmm_devmem_ref_kill(struct dev_pagemap *pgmap)
-{
-	percpu_ref_kill(pgmap->ref);
-}
-
-static vm_fault_t hmm_devmem_migrate_to_ram(struct vm_fault *vmf)
-{
-	struct hmm_devmem *devmem =
-		container_of(vmf->page->pgmap, struct hmm_devmem, pagemap);
-
-	return devmem->ops->fault(devmem, vmf->vma, vmf->address, vmf->page,
-			vmf->flags, vmf->pmd);
-}
-
-static void hmm_devmem_free(struct page *page)
-{
-	struct hmm_devmem *devmem =
-		container_of(page->pgmap, struct hmm_devmem, pagemap);
-
-	devmem->ops->free(devmem, page);
-}
-
-static const struct dev_pagemap_ops hmm_pagemap_ops = {
-	.page_free		= hmm_devmem_free,
-	.kill			= hmm_devmem_ref_kill,
-	.cleanup		= hmm_devmem_ref_exit,
-	.migrate_to_ram		= hmm_devmem_migrate_to_ram,
-};
-
-/*
- * hmm_devmem_add() - hotplug ZONE_DEVICE memory for device memory
- *
- * @ops: memory event device driver callback (see struct hmm_devmem_ops)
- * @device: device struct to bind the resource too
- * @size: size in bytes of the device memory to add
- * Returns: pointer to new hmm_devmem struct ERR_PTR otherwise
- *
- * This function first finds an empty range of physical address big enough to
- * contain the new resource, and then hotplugs it as ZONE_DEVICE memory, which
- * in turn allocates struct pages. It does not do anything beyond that; all
- * events affecting the memory will go through the various callbacks provided
- * by hmm_devmem_ops struct.
- *
- * Device driver should call this function during device initialization and
- * is then responsible of memory management. HMM only provides helpers.
- */
-struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
-				  struct device *device,
-				  unsigned long size)
-{
-	struct hmm_devmem *devmem;
-	void *result;
-	int ret;
-
-	devmem = devm_kzalloc(device, sizeof(*devmem), GFP_KERNEL);
-	if (!devmem)
-		return ERR_PTR(-ENOMEM);
-
-	init_completion(&devmem->completion);
-	devmem->pfn_first = -1UL;
-	devmem->pfn_last = -1UL;
-	devmem->resource = NULL;
-	devmem->device = device;
-	devmem->ops = ops;
-
-	ret = percpu_ref_init(&devmem->ref, &hmm_devmem_ref_release,
-			      0, GFP_KERNEL);
-	if (ret)
-		return ERR_PTR(ret);
-
-	devmem->resource = devm_request_free_mem_region(device, &iomem_resource,
-			size);
-	if (IS_ERR(devmem->resource))
-		return ERR_CAST(devmem->resource);
-	devmem->pfn_first = devmem->resource->start >> PAGE_SHIFT;
-	devmem->pfn_last = devmem->pfn_first +
-			   (resource_size(devmem->resource) >> PAGE_SHIFT);
-
-	devmem->pagemap.type = MEMORY_DEVICE_PRIVATE;
-	devmem->pagemap.res = *devmem->resource;
-	devmem->pagemap.ops = &hmm_pagemap_ops;
-	devmem->pagemap.ref = &devmem->ref;
-
-	result = devm_memremap_pages(devmem->device, &devmem->pagemap);
-	if (IS_ERR(result))
-		return result;
-	return devmem;
-}
-EXPORT_SYMBOL_GPL(hmm_devmem_add);
-#endif /* CONFIG_DEVICE_PRIVATE  */
-- 
2.20.1

