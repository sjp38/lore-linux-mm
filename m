Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A67B5C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 22:04:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 702EC216B7
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 22:04:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 702EC216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F27E66B0007; Mon,  5 Aug 2019 18:04:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB21D6B0008; Mon,  5 Aug 2019 18:04:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D52F76B000A; Mon,  5 Aug 2019 18:04:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B3406B0007
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 18:04:44 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 6so54390354pfz.10
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 15:04:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Z1vqL6JMXTNrRYHObPRcXJ36gZwsKRpaiXu6xbYwXcI=;
        b=e4EhpvQczxrYcLi22eUsu6snhf/vE8uk3lEw3NxrB0A1gD/EaM9CX6pqUxKu+QrTdR
         ogItkBR7n+I2Iq0+xMUrFgOeAg3X1tqb8IVHAHqIOK4heJoHTfpGJtSboPMzCfcehbOe
         8k5oiHUyciRlgHs/4d2cIBrt+2W6Q3oS3AScZXJ6qYCASNL/rnUWZhp+00ggeNrD5TG6
         VvWxd8M+W+z8kWRxJFCCco+atYFFvbBbSChFKFcE6yKPSGjEjnYiVmccDTmpQsuu5ndg
         of5m6tLCsVaWw0iwLSzUMlAfyhpW9/zaeQNgJZ7x1pGlUg4DW5gCVJGSkfn/MdTFO0Wu
         D4BA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUzquHv5pd4D4G0y/1SGQgLAoJWAaZXp68J9zGqbgd+nnHmcvYm
	NdK61IEyUpp4qZ4Bnbro+CBvZvrTPxrXON9BaEdANmMVrUB1m821gsqaIMxA6U1mQB/omte4WSh
	92fM3k1n0XU8Yxum7piw7b4bOn/uQOfcC7eZ9LVTgzZ/4S2p1b6kcZPze/ZlrnW/vmA==
X-Received: by 2002:a65:4304:: with SMTP id j4mr36956pgq.419.1565042684222;
        Mon, 05 Aug 2019 15:04:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkfD3dNczRqF7qygKXuEDYXPAIrUuGr5y2nTGCBznitElTzn+LXJHxL1NfRp8qErGfx+kG
X-Received: by 2002:a65:4304:: with SMTP id j4mr36902pgq.419.1565042683416;
        Mon, 05 Aug 2019 15:04:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565042683; cv=none;
        d=google.com; s=arc-20160816;
        b=NsqMo30ovOGd2Q0F0BWM5rJ6/DJaCuFn9MQ6tlbdE+q/L7nMJLwAz4zE6RJmFsWF1f
         151Y2C2zlCBKwO4CV1by8vcO2QAHp3cIKzb3g30yST1ZMlBC5pPiWPBl4Cb3OtSaJGxe
         f2bnoPwKIwvuJLjaguUijo1fcpxpjw1gloIQeVC/+fTz1WFYhq7DjC2ytJThRklMLL9c
         DnRnRvT1VusHQPgiGaaWLChQBbPWPH2W4XmV+luRnFNWwxXCjjoYeNRrh3j4NT4oeCRI
         75n6m8rf4b5JlOdIWv2VYeWkhS71SZ2V+3sCvjAgywyq1nkZCyaU8RG3LO9cnLqOLauH
         yraw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Z1vqL6JMXTNrRYHObPRcXJ36gZwsKRpaiXu6xbYwXcI=;
        b=ImfKgvTg+Wdevf5N+0HrSTPmf75CY9S7bS3u1QUppDUQn5bEs1EHdERVr/pPossPAZ
         WvysNP1U2uCzpVcDQcc1tfr4BtPMSgY+pL8rVpryvdYZnBfidGZganGggSGdke74e/jT
         rz/skk9mJQVjlSYBF+PmfZtt+B6GIxTGscticefRxl+xHpumQn+Tm1mNltOBXmjCbiLi
         MA8NhDXf9vaTnMJ/NMZYkW0cIYPd04n53jbN7UamIHNFaOHKbBadFvigJf7/0SqDm/iW
         Q6F1xZVWyqXt9AHsvDV5rFW759xm/Hnfta5l7iFEaPEuq7UlDwKLbOFxwx58zJjay5KK
         t7rQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id r8si47951615pgr.243.2019.08.05.15.04.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 15:04:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Aug 2019 15:04:42 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,350,1559545200"; 
   d="scan'208";a="373219765"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga005.fm.intel.com with ESMTP; 05 Aug 2019 15:04:42 -0700
Date: Mon, 5 Aug 2019 15:04:42 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org
Subject: Re: [PATCH] fs/io_uring.c: convert put_page() to put_user_page*()
Message-ID: <20190805220441.GA23416@iweiny-DESK2.sc.intel.com>
References: <20190805023206.8831-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805023206.8831-1-jhubbard@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 04, 2019 at 07:32:06PM -0700, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
> 
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: linux-fsdevel@vger.kernel.org
> Cc: linux-block@vger.kernel.org
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>

Signed-off-by: Ira Weiny <ira.weiny@intel.com>

> ---
>  fs/io_uring.c | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/io_uring.c b/fs/io_uring.c
> index d542f1cf4428..8a1de5ab9c6d 100644
> --- a/fs/io_uring.c
> +++ b/fs/io_uring.c
> @@ -2815,7 +2815,7 @@ static int io_sqe_buffer_unregister(struct io_ring_ctx *ctx)
>  		struct io_mapped_ubuf *imu = &ctx->user_bufs[i];
>  
>  		for (j = 0; j < imu->nr_bvecs; j++)
> -			put_page(imu->bvec[j].bv_page);
> +			put_user_page(imu->bvec[j].bv_page);
>  
>  		if (ctx->account_mem)
>  			io_unaccount_mem(ctx->user, imu->nr_bvecs);
> @@ -2959,10 +2959,8 @@ static int io_sqe_buffer_register(struct io_ring_ctx *ctx, void __user *arg,
>  			 * if we did partial map, or found file backed vmas,
>  			 * release any pages we did get
>  			 */
> -			if (pret > 0) {
> -				for (j = 0; j < pret; j++)
> -					put_page(pages[j]);
> -			}
> +			if (pret > 0)
> +				put_user_pages(pages, pret);
>  			if (ctx->account_mem)
>  				io_unaccount_mem(ctx->user, nr_pages);
>  			kvfree(imu->bvec);
> -- 
> 2.22.0
> 

