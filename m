Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7593A6B0007
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 10:14:40 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g11-v6so4082346edi.8
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 07:14:40 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b19-v6si729155edb.96.2018.08.06.07.14.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 07:14:37 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w76EEWoE143545
	for <linux-mm@kvack.org>; Mon, 6 Aug 2018 10:14:35 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kpppdkmb9-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 06 Aug 2018 10:14:35 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 6 Aug 2018 15:14:26 +0100
Date: Mon, 6 Aug 2018 17:14:13 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] resource: Merge resources on a node when hot-adding
 memory
References: <20180806065224.31383-1-rashmica.g@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180806065224.31383-1-rashmica.g@gmail.com>
Message-Id: <20180806141412.GC6636@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rashmica Gupta <rashmica.g@gmail.com>
Cc: toshi.kani@hpe.com, tglx@linutronix.de, akpm@linux-foundation.org, bp@suse.de, brijesh.singh@amd.com, thomas.lendacky@amd.com, jglisse@redhat.com, gregkh@linuxfoundation.org, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, mhocko@suse.com, iamjoonsoo.kim@lge.com, vbabka@suse.cz, malat@debian.org, pasha.tatashin@oracle.com, bhelgaas@google.com, osalvador@techadventures.net, yasu.isimatu@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Aug 06, 2018 at 04:52:24PM +1000, Rashmica Gupta wrote:
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
> 
> This patch adds a function request_resource_and_merge(). This is called
> instead of request_resource_conflict() when registering a resource in
> add_memory(). It calls request_resource_conflict() and if hot-removing is
> enabled (if it isn't we won't get resource fragmentation) we attempt to
> merge contiguous resources on the node.
> 
> Signed-off-by: Rashmica Gupta <rashmica.g@gmail.com>
> ---
> v1->v2: Only attempt to merge resources if hot-remove is enabled.
> 
>  include/linux/ioport.h         |   2 +
>  include/linux/memory_hotplug.h |   2 +-
>  kernel/resource.c              | 116 +++++++++++++++++++++++++++++++++++++++++
>  mm/memory_hotplug.c            |  22 ++++----
>  4 files changed, 130 insertions(+), 12 deletions(-)
> 
> diff --git a/include/linux/ioport.h b/include/linux/ioport.h
> index da0ebaec25f0..f5b93a711e86 100644
> --- a/include/linux/ioport.h
> +++ b/include/linux/ioport.h
> @@ -189,6 +189,8 @@ extern int allocate_resource(struct resource *root, struct resource *new,
>  						       resource_size_t,
>  						       resource_size_t),
>  			     void *alignf_data);
> +extern struct resource *request_resource_and_merge(struct resource *parent,
> +						   struct resource *new, int nid);
>  struct resource *lookup_resource(struct resource *root, resource_size_t start);
>  int adjust_resource(struct resource *res, resource_size_t start,
>  		    resource_size_t size);
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 4e9828cda7a2..9c00f97c8cc6 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -322,7 +322,7 @@ static inline void remove_memory(int nid, u64 start, u64 size) {}
>  extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
>  		void *arg, int (*func)(struct memory_block *, void *));
>  extern int add_memory(int nid, u64 start, u64 size);
> -extern int add_memory_resource(int nid, struct resource *resource, bool online);
> +extern int add_memory_resource(int nid, u64 start, u64 size, bool online);

The add_memory_resource() function is also used by Xen balloon. It should
be updated as well.

>  extern int arch_add_memory(int nid, u64 start, u64 size,
>  		struct vmem_altmap *altmap, bool want_memblock);
>  extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
> diff --git a/kernel/resource.c b/kernel/resource.c
> index 30e1bc68503b..5967061f9cea 100644
> --- a/kernel/resource.c
> +++ b/kernel/resource.c
> @@ -1621,3 +1621,119 @@ static int __init strict_iomem(char *str)
>  }
> 
>  __setup("iomem=", strict_iomem);
> +
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +/*
> + * Attempt to merge resource and it's sibling
> + */
> +static int merge_resources(struct resource *res)
> +{
> +	struct resource *next;
> +	struct resource *tmp;
> +	uint64_t size;
> +	int ret = -EINVAL;
> +
> +	next = res->sibling;
> +
> +	/*
> +	 * Not sure how to handle two different children. So only attempt
> +	 * to merge two resources if neither have children, only one has a
> +	 * child or if both have the same child.
> +	 */
> +	if ((res->child && next->child) && (res->child != next->child))
> +		return ret;
> +
> +	if (res->end + 1 != next->start)
> +		return ret;
> +
> +	if (res->flags != next->flags)
> +		return ret;
> +
> +	/* Update sibling and child of resource */
> +	res->sibling = next->sibling;
> +	tmp = res->child;
> +	if (!res->child)
> +		res->child = next->child;
> +
> +	size = next->end - res->start + 1;
> +	ret = __adjust_resource(res, res->start, size);
> +	if (ret) {
> +		/* Failed so restore resource to original state */
> +		res->sibling = next;
> +		res->child = tmp;
> +		return ret;
> +	}
> +
> +	free_resource(next);
> +
> +	return ret;
> +}
> +
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
> +
> +		ret = merge_resources(res);
> +		if (!ret)
> +			continue;
> +		res = res->sibling;
> +	}
> +	write_unlock(&resource_lock);
> +}
> +#endif /* CONFIG_MEMORY_HOTREMOVE */
> +
> +/**
> + * request_resource_and_merge() - request an I/O or memory resource for hot-add
> + * @parent: parent resource descriptor
> + * @new: resource descriptor desired by caller
> + * @nid: node id of the node we want the resource on
> + *
> + * Returns NULL for success and conflict resource on error.
> + * If no conflict resource then attempt to merge resources on the node.

Please put the return value description at the end and start it with
'Return:' rather than 'Returns'

> + *
> + * This is intended to cleanup the fragmentation of resources that occurs when
> + * hot-removing memory (see release_mem_region_adjustable). If hot-removing is
> + * not enabled then there is no point trying to merge resources.

I think it's worth noting that inability to merge the resources is not an
error.

> + */
> +struct resource *request_resource_and_merge(struct resource *parent,
> +					    struct resource *new, int nid)
> +{
> +	struct resource *conflict;
> +
> +	conflict = request_resource_conflict(parent, new);
> +
> +	if (conflict)
> +		return conflict;
> +
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +	merge_node_resources(nid, parent);
> +#endif /* CONFIG_MEMORY_HOTREMOVE */
> +
> +	return NULL;
> +}
> +#endif /* CONFIG_MEMORY_HOTPLUG */
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 7deb49f69e27..2e342f5ce322 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -97,7 +97,7 @@ void mem_hotplug_done(void)
>  }
> 
>  /* add this memory to iomem resource */
> -static struct resource *register_memory_resource(u64 start, u64 size)
> +static struct resource *register_memory_resource(int nid, u64 start, u64 size)
>  {
>  	struct resource *res, *conflict;
>  	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
> @@ -108,7 +108,7 @@ static struct resource *register_memory_resource(u64 start, u64 size)
>  	res->start = start;
>  	res->end = start + size - 1;
>  	res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
> -	conflict =  request_resource_conflict(&iomem_resource, res);
> +	conflict =  request_resource_and_merge(&iomem_resource, res, nid);
>  	if (conflict) {
>  		if (conflict->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY) {
>  			pr_debug("Device unaddressable memory block "
> @@ -122,11 +122,15 @@ static struct resource *register_memory_resource(u64 start, u64 size)
>  	return res;
>  }
> 
> -static void release_memory_resource(struct resource *res)
> +static void release_memory_resource(struct resource *res, u64 start, u64 size)
>  {
>  	if (!res)
>  		return;
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +	release_mem_region_adjustable(&iomem_resource, start, size);
> +#else
>  	release_resource(res);
> +#endif
>  	kfree(res);
>  	return;
>  }
> @@ -1096,17 +1100,13 @@ static int online_memory_block(struct memory_block *mem, void *arg)
>  }
> 
>  /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
> -int __ref add_memory_resource(int nid, struct resource *res, bool online)
> +int __ref add_memory_resource(int nid, u64 start, u64 size, bool online)
>  {
> -	u64 start, size;
>  	pg_data_t *pgdat = NULL;
>  	bool new_pgdat;
>  	bool new_node;
>  	int ret;
> 
> -	start = res->start;
> -	size = resource_size(res);
> -
>  	ret = check_hotplug_memory_range(start, size);
>  	if (ret)
>  		return ret;
> @@ -1195,13 +1195,13 @@ int __ref add_memory(int nid, u64 start, u64 size)
>  	struct resource *res;
>  	int ret;
> 
> -	res = register_memory_resource(start, size);
> +	res = register_memory_resource(nid, start, size);
>  	if (IS_ERR(res))
>  		return PTR_ERR(res);
> 
> -	ret = add_memory_resource(nid, res, memhp_auto_online);
> +	ret = add_memory_resource(nid, start, size, memhp_auto_online);
>  	if (ret < 0)
> -		release_memory_resource(res);
> +		release_memory_resource(res, start, size);
>  	return ret;
>  }
>  EXPORT_SYMBOL_GPL(add_memory);
> -- 
> 2.14.4
> 

-- 
Sincerely yours,
Mike.
