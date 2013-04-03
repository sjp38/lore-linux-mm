Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id ED1E06B00AF
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 03:39:04 -0400 (EDT)
Message-ID: <515BDC3B.2000907@cn.fujitsu.com>
Date: Wed, 03 Apr 2013 15:37:31 +0800
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] resource: Add release_mem_region_adjustable()
References: <1364919450-8741-1-git-send-email-toshi.kani@hp.com> <1364919450-8741-3-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1364919450-8741-3-git-send-email-toshi.kani@hp.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxram@us.ibm.com, tmac@hp.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com

On 04/03/2013 12:17 AM, Toshi Kani wrote:

> Added release_mem_region_adjustable(), which releases a requested
> region from a currently busy memory resource.  This interface
> adjusts the matched memory resource accordingly if the requested
> region does not match exactly but still fits into.
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
> There is no change to the existing interfaces since their restriction
> is valid for I/O resources.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> ---
>  include/linux/ioport.h |    2 +
>  kernel/resource.c      |   87 ++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 89 insertions(+)
> 
> diff --git a/include/linux/ioport.h b/include/linux/ioport.h
> index 85ac9b9b..0fe1a82 100644
> --- a/include/linux/ioport.h
> +++ b/include/linux/ioport.h
> @@ -192,6 +192,8 @@ extern struct resource * __request_region(struct resource *,
>  extern int __check_region(struct resource *, resource_size_t, resource_size_t);
>  extern void __release_region(struct resource *, resource_size_t,
>  				resource_size_t);
> +extern int release_mem_region_adjustable(struct resource *, resource_size_t,
> +				resource_size_t);
>  
>  static inline int __deprecated check_region(resource_size_t s,
>  						resource_size_t n)
> diff --git a/kernel/resource.c b/kernel/resource.c
> index ae246f9..789f160 100644
> --- a/kernel/resource.c
> +++ b/kernel/resource.c
> @@ -1021,6 +1021,93 @@ void __release_region(struct resource *parent, resource_size_t start,
>  }
>  EXPORT_SYMBOL(__release_region);
>  
> +/**
> + * release_mem_region_adjustable - release a previously reserved memory region
> + * @parent: parent resource descriptor
> + * @start: resource start address
> + * @size: resource region size
> + *
> + * The requested region is released from a currently busy memory resource.
> + * It adjusts the matched busy memory resource accordingly if the requested
> + * region does not match exactly but still fits into.  Existing children of
> + * the busy memory resource must be immutable in this request.
> + *
> + * Note, when the busy memory resource gets split into two entries, the code
> + * assumes that all children remain in the lower address entry for simplicity.
> + * Enhance this logic when necessary.
> + */
> +int release_mem_region_adjustable(struct resource *parent,
> +			resource_size_t start, resource_size_t size)
> +{
> +	struct resource **p;
> +	struct resource *res, *new;
> +	resource_size_t end;
> +	int ret = 0;
> +
> +	p = &parent->child;
> +	end = start + size - 1;
> +
> +	write_lock(&resource_lock);
> +
> +	while ((res = *p)) {
> +		if (res->start > start || res->end < end) {
> +			p = &res->sibling;
> +			continue;
> +		}
> +
> +		if (!(res->flags & IORESOURCE_MEM)) {
> +			ret = -EINVAL;
> +			break;
> +		}
> +
> +		if (!(res->flags & IORESOURCE_BUSY)) {
> +			p = &res->child;
> +			continue;
> +		}
> +
> +		if (res->start == start && res->end == end) {
> +			/* free the whole entry */
> +			*p = res->sibling;
> +			kfree(res);
> +		} else if (res->start == start && res->end != end) {
> +			/* adjust the start */
> +			ret = __adjust_resource(res, end+1,
> +						res->end - end);
> +		} else if (res->start != start && res->end == end) {
> +			/* adjust the end */
> +			ret = __adjust_resource(res, res->start,
> +						start - res->start);
> +		} else {
> +			/* split into two entries */
> +			new = kzalloc(sizeof(struct resource), GFP_KERNEL);
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
> +

Hi Toshi,
  What about the following small changes? Maybe it can make the code more rigorous~

Thanks,
Gu

int release_mem_region_adjustable(struct resource *parent,
                        resource_size_t start, resource_size_t size)
{
        struct resource **p;
        struct resource *res, *new;
        resource_size_t end;
        int ret = 0;

        end = start + size - 1;
        if ((start < parent->start) || (end > parent->end))
                return -EINVAL;

        p = &parent->child;

        write_lock(&resource_lock);

        while (res = *p) {
                if (res->start <= start && res->end >= end) {
                        if (!(res->flags & IORESOURCE_MEM)) {
                                ret = -EINVAL;
                                break;
                        }  

                        if (!(res->flags & IORESOURCE_BUSY)) {
                                p = &res->child;
                                continue;
                        }   

                        if (res->start == start && res->end == end) {
                                /* free the whole entry */
                                *p = res->sibling;
                                kfree(res);
                        } else if (res->start == start && res->end != end) {
                                /* adjust the start */
                                ret = __adjust_resource(res, end+1,
                                                res->end - end);
                        } else if (res->start != start && res->end == end) {
                                /* adjust the end */
                                ret = __adjust_resource(res, res->start,
                                                start - res->start);
                        } else {
                                /* split into two entries */
                                new = kzalloc(sizeof(struct resource), GFP_KERNEL);
                                if (!new) {
                                        ret = -ENOMEM;
                                        break;
                                }   
                                new->name = res->name;
                                new->start = end + 1;
                                new->end = res->end;
                                new->flags = res->flags;
                                new->parent = res->parent;
                                new->sibling = res->sibling;
                                new->child = NULL;

                                ret = __adjust_resource(res, res->start,
                                                start - res->start);
                                if (ret) {
                                        kfree(new);
                                        break;
                                }   
                                res->sibling = new;
                        }   
                        break;
                }   
                p = &res->sibling;
        }   

        write_unlock(&resource_lock);
        return ret;
}

>  /*
>   * Managed region resource
>   */
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
