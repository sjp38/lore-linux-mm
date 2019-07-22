Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EF34C76194
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 19:05:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39848218B0
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 19:05:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Qy0etjiu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39848218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA62B6B0007; Mon, 22 Jul 2019 15:05:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C56DF8E0003; Mon, 22 Jul 2019 15:05:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD0F78E0001; Mon, 22 Jul 2019 15:05:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8839B6B0007
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 15:05:44 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id b75so30442981ywh.8
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 12:05:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=8K12rdfwIMLeACivZ31dz3qePpqi9G1AM6eI//iYEN8=;
        b=GHybNWeQBp3UPgSSNADv91m7q7Z1WOwkJotEBaYdLXGWLbHLLYQINMPK/VnfaPxniH
         Ay4wF9BkpYm3MA+DmHvdeWume206eZJGg78+frFB/XJxPiZjhGRSjnrj7s3DeDmT5zoK
         aYan/Yhm4CviEdZaY91HDn0TIyMsuFzHfAhfKZ1Hkq0oiC+BLwoGIR3M+YAWIA1OU1cQ
         3ZZmrdzPKuCiiu/HJUgaxi79P/j3bXaKWlhys1cLxQXn8b95Q3JuTKV6yRjbL0dKEnmt
         J2uvLEMeqGx2889bJJ0qgp7Hbbv0Ozel2vGjikJWG+rq8DYdBVcuyrTEDiAorlszPNoN
         9sIA==
X-Gm-Message-State: APjAAAWIQWb9OQ2mAtwHEHstNik/sPuKqVsoSz+XPfBwvEx0wk7Fjrtj
	glTpQEKpmGWOZ4kcMfIjd5a3YgGIXOIJqiqwwGhVsumLloy3gVB4aTc64hi5TFtf44IKY3sNBwA
	Vq7rIIHbAxHH39cVv7pWN+Rv894iBOnDzjPExjQbFckY+agCr0I/lyHpd+quG64iJlg==
X-Received: by 2002:a25:403:: with SMTP id 3mr43242523ybe.113.1563822344256;
        Mon, 22 Jul 2019 12:05:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvHCLGizUi1ufKESW5XmfajRbf7gj12H0cARDYLGvS8vre1lB2FsTvQ8tous2ikgA11j+N
X-Received: by 2002:a25:403:: with SMTP id 3mr43242485ybe.113.1563822343646;
        Mon, 22 Jul 2019 12:05:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563822343; cv=none;
        d=google.com; s=arc-20160816;
        b=oL2cJ858hyNi/+Efx/de6ZuuO/XILREqEu07kCknUzGoHMvojGNyg9uicCwEp3Ci0V
         kWGw0fFHyvql1izBvr3pDmg4EBllwwK8oJyQP51Z8TBoD0wYJNCF43Lx1ow/A8ystW1y
         6IR+a8WQRNh4Q4f4LqLdDhyYoCWCPq4l+NxQJeITLLW6vI13rhbQE09r73++fOq4pyBp
         dGle7wsV5uaieHGgIc1geE/r9qyBPgALE9HWjdipRu4rqbR+x/pLFQCLIvoZqvTJZrMg
         acfXuGLqwRZiTd6edDJK8JruoZSi6MIgCxR7Uf8/r8+tpL2z3UEE0Xu/t84v+HbemWSy
         0Mgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=8K12rdfwIMLeACivZ31dz3qePpqi9G1AM6eI//iYEN8=;
        b=Ajxp8HoNVLTGXPUmgGPcLJPBBFdGQwrTCguP2WbhRfSeJHG0ZAXAlmt2GDVRpOuQaO
         mIMQCVAghD9mEXeR6Drs7TjyoGH/Er5QaHE4dQIIcuhEv7GghkWtugrDU/Fx1i5CrBvo
         uLcylH3yw5TY1Np64wB8hbuJeirY/+ZOIgiJABtg9mKcpL+z8vguEhvp0SpjMSV1bbiV
         /lmNQ8jaF/u4kIhSNxWvwsciz67o1KHkTQsCLwLhdg86zWxXgWr8z5ri0IDETpEteY6d
         zNgxZGSu5sZ2/ROoKKzLm7tumhZLDtE7s0mH3xg9/nCgjyVvINdTfK+hA+rHUuO2u1vr
         Cj9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Qy0etjiu;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id l1si14687627ybo.116.2019.07.22.12.05.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 12:05:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Qy0etjiu;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3609060000>; Mon, 22 Jul 2019 12:05:42 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Mon, 22 Jul 2019 12:05:41 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Mon, 22 Jul 2019 12:05:41 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 22 Jul
 2019 19:05:41 +0000
Subject: Re: [PATCH 3/3] gup: new put_user_page_dirty*() helpers
To: <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
CC: Alexander Viro <viro@zeniv.linux.org.uk>, =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?=
	<bjorn.topel@intel.com>, Boaz Harrosh <boaz@plexistor.com>, Christoph Hellwig
	<hch@lst.de>, Daniel Vetter <daniel@ffwll.ch>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, David Airlie
	<airlied@linux.ie>, "David S . Miller" <davem@davemloft.net>, Ilya Dryomov
	<idryomov@gmail.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, Jens Axboe <axboe@kernel.dk>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Johannes Thumshirn
	<jthumshirn@suse.de>, Magnus Karlsson <magnus.karlsson@intel.com>, Matthew
 Wilcox <willy@infradead.org>, Miklos Szeredi <miklos@szeredi.hu>, Ming Lei
	<ming.lei@redhat.com>, Sage Weil <sage@redhat.com>, Santosh Shilimkar
	<santosh.shilimkar@oracle.com>, Yan Zheng <zyan@redhat.com>,
	<netdev@vger.kernel.org>, <dri-devel@lists.freedesktop.org>,
	<linux-mm@kvack.org>, <linux-rdma@vger.kernel.org>, <bpf@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
References: <20190722043012.22945-1-jhubbard@nvidia.com>
 <20190722043012.22945-4-jhubbard@nvidia.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <3a294582-9c60-b70c-8389-68c5d3326765@nvidia.com>
Date: Mon, 22 Jul 2019 12:05:40 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190722043012.22945-4-jhubbard@nvidia.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563822342; bh=8K12rdfwIMLeACivZ31dz3qePpqi9G1AM6eI//iYEN8=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=Qy0etjiupH0o/2VLEf2Kfw/6ThF3QIOwnl/C/rvCFndMqXXmTJum25AxDmXBD9fx0
	 +lec8POS98AIoHo7ixvgZ3iz684XA4lS1yZHPSINz9aZy0LmoLhaZPsSSFU5/Bo03T
	 52w9cXBaViCVqsTggF6GWpW0Oah+V7bMe4hi03+YNd2MQZn5Lsu0QELVxORLPDbDhK
	 rF6Wkh2eu1qSHQDfDMZEY9MYZ4nx59fTNJ9YnYLTvixS/iWf/D9hx5YrGY30jFkb1V
	 lkJLRCre9OmDJ3XF6bKkUZ7HtN33TM2Oviu2bFiwB2p3PM/eluQleNA55IB3j7XWpo
	 T97GFPuEvUYQA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/21/19 9:30 PM, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> While converting call sites to use put_user_page*() [1], quite a few
> places ended up needing a single-page routine to put and dirty a
> page.
> 
> Provide put_user_page_dirty() and put_user_page_dirty_lock(),
> and use them in a few places: net/xdp, drm/via/, drivers/infiniband.
> 

Please disregard this one, I'm going to drop it, as per the
discussion in patch 1.

thanks,
-- 
John Hubbard
NVIDIA

> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Jan Kara <jack@suse.cz>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
>  drivers/gpu/drm/via/via_dmablit.c        |  2 +-
>  drivers/infiniband/core/umem.c           |  2 +-
>  drivers/infiniband/hw/usnic/usnic_uiom.c |  2 +-
>  include/linux/mm.h                       | 10 ++++++++++
>  net/xdp/xdp_umem.c                       |  2 +-
>  5 files changed, 14 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
> index 219827ae114f..d30b2d75599f 100644
> --- a/drivers/gpu/drm/via/via_dmablit.c
> +++ b/drivers/gpu/drm/via/via_dmablit.c
> @@ -189,7 +189,7 @@ via_free_sg_info(struct pci_dev *pdev, drm_via_sg_info_t *vsg)
>  		for (i = 0; i < vsg->num_pages; ++i) {
>  			if (NULL != (page = vsg->pages[i])) {
>  				if (!PageReserved(page) && (DMA_FROM_DEVICE == vsg->direction))
> -					put_user_pages_dirty(&page, 1);
> +					put_user_page_dirty(page);
>  				else
>  					put_user_page(page);
>  			}
> diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
> index 08da840ed7ee..a7337cc3ca20 100644
> --- a/drivers/infiniband/core/umem.c
> +++ b/drivers/infiniband/core/umem.c
> @@ -55,7 +55,7 @@ static void __ib_umem_release(struct ib_device *dev, struct ib_umem *umem, int d
>  	for_each_sg_page(umem->sg_head.sgl, &sg_iter, umem->sg_nents, 0) {
>  		page = sg_page_iter_page(&sg_iter);
>  		if (umem->writable && dirty)
> -			put_user_pages_dirty_lock(&page, 1);
> +			put_user_page_dirty_lock(page);
>  		else
>  			put_user_page(page);
>  	}
> diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
> index 0b0237d41613..d2ded624fb2a 100644
> --- a/drivers/infiniband/hw/usnic/usnic_uiom.c
> +++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
> @@ -76,7 +76,7 @@ static void usnic_uiom_put_pages(struct list_head *chunk_list, int dirty)
>  			page = sg_page(sg);
>  			pa = sg_phys(sg);
>  			if (dirty)
> -				put_user_pages_dirty_lock(&page, 1);
> +				put_user_page_dirty_lock(page);
>  			else
>  				put_user_page(page);
>  			usnic_dbg("pa: %pa\n", &pa);
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0334ca97c584..c0584c6d9d78 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1061,6 +1061,16 @@ void put_user_pages_dirty(struct page **pages, unsigned long npages);
>  void put_user_pages_dirty_lock(struct page **pages, unsigned long npages);
>  void put_user_pages(struct page **pages, unsigned long npages);
>  
> +static inline void put_user_page_dirty(struct page *page)
> +{
> +	put_user_pages_dirty(&page, 1);
> +}
> +
> +static inline void put_user_page_dirty_lock(struct page *page)
> +{
> +	put_user_pages_dirty_lock(&page, 1);
> +}
> +
>  #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
>  #define SECTION_IN_PAGE_FLAGS
>  #endif
> diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
> index 9cbbb96c2a32..1d122e52c6de 100644
> --- a/net/xdp/xdp_umem.c
> +++ b/net/xdp/xdp_umem.c
> @@ -171,7 +171,7 @@ static void xdp_umem_unpin_pages(struct xdp_umem *umem)
>  	for (i = 0; i < umem->npgs; i++) {
>  		struct page *page = umem->pgs[i];
>  
> -		put_user_pages_dirty_lock(&page, 1);
> +		put_user_page_dirty_lock(page);
>  	}
>  
>  	kfree(umem->pgs);
> 

