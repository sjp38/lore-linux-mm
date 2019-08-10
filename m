Return-Path: <SRS0=GuKW=WG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8678DC433FF
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 00:30:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3186D214C6
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 00:30:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="YuSjKP4A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3186D214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B95A76B0005; Fri,  9 Aug 2019 20:30:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B46AA6B0006; Fri,  9 Aug 2019 20:30:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A34E56B0007; Fri,  9 Aug 2019 20:30:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7732A6B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 20:30:03 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x10so62521912pfa.23
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 17:30:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=b6l0EcXIqF+/G734s3cwMmTuz8hr26aRZITM0rTS7i0=;
        b=k8/7AEppx3VKOnRZZqDWvcy5BGLishoV484um+HjBEn79KOs/hG+4tGK6Vx8VLI31Z
         t126gMDGJeMRqHZUgMMa6ziv7kgRgZNVQV4EubqXQ4VgNdRypz71CEZeXZbMTeOiuIxz
         J6gRMrR6uMtWWxM5200JymXFMZqvNwju0VVE6yZwuleIBc1N4Umd3XcjxKzuHnr8U6QV
         ACEBcq6+iTczPHS+VXGo/7Y4WYUENiHw1KzSky7kJ7LWpcbIueba+AGbSHFzCAAimfSf
         ndVeaxUD60fREc6ohD54KCpnuKJMgraYUpCZE/LVndhnb7WnFmGyMio7U3J/Z8f4yASe
         B/Jg==
X-Gm-Message-State: APjAAAXMgMRfMD17xJEhHblJum89Zq00LB0VQUy/t0zvPSDrm12vjOch
	O8r3+YXxqnGLe+Zxw8rfhA3KXmaFrVXDmoaayZ7Xoiig4pB0NcwD9A1rg3MjZ+gsqCN7oovDM+5
	b4LBppYxsC+9yBKsfkYVT8QbUN9stYplclGAvd02ekYaBPAu5b2EAoHJv5I/rvM+20g==
X-Received: by 2002:a17:90a:c24e:: with SMTP id d14mr4608408pjx.129.1565397002984;
        Fri, 09 Aug 2019 17:30:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEuuArW/Bdc4u0pgo6vlYyzDIHxNCmFFsKVSf7QBYGnd6IqImoDlP4zX88Nn4kWB3m8y7p
X-Received: by 2002:a17:90a:c24e:: with SMTP id d14mr4608347pjx.129.1565397001946;
        Fri, 09 Aug 2019 17:30:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565397001; cv=none;
        d=google.com; s=arc-20160816;
        b=G1WS5XkfOCM7pRaE46gPhSuby0FDjuOg/9pbNn4jZCgWAVUcPw4nbrVvLXmGGHrmDs
         02tBIl2rBLi0XiE2JNlWfYvfg+yKmK2C9Lk4DY1QgXu+QQEZdCLCVbjyyNu+n4L33LMo
         gfIq50cw/nE2aYEonfDPHhgLxTqL41r/IHxmfBb2WAnqcCNlQ7pLljubV7/ehyzoW37n
         FnOcGm28T6f3jC49/bKhwofG1DNw9o1ALHZH/wQD8tGFhFficmoEJZp1wcAA5/N0x5TO
         RRMDcerAgVcWh9TNpqZ0igXUHFmRY10NwwpoR5pRoeQlRXHiJF2/kGISH8kq7fP/hRLh
         /t5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=b6l0EcXIqF+/G734s3cwMmTuz8hr26aRZITM0rTS7i0=;
        b=YL/SJE9sLwD7eA2qzErsrb27TJtNmYLU5frYwRPYwkzo1+SS8IqP5YHc6HJ7UDIDQb
         sg3rPpfuRcci/vV2v6/wLEj8TmkvHZ1lcB6ZBfxl5cOfP5m2UvYAAQv1ZFx9kpdReTNB
         e6JQFbqyF7AeYwxVblZCti59YRRSRFPuf03/XVIL73cf3vjo1Zl2rJKLvY8LdIBa6dxp
         i3AzzYo4a7BQ+C5QmPj5stxUDQV2eoOnUAH6/nJMNnHhzuNJ9zcvZs4vif4hzpzhjczV
         EIG0UMPfiQyHsYlgRmvyKlmtAig9it1mmhxWuKgu7/qKtw7O2E4+wvox5tzCR/zxpWtN
         1EsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YuSjKP4A;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id g7si53205681plt.244.2019.08.09.17.30.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 17:30:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=YuSjKP4A;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d4e100b0000>; Fri, 09 Aug 2019 17:30:03 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 09 Aug 2019 17:30:01 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 09 Aug 2019 17:30:01 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Sat, 10 Aug
 2019 00:30:00 +0000
Subject: Re: [RFC PATCH v2 12/19] mm/gup: Prep put_user_pages() to take an
 vaddr_pin struct
To: <ira.weiny@intel.com>, Andrew Morton <akpm@linux-foundation.org>
CC: Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Theodore Ts'o
	<tytso@mit.edu>, Michal Hocko <mhocko@suse.com>, Dave Chinner
	<david@fromorbit.com>, <linux-xfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <linux-nvdimm@lists.01.org>,
	<linux-ext4@vger.kernel.org>, <linux-mm@kvack.org>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-13-ira.weiny@intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <12b6a576-7a64-102c-f4d7-7a4ad34df710@nvidia.com>
Date: Fri, 9 Aug 2019 17:30:00 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809225833.6657-13-ira.weiny@intel.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565397003; bh=b6l0EcXIqF+/G734s3cwMmTuz8hr26aRZITM0rTS7i0=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=YuSjKP4AhoHBLbcLLk3pP6lpPKp3lDROEPEvTqE9UI51WZMnw7gDxHjDxCNYgrKFG
	 eJSblzJ11XR+iPKHqtIBfdezKsvu3QyJNyAtWH8orgG5n3CXjFYzGPRkTarpeyNBWM
	 Ld3eQEAg5q/fhZpMxjwhjHlvzkvWoxrjGf8mteQe/9zOwX+/hKrNHzUUZDIkFyAvE4
	 TUmARG5/QH4nieV6kDH49Ow4NjXJWhjIX2dJU7VZ8T9crzyuhKuNKD4B0ovUrTCKYM
	 z6Jov3Bvzd7/f65uk7zLQUZ9QVk+5mVU49Voiwk1vsJL5LuA4oqdZMOTf5a8XkXl6c
	 7USB/u58j90KA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/9/19 3:58 PM, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> Once callers start to use vaddr_pin the put_user_pages calls will need
> to have access to this data coming in.  Prep put_user_pages() for this
> data.
> 
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> ---
>  include/linux/mm.h |  20 +-------
>  mm/gup.c           | 122 ++++++++++++++++++++++++++++++++-------------
>  2 files changed, 88 insertions(+), 54 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index befe150d17be..9d37cafbef9a 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1064,25 +1064,7 @@ static inline void put_page(struct page *page)
>  		__put_page(page);
>  }
>  
> -/**
> - * put_user_page() - release a gup-pinned page
> - * @page:            pointer to page to be released
> - *
> - * Pages that were pinned via get_user_pages*() must be released via
> - * either put_user_page(), or one of the put_user_pages*() routines
> - * below. This is so that eventually, pages that are pinned via
> - * get_user_pages*() can be separately tracked and uniquely handled. In
> - * particular, interactions with RDMA and filesystems need special
> - * handling.
> - *
> - * put_user_page() and put_page() are not interchangeable, despite this early
> - * implementation that makes them look the same. put_user_page() calls must
> - * be perfectly matched up with get_user_page() calls.
> - */
> -static inline void put_user_page(struct page *page)
> -{
> -	put_page(page);
> -}
> +void put_user_page(struct page *page);
>  
>  void put_user_pages_dirty_lock(struct page **pages, unsigned long npages,
>  			       bool make_dirty);
> diff --git a/mm/gup.c b/mm/gup.c
> index a7a9d2f5278c..10cfd30ff668 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -24,30 +24,41 @@
>  
>  #include "internal.h"
>  
> -/**
> - * put_user_pages_dirty_lock() - release and optionally dirty gup-pinned pages
> - * @pages:  array of pages to be maybe marked dirty, and definitely released.

A couple comments from our circular review chain: some fellow with the same
last name as you, recommended wording it like this:

      @pages:  array of pages to be put

> - * @npages: number of pages in the @pages array.
> - * @make_dirty: whether to mark the pages dirty
> - *
> - * "gup-pinned page" refers to a page that has had one of the get_user_pages()
> - * variants called on that page.
> - *
> - * For each page in the @pages array, make that page (or its head page, if a
> - * compound page) dirty, if @make_dirty is true, and if the page was previously
> - * listed as clean. In any case, releases all pages using put_user_page(),
> - * possibly via put_user_pages(), for the non-dirty case.
> - *
> - * Please see the put_user_page() documentation for details.
> - *
> - * set_page_dirty_lock() is used internally. If instead, set_page_dirty() is
> - * required, then the caller should a) verify that this is really correct,
> - * because _lock() is usually required, and b) hand code it:
> - * set_page_dirty_lock(), put_user_page().
> - *
> - */
> -void put_user_pages_dirty_lock(struct page **pages, unsigned long npages,
> -			       bool make_dirty)
> +static void __put_user_page(struct vaddr_pin *vaddr_pin, struct page *page)
> +{
> +	page = compound_head(page);
> +
> +	/*
> +	 * For devmap managed pages we need to catch refcount transition from
> +	 * GUP_PIN_COUNTING_BIAS to 1, when refcount reach one it means the
> +	 * page is free and we need to inform the device driver through
> +	 * callback. See include/linux/memremap.h and HMM for details.
> +	 */
> +	if (put_devmap_managed_page(page))
> +		return;
> +
> +	if (put_page_testzero(page))
> +		__put_page(page);
> +}
> +
> +static void __put_user_pages(struct vaddr_pin *vaddr_pin, struct page **pages,
> +			     unsigned long npages)
> +{
> +	unsigned long index;
> +
> +	/*
> +	 * TODO: this can be optimized for huge pages: if a series of pages is
> +	 * physically contiguous and part of the same compound page, then a
> +	 * single operation to the head page should suffice.
> +	 */

As discussed in the other review thread (""), let's just delete that comment,
as long as you're moving things around.


> +	for (index = 0; index < npages; index++)
> +		__put_user_page(vaddr_pin, pages[index]);
> +}
> +
> +static void __put_user_pages_dirty_lock(struct vaddr_pin *vaddr_pin,
> +					struct page **pages,
> +					unsigned long npages,
> +					bool make_dirty)

Elsewhere in this series, we pass vaddr_pin at the end of the arg list.
Here we pass it at the beginning, and it caused a minor jar when reading it.
Obviously just bike shedding at this point, though. Either way. :)

>  {
>  	unsigned long index;
>  
> @@ -58,7 +69,7 @@ void put_user_pages_dirty_lock(struct page **pages, unsigned long npages,
>  	 */
>  
>  	if (!make_dirty) {
> -		put_user_pages(pages, npages);
> +		__put_user_pages(vaddr_pin, pages, npages);
>  		return;
>  	}
>  
> @@ -86,9 +97,58 @@ void put_user_pages_dirty_lock(struct page **pages, unsigned long npages,
>  		 */
>  		if (!PageDirty(page))
>  			set_page_dirty_lock(page);
> -		put_user_page(page);
> +		__put_user_page(vaddr_pin, page);
>  	}
>  }
> +
> +/**
> + * put_user_page() - release a gup-pinned page
> + * @page:            pointer to page to be released
> + *
> + * Pages that were pinned via get_user_pages*() must be released via
> + * either put_user_page(), or one of the put_user_pages*() routines
> + * below. This is so that eventually, pages that are pinned via
> + * get_user_pages*() can be separately tracked and uniquely handled. In
> + * particular, interactions with RDMA and filesystems need special
> + * handling.
> + *
> + * put_user_page() and put_page() are not interchangeable, despite this early
> + * implementation that makes them look the same. put_user_page() calls must
> + * be perfectly matched up with get_user_page() calls.
> + */
> +void put_user_page(struct page *page)
> +{
> +	__put_user_page(NULL, page);
> +}
> +EXPORT_SYMBOL(put_user_page);
> +
> +/**
> + * put_user_pages_dirty_lock() - release and optionally dirty gup-pinned pages
> + * @pages:  array of pages to be maybe marked dirty, and definitely released.

Same here:

      @pages:  array of pages to be put

> + * @npages: number of pages in the @pages array.
> + * @make_dirty: whether to mark the pages dirty
> + *
> + * "gup-pinned page" refers to a page that has had one of the get_user_pages()
> + * variants called on that page.
> + *
> + * For each page in the @pages array, make that page (or its head page, if a
> + * compound page) dirty, if @make_dirty is true, and if the page was previously
> + * listed as clean. In any case, releases all pages using put_user_page(),
> + * possibly via put_user_pages(), for the non-dirty case.
> + *
> + * Please see the put_user_page() documentation for details.
> + *
> + * set_page_dirty_lock() is used internally. If instead, set_page_dirty() is
> + * required, then the caller should a) verify that this is really correct,
> + * because _lock() is usually required, and b) hand code it:
> + * set_page_dirty_lock(), put_user_page().
> + *
> + */
> +void put_user_pages_dirty_lock(struct page **pages, unsigned long npages,
> +			       bool make_dirty)
> +{
> +	__put_user_pages_dirty_lock(NULL, pages, npages, make_dirty);
> +}
>  EXPORT_SYMBOL(put_user_pages_dirty_lock);
>  
>  /**
> @@ -102,15 +162,7 @@ EXPORT_SYMBOL(put_user_pages_dirty_lock);
>   */
>  void put_user_pages(struct page **pages, unsigned long npages)
>  {
> -	unsigned long index;
> -
> -	/*
> -	 * TODO: this can be optimized for huge pages: if a series of pages is
> -	 * physically contiguous and part of the same compound page, then a
> -	 * single operation to the head page should suffice.
> -	 */
> -	for (index = 0; index < npages; index++)
> -		put_user_page(pages[index]);
> +	__put_user_pages(NULL, pages, npages);
>  }
>  EXPORT_SYMBOL(put_user_pages);
>  
> 

This all looks pretty good, so regardless of the outcome of the minor
points above,
   
    Reviewed-by: John Hubbard <jhubbard@nvidia.com>


thanks,
-- 
John Hubbard
NVIDIA

