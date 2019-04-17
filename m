Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96C93C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 11:53:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 500E720835
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 11:53:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 500E720835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D30206B0003; Wed, 17 Apr 2019 07:53:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDDD76B0006; Wed, 17 Apr 2019 07:53:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCF316B0007; Wed, 17 Apr 2019 07:53:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6F19A6B0003
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 07:53:02 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h10so4550681edn.22
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 04:53:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=psfmQMw37rJSBYAbNQScEkb0wcakz7qjyIRn25BrGyY=;
        b=BZA1DPzFfYMU9pvTwPdtCv8EB9pLVcGdCHBcUuTMEGBxUV8BSSrnGUAL9CQ9v4EcyW
         ++srTY5d9Nf5QjVpSMkEMg4uDtK0jfvV5F+gP7GetliLrfyvbx9qrFzjXfYmXa7Ygymc
         +Zw9C6/duKwnIOuX1B7g4G9mbnBlguPQ4sFwiR0mZ/eRL8kLOVoXnZ2nx2QWKI4rMsWq
         Wa79+RGV+YnG5OBp51T1bbOcrzcf3ECAyy+D5sCHDw1vOI5N9OProBlt1FG+on73G2No
         zh1Jd3WwY2qT2+O549jM6KoVuUX51sBN4UOnitXvj6D+suqYcE0qPGP9iqaP650oaFdJ
         6F8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVX1wAeGnVBFfIXy/jQsyDXYyeSbKqF4zCDCz1T+2P3cjdG0jSJ
	sXDW90pz5xJFIXn2Di6CwUr9LrU5ScWcy/+j5yTUYYVmoKt8q0G3QhGdqj0Ec1G8VyGmNkYSLI/
	fo4IdfVKFWbW25WK598K0ClXrXbiDlk3Ljsgzy4kMZIceWZ9S3jJ6YNQ0HKOhf7Iivw==
X-Received: by 2002:a17:906:7e47:: with SMTP id z7mr16536903ejr.248.1555501981972;
        Wed, 17 Apr 2019 04:53:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxFE8KN9Gx1Gb5M8WCsNQ4Q/eQpdwIrfEehypxt+f0xS0PYFwxEISQGAGyzhezIQmJjgrb3
X-Received: by 2002:a17:906:7e47:: with SMTP id z7mr16536860ejr.248.1555501980910;
        Wed, 17 Apr 2019 04:53:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555501980; cv=none;
        d=google.com; s=arc-20160816;
        b=VjYYQ7z5G4nqQ10UFjzdUyj6F4ADSRn8OInT5hAgsCbjV2F9/4LyNBjQmBzjIfRNCU
         8cTivMMswGfVWzDb+fNU06sDMB/5lkhrbor4d+dglDtzJW/8gUu072YEDFqtzATLFTaT
         1PXqOuhuULjHF7Px6p0NaQcIpn6cvzrytoBm3IzZkfDlJbRkqTFsIPQOZS0jKXRC1+50
         LsOpxvH4lD7VVA+b6ADAAgLZ28lffK+LmXzq2Cwfd8XBPmIFdf+hCsFctcHwibb6Gsv7
         S/rG0UC6mTqfJ/B4CZkC6Ty0WYqRVnDjQ/nKiKd1e0bzsWJd3tt1pbpbYWZlNes4yfQD
         +MJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=psfmQMw37rJSBYAbNQScEkb0wcakz7qjyIRn25BrGyY=;
        b=rKXFoYVp1RVYPwzT59hLgQ5BbIRbHGU7v5pWyGKeXQQNzB+05BIE1oJq9rGKtfm4F/
         dKH1ItnHEbzK75BS0LkAQOthkcMFN4e4yZxv4mp6wpK08SL6tCM7HurVM87oFIWXqHPS
         zhSY6+fByMiLklkAFJNwhcum/zBwyW46i/N6aSowZMPfLpt413kXcGQTPh2A3qBqVz72
         EGf07anwYecGzvts9Qrhu7FvZ7NUuaDlga3H2xiRrU/GZHiWVwDzXXz8xcfIjLJmlbJP
         VBbF7TN49xQyFdgdTR3xsMJJvYe8dcBfy8fM4oDMgI1Qh4yGLdv/sGkTpXeAo0dnDvlM
         Ginw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s26si1625017ejx.262.2019.04.17.04.53.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 04:53:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 478D8AFFB;
	Wed, 17 Apr 2019 11:53:00 +0000 (UTC)
Message-ID: <1555501962.3139.10.camel@suse.de>
Subject: Re: [PATCH v1 1/4] mm/memory_hotplug: Release memory resource after
 arch_remove_memory()
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
  Michal Hocko <mhocko@suse.com>, Pavel Tatashin
 <pasha.tatashin@soleen.com>, Wei Yang <richard.weiyang@gmail.com>, Qian Cai
 <cai@lca.pw>, Arun KS <arunks@codeaurora.org>, Mathieu Malaterre
 <malat@debian.org>
Date: Wed, 17 Apr 2019 13:52:42 +0200
In-Reply-To: <20190409100148.24703-2-david@redhat.com>
References: <20190409100148.24703-1-david@redhat.com>
	 <20190409100148.24703-2-david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-04-09 at 12:01 +0200, David Hildenbrand wrote:
> __add_pages() doesn't add the memory resource, so __remove_pages()
> shouldn't remove it. Let's factor it out. Especially as it is a
> special
> case for memory used as system memory, added via add_memory() and
> friends.

I would call the special case the other way, aka: zone_device hooking
into hotplug path.

> 
> We now remove the resource after removing the sections instead of
> doing
> it the other way around. I don't think this change is problematic.
> 
> add_memory()
> 	register memory resource
> 	arch_add_memory()
> 
> remove_memory
> 	arch_remove_memory()
> 	release memory resource
> 
> While at it, explain why we ignore errors and that it only happeny if
> we remove memory in a different granularity as we added it.

In the future we may want to allow drivers to hook directly into
arch_add_memory()/arch_remove_memory(), and this will lead to different
granularity in hot_add/hot_remove operations. 

At least that was one of the conclusions I drew from the last vmemmap-
patchset.
So, we will have to see how we can handle those kind of errors.

> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Besides what Andrew pointed out about the types of start,size, I do not
see anything wrong:

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> ---
>  mm/memory_hotplug.c | 34 ++++++++++++++++++++--------------
>  1 file changed, 20 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 4970ff658055..696ed7ee5e28 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -562,20 +562,6 @@ int __remove_pages(struct zone *zone, unsigned
> long phys_start_pfn,
>  	if (is_dev_zone(zone)) {
>  		if (altmap)
>  			map_offset = vmem_altmap_offset(altmap);
> -	} else {
> -		resource_size_t start, size;
> -
> -		start = phys_start_pfn << PAGE_SHIFT;
> -		size = nr_pages * PAGE_SIZE;
> -
> -		ret = release_mem_region_adjustable(&iomem_resource,
> start,
> -					size);
> -		if (ret) {
> -			resource_size_t endres = start + size - 1;
> -
> -			pr_warn("Unable to release resource <%pa-
> %pa> (%d)\n",
> -					&start, &endres, ret);
> -		}
>  	}
>  
>  	clear_zone_contiguous(zone);
> @@ -1820,6 +1806,25 @@ void try_offline_node(int nid)
>  }
>  EXPORT_SYMBOL(try_offline_node);
>  
> +static void __release_memory_resource(u64 start, u64 size)
> +{
> +	int ret;
> +
> +	/*
> +	 * When removing memory in the same granularity as it was
> added,
> +	 * this function never fails. It might only fail if
> resources
> +	 * have to be adjusted or split. We'll ignore the error, as
> +	 * removing of memory cannot fail.
> +	 */
> +	ret = release_mem_region_adjustable(&iomem_resource, start,
> size);
> +	if (ret) {
> +		resource_size_t endres = start + size - 1;
> +
> +		pr_warn("Unable to release resource <%pa-%pa>
> (%d)\n",
> +			&start, &endres, ret);
> +	}
> +}
> +
>  /**
>   * remove_memory
>   * @nid: the node ID
> @@ -1854,6 +1859,7 @@ void __ref __remove_memory(int nid, u64 start,
> u64 size)
>  	memblock_remove(start, size);
>  
>  	arch_remove_memory(nid, start, size, NULL);
> +	__release_memory_resource(start, size);
>  
>  	try_offline_node(nid);
>  
-- 
Oscar Salvador
SUSE L3

