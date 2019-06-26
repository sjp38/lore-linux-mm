Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB8E8C4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:23:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84BF02085A
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:23:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84BF02085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16D2D8E0005; Wed, 26 Jun 2019 02:23:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11E4D8E0002; Wed, 26 Jun 2019 02:23:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00D8E8E0005; Wed, 26 Jun 2019 02:23:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A75AC8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:23:46 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y24so1626557edb.1
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:23:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SCQaZzbSxKSrAH0VgiQraIY2A91MTXFvXV8mrRzOWtY=;
        b=WhyUJlxlN1wvlLIck3EKFkqi6vFjGBHBJH0P3poi25VVG5YWLtMuzcAG0lEyLLQQBu
         94HLW52SZWzFgY9KcohRJUbiKkcLOVCDNHf+nB3W+M6OrfOd+9TU+MNgWWVGJZ7JsP7R
         6O/2W8d3cwrCPZrzpmfn5DwsuMJKOR7u8wQC4lKbuH7EL4C6ivkTmjuTjQMQbyVk1Xin
         fhbc2w4THoSa1p47Jn2yfft9d3ArNWou8Wt2N3zCKe3U6n//62cYotKdZV9b8Tk+9rWC
         V8o7ykWsQs39+c6vslDAJMQWnfdnX7jwHcNG4gzo3z99dOI0vHit0HtX4mSiCiJJiocF
         zTOw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX8pdF2DfX6Zx52lV7jH5tiTwz6s5Y5oZFk2k6WtNpfsF3su3V5
	RhsBpneqvNs9rfUCwJe4R3R0ZU0BsYHGm1sKqtX0CBtx2+mBCzs0346zNOcC23gL6wQbKjf2waO
	JmCxlYi4Q2yLf8iQ78VeBx2EMW0xZJfOsDjZd/a8T7VJwHSvh/E08SPETL9Lw2KI=
X-Received: by 2002:a17:906:2f15:: with SMTP id v21mr2415425eji.113.1561530226232;
        Tue, 25 Jun 2019 23:23:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHotNYsRzLrfLYYwA6ihMAqTO2pqc3+xqugwD+rXH34gkUoC61LB728ClmjGEZ8ao4rfwY
X-Received: by 2002:a17:906:2f15:: with SMTP id v21mr2415391eji.113.1561530225548;
        Tue, 25 Jun 2019 23:23:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561530225; cv=none;
        d=google.com; s=arc-20160816;
        b=wD+8+vtQN/8G1lUfcTcSLRH+SZej/NmxdHUNJqBRsOyatcs8mMuPnReD+/vRMCQ9Tw
         vXii3cbk8S+3eIPGqzfIi14akQO78JLwkD8KLKXgsXUHKnRO9rvJFi3OafIXqUClJV33
         goEbvKLz9Nt8NjwIvGB1nRtPl6Wn4BLNqLXJPza2LmpbLP/SEnxOwa47E4bRqql6Zw2r
         eE/dopfXeu33hgCngGRdO03UOcY8jUlSlCK6oCg5HGt7koDXcYhhwoDQpX0U5/fqAqCU
         7Z8GbE+XVtEU5DiNS65wlpE9CxPw4nZzfqv0J5h+5S7FgMLKpPY/MoUIma/SUk/Vu67W
         Hivw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SCQaZzbSxKSrAH0VgiQraIY2A91MTXFvXV8mrRzOWtY=;
        b=Ru5ddtCr+XTPSy9zFea4ypgJ8Nl7PXlmSsQO89vmOY2Wjk0Q4SF2XoIqejxXvb5MX2
         zDNdPi0lT5ZLgro7N/M76ljbLhh0YMct2mqkawlcKqW4bV12RHDiZVBZTAFJGw9KfsAx
         aIEDo3yqCtDZDijnk9Qw5DZRJYWHF48rzlWBWa7auKKe1Og5uSTOyH6UherCdgfRMyQk
         6DZHfeqLVEibUGtVkupLg/CYberxi94WqC69GHb5n34zisLV/SCjUP4VELw4ylqAOXey
         6u4nahW3/EjCy0SH60ztS3bWAx+hrbivoGSe3nnsVx0KuT9LAr3TFhZe94zoZJrBhYAs
         x/AA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v1si1867514ejd.397.2019.06.25.23.23.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 23:23:45 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0BAE6AD47;
	Wed, 26 Jun 2019 06:23:45 +0000 (UTC)
Date: Wed, 26 Jun 2019 08:23:44 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alastair D'Silva <alastair@au1.ibm.com>
Cc: alastair@d-silva.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Oscar Salvador <osalvador@suse.de>,
	Mike Rapoport <rppt@linux.ibm.com>, Baoquan He <bhe@redhat.com>,
	Qian Cai <cai@lca.pw>, Logan Gunthorpe <logang@deltatee.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v2 2/3] mm: don't hide potentially null memmap pointer in
 sparse_remove_one_section
Message-ID: <20190626062344.GG17798@dhcp22.suse.cz>
References: <20190626061124.16013-1-alastair@au1.ibm.com>
 <20190626061124.16013-3-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626061124.16013-3-alastair@au1.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 26-06-19 16:11:22, Alastair D'Silva wrote:
> From: Alastair D'Silva <alastair@d-silva.org>
> 
> By adding offset to memmap before passing it in to clear_hwpoisoned_pages,
> we hide a potentially null memmap from the null check inside
> clear_hwpoisoned_pages.
> 
> This patch passes the offset to clear_hwpoisoned_pages instead, allowing
> memmap to successfully peform it's null check.

Same issue with the changelog as the previous patch (missing WHY).

> 
> Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
> ---
>  mm/sparse.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 57a1a3d9c1cf..1ec32aef5590 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -753,7 +753,8 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  #ifdef CONFIG_MEMORY_FAILURE
> -static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
> +static void clear_hwpoisoned_pages(struct page *memmap,
> +		unsigned long start, unsigned long count)
>  {
>  	int i;
>  
> @@ -769,7 +770,7 @@ static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
>  	if (atomic_long_read(&num_poisoned_pages) == 0)
>  		return;
>  
> -	for (i = 0; i < nr_pages; i++) {
> +	for (i = start; i < start + count; i++) {
>  		if (PageHWPoison(&memmap[i])) {
>  			atomic_long_sub(1, &num_poisoned_pages);
>  			ClearPageHWPoison(&memmap[i]);
> @@ -777,7 +778,8 @@ static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
>  	}
>  }
>  #else
> -static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
> +static inline void clear_hwpoisoned_pages(struct page *memmap,
> +		unsigned long start, unsigned long count)
>  {
>  }
>  #endif
> @@ -824,7 +826,7 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
>  		ms->pageblock_flags = NULL;
>  	}
>  
> -	clear_hwpoisoned_pages(memmap + map_offset,
> +	clear_hwpoisoned_pages(memmap, map_offset,
>  			PAGES_PER_SECTION - map_offset);
>  	free_section_usemap(memmap, usemap, altmap);
>  }
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs

