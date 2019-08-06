Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFC71C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 17:39:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BABE20717
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 17:39:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BABE20717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A16C6B0007; Tue,  6 Aug 2019 13:39:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 353346B0008; Tue,  6 Aug 2019 13:39:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F4376B000A; Tue,  6 Aug 2019 13:39:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D68E66B0007
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 13:39:48 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 28so4846837pgm.12
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 10:39:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=c6BG0Km/Tslaw/+Xwtlcret2Xibp1hCoRdnt5yzUBsM=;
        b=YVRJwFq/Dvz1wss/IsDZyLxxEXvumxTzdhcyylOO+1i3FaQIotRXPNgxWKPSgnn6o7
         Msv8nCPCpOcB9IJmeCziMxcwAnRpim7wYkAtG41F17S9rCif3HEhRub10mzADiPBSs+a
         X4J3yEvWr+gLGR/hSflK9tHc99IIK6MqsQKwUUVTSRnWnVN+stCVoSmfvdEfbtg6xz/k
         kGeTRknfTRXPL5tLGmLRd3c1ysUi760j78my+8m6v3g9pZXE6lus9hZntJCsNI5dytSZ
         JUWidAKKWYFtVwI0jMINJ3KDe/2JaArk/WnEN1tcONwv8ywfpfiTkC1ucu8BArWuczgW
         OPjg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVox4Y3VZPledLQ52wYBPTigY5UU8WpDN0Z4UWfbDqhFeMQwHtC
	gsjNNL8C2T5IIKdArtYQShmJetiUf8M/FpiiWQJNjIxkUW7LxnllAipbx6e/H8mH576gloTm69Y
	va4rGY+AJJkbXUcZtwDs/AKFd6Lop1TGCGqNMnZYpjJExuOcfFUm87N8JeqGUOJtabA==
X-Received: by 2002:a65:4808:: with SMTP id h8mr4048914pgs.22.1565113188261;
        Tue, 06 Aug 2019 10:39:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxDIlFzU5oVp56NtJKHlE9VrGeG6ucmof1s5JP5U63SOD2Vf+Gljtcs4q6jM6o7X+3dTYG
X-Received: by 2002:a65:4808:: with SMTP id h8mr4048860pgs.22.1565113187261;
        Tue, 06 Aug 2019 10:39:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565113187; cv=none;
        d=google.com; s=arc-20160816;
        b=EAVT94wbCDOxuUHodr2tbLwIwm3+MPQ4BmkWGHYt/zorwscwTbRI0Hxsw0I9DkGpar
         3HDXAgEGD3YZaIJppubPRXJ6Ae+XkR8hWl9ubco0g+AQYKeS9BpaHcgfsK5VTKwIgDrR
         w7E5JeDToBTJh7pxcf6dFD35A1gHVLgu6HL1x/I5VwxYYAwhJ3542STEXzNmhptm+/8a
         KlWdzyrhMF+GaDpZKm72pfugGoOeDZLV/Ne8JrtPxhCLviRKca62JJZapq/iwbu+E8xB
         gjiJfo83+FHelWZNa4RqCn4TsEIseq9rj1mCt8EaPmRrr/z21JkeJHK2vKLZk636cNVP
         kveg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=c6BG0Km/Tslaw/+Xwtlcret2Xibp1hCoRdnt5yzUBsM=;
        b=H/7GjzPSl0la09kf6UpbmyohApFcAPZXZjXPc5ZfOicpIl82ZOQiDaK3I7nUAIlF1d
         LQdNcqijMLDe9Oypr5HFGyxy4233HOwPtcHD2e5hFIVIWPmuF+UaS9TClxforKPRODNn
         hB5+MIQ2cUA72Yu0r8ztMN7QX4n8tCpNkzHJ36GBVtsuI6LogBpUitkBimpmTOMkfIra
         kNOxzFiGmVTKI2cO1pfro/CMyJ3EmncFnNLmgkiJNqohf/M0G8HWUKrLu4XDUOWEwLmT
         Buq9VjgINBGgraWEum+vZarapEEjT3SfgcvWKZ0/Xuiv60b8D7vzXEMSu34jgzZTY3tS
         lyfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id j18si14959227pjn.42.2019.08.06.10.39.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 10:39:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Aug 2019 10:39:46 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,353,1559545200"; 
   d="scan'208";a="174242846"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga008.fm.intel.com with ESMTP; 06 Aug 2019 10:39:46 -0700
Date: Tue, 6 Aug 2019 10:39:46 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org, devel@driverdev.osuosl.org,
	devel@lists.orangefs.org, dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org, linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-media@vger.kernel.org,
	linux-mm@kvack.org, linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, sparclinux@vger.kernel.org,
	x86@kernel.org, xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>, Christoph Hellwig <hch@lst.de>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 01/34] mm/gup: add make_dirty arg to
 put_user_pages_dirty_lock()
Message-ID: <20190806173945.GA4748@iweiny-DESK2.sc.intel.com>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
 <20190804224915.28669-2-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190804224915.28669-2-jhubbard@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 04, 2019 at 03:48:42PM -0700, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> Provide a more capable variation of put_user_pages_dirty_lock(),
> and delete put_user_pages_dirty(). This is based on the
> following:
> 
> 1. Lots of call sites become simpler if a bool is passed
> into put_user_page*(), instead of making the call site
> choose which put_user_page*() variant to call.
> 
> 2. Christoph Hellwig's observation that set_page_dirty_lock()
> is usually correct, and set_page_dirty() is usually a
> bug, or at least questionable, within a put_user_page*()
> calling chain.
> 
> This leads to the following API choices:
> 
>     * put_user_pages_dirty_lock(page, npages, make_dirty)
> 
>     * There is no put_user_pages_dirty(). You have to
>       hand code that, in the rare case that it's
>       required.
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
>  drivers/infiniband/core/umem.c             |   5 +-
>  drivers/infiniband/hw/hfi1/user_pages.c    |   5 +-
>  drivers/infiniband/hw/qib/qib_user_pages.c |  13 +--
>  drivers/infiniband/hw/usnic/usnic_uiom.c   |   5 +-
>  drivers/infiniband/sw/siw/siw_mem.c        |  19 +---
>  include/linux/mm.h                         |   5 +-
>  mm/gup.c                                   | 115 +++++++++------------
>  7 files changed, 61 insertions(+), 106 deletions(-)
> 
> diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
> index 08da840ed7ee..965cf9dea71a 100644
> --- a/drivers/infiniband/core/umem.c
> +++ b/drivers/infiniband/core/umem.c
> @@ -54,10 +54,7 @@ static void __ib_umem_release(struct ib_device *dev, struct ib_umem *umem, int d
>  
>  	for_each_sg_page(umem->sg_head.sgl, &sg_iter, umem->sg_nents, 0) {
>  		page = sg_page_iter_page(&sg_iter);
> -		if (umem->writable && dirty)
> -			put_user_pages_dirty_lock(&page, 1);
> -		else
> -			put_user_page(page);
> +		put_user_pages_dirty_lock(&page, 1, umem->writable && dirty);
>  	}
>  
>  	sg_free_table(&umem->sg_head);
> diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
> index b89a9b9aef7a..469acb961fbd 100644
> --- a/drivers/infiniband/hw/hfi1/user_pages.c
> +++ b/drivers/infiniband/hw/hfi1/user_pages.c
> @@ -118,10 +118,7 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
>  void hfi1_release_user_pages(struct mm_struct *mm, struct page **p,
>  			     size_t npages, bool dirty)
>  {
> -	if (dirty)
> -		put_user_pages_dirty_lock(p, npages);
> -	else
> -		put_user_pages(p, npages);
> +	put_user_pages_dirty_lock(p, npages, dirty);
>  
>  	if (mm) { /* during close after signal, mm can be NULL */
>  		atomic64_sub(npages, &mm->pinned_vm);
> diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
> index bfbfbb7e0ff4..26c1fb8d45cc 100644
> --- a/drivers/infiniband/hw/qib/qib_user_pages.c
> +++ b/drivers/infiniband/hw/qib/qib_user_pages.c
> @@ -37,15 +37,6 @@
>  
>  #include "qib.h"
>  
> -static void __qib_release_user_pages(struct page **p, size_t num_pages,
> -				     int dirty)
> -{
> -	if (dirty)
> -		put_user_pages_dirty_lock(p, num_pages);
> -	else
> -		put_user_pages(p, num_pages);
> -}
> -
>  /**
>   * qib_map_page - a safety wrapper around pci_map_page()
>   *
> @@ -124,7 +115,7 @@ int qib_get_user_pages(unsigned long start_page, size_t num_pages,
>  
>  	return 0;
>  bail_release:
> -	__qib_release_user_pages(p, got, 0);
> +	put_user_pages_dirty_lock(p, got, false);
>  bail:
>  	atomic64_sub(num_pages, &current->mm->pinned_vm);
>  	return ret;
> @@ -132,7 +123,7 @@ int qib_get_user_pages(unsigned long start_page, size_t num_pages,
>  
>  void qib_release_user_pages(struct page **p, size_t num_pages)
>  {
> -	__qib_release_user_pages(p, num_pages, 1);
> +	put_user_pages_dirty_lock(p, num_pages, true);
>  
>  	/* during close after signal, mm can be NULL */
>  	if (current->mm)
> diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
> index 0b0237d41613..62e6ffa9ad78 100644
> --- a/drivers/infiniband/hw/usnic/usnic_uiom.c
> +++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
> @@ -75,10 +75,7 @@ static void usnic_uiom_put_pages(struct list_head *chunk_list, int dirty)
>  		for_each_sg(chunk->page_list, sg, chunk->nents, i) {
>  			page = sg_page(sg);
>  			pa = sg_phys(sg);
> -			if (dirty)
> -				put_user_pages_dirty_lock(&page, 1);
> -			else
> -				put_user_page(page);
> +			put_user_pages_dirty_lock(&page, 1, dirty);
>  			usnic_dbg("pa: %pa\n", &pa);
>  		}
>  		kfree(chunk);
> diff --git a/drivers/infiniband/sw/siw/siw_mem.c b/drivers/infiniband/sw/siw/siw_mem.c
> index 67171c82b0c4..1e197753bf2f 100644
> --- a/drivers/infiniband/sw/siw/siw_mem.c
> +++ b/drivers/infiniband/sw/siw/siw_mem.c
> @@ -60,20 +60,6 @@ struct siw_mem *siw_mem_id2obj(struct siw_device *sdev, int stag_index)
>  	return NULL;
>  }
>  
> -static void siw_free_plist(struct siw_page_chunk *chunk, int num_pages,
> -			   bool dirty)
> -{
> -	struct page **p = chunk->plist;
> -
> -	while (num_pages--) {
> -		if (!PageDirty(*p) && dirty)
> -			put_user_pages_dirty_lock(p, 1);
> -		else
> -			put_user_page(*p);
> -		p++;
> -	}
> -}
> -
>  void siw_umem_release(struct siw_umem *umem, bool dirty)
>  {
>  	struct mm_struct *mm_s = umem->owning_mm;
> @@ -82,8 +68,9 @@ void siw_umem_release(struct siw_umem *umem, bool dirty)
>  	for (i = 0; num_pages; i++) {
>  		int to_free = min_t(int, PAGES_PER_CHUNK, num_pages);
>  
> -		siw_free_plist(&umem->page_chunk[i], to_free,
> -			       umem->writable && dirty);
> +		put_user_pages_dirty_lock(umem->page_chunk[i].plist,
> +					  to_free,
> +					  umem->writable && dirty);
>  		kfree(umem->page_chunk[i].plist);
>  		num_pages -= to_free;
>  	}
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0334ca97c584..9759b6a24420 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1057,8 +1057,9 @@ static inline void put_user_page(struct page *page)
>  	put_page(page);
>  }
>  
> -void put_user_pages_dirty(struct page **pages, unsigned long npages);
> -void put_user_pages_dirty_lock(struct page **pages, unsigned long npages);
> +void put_user_pages_dirty_lock(struct page **pages, unsigned long npages,
> +			       bool make_dirty);
> +
>  void put_user_pages(struct page **pages, unsigned long npages);
>  
>  #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
> diff --git a/mm/gup.c b/mm/gup.c
> index 98f13ab37bac..7fefd7ab02c4 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -29,85 +29,70 @@ struct follow_page_context {
>  	unsigned int page_mask;
>  };
>  
> -typedef int (*set_dirty_func_t)(struct page *page);
> -
> -static void __put_user_pages_dirty(struct page **pages,
> -				   unsigned long npages,
> -				   set_dirty_func_t sdf)
> -{
> -	unsigned long index;
> -
> -	for (index = 0; index < npages; index++) {
> -		struct page *page = compound_head(pages[index]);
> -
> -		/*
> -		 * Checking PageDirty at this point may race with
> -		 * clear_page_dirty_for_io(), but that's OK. Two key cases:
> -		 *
> -		 * 1) This code sees the page as already dirty, so it skips
> -		 * the call to sdf(). That could happen because
> -		 * clear_page_dirty_for_io() called page_mkclean(),
> -		 * followed by set_page_dirty(). However, now the page is
> -		 * going to get written back, which meets the original
> -		 * intention of setting it dirty, so all is well:
> -		 * clear_page_dirty_for_io() goes on to call
> -		 * TestClearPageDirty(), and write the page back.
> -		 *
> -		 * 2) This code sees the page as clean, so it calls sdf().
> -		 * The page stays dirty, despite being written back, so it
> -		 * gets written back again in the next writeback cycle.
> -		 * This is harmless.
> -		 */
> -		if (!PageDirty(page))
> -			sdf(page);
> -
> -		put_user_page(page);
> -	}
> -}
> -
>  /**
> - * put_user_pages_dirty() - release and dirty an array of gup-pinned pages
> - * @pages:  array of pages to be marked dirty and released.
> + * put_user_pages_dirty_lock() - release and optionally dirty gup-pinned pages
> + * @pages:  array of pages to be maybe marked dirty, and definitely released.

Better would be.

@pages:  array of pages to be put

>   * @npages: number of pages in the @pages array.
> + * @make_dirty: whether to mark the pages dirty
>   *
>   * "gup-pinned page" refers to a page that has had one of the get_user_pages()
>   * variants called on that page.
>   *
>   * For each page in the @pages array, make that page (or its head page, if a
> - * compound page) dirty, if it was previously listed as clean. Then, release
> - * the page using put_user_page().
> + * compound page) dirty, if @make_dirty is true, and if the page was previously
> + * listed as clean. In any case, releases all pages using put_user_page(),
> + * possibly via put_user_pages(), for the non-dirty case.

I don't think users of this interface need this level of detail.  I think
something like.

 * For each page in the @pages array, release the page.  If @make_dirty is
 * true, mark the page dirty prior to release.


>   *
>   * Please see the put_user_page() documentation for details.
>   *
> - * set_page_dirty(), which does not lock the page, is used here.
> - * Therefore, it is the caller's responsibility to ensure that this is
> - * safe. If not, then put_user_pages_dirty_lock() should be called instead.
> + * set_page_dirty_lock() is used internally. If instead, set_page_dirty() is
> + * required, then the caller should a) verify that this is really correct,
> + * because _lock() is usually required, and b) hand code it:
> + * set_page_dirty_lock(), put_user_page().
>   *
>   */
> -void put_user_pages_dirty(struct page **pages, unsigned long npages)
> +void put_user_pages_dirty_lock(struct page **pages, unsigned long npages,
> +			       bool make_dirty)
>  {
> -	__put_user_pages_dirty(pages, npages, set_page_dirty);
> -}
> -EXPORT_SYMBOL(put_user_pages_dirty);
> +	unsigned long index;
>  
> -/**
> - * put_user_pages_dirty_lock() - release and dirty an array of gup-pinned pages
> - * @pages:  array of pages to be marked dirty and released.
> - * @npages: number of pages in the @pages array.
> - *
> - * For each page in the @pages array, make that page (or its head page, if a
> - * compound page) dirty, if it was previously listed as clean. Then, release
> - * the page using put_user_page().
> - *
> - * Please see the put_user_page() documentation for details.
> - *
> - * This is just like put_user_pages_dirty(), except that it invokes
> - * set_page_dirty_lock(), instead of set_page_dirty().
> - *
> - */
> -void put_user_pages_dirty_lock(struct page **pages, unsigned long npages)
> -{
> -	__put_user_pages_dirty(pages, npages, set_page_dirty_lock);
> +	/*
> +	 * TODO: this can be optimized for huge pages: if a series of pages is
> +	 * physically contiguous and part of the same compound page, then a
> +	 * single operation to the head page should suffice.
> +	 */

I think this comment belongs to the for loop below...  or just something about
how to make this and put_user_pages() more efficient.  It is odd, that this is
the same comment as in put_user_pages()...

The code is good.  So... Other than the comments.

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

Ira

> +
> +	if (!make_dirty) {
> +		put_user_pages(pages, npages);
> +		return;
> +	}
> +
> +	for (index = 0; index < npages; index++) {
> +		struct page *page = compound_head(pages[index]);
> +		/*
> +		 * Checking PageDirty at this point may race with
> +		 * clear_page_dirty_for_io(), but that's OK. Two key
> +		 * cases:
> +		 *
> +		 * 1) This code sees the page as already dirty, so it
> +		 * skips the call to set_page_dirty(). That could happen
> +		 * because clear_page_dirty_for_io() called
> +		 * page_mkclean(), followed by set_page_dirty().
> +		 * However, now the page is going to get written back,
> +		 * which meets the original intention of setting it
> +		 * dirty, so all is well: clear_page_dirty_for_io() goes
> +		 * on to call TestClearPageDirty(), and write the page
> +		 * back.
> +		 *
> +		 * 2) This code sees the page as clean, so it calls
> +		 * set_page_dirty(). The page stays dirty, despite being
> +		 * written back, so it gets written back again in the
> +		 * next writeback cycle. This is harmless.
> +		 */
> +		if (!PageDirty(page))
> +			set_page_dirty_lock(page);
> +		put_user_page(page);
> +	}
>  }
>  EXPORT_SYMBOL(put_user_pages_dirty_lock);
>  
> -- 
> 2.22.0
> 

