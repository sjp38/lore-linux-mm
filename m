Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3FED56B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 12:04:15 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id rt7so110583666obb.3
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 09:04:15 -0800 (PST)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id kl7si12644264oeb.81.2016.03.07.09.04.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 09:04:14 -0800 (PST)
Message-ID: <1457373413.15454.334.camel@hpe.com>
Subject: Re: [PATCH v2 2/3] libnvdimm, pmem: adjust for section collisions
 with 'System RAM'
From: Toshi Kani <toshi.kani@hpe.com>
Date: Mon, 07 Mar 2016 10:56:53 -0700
In-Reply-To: <CAA9_cmc9vjChKqs7P1NG9r66TGapw0cYHfcajWh_O+hk433MTg@mail.gmail.com>
References: 
	<20160303215304.1014.69931.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <20160303215315.1014.95661.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <1457146138.15454.277.camel@hpe.com>
	 <CAA9_cmc9vjChKqs7P1NG9r66TGapw0cYHfcajWh_O+hk433MTg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, 2016-03-04 at 18:23 -0800, Dan Williams wrote:
> On Fri, Mar 4, 2016 at 6:48 PM, Toshi Kani <toshi.kani@hpe.com> wrote:
> > On Thu, 2016-03-03 at 13:53 -0800, Dan Williams wrote:
> > > On a platform where 'Persistent Memory' and 'System RAM' are mixed
> > > within a given sparsemem section, trim the namespace and notify about
> > > the
> > > sub-optimal alignment.
> > > 
> > > Cc: Toshi Kani <toshi.kani@hpe.com>
> > > Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> > > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > > ---
> > > A drivers/nvdimm/namespace_devs.c |A A A A 7 ++
> > > A drivers/nvdimm/pfn.hA A A A A A A A A A A A |A A A 10 ++-
> > > A drivers/nvdimm/pfn_devs.cA A A A A A A |A A A A 5 ++
> > > A drivers/nvdimm/pmem.cA A A A A A A A A A A |A A 125 ++++++++++++++++++++++++++++-
> > > ----
> > > ------
> > > A 4 files changed, 111 insertions(+), 36 deletions(-)
> > > 
> > > diff --git a/drivers/nvdimm/namespace_devs.c
> > > b/drivers/nvdimm/namespace_devs.c
> > > index 8ebfcaae3f5a..463756ca2d4b 100644
> > > --- a/drivers/nvdimm/namespace_devs.c
> > > +++ b/drivers/nvdimm/namespace_devs.c
> > > @@ -133,6 +133,7 @@ bool nd_is_uuid_unique(struct device *dev, u8
> > > *uuid)
> > > A bool pmem_should_map_pages(struct device *dev)
> > > A {
> > > A A A A A A struct nd_region *nd_region = to_nd_region(dev->parent);
> > > +A A A A A struct nd_namespace_io *nsio;
> > > 
> > > A A A A A A if (!IS_ENABLED(CONFIG_ZONE_DEVICE))
> > > A A A A A A A A A A A A A A return false;
> > > @@ -143,6 +144,12 @@ bool pmem_should_map_pages(struct device *dev)
> > > A A A A A A if (is_nd_pfn(dev) || is_nd_btt(dev))
> > > A A A A A A A A A A A A A A return false;
> > > 
> > > +A A A A A nsio = to_nd_namespace_io(dev);
> > > +A A A A A if (region_intersects(nsio->res.start, resource_size(&nsio-
> > > > res),
> > > +A A A A A A A A A A A A A A A A A A A A A A A A A A A A A IORESOURCE_SYSTEM_RAM,
> > > +A A A A A A A A A A A A A A A A A A A A A A A A A A A A A IORES_DESC_NONE) == REGION_MIXED)
> > 
> > Should this be != REGION_DISJOINT for safe?
> 
> Acutally, it's ok.A A It doesn't need to be disjoint.A A The problem is
> mixing an mm-zone within a given section.A A If the region intersects
> system-ram then devm_memremap_pages() is a no-op and we can use the
> existing page allocation and linear mapping.

Oh, I see.

> > 
> > > +A A A A A A A A A A A A A return false;
> > > +
> > 
> > A :
> > 
> > > @@ -304,21 +311,56 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
> > > A A A A A A }
> > > 
> > > A A A A A A memset(pfn_sb, 0, sizeof(*pfn_sb));
> > > -A A A A A npfns = (pmem->size - SZ_8K) / SZ_4K;
> > > +
> > > +A A A A A /*
> > > +A A A A A A * Check if pmem collides with 'System RAM' when section
> > > aligned
> > > and
> > > +A A A A A A * trim it accordingly
> > > +A A A A A A */
> > > +A A A A A nsio = to_nd_namespace_io(&ndns->dev);
> > > +A A A A A start = PHYS_SECTION_ALIGN_DOWN(nsio->res.start);
> > > +A A A A A size = resource_size(&nsio->res);
> > > +A A A A A if (region_intersects(start, size, IORESOURCE_SYSTEM_RAM,
> > > +A A A A A A A A A A A A A A A A A A A A A A A A A A A A A IORES_DESC_NONE) == REGION_MIXED) {
> > > +
> > > +A A A A A A A A A A A A A start = nsio->res.start;
> > > +A A A A A A A A A A A A A start_pad = PHYS_SECTION_ALIGN_UP(start) - start;
> > > +A A A A A }
> > > +
> > > +A A A A A start = nsio->res.start;
> > > +A A A A A size = PHYS_SECTION_ALIGN_UP(start + size) - start;
> > > +A A A A A if (region_intersects(start, size, IORESOURCE_SYSTEM_RAM,
> > > +A A A A A A A A A A A A A A A A A A A A A A A A A A A A A IORES_DESC_NONE) == REGION_MIXED) {
> > > +A A A A A A A A A A A A A size = resource_size(&nsio->res);
> > > +A A A A A A A A A A A A A end_trunc = start + size -
> > > PHYS_SECTION_ALIGN_DOWN(start
> > > + size);
> > > +A A A A A }
> > 
> > This check seems to assume that guest's regular memory layout does not
> > change.A A That is, if there is no collision at first, there won't be any
> > later.A A Is this a valid assumption?
> 
> If platform firmware changes the physical alignment during the
> lifetime of the namespace there's not much we can do.A A 

The physical alignment can be changed as long as it is large enough (see
below).

> Another problem
> not addressed by this patch is firmware choosing to hot plug system
> ram into the same section as persistent memory.A A 

Yes, and it does not have to be a hot-plug operation. A Memory size may be
changed off-line. A Data image can be copied to different guests for instant
deployment, or may be migrated to a different guest.

> As far as I can see
> all we do is ask firmware implementations to respect Linux section
> boundaries and otherwise not change alignments.

In addition to the requirement that pmem range alignment may not change,
the code also requires a regular memory range does not change to intersect
with a pmem section later. A This seems fragile to me since guest config may
vary / change as I mentioned above.

So, shouldn't the driver fails to attach when the range is not aligned by
the section size? A Since we need to place a requirement to firmware anyway,
we can simply state that it must be aligned by 128MiB (at least) on x86.
A Then, memory and pmem physical layouts can be changed as long as this
requirement is met.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
