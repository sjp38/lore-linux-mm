Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id BB6E06B0255
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 06:22:23 -0400 (EDT)
Received: by ykdt205 with SMTP id t205so37238350ykd.1
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 03:22:23 -0700 (PDT)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id n124si962064ywe.197.2015.08.13.03.22.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Aug 2015 03:22:22 -0700 (PDT)
Message-ID: <55CC6FB7.4080600@citrix.com>
Date: Thu, 13 Aug 2015 11:21:43 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [PATCHv3 01/10] mm: memory hotplug with an existing
 resource
References: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
 <1438275792-5726-2-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1438275792-5726-2-git-send-email-david.vrabel@citrix.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
Cc: Daniel Kiper <daniel.kiper@oracle.com>, linux-mm@kvack.org, Boris
 Ostrovsky <boris.ostrovsky@oracle.com>, Andrew Morton <akpm@linux-foundation.org>

On 30/07/15 18:03, David Vrabel wrote:
> Add add_memory_resource() to add memory using an existing "System RAM"
> resource.  This is useful if the memory region is being located by
> finding a free resource slot with allocate_resource().
> 
> Xen guests will make use of this in their balloon driver to hotplug
> arbitrary amounts of memory in response to toolstack requests.

Ping?  This enables a useful feature for Xen guests.

> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/memory_hotplug.h |  2 ++
>  mm/memory_hotplug.c            | 28 +++++++++++++++++++++-------
>  2 files changed, 23 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 6ffa0ac..c76d371 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -11,6 +11,7 @@ struct zone;
>  struct pglist_data;
>  struct mem_section;
>  struct memory_block;
> +struct resource;
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
>  
> @@ -266,6 +267,7 @@ static inline void remove_memory(int nid, u64 start, u64 size) {}
>  extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
>  		void *arg, int (*func)(struct memory_block *, void *));
>  extern int add_memory(int nid, u64 start, u64 size);
> +extern int add_memory_resource(int nid, struct resource *resource);
>  extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default);
>  extern int arch_add_memory(int nid, u64 start, u64 size);
>  extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 003dbe4..169770a 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1224,23 +1224,21 @@ int zone_for_memory(int nid, u64 start, u64 size, int zone_default)
>  }
>  
>  /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
> -int __ref add_memory(int nid, u64 start, u64 size)
> +int __ref add_memory_resource(int nid, struct resource *res)
>  {
> +	u64 start, size;
>  	pg_data_t *pgdat = NULL;
>  	bool new_pgdat;
>  	bool new_node;
> -	struct resource *res;
>  	int ret;
>  
> +	start = res->start;
> +	size = resource_size(res);
> +
>  	ret = check_hotplug_memory_range(start, size);
>  	if (ret)
>  		return ret;
>  
> -	res = register_memory_resource(start, size);
> -	ret = -EEXIST;
> -	if (!res)
> -		return ret;
> -
>  	{	/* Stupid hack to suppress address-never-null warning */
>  		void *p = NODE_DATA(nid);
>  		new_pgdat = !p;
> @@ -1290,6 +1288,22 @@ out:
>  	mem_hotplug_done();
>  	return ret;
>  }
> +EXPORT_SYMBOL_GPL(add_memory_resource);
> +
> +int __ref add_memory(int nid, u64 start, u64 size)
> +{
> +	struct resource *res;
> +	int ret;
> +
> +	res = register_memory_resource(start, size);
> +	if (!res)
> +		return -EEXIST;
> +
> +	ret = add_memory_resource(nid, res);
> +	if (ret < 0)
> +		release_memory_resource(res);
> +	return ret;
> +}
>  EXPORT_SYMBOL_GPL(add_memory);
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
