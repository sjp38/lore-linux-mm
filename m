Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id CBE226B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 04:23:15 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id m26so18015646wrm.5
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 01:23:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1si19582993wrd.118.2017.04.18.01.23.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 01:23:14 -0700 (PDT)
Subject: Re: [PATCH -v2 0/9] mm: make movable onlining suck less
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170410162749.7d7f31c1@nial.brq.redhat.com>
 <20170410160228.GI4618@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c5ba7d24-1ad9-5f42-3c60-96aed4cc0a17@suse.cz>
Date: Tue, 18 Apr 2017 10:23:12 +0200
MIME-Version: 1.0
In-Reply-To: <20170410160228.GI4618@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Igor Mammedov <imammedo@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tobias Regnery <tobias.regnery@gmail.com>

On 04/10/2017 06:02 PM, Michal Hocko wrote:
> On Mon 10-04-17 16:27:49, Igor Mammedov wrote:
> [...]
>> #issue3:
>> removable flag flipped to non-removable state
>>
>> // before series at commit ef0b577b6:
>> memory32:offline removable: 0  zones: Normal Movable
>> memory33:offline removable: 0  zones: Normal Movable
>> memory34:offline removable: 0  zones: Normal Movable
>> memory35:offline removable: 0  zones: Normal Movable
> 
> did you mean _after_ the series because the bellow looks like
> the original behavior (at least valid_zones).
>  
>> // after series at commit 6a010434
>> memory32:offline removable: 1  zones: Normal
>> memory33:offline removable: 1  zones: Normal
>> memory34:offline removable: 1  zones: Normal
>> memory35:offline removable: 1  zones: Normal Movable
>>
>> also looking at #issue1 removable flag state doesn't
>> seem to be consistent between state changes but maybe that's
>> been broken before
> 
> Well, the file has a very questionable semantic. It doesn't provide
> a stable information. Anyway put that aside.
> is_pageblock_removable_nolock relies on having zone association
> which we do not have yet if the memblock is offline. So we need
> the following. I will queue this as a preparatory patch.
> ---
> From 4f3ebc02f4d552d3fe114787ca8a38cc68702208 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Mon, 10 Apr 2017 17:59:03 +0200
> Subject: [PATCH] mm, memory_hotplug: consider offline memblocks removable
> 
> is_pageblock_removable_nolock relies on having zone association to
> examine all the page blocks to check whether they are movable or free.
> This is just wasting of cycles when the memblock is offline. Later patch
> in the series will also change the time when the page is associated with
> a zone so we let's bail out early if the memblock is offline.
> 
> Reported-by: Igor Mammedov <imammedo@redhat.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  drivers/base/memory.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 9677b6b711b0..0c29ec5598ea 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -128,6 +128,9 @@ static ssize_t show_mem_removable(struct device *dev,
>  	int ret = 1;
>  	struct memory_block *mem = to_memory_block(dev);
>  
> +	if (mem->stat != MEM_ONLINE)
> +		goto out;
> +
>  	for (i = 0; i < sections_per_block; i++) {
>  		if (!present_section_nr(mem->start_section_nr + i))
>  			continue;
> @@ -135,6 +138,7 @@ static ssize_t show_mem_removable(struct device *dev,
>  		ret &= is_mem_section_removable(pfn, PAGES_PER_SECTION);
>  	}
>  
> +out:
>  	return sprintf(buf, "%d\n", ret);
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
