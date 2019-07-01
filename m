Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9708FC0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 07:42:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 649732054F
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 07:42:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 649732054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E95CC8E0005; Mon,  1 Jul 2019 03:42:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E46FF8E0002; Mon,  1 Jul 2019 03:42:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D35A28E0005; Mon,  1 Jul 2019 03:42:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f80.google.com (mail-ed1-f80.google.com [209.85.208.80])
	by kanga.kvack.org (Postfix) with ESMTP id 83DF58E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 03:42:06 -0400 (EDT)
Received: by mail-ed1-f80.google.com with SMTP id i44so16297589eda.3
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 00:42:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6R+PwvpfFiaEmtQRre/5mca+3AZ4ZJ2JN2BqgUYVfuQ=;
        b=LdtOo6Hiybzij5L0AVPfRx5Xi2Zkp9PbjJdVeKZXJkk83cw6mAXuy9gchsDqg0schz
         hiz9VkbytTl+g6gdGNjzvo0I0oJP4Te0OFBZkrHzW8x1aYQidKqLLMuAv3RD2mxNgR6f
         l9msKW2uJ0EGEtw9TPsWYTmjere+0cetcMzbGROLAVzAY9O4zYjrnrThTFfiw0pvLPfe
         GZGLitxLu9VLDW0cYJiK7iI32ECamjZ0S8hyuXRV0tzWLMKoHsZ30g8mgQAHsdox5Ab7
         xSqguuQQWDR6/PFQTj9+xC2l6y6NZ8VM/JuE6zi34lnYpyanfek2ZdQE7DnYyQsLonau
         cRvQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVn9pKpXTZd93G84maCN03fWFOAllHCYtP9KOGZvUtiIVhT1bIx
	GbEctndqBQQlf38Xu6i9xmlFBFTxJZZ8aVext1V6qsKwwOllT1pNpJqCusEfI1dBDeREm1W+gZP
	1VpU/kWPxelQRVkOTnMGXJTtxyIEJV/yq/VIjs+n0b0/6q7VTvD+IJ8Pa4vSfoHk=
X-Received: by 2002:a17:907:2161:: with SMTP id rl1mr13181538ejb.8.1561966926076;
        Mon, 01 Jul 2019 00:42:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSUggn156lrVpW2AeVQora2k//XAFgqP0xJY/1vUd5H1ueuyfzOI1UCE4t+fFWbiVwIeXb
X-Received: by 2002:a17:907:2161:: with SMTP id rl1mr13181483ejb.8.1561966925250;
        Mon, 01 Jul 2019 00:42:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561966925; cv=none;
        d=google.com; s=arc-20160816;
        b=R7t4Q/YO3SPjnjlycbVQrfDZpKrR2a8TJF1LyOuouJ16arXie8UqBtNFKdWwDbca33
         2k5KbKLTutxpD4azZKRoVV6WR2+nkb03iguALjOEDVmogR5UiWKb4MGWh6ikIDlsZKHl
         nfB9xd9Rei80Sw0l3VlljmAW0JnVhZU0BmYdVUq4n/e3pCMwD4j+XS8td8mg3A2x+fP9
         kRmrLKwc/OQNDKXDbVl/1J6OnnV3gV47+M+WmAXksqa5zqyKzd9AD0FJtBBJDH8zokpE
         yM3080LpuKdPbzfRgISzXxz9wqgMrXuYkvHw5ZGCNmfyvpvyts4AvqBKwoTET2lkRVVe
         fYGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6R+PwvpfFiaEmtQRre/5mca+3AZ4ZJ2JN2BqgUYVfuQ=;
        b=dFvcQi5IpX6P+Gxe/veayQFyd5Z065rqAax6b5WjVh0W/5vVwy+220lHSf3NEjicKs
         zx+VxxC6JDu4WVipC+fk0xTackI/5cIi+MnNQyqXJjCjVZWpV6kXMDkGhYKwMDRufoQ/
         mZ5875u3cDhTsZC5QFQmKgsmjNBZ4JHRP6208eDUTflHXxrurFY9i6LamhfKS6NPo8UC
         ydk0elyTXaHmRsmyvfvaWBvadwHQBekqL8DoQBBy+VNjTxJdzpTgHCEJ01oAff+Q8DDn
         mNcMmfVzOBFk6EIuPkINvU3QEYsbZQWYjZ5CcLt40AMTpZky+JjsigPQsdYjnbMBsqn6
         GvKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q14si8345651edd.22.2019.07.01.00.42.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 00:42:05 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5F478AFFA;
	Mon,  1 Jul 2019 07:42:04 +0000 (UTC)
Date: Mon, 1 Jul 2019 09:42:02 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: Re: [PATCH v3 01/11] mm/memory_hotplug: Simplify and fix
 check_hotplug_memory_range()
Message-ID: <20190701074202.GB6376@dhcp22.suse.cz>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-2-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-2-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Sorry for a really late response]

On Mon 27-05-19 13:11:42, David Hildenbrand wrote:
> By converting start and size to page granularity, we actually ignore
> unaligned parts within a page instead of properly bailing out with an
> error.

I do not expect any code path would ever provide an unaligned address
and even if it did then rounding that to a pfn doesn't sound like a
terrible thing to do. Anyway this removes few lines so why not.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> Reviewed-by: Wei Yang <richardw.yang@linux.intel.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memory_hotplug.c | 11 +++--------
>  1 file changed, 3 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index e096c987d261..762887b2358b 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1051,16 +1051,11 @@ int try_online_node(int nid)
>  
>  static int check_hotplug_memory_range(u64 start, u64 size)
>  {
> -	unsigned long block_sz = memory_block_size_bytes();
> -	u64 block_nr_pages = block_sz >> PAGE_SHIFT;
> -	u64 nr_pages = size >> PAGE_SHIFT;
> -	u64 start_pfn = PFN_DOWN(start);
> -
>  	/* memory range must be block size aligned */
> -	if (!nr_pages || !IS_ALIGNED(start_pfn, block_nr_pages) ||
> -	    !IS_ALIGNED(nr_pages, block_nr_pages)) {
> +	if (!size || !IS_ALIGNED(start, memory_block_size_bytes()) ||
> +	    !IS_ALIGNED(size, memory_block_size_bytes())) {
>  		pr_err("Block size [%#lx] unaligned hotplug range: start %#llx, size %#llx",
> -		       block_sz, start, size);
> +		       memory_block_size_bytes(), start, size);
>  		return -EINVAL;
>  	}
>  
> -- 
> 2.20.1
> 

-- 
Michal Hocko
SUSE Labs

