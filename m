Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id DA4816B00AC
	for <linux-mm@kvack.org>; Sat, 16 Feb 2013 01:21:11 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id wy12so895185pbc.35
        for <linux-mm@kvack.org>; Fri, 15 Feb 2013 22:21:11 -0800 (PST)
Message-ID: <511F254D.2010909@gmail.com>
Date: Sat, 16 Feb 2013 14:21:01 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 2/8] zsmalloc: add documentation
References: <1360780731-11708-1-git-send-email-sjenning@linux.vnet.ibm.com> <1360780731-11708-3-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1360780731-11708-3-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 02/14/2013 02:38 AM, Seth Jennings wrote:
> This patch adds a documentation file for zsmalloc at
> Documentation/vm/zsmalloc.txt
>
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> ---
>   Documentation/vm/zsmalloc.txt |   68 +++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 68 insertions(+)
>   create mode 100644 Documentation/vm/zsmalloc.txt
>
> diff --git a/Documentation/vm/zsmalloc.txt b/Documentation/vm/zsmalloc.txt
> new file mode 100644
> index 0000000..85aa617
> --- /dev/null
> +++ b/Documentation/vm/zsmalloc.txt
> @@ -0,0 +1,68 @@
> +zsmalloc Memory Allocator
> +
> +Overview
> +
> +zmalloc a new slab-based memory allocator,
> +zsmalloc, for storing compressed pages.  It is designed for
> +low fragmentation and high allocation success rate on
> +large object, but <= PAGE_SIZE allocations.
> +
> +zsmalloc differs from the kernel slab allocator in two primary
> +ways to achieve these design goals.
> +
> +zsmalloc never requires high order page allocations to back
> +slabs, or "size classes" in zsmalloc terms. Instead it allows
> +multiple single-order pages to be stitched together into a
> +"zspage" which backs the slab.  This allows for higher allocation
> +success rate under memory pressure.
> +
> +Also, zsmalloc allows objects to span page boundaries within the
> +zspage.  This allows for lower fragmentation than could be had
> +with the kernel slab allocator for objects between PAGE_SIZE/2
> +and PAGE_SIZE.  With the kernel slab allocator, if a page compresses
> +to 60% of it original size, the memory savings gained through
> +compression is lost in fragmentation because another object of
> +the same size can't be stored in the leftover space.
> +
> +This ability to span pages results in zsmalloc allocations not being
> +directly addressable by the user.  The user is given an
> +non-dereferencable handle in response to an allocation request.
> +That handle must be mapped, using zs_map_object(), which returns
> +a pointer to the mapped region that can be used.  The mapping is
> +necessary since the object data may reside in two different
> +noncontigious pages.

Do you mean the reason of  to use a zsmalloc object must map after 
malloc is object data maybe reside in two different nocontiguous pages?

> +
> +For 32-bit systems, zsmalloc has the added benefit of being
> +able to back slabs with HIGHMEM pages, something not possible

What's the meaning of "back slabs with HIGHMEM pages"?

> +with the kernel slab allocators (SLAB or SLUB).
> +
> +Usage:
> +
> +#include <linux/zsmalloc.h>
> +
> +/* create a new pool */
> +struct zs_pool *pool = zs_create_pool("mypool", GFP_KERNEL);
> +
> +/* allocate a 256 byte object */
> +unsigned long handle = zs_malloc(pool, 256);
> +
> +/*
> + * Map the object to get a dereferenceable pointer in "read-write mode"
> + * (see zsmalloc.h for additional modes)
> + */
> +void *ptr = zs_map_object(pool, handle, ZS_MM_RW);
> +
> +/* do something with ptr */
> +
> +/*
> + * Unmap the object when done dealing with it. You should try to
> + * minimize the time for which the object is mapped since preemption
> + * is disabled during the mapped period.
> + */
> +zs_unmap_object(pool, handle);
> +
> +/* free the object */
> +zs_free(pool, handle);
> +
> +/* destroy the pool */
> +zs_destroy_pool(pool);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
