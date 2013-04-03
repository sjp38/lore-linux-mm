Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 1B8566B003A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 15:58:27 -0400 (EDT)
Message-ID: <1365018417.11159.107.camel@misato.fc.hp.com>
Subject: Re: [PATCH 2/3] resource: Add release_mem_region_adjustable()
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 03 Apr 2013 13:46:57 -0600
In-Reply-To: <515B853D.4060003@jp.fujitsu.com>
References: <1364919450-8741-1-git-send-email-toshi.kani@hp.com>
	 <1364919450-8741-3-git-send-email-toshi.kani@hp.com>
	 <515B853D.4060003@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxram@us.ibm.com, tmac@hp.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com

On Wed, 2013-04-03 at 10:26 +0900, Yasuaki Ishimatsu wrote:
> 2013/04/03 1:17, Toshi Kani wrote:
> > Added release_mem_region_adjustable(), which releases a requested
> > region from a currently busy memory resource.  This interface
> > adjusts the matched memory resource accordingly if the requested
> > region does not match exactly but still fits into.
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
> 
> The patch looks mostly good. One nitpick below.

Thanks for reviewing all 3 patches!

> > ---
> >   include/linux/ioport.h |    2 +
> >   kernel/resource.c      |   87 ++++++++++++++++++++++++++++++++++++++++++++++++
> >   2 files changed, 89 insertions(+)
> > 
> > diff --git a/include/linux/ioport.h b/include/linux/ioport.h
> > index 85ac9b9b..0fe1a82 100644
> > --- a/include/linux/ioport.h
> > +++ b/include/linux/ioport.h
> > @@ -192,6 +192,8 @@ extern struct resource * __request_region(struct resource *,
> >   extern int __check_region(struct resource *, resource_size_t, resource_size_t);
> >   extern void __release_region(struct resource *, resource_size_t,
> >   				resource_size_t);
> > +extern int release_mem_region_adjustable(struct resource *, resource_size_t,
> > +				resource_size_t);
> >   
> >   static inline int __deprecated check_region(resource_size_t s,
> >   						resource_size_t n)
> > diff --git a/kernel/resource.c b/kernel/resource.c
> > index ae246f9..789f160 100644
> > --- a/kernel/resource.c
> > +++ b/kernel/resource.c
> > @@ -1021,6 +1021,93 @@ void __release_region(struct resource *parent, resource_size_t start,
> >   }
> >   EXPORT_SYMBOL(__release_region);
> >   
> > +/**
> > + * release_mem_region_adjustable - release a previously reserved memory region
> > + * @parent: parent resource descriptor
> > + * @start: resource start address
> > + * @size: resource region size
> > + *
> > + * The requested region is released from a currently busy memory resource.
> > + * It adjusts the matched busy memory resource accordingly if the requested
> > + * region does not match exactly but still fits into.  Existing children of
> > + * the busy memory resource must be immutable in this request.
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
> > +	int ret = 0;
> > +
> > +	p = &parent->child;
> > +	end = start + size - 1;
> > +
> > +	write_lock(&resource_lock);
> > +
> > +	while ((res = *p)) {
> > +		if (res->start > start || res->end < end) {
> > +			p = &res->sibling;
> > +			continue;
> > +		}
> > +
> > +		if (!(res->flags & IORESOURCE_MEM)) {
> > +			ret = -EINVAL;
> > +			break;
> > +		}
> > +
> > +		if (!(res->flags & IORESOURCE_BUSY)) {
> > +			p = &res->child;
> > +			continue;
> > +		}
> > +
> > +		if (res->start == start && res->end == end) {
> > +			/* free the whole entry */
> > +			*p = res->sibling;
> > +			kfree(res);
> > +		} else if (res->start == start && res->end != end) {
> > +			/* adjust the start */
> > +			ret = __adjust_resource(res, end+1,
>                                                      end + 1,

Yes, I will update as you suggested. 

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
