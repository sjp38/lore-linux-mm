Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CE40C04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 15:01:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 41C982182B
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 15:01:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41C982182B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 948E86B0270; Mon, 27 May 2019 11:01:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D1FA6B0272; Mon, 27 May 2019 11:01:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 774076B0281; Mon, 27 May 2019 11:01:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 26C6E6B0270
	for <linux-mm@kvack.org>; Mon, 27 May 2019 11:01:13 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c1so28379395edi.20
        for <linux-mm@kvack.org>; Mon, 27 May 2019 08:01:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=1GNZVkr57fgdF1rUp1cbQT5WCv4nVhkLxgTXkpSsqfk=;
        b=BkZtW+8IbNwV3V2gKH8Su9YqBvmStLdXhvyryLZvzIo3qMqriBW0QNMZx+KnYghJo2
         lsPyT/x7yGbgWuoIH9PFUJqv+8t6iEZ+Hb+5UXF0yTCcjRcuma6F3jR0+/C4j1CHgn+u
         niIBydpSBElNVf1koMxZwpsxDfvbMKK/c+KL47MaflZyGi7mOpnMPfIAWIGuoAW2Nqph
         YC4bDAR0zhAD3C4aYYbkIahMiIJ2W3GMLz+JXurCJ1e/JfmpqFgTGB6nh95SwhBOq/z2
         9f6gRPzY7AsufWvhX5L8HsRK677R52apMnWEznY3SxzITJ94ssqKVd1cfR1KLdh+inzv
         wWFA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVeWn8jUHVw3ufKKVu1xCYbwZh2dEMiC2do+ULVlcdqe2w/4Xmj
	FSvWrRDRKVwD9T1zuzev5bmxYT0kyM1XBHFv1xfQsZxktXWbABzyW7EmLwin5xJH6q+6VpTn5i1
	Turufssr1BnZ+dlK41qU0khxD+JxmKqRmVPXqhfVuJEqhi6ELzzlvi8MnCiSRdwo=
X-Received: by 2002:a50:89b0:: with SMTP id g45mr124140509edg.200.1558969272695;
        Mon, 27 May 2019 08:01:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWRVPaIBUcnO4Jap+y/jGsY1Z7WiL2t+rlyjIV3HotU/4HCouWCikJ5xekzip4yKzUqugy
X-Received: by 2002:a50:89b0:: with SMTP id g45mr124140166edg.200.1558969269825;
        Mon, 27 May 2019 08:01:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558969269; cv=none;
        d=google.com; s=arc-20160816;
        b=QGCQhmJ8Z4ogb0LlS0z49+9RQFHgoIinSqaP7XuqQ5/mtmpD90MtF8WMpcvn1RdxsW
         dSaKAIt1L+RS9s7EBRpbcuOJcmOQ62ebZGX6AIYaR9elMJ7kh67XIGsa+2J6hDnbakcd
         QSA0ORZQfh6ChzGKMIQIPEUxJQqPuYOW+PAguqqAueJo0INoUesVB+TXOdfXsNPMEK0K
         udAIg7B9CT1Nst/vIFP3v0iV5VrY1xXyuwhWsiU1oskCv80BJIHZlYNZqOU/aszZtgNU
         yxPZOyMXFLL1IPe+l84KhpWaPC/44vtoXxWjMhJQHyyLnuC5CAwpvBWB3ZwO/u4xeV0u
         L3+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=1GNZVkr57fgdF1rUp1cbQT5WCv4nVhkLxgTXkpSsqfk=;
        b=foPw8pHgWjO5PiRAcFiDYgCTb7uBFi0F2C7wkE2bMvSOlMfe/VUm3RRSVGgFbIEi8L
         uzjBcovH9mH2MYC8ES/mO8zI86oQZCjGbcBVAlDgBeBg2d2qxEX1eXy71ThkgbxmBgy0
         pjCsqFD5Q1C9AiC0A1XZqFO1kA1nK98w+QhybSQuNfjYzMr5N9JpYiOOOGP9srcNJ75V
         L1LqVzbQpqriX6Mjq2EtcFfssBp0Hp4i3c8cJmURnyonk0XoLEF2mkhvsfnw8Faj37rb
         CUGws1DKc5D9f0mPxJ9GbCmIvMdz3m3ELV1bhWuaTrvtrZNOy4axJXoVXA3U86rIG8Ox
         IFfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e36si8950507ede.438.2019.05.27.08.01.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 08:01:09 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 065A5AE74;
	Mon, 27 May 2019 15:01:08 +0000 (UTC)
Date: Mon, 27 May 2019 17:01:07 +0200
From: Michal Hocko <mhocko@kernel.org>
To: ira.weiny@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2] mm/swap: Fix release_pages() when releasing devmap
 pages
Message-ID: <20190527150107.GG1658@dhcp22.suse.cz>
References: <20190524173656.8339-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190524173656.8339-1-ira.weiny@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 24-05-19 10:36:56, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> Device pages can be more than type MEMORY_DEVICE_PUBLIC.
> 
> Handle all device pages within release_pages()
> 
> This was found via code inspection while determining if release_pages()
> and the new put_user_pages() could be interchangeable.

Please expand more about who is such a user and why does it use
release_pages rather than put_*page API. The above changelog doesn't
really help understanding what is the actual problem. I also do not
understand the fix and a failure mode from release_pages is just scary.
It is basically impossible to handle the error case. So what is going on
here?

> Cc: Jérôme Glisse <jglisse@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> 
> ---
> Changes from V1:
> 	Add comment clarifying that put_devmap_managed_page() can still
> 	fail.
> 	Add Reviewed-by tags.
> 
>  mm/swap.c | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 9d0432baddb0..f03b7b4bfb4f 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -740,15 +740,18 @@ void release_pages(struct page **pages, int nr)
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
> +			 * zone-device-pages can still fail here and will
> +			 * therefore need put_page_testzero()
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

