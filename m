Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3F80C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 17:47:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A16162184D
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 17:47:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A16162184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 497136B000E; Fri, 29 Mar 2019 13:47:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 446276B0010; Fri, 29 Mar 2019 13:47:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 335C16B0269; Fri, 29 Mar 2019 13:47:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E9FC26B000E
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 13:47:39 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id q18so2141143pll.16
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 10:47:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=w9iAm9mtRGL0c6b4Qv9pOcaRgs1GRlLTUXZ07VKuonU=;
        b=bO4vqTWjYP4hxkANt/bUL7bQAuw4+Aztbl4tXT+S/mWfWamzTEVFU08bhqEgV4qGm0
         jDweem/0JUZjnMhWv4l/tvvYzUsKw4btTQmbVEyfQr2bIkTT+lDXnTVuXOtkFLsYVEdz
         7WbI/lu7X1VqwtkQ2k3vJlynJ6VpKo2JaCFJJ7L6Yksqco4qBOd9GOkS0q9VsRsz9S8k
         akqEV2rFUHgFD+Msf6U58etxTbxx3qdwSbKKZdRCXN7fVUB9qdl8rboRwakirVTHOeuS
         H9pb3iVOx6Yot9QUu/OXlhDYd67xd6zAmqbsZubN2aiGAqyQ/YwfzT7Ir2mkcUz7w3NE
         5AQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUeKmUPjCuAPRRvCW1TGijfQvJhYuhwHsndEBm2topTF2wvTSqF
	RnkryeZuAXCvtSgJkCdOo/euEFynM3AvYIH6KOw1oOv/vjbv68bdyrNRTpnukfocv2sH7zbMarK
	QRmbCJqgYxNS6BvqqmVs7KhyLNQq3cGkwMinEH8tH/Pk8JA3IadeyAhPdHE7CBgMz3Q==
X-Received: by 2002:a62:3047:: with SMTP id w68mr48031090pfw.17.1553881659507;
        Fri, 29 Mar 2019 10:47:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuS/Qkug167ZVlZAv1t0qPixMs0kxYPWDdvuSy+5NYo3BHwqKuqgQ6fVAph8GUien+gdcr
X-Received: by 2002:a62:3047:: with SMTP id w68mr48031019pfw.17.1553881658421;
        Fri, 29 Mar 2019 10:47:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553881658; cv=none;
        d=google.com; s=arc-20160816;
        b=QC8taqGCBIfYqL64wn9Xp42azpqb1jV+I4J4I0UXlD8sxPW/5yENhele7ra3pUYQDN
         E4VTugsj6P8YDJqc2n0F3w1GNekqoX+MIxz3YHkKOYa9u0+i6rn6KEDlc/fCZU/5ckH0
         XdsYgPqvVosQ4i4h5x+VNpk30IOLzYr9O8t6EkFy70BJLoaPbsyz+b3CB/bP8DpKHmuw
         Qwk6WkwG+NQMjQp0Rzbl/0FpCvFgNTOXNtCVqHPJTQE9X7tOzM1cYl/XRfOX0COU6Bds
         t7bEWNCOuPjBJmzPANtAOyATIEks3DgLrsfPGHd3Tvq84CG85xDaYt40gsT7HuiJ852e
         JiHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=w9iAm9mtRGL0c6b4Qv9pOcaRgs1GRlLTUXZ07VKuonU=;
        b=yarjoXKSGMwswx1pdTPHTqPEiCLAo0r/4Gmu+U6rUo/kPHMwg3fJQgHEF5t+/TQuo3
         lpLfpeStng0xFa6LjdzRtog4gFPdkzMbISVtS2F5z23g9mQjurbf0X02H/DbimjqkJFA
         dSeGNws7LFE6moKkAD9cHuf5hlEjNhNheTxJXNo+uexxyALWwxM9xzof/5938dsvLc2k
         O72DQrXbGvtPPz0f7f8wiq5FvuuetG1rmgPhguU1WiW2nuiNplC9+LPJUiiBppQzyU7k
         rSmDNhTlYDzXq0fHYbiayS/R6I6MamsU7hMT00hKnCz+SXkg+N+HARLxe1yphav+jrWp
         B/Yw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 124si2323026pfw.148.2019.03.29.10.47.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 10:47:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Mar 2019 10:47:37 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,285,1549958400"; 
   d="scan'208";a="333270212"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga005.fm.intel.com with ESMTP; 29 Mar 2019 10:47:37 -0700
Date: Fri, 29 Mar 2019 02:46:31 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Logan Gunthorpe <logang@deltatee.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org,
	linux-pci@vger.kernel.org, linux-nvdimm@lists.01.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 6/6] mm/devm_memremap_pages: Fix final page put race
Message-ID: <20190329094630.GA6024@iweiny-DESK2.sc.intel.com>
References: <155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155387327591.2443841.1024616899609926902.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <155387327591.2443841.1024616899609926902.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 08:27:55AM -0700, Dan Williams wrote:
> Logan noticed that devm_memremap_pages_release() kills the percpu_ref
> drops all the page references that were acquired at init and then
> immediately proceeds to unplug, arch_remove_memory(), the backing pages
> for the pagemap. If for some reason device shutdown actually collides
> with a busy / elevated-ref-count page then arch_remove_memory() should
> be deferred until after that reference is dropped.
> 
> As it stands the "wait for last page ref drop" happens *after*
> devm_memremap_pages_release() returns, which is obviously too late and
> can lead to crashes.
> 
> Fix this situation by assigning the responsibility to wait for the
> percpu_ref to go idle to devm_memremap_pages() with a new ->cleanup()
> callback. Implement the new cleanup callback for all
> devm_memremap_pages() users: pmem, devdax, hmm, and p2pdma.
> 
> Reported-by: Logan Gunthorpe <logang@deltatee.com>
> Fixes: 41e94a851304 ("add devm_memremap_pages")
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Bjorn Helgaas <bhelgaas@google.com>
> Cc: "Jérôme Glisse" <jglisse@redhat.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

For the series:

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> ---
>  drivers/dax/device.c              |   13 +++----------
>  drivers/nvdimm/pmem.c             |   17 +++++++++++++----
>  drivers/pci/p2pdma.c              |   17 +++--------------
>  include/linux/memremap.h          |    2 ++
>  kernel/memremap.c                 |   17 ++++++++++++-----
>  mm/hmm.c                          |   14 +++-----------
>  tools/testing/nvdimm/test/iomap.c |    2 ++
>  7 files changed, 38 insertions(+), 44 deletions(-)
> 
> diff --git a/drivers/dax/device.c b/drivers/dax/device.c
> index e428468ab661..e3aa78dd1bb0 100644
> --- a/drivers/dax/device.c
> +++ b/drivers/dax/device.c
> @@ -27,9 +27,8 @@ static void dev_dax_percpu_release(struct percpu_ref *ref)
>  	complete(&dev_dax->cmp);
>  }
>  
> -static void dev_dax_percpu_exit(void *data)
> +static void dev_dax_percpu_exit(struct percpu_ref *ref)
>  {
> -	struct percpu_ref *ref = data;
>  	struct dev_dax *dev_dax = ref_to_dev_dax(ref);
>  
>  	dev_dbg(&dev_dax->dev, "%s\n", __func__);
> @@ -468,18 +467,12 @@ int dev_dax_probe(struct device *dev)
>  	if (rc)
>  		return rc;
>  
> -	rc = devm_add_action_or_reset(dev, dev_dax_percpu_exit, &dev_dax->ref);
> -	if (rc)
> -		return rc;
> -
>  	dev_dax->pgmap.ref = &dev_dax->ref;
>  	dev_dax->pgmap.kill = dev_dax_percpu_kill;
> +	dev_dax->pgmap.cleanup = dev_dax_percpu_exit;
>  	addr = devm_memremap_pages(dev, &dev_dax->pgmap);
> -	if (IS_ERR(addr)) {
> -		devm_remove_action(dev, dev_dax_percpu_exit, &dev_dax->ref);
> -		percpu_ref_exit(&dev_dax->ref);
> +	if (IS_ERR(addr))
>  		return PTR_ERR(addr);
> -	}
>  
>  	inode = dax_inode(dax_dev);
>  	cdev = inode->i_cdev;
> diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
> index bc2f700feef8..507b9eda42aa 100644
> --- a/drivers/nvdimm/pmem.c
> +++ b/drivers/nvdimm/pmem.c
> @@ -304,11 +304,19 @@ static const struct attribute_group *pmem_attribute_groups[] = {
>  	NULL,
>  };
>  
> -static void pmem_release_queue(void *q)
> +static void __pmem_release_queue(struct percpu_ref *ref)
>  {
> +	struct request_queue *q;
> +
> +	q = container_of(ref, typeof(*q), q_usage_counter);
>  	blk_cleanup_queue(q);
>  }
>  
> +static void pmem_release_queue(void *ref)
> +{
> +	__pmem_release_queue(ref);
> +}
> +
>  static void pmem_freeze_queue(struct percpu_ref *ref)
>  {
>  	struct request_queue *q;
> @@ -400,12 +408,10 @@ static int pmem_attach_disk(struct device *dev,
>  	if (!q)
>  		return -ENOMEM;
>  
> -	if (devm_add_action_or_reset(dev, pmem_release_queue, q))
> -		return -ENOMEM;
> -
>  	pmem->pfn_flags = PFN_DEV;
>  	pmem->pgmap.ref = &q->q_usage_counter;
>  	pmem->pgmap.kill = pmem_freeze_queue;
> +	pmem->pgmap.cleanup = __pmem_release_queue;
>  	if (is_nd_pfn(dev)) {
>  		if (setup_pagemap_fsdax(dev, &pmem->pgmap))
>  			return -ENOMEM;
> @@ -426,6 +432,9 @@ static int pmem_attach_disk(struct device *dev,
>  		pmem->pfn_flags |= PFN_MAP;
>  		memcpy(&bb_res, &pmem->pgmap.res, sizeof(bb_res));
>  	} else {
> +		if (devm_add_action_or_reset(dev, pmem_release_queue,
> +					&q->q_usage_counter))
> +			return -ENOMEM;
>  		addr = devm_memremap(dev, pmem->phys_addr,
>  				pmem->size, ARCH_MEMREMAP_PMEM);
>  		memcpy(&bb_res, &nsio->res, sizeof(bb_res));
> diff --git a/drivers/pci/p2pdma.c b/drivers/pci/p2pdma.c
> index 1b96c1688715..7ff5b8067670 100644
> --- a/drivers/pci/p2pdma.c
> +++ b/drivers/pci/p2pdma.c
> @@ -95,7 +95,7 @@ static void pci_p2pdma_percpu_kill(struct percpu_ref *ref)
>  	percpu_ref_kill(ref);
>  }
>  
> -static void pci_p2pdma_percpu_cleanup(void *ref)
> +static void pci_p2pdma_percpu_cleanup(struct percpu_ref *ref)
>  {
>  	struct p2pdma_pagemap *p2p_pgmap = to_p2p_pgmap(ref);
>  
> @@ -197,16 +197,6 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
>  	if (error)
>  		goto pgmap_free;
>  
> -	/*
> -	 * FIXME: the percpu_ref_exit needs to be coordinated internal
> -	 * to devm_memremap_pages_release(). Duplicate the same ordering
> -	 * as other devm_memremap_pages() users for now.
> -	 */
> -	error = devm_add_action(&pdev->dev, pci_p2pdma_percpu_cleanup,
> -			&p2p_pgmap->ref);
> -	if (error)
> -		goto ref_cleanup;
> -
>  	pgmap = &p2p_pgmap->pgmap;
>  
>  	pgmap->res.start = pci_resource_start(pdev, bar) + offset;
> @@ -217,11 +207,12 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
>  	pgmap->pci_p2pdma_bus_offset = pci_bus_address(pdev, bar) -
>  		pci_resource_start(pdev, bar);
>  	pgmap->kill = pci_p2pdma_percpu_kill;
> +	pgmap->cleanup = pci_p2pdma_percpu_cleanup;
>  
>  	addr = devm_memremap_pages(&pdev->dev, pgmap);
>  	if (IS_ERR(addr)) {
>  		error = PTR_ERR(addr);
> -		goto ref_exit;
> +		goto pgmap_free;
>  	}
>  
>  	error = gen_pool_add_owner(pdev->p2pdma->pool, (unsigned long)addr,
> @@ -238,8 +229,6 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
>  
>  pages_free:
>  	devm_memunmap_pages(&pdev->dev, pgmap);
> -ref_cleanup:
> -	percpu_ref_exit(&p2p_pgmap->ref);
>  pgmap_free:
>  	devm_kfree(&pdev->dev, p2p_pgmap);
>  	return error;
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index 7601ee314c4a..1732dea030b2 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -81,6 +81,7 @@ typedef void (*dev_page_free_t)(struct page *page, void *data);
>   * @res: physical address range covered by @ref
>   * @ref: reference count that pins the devm_memremap_pages() mapping
>   * @kill: callback to transition @ref to the dead state
> + * @cleanup: callback to wait for @ref to be idle and reap it
>   * @dev: host device of the mapping for debug
>   * @data: private data pointer for page_free()
>   * @type: memory type: see MEMORY_* in memory_hotplug.h
> @@ -92,6 +93,7 @@ struct dev_pagemap {
>  	struct resource res;
>  	struct percpu_ref *ref;
>  	void (*kill)(struct percpu_ref *ref);
> +	void (*cleanup)(struct percpu_ref *ref);
>  	struct device *dev;
>  	void *data;
>  	enum memory_type type;
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 65afbacab44e..05d1af5a2f15 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -96,6 +96,7 @@ static void devm_memremap_pages_release(void *data)
>  	pgmap->kill(pgmap->ref);
>  	for_each_device_pfn(pfn, pgmap)
>  		put_page(pfn_to_page(pfn));
> +	pgmap->cleanup(pgmap->ref);
>  
>  	/* pages are dead and unused, undo the arch mapping */
>  	align_start = res->start & ~(SECTION_SIZE - 1);
> @@ -134,8 +135,8 @@ static void devm_memremap_pages_release(void *data)
>   * 2/ The altmap field may optionally be initialized, in which case altmap_valid
>   *    must be set to true
>   *
> - * 3/ pgmap->ref must be 'live' on entry and will be killed at
> - *    devm_memremap_pages_release() time, or if this routine fails.
> + * 3/ pgmap->ref must be 'live' on entry and will be killed and reaped
> + *    at devm_memremap_pages_release() time, or if this routine fails.
>   *
>   * 4/ res is expected to be a host memory range that could feasibly be
>   *    treated as a "System RAM" range, i.e. not a device mmio range, but
> @@ -151,8 +152,10 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  	pgprot_t pgprot = PAGE_KERNEL;
>  	int error, nid, is_ram;
>  
> -	if (!pgmap->ref || !pgmap->kill)
> +	if (!pgmap->ref || !pgmap->kill || !pgmap->cleanup) {
> +		WARN(1, "Missing reference count teardown definition\n");
>  		return ERR_PTR(-EINVAL);
> +	}
>  
>  	align_start = res->start & ~(SECTION_SIZE - 1);
>  	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
> @@ -163,14 +166,16 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  	if (conflict_pgmap) {
>  		dev_WARN(dev, "Conflicting mapping in same section\n");
>  		put_dev_pagemap(conflict_pgmap);
> -		return ERR_PTR(-ENOMEM);
> +		error = -ENOMEM;
> +		goto err_array;
>  	}
>  
>  	conflict_pgmap = get_dev_pagemap(PHYS_PFN(align_end), NULL);
>  	if (conflict_pgmap) {
>  		dev_WARN(dev, "Conflicting mapping in same section\n");
>  		put_dev_pagemap(conflict_pgmap);
> -		return ERR_PTR(-ENOMEM);
> +		error = -ENOMEM;
> +		goto err_array;
>  	}
>  
>  	is_ram = region_intersects(align_start, align_size,
> @@ -262,6 +267,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  	pgmap_array_delete(res);
>   err_array:
>  	pgmap->kill(pgmap->ref);
> +	pgmap->cleanup(pgmap->ref);
> +
>  	return ERR_PTR(error);
>  }
>  EXPORT_SYMBOL_GPL(devm_memremap_pages);
> diff --git a/mm/hmm.c b/mm/hmm.c
> index fe1cd87e49ac..225ade644058 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -975,9 +975,8 @@ static void hmm_devmem_ref_release(struct percpu_ref *ref)
>  	complete(&devmem->completion);
>  }
>  
> -static void hmm_devmem_ref_exit(void *data)
> +static void hmm_devmem_ref_exit(struct percpu_ref *ref)
>  {
> -	struct percpu_ref *ref = data;
>  	struct hmm_devmem *devmem;
>  
>  	devmem = container_of(ref, struct hmm_devmem, ref);
> @@ -1054,10 +1053,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
>  	if (ret)
>  		return ERR_PTR(ret);
>  
> -	ret = devm_add_action_or_reset(device, hmm_devmem_ref_exit, &devmem->ref);
> -	if (ret)
> -		return ERR_PTR(ret);
> -
>  	size = ALIGN(size, PA_SECTION_SIZE);
>  	addr = min((unsigned long)iomem_resource.end,
>  		   (1UL << MAX_PHYSMEM_BITS) - 1);
> @@ -1096,6 +1091,7 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
>  	devmem->pagemap.ref = &devmem->ref;
>  	devmem->pagemap.data = devmem;
>  	devmem->pagemap.kill = hmm_devmem_ref_kill;
> +	devmem->pagemap.cleanup = hmm_devmem_ref_exit;
>  
>  	result = devm_memremap_pages(devmem->device, &devmem->pagemap);
>  	if (IS_ERR(result))
> @@ -1133,11 +1129,6 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
>  	if (ret)
>  		return ERR_PTR(ret);
>  
> -	ret = devm_add_action_or_reset(device, hmm_devmem_ref_exit,
> -			&devmem->ref);
> -	if (ret)
> -		return ERR_PTR(ret);
> -
>  	devmem->pfn_first = devmem->resource->start >> PAGE_SHIFT;
>  	devmem->pfn_last = devmem->pfn_first +
>  			   (resource_size(devmem->resource) >> PAGE_SHIFT);
> @@ -1150,6 +1141,7 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
>  	devmem->pagemap.ref = &devmem->ref;
>  	devmem->pagemap.data = devmem;
>  	devmem->pagemap.kill = hmm_devmem_ref_kill;
> +	devmem->pagemap.cleanup = hmm_devmem_ref_exit;
>  
>  	result = devm_memremap_pages(devmem->device, &devmem->pagemap);
>  	if (IS_ERR(result))
> diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
> index c6635fee27d8..219dd0a1cb08 100644
> --- a/tools/testing/nvdimm/test/iomap.c
> +++ b/tools/testing/nvdimm/test/iomap.c
> @@ -108,7 +108,9 @@ static void nfit_test_kill(void *_pgmap)
>  {
>  	struct dev_pagemap *pgmap = _pgmap;
>  
> +	WARN_ON(!pgmap || !pgmap->ref || !pgmap->kill || !pgmap->cleanup);
>  	pgmap->kill(pgmap->ref);
> +	pgmap->cleanup(pgmap->ref);
>  }
>  
>  void *__wrap_devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
> 

