Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1BA4D6B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 14:17:01 -0400 (EDT)
Received: by obpn3 with SMTP id n3so52385864obp.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 11:17:00 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id o10si20414019obi.22.2015.06.25.11.17.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 11:17:00 -0700 (PDT)
Date: Thu, 25 Jun 2015 20:16:51 +0200
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCHv1 4/8] xen/balloon: find non-conflicting regions to place
 hotplugged memory
Message-ID: <20150625181651.GL14050@olila.local.net-space.pl>
References: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
 <1435252263-31952-5-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1435252263-31952-5-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: xen-devel@lists.xenproject.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jun 25, 2015 at 06:10:59PM +0100, David Vrabel wrote:
> Instead of placing hotplugged memory at the end of RAM (which may
> conflict with PCI devices or reserved regions) use allocate_resource()
> to get a new, suitably aligned resource that does not conflict.
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

In general Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com>

but two nitpicks below...

> ---
>  drivers/xen/balloon.c |   63 +++++++++++++++++++++++++++++++++++++++++--------
>  1 file changed, 53 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> index fd93369..d0121ee 100644
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -54,6 +54,7 @@
>  #include <linux/memory.h>
>  #include <linux/memory_hotplug.h>
>  #include <linux/percpu-defs.h>
> +#include <linux/slab.h>
>
>  #include <asm/page.h>
>  #include <asm/pgalloc.h>
> @@ -208,6 +209,42 @@ static bool balloon_is_inflated(void)
>  		return false;
>  }
>
> +static struct resource *additional_memory_resource(phys_addr_t size)
> +{
> +	struct resource *res;
> +	int ret;
> +
> +	res = kzalloc(sizeof(*res), GFP_KERNEL);
> +	if (!res)
> +		return NULL;
> +
> +	res->name = "System RAM";
> +	res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> +
> +	ret = allocate_resource(&iomem_resource, res,
> +				size, 0, -1,
> +				PAGES_PER_SECTION * PAGE_SIZE, NULL, NULL);
> +	if (ret < 0) {
> +		pr_err("Cannot allocate new System RAM resource\n");
> +		kfree(res);
> +		return NULL;
> +	}
> +
> +	return res;
> +}
> +
> +static void release_memory_resource(struct resource *resource)
> +{
> +	if (!resource)
> +		return;

Please add one empty line here.

> +	/*
> +	 * No need to reset region to identity mapped since we now
> +	 * know that no I/O can be in this region
> +	 */
> +	release_resource(resource);
> +	kfree(resource);
> +}
> +
>  /*
>   * reserve_additional_memory() adds memory region of size >= credit above
>   * max_pfn. New region is section aligned and size is modified to be multiple
> @@ -221,13 +258,17 @@ static bool balloon_is_inflated(void)
>
>  static enum bp_state reserve_additional_memory(long credit)
>  {
> +	struct resource *resource;
>  	int nid, rc;
> -	u64 hotplug_start_paddr;
> -	unsigned long balloon_hotplug = credit;
> +	unsigned long balloon_hotplug;
> +
> +	balloon_hotplug = round_up(credit, PAGES_PER_SECTION);
> +
> +	resource = additional_memory_resource(balloon_hotplug * PAGE_SIZE);
> +	if (!resource)
> +		goto err;
>
> -	hotplug_start_paddr = PFN_PHYS(SECTION_ALIGN_UP(max_pfn));
> -	balloon_hotplug = round_up(balloon_hotplug, PAGES_PER_SECTION);
> -	nid = memory_add_physaddr_to_nid(hotplug_start_paddr);
> +	nid = memory_add_physaddr_to_nid(resource->start);
>
>  #ifdef CONFIG_XEN_HAVE_PVMMU
>          /*
> @@ -242,21 +283,20 @@ static enum bp_state reserve_additional_memory(long credit)
>  	if (!xen_feature(XENFEAT_auto_translated_physmap)) {
>  		unsigned long pfn, i;
>
> -		pfn = PFN_DOWN(hotplug_start_paddr);
> +		pfn = PFN_DOWN(resource->start);
>  		for (i = 0; i < balloon_hotplug; i++) {
>  			if (!set_phys_to_machine(pfn + i, INVALID_P2M_ENTRY)) {
>  				pr_warn("set_phys_to_machine() failed, no memory added\n");
> -				return BP_ECANCELED;
> +				goto err;
>  			}
>                  }
>  	}
>  #endif
>
> -	rc = add_memory(nid, hotplug_start_paddr, balloon_hotplug << PAGE_SHIFT);
> -
> +	rc = add_memory_resource(nid, resource);
>  	if (rc) {
>  		pr_warn("Cannot add additional memory (%i)\n", rc);
> -		return BP_ECANCELED;
> +		goto err;
>  	}
>
>  	balloon_hotplug -= credit;
> @@ -265,6 +305,9 @@ static enum bp_state reserve_additional_memory(long credit)
>  	balloon_stats.balloon_hotplug = balloon_hotplug;
>
>  	return BP_DONE;

Ditto.

> +  err:
> +	release_memory_resource(resource);
> +	return BP_ECANCELED;
>  }
>
>  static void xen_online_page(struct page *page)
> --
> 1.7.10.4

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
