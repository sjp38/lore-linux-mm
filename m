Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC535C5ACAE
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 09:46:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADC0220856
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 09:46:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="aXpDJ9aB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADC0220856
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 490826B0003; Thu, 12 Sep 2019 05:46:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4404C6B0005; Thu, 12 Sep 2019 05:46:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32DF66B0006; Thu, 12 Sep 2019 05:46:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0081.hostedemail.com [216.40.44.81])
	by kanga.kvack.org (Postfix) with ESMTP id 0CF686B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 05:46:25 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id A48D01EF3
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 09:46:24 +0000 (UTC)
X-FDA: 75925788288.06.woman89_54faa50656424
X-HE-Tag: woman89_54faa50656424
X-Filterd-Recvd-Size: 5445
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 09:46:23 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id a23so21132284edv.5
        for <linux-mm@kvack.org>; Thu, 12 Sep 2019 02:46:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=+UyKiSlCaUkZGSuO0Sn5mI0OYBngHSXLKAH/562lIqI=;
        b=aXpDJ9aB0wt3TGU0/ZL7E4RmOYJxeN5X/S5JG56aeGrcXRjwWCzWTem0AkaoNFe990
         bbE9Omc+2tzXG9k75Ev0aAclSuz8BCC9xlRjcZY5SkuudR4RcJLpGcGK6TqZvqbiSrOn
         W0OEkpagpUWEmj45mgjtp27+YzCfGbvHnPUtQXLjRci0ORz4NZco6SDSjS6kxxeuNqf8
         dAMhtWIDh5TXG8Ti3lTRUNNrp3i/dODe9ejjJmlbJuL5Ie7yK+TxFSC20cIM2TwFaTV/
         KPVnBfabA9Ld+Zvd1kdKeLfKUdaRigCO94b1SCtPgCv0zksO1KPMyWvI+eaXpEFpfNPB
         gSjA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=+UyKiSlCaUkZGSuO0Sn5mI0OYBngHSXLKAH/562lIqI=;
        b=XiVwUb+dQ+XpegBdBEWYxhlN0l2/2PnlmZH1UNF4mAHpoBu43RKMTliPjMLZHrV+sa
         X3j69lbhHTHmgpQBZnUprBGxI6ESyOfkyTsXU7wcQczUJdPNi76Uj8HVGMBuT54haDJ7
         STdOWQdCDYU29V8mNhobLamCeVdpPHzIHixc0E50SKNNZmmnRpNedlfUZKZ/8vR5nPyy
         NFMAE72j4Mu6hJEzLOqKSs03ntWunAh9i7yYUUzyVgY5t28i5bSH0AIltB2+xJi2c7p8
         Umxq2IbIf8QNYjCkFyiPJkZVdKATqJFEG+JX6MW08P2X+8YB0bE9JyH0YbUGXhPLiPsx
         vqmA==
X-Gm-Message-State: APjAAAU6Csb3000D0v3+Cq/PUfY53VjtCo5Mkvbp5E8jjfYQaLapWX6T
	DxMzqQTA7DcEFKlx37LTjdsxUg==
X-Google-Smtp-Source: APXvYqzcJuQSNTfTiOqDf5b9PLpt0sipTAEEY55d+MmxRm6Hkg07fkj/J7ssBpH9EfThJXAmhT/EVw==
X-Received: by 2002:aa7:d899:: with SMTP id u25mr39791190edq.289.1568281582725;
        Thu, 12 Sep 2019 02:46:22 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id t21sm2728489ejf.27.2019.09.12.02.46.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Sep 2019 02:46:22 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 3884C100B4A; Thu, 12 Sep 2019 12:46:23 +0300 (+03)
Date: Thu, 12 Sep 2019 12:46:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Yu Zhao <yuzhao@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 2/4] mm: clean up validate_slab()
Message-ID: <20190912094623.fn6qdefrnnskdai5@box>
References: <20190912004401.jdemtajrspetk3fh@box>
 <20190912023111.219636-1-yuzhao@google.com>
 <20190912023111.219636-2-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190912023111.219636-2-yuzhao@google.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 11, 2019 at 08:31:09PM -0600, Yu Zhao wrote:
> The function doesn't need to return any value, and the check can be
> done in one pass.
> 
> There is a behavior change: before the patch, we stop at the first
> invalid free object; after the patch, we stop at the first invalid
> object, free or in use. This shouldn't matter because the original
> behavior isn't intended anyway.
> 
> Signed-off-by: Yu Zhao <yuzhao@google.com>
> ---
>  mm/slub.c | 21 ++++++++-------------
>  1 file changed, 8 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 62053ceb4464..7b7e1ee264ef 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -4386,31 +4386,26 @@ static int count_total(struct page *page)
>  #endif
>  
>  #ifdef CONFIG_SLUB_DEBUG
> -static int validate_slab(struct kmem_cache *s, struct page *page,
> +static void validate_slab(struct kmem_cache *s, struct page *page,
>  						unsigned long *map)
>  {
>  	void *p;
>  	void *addr = page_address(page);
>  
> -	if (!check_slab(s, page) ||
> -			!on_freelist(s, page, NULL))
> -		return 0;
> +	if (!check_slab(s, page) || !on_freelist(s, page, NULL))
> +		return;
>  
>  	/* Now we know that a valid freelist exists */
>  	bitmap_zero(map, page->objects);
>  
>  	get_map(s, page, map);
>  	for_each_object(p, s, addr, page->objects) {
> -		if (test_bit(slab_index(p, s, addr), map))
> -			if (!check_object(s, page, p, SLUB_RED_INACTIVE))
> -				return 0;
> -	}
> +		u8 val = test_bit(slab_index(p, s, addr), map) ?
> +			 SLUB_RED_INACTIVE : SLUB_RED_ACTIVE;

Proper 'if' would be more readable.

Other than that look fine to me.

>  
> -	for_each_object(p, s, addr, page->objects)
> -		if (!test_bit(slab_index(p, s, addr), map))
> -			if (!check_object(s, page, p, SLUB_RED_ACTIVE))
> -				return 0;
> -	return 1;
> +		if (!check_object(s, page, p, val))
> +			break;
> +	}
>  }
>  
>  static void validate_slab_slab(struct kmem_cache *s, struct page *page,
> -- 
> 2.23.0.162.g0b9fbb3734-goog
> 

-- 
 Kirill A. Shutemov

