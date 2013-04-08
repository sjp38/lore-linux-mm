Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id DAD156B00FC
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 10:38:54 -0400 (EDT)
Message-ID: <1365431196.2186.3.camel@misato.fc.hp.com>
Subject: Re: [UPDATE][PATCH 2/3] resource: Add
 release_mem_region_adjustable()
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 08 Apr 2013 08:26:36 -0600
In-Reply-To: <516224E4.5010409@jp.fujitsu.com>
References: <1365031405-25206-1-git-send-email-toshi.kani@hp.com>
	 <516224E4.5010409@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxram@us.ibm.com, guz.fnst@cn.fujitsu.com, tmac@hp.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com

On Mon, 2013-04-08 at 11:01 +0900, Yasuaki Ishimatsu wrote:
> Hi Toshi,
> 
> 2013/04/04 8:23, Toshi Kani wrote:
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
> Reviewed-by : Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Great!  Thanks Yasuaki!

> One nitpick below.
> 

(snip)

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
> > +	int ret = -EINVAL;
> > +
> 
> > +	end = start + size - 1;
> > +	if ((start < parent->start) || (end > parent->end))
> > +		return -EINVAL;
> 
> "ret" is initialized to -EINVAL. So how about use it?

Sounds good.  I will make the change.

Thanks again,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
