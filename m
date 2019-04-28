Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.7 required=3.0 tests=DATE_IN_PAST_12_24,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9B30C04AA6
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 11:39:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F88620673
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 11:39:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F88620673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E053A6B0003; Mon, 29 Apr 2019 07:39:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB5746B0005; Mon, 29 Apr 2019 07:39:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7D1A6B0007; Mon, 29 Apr 2019 07:39:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 75CEE6B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 07:39:52 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o8so4692499edh.12
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 04:39:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SBTFhW2tds2NpY2EgDOKky4WTtCOEsy9pYIImYgy518=;
        b=OWIISavgtvH6sxnp9Oa74zTYqEgvPOqMincJ1CRjdiQl4H8uOpUW8yOy50w4DYnyHg
         o9o1UkBdW60V0D2U0fOphnzKREKSty2jMFKr30w1C321ffALaioOHbaczL6PNOMMRlZp
         eOkF4VRkSMKA1l/p6pf54SHnK0INSNPvkJjpx8y1LlWms5k3d4dXu6Q7QakTpCc0QMia
         0JmGfXazCzaDYznbT8eInClMbapfTegrzA8jkHmXCqcmg5NTP7oCyflgiOUPnwY8nHYa
         ilmZBDpCZhao21c0ZcpsmipKetsW0wx9uHHVm/fkOdY+ryGQwqFiKlnDOk+z3Ui7GmzP
         WhHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAV+dCTowHG8qmgJMWot+HqeiZvA1+QS5UPjrM1pFmcHjcJ89rhg
	koUy27xHle06ikJqzbOxJOs+xgOQkUXiMG0lgp+AjZoIwxjmDdq49WGCVaQpf/QVWQPvFli6/gn
	74eIIJ6OHTS6/mLV+ltAGgVgWU+nGMJ8up5Hh00+O69VwtFg4CYjOKvSlaNNwQKAFCA==
X-Received: by 2002:a50:98c2:: with SMTP id j60mr27340023edb.128.1556537992062;
        Mon, 29 Apr 2019 04:39:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQHotpF4UDQoIx4WtVLchu7sMU9FgUTjFqJQrtaJcYg8M1YK+73/mrjmLbK4q6Doo9hv3I
X-Received: by 2002:a50:98c2:: with SMTP id j60mr27339982edb.128.1556537991177;
        Mon, 29 Apr 2019 04:39:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556537991; cv=none;
        d=google.com; s=arc-20160816;
        b=IdDfOuwkhs49vVXGpM9v6bj4VVcUcQXzvuGsYGcSB6dAQp5k1Gfs9ZswsXyZwx1hDG
         mDH8vAeUv6ZRbz+4F2Cfk8+8HMQarVPwKUVKOQgC/G7k4I1LGeFRsSRAJ0iT+bH+jGDP
         Bzw5YJHdTpsHYby2v5mdXj2FRmVB5CbDA0BjlbLGw4Pcg8GerSdwZ/xvDnGOnrMN/odW
         uIeb6rG8z2RnKM0U6Bs1aZnCIe1QXQZ7Ji8f4KtVCKm0BJ1sL8Tp2o4OANgOeXfuuEkk
         mJuOh1sQk4mInu3Pml5hgVKJ9S0RBIZeLUKOXblQcv6YRjWQ3NJTRnWAoy7zBu6OkPJy
         xQLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SBTFhW2tds2NpY2EgDOKky4WTtCOEsy9pYIImYgy518=;
        b=NqFF9/a3MVZPH6g5QnnVkGfOQZb3cd5DW74T6+sTvEzqXlx3n5dPJVa/xIVvrum0cv
         7yyuiN8eEiISXduH9UAW1mw65rvUC8YuF3N5tZUOVIYGumPv/SFs0Du6zmHpLQGCbEc7
         PA78+UWl4H6XyP0FfIYPk3yN2RCvkLpzNi7j/RiGlh2KY7P0WzqB0xYMYRq6/9p3kela
         IYIzIiJ6Hj+6w6rOICJFYdl57Vt2jaWqdyXD2661hMzRx7Km3NabBan931V06UNiAylY
         KRQWCfWVgqBxhuv7a1ML+EhUpuDX1KuPCR99/B8cE/kN6TgJ04rQGKcxpYbLWsoJrxHZ
         F3Gg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n25si3751355ejd.172.2019.04.29.04.39.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 04:39:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4EE20AE20;
	Mon, 29 Apr 2019 11:39:50 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 820AF1E3BF3; Sun, 28 Apr 2019 21:20:29 +0200 (CEST)
Date: Sun, 28 Apr 2019 21:20:29 +0200
From: Jan Kara <jack@suse.cz>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: cluster-devel@redhat.com, Christoph Hellwig <hch@lst.de>,
	Bob Peterson <rpeterso@redhat.com>, Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v5 1/3] iomap: Fix use-after-free error in page_done
 callback
Message-ID: <20190428192029.GB7441@quack2>
References: <20190426131127.19164-1-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190426131127.19164-1-agruenba@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 26-04-19 15:11:25, Andreas Gruenbacher wrote:
> In iomap_write_end, we are not holding a page reference anymore when
> calling the page_done callback, but the callback needs that reference to
> access the page.
> 
> To fix that, move the put_page call in __generic_write_end into the
> callers of __generic_write_end.  Then, in iomap_write_end, put the page
> after calling the page_done callback.
> 
> Reported-by: Jan Kara <jack@suse.cz>
> Fixes: 63899c6f8851 ("iomap: add a page_done callback")
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>

The patch looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/buffer.c |  5 +++--
>  fs/iomap.c  | 12 ++++++++++--
>  2 files changed, 13 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/buffer.c b/fs/buffer.c
> index ce357602f471..6e2c95160ce3 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -2104,7 +2104,6 @@ int __generic_write_end(struct inode *inode, loff_t pos, unsigned copied,
>  	}
>  
>  	unlock_page(page);
> -	put_page(page);
>  
>  	if (old_size < pos)
>  		pagecache_isize_extended(inode, old_size, pos);
> @@ -2160,7 +2159,9 @@ int generic_write_end(struct file *file, struct address_space *mapping,
>  			struct page *page, void *fsdata)
>  {
>  	copied = block_write_end(file, mapping, pos, len, copied, page, fsdata);
> -	return __generic_write_end(mapping->host, pos, copied, page);
> +	copied = __generic_write_end(mapping->host, pos, copied, page);
> +	put_page(page);
> +	return copied;
>  }
>  EXPORT_SYMBOL(generic_write_end);
>  
> diff --git a/fs/iomap.c b/fs/iomap.c
> index 97cb9d486a7d..3e4652dac9d9 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -765,6 +765,14 @@ iomap_write_end_inline(struct inode *inode, struct page *page,
>  	return copied;
>  }
>  
> +static int
> +buffer_write_end(struct address_space *mapping, loff_t pos, loff_t len,
> +		unsigned copied, struct page *page)
> +{
> +	copied = block_write_end(NULL, mapping, pos, len, copied, page, NULL);
> +	return __generic_write_end(mapping->host, pos, copied, page);
> +}
> +
>  static int
>  iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
>  		unsigned copied, struct page *page, struct iomap *iomap)
> @@ -774,14 +782,14 @@ iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
>  	if (iomap->type == IOMAP_INLINE) {
>  		ret = iomap_write_end_inline(inode, page, iomap, pos, copied);
>  	} else if (iomap->flags & IOMAP_F_BUFFER_HEAD) {
> -		ret = generic_write_end(NULL, inode->i_mapping, pos, len,
> -				copied, page, NULL);
> +		ret = buffer_write_end(inode->i_mapping, pos, len, copied, page);
>  	} else {
>  		ret = __iomap_write_end(inode, pos, len, copied, page, iomap);
>  	}
>  
>  	if (iomap->page_done)
>  		iomap->page_done(inode, pos, copied, page, iomap);
> +	put_page(page);
>  
>  	if (ret < len)
>  		iomap_write_failed(inode, pos, len);
> -- 
> 2.20.1
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

