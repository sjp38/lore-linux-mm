Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48953C46470
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 21:44:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 101BD2067D
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 21:44:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 101BD2067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A45476B0008; Mon, 29 Apr 2019 17:44:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F4C46B000E; Mon, 29 Apr 2019 17:44:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E5986B0010; Mon, 29 Apr 2019 17:44:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 403786B0008
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 17:44:43 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g36so1152022edg.8
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 14:44:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8lRratGBW3Cv1VUXc207f1krtwK9gaDZv1xRcTehSm8=;
        b=t6KzNE28tNQKUiIsNq9ALkL18Ws9DcxzjSO60/GIUxS+Mc4nK3jWoGf3L4rN8GfzX9
         tSv9sK6Tiao6efMaslkhJmbrhBsXHhQO2UoKz438ggsFsa5h0S9uDKpjbMS+ZV9Tq83P
         1uYLFyJi5rzit2gPuXyLO61uusItLs6fxOs+c4S2bm4+rWt3tC7YwDP+mpfh2u58xZaN
         o41rCuo3VmOaNaSqcYoGgqoUvfEvsHhUeqVFr+OPawqAUugp3sHNtfuYUo4aiSnjsTsq
         lL6SGBWOW33XDjuOI6zZYSMdgzcQGECVWX7I/lqPNgK+aOM/hdPhaiSVks++x3B95QGj
         7AZA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXPwjtvUXmng3SaSwjjechARdyZTdx2irfteLBpOcMr2D/R0KUE
	iN5olw7wqbvze5UEc4aVK1DxKIHIE/ECP+uiCnxi7VtZerHL0DCMWWEFuclC6o1mC4ONGmyH1IC
	cdJE2o3glyZrWUt04IhKb+b+SeNjAOT7wc/E0+eJ8iun8vY2QxjOdQIUBnSzqVi9Dxg==
X-Received: by 2002:a17:906:b2c7:: with SMTP id cf7mr5764144ejb.128.1556574282792;
        Mon, 29 Apr 2019 14:44:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPXNMmNhHD//h2eVkQkiWBN98V1RoTLkZY6hkarTovnQ2RC672o89Mfmi4u/iFe+S/xYLg
X-Received: by 2002:a17:906:b2c7:: with SMTP id cf7mr5764119ejb.128.1556574282041;
        Mon, 29 Apr 2019 14:44:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556574282; cv=none;
        d=google.com; s=arc-20160816;
        b=fe3faDbYQBmao845CVGAQMl4UhnvHPY5P65ZeH3p7UEF0BpRvahL0ytEvLQwczuKUN
         yLliSJSXnneZm1gkdfKxcmhczt4p77tHX43pXZFq9b6lUJQfYlgXR5a7SAY7OoZEOAug
         gmopGx+1MrS0GLbehLm7GANysXOyRM3yoD7RSpeYQ5C3csH1ebtBCmmf/lLFvwOH0JRV
         C+xMlF4L+GPPsiJi3Q+MgOtFLwR1riCyrmi+8gqWCCeCnvifaagPZ1NL3DnvnPfqYawc
         muCdhCsz6b/Ga000PPd36qnFi+GxpyWv65zwfffc/PZ2tSOhFJXfIZX8Bh3GACaYmQgH
         wzWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8lRratGBW3Cv1VUXc207f1krtwK9gaDZv1xRcTehSm8=;
        b=G71jAtNwdOBOXohzgh8YgeRvbz32kFrsGUtn2P5ba0b/OyPFAcGn6VNTp8CR45tfCA
         PY2P23jCn+7IPx5564jI9ej0Zz+MGte2+pR5myGXjs9lz00RNs96nrwHHYG0fDJGgUXN
         zAPoZ9kmWoLGjS7rLmF7K3eyMGmR2GVGoytThy+h56ndx1LIgOvMsnIkY9f9jxoHE9jY
         hXDUHgP6G4plx+diqLp7h4DMKRKB/C2ifdILN7UmobfhNuVqtojhXVYwiRVCis3YMdk3
         Krcro054hjN9qKckzsR95hBuiOLjced4l9g7TPzLHxTb3b2epsCM7ilzuUEiG4+WEALU
         qm8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o12si2234819ejr.332.2019.04.29.14.44.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 14:44:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9DB26ABD7;
	Mon, 29 Apr 2019 21:44:41 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 932171E3BEC; Mon, 29 Apr 2019 23:44:40 +0200 (CEST)
Date: Mon, 29 Apr 2019 23:44:40 +0200
From: Jan Kara <jack@suse.cz>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: cluster-devel@redhat.com, Christoph Hellwig <hch@lst.de>,
	Bob Peterson <rpeterso@redhat.com>, Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v6 1/4] iomap: Clean up __generic_write_end calling
Message-ID: <20190429214440.GE1424@quack2.suse.cz>
References: <20190429163239.4874-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190429163239.4874-1-agruenba@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 29-04-19 18:32:36, Andreas Gruenbacher wrote:
> From: Christoph Hellwig <hch@lst.de>
> 
> Move the call to __generic_write_end into iomap_write_end instead of
> duplicating it in each of the three branches.  This requires open coding
> the generic_write_end for the buffer_head case.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/iomap.c | 18 ++++++++----------
>  1 file changed, 8 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/iomap.c b/fs/iomap.c
> index 97cb9d486a7d..2344c662e6fc 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -738,13 +738,11 @@ __iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
>  	 * uptodate page as a zero-length write, and force the caller to redo
>  	 * the whole thing.
>  	 */
> -	if (unlikely(copied < len && !PageUptodate(page))) {
> -		copied = 0;
> -	} else {
> -		iomap_set_range_uptodate(page, offset_in_page(pos), len);
> -		iomap_set_page_dirty(page);
> -	}
> -	return __generic_write_end(inode, pos, copied, page);
> +	if (unlikely(copied < len && !PageUptodate(page)))
> +		return 0;
> +	iomap_set_range_uptodate(page, offset_in_page(pos), len);
> +	iomap_set_page_dirty(page);
> +	return copied;
>  }
>  
>  static int
> @@ -761,7 +759,6 @@ iomap_write_end_inline(struct inode *inode, struct page *page,
>  	kunmap_atomic(addr);
>  
>  	mark_inode_dirty(inode);
> -	__generic_write_end(inode, pos, copied, page);
>  	return copied;
>  }
>  
> @@ -774,12 +771,13 @@ iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
>  	if (iomap->type == IOMAP_INLINE) {
>  		ret = iomap_write_end_inline(inode, page, iomap, pos, copied);
>  	} else if (iomap->flags & IOMAP_F_BUFFER_HEAD) {
> -		ret = generic_write_end(NULL, inode->i_mapping, pos, len,
> -				copied, page, NULL);
> +		ret = block_write_end(NULL, inode->i_mapping, pos, len, copied,
> +				page, NULL);
>  	} else {
>  		ret = __iomap_write_end(inode, pos, len, copied, page, iomap);
>  	}
>  
> +	ret = __generic_write_end(inode, pos, ret, page);
>  	if (iomap->page_done)
>  		iomap->page_done(inode, pos, copied, page, iomap);
>  
> -- 
> 2.20.1
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

