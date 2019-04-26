Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 791E9C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:22:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43F27206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:22:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43F27206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D37B96B0003; Fri, 26 Apr 2019 10:22:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE87C6B0005; Fri, 26 Apr 2019 10:22:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BFF836B0006; Fri, 26 Apr 2019 10:22:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 72C316B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 10:22:46 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id u14so3579063wrr.9
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 07:22:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ATOvemLjsUuMwH/S84bYUTZwqav8fKEWm/GVj3uPGrY=;
        b=X6xl2VqIa63hljUaSayf5J7VqkO0nYhuDbbKGsToZ242Opf/P8yqxvDQ5RMSisv4QE
         j/toZ8I6UJ/pnSM9wWPQYlWutle38eLmiNZmHGaFkLgfHpFENnDE6EHDR5/siRb8PUq5
         fckg4WmFxmdyHVLTAF9W/zl7x9jREB3ZDNgkT6tQZn7qEJGySeNuKQ9pJe3ZNZQML3uy
         VjwPDhn32glA7DrSdMfFbDpHsQr3vRC9FCzqNO1HzP10ixglzNkoDRmw+BGxPC3NRsCF
         sybho9cT/B25o8XUoQDZa6d9Dsu5IyiiAvQqWs3B6+f/OL45pIyJg+6Dna+5xCkFNLgr
         imKg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUfJwojX5mTrDuSG1XckXwouKMxndTf32tAhkeKS8/+b/7FxfLI
	peERBGp9y8O1o7km3CDAMkc2WDDHhdsK+PxSu536hKb+cZUDpEdWLvAwNAJGxGeKHQYCZ6dTNUR
	ylfG6vs5U4Nbft82bzQm1h5r2hCNC58jReil5wosHBgG6+Gts9OLU0iZIBR4FCVCAyQ==
X-Received: by 2002:a1c:1b50:: with SMTP id b77mr1856685wmb.142.1556288565855;
        Fri, 26 Apr 2019 07:22:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyn96aEi2H8vjUIfK4tWFDgptKgwMzGz4nyMLS45+iaYppVfydr6cqUpqxEtXD5QfCTcvw9
X-Received: by 2002:a1c:1b50:: with SMTP id b77mr1856628wmb.142.1556288564797;
        Fri, 26 Apr 2019 07:22:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556288564; cv=none;
        d=google.com; s=arc-20160816;
        b=sRRGJGteEIP8V5Kbvv89b9TcqSPyHktjIRxeOqV3aKvB+qe1fF6ln72iTWYBFK00ML
         klHA5vQGBVUY2H+1cCW+hYwrywEV8XkB7x8IVOtFhWGM8jE1Xk60mmi+yGXnH+vGbHGI
         hfs9HxLYQaOOMpUqW0qKQystV6XbWNMyFYL29HHGr3lLPAtVWUsrTSwaBMbhHKANB89Y
         Epckls07FZPh59TeaBsRW45M9D2mIjruSPDIX7AZ0irxqvWprLevK0AvmW9uWrCNM2Az
         VG6hknCjw3kkVbdCSOkpkMHkQyAdVI1niHTreqvRK+zToUfRDUJ7JeYlpxSo43rq35Ma
         12PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ATOvemLjsUuMwH/S84bYUTZwqav8fKEWm/GVj3uPGrY=;
        b=QZlaeICkI2XjIjp9n9YX57senqxFqqz9u0aodzkfy5IUO98Dn+1+ECpuEVgxOKZngw
         N6iikKCwutmlaMHyWyeilRGolikTA3bogdu1+yinVTJMkoIyZC0ojCsHpdo2atjY6v3j
         l9Jdnvz0Hte7/lv9N59wjzaCe+c60o7OviMLkZww/uZ2Y80XWSC96L0HRjNzLtYwPnPh
         K0xD//WY6zuThskmH8ywP7yHjc1PByCtpMjW+guLqPgqdvdGVaRIBwAHKuETvk2dUsqX
         WVN9MiSm9g69pVtKhiu5vM7QAmBQuqx7ke/0DMy1hjw9GOdOg8jL8z6rf/qgPrsKcpCP
         Ds5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id z75si17626453wmc.151.2019.04.26.07.22.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 07:22:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 6210F68BFE; Fri, 26 Apr 2019 16:22:28 +0200 (CEST)
Date: Fri, 26 Apr 2019 16:22:28 +0200
From: Christoph Hellwig <hch@lst.de>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: cluster-devel@redhat.com, Christoph Hellwig <hch@lst.de>,
	Bob Peterson <rpeterso@redhat.com>, Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v5 2/3] iomap: Add a page_prepare callback
Message-ID: <20190426142228.GA16499@lst.de>
References: <20190426131127.19164-1-agruenba@redhat.com> <20190426131127.19164-2-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190426131127.19164-2-agruenba@redhat.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 26, 2019 at 03:11:26PM +0200, Andreas Gruenbacher wrote:
> Move the page_done callback into a separate iomap_page_ops structure and
> add a page_prepare calback to be called before the next page is written
> to.  In gfs2, we'll want to start a transaction in page_prepare and end
> it in page_done; other filesystems that implement data journaling will
> require the same kind of mechanism.
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> ---
>  fs/gfs2/bmap.c        | 22 +++++++++++++++++-----
>  fs/iomap.c            | 22 ++++++++++++++++++----
>  include/linux/iomap.h | 18 +++++++++++++-----
>  3 files changed, 48 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/gfs2/bmap.c b/fs/gfs2/bmap.c
> index 5da4ca9041c0..6b980703bae7 100644
> --- a/fs/gfs2/bmap.c
> +++ b/fs/gfs2/bmap.c
> @@ -991,15 +991,27 @@ static void gfs2_write_unlock(struct inode *inode)
>  	gfs2_glock_dq_uninit(&ip->i_gh);
>  }
>  
> -static void gfs2_iomap_journaled_page_done(struct inode *inode, loff_t pos,
> -				unsigned copied, struct page *page,
> -				struct iomap *iomap)
> +static int gfs2_iomap_page_prepare(struct inode *inode, loff_t pos,
> +				   unsigned len, struct iomap *iomap)
> +{
> +	return 0;
> +}
> +
> +static void gfs2_iomap_page_done(struct inode *inode, loff_t pos,
> +				 unsigned copied, struct page *page,
> +				 struct iomap *iomap)
>  {
>  	struct gfs2_inode *ip = GFS2_I(inode);
>  
> -	gfs2_page_add_databufs(ip, page, offset_in_page(pos), copied);
> +	if (page)
> +		gfs2_page_add_databufs(ip, page, offset_in_page(pos), copied);
>  }
>  
> +static const struct iomap_page_ops gfs2_iomap_page_ops = {
> +	.page_prepare = gfs2_iomap_page_prepare,
> +	.page_done = gfs2_iomap_page_done,
> +};
> +
>  static int gfs2_iomap_begin_write(struct inode *inode, loff_t pos,
>  				  loff_t length, unsigned flags,
>  				  struct iomap *iomap,
> @@ -1077,7 +1089,7 @@ static int gfs2_iomap_begin_write(struct inode *inode, loff_t pos,
>  		}
>  	}
>  	if (!gfs2_is_stuffed(ip) && gfs2_is_jdata(ip))
> -		iomap->page_done = gfs2_iomap_journaled_page_done;
> +		iomap->page_ops = &gfs2_iomap_page_ops;
>  	return 0;
>  
>  out_trans_end:
> diff --git a/fs/iomap.c b/fs/iomap.c
> index 3e4652dac9d9..ba2d44b33ed1 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -665,6 +665,7 @@ static int
>  iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
>  		struct page **pagep, struct iomap *iomap)
>  {
> +	const struct iomap_page_ops *page_ops = iomap->page_ops;
>  	pgoff_t index = pos >> PAGE_SHIFT;
>  	struct page *page;
>  	int status = 0;
> @@ -674,9 +675,17 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
>  	if (fatal_signal_pending(current))
>  		return -EINTR;
>  
> +	if (page_ops) {
> +		status = page_ops->page_prepare(inode, pos, len, iomap);
> +		if (status)
> +			return status;
> +	}
> +
>  	page = grab_cache_page_write_begin(inode->i_mapping, index, flags);
> -	if (!page)
> -		return -ENOMEM;
> +	if (!page) {
> +		status = -ENOMEM;
> +		goto no_page;
> +	}
>  
>  	if (iomap->type == IOMAP_INLINE)
>  		iomap_read_inline_data(inode, page, iomap);
> @@ -684,12 +693,16 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
>  		status = __block_write_begin_int(page, pos, len, NULL, iomap);
>  	else
>  		status = __iomap_write_begin(inode, pos, len, page, iomap);
> +
>  	if (unlikely(status)) {
>  		unlock_page(page);
>  		put_page(page);
>  		page = NULL;
>  
>  		iomap_write_failed(inode, pos, len);
> +no_page:
> +		if (page_ops)
> +			page_ops->page_done(inode, pos, 0, NULL, iomap);
>  	}
>  
>  	*pagep = page;

I think we need to clean this area up a bit, this is becoming to
confusing.

Something like:

	if (unlikely(status))
		goto out_unlock;

	*pagep = page;
	return 0;

out_unlock:
	unlock_page(page);
	put_page(page);
	iomap_write_failed(inode, pos, len);
out_no_page:
	if (page_ops)
		page_ops->page_done(inode, pos, 0, NULL, iomap);
	*pagep = NULL;
	return status;


> +	if (page_ops)
> +		page_ops->page_done(inode, pos, copied, page, iomap);

Do we always require both pages ops to be set?  Wouldn't it be better
to check for the method presence as well?

> +/*
> + * Called before / after processing a page in the mapping returned in this
> + * iomap.  At least for now, this is only supported in the buffered write path.
> + * When page_prepare returns 0, page_done is called as well
> + * (possibly with page == NULL).
> + */

Not just for now - I think the concept fundamentally only makes sense
for buffered I/O.  Maybe we need to express that a little more clearly.

Otherwise looks fine to me.

