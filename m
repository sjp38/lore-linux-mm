Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7543B6B03F9
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 04:15:06 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u18so5104429wrc.17
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 01:15:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f3si1874205wme.93.2017.04.06.01.15.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 01:15:04 -0700 (PDT)
Date: Thu, 6 Apr 2017 10:14:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/6] mm, memory_hotplug: do not associate hotadded memory
 to zones until online
Message-ID: <20170406081459.GE5497@dhcp22.suse.cz>
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170330115454.32154-6-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170330115454.32154-6-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Dan Williams <dan.j.williams@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu 30-03-17 13:54:53, Michal Hocko wrote:
[...]
> -static int __meminit __add_section(int nid, struct zone *zone,
> -					unsigned long phys_start_pfn)
> +static int __meminit __add_section(int nid, unsigned long phys_start_pfn)
>  {
>  	int ret;
> +	int i;
>  
>  	if (pfn_valid(phys_start_pfn))
>  		return -EEXIST;
>  
> -	ret = sparse_add_one_section(zone, phys_start_pfn);
> -
> +	ret = sparse_add_one_section(NODE_DATA(nid), phys_start_pfn);
>  	if (ret < 0)
>  		return ret;
>  
> -	ret = __add_zone(zone, phys_start_pfn);
> +	/*
> +	 * Make all the pages reserved so that nobody will stumble over half
> +	 * initialized state.
> +	 */
> +	for (i = 0; i < PAGES_PER_SECTION; i++) {
> +		unsigned long pfn = phys_start_pfn + i;
> +		if (!pfn_valid(pfn))
> +			continue;
>  
> -	if (ret < 0)
> -		return ret;
> +		SetPageReserved(pfn_to_page(phys_start_pfn + i));
> +	}
>  
>  	return register_new_memory(nid, __pfn_to_section(phys_start_pfn));

I have just realized one more dependency on the zone initialization.
register_new_memory relies on is_zone_device_section to rule out
memblock specific operations including sysfs infrastructure. I have come
up with the following to handle this.
---
