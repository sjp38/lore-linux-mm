Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21468C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 17:40:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C100120717
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 17:40:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C100120717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7728F6B0008; Tue,  6 Aug 2019 13:40:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 721926B000A; Tue,  6 Aug 2019 13:40:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EA3A6B000C; Tue,  6 Aug 2019 13:40:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2656B6B0008
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 13:40:21 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 145so56349323pfw.16
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 10:40:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Vs4zormtri2zMSHG4XyrvuMjcO2hY2E78NXVryq5r2A=;
        b=ryo2qvotWCldzVCE6PCvByRlxXRi6ROT6dC1tFkICu0PQlKl6zmrmWkaHiDAiI++v0
         sk76pTkVlR0K44oG2bAYxzmDr+Bqute+cHIgX66fGDrIsOdnmeHbRbtgsUh49zOghCRl
         Ya0xUG4HK+fO95auPixmfKINdY7CYI644dwkSAky/LJz5ixuX5s4oAk5d06LNP0FnJew
         z5ZwpbsEpNo5nDKr83Tc3EorC8p0BOahEMer/e1VwVd04pMkHPirAba3m/igFtZzh66x
         WaaxjBeSYsLF7ed0sj5ponPiuCz2kgooxHgu27RW/ehUrq+x21HNMSObHsCuwxovdf+5
         +I1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU59lHrxth58prorSvpoL24Y12BYWgo+4vh/xobP4lghr4A5fHG
	clmpqwsG44CJwSVi4KArN2vLLXP5S0IuZdZDTX9vlGxy2OotRt5ywsVG07M/U/r1JhguP7W0s2l
	PzkGmSk1MkrZ+MD1/kiglfPPwomWE4biCVc75PZIeSfdCKe03Zw+ZnwNm0x34TzH+VA==
X-Received: by 2002:a17:902:76c6:: with SMTP id j6mr4294126plt.102.1565113220638;
        Tue, 06 Aug 2019 10:40:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKlZ43NwfHZSlw3oiRcw2Bpl/uFnkRJ3SXaMcsrd8kbz2pVeEUuE3O6ckZvIW/oQMZcW2H
X-Received: by 2002:a17:902:76c6:: with SMTP id j6mr4294075plt.102.1565113219767;
        Tue, 06 Aug 2019 10:40:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565113219; cv=none;
        d=google.com; s=arc-20160816;
        b=VlRME90T8RMUCV1WdLMzs8QbZ5HZAlvUeD8nzIHvEErBNNRVc7H/uAwN+pCI9Qi35P
         Un2IPYNx/ppSuj/XzE0cna57r1KuNbI/69qShxIEGFLwi0nVXFd/r/bRQf5D7EA3nctF
         hccqRupZ/OCQffyPniKO+OO36lr8JjdEPHXzo8FMwcJQPq81HXibLKVt+zdeigJy1Qyu
         W2gRjiowb7TH7VNi1xNbQpC92aHCj9PvQvzoeJyZKwaTceuT4kmlmzkaQ0zwOiSySmqT
         B7XvntzYyWcAwBSPrmnvWzaaOTe+/nkODl2F9l4v900f8ovbDzDHdGcIAwqhv3nS7G5S
         5V4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Vs4zormtri2zMSHG4XyrvuMjcO2hY2E78NXVryq5r2A=;
        b=OFpbZ1yNuNXQqBcXngDv2FI+Ay0IN2gIixH7qSXDzfWqfILWKH68AlYAjBuIDb9wl9
         9zotYSBQ3iWv9rsbP1INWIV1kPBzc2Ck/+LHtTrlSTx9coQFecJS6k7ihcj53nYQ1KlH
         jzsYiomZjm7umP2g+ObVopkXA7pWMnPQl6mxv7pmjHpjOqRJydQNZOxd7glwUSIjj1E9
         vfX0g8q28Xk23kG3MOkRfUHDYlsoxQwgfbm2MkNFiJbzEejLWAF0inD9otJcPxXKBJCJ
         dcO2nf4xiImKGDHuXyuHYSDJ9VtraaamOVjtYeQ+TCYxQCZl6yTEvEYxwuZX6TGMj9J+
         qlOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a63si43935858pla.348.2019.08.06.10.40.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 10:40:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Aug 2019 10:40:19 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,353,1559545200"; 
   d="scan'208";a="168363539"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga008.jf.intel.com with ESMTP; 06 Aug 2019 10:40:17 -0700
Date: Tue, 6 Aug 2019 10:40:17 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	=?iso-8859-1?Q?Bj=F6rn_T=F6pel?= <bjorn.topel@intel.com>,
	Boaz Harrosh <boaz@plexistor.com>, Christoph Hellwig <hch@lst.de>,
	Daniel Vetter <daniel@ffwll.ch>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>, David Airlie <airlied@linux.ie>,
	"David S . Miller" <davem@davemloft.net>,
	Ilya Dryomov <idryomov@gmail.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jens Axboe <axboe@kernel.dk>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Magnus Karlsson <magnus.karlsson@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <miklos@szeredi.hu>, Ming Lei <ming.lei@redhat.com>,
	Sage Weil <sage@redhat.com>,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>,
	Yan Zheng <zyan@redhat.com>, netdev@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-mm@kvack.org,
	linux-rdma@vger.kernel.org, bpf@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v6 1/3] mm/gup: add make_dirty arg to
 put_user_pages_dirty_lock()
Message-ID: <20190806174017.GB4748@iweiny-DESK2.sc.intel.com>
References: <20190804214042.4564-1-jhubbard@nvidia.com>
 <20190804214042.4564-2-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190804214042.4564-2-jhubbard@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 04, 2019 at 02:40:40PM -0700, john.hubbard@gmail.com wrote:
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

I assume this is superseded by the patch in the large series?

Ira

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

