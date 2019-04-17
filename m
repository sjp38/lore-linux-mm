Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD2F6C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:13:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93BC521773
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:13:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93BC521773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DEDF6B0005; Wed, 17 Apr 2019 09:13:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28F826B0006; Wed, 17 Apr 2019 09:13:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17FFC6B0007; Wed, 17 Apr 2019 09:13:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC4326B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 09:13:01 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id q17so1625162eda.13
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 06:13:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/7SAxIswgcYa/36crrMUQq75tMZqNqiCCsXbUn5QQOg=;
        b=um7UuAKD03AcOTVSw3GmitUWJt35kLZ3AWveFMhaf0Ezxae32yvHocWE7T/hrSnlvK
         x9h7Sjo3VoZTjcC8+Zm3IUnf3Ly+cVksrDrKPGm+I3FMkaX2qc5s1zizVR2BmsGBbP2Y
         K9aOVRVbJ+0lXk/8YRQ+/Yn/iZeqOwWVw626FwdJMXrEiOjBcJ/O3vtffrgeRKHbutjB
         Tk53Tial4i4aP6iu2t1q0VBDuQIUyJ+Q6Rq1SyKpcQjrrggQKwm3lACdhDKkF3GsfvUx
         H5UKf4idWQzhZuZt3OE0NTRwjnnl6xmO2mVZ0cYICYEhw2cKvbqG3qPDMO9kOFa3Xe86
         uzdw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVJWOmLs2leUpm2gGxYh1Al/g9PBO0Gnxfh5wT2YdiWc1oDbg2a
	z0V1c76bTOnYKiH2jKsu6sUsabQJ9nkUHtN+ZcW/aRhgj4wOcKzI7opthaELr4rRlt5njyQFvnq
	W+0n6xWXQtE31QPsO9QH6kvVbpjKjby42CjEzKBA5ihgeQiBiaOsFhu8C41POuaQ=
X-Received: by 2002:a50:8b24:: with SMTP id l33mr37926586edl.235.1555506781236;
        Wed, 17 Apr 2019 06:13:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3nEqCgelNwZH4BYv8HcVSxlD999YhpcBLGp1/f4VIjVXGvTS7pqolxIdnq7SPxX9rhuz/
X-Received: by 2002:a50:8b24:: with SMTP id l33mr37926526edl.235.1555506780204;
        Wed, 17 Apr 2019 06:13:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555506780; cv=none;
        d=google.com; s=arc-20160816;
        b=ZuWJo8ObpWdIBaKDBzW/uh9ybpcBMSFNCe0doQy9Vzm1uTvKPQZ6Z/4g/YRWmot7K4
         43Map3gIv6f8XWoQ5xCJO+9+jNGWPpxNjYlBxl9paehqkk7x8KuCmf7hQO6Uwgr9z9wO
         +/PFwQCV/HlxC5GLx8MLLdW3Unw//kJe7nqxGTv2/4x9sviqto/U9w4RYyDcf9D0Sm2P
         p0aXAowHUQkVdoVSz0KGiNU0oEm15nQ/R7ZRvbTO+uTAJ21X1xkyUsMzsBzhERhNZWug
         LOEu7pPWGP/YMttAfr+W3vuoKDdoWvyXnOQz+6pw+E39MMpHg61rPXvSobvLY/iPthmx
         zbVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/7SAxIswgcYa/36crrMUQq75tMZqNqiCCsXbUn5QQOg=;
        b=m5qbPfii9kpGQdstJIq0IfaWfzlhuTbV/YwNbUReI42uaQlU7e3reXqAF3DztOkZKP
         qZSCflY5A5ti6HItbnF026vML2QPEYTC3Q1w0NK8ZlNO6d+38TC+76LNI49TJWTr6OGv
         GeiQB13A5CvXsIfH6ZIeUNQuV0e3Mgd2hJMEL9hb5uuzpVsvsgntB/n6ivycAV/AKgf8
         x2ZaOSLlQhs1pWt8ZHDJLiDnOZgT0IC8kThkTy+qd3fqFtubraq/azvEmv/ioeDwfOlt
         qk7wCITtXaCdxPDttZdcAe8v56Ubt0uuk0jfJLH80fl4NdcXKQWuKsKCgqzkrvDML4bE
         y1DQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w3si4147597ejf.257.2019.04.17.06.13.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 06:13:00 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 51D34B171;
	Wed, 17 Apr 2019 13:12:59 +0000 (UTC)
Date: Wed, 17 Apr 2019 15:12:58 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: Re: [PATCH v1 1/4] mm/memory_hotplug: Release memory resource after
 arch_remove_memory()
Message-ID: <20190417131258.GI5878@dhcp22.suse.cz>
References: <20190409100148.24703-1-david@redhat.com>
 <20190409100148.24703-2-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190409100148.24703-2-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 09-04-19 12:01:45, David Hildenbrand wrote:
> __add_pages() doesn't add the memory resource, so __remove_pages()
> shouldn't remove it. Let's factor it out. Especially as it is a special
> case for memory used as system memory, added via add_memory() and
> friends.
> 
> We now remove the resource after removing the sections instead of doing
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

OK, I agree that the symmetry is good in general and it certainly makes
sense here as well. But does it make sense to pick up this particular
part without larger considerations of add vs. remove apis? I have a
strong feeling this wouldn't be the only thing to care about. In other
words does this help future changes or it is more likely to cause more
code conflicts with other features being developed right now?

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
> ---
>  mm/memory_hotplug.c | 34 ++++++++++++++++++++--------------
>  1 file changed, 20 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 4970ff658055..696ed7ee5e28 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -562,20 +562,6 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
>  	if (is_dev_zone(zone)) {
>  		if (altmap)
>  			map_offset = vmem_altmap_offset(altmap);
> -	} else {
> -		resource_size_t start, size;
> -
> -		start = phys_start_pfn << PAGE_SHIFT;
> -		size = nr_pages * PAGE_SIZE;
> -
> -		ret = release_mem_region_adjustable(&iomem_resource, start,
> -					size);
> -		if (ret) {
> -			resource_size_t endres = start + size - 1;
> -
> -			pr_warn("Unable to release resource <%pa-%pa> (%d)\n",
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
> +	 * When removing memory in the same granularity as it was added,
> +	 * this function never fails. It might only fail if resources
> +	 * have to be adjusted or split. We'll ignore the error, as
> +	 * removing of memory cannot fail.
> +	 */
> +	ret = release_mem_region_adjustable(&iomem_resource, start, size);
> +	if (ret) {
> +		resource_size_t endres = start + size - 1;
> +
> +		pr_warn("Unable to release resource <%pa-%pa> (%d)\n",
> +			&start, &endres, ret);
> +	}
> +}
> +
>  /**
>   * remove_memory
>   * @nid: the node ID
> @@ -1854,6 +1859,7 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
>  	memblock_remove(start, size);
>  
>  	arch_remove_memory(nid, start, size, NULL);
> +	__release_memory_resource(start, size);
>  
>  	try_offline_node(nid);
>  
> -- 
> 2.17.2
> 

-- 
Michal Hocko
SUSE Labs

