Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08544C48BE3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 08:11:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB343208CA
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 08:11:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB343208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FE936B0005; Fri, 21 Jun 2019 04:11:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B0D08E0002; Fri, 21 Jun 2019 04:11:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB88D8E0001; Fri, 21 Jun 2019 04:11:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A0EC06B0005
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 04:11:51 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i9so8112462edr.13
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 01:11:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=7i6dJlpycYYkF3HawzKcEbdgni5ZrmtRBp3Gy0v9tRc=;
        b=HBMZyGx6zjLlhg5/SNSk1ujQssTMXvfw1U15cz8YGfpPfUFaJYO2DazYg5mmsDG4Z1
         R5Y7HGXK+zV6JmYptg9k7zfThBUcYwgWPIxaasw7vBA7uefJVLRi+vGSyXe8QXlANsTh
         ypc0TfpPFB6EwsKKc0/f/7PGZIv91gA3TXJKI1DNdl+qC9Bhe/26NgySZ/Q6LoX8pLKU
         6UikwkcOG7/KhSZoKeyWDLXGiOV5Y5dSvzAnN+Jpsxhr5d39qElhjwAUissj09AqQWZX
         PU7ROtT9uRUM8K/9DI8cGypp+nwi46XksYMID2gJ5x0kEPLA7N/UyuxrINX0mq2Qyjqg
         lKuQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUPusGwGPYmB76eF0D4vhdb1Kw7lQdz1ssB4KVKP+w1loYmep7P
	thWXzGiax7wmWn4asvHN3+P4O7OIhLedzo4NRSSEzeYsZA3FlIon4d96tRKCBDdEwgpvisg1DhE
	lCBIegD18D0CJPDhEL3nFhtBvWW2aFqXYn7p0ALG011m9trubhEO9lt7VWTH8RFU=
X-Received: by 2002:a50:87d0:: with SMTP id 16mr91868011edz.133.1561104710921;
        Fri, 21 Jun 2019 01:11:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWF1vYwc95ZxhkG9DE3Mj561j5nJJf/Ke6XtjokJVy3cJf0C+ISWHYAIyHvS8s+lW7ohDS
X-Received: by 2002:a50:87d0:: with SMTP id 16mr91867943edz.133.1561104710027;
        Fri, 21 Jun 2019 01:11:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561104710; cv=none;
        d=google.com; s=arc-20160816;
        b=d6tzfLAW95G3ynqCtsGW1hAWALqaHAixNYsBumJvgAh4RE5NkdX/u3Wy4BCqpfxhNJ
         QO1lk5Ia0zGquAaQmlaabSo+8nuyUzKqTCzQh2lfKzL00vR79n9ihs5AyYpXnRx6Nbxq
         euv2bFt8PHd4Bul3s2xA9iE1uVrleNJIBgRz0/HSuzse7VSQC5gof/DFhk2FPJDw/gzA
         B+bGTjnTW1baLrTHIns3NFqoDTRztCm+gRiYbtcnJj8HeHhwzWZ4KxY3VtSLw170yHbb
         2OO8bePWNfWGDq0J8pRVifP0DD7w28I4g1HWL7DXbKnROY9Cazp3KyXF7UEikBGOhspt
         V++w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=7i6dJlpycYYkF3HawzKcEbdgni5ZrmtRBp3Gy0v9tRc=;
        b=s+ZwzhKqLsAPAVtPLQTrWs2Yq0EwrB15K1S20/A/3sQoW8zi0n9E0c5vrlNZ/n16JL
         K25/9ujwhnN06LqFpwQAZBgy8qDjzNNC8n21tpgq09FBRGthgxn6hRo9oA4GFHi4Hja+
         FWtxUhptBqOrNvlNvml4shMiJSqr8auusACB7qV3yRHJl8nbCIdTHL3pHCSE+NLRZ2j+
         C9uXI/0g/8Rlo0hGN0GqSnp+SZ+iqZV8zcovxWOjPu7ypFZkGU/G9rmyrJ03x9ZbBEAk
         7pMoxV/k8tcpRtebUUrYA245rzCj1YZ6wM4Boa0IuA5HAuJxDuduh+baGuQvLUakmM5i
         uMFg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gf12si1337222ejb.392.2019.06.21.01.11.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 01:11:49 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5292CAF50;
	Fri, 21 Jun 2019 08:11:49 +0000 (UTC)
Date: Fri, 21 Jun 2019 10:11:47 +0200
From: Michal Hocko <mhocko@kernel.org>
To: ira.weiny@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v4] mm/swap: Fix release_pages() when releasing devmap
 pages
Message-ID: <20190621081147.GC3429@dhcp22.suse.cz>
References: <20190605214922.17684-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190605214922.17684-1-ira.weiny@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Sorry for a late reply.

On Wed 05-06-19 14:49:22, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> release_pages() is an optimized version of a loop around put_page().
> Unfortunately for devmap pages the logic is not entirely correct in
> release_pages().  This is because device pages can be more than type
> MEMORY_DEVICE_PUBLIC.  There are in fact 4 types, private, public, FS
> DAX, and PCI P2PDMA.  Some of these have specific needs to "put" the
> page while others do not.
> 
> This logic to handle any special needs is contained in
> put_devmap_managed_page().  Therefore all devmap pages should be
> processed by this function where we can contain the correct logic for a
> page put.
> 
> Handle all device type pages within release_pages() by calling
> put_devmap_managed_page() on all devmap pages.  If
> put_devmap_managed_page() returns true the page has been put and we
> continue with the next page.  A false return of
> put_devmap_managed_page() means the page did not require special
> processing and should fall to "normal" processing.
> 
> This was found via code inspection while determining if release_pages()
> and the new put_user_pages() could be interchangeable.[1]

This is much more clear than the previous version I've looked at. Thanks
a lot!
> 
> [1] https://lore.kernel.org/lkml/20190523172852.GA27175@iweiny-DESK2.sc.intel.com/
> 
> Cc: Jérôme Glisse <jglisse@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> 
> ---
> Changes from V3:
> 	Update comment to the one provided by John
> 
> Changes from V2:
> 	Update changelog for more clarity as requested by Michal
> 	Update comment WRT "failing" of put_devmap_managed_page()
> 
> Changes from V1:
> 	Add comment clarifying that put_devmap_managed_page() can still
> 	fail.
> 	Add Reviewed-by tags.
> 
>  mm/swap.c | 13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 7ede3eddc12a..607c48229a1d 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -740,15 +740,20 @@ void release_pages(struct page **pages, int nr)
>  		if (is_huge_zero_page(page))
>  			continue;
>  
> -		/* Device public page can not be huge page */
> -		if (is_device_public_page(page)) {
> +		if (is_zone_device_page(page)) {
>  			if (locked_pgdat) {
>  				spin_unlock_irqrestore(&locked_pgdat->lru_lock,
>  						       flags);
>  				locked_pgdat = NULL;
>  			}
> -			put_devmap_managed_page(page);
> -			continue;
> +			/*
> +			 * ZONE_DEVICE pages that return 'false' from
> +			 * put_devmap_managed_page() do not require special
> +			 * processing, and instead, expect a call to
> +			 * put_page_testzero().
> +			 */
> +			if (put_devmap_managed_page(page))
> +				continue;
>  		}
>  
>  		page = compound_head(page);
> -- 
> 2.20.1
> 

-- 
Michal Hocko
SUSE Labs

