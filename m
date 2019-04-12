Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E716EC10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 11:59:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86B022082E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 11:59:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86B022082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D0E396B0010; Fri, 12 Apr 2019 07:59:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C965E6B026A; Fri, 12 Apr 2019 07:59:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B36C06B026B; Fri, 12 Apr 2019 07:59:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6084C6B0010
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 07:59:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p88so4743702edd.17
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 04:59:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=t5TYhZmnd5L+AXUdP/jm/jEk3u8WIGaRjpSweCd/7YQ=;
        b=WWBBu4G5C9zotSysByuM8DcKWmNCqHlI1SzOyDbYmLmMuWIg6FGKeOW0mAR9DW85cs
         sV9L4o+wAbz8iF3IJL71nlP+MMZn0MAj9kGfp/noeYyj8Of2IPzOSVzt5F5d/UpSquzk
         F6+fvvO5WUJxbY2tFKRq49MDGeRgmtR6bnuv9jAQom+wmSw4QuqbxvyUm8eYp+pD1x2P
         j7bj/8ikycmR2kETDJFrct5RsI475qAzywx3bZKDus6YQoyAOBG1PSk+Wbgpi3+pcO73
         hZPJnf16VdaC8V8jyFoidGwwliYg/EEs8bIP1Au4P24ndS60qq0aDKkObKHhf53sniPR
         Ayhw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWJx9fH8wf1epKnXadHY0RKHh1mg841PavjC+wUvdoCe4Y6Ft/s
	17oQ6jLDJvp9abIcY2tXKYqHMXLdQcdfcSiOK2oeKOaHlPmvtdlGxGVW4bhlPS+5MR9HFa3DsFa
	mw5zfMyHCNLEJKlCYatW5zQy/SzBVRuI8Q83ZOm+s0Wgo6dzEqFeSMPl5F/LgtWA=
X-Received: by 2002:a17:906:a4b:: with SMTP id x11mr31066060ejf.200.1555070377796;
        Fri, 12 Apr 2019 04:59:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjNmkcJsxg2AKGhkU9w3TIJsHs4IuP3jfeBHdyw3SUKmng146etIp8uKNKNsvISJcyuzPV
X-Received: by 2002:a17:906:a4b:: with SMTP id x11mr31066006ejf.200.1555070376633;
        Fri, 12 Apr 2019 04:59:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555070376; cv=none;
        d=google.com; s=arc-20160816;
        b=vZxVhrWgUxTP5UbiwWAyGPQ8anqGfK2zQWG+9LjLysfAoZ1li34FNps6CsCVOeEaA3
         rRHXZfsWyRSWcfrjzfbr0abhY3dibl4rLQ9hJCixaLnP6dkR9nGK02eq2CKkxImDP8HM
         sgMh4awvNcuxxNxiDHE9xMq54vrk5h0magInXT2D6QhL3PDMUWkGqro5Ne8Xk54MS3Gj
         B+ytjQ5zLhxmyejgZ1R2qzImKq3bAEqpjhV++f8MDEy4A+sw+g4MFSSxt7tM22h2NH7e
         y4s8wLpkfKMDGC7RufT3ru6WW7HtqDz3cKu7FNdCKSboOyxz+1LxCeuIyQz1Ux0FII6a
         eCNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=t5TYhZmnd5L+AXUdP/jm/jEk3u8WIGaRjpSweCd/7YQ=;
        b=Z7jAaryitM28I64RIc5hTii5Q7dhWiPlkSvQfYDS1pqqUtSbL90o050NyftDXQRHdJ
         Z8JBhHkQP7lQietFYVZXj4dJ3ek7T61mg7lxqI6NLPcbA53AHJhHCAxwlSkEHhMpM7Rd
         BRYbt04u0n7phOKoNkmInqtDAxbkBatA/X2LcwRvJB1Z71/HPlJXoq7t13NnVp52Zz2b
         m/Ix+q/k06Hj55gg2DdkM1W5AopX3xXuAIaItbYgFi6rncCIxeur75nYr0UUMQb8/7+f
         TpejXCPpnB3eb8Znd+tlkunxyWeQ8CHYIzlake2vBl4SENNNXrQNKwpeeDvZTAxaUhYH
         CjFw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f7si2214874edn.259.2019.04.12.04.59.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 04:59:36 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0577EAA85;
	Fri, 12 Apr 2019 11:59:35 +0000 (UTC)
Date: Fri, 12 Apr 2019 13:59:34 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, osalvador@suse.de, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/hotplug: treat CMA pages as unmovable
Message-ID: <20190412115934.GC5223@dhcp22.suse.cz>
References: <20190411213124.8254-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190411213124.8254-1-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-04-19 17:31:24, Qian Cai wrote:
> When offlining a memory block that contains reserved CMA areas, it will
> set those page blocks migration type as MIGRATE_ISOLATE. Then, onlining
> will set them as MIGRATE_MOVABLE. As the results, those page blocks lose
> their original types, i.e., MIGRATE_CMA, and then it causes troubles
> like accounting for CMA areas becomes inconsist,

Yes migrate type based accounting sucks. Joonsoo had a patch to use a
(movable) zone for that purpose. Anyway the above description is not
really easy to grasp. At least it was not for me. Because there are
mutlitple things going on here. I would suggest something like the
following:

: has_unmovable_pages is used by both CMA allocator and the memory
: hotplug. The later doesn't know how to offline CMA pool properly
: now but if an unused (free) CMA page is encountered then
: has_unmovable_pages happily considers it as a free memory and propagates
: this up the call chain. Memory offlining code then frees the page
: without a proper CMA tear down which leads to an accounting issues.
: Moreover if the same memory range is onlined again then the memory never
: gets back to the CMA pool.
: 
: State after memory offline
:  # grep cma /proc/vmstat
:  nr_free_cma 205824
: 
:  # cat /sys/kernel/debug/cma/cma-kvm_cma/count
:  209920
: 
And continue with the following kmemleak splat

> Also, kmemleak still think those memory address are reserved but have
> already been used by the buddy allocator after onlining.
> 
> Offlined Pages 4096
> kmemleak: Cannot insert 0xc000201f7d040008 into the object search tree
> (overlaps existing)
> Call Trace:
> [c00000003dc2faf0] [c000000000884b2c] dump_stack+0xb0/0xf4 (unreliable)
> [c00000003dc2fb30] [c000000000424fb4] create_object+0x344/0x380
> [c00000003dc2fbf0] [c0000000003d178c] __kmalloc_node+0x3ec/0x860
> [c00000003dc2fc90] [c000000000319078] kvmalloc_node+0x58/0x110
> [c00000003dc2fcd0] [c000000000484d9c] seq_read+0x41c/0x620
> [c00000003dc2fd60] [c0000000004472bc] __vfs_read+0x3c/0x70
> [c00000003dc2fd80] [c0000000004473ac] vfs_read+0xbc/0x1a0
> [c00000003dc2fdd0] [c00000000044783c] ksys_read+0x7c/0x140
> [c00000003dc2fe20] [c00000000000b108] system_call+0x5c/0x70
> kmemleak: Kernel memory leak detector disabled
> kmemleak: Object 0xc000201cc8000000 (size 13757317120):
> kmemleak:   comm "swapper/0", pid 0, jiffies 4294937297
> kmemleak:   min_count = -1
> kmemleak:   count = 0
> kmemleak:   flags = 0x5
> kmemleak:   checksum = 0
> kmemleak:   backtrace:
>      cma_declare_contiguous+0x2a4/0x3b0
>      kvm_cma_reserve+0x11c/0x134
>      setup_arch+0x300/0x3f8
>      start_kernel+0x9c/0x6e8
>      start_here_common+0x1c/0x4b0
> kmemleak: Automatic memory scanning thread ended
> 
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>  mm/page_alloc.c | 20 ++++++++++++--------
>  1 file changed, 12 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d96ca5bc555b..896db9241fa6 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -8015,14 +8015,18 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  	 * can still lead to having bootmem allocations in zone_movable.
>  	 */
>  
> -	/*
> -	 * CMA allocations (alloc_contig_range) really need to mark isolate
> -	 * CMA pageblocks even when they are not movable in fact so consider
> -	 * them movable here.
> -	 */
> -	if (is_migrate_cma(migratetype) &&
> -			is_migrate_cma(get_pageblock_migratetype(page)))
> -		return false;
> +	if (is_migrate_cma(get_pageblock_migratetype(page))) {
> +		/*
> +		 * CMA allocations (alloc_contig_range) really need to mark
> +		 * isolate CMA pageblocks even when they are not movable in fact
> +		 * so consider them movable here.
> +		 */
> +		if (is_migrate_cma(migratetype))
> +			return false;
> +
> +		pr_warn("page: %px is in CMA", page);
> +		return true;

you want goto unmovable here. dum_page doesn't print the migrate type so
we will need to make the dump reason conditional defaulting to "unmovable page"
and overriding it to "CMA page" in this path.

Other than that the patch looks reasonable to me. I hate this special
casing here but this falls into the same bucket with 4da2ce250f986.

Thanks!

> +	}
>  
>  	pfn = page_to_pfn(page);
>  	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
> -- 
> 2.20.1 (Apple Git-117)

-- 
Michal Hocko
SUSE Labs

