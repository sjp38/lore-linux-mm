Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48B48C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:29:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63C65206C0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:29:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TIMuDlgi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63C65206C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99EDD6B0005; Thu, 25 Apr 2019 11:29:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94E0B6B000D; Thu, 25 Apr 2019 11:29:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 864EE6B0010; Thu, 25 Apr 2019 11:29:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7296B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 11:29:47 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id m9so10118855pge.7
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:29:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PlgZa5fNEN4G30GBHPSvgZcqYuqb7Rv6jBBzHiGZvn8=;
        b=J4byKGawbBeUWP7wqhyU0p2/b+W6SidevKsiif1qFV/Kaplom5MFxnzTPqqVELYxyq
         M0w9UNZ86wd+hMZO9xg8MEuciObEbmNzYTQ9ct9vOiq3p+1AFHx4NY3XvGZP8A5/1KSk
         B3qbThL6l5O05huFRS+RiPcBbTOaEEeLW3EdXBP5O9sOc9lsiH1LxnAD+EP3Y8NF9cer
         T7OtA6RqlnuoBow+QPGgqq1IJqwhWlHxaYzr64MxHzz3F6dEgfD5H9L/xsyHc81w++5u
         csy1+T1ghdLJat36nfGfeCl48MIOpxTpdLqRgrTtoBYEye9Y6P9/nxGs7PwSnoQ82faS
         HvWQ==
X-Gm-Message-State: APjAAAUuL82W5oXdbMgX+AJG8VjEbXUoDzY1jRNuCPp0u21w+6uM76FV
	sZ95i+DdMoQ9EmBmJWFqD99vs2sbd5xujlQGh5JZDDi7dfZ2OUYj7M8kU+CsA7oLnHsUhgl8scm
	z5c46yKR9Oj1uP/jZ415CYdNwsqEp5OKE1pASvSXPoESgf5UTd7W/rQchhW9ASNgw2g==
X-Received: by 2002:a17:902:822:: with SMTP id 31mr39481649plk.41.1556206186829;
        Thu, 25 Apr 2019 08:29:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwP7yLhdH2gtCRIQ3M3T8Bg4y//e98s3OV3GqSRoJIWheIhAvWy84MDL++A5bNg6g8arK+V
X-Received: by 2002:a17:902:822:: with SMTP id 31mr39481570plk.41.1556206185985;
        Thu, 25 Apr 2019 08:29:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556206185; cv=none;
        d=google.com; s=arc-20160816;
        b=GBkCHe061uvPyh8t/KKZL4NIu80GHdArersa76Jaahd/PxnOm4gzvYHLeQczz7ke3z
         25T1dZKQR7QHQxoPG4o/1qDUrvFmg+0/lxvVoSsqaHfI/2V5hxbOmDSXjvEfBZdrAiTc
         OGKqJbojyK5Mg9G5szqpLetF6gTto/X4+3iF3q3/JzZ8zbR5sCtkY19Q5+8qEefeJx89
         QgTp9RoogxyuL/PXTwEIgh1hmKWqRiHfZmziyHC3E/gxdvLGxrd/tV0DmkEbp+awt5kr
         2TolMdwez6oudECckc+ie9t5dAd7unz3UziNpNwuL29JNsJrd6lqAWUC9vvmfoAr7aRY
         WSng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=PlgZa5fNEN4G30GBHPSvgZcqYuqb7Rv6jBBzHiGZvn8=;
        b=SE8DLv+QwwUc9FJznziQJbr9UzhZrLQY9g5/wXAgoYo0xrW2NvVGWhc07cwPOFAqXe
         vmQMcHtdXS9pFq5C/41dCQLnhXSbJDiYMAkcvyTDZDSkXsuXPvfyvtDZd20uEjB7SEat
         DYXoPk5xPq/zkji0XqNLhR/JuNqdEyF6hSXNagde1iI2gmQgFP/qPrHHPRifZTBIK335
         yBekeBCgI0up/PkoguRF/69kr5np13dCaUaHIlhDSYGt4vPWfmPoHpIpcJwe/LL/HCuH
         J3un9/1fCgpcPQwSWNxrYuRD18kz1lvjQWUrvmQyrQ4ayc24fwmtPP7wQCwvJ0i5pcaq
         9/7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TIMuDlgi;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j10si22545920plb.346.2019.04.25.08.29.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Apr 2019 08:29:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TIMuDlgi;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=PlgZa5fNEN4G30GBHPSvgZcqYuqb7Rv6jBBzHiGZvn8=; b=TIMuDlgi/SxAbQRgeH7+5+shy
	p2zO+nw8frdOOx2+wtp05lr1D+zKqrhQcSPbEQQLMEoy8Pksh7zA3Tq5P7JhRgG3jLjtI+THlW5uA
	j3LCG5WXiwSxVBnJ4a7n6jx3H1qXVokj1wrrkpfkFz75ydjzkoefyD2JQTSzrL/62kUAGeZvRsOMK
	wobqD6/OMq+irq3nQu4mauu2sbbER2kOjn8nuNsHdhIEDTvJJhO3E5TigIkyarG62skVQogcKD31N
	QtleWfwn3ipFL4h88E8b0R7IZ7jcOwwwWwmOGqlhQRqZctZ/litBukmxYCpQ6C56jwK46RN8C/8p/
	qrFRvklGA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJgJg-0004SJ-J8; Thu, 25 Apr 2019 15:29:40 +0000
Date: Thu, 25 Apr 2019 08:29:40 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: cluster-devel@redhat.com, Christoph Hellwig <hch@lst.de>,
	Bob Peterson <rpeterso@redhat.com>, Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v2 1/2] iomap: Add a page_prepare callback
Message-ID: <20190425152940.GJ19031@bombadil.infradead.org>
References: <20190425152631.633-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190425152631.633-1-agruenba@redhat.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 05:26:30PM +0200, Andreas Gruenbacher wrote:

This seems to be corrupted; there's no declaration of a page_ops in
iomap_write_begin ... unless you're basing on a patch I don't have?

> diff --git a/fs/iomap.c b/fs/iomap.c
> index 97cb9d486a7d..967c985c5310 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -674,9 +674,17 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
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

