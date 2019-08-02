Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95AD6C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 22:32:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2693920B7C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 22:32:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="cpjIBy8J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2693920B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 944B96B0003; Fri,  2 Aug 2019 18:32:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CD986B0005; Fri,  2 Aug 2019 18:32:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76FE36B0006; Fri,  2 Aug 2019 18:32:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 40A9C6B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 18:32:40 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id q14so49190792pff.8
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 15:32:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=4K9VX2tT2a13PQvUytHU4nLNlmr+ahJaGE5s4V5FsNk=;
        b=fsxwmTS8c+VR9h7sW0cIx5OrwPy/P43Px8SBzzXXxRyzaLmhqlC9e3EIUOvYOWQIv8
         UiYIjYYN5ZL03nl+gq6+QzpTad4PSL8j/ZaHpbRnP/JX2/pxNcb2B2wGBKkU4qwNWjmc
         jeIY6pfHgd9rQYaIGDr7fKAIm4dBfwpbqBo0/X6ei3MZ8zSb6LtR6xoLu1XfMkHawwKo
         lLR5Xh/st2j0l2ca73O+0qMSnSxJWi8B77X8E82K/0+WCni8RZFY4HbIRw4rGlyKVoSq
         WZ7XVxc8dL15vuJjKXXGeAnrIDC1/Pptfmr9GVNP2ZlEXLB8CrvC1UgjPzWY71psUVlm
         KiDA==
X-Gm-Message-State: APjAAAVvCRBxBgZgN3GrbXlNarT3zS5VJNBtaU4HPDGhQYAZkb7ZTzkK
	tnzmrhES2+7K09XApvjLGHvhocBxaTBceQu7j/RFLM46rnzqA/JRf3XOPnt/2BfFL5iipknNiur
	v8Wdja0Gjql/vJMVUZiNMh86ozV844zs3ftl7BITESJUBzmqQaiQX4m2Y4ZGtDaFD3Q==
X-Received: by 2002:a63:1455:: with SMTP id 21mr82107016pgu.116.1564785159678;
        Fri, 02 Aug 2019 15:32:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPujBRiSvw4JEbEvx4WxiV/Ff6VuNEoq9nH6/KNRYg9FwhSn4XM6WEX/AOPQPPOlgPp4gO
X-Received: by 2002:a63:1455:: with SMTP id 21mr82106952pgu.116.1564785158508;
        Fri, 02 Aug 2019 15:32:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564785158; cv=none;
        d=google.com; s=arc-20160816;
        b=DXgXDjK9Vbh4So3OnHLbUltxPFEZfa+KmTaygygVDUS34AZt9Ecxu11C9e46S6oVRB
         L98AIRo1F2lof7lN8TshQG4dzc1yzUWJM6bd6QBQTwfHLOqmTPT0Hs/vtrpXbblUjcT7
         Sr16U0tFQY9CgRcHthqWjnW2LMxFo0eLKzfQy0T8nxHO1znO35PXqg+sxEFezzU38y7u
         G5MbjG2W7IVO22JAfLUQl0PTBsONHDcRnMD61WSICwIRyaqjnUhZds92MJlJD/Dp3wjj
         RxXFkNv0uIBCOOrLRyA+XUXZ2rrPYQZFT/uv2MTjNAAafPK5FjSqPBmTXCq0K+1DiFgI
         YV9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=4K9VX2tT2a13PQvUytHU4nLNlmr+ahJaGE5s4V5FsNk=;
        b=GLCW0Lkb/F76ACTwobLIeNht+aP74Jes9tYAHSJspgrM6GL7tbkNm6wK3A7p622fbJ
         P3P2MGj6EJrOLfLP0nEwiB4zg4PLkbVvyxv2QOkDiS/XAaNrCcxerK82T52o7dQReq+p
         x4YebxyLkwoZoOS75L2I0ywTQt79GY+tWVq9iarFH0VrWtu+qT5fQyQ1eoDrvbgf2MDA
         rbxi46ZuaOGm0rdtXcC34gN/FWKkZEPxroj/VNS6UPsF8ggIyJV5Pr5bdZz88D2tSLsY
         NMak5hN26Np1eTwjuuEjTUDx1CaUYTXIUEYBIwAvj6HE0gfsJM7PPE9l1zrQnvA5zKwD
         I2HA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=cpjIBy8J;
       spf=pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jlayton@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p1si43421872pff.250.2019.08.02.15.32.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 15:32:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=cpjIBy8J;
       spf=pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jlayton@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 58F57206A3;
	Fri,  2 Aug 2019 22:32:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564785158;
	bh=z6ytUlp+CIECyVYgzsmKAgNAlD3y+8CHq71PuCQ0D+c=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=cpjIBy8JqGDmfo2YvJ1zHX2H3F5SzV7XyBEUvKOoDGfZiHGtVeJHlsiNF8f/o/lw/
	 1IriX/50tm1jxxFU6BHxnU7AmYr31cK1qfEIW7FiUI67JvLd42gEz50jymZEZTSESa
	 2e28o/zwwAXm5Iq/SkAmipJbFc8z+f7/iU9PnXtA=
Message-ID: <2f0d5993e9731808b73b0018f5fc4b3335fc6373.camel@kernel.org>
Subject: Re: [PATCH 03/34] net/ceph: convert put_page() to put_user_page*()
From: Jeff Layton <jlayton@kernel.org>
To: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Dan Williams
 <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Ira Weiny <ira.weiny@intel.com>, Jan Kara
 <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, =?ISO-8859-1?Q?J=E9r=F4me?=
 Glisse <jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
 amd-gfx@lists.freedesktop.org,  ceph-devel@vger.kernel.org,
 devel@driverdev.osuosl.org, devel@lists.orangefs.org, 
 dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, 
 kvm@vger.kernel.org, linux-arm-kernel@lists.infradead.org, 
 linux-block@vger.kernel.org, linux-crypto@vger.kernel.org, 
 linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 linux-media@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org,
  linux-rdma@vger.kernel.org, linux-rpi-kernel@lists.infradead.org, 
 linux-xfs@vger.kernel.org, netdev@vger.kernel.org,
 rds-devel@oss.oracle.com,  sparclinux@vger.kernel.org, x86@kernel.org,
 xen-devel@lists.xenproject.org,  John Hubbard <jhubbard@nvidia.com>, Ilya
 Dryomov <idryomov@gmail.com>, Sage Weil <sage@redhat.com>, "David S .
 Miller" <davem@davemloft.net>
Date: Fri, 02 Aug 2019 18:32:33 -0400
In-Reply-To: <20190802022005.5117-4-jhubbard@nvidia.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
	 <20190802022005.5117-4-jhubbard@nvidia.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.4 (3.32.4-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-08-01 at 19:19 -0700, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
> 
> Cc: Ilya Dryomov <idryomov@gmail.com>
> Cc: Sage Weil <sage@redhat.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: ceph-devel@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
>  net/ceph/pagevec.c | 8 +-------
>  1 file changed, 1 insertion(+), 7 deletions(-)
> 
> diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
> index 64305e7056a1..c88fff2ab9bd 100644
> --- a/net/ceph/pagevec.c
> +++ b/net/ceph/pagevec.c
> @@ -12,13 +12,7 @@
>  
>  void ceph_put_page_vector(struct page **pages, int num_pages, bool dirty)
>  {
> -	int i;
> -
> -	for (i = 0; i < num_pages; i++) {
> -		if (dirty)
> -			set_page_dirty_lock(pages[i]);
> -		put_page(pages[i]);
> -	}
> +	put_user_pages_dirty_lock(pages, num_pages, dirty);
>  	kvfree(pages);
>  }
>  EXPORT_SYMBOL(ceph_put_page_vector);

This patch looks sane enough. Assuming that the earlier patches are OK:

Acked-by: Jeff Layton <jlayton@kernel.org>

