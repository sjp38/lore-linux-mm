Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 428C68E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 14:16:45 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id n39so6504417qtn.18
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 11:16:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o5si1711136qta.399.2019.01.16.11.16.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 11:16:42 -0800 (PST)
Date: Wed, 16 Jan 2019 14:16:36 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 2/4] mm/memory-hotplug: allow memory resources to be
 children
Message-ID: <20190116191635.GD3617@redhat.com>
References: <20190116181859.D1504459@viggo.jf.intel.com>
 <20190116181902.670EEBC3@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190116181902.670EEBC3@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: dave@sr71.net, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com, baiyaowei@cmss.chinamobile.com, tiwai@suse.de

On Wed, Jan 16, 2019 at 10:19:02AM -0800, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> The mm/resource.c code is used to manage the physical address
> space.  We can view the current resource configuration in
> /proc/iomem.  An example of this is at the bottom of this
> description.
> 
> The nvdimm subsystem "owns" the physical address resources which
> map to persistent memory and has resources inserted for them as
> "Persistent Memory".  We want to use this persistent memory, but
> as volatile memory, just like RAM.  The best way to do this is
> to leave the existing resource in place, but add a "System RAM"
> resource underneath it. This clearly communicates the ownership
> relationship of this memory.
> 
> The request_resource_conflict() API only deals with the
> top-level resources.  Replace it with __request_region() which
> will search for !IORESOURCE_BUSY areas lower in the resource
> tree than the top level.
> 
> We also rework the old error message a bit since we do not get
> the conflicting entry back: only an indication that we *had* a
> conflict.

We should keep the device private check (moving it in __request_region)
as device private can try to register un-use physical address (un-use
at time of device private registration) that latter can block valid
physical address the error message you are removing report such event.


> 
> We *could* also simply truncate the existing top-level
> "Persistent Memory" resource and take over the released address
> space.  But, this means that if we ever decide to hot-unplug the
> "RAM" and give it back, we need to recreate the original setup,
> which may mean going back to the BIOS tables.
> 
> This should have no real effect on the existing collision
> detection because the areas that truly conflict should be marked
> IORESOURCE_BUSY.

Still i am worrying that this might allow device private to register
itself as a child of some un-busy resource as this patch obviously
change the behavior of register_memory_resource()

What about instead explicitly providing parent resource to add_memory()
and then to register_memory_resource() so if it is provided as an
argument (!NULL) then you can __request_region(arg_res, ...) otherwise
you keep existing code intact ?

Cheers,
Jérôme


> 
> 00000000-00000fff : Reserved
> 00001000-0009fbff : System RAM
> 0009fc00-0009ffff : Reserved
> 000a0000-000bffff : PCI Bus 0000:00
> 000c0000-000c97ff : Video ROM
> 000c9800-000ca5ff : Adapter ROM
> 000f0000-000fffff : Reserved
>   000f0000-000fffff : System ROM
> 00100000-9fffffff : System RAM
>   01000000-01e071d0 : Kernel code
>   01e071d1-027dfdff : Kernel data
>   02dc6000-0305dfff : Kernel bss
> a0000000-afffffff : Persistent Memory (legacy)
>   a0000000-a7ffffff : System RAM
> b0000000-bffdffff : System RAM
> bffe0000-bfffffff : Reserved
> c0000000-febfffff : PCI Bus 0000:00
> 
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Dave Jiang <dave.jiang@intel.com>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Vishal Verma <vishal.l.verma@intel.com>
> Cc: Tom Lendacky <thomas.lendacky@amd.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: linux-nvdimm@lists.01.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Fengguang Wu <fengguang.wu@intel.com>
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> ---
> 
>  b/mm/memory_hotplug.c |   31 ++++++++++++++-----------------
>  1 file changed, 14 insertions(+), 17 deletions(-)
> 
> diff -puN mm/memory_hotplug.c~mm-memory-hotplug-allow-memory-resource-to-be-child mm/memory_hotplug.c
> --- a/mm/memory_hotplug.c~mm-memory-hotplug-allow-memory-resource-to-be-child	2018-12-20 11:48:42.317771933 -0800
> +++ b/mm/memory_hotplug.c	2018-12-20 11:48:42.322771933 -0800
> @@ -98,24 +98,21 @@ void mem_hotplug_done(void)
>  /* add this memory to iomem resource */
>  static struct resource *register_memory_resource(u64 start, u64 size)
>  {
> -	struct resource *res, *conflict;
> -	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
> -	if (!res)
> -		return ERR_PTR(-ENOMEM);
> +	struct resource *res;
> +	unsigned long flags =  IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
> +	char *resource_name = "System RAM";
>  
> -	res->name = "System RAM";
> -	res->start = start;
> -	res->end = start + size - 1;
> -	res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
> -	conflict =  request_resource_conflict(&iomem_resource, res);
> -	if (conflict) {
> -		if (conflict->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY) {
> -			pr_debug("Device unaddressable memory block "
> -				 "memory hotplug at %#010llx !\n",
> -				 (unsigned long long)start);
> -		}
> -		pr_debug("System RAM resource %pR cannot be added\n", res);
> -		kfree(res);
> +	/*
> +	 * Request ownership of the new memory range.  This might be
> +	 * a child of an existing resource that was present but
> +	 * not marked as busy.
> +	 */
> +	res = __request_region(&iomem_resource, start, size,
> +			       resource_name, flags);
> +
> +	if (!res) {
> +		pr_debug("Unable to reserve System RAM region: %016llx->%016llx\n",
> +				start, start + size);
>  		return ERR_PTR(-EEXIST);
>  	}
>  	return res;
> _
> 
