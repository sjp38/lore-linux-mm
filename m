Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1EDE06B000E
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 07:52:13 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d18-v6so5304396edp.0
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 04:52:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v25-v6si1674152edb.343.2018.08.07.04.52.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 04:52:11 -0700 (PDT)
Subject: Re: [PATCH v2] resource: Merge resources on a node when hot-adding
 memory
References: <20180806065224.31383-1-rashmica.g@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5543a32a-20f9-18ff-dc13-73737257ed99@suse.cz>
Date: Tue, 7 Aug 2018 13:52:07 +0200
MIME-Version: 1.0
In-Reply-To: <20180806065224.31383-1-rashmica.g@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rashmica Gupta <rashmica.g@gmail.com>, toshi.kani@hpe.com, tglx@linutronix.de, akpm@linux-foundation.org, bp@suse.de, brijesh.singh@amd.com, thomas.lendacky@amd.com, jglisse@redhat.com, gregkh@linuxfoundation.org, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, mhocko@suse.com, iamjoonsoo.kim@lge.com, malat@debian.org, pasha.tatashin@oracle.com, bhelgaas@google.com, osalvador@techadventures.net, yasu.isimatu@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/06/2018 08:52 AM, Rashmica Gupta wrote:
> When hot-removing memory release_mem_region_adjustable() splits
> iomem resources if they are not the exact size of the memory being
> hot-deleted. Adding this memory back to the kernel adds a new
> resource.
> 
> Eg a node has memory 0x0 - 0xfffffffff. Offlining and hot-removing
> 1GB from 0xf40000000 results in the single resource 0x0-0xfffffffff being
> split into two resources: 0x0-0xf3fffffff and 0xf80000000-0xfffffffff.
> 
> When we hot-add the memory back we now have three resources:
> 0x0-0xf3fffffff, 0xf40000000-0xf7fffffff, and 0xf80000000-0xfffffffff.
> 
> Now if we try to remove a section of memory that overlaps these resources,
> like 2GB from 0xf40000000, release_mem_region_adjustable() fails as it
> expects the chunk of memory to be within the boundaries of a single
> resource.

Hi,

it's the first time I see the resource code, so I might be easily wrong.
How can it happen that the second remove is section aligned but the
first one not?

> This patch adds a function request_resource_and_merge(). This is called
> instead of request_resource_conflict() when registering a resource in
> add_memory(). It calls request_resource_conflict() and if hot-removing is
> enabled (if it isn't we won't get resource fragmentation) we attempt to
> merge contiguous resources on the node.
> 
> Signed-off-by: Rashmica Gupta <rashmica.g@gmail.com>
...
> --- a/kernel/resource.c
> +++ b/kernel/resource.c
...
> +/*
> + * Attempt to merge resources on the node
> + */
> +static void merge_node_resources(int nid, struct resource *parent)
> +{
> +	struct resource *res;
> +	uint64_t start_addr;
> +	uint64_t end_addr;
> +	int ret;
> +
> +	start_addr = node_start_pfn(nid) << PAGE_SHIFT;
> +	end_addr = node_end_pfn(nid) << PAGE_SHIFT;
> +
> +	write_lock(&resource_lock);
> +
> +	/* Get the first resource */
> +	res = parent->child;
> +
> +	while (res) {
> +		/* Check that the resource is within the node */
> +		if (res->start < start_addr) {
> +			res = res->sibling;
> +			continue;
> +		}
> +		/* Exit if resource is past end of node */
> +		if (res->sibling->end > end_addr)
> +			break;

IIUC, resource end is closed, so adjacent resources's start is end+1.
But node_end_pfn is open, so the comparison above should use '>='
instead of '>'?

> +
> +		ret = merge_resources(res);
> +		if (!ret)
> +			continue;
> +		res = res->sibling;

Should this rather use next_resource() to merge at all levels of the
hierarchy? Although memory seems to be flat under &iomem_resource so it
would be just future-proofing.

Thanks,
Vlastimil
