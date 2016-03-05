Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id DF5C46B0005
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 20:56:17 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id ts10so65786263obc.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 17:56:17 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id cp8si4268515oec.98.2016.03.04.17.56.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 17:56:17 -0800 (PST)
Message-ID: <1457146138.15454.277.camel@hpe.com>
Subject: Re: [PATCH v2 2/3] libnvdimm, pmem: adjust for section collisions
 with 'System RAM'
From: Toshi Kani <toshi.kani@hpe.com>
Date: Fri, 04 Mar 2016 19:48:58 -0700
In-Reply-To: <20160303215315.1014.95661.stgit@dwillia2-desk3.amr.corp.intel.com>
References: 
	<20160303215304.1014.69931.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <20160303215315.1014.95661.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org

On Thu, 2016-03-03 at 13:53 -0800, Dan Williams wrote:
> On a platform where 'Persistent Memory' and 'System RAM' are mixed
> within a given sparsemem section, trim the namespace and notify about the
> sub-optimal alignment.
> 
> Cc: Toshi Kani <toshi.kani@hpe.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
> A drivers/nvdimm/namespace_devs.c |A A A A 7 ++
> A drivers/nvdimm/pfn.hA A A A A A A A A A A A |A A A 10 ++-
> A drivers/nvdimm/pfn_devs.cA A A A A A A |A A A A 5 ++
> A drivers/nvdimm/pmem.cA A A A A A A A A A A |A A 125 ++++++++++++++++++++++++++++-----
> ------
> A 4 files changed, 111 insertions(+), 36 deletions(-)
> 
> diff --git a/drivers/nvdimm/namespace_devs.c
> b/drivers/nvdimm/namespace_devs.c
> index 8ebfcaae3f5a..463756ca2d4b 100644
> --- a/drivers/nvdimm/namespace_devs.c
> +++ b/drivers/nvdimm/namespace_devs.c
> @@ -133,6 +133,7 @@ bool nd_is_uuid_unique(struct device *dev, u8 *uuid)
> A bool pmem_should_map_pages(struct device *dev)
> A {
> A 	struct nd_region *nd_region = to_nd_region(dev->parent);
> +	struct nd_namespace_io *nsio;
> A 
> A 	if (!IS_ENABLED(CONFIG_ZONE_DEVICE))
> A 		return false;
> @@ -143,6 +144,12 @@ bool pmem_should_map_pages(struct device *dev)
> A 	if (is_nd_pfn(dev) || is_nd_btt(dev))
> A 		return false;
> A 
> +	nsio = to_nd_namespace_io(dev);
> +	if (region_intersects(nsio->res.start, resource_size(&nsio-
> >res),
> +				IORESOURCE_SYSTEM_RAM,
> +				IORES_DESC_NONE) == REGION_MIXED)

Should this be !=A REGION_DISJOINT for safe?

> +		return false;
> +

A :

> @@ -304,21 +311,56 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
> A 	}
> A 
> A 	memset(pfn_sb, 0, sizeof(*pfn_sb));
> -	npfns = (pmem->size - SZ_8K) / SZ_4K;
> +
> +	/*
> +	A * Check if pmem collides with 'System RAM' when section aligned
> and
> +	A * trim it accordingly
> +	A */
> +	nsio = to_nd_namespace_io(&ndns->dev);
> +	start = PHYS_SECTION_ALIGN_DOWN(nsio->res.start);
> +	size = resource_size(&nsio->res);
> +	if (region_intersects(start, size, IORESOURCE_SYSTEM_RAM,
> +				IORES_DESC_NONE) == REGION_MIXED) {
> +
> +		start = nsio->res.start;
> +		start_pad = PHYS_SECTION_ALIGN_UP(start) - start;
> +	}
> +
> +	start = nsio->res.start;
> +	size = PHYS_SECTION_ALIGN_UP(start + size) - start;
> +	if (region_intersects(start, size, IORESOURCE_SYSTEM_RAM,
> +				IORES_DESC_NONE) == REGION_MIXED) {
> +		size = resource_size(&nsio->res);
> +		end_trunc = start + size - PHYS_SECTION_ALIGN_DOWN(start
> + size);
> +	}

This check seems to assume that guest's regular memory layout does not
change.A A That is, if there is no collision at first, there won't be any
later.A A Is this a valid assumption?

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
