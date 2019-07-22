Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D64AC76195
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:34:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2CDB21993
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:34:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2CDB21993
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85CCD6B0007; Mon, 22 Jul 2019 05:34:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80D926B0008; Mon, 22 Jul 2019 05:34:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FC276B000A; Mon, 22 Jul 2019 05:34:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 262846B0007
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 05:34:35 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id f189so8791685wme.5
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 02:34:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JLIqc4ok0KFH4hHynCXkcM5xSPPn+/DWBah11nXcUBM=;
        b=h24FAq+1KW4BkdiMKsn2W9e77vMLbhv+jCnbeIbhy0VKTcB9P2HeGgv9lzR4qeHcli
         uRip2M7g45rmQaThT0+SxLFK1qSbwljkndQHKpFib3fGneiFWVUFZSsIZ3eP6mmOKn9S
         j0IpVclR1kGFBfqCSG3iZEr+16XhgZ+lFCpzWrgXPtb61/c4OdBZn8xvMzToyB0cpeTO
         QfHMkm//InUlTNCyKUV8byeeqp6Khr6SghZVn04EtGq85Uyk+QfxQFo/9CO7vfvKWQwq
         Dvhq5uAaTaWcOhWX+S8uIeaMrBY1HhrIau7eYnBARSjoJbUjJR2094HHxvgaAkNk7twn
         kIlw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUseK2SpdBfgzqQ2HXbGm1VusuZa9iuvYi07V9XSqXCoBlGcdya
	uWYxSoFvQGbXK8EC+IeSr7tPOepI7mf0lkhBiDKy5fmT4HHKozWJLpBTYRLKh8BBDA9ECGPD9tH
	+XOorF2imf8mtAyPiteD82FyYabtP7ssl7c39PcXEvqQZ+ctmmNFA2ju6H+Y82v3pXQ==
X-Received: by 2002:a5d:428b:: with SMTP id k11mr42457139wrq.174.1563788074710;
        Mon, 22 Jul 2019 02:34:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw06oR9JTnWSoRZXS4CfFbdNE7fzcLUlk/ZUoxiYCJ10I4tIQWc1GD+9ObKIvuzHCLLhlIX
X-Received: by 2002:a5d:428b:: with SMTP id k11mr42456381wrq.174.1563788069138;
        Mon, 22 Jul 2019 02:34:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563788069; cv=none;
        d=google.com; s=arc-20160816;
        b=W9uRHLzZ5sD9wrK4ZRpJbMI33hz/ei4WWBjeDp7eD7H4qN4ZLDM8q/AHxXdks+XzDv
         t6SQADTXjmlDS/27tNJaxlerRgt29XH/J7wzvHQcZzh0MHNvmAw4GbFAbK6lvtBiTZI7
         ZVU4SKbfIhxnH8UfVDyTVQaaKlPI1dkGeDi87kXDxjkca/sND5NKy83ciLrJrmfEvJMK
         rlZyIR0nz2ZFYpOrlEoBAk4nXeA+ssMQTahn2Z8nUlhwIjjyjiq82MdAgMzr5JOlp5pL
         9ZHGIGYIy65xol9eHfsPEprlq8sdVvLA79/rRbuDc54tyafu/EDR1I/N5jON4Jh4XZR+
         fgAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JLIqc4ok0KFH4hHynCXkcM5xSPPn+/DWBah11nXcUBM=;
        b=YF2bEbFoRMRlyx3bIRi6degDe9axkXIXcTyIHfhzKYF9GIgRrA5w+qEb/sMFJVaMC6
         Qr/j0o2RzASEDinepVtqJBdZd0JeNqnLHr2vsPMAW1oFnhhc+rRKWyY+eAumICqRlYxj
         /8dTJWnU/hgbC2d9jbch2pptI6TpyMtHNygoXhqqyh211LhaUBCIRYHgTom228/J6WD7
         yu4Ex18XeP6XWgOYaAuJbYGrVRXyVQsGMuYGNt1LIS+T/H3wLOqI3ztPdHxPYGS3sLjw
         q++3vw3f2wDoxYIuffUH0KpMZJJUWHdFa2QBXb1ZUi+DkgINh0LHeX4bYsMwilUqVa69
         RGoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m8si38094500wrn.174.2019.07.22.02.34.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 02:34:29 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 5F1B668B20; Mon, 22 Jul 2019 11:34:28 +0200 (CEST)
Date: Mon, 22 Jul 2019 11:34:28 +0200
From: Christoph Hellwig <hch@lst.de>
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
Subject: Re: [PATCH 2/3] net/xdp: convert put_page() to put_user_page*()
Message-ID: <20190722093428.GC29538@lst.de>
References: <20190722043012.22945-1-jhubbard@nvidia.com> <20190722043012.22945-3-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722043012.22945-3-jhubbard@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
> index 83de74ca729a..9cbbb96c2a32 100644
> --- a/net/xdp/xdp_umem.c
> +++ b/net/xdp/xdp_umem.c
> @@ -171,8 +171,7 @@ static void xdp_umem_unpin_pages(struct xdp_umem *umem)
>  	for (i = 0; i < umem->npgs; i++) {
>  		struct page *page = umem->pgs[i];
>  
> -		set_page_dirty_lock(page);
> -		put_page(page);
> +		put_user_pages_dirty_lock(&page, 1);

Same here, we really should avoid the need for the loop here and
do the looping inside the helper.

