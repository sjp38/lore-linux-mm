Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 6718A6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 17:44:14 -0400 (EDT)
Date: Wed, 10 Apr 2013 14:44:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 2/3] resource: Add release_mem_region_adjustable()
Message-Id: <20130410144412.395bf9f2fb8192920175e30a@linux-foundation.org>
In-Reply-To: <1365614221-685-3-git-send-email-toshi.kani@hp.com>
References: <1365614221-685-1-git-send-email-toshi.kani@hp.com>
	<1365614221-685-3-git-send-email-toshi.kani@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, linuxram@us.ibm.com, guz.fnst@cn.fujitsu.com, tmac@hp.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com

On Wed, 10 Apr 2013 11:17:00 -0600 Toshi Kani <toshi.kani@hp.com> wrote:

> Added release_mem_region_adjustable(), which releases a requested
> region from a currently busy memory resource.  This interface
> adjusts the matched memory resource accordingly even if the
> requested region does not match exactly but still fits into.
> 
> This new interface is intended for memory hot-delete.  During
> bootup, memory resources are inserted from the boot descriptor
> table, such as EFI Memory Table and e820.  Each memory resource
> entry usually covers the whole contigous memory range.  Memory
> hot-delete request, on the other hand, may target to a particular
> range of memory resource, and its size can be much smaller than
> the whole contiguous memory.  Since the existing release interfaces
> like __release_region() require a requested region to be exactly
> matched to a resource entry, they do not allow a partial resource
> to be released.
> 
> This new interface is restrictive (i.e. release under certain
> conditions), which is consistent with other release interfaces,
> __release_region() and __release_resource().  Additional release
> conditions, such as an overlapping region to a resource entry,
> can be supported after they are confirmed as valid cases.
> 
> There is no change to the existing interfaces since their restriction
> is valid for I/O resources.
> 
> ...
>
> +int release_mem_region_adjustable(struct resource *parent,
> +			resource_size_t start, resource_size_t size)
> +{
> +	struct resource **p;
> +	struct resource *res, *new;
> +	resource_size_t end;
> +	int ret = -EINVAL;
> +
> +	end = start + size - 1;
> +	if ((start < parent->start) || (end > parent->end))
> +		return ret;
> +
> +	p = &parent->child;
> +	write_lock(&resource_lock);
> +
> +	while ((res = *p)) {
> +		if (res->start >= end)
> +			break;
> +
> +		/* look for the next resource if it does not fit into */
> +		if (res->start > start || res->end < end) {
> +			p = &res->sibling;
> +			continue;
> +		}
> +
> +		if (!(res->flags & IORESOURCE_MEM))
> +			break;
> +
> +		if (!(res->flags & IORESOURCE_BUSY)) {
> +			p = &res->child;
> +			continue;
> +		}
> +
> +		/* found the target resource; let's adjust accordingly */
> +		if (res->start == start && res->end == end) {
> +			/* free the whole entry */
> +			*p = res->sibling;
> +			kfree(res);
> +			ret = 0;
> +		} else if (res->start == start && res->end != end) {
> +			/* adjust the start */
> +			ret = __adjust_resource(res, end + 1,
> +						res->end - end);
> +		} else if (res->start != start && res->end == end) {
> +			/* adjust the end */
> +			ret = __adjust_resource(res, res->start,
> +						start - res->start);
> +		} else {
> +			/* split into two entries */
> +			new = kzalloc(sizeof(struct resource), GFP_KERNEL);

Nope, we can't perform a GFP_KERNEL allocation under write_lock().

Was this code path runtime tested?  If no, please try
to find a way to test it.  If yes, please see
Documentation/SubmitChecklist section 12 and use that in the future.

I'll switch it to GFP_ATOMIC.  Which is horridly lame but the
allocation is small and alternatives are unobvious.

> +			if (!new) {
> +				ret = -ENOMEM;
> +				break;
> +			}
> +			new->name = res->name;
> +			new->start = end + 1;
> +			new->end = res->end;
> +			new->flags = res->flags;
> +			new->parent = res->parent;
> +			new->sibling = res->sibling;
> +			new->child = NULL;
> +
> +			ret = __adjust_resource(res, res->start,
> +						start - res->start);
> +			if (ret) {
> +				kfree(new);
> +				break;
> +			}
> +			res->sibling = new;
> +		}
> +
> +		break;
> +	}
> +
> +	write_unlock(&resource_lock);
> +	return ret;
> +}
> +#endif	/* CONFIG_MEMORY_HOTPLUG */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
