Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 1AEDC6B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 15:14:50 -0400 (EDT)
Message-ID: <1365534150.32127.55.camel@misato.fc.hp.com>
Subject: Re: [UPDATE][PATCH v2 2/3] resource: Add
 release_mem_region_adjustable()
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 09 Apr 2013 13:02:30 -0600
In-Reply-To: <20130409054825.GB7251@ram.oc3035372033.ibm.com>
References: <1365457655-7453-1-git-send-email-toshi.kani@hp.com>
	 <20130409054825.GB7251@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "Makphaibulchoke, Thavatchai" <thavatchai.makpahibulchoke@hp.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "tangchen@cn.fujitsu.com" <tangchen@cn.fujitsu.com>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>

On Tue, 2013-04-09 at 05:48 +0000, Ram Pai wrote:
> On Mon, Apr 08, 2013 at 03:47:35PM -0600, Toshi Kani wrote:
> > Added release_mem_region_adjustable(), which releases a requested
> > region from a currently busy memory resource.  This interface
> > adjusts the matched memory resource accordingly even if the
> > requested region does not match exactly but still fits into.
> > 
> > This new interface is intended for memory hot-delete.  During
> > bootup, memory resources are inserted from the boot descriptor
> > table, such as EFI Memory Table and e820.  Each memory resource
> > entry usually covers the whole contigous memory range.  Memory
> > hot-delete request, on the other hand, may target to a particular
> > range of memory resource, and its size can be much smaller than
> > the whole contiguous memory.  Since the existing release interfaces
> > like __release_region() require a requested region to be exactly
> > matched to a resource entry, they do not allow a partial resource
> > to be released.
> > 
> > There is no change to the existing interfaces since their restriction
> > is valid for I/O resources.
> > 
> > Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> > Reviewed-by : Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> > ---
> > 
> > Added #ifdef CONFIG_MEMORY_HOTPLUG as suggested by Andrew Morton.
> > 
> > ---
> >  include/linux/ioport.h |    4 ++
> >  kernel/resource.c      |   96 ++++++++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 100 insertions(+)
> > 
> > diff --git a/include/linux/ioport.h b/include/linux/ioport.h
> > index 85ac9b9b..961d4dc 100644
> > --- a/include/linux/ioport.h
> > +++ b/include/linux/ioport.h
> > @@ -192,6 +192,10 @@ extern struct resource * __request_region(struct resource *,
> >  extern int __check_region(struct resource *, resource_size_t, resource_size_t);
> >  extern void __release_region(struct resource *, resource_size_t,
> >  				resource_size_t);
> > +#ifdef CONFIG_MEMORY_HOTPLUG
> > +extern int release_mem_region_adjustable(struct resource *, resource_size_t,
> > +				resource_size_t);
> > +#endif
> > 
> >  static inline int __deprecated check_region(resource_size_t s,
> >  						resource_size_t n)
> > diff --git a/kernel/resource.c b/kernel/resource.c
> > index ae246f9..25b945c 100644
> > --- a/kernel/resource.c
> > +++ b/kernel/resource.c
> > @@ -1021,6 +1021,102 @@ void __release_region(struct resource *parent, resource_size_t start,
> >  }
> >  EXPORT_SYMBOL(__release_region);
> > 
> > +#ifdef CONFIG_MEMORY_HOTPLUG
> > +/**
> > + * release_mem_region_adjustable - release a previously reserved memory region
> > + * @parent: parent resource descriptor
> > + * @start: resource start address
> > + * @size: resource region size
> > + *
> > + * This interface is intended for memory hot-delete.  The requested region is
> > + * released from a currently busy memory resource.  It adjusts the matched
> > + * busy memory resource accordingly even if the requested region does not
> > + * match exactly but still fits into.  Existing children of the busy memory
> > + * resource must be immutable in this request.
> > + *
> > + * Note, when the busy memory resource gets split into two entries, the code
> > + * assumes that all children remain in the lower address entry for simplicity.
> > + * Enhance this logic when necessary.
> > + */
> > +int release_mem_region_adjustable(struct resource *parent,
> > +			resource_size_t start, resource_size_t size)
> > +{
> > +	struct resource **p;
> > +	struct resource *res, *new;
> > +	resource_size_t end;
> > +	int ret = -EINVAL;
> > +
> > +	end = start + size - 1;
> > +	if ((start < parent->start) || (end > parent->end))
> > +		return ret;
> > +
> > +	p = &parent->child;
> > +	write_lock(&resource_lock);
> > +
> > +	while ((res = *p)) {
> > +		if (res->start >= end)
> > +			break;
> > +
> > +		/* look for the next resource if it does not fit into */
> > +		if (res->start > start || res->end < end) {
> > +			p = &res->sibling;
> > +			continue;
> > +		}
> 
> What if the resource overlaps. In other words, the res->start > start 
> but res->end > end  ? 
> 
> Also do you handle the case where the range <start,end> spans
> across multiple adjacent resources?

Good questions!  The two cases above are handled as error cases
(-EINVAL) by design.  A requested region must either match exactly or
fit into a single resource entry.  There are basically two design
choices in release -- restrictive or non-restrictive.  Restrictive only
releases under certain conditions, and non-restrictive releases under
any conditions.  Since the existing release interfaces,
__release_region() and __release_resource(), are restrictive, I intend
to follow the same policy and made this new interface restrictive as
well.  This new interface handles the common scenarios of memory
hot-plug operations well.  I think your example cases are non-typical
scenarios for memory hot-plug, and I am not sure if they happen under
normal cases at this point.  Hence, they are handled as error cases for
now.  We can always enhance this interface when we find them necessary
to support as this interface is dedicated for memory hot-plug.  In other
words, we should make such enhancement after we understand their
scenarios well.  Does it make sense?

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
